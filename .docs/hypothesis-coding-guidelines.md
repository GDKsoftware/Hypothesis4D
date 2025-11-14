# Hypothesis4D - Project-Specific Coding Guidelines

This document contains coding guidelines specific to the Hypothesis4D property-based testing library.

## Architecture Overview

The library is organized into the following main components:

```
Hypothesis.Attributes       - Strategy attribute declarations
Hypothesis.Generators.*     - Value generators with shrinking
  ├─ Interfaces            - IValueGenerator interface
  ├─ Integers              - Integer value generation
  ├─ Strings               - String value generation
  └─ Factory               - Generator creation from attributes
Hypothesis.Core             - Test runner and shrinking orchestration
Hypothesis.Runner           - Framework integration helper
Hypothesis.Exceptions       - Custom exception types
```

## Naming Conventions

### Generator Classes

Generator classes follow the pattern `T<DataType>Generator`:

```delphi
// ✅ Good
TIntegerGenerator
TStringGenerator
TBooleanGenerator

// ❌ Bad
TIntGenerator
TStrGen
TGeneratorForIntegers
```

### Attribute Classes

Strategy attributes follow the pattern `<DataType><Strategy>Attribute`:

```delphi
// ✅ Good
IntRangeAttribute
IntPositiveAttribute
StringAlphaAttribute

// ❌ Bad
RangeAttribute          // Missing type prefix
IntegerRangeAttribute   // Too verbose
PositiveIntAttribute    // Wrong order
```

### Test Method Naming

Property test methods follow the pattern `Test<PropertyBeingTested>`:

```delphi
// ✅ Good - describes the property being tested
procedure TestAdditionIsCommutative;
procedure TestReversePreservesLength;
procedure TestSortingIsIdempotent;

// ❌ Bad - describes the implementation
procedure TestReverseFunction;
procedure CheckAddition;
procedure ValidateSort;
```

Wrapper methods that call `THypothesis.Run` follow the pattern `RunTest<PropertyName>`:

```delphi
// ✅ Good
[Test]
procedure RunTestAdditionIsCommutative;

// Implementation
procedure RunTestAdditionIsCommutative;
begin
  THypothesis.Run(Self, 'TestAdditionIsCommutative');
end;
```

## Generator Implementation

### Interface Implementation

All generators must implement `IValueGenerator`:

```delphi
type
  TCustomGenerator = class(TInterfacedObject, IValueGenerator)
  public
    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;
```

### Shrinking Strategy

Shrinking must always move towards simpler values:

- **Integers**: Shrink towards zero
- **Strings**: Shrink towards empty string or simpler characters
- **Collections**: Shrink towards empty or fewer elements

```delphi
// ✅ Good - shrinks towards zero
function TIntegerGenerator.Shrink(const Value: TValue): IList<TValue>;
begin
  Candidates := TCollections.CreateList<TValue>;
  IntValue := Value.AsInt64;

  // Try zero first if in range
  if (IntValue <> 0) and (0 >= FMin) and (0 <= FMax) then
    Candidates.Add(TValue.From<Int64>(0));

  // Then try values halfway to zero
  // ...
end;
```

### Generator Factory Pattern

New generators must be registered in `TGeneratorFactory.CreateFromAttribute`:

```delphi
class function TGeneratorFactory.CreateFromAttribute(const Attribute: TCustomAttribute): IValueGenerator;
begin
  if Attribute is CustomAttribute then
  begin
    const Custom = CustomAttribute(Attribute);
    Exit(TCustomGenerator.Create(Custom.Param1, Custom.Param2));
  end;

  // ... other generators ...

  raise Exception.CreateFmt('Unsupported attribute type: %s', [Attribute.ClassName]);
end;
```

## Test Structure

### Property Test Pattern

Property tests follow a two-method pattern:

1. **Wrapper method** with `[Test]` attribute - calls `THypothesis.Run`
2. **Property method** with `[ForAll(N)]` attribute - contains the actual test logic

**Important**: In the class declaration, declare the wrapper and property method **together as a pair**, not separated. This keeps related methods grouped and improves readability.

```delphi
type
  [TestFixture]
  TMyPropertyTests = class
  public
    // First test pair
    [Test]
    procedure RunTestFirstProperty;

    [ForAll(100)]
    procedure TestFirstProperty([Strategy('param', val)] const Param: Type);

    // Second test pair
    [Test]
    procedure RunTestSecondProperty;

    [ForAll(100)]
    procedure TestSecondProperty([Strategy('param', val)] const Param: Type);
  end;

implementation

// Implement pairs in the same order
procedure TMyPropertyTests.RunTestFirstProperty;
begin
  THypothesis.Run(Self, 'TestFirstProperty');
end;

procedure TMyPropertyTests.TestFirstProperty(const Param: Type);
begin
  // First property test implementation
  Assert.IsTrue(FirstPropertyHolds(Param));
end;

procedure TMyPropertyTests.RunTestSecondProperty;
begin
  THypothesis.Run(Self, 'TestSecondProperty');
end;

procedure TMyPropertyTests.TestSecondProperty(const Param: Type);
begin
  // Second property test implementation
  Assert.IsTrue(SecondPropertyHolds(Param));
end;
```

**Bad example** - wrapper and property methods separated:

