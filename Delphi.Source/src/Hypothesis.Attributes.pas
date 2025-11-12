unit Hypothesis.Attributes;

interface

type
  TStrategyAttribute = class(TCustomAttribute)
  private
    FParamName: string;

  public
    constructor Create(const ParamName: string);

    property ParamName: string read FParamName;
  end;

  ForAllAttribute = class(TCustomAttribute)
  private
    FIterations: Integer;

  public
    constructor Create(const Iterations: Integer = 10);

    property Iterations: Integer read FIterations;
  end;

  IntRangeAttribute = class(TStrategyAttribute)
  private
    FMin: Int64;
    FMax: Int64;

  public
    constructor Create(const ParamName: string; const Min: Int64; const Max: Int64);

    property Min: Int64 read FMin;
    property Max: Int64 read FMax;
  end;

  IntPositiveAttribute = class(TStrategyAttribute)
  private
    FMax: Int64;

  public
    constructor Create(const ParamName: string; const Max: Int64 = High(Int64));

    property Max: Int64 read FMax;
  end;

  IntNegativeAttribute = class(TStrategyAttribute)
  private
    FMin: Int64;

  public
    constructor Create(const ParamName: string; const Min: Int64 = Low(Int64));

    property Min: Int64 read FMin;
  end;

  IntNonZeroAttribute = class(TStrategyAttribute)
  private
    FMin: Int64;
    FMax: Int64;

  public
    constructor Create(const ParamName: string; const Min: Int64; const Max: Int64);

    property Min: Int64 read FMin;
    property Max: Int64 read FMax;
  end;

  StringGenAttribute = class(TStrategyAttribute)
  private
    FMinLen: Integer;
    FMaxLen: Integer;

  public
    constructor Create(const ParamName: string; const MinLen: Integer; const MaxLen: Integer);

    property MinLen: Integer read FMinLen;
    property MaxLen: Integer read FMaxLen;
  end;

  StringAlphaAttribute = class(TStrategyAttribute)
  private
    FMinLen: Integer;
    FMaxLen: Integer;

  public
    constructor Create(const ParamName: string; const MinLen: Integer; const MaxLen: Integer);

    property MinLen: Integer read FMinLen;
    property MaxLen: Integer read FMaxLen;
  end;

  StringNumericAttribute = class(TStrategyAttribute)
  private
    FMinLen: Integer;
    FMaxLen: Integer;

  public
    constructor Create(const ParamName: string; const MinLen: Integer; const MaxLen: Integer);

    property MinLen: Integer read FMinLen;
    property MaxLen: Integer read FMaxLen;
  end;

implementation

constructor TStrategyAttribute.Create(const ParamName: string);
begin
  inherited Create;
  FParamName := ParamName;
end;

constructor ForAllAttribute.Create(const Iterations: Integer);
begin
  inherited Create;
  FIterations := Iterations;
end;

constructor IntRangeAttribute.Create(const ParamName: string; const Min: Int64; const Max: Int64);
begin
  inherited Create(ParamName);
  FMin := Min;
  FMax := Max;
end;

constructor IntPositiveAttribute.Create(const ParamName: string; const Max: Int64);
begin
  inherited Create(ParamName);
  FMax := Max;
end;

constructor IntNegativeAttribute.Create(const ParamName: string; const Min: Int64);
begin
  inherited Create(ParamName);
  FMin := Min;
end;

constructor IntNonZeroAttribute.Create(const ParamName: string; const Min: Int64; const Max: Int64);
begin
  inherited Create(ParamName);
  FMin := Min;
  FMax := Max;
end;

constructor StringGenAttribute.Create(const ParamName: string; const MinLen: Integer; const MaxLen: Integer);
begin
  inherited Create(ParamName);
  FMinLen := MinLen;
  FMaxLen := MaxLen;
end;

constructor StringAlphaAttribute.Create(const ParamName: string; const MinLen: Integer; const MaxLen: Integer);
begin
  inherited Create(ParamName);
  FMinLen := MinLen;
  FMaxLen := MaxLen;
end;

constructor StringNumericAttribute.Create(const ParamName: string; const MinLen: Integer; const MaxLen: Integer);
begin
  inherited Create(ParamName);
  FMinLen := MinLen;
  FMaxLen := MaxLen;
end;

end.
