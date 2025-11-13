unit Hypothesis.Generators.Floats;

interface

uses
  System.Rtti,
  System.Math,
  Spring.Collections,
  Hypothesis.Generators.Interfaces;

type
  /// <summary>
  /// Generator for floating-point values (Single/Double).
  /// </summary>
  /// <remarks>
  /// Generates random double values within specified range.
  /// Optionally generates special values like NaN and Infinity.
  /// Shrinking behavior: Special values → 0.0 → nearest integer → halfway to zero.
  /// </remarks>
  TFloatGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMin: Double;
    FMax: Double;
    FAllowNaN: Boolean;
    FAllowInfinity: Boolean;

    function GenerateFiniteFloat: Double;
    function IsNearInteger(const Value: Double): Boolean;
  public
    constructor Create(const Min: Double; const Max: Double;
                       const AllowNaN: Boolean = False;
                       const AllowInfinity: Boolean = False);

    /// <summary>
    /// Generates a random floating-point value.
    /// </summary>
    function GenerateValue: TValue;

    /// <summary>
    /// Returns shrink candidates for the given float value.
    /// </summary>
    function Shrink(const Value: TValue): IList<TValue>;
  end;

implementation

{ TFloatGenerator }

constructor TFloatGenerator.Create(const Min: Double; const Max: Double;
                                    const AllowNaN: Boolean;
                                    const AllowInfinity: Boolean);
begin
  inherited Create;
  FMin := Min;
  FMax := Max;
  FAllowNaN := AllowNaN;
  FAllowInfinity := AllowInfinity;
end;

function TFloatGenerator.GenerateFiniteFloat: Double;
begin
  // Generate in range [FMin, FMax]
  Result := FMin + Random * (FMax - FMin);
end;

function TFloatGenerator.GenerateValue: TValue;
var
  SpecialChoice: Integer;
  Value: Double;
begin
  // Generate special values if allowed (5% chance)
  if FAllowNaN or FAllowInfinity then
  begin
    SpecialChoice := Random(20);
    case SpecialChoice of
      0: if FAllowNaN then Exit(TValue.From<Double>(NaN));
      1: if FAllowInfinity then Exit(TValue.From<Double>(Infinity));
      2: if FAllowInfinity then Exit(TValue.From<Double>(NegInfinity));
    end;
  end;

  Value := GenerateFiniteFloat;
  Result := TValue.From<Double>(Value);
end;

function TFloatGenerator.IsNearInteger(const Value: Double): Boolean;
const
  Epsilon = 1e-9;
begin
  Result := Abs(Value - Round(Value)) < Epsilon;
end;

function TFloatGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  FloatValue: Double;
  Candidates: IList<TValue>;
  IntValue: Int64;
  HalfValue: Double;
begin
  Candidates := TCollections.CreateList<TValue>;
  FloatValue := Value.AsExtended; // Use AsExtended for all float types

  // Handle special values
  if IsNan(FloatValue) then
  begin
    // NaN shrinks to Infinity, then to large finite
    if FAllowInfinity then
    begin
      Candidates.Add(TValue.From<Double>(Infinity));
      Candidates.Add(TValue.From<Double>(NegInfinity));
    end;
    Candidates.Add(TValue.From<Double>(MaxDouble));
    Exit(Candidates);
  end;

  if IsInfinite(FloatValue) then
  begin
    // Infinity shrinks to large finite value
    if FloatValue > 0 then
      Candidates.Add(TValue.From<Double>(MaxDouble))
    else
      Candidates.Add(TValue.From<Double>(-MaxDouble));
    Exit(Candidates);
  end;

  // For finite values, shrink towards 0.0
  if FloatValue <> 0.0 then
  begin
    // Try zero if in range
    if (0.0 >= FMin) and (0.0 <= FMax) then
      Candidates.Add(TValue.From<Double>(0.0));

    // Try nearest integer if close
    if IsNearInteger(FloatValue) then
    begin
      IntValue := Round(FloatValue);
      if (IntValue >= FMin) and (IntValue <= FMax) and (IntValue <> FloatValue) then
        Candidates.Add(TValue.From<Double>(Double(IntValue)));
    end;

    // Try halfway to zero
    HalfValue := FloatValue / 2.0;
    if (HalfValue >= FMin) and (HalfValue <= FMax) and (HalfValue <> FloatValue) then
      Candidates.Add(TValue.From<Double>(HalfValue));

    // Try removing fractional part (floor/ceil towards zero)
    if FloatValue > 0 then
    begin
      if (Floor(FloatValue) >= FMin) and (Floor(FloatValue) <> FloatValue) then
        Candidates.Add(TValue.From<Double>(Floor(FloatValue)));
    end
    else
    begin
      if (Ceil(FloatValue) <= FMax) and (Ceil(FloatValue) <> FloatValue) then
        Candidates.Add(TValue.From<Double>(Ceil(FloatValue)));
    end;
  end;

  Result := Candidates;
end;

end.
