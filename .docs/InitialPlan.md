# Plan: Minimale Property-Based Testing Library voor Delphi

## Requirements Samenvatting

Gebaseerd op de verzamelde requirements, wordt het volgende geïmplementeerd:

### Technische Specificaties
- **Target**: Delphi 11 of nieuwer
- **Test Framework**: DUnitX integratie
- **Data Types**: Integers (Int64, Integer) + Strings
- **Shrinking**: Basis shrinking algoritmes
- **Database**: Geen (later toe te voegen)
- **Default Iteraties**: 10 (configureerbaar per test)

### Integer Strategies
1. `IntRange(ParamName, Min, Max)` - Range tussen min en max
2. `IntPositive(ParamName, Max)` - Positieve integers 1..Max
3. `IntNegative(ParamName, Min)` - Negatieve integers Min..-1
4. `IntNonZero(ParamName, Min, Max)` - Range exclusief nul

### String Strategies
1. `StringGen(ParamName, MinLen, MaxLen)` - Willekeurige characters
2. `StringAlpha(ParamName, MinLen, MaxLen)` - Alleen letters (A-Z, a-z)
3. `StringNumeric(ParamName, MinLen, MaxLen)` - Alleen cijfers (0-9)

### Basis Shrinking
- **Integer**: Naar nul toe verkleinen (halveren, binary search)
- **String**: Lengte verkorten (halveren, character deletion)

## Implementatie Plan

### Fase 1: Kern Architectuur (Units 1-3)
1. **Hypothesis.Attributes.pas**
   - `ForAllAttribute` class met Iterations parameter
   - Basis `StrategyAttribute` class
   - Alle integer strategy attributes (4x)
   - Alle string strategy attributes (3x)

2. **Hypothesis.Generators.pas**
   - `IValueGenerator<T>` interface
   - `TIntegerGenerator` class met shrinking
   - `TStringGenerator` class met shrinking
   - Generator registry/factory

3. **Hypothesis.Core.pas**
   - `TPropertyTestRunner` class
   - RTTI-based parameter inspection
   - Test execution loop met shrinking
   - Failure reporting

### Fase 2: DUnitX Integratie (Unit 4)
4. **Hypothesis.DUnitX.pas**
   - Extension voor DUnitX TestFixture
   - Automatische property test discovery
   - Integratie met DUnitX assertions
   - Pretty-printing van failures

### Fase 3: Voorbeelden & Documentatie
5. **Hypothesis.Examples.pas**
   - 5-10 voorbeeld property tests
   - Demo van alle strategy types
   - Best practices voorbeelden

6. **README.md**
   - Installatie instructies
   - Quick start guide
   - API documentatie
   - Voorbeeld gebruik

## Deliverables

### Code Bestanden
```
src/
├── Hypothesis.Attributes.pas      (~200 regels)
├── Hypothesis.Generators.pas      (~300 regels)
├── Hypothesis.Core.pas            (~400 regels)
├── Hypothesis.DUnitX.pas          (~150 regels)
└── Hypothesis.Types.pas           (~50 regels)

examples/
└── Hypothesis.Examples.pas        (~300 regels)

docs/
└── README.md
```

### Geschatte Code Size
- **Totaal**: ~1400 regels productie code
- **Voorbeelden**: ~300 regels
- **Documentatie**: Uitgebreid

## Voorbeeld API Gebruik

```pascal
type
  [TestFixture]
  TMyPropertyTests = class
  public
    [Test]
    [ForAll(10)]  // 10 iteraties (kan aangepast naar 100+ voor CI)
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

## Tijdsinschatting
- **Fase 1 (Kern)**: 2-3 dagen
- **Fase 2 (DUnitX)**: 1 dag
- **Fase 3 (Docs/Examples)**: 1 dag
- **Testing & Refinement**: 1 dag
- **Totaal**: ~5-6 dagen werk

## Toekomstige Uitbreidingen (Niet in MVP)
- Collections (TArray<T>, TList<T>)
- Floats/Doubles
- Booleans
- File-based test database
- Geavanceerd shrinking
- Custom type strategies
- Stateful testing
- Meer string varianten (Unicode, ASCII, etc.)

## Ontwerpbeslissingen

### Waarom Custom Attributes?
- Native Delphi language feature (sinds Delphi 2010)
- Type-safe parameter configuratie
- Declaratieve, leesbare test syntax
- Goede IDE ondersteuning (IntelliSense)
- Flexibel en uitbreidbaar

### Waarom Basis Shrinking?
- Balans tussen complexiteit en waarde
- Makkelijker te implementeren en debuggen
- Voldoende voor meeste use cases
- Kan later uitgebreid worden

### Waarom Geen Database in MVP?
- Focus op kernfunctionaliteit
- Random seed is voldoende voor reproduceerbaarheid
- Database kan later toegevoegd worden zonder API breaking changes
- Vermindert complexiteit en dependencies

## Architectuur Principes

1. **Separation of Concerns**
   - Attributes: Declaratie van strategies
   - Generators: Data generatie logica
   - Core: Test execution engine
   - Integration: Framework-specifieke code

2. **Extensibility**
   - Nieuwe strategies door nieuwe attribute classes
   - Custom generators via interface implementatie
   - Generator registry voor type mapping

3. **Type Safety**
   - Gebruik van Delphi generics waar mogelijk
   - Compile-time checking van attribute parameters
   - RTTI voor runtime type matching

4. **Simplicity**
   - Minimale API surface
   - Duidelijke naming conventions
   - Focus op common use cases
