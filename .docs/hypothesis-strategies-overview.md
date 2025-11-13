# Python Hypothesis Library - Strategieën Overzicht

Dit document bevat een volledige inventarisatie van alle strategieën die beschikbaar zijn in de Python Hypothesis library. Dit dient als referentiemateriaal voor toekomstige uitbreidingen van de Delphi implementatie.

## 1. BASIS/PRIMITIEVE STRATEGIEËN

### Boolean
- `booleans()` - Genereert True/False waarden

### None/Nothing
- `none()` - Genereert altijd None
- `nothing()` - Genereert nooit waarden (altijd reject)
- `just(value)` - Retourneert altijd één vaste waarde

### Sampling
- `sampled_from(elements)` - Samples uit een sequence of enum

## 2. NUMERIEKE STRATEGIEËN

### Integers
- `integers(min_value=None, max_value=None)` - Genereert integers binnen grenzen
  - Shrinkt richting nul
  - Negatieve waarden shrinken richting positief

### Floating Point
- `floats(min_value=None, max_value=None, allow_nan=None, allow_infinity=None, allow_subnormal=None, width=64, exclude_min=False, exclude_max=False)` - Genereert floats
  - Ondersteunt 16, 32, en 64-bit precisie
  - Controle over NaN, infinity, subnormals
  - Open/gesloten interval support

### Complexe Getallen
- `complex_numbers(min_magnitude=0, max_magnitude=None, allow_infinity=None, allow_nan=None)` - Genereert complexe getallen

### Rationale Getallen
- `fractions(min_value=None, max_value=None, max_denominator=None)` - Genereert fractions.Fraction objecten
- `decimals(min_value=None, max_value=None, allow_nan=None, allow_infinity=None, places=None)` - Genereert decimal.Decimal objecten

## 3. TEKST/STRING STRATEGIEËN

### Characters
- `characters(codec=None, min_codepoint=None, max_codepoint=None, categories=None, exclude_characters='', include_characters='')` - Genereert enkele karakters
  - Unicode categorie filtering
  - Codec filtering
  - Karakter inclusie/exclusie

### Text/Strings
- `text(alphabet=characters(), min_size=0, max_size=None)` - Genereert strings
  - Aanpasbaar alfabet
  - Lengte controle
  - Speciale filter optimalisaties (bijv. str.isidentifier)

### Binary
- `binary(min_size=0, max_size=None)` - Genereert bytes objecten

### Regular Expressions
- `from_regex(regex, fullmatch=False, alphabet=None)` - Genereert strings die matchen met regex pattern
  - Ondersteunt meeste regex features
  - Optioneel custom alfabet

## 4. COLLECTIE STRATEGIEËN

### Lists
- `lists(elements, min_size=0, max_size=None, unique=False, unique_by=None)` - Genereert lijsten
  - Element strategie aanpassing
  - Grootte constraints
  - Uniciteit constraints

### Sets
- `sets(elements, min_size=0, max_size=None)` - Genereert sets

### Frozensets
- `frozensets(elements, min_size=0, max_size=None)` - Genereert frozensets

### Tuples
- `tuples(*args)` - Genereert fixed-length tuples met heterogene elementen
  - Elke positie heeft eigen strategie

### Dictionaries
- `dictionaries(keys, values, min_size=0, max_size=None)` - Genereert dictionaries
- `fixed_dictionaries(mapping, optional=None)` - Genereert dicts met vaste keys
  - Verplichte en optionele keys

### Iterables
- `iterables(elements, min_size=0, max_size=None, unique=False, unique_by=None)` - Genereert iterables (niet lists)

## 5. DATETIME STRATEGIEËN

### Dates
- `dates(min_value=datetime.date.min, max_value=datetime.date.max)` - Genereert dates
  - Shrinkt richting 1 januari 2000

### Times
- `times(min_value=datetime.time.min, max_value=datetime.time.max, timezones=none())` - Genereert times
  - Optionele timezone support

### Datetimes
- `datetimes(min_value=datetime.datetime.min, max_value=datetime.datetime.max, timezones=none(), allow_imaginary=True)` - Genereert datetimes
  - Timezone-aware of naive
  - Controle voor DST edge cases
  - Shrinkt richting middernacht 1 jan 2000

### Timedeltas
- `timedeltas(min_value=datetime.timedelta.min, max_value=datetime.timedelta.max)` - Genereert timedeltas
  - Shrinkt richting nul

### Timezones
- `timezones(no_cache=False)` - Genereert zoneinfo.ZoneInfo objecten
- `timezone_keys(allow_prefix=True)` - Genereert IANA timezone naam strings

## 6. NETWERK/INTERNET STRATEGIEËN