```delphi
// ❌ Bad - all wrappers first, then all property methods
type
  [TestFixture]
  TMyPropertyTests = class
  public
    [Test]
    procedure RunTestFirstProperty;

    [Test]
    procedure RunTestSecondProperty;

    [ForAll(100)]
    procedure TestFirstProperty([Strategy('param', val)] const Param: Type);

    [ForAll(100)]
    procedure TestSecondProperty([Strategy('param', val)] const Param: Type);
  end;
```

### Test Method Naming Match

The wrapper method name must match the property method name with `Run` prefix:

```delphi
// ✅ Good - names match
procedure RunTestAdditionIsCommutative;
procedure TestAdditionIsCommutative(...);

// ❌ Bad - names don't match
procedure RunTestAddition;
procedure TestAdditionIsCommutative(...);
```

## Error Messages

### Property Failure Messages

Include enough context to reproduce the failure:

```delphi
// ✅ Good - includes values and expected behavior
Assert.AreEqual(Expected, Actual,
  Format('Addition should be commutative: %d + %d = %d + %d', [A, B, B, A]));

// ❌ Bad - not enough context
Assert.AreEqual(Expected, Actual, 'Test failed');
```

### Exception Messages

Framework exceptions should include:
- What went wrong
- The failing values (original and shrunk)
- The iteration number
- The seed for reproducibility

```delphi
ErrorMsg := Format('Property test failed on iteration %d/%d' + sLineBreak +
                   'Original values: %s' + sLineBreak +
                   'Minimal failing example: %s' + sLineBreak +
                   'Seed: %d',
                   [Iteration, Iterations,
                    FormatValueList(OriginalValues),
                    FormatValueList(MinimalValues),
                    Seed]);
```

## Parameter Attributes

### Attribute Formatting

Parameter attributes must stay with their parameters and follow alignment rules:

```delphi
// ✅ Good - single parameter on one line
[ForAll(100)]
procedure TestMethod([IntRange(-1000, 1000)] const Value: Integer);

// ✅ Good - multiple parameters aligned
[ForAll(100)]
procedure TestMethod([IntRange(-1000, 1000)] const A: Integer;
                    [IntRange(-1000, 1000)] const B: Integer);

// ❌ Bad - attribute separated from parameter
[ForAll(100)]
procedure TestMethod(
  [IntRange(-1000, 1000)] const Value: Integer
);
```

## File Organization

### Unit Naming

Units follow the pattern `Hypothesis.<Component>[.<SubComponent>]`:

```delphi
Hypothesis.Core
Hypothesis.Runner
Hypothesis.Attributes
Hypothesis.Exceptions
Hypothesis.Generators.Interfaces
Hypothesis.Generators.Integers
Hypothesis.Generators.Strings
Hypothesis.Generators.Factory
```

### One Generator Per File

Each generator implementation should be in its own file:

```delphi
// ✅ Good - separate files
Hypothesis.Generators.Integers.pas  // TIntegerGenerator
Hypothesis.Generators.Strings.pas   // TStringGenerator
Hypothesis.Generators.Booleans.pas  // TBooleanGenerator

// ❌ Bad - multiple generators in one file
Hypothesis.Generators.pas  // All generators
```

### Interface Separation

The `IValueGenerator` interface is in `Hypothesis.Generators.Interfaces` and must not be duplicated in other units.

## Testing Strategy

### Iteration Count

Default to 100 iterations for property tests:

```delphi
// ✅ Good - standard iteration count
[ForAll(100)]
procedure TestProperty;

// Special cases:
[ForAll(10)]   // Quick smoke test during development
[ForAll(1000)] // Expensive operations or critical properties
```

### Strategy Selection

Choose the most restrictive strategy that tests the property:

```delphi
// ✅ Good - tests with positive integers only
[ForAll(100)]
procedure TestArrayIndex([IntPositive(100)] const Index: Integer);

// ❌ Bad - allows invalid values
[ForAll(100)]
procedure TestArrayIndex([IntRange(-1000, 1000)] const Index: Integer);
```

## Documentation

### Method Comments

The code should be self-documenting. Only add comments when:
- The algorithm is non-obvious (e.g., shrinking strategies)
- There's a specific reason for a choice that's not clear from the code
- External constraints require explanation

```delphi
// ✅ Good - explains non-obvious shrinking strategy
// Shrink by repeatedly halving the distance to zero
// This provides a good balance between shrinking speed and finding minimal examples
Step := Abs(IntValue) div 2;
while Step > 0 do
begin
  // ...
end;

// ❌ Bad - states the obvious
// Loop through the candidates
for Candidate in Candidates do
begin
  // ...
end;
```

## Future Extensions

When adding new generators or strategies:

1. Create new generator in `Hypothesis.Generators.<DataType>.pas`
2. Implement `IValueGenerator` interface
3. Create corresponding attribute in `Hypothesis.Attributes.pas`
4. Register in `TGeneratorFactory.CreateFromAttribute`
5. Add comprehensive tests in `Hypothesis.Core.Tests.pas`
6. Update this document with specific guidelines

## References

- See `.docs/gdk-delphi-coding-guidelines.md` for general Delphi coding standards
- See `.docs/gdk-ai-interaction-guidelines.md` for AI interaction patterns
