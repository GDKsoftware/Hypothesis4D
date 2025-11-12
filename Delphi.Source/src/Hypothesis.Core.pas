unit Hypothesis.Core;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  Spring.Collections;

type
  TPropertyTestFailure = class(Exception)
  private
    FOriginalValues: IList<TValue>;
    FMinimalValues: IList<TValue>;
    FIterationNumber: Integer;
    FSeed: Integer;

  public
    constructor Create(const Msg: string; const OriginalValues: IList<TValue>; const MinimalValues: IList<TValue>; const IterationNumber: Integer; const Seed: Integer);

    property OriginalValues: IList<TValue> read FOriginalValues;
    property MinimalValues: IList<TValue> read FMinimalValues;
    property IterationNumber: Integer read FIterationNumber;
    property Seed: Integer read FSeed;
  end;

  TParameterInfo = record
    ParamName: string;
    ParamType: TRttiType;
    Generator: IInterface;
  end;

  TPropertyTestRunner = class
  private
    FContext: TRttiContext;
    FSeed: Integer;

    function ExtractForAllAttribute(const Method: TRttiMethod): TCustomAttribute;
    function ExtractParameterAttributes(const Method: TRttiMethod): IList<TParameterInfo>;
    function ExecuteTest(const Method: TRttiMethod; const Instance: TObject; const ParamValues: IList<TValue>): Boolean;
    function ShrinkFailure(const Method: TRttiMethod; const Instance: TObject; const OriginalValues: IList<TValue>; const Params: IList<TParameterInfo>): IList<TValue>;
    function FormatValueList(const Values: IList<TValue>): string;

  public
    constructor Create;
    destructor Destroy; override;

    procedure RunPropertyTest(const Method: TRttiMethod; const Instance: TObject);

    property Seed: Integer read FSeed write FSeed;
  end;

implementation

uses
  Hypothesis.Attributes,
  Hypothesis.Generators;

constructor TPropertyTestFailure.Create(const Msg: string; const OriginalValues: IList<TValue>; const MinimalValues: IList<TValue>; const IterationNumber: Integer; const Seed: Integer);
begin
  inherited Create(Msg);
  FOriginalValues := OriginalValues;
  FMinimalValues := MinimalValues;
  FIterationNumber := IterationNumber;
  FSeed := Seed;
end;

constructor TPropertyTestRunner.Create;
begin
  inherited Create;
  FContext := TRttiContext.Create;
  FSeed := Random(MaxInt);
  RandSeed := FSeed;
end;

destructor TPropertyTestRunner.Destroy;
begin
  FContext.Free;
  inherited;
end;

function TPropertyTestRunner.ExtractForAllAttribute(const Method: TRttiMethod): TCustomAttribute;
var
  Attr: TCustomAttribute;
begin
  for Attr in Method.GetAttributes do
  begin
    if Attr is ForAllAttribute then
      Exit(Attr);
  end;

  Result := nil;
end;

function TPropertyTestRunner.ExtractParameterAttributes(const Method: TRttiMethod): IList<TParameterInfo>;
var
  Params: TArray<TRttiParameter>;
  Param: TRttiParameter;
  Attr: TCustomAttribute;
  Info: TParameterInfo;
  StrategyAttr: TStrategyAttribute;
begin
  Result := TCollections.CreateList<TParameterInfo>;
  Params := Method.GetParameters;

  for Param in Params do
  begin
    StrategyAttr := nil;

    for Attr in Param.GetAttributes do
    begin
      if Attr is TStrategyAttribute then
      begin
        StrategyAttr := TStrategyAttribute(Attr);
        Break;
      end;
    end;

    if StrategyAttr = nil then
      raise Exception.CreateFmt('Parameter %s has no strategy attribute', [Param.Name]);

    Info.ParamName := Param.Name;
    Info.ParamType := Param.ParamType;
    Info.Generator := TGeneratorFactory.CreateFromAttribute(StrategyAttr);

    Result.Add(Info);
  end;
end;

function TPropertyTestRunner.ExecuteTest(const Method: TRttiMethod; const Instance: TObject; const ParamValues: IList<TValue>): Boolean;
var
  Args: TArray<TValue>;
  I: Integer;