### IP Addresses
- `ip_addresses(v=None, network=None)` - Genereert IPv4 of IPv6 adressen
  - Versie selectie (4, 6, of beide)
  - Netwerk/subnet filtering
  - Speciale adres ranges

### Domains & URLs
- `domains(max_length=255, max_element_length=63)` - Genereert RFC-1035 domain namen (provisional)
- `emails(domains=domains())` - Genereert email adressen
- `urls()` - Genereert HTTP/HTTPS URLs (provisional)

## 7. COMPOSITE/BUILDER STRATEGIEËN

### Builds
- `builds(target, *args, **kwargs)` - Bouwt objecten door een callable aan te roepen
  - Strategieën voor elk argument
  - Handig voor object constructie

### Composite
- `@composite` decorator - Creëert custom strategieën met draw functie
  - Volledige controle over generatie logica
  - Kan meerdere strategieën combineren

### Recursive
- `recursive(base, extend, max_leaves=100)` - Genereert recursieve structuren
  - Trees, geneste data structuren
  - Diepte controle

### One Of
- `one_of(*strategies)` - Kiest uit meerdere strategieën

### Deferred
- `deferred(definition)` - Lazy strategie definitie
  - Handig voor recursieve/circulaire referenties

## 8. SPECIAL-PURPOSE STRATEGIEËN

### Data Drawing
- `data()` - Retourneert een DataObject voor interactief drawing
- `runner(default=not_set)` - Genereert waarden vanuit een test

### Random
- `randoms(use_true_random=False)` - Genereert Random instances
- `random_module()` - Genereert seeder voor random module

### UUIDs
- `uuids(version=None)` - Genereert UUID objecten

### Slices
- `slices(size)` - Genereert slice objecten voor indexing

### Permutations
- `permutations(values)` - Genereert permutaties van een sequence

### Functions
- `functions(like=lambda: None, returns=..., pure=False)` - Genereert callable functions

### Shared
- `shared(base, key=None)` - Deelt gegenereerde waarden over test runs

## 9. TYPE-BASED STRATEGIEËN

### From Type
- `from_type(type)` - Leidt strategie af van type annotations
  - Ondersteunt typing module types
  - Custom type registraties via `register_type_strategy()`

## 10. EXTRA MODULES (Extensies)

### NumPy (`hypothesis.extra.numpy`)
- `from_dtype(dtype, ...)` - Genereert waarden van gegeven dtype
- `arrays(dtype, shape, elements=None, fill=None, unique=False)` - Genereert numpy arrays
- `array_shapes(min_dims=0, max_dims=None, min_side=0, max_side=None)` - Genereert array shapes
- `scalar_dtypes()` - Alle scalar dtypes
- `boolean_dtypes()` - Boolean dtypes
- `integer_dtypes(endianness='?', sizes=(8,16,32,64))` - Integer dtypes
- `unsigned_integer_dtypes(...)` - Unsigned integer dtypes
- `floating_dtypes(endianness='?', sizes=(16,32,64))` - Float dtypes
- `complex_number_dtypes(...)` - Complex dtypes
- `datetime64_dtypes(...)` - Datetime64 dtypes
- `timedelta64_dtypes(...)` - Timedelta64 dtypes
- `byte_string_dtypes(...)` - Byte string dtypes
- `unicode_string_dtypes(...)` - Unicode string dtypes
- `nested_dtypes(...)` - Structured/nested dtypes
- `broadcastable_shapes(...)` - Shapes die samen broadcasten
- `mutually_broadcastable_shapes(...)` - Meerdere broadcastable shapes
- `basic_indices(shape, ...)` - Array indexing strategieën
- `integer_array_indices(shape, ...)` - Integer array indices
- `valid_tuple_axes(...)` - Geldige axis tuples

### Pandas (`hypothesis.extra.pandas`)
- `data_frames(columns=None, rows=None, index=None)` - Genereert DataFrames
- `series(elements=None, dtype=None, index=None, fill=None, unique=False)` - Genereert Series
- `indexes(elements=None, dtype=None, min_size=0, max_size=None, unique=True)` - Genereert Index objecten
- `range_indexes(min_size=0, max_size=None)` - Genereert RangeIndex objecten
- `columns(...)` - Genereert column specificaties

### Django (`hypothesis.extra.django`)
- `from_field(field)` - Genereert waarden voor Django model fields
- `from_model(model, ...)` - Genereert model instances
- `register_field_strategy(field_type, strategy)` - Custom field strategieën

### Dateutil (`hypothesis.extra.dateutil`)
- `timezones()` - Genereert dateutil timezone objecten

### PyTZ (`hypothesis.extra.pytz`)
- `timezones()` - Genereert pytz timezone objecten

