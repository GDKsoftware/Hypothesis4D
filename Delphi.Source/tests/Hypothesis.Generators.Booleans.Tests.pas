unit Hypothesis.Generators.Booleans.Tests;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  Spring.Collections,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.Booleans;

type
  [TestFixture]
  TBooleanGeneratorTests = class
  private
    FGenerator: IValueGenerator;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestGenerateValueReturnsBooleanType;

    [Test]
    procedure TestGenerateValueReturnsTrueOrFalse;

    [Test]
    procedure TestGenerateManyValuesCoversBothOutcomes;

    [Test]
    procedure TestShrinkTrueReturnsFalse;

    [Test]
    procedure TestShrinkFalseReturnsEmpty;

    [Test]
    procedure TestShrinkReturnsCorrectType;
  end;

implementation

{ TBooleanGeneratorTests }

procedure TBooleanGeneratorTests.Setup;
begin
  FGenerator := TBooleanGenerator.Create;
end;

procedure TBooleanGeneratorTests.TearDown;
begin
  FGenerator := nil;
end;

procedure TBooleanGeneratorTests.TestGenerateValueReturnsBooleanType;
var
  Value: TValue;
begin
  Value := FGenerator.GenerateValue;
  Assert.AreEqual(Integer(tkEnumeration), Integer(Value.Kind));
  Assert.IsTrue(Value.TypeInfo = TypeInfo(Boolean), 'TypeInfo should be Boolean');
end;

procedure TBooleanGeneratorTests.TestGenerateValueReturnsTrueOrFalse;
var
  Value: TValue;
  BoolValue: Boolean;
begin
  Value := FGenerator.GenerateValue;
  BoolValue := Value.AsBoolean;
  Assert.IsTrue((BoolValue = True) or (BoolValue = False));
end;

procedure TBooleanGeneratorTests.TestGenerateManyValuesCoversBothOutcomes;
var
  I: Integer;
  Value: TValue;
  HasTrue: Boolean;
  HasFalse: Boolean;
begin
  HasTrue := False;
  HasFalse := False;

  // Generate many values to ensure both True and False appear
  for I := 1 to 100 do
  begin
    Value := FGenerator.GenerateValue;
    if Value.AsBoolean then
      HasTrue := True
    else
      HasFalse := True;

    if HasTrue and HasFalse then
      Break;
  end;

  Assert.IsTrue(HasTrue, 'Expected to generate at least one True value');
  Assert.IsTrue(HasFalse, 'Expected to generate at least one False value');
end;

procedure TBooleanGeneratorTests.TestShrinkTrueReturnsFalse;
var
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  Value := TValue.From<Boolean>(True);
  Shrinks := FGenerator.Shrink(Value);

  Assert.AreEqual(1, Shrinks.Count, 'True should shrink to one candidate: False');
  Assert.IsFalse(Shrinks[0].AsBoolean, 'True should shrink to False');
end;

procedure TBooleanGeneratorTests.TestShrinkFalseReturnsEmpty;
var
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  Value := TValue.From<Boolean>(False);
  Shrinks := FGenerator.Shrink(Value);

  Assert.AreEqual(0, Shrinks.Count, 'False is minimal and should not shrink further');
end;

procedure TBooleanGeneratorTests.TestShrinkReturnsCorrectType;
var
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  Value := TValue.From<Boolean>(True);
  Shrinks := FGenerator.Shrink(Value);

  if Shrinks.Count > 0 then
  begin
    Assert.AreEqual(Integer(tkEnumeration), Integer(Shrinks[0].Kind));
    Assert.IsTrue(Shrinks[0].TypeInfo = TypeInfo(Boolean), 'TypeInfo should be Boolean');
  end;
end;

end.
