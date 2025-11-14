# Plan: Minimal Property-Based Testing Library for Delphi

## Requirements Summary

Based on the gathered requirements, the following will be implemented:

### Technical Specifications
- **Target**: Delphi 11 or newer
- **Test Framework**: DUnitX integration
- **Data Types**: Integers (Int64, Integer) + Strings
- **Shrinking**: Basic shrinking algorithms
- **Database**: None (can be added later)
- **Default Iterations**: 10 (configurable per test)

### Integer Strategies
1. `IntRange(ParamName, Min, Max)` - Range between min and max
2. `IntPositive(ParamName, Max)` - Positive integers 1..Max
3. `IntNegative(ParamName, Min)` - Negative integers Min..-1
4. `IntNonZero(ParamName, Min, Max)` - Range excluding zero

### String Strategies
1. `StringGen(ParamName, MinLen, MaxLen)` - Random characters
2. `StringAlpha(ParamName, MinLen, MaxLen)` - Letters only (A-Z, a-z)
3. `StringNumeric(ParamName, MinLen, MaxLen)` - Digits only (0-9)

### Basic Shrinking
- **Integer**: Shrink towards zero (halving, binary search)
- **String**: Reduce length (halving, character deletion)

## Implementation Plan

### Phase 1: Core Architecture (Units 1-3)
1. **Hypothesis.Attributes.pas**
   - `ForAllAttribute` class with Iterations parameter
   - Base `StrategyAttribute` class
   - All integer strategy attributes (4x)
   - All string strategy attributes (3x)

2. **Hypothesis.Generators.pas**
   - `IValueGenerator<T>` interface
   - `TIntegerGenerator` class with shrinking
   - `TStringGenerator` class with shrinking
   - Generator registry/factory

3. **Hypothesis.Core.pas**
   - `TPropertyTestRunner` class
   - RTTI-based parameter inspection
   - Test execution loop with shrinking
   - Failure reporting

### Phase 2: DUnitX Integration (Unit 4)
4. **Hypothesis.DUnitX.pas**
   - Extension for DUnitX TestFixture
   - Automatic property test discovery
   - Integration with DUnitX assertions
   - Pretty-printing of failures

### Phase 3: Examples & Documentation
5. **Hypothesis.Examples.pas**
   - 5-10 example property tests
   - Demo of all strategy types
   - Best practices examples

6. **README.md**
   - Installation instructions
   - Quick start guide
   - API documentation
   - Example usage

## Deliverables

### Code Files
```
src/
├── Hypothesis.Attributes.pas      (~200 lines)
├── Hypothesis.Generators.pas      (~300 lines)
├── Hypothesis.Core.pas            (~400 lines)
├── Hypothesis.DUnitX.pas          (~150 lines)
└── Hypothesis.Types.pas           (~50 lines)

examples/
└── Hypothesis.Examples.pas        (~300 lines)

docs/
└── README.md
```

### Estimated Code Size
- **Total**: ~1400 lines of production code
- **Examples**: ~300 lines
- **Documentation**: Comprehensive

## Example API Usage

```pascal
type
  [TestFixture]
  TMyPropertyTests = class
  public
    [Test]
    [ForAll(10)]  // 10 iterations (can be adjusted to 100+ for CI)
    procedure TestStringReverse(
      [StringAlpha('input', 0, 50)] const AInput: string
    );

    [Test]
    [ForAll(10)]
    procedure TestAdditionCommutative(
      [IntRange('a', -100, 100)] A: Integer;
      [IntRange('b', -100, 100)] B: Integer
    );

    [Test]
    [ForAll(10)]
    procedure TestDivisionSafe(
      [IntRange('numerator', -1000, 1000)] Num: Integer;
      [IntNonZero('denominator', -1000, 1000)] Den: Integer
    );
  end;
```

## Time Estimate
- **Phase 1 (Core)**: 2-3 days
- **Phase 2 (DUnitX)**: 1 day
- **Phase 3 (Docs/Examples)**: 1 day
- **Testing & Refinement**: 1 day
- **Total**: ~5-6 days work

## Future Extensions (Not in MVP)
- Collections (TArray<T>, TList<T>)
- Floats/Doubles
- Booleans
- File-based test database
- Advanced shrinking
- Custom type strategies
- Stateful testing
- More string variants (Unicode, ASCII, etc.)

## Design Decisions

### Why Custom Attributes?
- Native Delphi language feature (since Delphi 2010)
- Type-safe parameter configuration
- Declarative, readable test syntax
- Good IDE support (IntelliSense)
- Flexible and extensible

### Why Basic Shrinking?
- Balance between complexity and value
- Easier to implement and debug
- Sufficient for most use cases
- Can be extended later

### Why No Database in MVP?
- Focus on core functionality
- Random seed is sufficient for reproducibility
- Database can be added later without API breaking changes
- Reduces complexity and dependencies

## Architecture Principles

1. **Separation of Concerns**
   - Attributes: Declaration of strategies
   - Generators: Data generation logic
   - Core: Test execution engine
   - Integration: Framework-specific code

2. **Extensibility**
   - New strategies through new attribute classes
   - Custom generators via interface implementation
   - Generator registry for type mapping

3. **Type Safety**
   - Use of Delphi generics where possible
   - Compile-time checking of attribute parameters
   - RTTI for runtime type matching

4. **Simplicity**
   - Minimal API surface
   - Clear naming conventions
   - Focus on common use cases