### Lark (`hypothesis.extra.lark`)
- `from_lark(grammar, ...)` - Genereert strings die matchen met Lark grammar

### Array API (`hypothesis.extra.array_api`)
- Vergelijkbaar met numpy maar voor Array API standaard implementaties

## 11. STRATEGIE COMBINATORS/MODIFIERS

Alle strategieën ondersteunen deze methods:
- `.map(func)` - Transformeer gegenereerde waarden
- `.filter(condition)` - Filter gegenereerde waarden
- `.flatmap(expand)` - Chain afhankelijke strategieën
- `.example()` - Genereer één enkel voorbeeld

## PATRONEN & IMPLEMENTATIE DETAILS

### Shrinking Gedrag

**Algemene Principes:**
- Integers/floats shrinken naar nul
- Collections shrinken naar kleinere groottes en eenvoudigere elementen
- Strings shrinken naar lege string
- Datetimes shrinken naar 1 januari 2000 middernacht

### Strategy Classes (Intern)

Python Hypothesis gebruikt 30+ gespecialiseerde strategy classes, waaronder:
- `IntegersStrategy`, `FloatStrategy`, `NanStrategy`
- `TextStrategy`, `BytesStrategy`, `OneCharStringStrategy`
- `ListStrategy`, `UniqueListStrategy`, `TupleStrategy`, `FixedDictStrategy`
- `DateStrategy`, `TimeStrategy`, `DatetimeStrategy`, `TimedeltaStrategy`
- `SampledFromStrategy`, `OneOfStrategy`, `MappedStrategy`, `FilteredStrategy`
- `BuildsStrategy`, `CompositeStrategy`, `RecursiveStrategy`
- En vele meer gespecialiseerde implementaties

### Key Design Patterns

1. **Declaratieve Strategie Compositie**
   - Strategieën kunnen gedeclareerd worden zonder onmiddellijke evaluatie
   - Compositie via `.map()`, `.filter()`, `.flatmap()`

2. **Lazy Evaluatie met Deferred Strategieën**
   - Ondersteunt circulaire en recursieve referenties
   - `deferred()` functie voor uitgestelde definitie

3. **Caching voor Performance**
   - `@cacheable` decorator voor hergebruik
   - Vermijdt onnodige regeneratie

4. **Slimme Filtering met Predicate Analyse**
   - Optimalisaties voor veelvoorkomende predicates
   - Speciale behandeling voor string filters (bijv. `str.isidentifier`)

5. **Efficiënt Shrinking door Interne Representatie**
   - Gebruik van interne buffer representaties
   - Systematische reductie van complexiteit

6. **Type-Based Inference Systeem**
   - `from_type()` analyseert type annotations
   - Automatische strategie selectie
   - Uitbreidbaar via `register_type_strategy()`

## IMPLICATIES VOOR DELPHI IMPLEMENTATIE

### Huidige Status (MVP)
De Delphi implementatie ondersteunt momenteel:
- **Integer Strategieën:** IntRange, IntPositive, IntNegative, IntNonZero
- **String Strategieën:** StringGen, StringAlpha, StringNumeric
- Basis shrinking voor beide types
- DUnitX integratie

### Mogelijke Toekomstige Uitbreidingen

**Prioriteit Hoog (Veel Gebruikt):**
- Boolean strategieën
- Float/Double strategieën (met NaN/Infinity support)
- List/Array strategieën
- Date/Time/DateTime strategieën
- Sampled_from (enums en sets)

**Prioriteit Gemiddeld:**
- Set strategieën
- Dictionary/Map strategieën
- Tuple/Record strategieën
- Character strategieën met Unicode support

**Prioriteit Laag (Gespecialiseerd):**
- Regex-based string generatie
- Recursive strategieën voor boom structuren
- Composite strategieën met custom logic
- Network types (IP addresses, URLs)

**Framework Extensies:**
- FireDAC dataset strategieën
- VCL/FMX component strategieën
- JSON/XML document strategieën

### Architectuur Overwegingen

Bij uitbreiding van de Delphi implementatie:

1. **Generics Support**: Gebruik Delphi generics voor type-safe strategieën
2. **RTTI Integration**: Uitbreiding van automatische type detectie
3. **Attribute System**: Volg huidige attribuut-based approach
4. **Shrinking Algorithm**: Implementeer systematische shrinking zoals Python
5. **Performance**: Overweeg caching en lazy evaluatie patronen

## REFERENTIES

- Python Hypothesis Library: https://hypothesis.readthedocs.io/
- Source Code: `Python.Source/` folder in dit project
- Delphi Implementatie: Zie [InitialPlan.md](.docs/InitialPlan.md)
- Coding Guidelines: Zie [hypothesis-coding-guidelines.md](.docs/hypothesis-coding-guidelines.md)
