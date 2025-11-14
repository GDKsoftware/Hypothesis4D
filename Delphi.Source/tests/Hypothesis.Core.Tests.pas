unit Hypothesis.Core.Tests;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Math,
  Hypothesis.Attributes,
  Hypothesis.Runner;

type
  [TestFixture]
  TIntegerPropertyTests = class
  public
    [Test]
    procedure RunTestReversePreservesSign;

    [ForAll(100)]
    procedure TestReversePreservesSign([IntRange(-1000, 1000)] const Value: Integer);

    [Test]
    procedure RunTestAdditionIsCommutative;

    [ForAll(100)]
    procedure TestAdditionIsCommutative([IntRange(-1000, 1000)] const A: Integer;
                                        [IntRange(-1000, 1000)] const B: Integer);

    [Test]
    procedure RunTestAbsoluteValueIsNonNegative;

    [ForAll(100)]
    procedure TestAbsoluteValueIsNonNegative([IntRange(Low(Integer) + 1, High(Integer) - 1)] const Value: Integer);

    [Test]
    procedure RunTestPositiveValuesArePositive;

    [ForAll(100)]
    procedure TestPositiveValuesArePositive([IntPositive(10000)] const Value: Integer);

    [Test]
    procedure RunTestNegativeValuesAreNegative;

    [ForAll(100)]
    procedure TestNegativeValuesAreNegative([IntNegative(-10000)] const Value: Integer);

    [Test]
    procedure RunTestNonZeroValuesAreNotZero;

    [ForAll(100)]
    procedure TestNonZeroValuesAreNotZero([IntNonZero(-1000, 1000)] const Value: Integer);
  end;

  [TestFixture]
  TBooleanPropertyTests = class
  public
    [Test]
    procedure RunTestDoubleNegation;

    [ForAll(100)]
    procedure TestDoubleNegation([Boolean] const Value: Boolean);

    [Test]
    procedure RunTestAndIsCommutative;

    [ForAll(100)]
    procedure TestAndIsCommutative([Boolean] const A: Boolean;
                                   [Boolean] const B: Boolean);

    [Test]
    procedure RunTestOrIsCommutative;

    [ForAll(100)]
    procedure TestOrIsCommutative([Boolean] const A: Boolean;
                                  [Boolean] const B: Boolean);

    [Test]
    procedure RunTestDeMorganAnd;

    [ForAll(100)]
    procedure TestDeMorganAnd([Boolean] const A: Boolean;
                              [Boolean] const B: Boolean);

    [Test]
    procedure RunTestDeMorganOr;

    [ForAll(100)]
    procedure TestDeMorganOr([Boolean] const A: Boolean;
                             [Boolean] const B: Boolean);
  end;

  [TestFixture]
  TFloatPropertyTests = class
  public
    [Test]
    procedure RunTestAdditionIsCommutative;

    [ForAll(100)]
    procedure TestAdditionIsCommutative([FloatRange(-1000.0, 1000.0)] const A: Double;
                                        [FloatRange(-1000.0, 1000.0)] const B: Double);

    [Test]
    procedure RunTestAbsoluteValueIsPositive;

    [ForAll(100)]
    procedure TestAbsoluteValueIsPositive([FloatRange(-1000.0, 1000.0)] const Value: Double);

    [Test]
    procedure RunTestSqrtSquare;

    [ForAll(100)]
    procedure TestSqrtSquare([FloatPositive(1000.0)] const Value: Double);

    [Test]
    procedure RunTestUnitIntervalBounds;

    [ForAll(100)]
    procedure TestUnitIntervalBounds([FloatUnit] const Value: Double);

    [Test]
    procedure RunTestPositiveValuesArePositive;

    [ForAll(100)]
    procedure TestPositiveValuesArePositive([FloatPositive(1000.0)] const Value: Double);

    [Test]
    procedure RunTestNegativeValuesAreNegative;

    [ForAll(100)]
    procedure TestNegativeValuesAreNegative([FloatNegative(-1000.0)] const Value: Double);
  end;

  [TestFixture]
  TDateTimePropertyTests = class
  public
    [Test]
    procedure RunTestDateAddSubtract;

    [ForAll(100)]
    procedure TestDateAddSubtract([DateRange(1900, 2100)] const Date: TDate);

    [Test]
    procedure RunTestDateOrdering;

    [ForAll(100)]
    procedure TestDateOrdering([DateRange(1900, 2100)] const Date1: TDate;
                               [DateRange(1900, 2100)] const Date2: TDate);

    [Test]
    procedure RunTestTimeWithinDay;

    [ForAll(100)]
    procedure TestTimeWithinDay([TimeRange] const Time: TTime);

    [Test]
    procedure RunTestDateTimeComponents;

    [ForAll(100)]
    procedure TestDateTimeComponents([DateTimeRange(1900, 2100)] const DT: TDateTime);

    [Test]
    procedure RunTestRecentDatesAreRecent;

    [ForAll(100)]
    procedure TestRecentDatesAreRecent([DateRecent(30)] const Date: TDate);
  end;

  [TestFixture]
  TStringPropertyTests = class
  public
    [Test]
    procedure RunTestReverseOfReverseIsIdentity;

    [ForAll(100)]
    procedure TestReverseOfReverseIsIdentity([StringAlpha(0, 100)] const Text: string);

    [Test]
    procedure RunTestConcatenationLength;

    [ForAll(100)]
    procedure TestConcatenationLength([StringAlpha(0, 50)] const A: string;
                                      [StringAlpha(0, 50)] const B: string);

    [Test]
    procedure RunTestUpperCaseIsIdempotent;

    [ForAll(100)]
    procedure TestUpperCaseIsIdempotent([StringAlpha(0, 100)] const Text: string);

    [Test]
    procedure RunTestAlphaStringContainsOnlyLetters;

    [ForAll(100)]
    procedure TestAlphaStringContainsOnlyLetters([StringAlpha(1, 50)] const Text: string);

    [Test]
    procedure RunTestNumericStringContainsOnlyDigits;

    [ForAll(100)]
    procedure TestNumericStringContainsOnlyDigits([StringNumeric(1, 50)] const Text: string);

    [Test]
    procedure RunTestEmptyStringHandling;

    [ForAll(100)]
    procedure TestEmptyStringHandling([StringGen(0, 100)] const Text: string);
  end;

  [TestFixture]
  TCombinedPropertyTests = class
  public
    [Test]
    procedure RunTestStringRepetition;

    [ForAll(100)]
    procedure TestStringRepetition([StringAlpha(1, 20)] const Text: string;
                                   [IntPositive(10)] const Count: Integer);

    [Test]
    procedure RunTestSubstringLength;

    [ForAll(100)]
    procedure TestSubstringLength([StringAlpha(5, 50)] const Text: string;
                                  [IntPositive(5)] const Start: Integer);
  end;

