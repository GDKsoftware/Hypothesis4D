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

- **Fase**: ✅ MVP Voltooid
- **Implementatie**: Alle core features zijn geïmplementeerd en getest
- **Status**: Zie [.docs/todo.md](.docs/todo.md) voor volledige project status en toekomstige verbeteringen

**Belangrijk**: Bij het voltooien van taken moet [.docs/todo.md](.docs/todo.md) bijgewerkt worden om de actuele project status weer te geven.

## Git Commit Guidelines

Bij het maken van commits:

- **Geen referenties naar AI tools**: Voeg GEEN verwijzingen toe naar Claude Code, Anthropic, of andere AI tools in commit messages
- **Compacte samenvatting**: Een korte, duidelijke samenvatting van de wijziging is voldoende
- **Geen uitgebreide opsommingen**: Het hoeft geen gedetailleerde lijst van alle wijzigingen te zijn
- **Focus op het "waarom"**: Vertel waarom de wijziging is gemaakt, niet alle details van wat er veranderd is

**Voorbeeld goede commit message**:
```
Fix: Correct parameter attribute formatting in test methods

Updated test methods to follow the parameter attributes formatting
guidelines for better consistency.
```

**Voorbeeld slechte commit message**:
```
Fix parameter formatting

Changes:
- Updated line 23 in file X
- Changed spacing in file Y
- Modified alignment in file Z

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Building the Project

### Build Unit Tests

Om de unit tests te builden:

1. Navigeer naar de test directory:
   ```
   cd Delphi.Source\tests
   ```

2. Voer het build script uit:
   ```powershell
   ..\..\\.delphi-build\build-script.ps1
   ```

Het build script:
- Compileert het `Hypothesis4D.UnitTests.dpr` project
- Gebruikt de configuratie uit `.delphi-build\delphi.config.json`

**Let op**: De build configuratie moet eerst lokaal aangemaakt worden door het setup script uit te voeren vanuit de `.delphi-build` directory.

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
    procedure RunTestStringReverse;

    [ForAll(100)]
    procedure TestStringReverse([StringAlpha('Text', 0, 50)] const Text: string);
  end;

implementation

procedure TMyPropertyTests.RunTestStringReverse;
begin
  THypothesis.Run(Self, 'TestStringReverse');
end;
```

## Bronmateriaal

De originele Python Hypothesis library staat in de `Python.Source/` folder en is gebruikt voor analyse en inspiratie.
