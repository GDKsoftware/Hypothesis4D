# Hypothesis for Delphi

A minimal property-based testing library for Delphi, inspired by [Python's Hypothesis library](https://hypothesis.readthedocs.io/en/latest/).

## Overview

Hypothesis for Delphi enables property-based testing using custom attributes and automatic value generation with shrinking support. Instead of writing individual test cases with specific values, you define properties that should hold true for all valid inputs, and Hypothesis generates test data automatically.

### Property-Based Testing vs Traditional Testing

Traditional unit tests verify behavior with specific, hand-picked examples: "when I reverse 'hello', I get 'olleh'". Property-based testing takes a different approach by defining general rules: "reversing any string twice returns the original". Hypothesis then automatically generates hundreds of test cases to verify this property holds for empty strings, single characters, long strings, special characters, and edge cases you might not have thought of. When a property fails, Hypothesis automatically "shrinks" the failing input to find the simplest example that breaks your code, making debugging much easier. This approach catches corner cases that manual testing often misses, while requiring less test code to write and maintain. Property-based testing complements traditional example-based tests perfectly: use examples for specific known scenarios and edge cases, and use properties to verify general behavior across a wide range of inputs.

## Features

- **Automatic Value Generation**: Generate random test data based on declarative strategies
- **Smart Shrinking**: When a test fails, automatically finds the minimal failing example
- **DUnitX Integration**: Seamless integration with the DUnitX test framework
- **Type-Safe**: Leverages Delphi's RTTI and generics for type safety
- **Configurable**: Control iteration counts and random seeds for reproducibility

## Requirements

- Delphi 11 (or newer)
- DUnitX test framework
- Spring4D collections library

## Installation

1. Add the `Delphi.Source\src` folder to your project's search path
2. Ensure DUnitX and Spring4D are available in your project
3. Add the required units to your test project:
   - `Hypothesis.Attributes` - Strategy attribute declarations
   - `Hypothesis.Runner` - Test execution helper
   - `Hypothesis.Core` - Core test runner (automatically included)
   - `Hypothesis.Generators.*` - Value generators (automatically included)

## Quick Start

```delphi
unit MyTests;

interface

uses
  DUnitX.TestFramework,
  Hypothesis.Attributes,
  Hypothesis.Runner;

type
  [TestFixture]
  TMyPropertyTests = class
  public
    [Test]
    procedure RunTestStringReverse;

    [ForAll(100)]
    procedure TestStringReverse([StringAlpha(0, 50)] const Text: string);
  end;

implementation

uses
  System.SysUtils;

function ReverseString(const S: string): string;
begin
  Result := '';
  for var I := S.Length downto 1 do
    Result := Result + S[I];
end;

procedure TMyPropertyTests.RunTestStringReverse;
begin
  THypothesis.Run(Self, 'TestStringReverse');
end;

procedure TMyPropertyTests.TestStringReverse(const Text: string);
begin
  var Reversed := ReverseString(Text);
  var DoubleReversed := ReverseString(Reversed);

  Assert.AreEqual(Text, DoubleReversed,
    'Reversing a string twice should give the original string');
end;

end.
```

## Strategy Attributes

### Integer Strategies

#### `IntRange(Min, Max)`
Generates integers within the specified range (inclusive).

```delphi
[Test]
procedure RunTestIntRange;

[ForAll(100)]
procedure TestIntRange([IntRange(-100, 100)] const Value: Integer);

// Implementation
procedure TMyTests.RunTestIntRange;
begin
  THypothesis.Run(Self, 'TestIntRange');
end;
```

#### `IntPositive(Max)`
Generates positive integers from 1 to Max (inclusive).

```delphi
[ForAll(100)]
procedure TestPositive([IntPositive(1000)] const Count: Integer);
```

#### `IntNegative(Min)`
Generates negative integers from Min to -1 (inclusive).

```delphi
[ForAll(100)]
procedure TestNegative([IntNegative(-1000)] const Debt: Integer);
```

#### `IntNonZero(Min, Max)`
Generates integers in the range Min to Max, excluding zero.

```delphi
[ForAll(100)]
procedure TestNonZero([IntNonZero(-100, 100)] const Divisor: Integer);
```

### String Strategies

#### `StringGen(MinLen, MaxLen)`
Generates strings with arbitrary printable characters.

```delphi
[ForAll(100)]
procedure TestAnyString([StringGen(0, 100)] const Text: string);
```

#### `StringAlpha(MinLen, MaxLen)`
Generates strings containing only alphabetic characters (A-Z, a-z).

```delphi
[ForAll(100)]
procedure TestAlphaString([StringAlpha(1, 50)] const Name: string);
```

#### `StringNumeric(MinLen, MaxLen)`
Generates strings containing only numeric digits (0-9).

```delphi
[ForAll(100)]
procedure TestNumericString([StringNumeric(5, 10)] const Code: string);
```

### Boolean Strategies

#### `Boolean`
Generates boolean values (True or False).

```delphi
[ForAll(100)]
procedure TestBoolean([Boolean] const Flag: Boolean);
```

### Float/Double Strategies

#### `FloatRange(Min, Max, AllowNaN, AllowInfinity)`
Generates floating-point values within the specified range.

```delphi
[ForAll(100)]
procedure TestFloatRange([FloatRange(-100.0, 100.0)] const Value: Double);

// With special values
[ForAll(100)]
procedure TestFloatSpecial([FloatRange(-10.0, 10.0, True, True)] const Value: Double);
```

#### `FloatPositive(Max)`
Generates positive floating-point values greater than zero.

```delphi
[ForAll(100)]
procedure TestPositiveFloat([FloatPositive(1000.0)] const Amount: Double);
```

#### `FloatNegative(Min)`
Generates negative floating-point values less than zero.

```delphi
[ForAll(100)]
procedure TestNegativeFloat([FloatNegative(-1000.0)] const Debt: Double);
```

#### `FloatUnit`
Generates floating-point values in the unit interval [0.0, 1.0].

```delphi
[ForAll(100)]
procedure TestProbability([FloatUnit] const Probability: Double);
```

### Date/DateTime Strategies

#### `DateRange(MinYear, MaxYear)`
Generates date values (TDate) within the specified year range.

```delphi
[ForAll(100)]
procedure TestDate([DateRange(1900, 2100)] const Date: TDate);
```

#### `DateTimeRange(MinYear, MaxYear)`
Generates datetime values (TDateTime) with both date and time components.

```delphi
[ForAll(100)]
procedure TestDateTime([DateTimeRange(1900, 2100)] const DT: TDateTime);
```

#### `DateRecent(Days)`
Generates recent dates within the specified number of days from today.

```delphi
[ForAll(100)]
procedure TestRecentDate([DateRecent(30)] const Date: TDate);
```

#### `TimeRange`
Generates time values (TTime) representing time of day (00:00:00 to 23:59:59).

```delphi
[ForAll(100)]
procedure TestTime([TimeRange] const Time: TTime);
```

### Collection Strategies

Collection generators (arrays, lists, dictionaries) require manual instantiation due to Delphi's compile-time constant requirements in attributes. Hypothesis provides convenient helper methods to simplify collection generation.

#### Using Collection Helpers

Instead of using attributes, use the helper methods with the generator-based `Run` overload:

```delphi
type
  [TestFixture]
  TCollectionTests = class
  public
    [Test]
    procedure RunTestArraySum;
    procedure TestArraySum(const Values: TArray<Int64>);
  end;

implementation

procedure TCollectionTests.RunTestArraySum;
begin
  THypothesis.Run(Self, 'TestArraySum', [
    THypothesis.ArrayOfIntegers(5, 10, 1, 100)
  ], 50);
end;

procedure TCollectionTests.TestArraySum(const Values: TArray<Int64>);
var
  Sum: Int64;
  I: Integer;
begin
  Sum := 0;
  for I := 0 to High(Values) do
    Sum := Sum + Values[I];

  Assert.IsTrue(Sum > 0, 'Sum of positive integers should be positive');
  Assert.IsTrue(Length(Values) >= 5);
  Assert.IsTrue(Length(Values) <= 10);
end;
```

#### Array Helper Methods

- `ArrayOfIntegers(MinCount, MaxCount, MinValue, MaxValue, ExcludeZero)` - Arrays of Int64
- `ArrayOfStrings(MinCount, MaxCount, MinLen, MaxLen, CharSet)` - Arrays of strings
- `ArrayOfFloats(MinCount, MaxCount, MinValue, MaxValue, AllowNaN, AllowInfinity)` - Arrays of Double
- `ArrayOfBooleans(MinCount, MaxCount)` - Arrays of Boolean
- `ArrayOf(MinCount, MaxCount, ElementGenerator, ElementTypeInfo)` - Generic array generator

```delphi
// Generate array of 3-7 strings, each 5-15 characters long
THypothesis.ArrayOfStrings(3, 7, 5, 15, TStringCharSet.Alpha)

// Generate array of 10-20 floats between -1.0 and 1.0
THypothesis.ArrayOfFloats(10, 20, -1.0, 1.0)
```

#### List Helper Methods

Lists use Spring4D's `IList<T>` interface:

- `ListOfIntegers(MinCount, MaxCount, MinValue, MaxValue, ExcludeZero)` - Lists of Int64
- `ListOfStrings(MinCount, MaxCount, MinLen, MaxLen, CharSet)` - Lists of strings
- `ListOfFloats(MinCount, MaxCount, MinValue, MaxValue, AllowNaN, AllowInfinity)` - Lists of Double
- `ListOfBooleans(MinCount, MaxCount)` - Lists of Boolean
- `ListOf(MinCount, MaxCount, ElementGenerator, ElementTypeInfo)` - Generic list generator

```delphi
procedure TTests.RunTestListContains;
begin
  THypothesis.Run(Self, 'TestListContains', [
    THypothesis.ListOfIntegers(5, 10, 1, 100)
  ], 50);
end;

procedure TTests.TestListContains(const Values: IList<Int64>);
begin
  if Values.Count > 0 then
    Assert.IsTrue(Values.Contains(Values[0]));
end;
```

#### Dictionary Helper Methods

Dictionaries use Spring4D's `IDictionary<K,V>` interface:

- `DictIntegerToString(MinCount, MaxCount, KeyMin, KeyMax, ValueMinLen, ValueMaxLen, ValueCharSet)` - Int64 → string
- `DictStringToInteger(MinCount, MaxCount, KeyMinLen, KeyMaxLen, KeyCharSet, ValueMin, ValueMax)` - string → Int64
- `DictStringToString(MinCount, MaxCount, KeyMinLen, KeyMaxLen, KeyCharSet, ValueMinLen, ValueMaxLen, ValueCharSet)` - string → string
- `DictOf(MinCount, MaxCount, KeyGenerator, ValueGenerator, KeyTypeInfo, ValueTypeInfo)` - Generic dictionary generator

```delphi
// Generate dictionary with 3-8 entries, Int64 keys (1-100), string values (5-15 chars)
THypothesis.DictIntegerToString(3, 8, 1, 100, 5, 15, TStringCharSet.Alpha)
```

#### Multiple Collection Parameters

You can pass multiple generators to test interactions between collections:

```delphi
procedure TTests.RunTestArrayConcatenation;
begin
  THypothesis.Run(Self, 'TestArrayConcatenation', [
    THypothesis.ArrayOfIntegers(3, 5, 1, 100),
    THypothesis.ArrayOfIntegers(3, 5, 1, 100)
  ], 50);
end;

procedure TTests.TestArrayConcatenation(const A1, A2: TArray<Int64>);
var
  Combined: TArray<Int64>;
begin
  SetLength(Combined, Length(A1) + Length(A2));
  // ... concatenation logic ...
  Assert.AreEqual(Length(A1) + Length(A2), Length(Combined));
end;
```

## Configuring Iterations

Use the `ForAll` attribute to specify the number of test iterations (default: 10).

```delphi
[ForAll(1000)]
procedure TestWithManyIterations([IntRange(1, 100)] const Value: Integer);
```

## Multiple Parameters

Property tests can accept multiple parameters with different strategies.

### Using Attribute-Based Generation

```delphi
[ForAll(100)]
procedure TestAddition([IntRange(-1000, 1000)] const A: Integer;
                       [IntRange(-1000, 1000)] const B: Integer);
begin
  const Sum = Int64(A) + Int64(B);
  Assert.AreEqual(Sum, Int64(B) + Int64(A), 'Addition should be commutative');
end;
```

### Using Generator-Based Execution

For more complex scenarios or when using collections, you can pass generators directly:

```delphi
[Test]
procedure RunTestComplexScenario;

procedure TestComplexScenario(const Values: TArray<Int64>; const Name: string);

// Implementation
procedure TTests.RunTestComplexScenario;
begin
  THypothesis.Run(Self, 'TestComplexScenario', [
    THypothesis.ArrayOfIntegers(5, 10, 1, 100),
    THypothesis.StringAlpha(3, 20)  // Note: StringAlpha not yet implemented as helper
  ], 50);
end;
```

**Note**: Currently, only collection helpers are available. String and other type helpers are planned for future versions.

## How Shrinking Works

When a test fails, Hypothesis automatically searches for a simpler failing example:

- **Integers**: Binary search towards zero within valid range
- **Strings**: Reduce length and simplify characters
- **Booleans**: True shrinks to False
- **Floats**: Special values → zero → nearest integer → halfway towards zero
- **Dates**: Year shrinks towards 2000, month towards January, day towards 1st
- **DateTimes**: Date components shrink as above, time shrinks towards midnight
- **Times**: Hour/minute/second/millisecond each shrink towards zero

Example failure output:

```
Property test failed on iteration 47/100
Original values: 'AbCdEfGhIjKlMnOp', 42
Minimal failing example: 'A', 1
Seed: 12345678
```

## Best Practices

1. **Keep properties simple**: Each test should verify one property
2. **Use appropriate ranges**: Don't generate more values than needed
3. **Handle edge cases**: Consider empty strings, zero, negative numbers
4. **Use meaningful parameter names**: The ParamName helps in error messages
5. **Start with fewer iterations**: Use 10-100 iterations during development, increase for CI

## Examples

The project includes two types of examples:

### Example Code
[Delphi.Source/examples/Hypothesis.Examples.pas](Delphi.Source/examples/Hypothesis.Examples.pas) - Simple utility classes demonstrating testable code:
- `TStringUtils`: String manipulation functions
- `TMathUtils`: Mathematical operations

### Example Tests
[Delphi.Source/examples/Hypothesis.Examples.Tests.pas](Delphi.Source/examples/Hypothesis.Examples.Tests.pas) - Property-based tests for the example code:
- String reversal properties (involutive, length preservation)
- Arithmetic properties (commutativity, associativity)
- Consistency checks

### Framework Tests
[Delphi.Source/tests/Hypothesis.Core.Tests.pas](Delphi.Source/tests/Hypothesis.Core.Tests.pas) - Comprehensive test suite including:
- Integer properties (reverse, addition, absolute value)
- String properties (reverse, concatenation, uppercase)
- Strategy validation (positive, negative, non-zero, alpha, numeric)
- Combined integer and string properties

## Architecture

The library consists of the following main components:

1. **Hypothesis.Attributes**: Custom attributes for declaring strategies (`ForAll`, `IntRange`, `StringAlpha`, etc.)
2. **Hypothesis.Generators.\***: Value generators with shrinking logic
   - `Hypothesis.Generators.Interfaces`: Base interface for all generators
   - `Hypothesis.Generators.Integers`: Integer value generation and shrinking
   - `Hypothesis.Generators.Strings`: String value generation and shrinking
   - `Hypothesis.Generators.Factory`: Creates appropriate generators from attributes
3. **Hypothesis.Core**: Test runner with RTTI-based parameter inspection and shrinking orchestration
4. **Hypothesis.Runner**: DUnitX framework integration helper (`THypothesis.Run`)
5. **Hypothesis.Exceptions**: Custom exception types for property test failures

## Limitations

Current implementation includes:

**✅ Supported Types**:
- Integers (Int64)
- Strings (with multiple character sets)
- Booleans
- Floats/Doubles (with special values)
- Dates, DateTimes, and Times
- Collections (TArray, IList, IDictionary via helper methods)

**⚠️ Collection Limitations**:
- Collections require manual instantiation using helper methods
- Cannot use attribute-based generation for collections (Delphi language limitation)
- Collection types are limited to: Int64, string, Double, Boolean

**📋 Not Yet Implemented**:
- Records and custom object types
- Advanced shrinking strategies
- Database/persistence for test cases
- Stateful testing
- Custom strategy composition
- Full generic collection support

Future versions may add support for records, advanced shrinking, and more flexible collection generators.

## Troubleshooting

### "Parameter has no strategy attribute"
Ensure all test method parameters have a strategy attribute (e.g., `IntRange`, `StringAlpha`).

### "Unsupported attribute type"
Check that you're using one of the supported strategy attributes.

### Tests are too slow
Reduce the number of iterations in the `ForAll` attribute or narrow the value ranges.

## Contributing

This is an experimental library. Feedback and contributions are welcome.

## License

[Specify your license here]

## Acknowledgments

Inspired by the excellent [Hypothesis library for Python](https://hypothesis.readthedocs.io/).
