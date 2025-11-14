unit Hypothesis.Generators.Collections.Tests;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  Spring.Collections,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.Collections,
  Hypothesis.Generators.Integers,
  Hypothesis.Generators.Strings,
  Hypothesis.Runner,
  Hypothesis.Attributes;

type
  [TestFixture]
  TCollectionGeneratorTests = class
  public
    // Array generator tests
    [Test]
    procedure TestArrayGeneratorCreatesArray;

    [Test]
    procedure TestArrayGeneratorRespectsMinMaxCount;

    [Test]
    procedure TestArrayGeneratorUsesElementGenerator;

    // List generator tests
    [Test]
    procedure TestListGeneratorCreatesList;

    [Test]
    procedure TestListGeneratorRespectsMinMaxCount;

    // Dictionary generator tests
    [Test]
    procedure TestDictionaryGeneratorCreatesDictionary;

    [Test]
    procedure TestDictionaryGeneratorRespectsMinMaxCount;
  end;

  [TestFixture]
  TCollectionHelperTests = class
  public
    // ArrayOf helpers
    [Test]
    procedure TestArrayOfIntegersHelper;

    [Test]
    procedure TestArrayOfStringsHelper;

    // ListOf helpers
    [Test]
    procedure TestListOfIntegersHelper;

    [Test]
    procedure TestListOfStringsHelper;

    // DictOf helpers
    [Test]
    procedure TestDictIntegerToStringHelper;

    [Test]
    procedure TestDictStringToIntegerHelper;
  end;

  [TestFixture]
  TCollectionPropertyTests = class
  public
    // Integration tests using new Run overload
    [Test]
    procedure RunTestArraySum;

    procedure TestArraySum(const Values: TArray<Int64>);

    [Test]
    procedure RunTestListContains;

    procedure TestListContains(const Values: IList<Int64>);

    [Test]
    procedure RunTestArrayConcatenation;

    procedure TestArrayConcatenation(const A1: TArray<Int64>; const A2: TArray<Int64>);
  end;

implementation

{ TCollectionGeneratorTests }

procedure TCollectionGeneratorTests.TestArrayGeneratorCreatesArray;
var
  ElementGen: IValueGenerator;
  ArrayGen: IValueGenerator;
  Value: TValue;
  Values: TArray<Int64>;
begin
  ElementGen := TIntegerGenerator.Create(1, 100, False);
  ArrayGen := TArrayGenerator.Create(5, 10, ElementGen, TypeInfo(Int64));

  Value := ArrayGen.GenerateValue;
  Values := Value.AsType<TArray<Int64>>;

  Assert.IsTrue(Length(Values) >= 5, 'Array should have at least 5 elements');
  Assert.IsTrue(Length(Values) <= 10, 'Array should have at most 10 elements');
end;

procedure TCollectionGeneratorTests.TestArrayGeneratorRespectsMinMaxCount;
var
  ElementGen: IValueGenerator;
  ArrayGen: IValueGenerator;
  Value: TValue;
  Values: TArray<Int64>;
  I: Integer;
begin
  ElementGen := TIntegerGenerator.Create(1, 100, False);
  ArrayGen := TArrayGenerator.Create(3, 7, ElementGen, TypeInfo(Int64));

  // Generate multiple arrays and verify they all respect bounds
  for I := 1 to 20 do
  begin
    Value := ArrayGen.GenerateValue;
    Values := Value.AsType<TArray<Int64>>;
    Assert.IsTrue(Length(Values) >= 3, Format('Iteration %d: Array too short', [I]));
    Assert.IsTrue(Length(Values) <= 7, Format('Iteration %d: Array too long', [I]));
  end;
end;

procedure TCollectionGeneratorTests.TestArrayGeneratorUsesElementGenerator;
var
  ElementGen: IValueGenerator;
  ArrayGen: IValueGenerator;
  Value: TValue;
  Values: TArray<Int64>;
  I: Integer;
begin
  // Use a restricted range to test element generation
  ElementGen := TIntegerGenerator.Create(50, 100, False);
  ArrayGen := TArrayGenerator.Create(5, 10, ElementGen, TypeInfo(Int64));

  Value := ArrayGen.GenerateValue;
  Values := Value.AsType<TArray<Int64>>;

  // All values should be in the specified range
  for I := 0 to High(Values) do
  begin
    Assert.IsTrue(Values[I] >= 50, Format('Value[%d]=%d should be >= 50', [I, Values[I]]));
    Assert.IsTrue(Values[I] <= 100, Format('Value[%d]=%d should be <= 100', [I, Values[I]]));
  end;
end;

procedure TCollectionGeneratorTests.TestListGeneratorCreatesList;
var
  ElementGen: IValueGenerator;
  ListGen: IValueGenerator;
  Value: TValue;
  Values: IList<Int64>;
