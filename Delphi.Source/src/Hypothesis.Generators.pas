unit Hypothesis.Generators;

interface

uses
  System.SysUtils,
  System.TypInfo,
  Spring.Collections,
  System.Rtti;

type
  IValueGenerator = interface
    ['{8A3C5E7F-9B2D-4E6A-8C1F-3D5B7E9A2C4F}']

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

  TIntegerGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMin: Int64;
    FMax: Int64;
    FExcludeZero: Boolean;

  public
    constructor Create(const Min: Int64; const Max: Int64; const ExcludeZero: Boolean = False);

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

  TStringCharSet = (Any, Alpha, Numeric);

  TStringGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMinLen: Integer;
    FMaxLen: Integer;
    FCharSet: TStringCharSet;

    function GenerateChar: Char;
    function SimplifyChar(const Ch: Char): Char;

  public
    constructor Create(const MinLen: Integer; const MaxLen: Integer; const CharSet: TStringCharSet);

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

  TGeneratorFactory = class
  public
    class function CreateFromAttribute(const Attribute: TCustomAttribute): IValueGenerator;
  end;

implementation

uses
  Hypothesis.Attributes;

constructor TIntegerGenerator.Create(const Min: Int64; const Max: Int64; const ExcludeZero: Boolean);
begin
  inherited Create;
  FMin := Min;
  FMax := Max;
  FExcludeZero := ExcludeZero;
end;

function TIntegerGenerator.GenerateValue: TValue;
var
  Generated: Int64;
  Range: Int64;
  RandValue: Double;
begin
  Range := FMax - FMin + 1;

  repeat
    if Range <= High(Integer) then
      Generated := FMin + Random(Integer(Range))
    else
    begin
      RandValue := Random;
      Generated := FMin + Trunc(RandValue * Range);
    end;
  until (not FExcludeZero) or (Generated <> 0);

  Result := TValue.From<Int64>(Generated);
end;

function TIntegerGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  IntValue: Int64;
  Candidates: IList<TValue>;
  Step: Int64;
  Candidate: Int64;
begin
  Candidates := TCollections.CreateList<TValue>;
  IntValue := Value.AsInt64;

  if IntValue = 0 then
    Exit(Candidates);

  if (IntValue >= FMin) and (IntValue <= FMax) then
  begin
    if (IntValue > 0) and (FMin <= 0) and (not FExcludeZero) then
      Candidates.Add(TValue.From<Int64>(0));

    if (IntValue < 0) and (FMax >= 0) and (not FExcludeZero) then
      Candidates.Add(TValue.From<Int64>(0));

    Step := Abs(IntValue) div 2;
    while Step > 0 do
    begin
      if IntValue > 0 then
      begin
        Candidate := IntValue - Step;
        if (Candidate >= FMin) and (Candidate <> IntValue) then
        begin
          if (not FExcludeZero) or (Candidate <> 0) then
            Candidates.Add(TValue.From<Int64>(Candidate));
        end;
      end
      else
      begin
        Candidate := IntValue + Step;
        if (Candidate <= FMax) and (Candidate <> IntValue) then
        begin
          if (not FExcludeZero) or (Candidate <> 0) then
            Candidates.Add(TValue.From<Int64>(Candidate));
        end;
      end;

      Step := Step div 2;
    end;
  end;

  Result := Candidates;
end;

constructor TStringGenerator.Create(const MinLen: Integer; const MaxLen: Integer; const CharSet: TStringCharSet);
begin
  inherited Create;
  FMinLen := MinLen;
  FMaxLen := MaxLen;
  FCharSet := CharSet;
end;

function TStringGenerator.GenerateChar: Char;
begin
  case FCharSet of
    TStringCharSet.Alpha:
      begin
        if Random(2) = 0 then
          Result := Chr(Ord('A') + Random(26))
        else
          Result := Chr(Ord('a') + Random(26));
      end;

    TStringCharSet.Numeric:
      Result := Chr(Ord('0') + Random(10));

    TStringCharSet.Any:
      Result := Chr(32 + Random(95));
  else
    Result := ' ';
  end;
end;

