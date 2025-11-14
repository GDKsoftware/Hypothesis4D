unit Hypothesis.Examples.Tests;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Hypothesis.Attributes,
  Hypothesis.Runner,
  Hypothesis.Examples;

type
  [TestFixture]
  TStringUtilsPropertyTests = class
  public
    [Test]
    procedure RunTestReverseIsInvolutive;

    [ForAll(100)]
    procedure TestReverseIsInvolutive([StringAlpha(0, 50)] const Text: string);

    [Test]
    procedure RunTestReverseLengthPreserved;

    [ForAll(100)]
    procedure TestReverseLengthPreserved([StringGen(0, 100)] const Text: string);
  end;

  [TestFixture]
  TMathUtilsPropertyTests = class
  public
    [Test]
    procedure RunTestAdditionIsCommutative;

    [ForAll(100)]
    procedure TestAdditionIsCommutative([IntRange(-1000, 1000)] const A: Integer;
                                        [IntRange(-1000, 1000)] const B: Integer);

    [Test]
    procedure RunTestAdditionIsAssociative;

    [ForAll(100)]
    procedure TestAdditionIsAssociative([IntRange(-100, 100)] const A: Integer;
                                        [IntRange(-100, 100)] const B: Integer;
                                        [IntRange(-100, 100)] const C: Integer);

    [Test]
    procedure RunTestIsEvenConsistency;

    [ForAll(100)]
    procedure TestIsEvenConsistency([IntRange(-10000, 10000)] const Value: Integer);
  end;

implementation

procedure TStringUtilsPropertyTests.RunTestReverseIsInvolutive;
begin
  THypothesis.Run(Self, 'TestReverseIsInvolutive');
end;

procedure TStringUtilsPropertyTests.RunTestReverseLengthPreserved;
begin
  THypothesis.Run(Self, 'TestReverseLengthPreserved');
end;

procedure TStringUtilsPropertyTests.TestReverseIsInvolutive(const Text: string);
var
  Reversed: string;
  DoubleReversed: string;
begin
  Reversed := TStringUtils.Reverse(Text);
  DoubleReversed := TStringUtils.Reverse(Reversed);

  Assert.AreEqual(Text, DoubleReversed,
    'Reversing a string twice should yield the original string');
end;

procedure TStringUtilsPropertyTests.TestReverseLengthPreserved(const Text: string);
var
  Reversed: string;
begin
  Reversed := TStringUtils.Reverse(Text);

  Assert.AreEqual(Text.Length, Reversed.Length,
    'Reversing should preserve string length');
end;

procedure TMathUtilsPropertyTests.TestAdditionIsCommutative(const A: Integer; const B: Integer);
var
  Sum1: Int64;
  Sum2: Int64;
begin
  Sum1 := TMathUtils.Add(A, B);
  Sum2 := TMathUtils.Add(B, A);

  Assert.AreEqual(Sum1, Sum2,
    Format('Addition should be commutative: %d + %d = %d + %d', [A, B, B, A]));
end;

procedure TMathUtilsPropertyTests.TestAdditionIsAssociative(const A: Integer; const B: Integer; const C: Integer);
var
  Result1: Int64;
  Result2: Int64;
begin
  Result1 := TMathUtils.Add(TMathUtils.Add(A, B), C);
  Result2 := TMathUtils.Add(A, TMathUtils.Add(B, C));

  Assert.AreEqual(Result1, Result2,
    Format('Addition should be associative: (%d + %d) + %d = %d + (%d + %d)', [A, B, C, A, B, C]));
end;

procedure TMathUtilsPropertyTests.RunTestAdditionIsCommutative;
begin
  THypothesis.Run(Self, 'TestAdditionIsCommutative');
end;

procedure TMathUtilsPropertyTests.RunTestAdditionIsAssociative;
begin
  THypothesis.Run(Self, 'TestAdditionIsAssociative');
end;

procedure TMathUtilsPropertyTests.RunTestIsEvenConsistency;
begin
  THypothesis.Run(Self, 'TestIsEvenConsistency');
end;

procedure TMathUtilsPropertyTests.TestIsEvenConsistency(const Value: Integer);
var
  IsEven: Boolean;
  ExpectedEven: Boolean;
begin
  IsEven := TMathUtils.IsEven(Value);
  ExpectedEven := (Value mod 2) = 0;

  Assert.AreEqual(ExpectedEven, IsEven,
    Format('IsEven(%d) should return %s', [Value, BoolToStr(ExpectedEven, True)]));
end;

end.
