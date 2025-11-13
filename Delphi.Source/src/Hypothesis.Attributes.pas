unit Hypothesis.Attributes;

interface

uses
  System.Math;

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

  BooleanAttribute = class(TStrategyAttribute)
  public
    constructor Create(const ParamName: string);
  end;

  FloatRangeAttribute = class(TStrategyAttribute)
  private
    FMin: Double;
    FMax: Double;
    FAllowNaN: Boolean;
    FAllowInfinity: Boolean;

  public
    constructor Create(const ParamName: string; const Min: Double; const Max: Double;
                       const AllowNaN: Boolean = False; const AllowInfinity: Boolean = False);

    property Min: Double read FMin;
    property Max: Double read FMax;
    property AllowNaN: Boolean read FAllowNaN;
    property AllowInfinity: Boolean read FAllowInfinity;
  end;

  FloatPositiveAttribute = class(TStrategyAttribute)
  private
    FMax: Double;

  public
    constructor Create(const ParamName: string; const Max: Double = MaxDouble);

    property Max: Double read FMax;
  end;

  FloatNegativeAttribute = class(TStrategyAttribute)
  private
    FMin: Double;

  public
    constructor Create(const ParamName: string; const Min: Double = -MaxDouble);

    property Min: Double read FMin;
  end;

  FloatUnitAttribute = class(TStrategyAttribute)
  public
    constructor Create(const ParamName: string);
  end;

  DateRangeAttribute = class(TStrategyAttribute)
  private
    FMinYear: Word;
    FMaxYear: Word;

  public
    constructor Create(const ParamName: string; const MinYear: Word = 1900;
                       const MaxYear: Word = 2100);

    property MinYear: Word read FMinYear;
    property MaxYear: Word read FMaxYear;
  end;

  DateTimeRangeAttribute = class(TStrategyAttribute)
  private
    FMinYear: Word;
    FMaxYear: Word;

  public
    constructor Create(const ParamName: string; const MinYear: Word = 1900;
                       const MaxYear: Word = 2100);

    property MinYear: Word read FMinYear;
    property MaxYear: Word read FMaxYear;
  end;

  DateRecentAttribute = class(TStrategyAttribute)
  private
    FDays: Integer;

  public
    constructor Create(const ParamName: string; const Days: Integer = 30);

    property Days: Integer read FDays;
  end;

  TimeRangeAttribute = class(TStrategyAttribute)
  public
    constructor Create(const ParamName: string);
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

constructor BooleanAttribute.Create(const ParamName: string);
begin
  inherited Create(ParamName);
end;

constructor FloatRangeAttribute.Create(const ParamName: string; const Min: Double;
                                        const Max: Double; const AllowNaN: Boolean;
                                        const AllowInfinity: Boolean);
begin
  inherited Create(ParamName);
  FMin := Min;
  FMax := Max;
  FAllowNaN := AllowNaN;
  FAllowInfinity := AllowInfinity;
end;

constructor FloatPositiveAttribute.Create(const ParamName: string; const Max: Double);
begin
  inherited Create(ParamName);
  FMax := Max;
end;

constructor FloatNegativeAttribute.Create(const ParamName: string; const Min: Double);
begin
  inherited Create(ParamName);
  FMin := Min;
end;

constructor FloatUnitAttribute.Create(const ParamName: string);
begin
  inherited Create(ParamName);
end;

constructor DateRangeAttribute.Create(const ParamName: string; const MinYear: Word;
                                       const MaxYear: Word);
begin
  inherited Create(ParamName);
  FMinYear := MinYear;
  FMaxYear := MaxYear;
end;

constructor DateTimeRangeAttribute.Create(const ParamName: string; const MinYear: Word;
                                           const MaxYear: Word);
begin
  inherited Create(ParamName);
  FMinYear := MinYear;
  FMaxYear := MaxYear;
end;

constructor DateRecentAttribute.Create(const ParamName: string; const Days: Integer);
begin
  inherited Create(ParamName);
  FDays := Days;
end;

constructor TimeRangeAttribute.Create(const ParamName: string);
begin
  inherited Create(ParamName);
end;

end.