begin
  ElementGen := TIntegerGenerator.Create(1, 100, False);
  ListGen := TListGenerator.Create(5, 10, ElementGen, TypeInfo(Int64));

  Value := ListGen.GenerateValue;
  Values := Value.AsType<IList<Int64>>;

  Assert.IsNotNull(Values, 'Generated list should not be nil');
  Assert.IsTrue(Values.Count >= 5, 'List should have at least 5 elements');
  Assert.IsTrue(Values.Count <= 10, 'List should have at most 10 elements');
end;

procedure TCollectionGeneratorTests.TestListGeneratorRespectsMinMaxCount;
var
  ElementGen: IValueGenerator;
  ListGen: IValueGenerator;
  Value: TValue;
  Values: IList<Int64>;
  I: Integer;
begin
  ElementGen := TIntegerGenerator.Create(1, 100, False);
  ListGen := TListGenerator.Create(2, 5, ElementGen, TypeInfo(Int64));

  for I := 1 to 20 do
  begin
    Value := ListGen.GenerateValue;
    Values := Value.AsType<IList<Int64>>;
    Assert.IsTrue(Values.Count >= 2, Format('Iteration %d: List too short', [I]));
    Assert.IsTrue(Values.Count <= 5, Format('Iteration %d: List too long', [I]));
  end;
end;

procedure TCollectionGeneratorTests.TestDictionaryGeneratorCreatesDictionary;
var
  KeyGen: IValueGenerator;
  ValueGen: IValueGenerator;
  DictGen: IValueGenerator;
  Value: TValue;
  Dict: IDictionary<Int64, string>;
begin
  KeyGen := TIntegerGenerator.Create(1, 1000, False);
  ValueGen := TStringGenerator.Create(5, 10, TStringCharSet.Alpha);
  DictGen := TDictionaryGenerator.Create(3, 8, KeyGen, ValueGen, TypeInfo(Int64), TypeInfo(string));

  Value := DictGen.GenerateValue;
  Dict := Value.AsType<IDictionary<Int64, string>>;

  Assert.IsNotNull(Dict, 'Generated dictionary should not be nil');
  Assert.IsTrue(Dict.Count >= 3, 'Dictionary should have at least 3 entries');
  Assert.IsTrue(Dict.Count <= 8, 'Dictionary should have at most 8 entries');
end;

procedure TCollectionGeneratorTests.TestDictionaryGeneratorRespectsMinMaxCount;
var
  KeyGen: IValueGenerator;
  ValueGen: IValueGenerator;
  DictGen: IValueGenerator;
  Value: TValue;
  Dict: IDictionary<Int64, string>;
  I: Integer;
begin
  KeyGen := TIntegerGenerator.Create(1, 10000, False);
  ValueGen := TStringGenerator.Create(5, 10, TStringCharSet.Alpha);
  DictGen := TDictionaryGenerator.Create(2, 4, KeyGen, ValueGen, TypeInfo(Int64), TypeInfo(string));

  for I := 1 to 20 do
  begin
    Value := DictGen.GenerateValue;
    Dict := Value.AsType<IDictionary<Int64, string>>;
    Assert.IsTrue(Dict.Count >= 2, Format('Iteration %d: Dictionary too small', [I]));
    Assert.IsTrue(Dict.Count <= 4, Format('Iteration %d: Dictionary too large', [I]));
  end;
end;

{ TCollectionHelperTests }

procedure TCollectionHelperTests.TestArrayOfIntegersHelper;
var
  ArrayGen: IValueGenerator;
  Value: TValue;
  Values: TArray<Int64>;
  I: Integer;
begin
  ArrayGen := THypothesis.ArrayOfIntegers(5, 10, 1, 100, False);
  Value := ArrayGen.GenerateValue;
  Values := Value.AsType<TArray<Int64>>;

  Assert.IsTrue(Length(Values) >= 5);
  Assert.IsTrue(Length(Values) <= 10);

  for I := 0 to High(Values) do
  begin
    Assert.IsTrue(Values[I] >= 1);
    Assert.IsTrue(Values[I] <= 100);
  end;
end;

procedure TCollectionHelperTests.TestArrayOfStringsHelper;
var
  ArrayGen: IValueGenerator;
  Value: TValue;
  Values: TArray<string>;
  I: Integer;
begin
  ArrayGen := THypothesis.ArrayOfStrings(3, 7, 5, 15, TStringCharSet.Alpha);
  Value := ArrayGen.GenerateValue;
  Values := Value.AsType<TArray<string>>;

  Assert.IsTrue(Length(Values) >= 3);
  Assert.IsTrue(Length(Values) <= 7);

  for I := 0 to High(Values) do
  begin
    Assert.IsTrue(Values[I].Length >= 5, Format('String[%d] too short: %d', [I, Values[I].Length]));
    Assert.IsTrue(Values[I].Length <= 15, Format('String[%d] too long: %d', [I, Values[I].Length]));
  end;
end;

procedure TCollectionHelperTests.TestListOfIntegersHelper;
var
  ListGen: IValueGenerator;
  Value: TValue;
  Values: IList<Int64>;
  I: Integer;
