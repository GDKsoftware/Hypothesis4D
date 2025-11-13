# Hypothesis for Delphi

A minimal property-based testing library for Delphi, inspired by Python's Hypothesis library.

## Overview

Hypothesis for Delphi enables property-based testing using custom attributes and automatic value generation with shrinking support. Instead of writing individual test cases with specific values, you define properties that should hold true for all valid inputs, and Hypothesis generates test data automatically.

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
    procedure TestStringReverse([StringAlpha('Text', 0, 50)] const Text: string);
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

#### `IntRange(ParamName, Min, Max)`
Generates integers within the specified range (inclusive).

```delphi
[Test]
procedure RunTestIntRange;

[ForAll(100)]
procedure TestIntRange([IntRange('Value', -100, 100)] const Value: Integer);

// Implementation
procedure TMyTests.RunTestIntRange;
begin
  THypothesis.Run(Self, 'TestIntRange');
end;
```

#### `IntPositive(ParamName, Max)`
Generates positive integers from 1 to Max (inclusive).

```delphi
[ForAll(100)]
procedure TestPositive([IntPositive('Count', 1000)] const Count: Integer);
```

#### `IntNegative(ParamName, Min)`
Generates negative integers from Min to -1 (inclusive).

```delphi
[ForAll(100)]
procedure TestNegative([IntNegative('Debt', -1000)] const Debt: Integer);
```

#### `IntNonZero(ParamName, Min, Max)`
Generates integers in the range Min to Max, excluding zero.

```delphi
[ForAll(100)]
procedure TestNonZero([IntNonZero('Divisor', -100, 100)] const Divisor: Integer);
```

### String Strategies

#### `StringGen(ParamName, MinLen, MaxLen)`
Generates strings with arbitrary printable characters.

```delphi
[ForAll(100)]
procedure TestAnyString([StringGen('Text', 0, 100)] const Text: string);
```

#### `StringAlpha(ParamName, MinLen, MaxLen)`
Generates strings containing only alphabetic characters (A-Z, a-z).

```delphi
[ForAll(100)]
procedure TestAlphaString([StringAlpha('Name', 1, 50)] const Name: string);
```

#### `StringNumeric(ParamName, MinLen, MaxLen)`
Generates strings containing only numeric digits (0-9).

```delphi
[ForAll(100)]
procedure TestNumericString([StringNumeric('Code', 5, 10)] const Code: string);
```

## Configuring Iterations

Use the `ForAll` attribute to specify the number of test iterations (default: 10).

```delphi
[ForAll(1000)]
procedure TestWithManyIterations([IntRange('Value', 1, 100)] const Value: Integer);
```

## Multiple Parameters

Property tests can accept multiple parameters with different strategies:

```delphi
[ForAll(100)]
procedure TestAddition([IntRange('A', -1000, 1000)] const A: Integer;
                       [IntRange('B', -1000, 1000)] const B: Integer);
begin
  const Sum = Int64(A) + Int64(B);
  Assert.AreEqual(Sum, Int64(B) + Int64(A), 'Addition should be commutative');
end;
```

## How Shrinking Works

When a test fails, Hypothesis automatically searches for a simpler failing example:

- **Integers**: Binary search towards zero within valid range
- **Strings**: Reduce length and simplify characters

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

## Limitations (MVP)

This is a minimal viable product with the following limitations:

- Only Integer (Int64) and String types supported
- Basic shrinking strategies only
- No database/persistence for test cases
- No stateful testing
- No custom strategy composition

Future versions may add support for additional types (floats, dates, collections), advanced shrinking, and stateful property testing.

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
