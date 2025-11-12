# Hypothesis for Delphi - Todo List

## Current Status

**Phase**: Planning & Design Complete
**Implementation**: Not Started
**Current State**: `Delphi.Source/` folder is empty

All planning documentation is complete and ready for implementation.

---

## Next Steps

### Phase 1: Core Architecture

#### [ ] 1. Project Structure Setup
**Estimate**: 1-2 hours
**Priority**: Critical - Blocker for all other work

**Tasks**:
- [ ] Create `Delphi.Source/src/` folder for core units
- [ ] Create `Delphi.Source/examples/` folder for example code
- [ ] Create `Delphi.Source/docs/` folder for generated documentation
- [ ] Create Delphi project file (.dproj) with DUnitX configuration
- [ ] Add Spring4D dependency to project
- [ ] Verify project compiles without errors/warnings

**Deliverables**:
- Working Delphi project structure
- DUnitX test framework configured
- Spring4D collections available

---

#### [ ] 2. Implement Hypothesis.Attributes.pas
**Estimate**: ~200 lines of code
**Priority**: High - Foundation for entire framework
**Dependencies**: Project structure must be complete

**Components to Implement**:
- [ ] `TStrategyAttribute` base class (inherits from `TCustomAttribute`)
  - Property: `ParamName: string` (parameter name to bind to)
- [ ] `ForAllAttribute` class
  - Property: `Iterations: Integer` (default 10)
- [ ] Integer strategy attributes:
  - [ ] `IntRangeAttribute(ParamName, Min, Max)`
  - [ ] `IntPositiveAttribute(ParamName, Max)`
  - [ ] `IntNegativeAttribute(ParamName, Min)`
  - [ ] `IntNonZeroAttribute(ParamName, Min, Max)`
- [ ] String strategy attributes:
  - [ ] `StringGenAttribute(ParamName, MinLen, MaxLen)`
  - [ ] `StringAlphaAttribute(ParamName, MinLen, MaxLen)`
  - [ ] `StringNumericAttribute(ParamName, MinLen, MaxLen)`

**Coding Standards**:
- Follow `.docs/gdk-delphi-coding-guidelines.md`
- Target Delphi 12.3
- No global functions
- Self-documenting code (no comments)
- Must compile without hints/warnings

**Deliverables**:
- `Delphi.Source/src/Hypothesis.Attributes.pas`
- All 7 strategy attributes implemented
- Unit tests for attribute instantiation

---

#### [ ] 3. Implement Hypothesis.Generators.pas
**Estimate**: ~300 lines of code
**Priority**: High - Core generation logic
**Dependencies**: Hypothesis.Attributes.pas must be complete

**Components to Implement**:
- [ ] `IValueGenerator<T>` interface
  - Method: `Generate: T` (produces random value)
  - Method: `Shrink(AValue: T): IList<T>` (returns shrinking candidates)
- [ ] `TIntegerGenerator<T: Integer>` class
  - Integer generation within range constraints
  - Shrinking via binary search towards zero
  - Support for Int64 and Integer types
- [ ] `TStringGenerator` class
  - String generation with character set constraints (Any, Alpha, Numeric)
  - Length-based shrinking (reduce length, simplify characters)
- [ ] Generator factory/registry
  - Maps strategy attributes to generator instances
  - Type-safe generator instantiation

**Shrinking Logic**:
- Integers: Binary search towards zero within valid range
- Strings: Remove characters from ends, simplify to simpler chars

**Deliverables**:
- `Delphi.Source/src/Hypothesis.Generators.pas`
- Working generators for all integer and string strategies
- Unit tests for generation and shrinking

---

#### [ ] 4. Implement Hypothesis.Core.pas
**Estimate**: ~400 lines of code
**Priority**: High - Test execution engine
**Dependencies**: Hypothesis.Attributes.pas and Hypothesis.Generators.pas must be complete

**Components to Implement**:
- [ ] `TPropertyTestRunner` class
  - RTTI-based test method inspection
  - Attribute extraction from method parameters
  - Generator instantiation from attributes
- [ ] Test execution loop
  - Iterate N times (from ForAllAttribute)
  - Generate parameter values for each iteration
  - Invoke test method with generated values
  - Catch and report failures
