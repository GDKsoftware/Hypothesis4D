unit Hypothesis.Generators.Floats.Tests;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  System.Math,
  Spring.Collections,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.Floats;

type
  [TestFixture]
  TFloatGeneratorTests = class
  private
    FGenerator: IValueGenerator;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestGenerateValueReturnsFloatType;

    [Test]
    procedure TestGenerateValueInRange;

    [Test]
    procedure TestGenerateSpecialValues;

    [Test]
    procedure TestShrinkZeroReturnsEmpty;

    [Test]
    procedure TestShrinkPositiveIncludesZero;

    [Test]
    procedure TestShrinkNegativeIncludesZero;

    [Test]
    procedure TestShrinkTowardsInteger;

    [Test]
    procedure TestShrinkHalfway;

    [Test]
    procedure TestShrinkNaNToInfinity;

    [Test]
    procedure TestShrinkInfinityToFinite;
  end;

implementation

uses
  System.SysUtils;

{ TFloatGeneratorTests }

procedure TFloatGeneratorTests.Setup;
begin
  FGenerator := TFloatGenerator.Create(-1000.0, 1000.0, False, False);
end;

procedure TFloatGeneratorTests.TearDown;
begin
  FGenerator := nil;
end;

procedure TFloatGeneratorTests.TestGenerateValueReturnsFloatType;
var
  Value: TValue;
begin
  Value := FGenerator.GenerateValue;
  Assert.AreEqual(tkFloat, Value.Kind);
end;

procedure TFloatGeneratorTests.TestGenerateValueInRange;
var
  I: Integer;
  Value: TValue;
  FloatValue: Double;
begin
  for I := 1 to 100 do
  begin
    Value := FGenerator.GenerateValue;
    FloatValue := Value.AsExtended;

    Assert.IsTrue((FloatValue >= -1000.0) and (FloatValue <= 1000.0),
                  Format('Value %g should be in range [-1000.0, 1000.0]', [FloatValue]));
  end;
end;

procedure TFloatGeneratorTests.TestGenerateSpecialValues;
var
  SpecialGen: IValueGenerator;
  I: Integer;
  Value: TValue;
  FloatValue: Double;
  HasNaN: Boolean;
  HasInfinity: Boolean;
begin
  SpecialGen := TFloatGenerator.Create(-100.0, 100.0, True, True);

  HasNaN := False;
  HasInfinity := False;

  // Generate many values to find special values
  for I := 1 to 1000 do
  begin
    Value := SpecialGen.GenerateValue;
    FloatValue := Value.AsExtended;

    if IsNan(FloatValue) then
      HasNaN := True;

    if IsInfinite(FloatValue) then
      HasInfinity := True;

    if HasNaN and HasInfinity then
      Break;
  end;

  Assert.IsTrue(HasNaN or HasInfinity, 'Should generate at least one special value');
end;

procedure TFloatGeneratorTests.TestShrinkZeroReturnsEmpty;
var
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  Value := TValue.From<Double>(0.0);
  Shrinks := FGenerator.Shrink(Value);

  Assert.AreEqual(0, Shrinks.Count, 'Zero should not shrink further');
end;

procedure TFloatGeneratorTests.TestShrinkPositiveIncludesZero;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasZero: Boolean;
  I: Integer;
begin
  Value := TValue.From<Double>(42.5);
  Shrinks := FGenerator.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'Positive value should have shrink candidates');

  HasZero := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    if Abs(Shrinks[I].AsExtended) < 1e-10 then
    begin
      HasZero := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasZero, 'Positive value should shrink towards zero');
end;

procedure TFloatGeneratorTests.TestShrinkNegativeIncludesZero;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasZero: Boolean;
  I: Integer;
begin
  Value := TValue.From<Double>(-42.5);
  Shrinks := FGenerator.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'Negative value should have shrink candidates');

  HasZero := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    if Abs(Shrinks[I].AsExtended) < 1e-10 then
    begin
      HasZero := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasZero, 'Negative value should shrink towards zero');
end;

procedure TFloatGeneratorTests.TestShrinkTowardsInteger;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasInteger: Boolean;
  I: Integer;
  ShrinkValue: Double;
begin
  Value := TValue.From<Double>(10.0000001); // Very close to 10
  Shrinks := FGenerator.Shrink(Value);

  HasInteger := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    ShrinkValue := Shrinks[I].AsExtended;
    if Abs(ShrinkValue - 10.0) < 1e-10 then
    begin
      HasInteger := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasInteger, 'Value close to integer should shrink to that integer');
end;

procedure TFloatGeneratorTests.TestShrinkHalfway;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasHalf: Boolean;
  I: Integer;
  ShrinkValue: Double;
begin
  Value := TValue.From<Double>(100.0);
  Shrinks := FGenerator.Shrink(Value);

  HasHalf := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    ShrinkValue := Shrinks[I].AsExtended;
    if Abs(ShrinkValue - 50.0) < 1e-10 then
    begin
      HasHalf := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasHalf, 'Value should shrink to halfway point towards zero');
end;

procedure TFloatGeneratorTests.TestShrinkNaNToInfinity;
var
  SpecialGen: IValueGenerator;
  Value: TValue;
  Shrinks: IList<TValue>;
  HasInfinity: Boolean;
  I: Integer;
begin
  SpecialGen := TFloatGenerator.Create(-1000.0, 1000.0, True, True);

  Value := TValue.From<Double>(NaN);
  Shrinks := SpecialGen.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'NaN should have shrink candidates');

  HasInfinity := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    if IsInfinite(Shrinks[I].AsExtended) then
    begin
      HasInfinity := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasInfinity, 'NaN should shrink to Infinity');
end;

procedure TFloatGeneratorTests.TestShrinkInfinityToFinite;
var
  SpecialGen: IValueGenerator;
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  SpecialGen := TFloatGenerator.Create(-1000.0, 1000.0, False, True);

  Value := TValue.From<Double>(Infinity);
  Shrinks := SpecialGen.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'Infinity should shrink to finite values');
  Assert.IsFalse(IsInfinite(Shrinks[0].AsExtended), 'First shrink candidate should be finite');
end;

end.