begin
  ListGen := THypothesis.ListOfIntegers(5, 10, 1, 100, False);
  Value := ListGen.GenerateValue;
  Values := Value.AsType<IList<Int64>>;

  Assert.IsTrue(Values.Count >= 5);
  Assert.IsTrue(Values.Count <= 10);

  for I := 0 to Values.Count - 1 do
  begin
    Assert.IsTrue(Values[I] >= 1);
    Assert.IsTrue(Values[I] <= 100);
  end;
end;

procedure TCollectionHelperTests.TestListOfStringsHelper;
var
  ListGen: IValueGenerator;
  Value: TValue;
  Values: IList<string>;
  I: Integer;
begin
  ListGen := THypothesis.ListOfStrings(3, 7, 5, 15, TStringCharSet.Alpha);
  Value := ListGen.GenerateValue;
  Values := Value.AsType<IList<string>>;

  Assert.IsTrue(Values.Count >= 3);
  Assert.IsTrue(Values.Count <= 7);

  for I := 0 to Values.Count - 1 do
  begin
    Assert.IsTrue(Values[I].Length >= 5);
    Assert.IsTrue(Values[I].Length <= 15);
  end;
end;

procedure TCollectionHelperTests.TestDictIntegerToStringHelper;
var
  DictGen: IValueGenerator;
  Value: TValue;
  Dict: IDictionary<Int64, string>;
begin
  DictGen := THypothesis.DictIntegerToString(3, 8, 1, 100, 5, 15, TStringCharSet.Alpha);
  Value := DictGen.GenerateValue;
  Dict := Value.AsType<IDictionary<Int64, string>>;

  Assert.IsTrue(Dict.Count >= 3);
  Assert.IsTrue(Dict.Count <= 8);
end;

procedure TCollectionHelperTests.TestDictStringToIntegerHelper;
var
  DictGen: IValueGenerator;
  Value: TValue;
  Dict: IDictionary<string, Int64>;
begin
  DictGen := THypothesis.DictStringToInteger(3, 8, 5, 15, TStringCharSet.Alpha, 1, 100);
  Value := DictGen.GenerateValue;
  Dict := Value.AsType<IDictionary<string, Int64>>;

  Assert.IsTrue(Dict.Count >= 3);
  Assert.IsTrue(Dict.Count <= 8);
end;

{ TCollectionPropertyTests }

procedure TCollectionPropertyTests.RunTestArraySum;
begin
  THypothesis.Run(Self, 'TestArraySum', [
    THypothesis.ArrayOfIntegers(5, 10, 1, 100)
  ], 50);
end;

procedure TCollectionPropertyTests.TestArraySum(const Values: TArray<Int64>);
var
  Sum: Int64;
  I: Integer;
begin
  Sum := 0;
  for I := 0 to High(Values) do
    Sum := Sum + Values[I];

  // Properties: all values are positive, so sum should be positive
  Assert.IsTrue(Sum > 0, Format('Sum of positive integers should be positive, got %d', [Sum]));
  Assert.IsTrue(Length(Values) >= 5, 'Array should have at least 5 elements');
  Assert.IsTrue(Length(Values) <= 10, 'Array should have at most 10 elements');
end;

procedure TCollectionPropertyTests.RunTestListContains;
begin
  THypothesis.Run(Self, 'TestListContains', [
    THypothesis.ListOfIntegers(5, 10, 1, 100)
  ], 50);
end;

procedure TCollectionPropertyTests.TestListContains(const Values: IList<Int64>);
var
  TestValue: Int64;
begin
  // If list is not empty, first element should be contained
  if Values.Count > 0 then
  begin
    TestValue := Values[0];
    Assert.IsTrue(Values.Contains(TestValue), Format('List should contain its first element %d', [TestValue]));
  end;

  Assert.IsTrue(Values.Count >= 5);
  Assert.IsTrue(Values.Count <= 10);
end;

procedure TCollectionPropertyTests.RunTestArrayConcatenation;
begin
  THypothesis.Run(Self, 'TestArrayConcatenation', [
    THypothesis.ArrayOfIntegers(3, 5, 1, 100),
    THypothesis.ArrayOfIntegers(3, 5, 1, 100)
  ], 50);
end;

procedure TCollectionPropertyTests.TestArrayConcatenation(const A1, A2: TArray<Int64>);
var
  Combined: TArray<Int64>;
  I: Integer;
begin
  // Concatenate arrays
  SetLength(Combined, Length(A1) + Length(A2));
  for I := 0 to High(A1) do
    Combined[I] := A1[I];
  for I := 0 to High(A2) do
    Combined[Length(A1) + I] := A2[I];

  // Property: combined length equals sum of individual lengths
  Assert.AreEqual(Length(A1) + Length(A2), Length(Combined),
                  Format('Combined array length should be %d + %d = %d',
                        [Length(A1), Length(A2), Length(A1) + Length(A2)]));
end;

end.