- [ ] Shrinking orchestration
  - On test failure, shrink each parameter
  - Re-run test with shrunk values
  - Find minimal failing example
  - Report original and shrunk values
- [ ] Failure reporting
  - Clear error messages with generated values
  - Show shrinking progression
  - Include seed for reproducibility

**Key Features**:
- Random seed tracking for reproducibility
- Configurable iteration count per test
- Exception handling and reporting
- Integration point for DUnitX

**Deliverables**:
- `Delphi.Source/src/Hypothesis.Core.pas`
- Complete test execution engine
- Unit tests for runner logic

---

### Phase 2: DUnitX Integration

#### [ ] 5. Implement Hypothesis.DUnitX.pas
**Estimate**: ~150 lines of code
**Priority**: Medium - Framework integration
**Dependencies**: All Phase 1 components must be complete

**Components to Implement**:
- [ ] DUnitX TestFixture extension
  - Detect `ForAllAttribute` on test methods
  - Automatic property test discovery
- [ ] Test method wrapper
  - Intercept ForAll-decorated test execution
  - Delegate to `TPropertyTestRunner`
  - Handle assertions and failures
- [ ] DUnitX assertion integration
  - Map Hypothesis failures to DUnitX test failures
  - Preserve stack traces
- [ ] Pretty-printed output
  - Show generated values in failure messages
  - Display shrinking results
  - Format for DUnitX test runner output

**Usage Pattern**:
```pascal
type
  [TestFixture]
  TMyTests = class
  public
    [Test]
    [ForAll(100)]
    procedure TestProperty(
      [IntRange('x', 1, 100)] x: Integer;
      [StringAlpha('s', 0, 50)] const s: string
    );
  end;
```

**Deliverables**:
- `Delphi.Source/src/Hypothesis.DUnitX.pas`
- Seamless DUnitX integration
- Example test project demonstrating usage

---

## Phase 3: Documentation & Examples

#### [ ] 6. Implement Hypothesis.Examples.pas
**Estimate**: ~300 lines of code
**Priority**: Low - Can be done after Phase 2

**Example Tests to Include**:
- [ ] Integer property: Reverse of reverse is identity
- [ ] Integer property: Addition is commutative
- [ ] String property: Length of concatenation
- [ ] String property: Reverse of reverse is identity
- [ ] Combined: String/Integer properties
- [ ] Edge cases: Empty strings, zero, negative numbers
- [ ] Shrinking demonstration: Intentional failures

**Deliverables**:
- `Delphi.Source/examples/Hypothesis.Examples.pas`
- 5-10 working example tests
- Demonstration of all strategy types

---

#### [ ] 7. Write README.md
**Estimate**: 2-3 hours
**Priority**: Medium - Important for adoption

**Sections**:
- [ ] Installation instructions
- [ ] Quick start guide with code example
- [ ] API documentation for all attributes
- [ ] Usage examples for each strategy type
- [ ] Best practices and tips
- [ ] Comparison with other testing approaches
- [ ] Roadmap and future enhancements

**Deliverables**:
- `Delphi.Source/README.md`
- Clear, comprehensive documentation

---

## References

- **Full Implementation Plan**: [InitialPlan.md](InitialPlan.md) (6 pages, detailed specifications)
- **Coding Standards**: [gdk-delphi-coding-guidelines.md](gdk-delphi-coding-guidelines.md)
- **Communication Guidelines**: [gdk-ai-interaction-guidelines.md](gdk-ai-interaction-guidelines.md)

---

## MVP Scope Reminder

**Data Types**: Integers (Int64, Integer) and Strings only
**Default Iterations**: 10 (configurable via ForAllAttribute)
**Shrinking**: Basic (integers: binary search; strings: length reduction)
**Target**: Delphi 12.3 with Spring4D collections
**Framework**: DUnitX test framework

**Out of Scope for MVP**:
- Database/persistence for test cases
- Advanced shrinking strategies
- Additional data types (floats, dates, collections, etc.)
- Stateful testing
- Custom strategy composition

---

## Estimated Timeline

- **Phase 1** (Items 1-4): 3-4 days
- **Phase 2** (Item 5): 1 day
- **Phase 3** (Items 6-7): 1-2 days

**Total**: 5-6 days of focused development
