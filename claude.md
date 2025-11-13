# Hypothesis for Delphi - Project Context

## Project Guidelines

This project uses three key guideline documents located in the `.docs` folder:

1. **Interaction Guidelines** (`.docs/gdk-ai-interaction-guidelines.md`)
   - How to communicate with the developer
   - Question patterns and clarification approach
   - Code delivery workflow
   - Context awareness for UI work

2. **Delphi Coding Style Guide** (`.docs/gdk-delphi-coding-guidelines.md`)
   - Naming conventions and code structure
   - Language-specific rules and patterns
   - Architecture principles
   - Quality standards

3. **Hypothesis4D Coding Guidelines** (`.docs/hypothesis-coding-guidelines.md`)
   - Project-specific naming conventions
   - Architecture and component organization
   - Generator implementation patterns
   - Test structure and patterns
   - Attribute usage and formatting

**Important**: Always follow all three documents when assisting with this codebase. Read them before starting any development work.

## Project Doel

Dit project ontwikkelt een minimale property-based testing library voor Delphi, geïnspireerd door Python's Hypothesis library.

## Initiele Plan

Het volledige initiële plan en de requirements zijn gedocumenteerd in:

**[.docs/InitialPlan.md](.docs/InitialPlan.md)**

## Project Status

- **Fase**: Planning & Design voltooid
- **Volgende stap**: Implementatie starten volgens het plan in InitialPlan.md
- **Todo's**: Zie [.docs/todo.md](.docs/todo.md) voor gedetailleerde volgende stappen

## Quick Reference

### Target
- Delphi 11 of nieuwer
- DUnitX test framework
- Custom attributes voor strategy declaratie

### Scope (MVP)
- **Data Types**: Integers + Strings
- **Integer Strategies**: IntRange, IntPositive, IntNegative, IntNonZero
- **String Strategies**: StringGen, StringAlpha, StringNumeric
- **Features**: Basis shrinking, 10 default iteraties (configureerbaar)
- **Geen Database**: Focus op kernfunctionaliteit

### Voorbeeld Gebruik

```pascal
type
  [TestFixture]
  TMyPropertyTests = class
  public
    [Test]
    [ForAll(10)]
    procedure TestStringReverse(
      [StringAlpha('input', 0, 50)] const AInput: string
    );
  end;
```

## Bronmateriaal

De originele Python Hypothesis library staat in de `Python.Source/` folder en is gebruikt voor analyse en inspiratie.