function TStringGenerator.SimplifyChar(const Ch: Char): Char;
begin
  case FCharSet of
    TStringCharSet.Alpha:
      begin
        if (Ch >= 'a') and (Ch <= 'z') then
          Result := 'a'
        else if (Ch >= 'A') and (Ch <= 'Z') then
          Result := 'A'
        else
          Result := Ch;
      end;

    TStringCharSet.Numeric:
      Result := '0';

    TStringCharSet.Any:
      Result := ' ';
  else
    Result := Ch;
  end;
end;

function TStringGenerator.GenerateValue: TValue;
var
  Len: Integer;
  Builder: TStringBuilder;
  I: Integer;
begin
  Len := FMinLen + Random(FMaxLen - FMinLen + 1);
  Builder := TStringBuilder.Create(Len);
  try
    for I := 1 to Len do
      Builder.Append(GenerateChar);

    Result := TValue.From<string>(Builder.ToString);
  finally
    Builder.Free;
  end;
end;

function TStringGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  StrValue: string;
  Candidates: IList<TValue>;
  NewLen: Integer;
  HalfLen: Integer;
  I: Integer;
  Simplified: string;
begin
  Candidates := TCollections.CreateList<TValue>;
  StrValue := Value.AsString;

  if StrValue.Length <= FMinLen then
    Exit(Candidates);

  if StrValue.Length > FMinLen then
  begin
    Candidates.Add(TValue.From<string>(StrValue.Substring(0, FMinLen)));
  end;

  HalfLen := (StrValue.Length + FMinLen) div 2;
  if (HalfLen > FMinLen) and (HalfLen < StrValue.Length) then
  begin
    Candidates.Add(TValue.From<string>(StrValue.Substring(0, HalfLen)));
  end;

  NewLen := StrValue.Length - 1;
  if NewLen >= FMinLen then
  begin
    Candidates.Add(TValue.From<string>(StrValue.Substring(0, NewLen)));
  end;

  if StrValue.Length > 0 then
  begin
    Simplified := StrValue;
    for I := 1 to Simplified.Length do
    begin
      if Simplified[I] <> SimplifyChar(Simplified[I]) then
      begin
        Simplified[I] := SimplifyChar(Simplified[I]);
        Candidates.Add(TValue.From<string>(Simplified));
        Break;
      end;
    end;
  end;

  Result := Candidates;
end;

class function TGeneratorFactory.CreateFromAttribute(const Attribute: TCustomAttribute): IValueGenerator;
begin
  if Attribute is IntRangeAttribute then
  begin
    const IntRange = IntRangeAttribute(Attribute);
    Exit(TIntegerGenerator.Create(IntRange.Min, IntRange.Max, False));
  end;

  if Attribute is IntPositiveAttribute then
  begin
    const IntPositive = IntPositiveAttribute(Attribute);
    Exit(TIntegerGenerator.Create(1, IntPositive.Max, False));
  end;

  if Attribute is IntNegativeAttribute then
  begin
    const IntNegative = IntNegativeAttribute(Attribute);
    Exit(TIntegerGenerator.Create(IntNegative.Min, -1, False));
  end;

  if Attribute is IntNonZeroAttribute then
  begin
    const IntNonZero = IntNonZeroAttribute(Attribute);
    Exit(TIntegerGenerator.Create(IntNonZero.Min, IntNonZero.Max, True));
  end;

  if Attribute is StringGenAttribute then
  begin
    const StrGen = StringGenAttribute(Attribute);
    Exit(TStringGenerator.Create(StrGen.MinLen, StrGen.MaxLen, TStringCharSet.Any));
  end;

  if Attribute is StringAlphaAttribute then
  begin
    const StrAlpha = StringAlphaAttribute(Attribute);
    Exit(TStringGenerator.Create(StrAlpha.MinLen, StrAlpha.MaxLen, TStringCharSet.Alpha));
  end;

  if Attribute is StringNumericAttribute then
  begin
    const StrNumeric = StringNumericAttribute(Attribute);
    Exit(TStringGenerator.Create(StrNumeric.MinLen, StrNumeric.MaxLen, TStringCharSet.Numeric));
  end;

  raise Exception.CreateFmt('Unsupported attribute type: %s', [Attribute.ClassName]);
end;

end.