begin
  SetLength(Args, ParamValues.Count);
  for I := 0 to ParamValues.Count - 1 do
    Args[I] := ParamValues[I];

  try
    Method.Invoke(Instance, Args);
    Result := True;
  except
    Result := False;
  end;
end;

function TPropertyTestRunner.ShrinkFailure(const Method: TRttiMethod; const Instance: TObject; const OriginalValues: IList<TValue>; const Params: IList<TParameterInfo>): IList<TValue>;
var
  BestValues: IList<TValue>;
  ParamIndex: Integer;
  Generator: IValueGenerator;
  Candidates: IList<TValue>;
  Candidate: TValue;
  TestValues: IList<TValue>;
  I: Integer;
  Improved: Boolean;
begin
  BestValues := TCollections.CreateList<TValue>;
  for I := 0 to OriginalValues.Count - 1 do
    BestValues.Add(OriginalValues[I]);

  repeat
    Improved := False;

    for ParamIndex := 0 to Params.Count - 1 do
    begin
      Generator := Params[ParamIndex].Generator as IValueGenerator;
      Candidates := Generator.Shrink(BestValues[ParamIndex]);

      for Candidate in Candidates do
      begin
        TestValues := TCollections.CreateList<TValue>;
        for I := 0 to BestValues.Count - 1 do
        begin
          if I = ParamIndex then
            TestValues.Add(Candidate)
          else
            TestValues.Add(BestValues[I]);
        end;

        if not ExecuteTest(Method, Instance, TestValues) then
        begin
          BestValues := TestValues;
          Improved := True;
          Break;
        end;
      end;

      if Improved then
        Break;
    end;
  until not Improved;

  Result := BestValues;
end;

function TPropertyTestRunner.FormatValueList(const Values: IList<TValue>): string;
var
  I: Integer;
  Parts: TArray<string>;
begin
  SetLength(Parts, Values.Count);

  for I := 0 to Values.Count - 1 do
  begin
    case Values[I].Kind of
      tkInteger, tkInt64:
        Parts[I] := Values[I].AsInt64.ToString;
      tkString, tkUString, tkLString, tkWString:
        Parts[I] := QuotedStr(Values[I].AsString);
    else
      Parts[I] := Values[I].ToString;
    end;
  end;

  Result := string.Join(', ', Parts);
end;

procedure TPropertyTestRunner.RunPropertyTest(const Method: TRttiMethod; const Instance: TObject);
var
  ForAllAttr: TCustomAttribute;
  Iterations: Integer;
  Params: IList<TParameterInfo>;
  ParamValues: IList<TValue>;
  Iteration: Integer;
  ParamInfo: TParameterInfo;
  Generator: IValueGenerator;
  MinimalValues: IList<TValue>;
  ErrorMsg: string;
begin
  ForAllAttr := ExtractForAllAttribute(Method);
  if ForAllAttr = nil then
    raise Exception.Create('Method must have ForAll attribute');

  Iterations := ForAllAttribute(ForAllAttr).Iterations;
  Params := ExtractParameterAttributes(Method);

  for Iteration := 1 to Iterations do
  begin
    ParamValues := TCollections.CreateList<TValue>;

    for ParamInfo in Params do
    begin
      Generator := ParamInfo.Generator as IValueGenerator;
      ParamValues.Add(Generator.GenerateValue);
    end;

    if not ExecuteTest(Method, Instance, ParamValues) then
    begin
      MinimalValues := ShrinkFailure(Method, Instance, ParamValues, Params);

      ErrorMsg := Format('Property test failed on iteration %d/%d' + sLineBreak +
                        'Original values: %s' + sLineBreak +
                        'Minimal failing example: %s' + sLineBreak +
                        'Seed: %d',
                        [Iteration, Iterations,
                         FormatValueList(ParamValues),
                         FormatValueList(MinimalValues),
                         FSeed]);

      raise TPropertyTestFailure.Create(ErrorMsg, ParamValues, MinimalValues, Iteration, FSeed);
    end;
  end;
end;

end.
