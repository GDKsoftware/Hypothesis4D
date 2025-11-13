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
    procedure TestReversePreservesSign([IntRange('Value', -1000, 1000)] const Value: Integer);

    [Test]
    procedure RunTestAdditionIsCommutative;

    [ForAll(100)]
    procedure TestAdditionIsCommutative([IntRange('A', -1000, 1000)] const A: Integer;
                                        [IntRange('B', -1000, 1000)] const B: Integer);

    [Test]
    procedure RunTestAbsoluteValueIsNonNegative;

    [ForAll(100)]
    procedure TestAbsoluteValueIsNonNegative([IntRange('Value', Low(Integer) + 1, High(Integer) - 1)] const Value: Integer);

    [Test]
    procedure RunTestPositiveValuesArePositive;

    [ForAll(100)]
    procedure TestPositiveValuesArePositive([IntPositive('Value', 10000)] const Value: Integer);

    [Test]
    procedure RunTestNegativeValuesAreNegative;

    [ForAll(100)]
    procedure TestNegativeValuesAreNegative([IntNegative('Value', -10000)] const Value: Integer);

    [Test]
    procedure RunTestNonZeroValuesAreNotZero;

    [ForAll(100)]
    procedure TestNonZeroValuesAreNotZero([IntNonZero('Value', -1000, 1000)] const Value: Integer);
  end;

  [TestFixture]
  TStringPropertyTests = class
  public
    [Test]
    procedure RunTestReverseOfReverseIsIdentity;

    [ForAll(100)]
    procedure TestReverseOfReverseIsIdentity([StringAlpha('Text', 0, 100)] const Text: string);

    [Test]
    procedure RunTestConcatenationLength;

    [ForAll(100)]
    procedure TestConcatenationLength([StringAlpha('A', 0, 50)] const A: string;
                                      [StringAlpha('B', 0, 50)] const B: string);

    [Test]
    procedure RunTestUpperCaseIsIdempotent;

    [ForAll(100)]
    procedure TestUpperCaseIsIdempotent([StringAlpha('Text', 0, 100)] const Text: string);

    [Test]
    procedure RunTestAlphaStringContainsOnlyLetters;

    [ForAll(100)]
    procedure TestAlphaStringContainsOnlyLetters([StringAlpha('Text', 1, 50)] const Text: string);

    [Test]
    procedure RunTestNumericStringContainsOnlyDigits;

    [ForAll(100)]
    procedure TestNumericStringContainsOnlyDigits([StringNumeric('Text', 1, 50)] const Text: string);

    [Test]
    procedure RunTestEmptyStringHandling;

    [ForAll(100)]
    procedure TestEmptyStringHandling([StringGen('Text', 0, 100)] const Text: string);
  end;

  [TestFixture]
  TCombinedPropertyTests = class
  public
    [Test]
    procedure RunTestStringRepetition;

    [ForAll(100)]
    procedure TestStringRepetition([StringAlpha('Text', 1, 20)] const Text: string;
                                   [IntPositive('Count', 10)] const Count: Integer);

    [Test]
    procedure RunTestSubstringLength;

    [ForAll(100)]
    procedure TestSubstringLength([StringAlpha('Text', 5, 50)] const Text: string;
                                  [IntPositive('Start', 5)] const Start: Integer);
  end;

implementation

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