implementation

uses
  System.DateUtils;

function ReverseInteger(const Value: Integer): Integer;
var
  AbsValue: Integer;
  IsNegative: Boolean;
begin
  Result := 0;
  AbsValue := Abs(Value);
  IsNegative := (Value < 0);

  while AbsValue > 0 do
  begin
    Result := Result * 10 + (AbsValue mod 10);
    AbsValue := AbsValue div 10;
  end;

  if IsNegative then
    Result := -Result;
end;

function ReverseString(const Text: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := Text.Length downto 1 do
    Result := Result + Text[I];
end;

function IsAlpha(const Ch: Char): Boolean;
begin
  Result := ((Ch >= 'A') and (Ch <= 'Z')) or ((Ch >= 'a') and (Ch <= 'z'));
end;

function IsNumeric(const Ch: Char): Boolean;
begin
  Result := (Ch >= '0') and (Ch <= '9');
end;

procedure TBooleanPropertyTests.RunTestDoubleNegation;
begin
  THypothesis.Run(Self, 'TestDoubleNegation');
end;

procedure TBooleanPropertyTests.RunTestAndIsCommutative;
begin
  THypothesis.Run(Self, 'TestAndIsCommutative');
end;

procedure TBooleanPropertyTests.RunTestOrIsCommutative;
begin
  THypothesis.Run(Self, 'TestOrIsCommutative');
end;

procedure TBooleanPropertyTests.RunTestDeMorganAnd;
begin
  THypothesis.Run(Self, 'TestDeMorganAnd');
end;

procedure TBooleanPropertyTests.RunTestDeMorganOr;
begin
  THypothesis.Run(Self, 'TestDeMorganOr');
end;

procedure TBooleanPropertyTests.TestDoubleNegation(const Value: Boolean);
begin
  Assert.AreEqual(Value, not (not Value), 'Double negation should equal original value');
end;

procedure TBooleanPropertyTests.TestAndIsCommutative(const A: Boolean; const B: Boolean);
begin
  Assert.AreEqual(A and B, B and A, 'Boolean AND should be commutative');
end;

procedure TBooleanPropertyTests.TestOrIsCommutative(const A: Boolean; const B: Boolean);
begin
  Assert.AreEqual(A or B, B or A, 'Boolean OR should be commutative');
end;

procedure TBooleanPropertyTests.TestDeMorganAnd(const A: Boolean; const B: Boolean);
begin
  Assert.AreEqual(not (A and B), (not A) or (not B), 'De Morgan''s law for AND should hold');
end;

procedure TBooleanPropertyTests.TestDeMorganOr(const A: Boolean; const B: Boolean);
begin
  Assert.AreEqual(not (A or B), (not A) and (not B), 'De Morgan''s law for OR should hold');
end;

procedure TFloatPropertyTests.RunTestAdditionIsCommutative;
begin
  THypothesis.Run(Self, 'TestAdditionIsCommutative');
end;

procedure TFloatPropertyTests.RunTestAbsoluteValueIsPositive;
begin
  THypothesis.Run(Self, 'TestAbsoluteValueIsPositive');
end;

procedure TFloatPropertyTests.RunTestSqrtSquare;
begin
  THypothesis.Run(Self, 'TestSqrtSquare');
end;

procedure TFloatPropertyTests.RunTestUnitIntervalBounds;
begin
  THypothesis.Run(Self, 'TestUnitIntervalBounds');
end;

procedure TFloatPropertyTests.RunTestPositiveValuesArePositive;
begin
  THypothesis.Run(Self, 'TestPositiveValuesArePositive');
end;

procedure TFloatPropertyTests.RunTestNegativeValuesAreNegative;
begin
  THypothesis.Run(Self, 'TestNegativeValuesAreNegative');
end;

procedure TFloatPropertyTests.TestAdditionIsCommutative(const A: Double; const B: Double);
const
  Epsilon = 1e-10;
begin
  Assert.IsTrue(Abs((A + B) - (B + A)) < Epsilon,
                Format('Addition should be commutative: %g + %g ≈ %g + %g', [A, B, B, A]));
end;

procedure TFloatPropertyTests.TestAbsoluteValueIsPositive(const Value: Double);
begin
  Assert.IsTrue(Abs(Value) >= 0,
                Format('Absolute value of %g should be non-negative, got %g', [Value, Abs(Value)]));
end;

procedure TFloatPropertyTests.TestSqrtSquare(const Value: Double);
const
  Epsilon = 1e-9;
var
  Square: Double;
  SqrtSquare: Double;
begin
  Square := Value * Value;
  SqrtSquare := Sqrt(Square);

  Assert.IsTrue(Abs(SqrtSquare - Value) < Epsilon,
                Format('Sqrt(%g * %g) should equal %g, got %g', [Value, Value, Value, SqrtSquare]));
end;

procedure TFloatPropertyTests.TestUnitIntervalBounds(const Value: Double);
begin
  Assert.IsTrue((Value >= 0.0) and (Value <= 1.0),
                Format('Value %g should be in [0.0, 1.0]', [Value]));
end;

procedure TFloatPropertyTests.TestPositiveValuesArePositive(const Value: Double);
begin
  Assert.IsTrue(Value > 0,
                Format('Value should be positive, got %g', [Value]));
end;

procedure TFloatPropertyTests.TestNegativeValuesAreNegative(const Value: Double);
begin
  Assert.IsTrue(Value < 0,
                Format('Value should be negative, got %g', [Value]));
end;

procedure TDateTimePropertyTests.RunTestDateAddSubtract;
begin
  THypothesis.Run(Self, 'TestDateAddSubtract');
end;

procedure TDateTimePropertyTests.RunTestDateOrdering;
begin
  THypothesis.Run(Self, 'TestDateOrdering');
end;

procedure TDateTimePropertyTests.RunTestTimeWithinDay;
begin
  THypothesis.Run(Self, 'TestTimeWithinDay');
end;

procedure TDateTimePropertyTests.RunTestDateTimeComponents;
begin
  THypothesis.Run(Self, 'TestDateTimeComponents');
end;

procedure TDateTimePropertyTests.RunTestRecentDatesAreRecent;
begin
  THypothesis.Run(Self, 'TestRecentDatesAreRecent');
end;

procedure TDateTimePropertyTests.TestDateAddSubtract(const Date: TDate);
var
  DatePlusOne: TDate;
  DateMinusOne: TDate;
begin
  DatePlusOne := Date + 1;
  DateMinusOne := DatePlusOne - 1;

  Assert.AreEqual(Int(Date), Int(DateMinusOne),
                  Format('(Date + 1) - 1 should equal original date', []));
end;

procedure TDateTimePropertyTests.TestDateOrdering(const Date1: TDate; const Date2: TDate);
var
  DaysDiff: Int64;
begin
  DaysDiff := DaysBetween(Date1, Date2);
  Assert.IsTrue(DaysDiff >= 0,
                Format('DaysBetween should always be non-negative, got %d', [DaysDiff]));
end;

procedure TDateTimePropertyTests.TestTimeWithinDay(const Time: TTime);
begin
  Assert.IsTrue((Time >= 0) and (Time < 1.0),
                Format('Time %g should be in range [0.0, 1.0)', [Time]));
end;

procedure TDateTimePropertyTests.TestDateTimeComponents(const DT: TDateTime);
var
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
  Reconstructed: TDateTime;
const
  Epsilon = 0.001; // 1 millisecond tolerance
begin
  DecodeDate(DT, Year, Month, Day);
  DecodeTime(DT, Hour, Min, Sec, MSec);

  Assert.IsTrue((Year >= 1900) and (Year <= 2100),
                Format('Year %d should be in valid range', [Year]));
  Assert.IsTrue((Month >= 1) and (Month <= 12),
                Format('Month %d should be in valid range', [Month]));
  Assert.IsTrue((Day >= 1) and (Day <= 31),
                Format('Day %d should be in valid range', [Day]));

  // Verify we can reconstruct the datetime
  Reconstructed := EncodeDate(Year, Month, Day) + EncodeTime(Hour, Min, Sec, MSec);
  Assert.IsTrue(Abs(DT - Reconstructed) < Epsilon,
                Format('Reconstructed datetime should match original within %g', [Epsilon]));
end;

procedure TDateTimePropertyTests.TestRecentDatesAreRecent(const Date: TDate);
var
  Today: TDate;
  DaysDiff: Integer;
begin
  Today := Date;
  DaysDiff := DaysBetween(Date, Today);

  Assert.IsTrue(DaysDiff <= 30,
                Format('Recent date should be within 30 days, got %d days', [DaysDiff]));
end;

procedure TIntegerPropertyTests.RunTestReversePreservesSign;
begin
  THypothesis.Run(Self, 'TestReversePreservesSign');
end;

procedure TIntegerPropertyTests.RunTestAdditionIsCommutative;
begin
  THypothesis.Run(Self, 'TestAdditionIsCommutative');
end;

procedure TIntegerPropertyTests.RunTestAbsoluteValueIsNonNegative;
begin
  THypothesis.Run(Self, 'TestAbsoluteValueIsNonNegative');
end;

procedure TIntegerPropertyTests.RunTestPositiveValuesArePositive;
begin
  THypothesis.Run(Self, 'TestPositiveValuesArePositive');
end;

procedure TIntegerPropertyTests.RunTestNegativeValuesAreNegative;
begin
  THypothesis.Run(Self, 'TestNegativeValuesAreNegative');
end;

procedure TIntegerPropertyTests.RunTestNonZeroValuesAreNotZero;
begin
  THypothesis.Run(Self, 'TestNonZeroValuesAreNotZero');
end;

procedure TIntegerPropertyTests.TestReversePreservesSign(const Value: Integer);
var
  Reversed: Integer;
begin
  Reversed := ReverseInteger(Value);

  if Value > 0 then
    Assert.IsTrue(Reversed > 0, Format('Reversing positive %d should give positive result, got %d', [Value, Reversed]))
  else if Value < 0 then
    Assert.IsTrue(Reversed < 0, Format('Reversing negative %d should give negative result, got %d', [Value, Reversed]))
  else
    Assert.AreEqual(0, Reversed, 'Reversing zero should give zero');
end;

procedure TIntegerPropertyTests.TestAdditionIsCommutative(const A: Integer; const B: Integer);
var
  Sum1: Int64;
  Sum2: Int64;
begin
  Sum1 := Int64(A) + Int64(B);
  Sum2 := Int64(B) + Int64(A);

  Assert.AreEqual(Sum1, Sum2, Format('Addition should be commutative: %d + %d = %d + %d', [A, B, B, A]));
end;

procedure TIntegerPropertyTests.TestAbsoluteValueIsNonNegative(const Value: Integer);
var
  AbsValue: Int64;
begin
  AbsValue := Abs(Int64(Value));

  Assert.IsTrue(AbsValue >= 0, Format('Absolute value of %d should be non-negative, got %d', [Value, AbsValue]));
end;

procedure TIntegerPropertyTests.TestPositiveValuesArePositive(const Value: Integer);
begin
  Assert.IsTrue(Value > 0, Format('Value should be positive, got %d', [Value]));
end;

procedure TIntegerPropertyTests.TestNegativeValuesAreNegative(const Value: Integer);
begin
  Assert.IsTrue(Value < 0, Format('Value should be negative, got %d', [Value]));
end;

procedure TIntegerPropertyTests.TestNonZeroValuesAreNotZero(const Value: Integer);
begin
  Assert.AreNotEqual(0, Value, 'Value should not be zero');
end;

procedure TStringPropertyTests.RunTestReverseOfReverseIsIdentity;
begin
  THypothesis.Run(Self, 'TestReverseOfReverseIsIdentity');
end;

procedure TStringPropertyTests.RunTestConcatenationLength;
begin
  THypothesis.Run(Self, 'TestConcatenationLength');
end;

procedure TStringPropertyTests.RunTestUpperCaseIsIdempotent;
begin
  THypothesis.Run(Self, 'TestUpperCaseIsIdempotent');
end;

procedure TStringPropertyTests.RunTestAlphaStringContainsOnlyLetters;
begin
  THypothesis.Run(Self, 'TestAlphaStringContainsOnlyLetters');
end;

procedure TStringPropertyTests.RunTestNumericStringContainsOnlyDigits;
begin
  THypothesis.Run(Self, 'TestNumericStringContainsOnlyDigits');
end;

procedure TStringPropertyTests.RunTestEmptyStringHandling;
begin
  THypothesis.Run(Self, 'TestEmptyStringHandling');
end;

procedure TStringPropertyTests.TestReverseOfReverseIsIdentity(const Text: string);
var
  Reversed: string;
  DoubleReversed: string;
begin
  Reversed := ReverseString(Text);
  DoubleReversed := ReverseString(Reversed);

  Assert.AreEqual(Text, DoubleReversed, 'Reverse of reverse should equal original text');
end;

procedure TStringPropertyTests.TestConcatenationLength(const A: string; const B: string);
var
  Combined: string;
begin
  Combined := A + B;

  Assert.AreEqual(A.Length + B.Length, Combined.Length, Format('Concatenation length should equal sum of parts: %d + %d', [A.Length, B.Length]));
end;

procedure TStringPropertyTests.TestUpperCaseIsIdempotent(const Text: string);
var
  Upper1: string;
  Upper2: string;
begin
  Upper1 := Text.ToUpper;
  Upper2 := Upper1.ToUpper;

  Assert.AreEqual(Upper1, Upper2, 'Uppercase should be idempotent');
end;

procedure TStringPropertyTests.TestAlphaStringContainsOnlyLetters(const Text: string);
var
  I: Integer;
begin
  for I := 1 to Text.Length do
  begin
    Assert.IsTrue(IsAlpha(Text[I]), Format('Character at position %d should be a letter, got %s', [I, Text[I]]));
  end;
end;

procedure TStringPropertyTests.TestNumericStringContainsOnlyDigits(const Text: string);
var
  I: Integer;
begin
  for I := 1 to Text.Length do
  begin
    Assert.IsTrue(IsNumeric(Text[I]), Format('Character at position %d should be a digit, got %s', [I, Text[I]]));
  end;
end;

procedure TStringPropertyTests.TestEmptyStringHandling(const Text: string);
begin
  Assert.IsTrue(Text.Length >= 0, 'String length should be non-negative');

  if Text.Length = 0 then
    Assert.IsTrue(Text.IsEmpty, 'Empty string should report IsEmpty as true');
end;

procedure TCombinedPropertyTests.TestStringRepetition(const Text: string; const Count: Integer);
var
  Repeated: string;
  I: Integer;
begin
  Repeated := '';
  for I := 1 to Count do
    Repeated := Repeated + Text;

  Assert.AreEqual(Text.Length * Count, Repeated.Length, Format('Repeated string length should be %d * %d = %d', [Text.Length, Count, Text.Length * Count]));
end;

procedure TCombinedPropertyTests.TestSubstringLength(const Text: string; const Start: Integer);
var
  SafeStart: Integer;
  Sub: string;
begin
  SafeStart := Min(Start, Text.Length);

  if SafeStart > 0 then
  begin
    Sub := Text.Substring(SafeStart - 1);
    Assert.AreEqual(Text.Length - SafeStart + 1, Sub.Length, Format('Substring from position %d should have correct length', [SafeStart]));
  end;
end;

procedure TCombinedPropertyTests.RunTestStringRepetition;
begin
  THypothesis.Run(Self, 'TestStringRepetition');
end;

procedure TCombinedPropertyTests.RunTestSubstringLength;
begin
  THypothesis.Run(Self, 'TestSubstringLength');
end;

end.
