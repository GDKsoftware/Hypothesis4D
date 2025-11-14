unit Hypothesis.Generators.Factory;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.DateUtils,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.Integers,
  Hypothesis.Generators.Strings,
  Hypothesis.Generators.Booleans,
  Hypothesis.Generators.Floats,
  Hypothesis.Generators.DateTimes,
  Hypothesis.Generators.Collections;

type
  TGeneratorFactory = class
  public
    class function CreateFromAttribute(const Attribute: TCustomAttribute): IValueGenerator;
  end;

implementation

uses
  Hypothesis.Attributes;

class function TGeneratorFactory.CreateFromAttribute(const Attribute: TCustomAttribute): IValueGenerator;
begin
  if Attribute is IntRangeAttribute then
  begin
    const IntRange = IntRangeAttribute(Attribute);
    Exit(TIntegerGenerator.Create(IntRange.Min, IntRange.Max, False));
  end;

  if Attribute is IntPositiveAttribute then
  begin
    const IntPositive = IntPositiveAttribute(Attribute);
    Exit(TIntegerGenerator.Create(1, IntPositive.Max, False));
  end;

  if Attribute is IntNegativeAttribute then
  begin
    const IntNegative = IntNegativeAttribute(Attribute);
    Exit(TIntegerGenerator.Create(IntNegative.Min, -1, False));
  end;

  if Attribute is IntNonZeroAttribute then
  begin
    const IntNonZero = IntNonZeroAttribute(Attribute);
    Exit(TIntegerGenerator.Create(IntNonZero.Min, IntNonZero.Max, True));
  end;

  if Attribute is StringGenAttribute then
  begin
    const StrGen = StringGenAttribute(Attribute);
    Exit(TStringGenerator.Create(StrGen.MinLen, StrGen.MaxLen, TStringCharSet.Any));
  end;

  if Attribute is StringAlphaAttribute then
  begin
    const StrAlpha = StringAlphaAttribute(Attribute);
    Exit(TStringGenerator.Create(StrAlpha.MinLen, StrAlpha.MaxLen, TStringCharSet.Alpha));
  end;

  if Attribute is StringNumericAttribute then
  begin
    const StrNumeric = StringNumericAttribute(Attribute);
    Exit(TStringGenerator.Create(StrNumeric.MinLen, StrNumeric.MaxLen, TStringCharSet.Numeric));
  end;

  if Attribute is StringAsciiAttribute then
  begin
    const StrAscii = StringAsciiAttribute(Attribute);
    Exit(TStringGenerator.Create(StrAscii.MinLen, StrAscii.MaxLen, TStringCharSet.Ascii));
  end;

  if Attribute is StringUnicodeAttribute then
  begin
    const StrUnicode = StringUnicodeAttribute(Attribute);
    Exit(TStringGenerator.Create(StrUnicode.MinLen, StrUnicode.MaxLen, TStringCharSet.Unicode));
  end;

  if Attribute is StringEmailAttribute then
    Exit(TStringGenerator.Create(0, 0, TStringCharSet.Email));

  if Attribute is StringUrlAttribute then
  begin
    const StrUrl = StringUrlAttribute(Attribute);
    Exit(TStringGenerator.Create(StrUrl.IncludeProtocol));
  end;

  if Attribute is StringRegexAttribute then
  begin
    const StrRegex = StringRegexAttribute(Attribute);
    Exit(TStringGenerator.Create(StrRegex.Pattern));
  end;

  if Attribute is BooleanAttribute then
    Exit(TBooleanGenerator.Create);

  if Attribute is FloatRangeAttribute then
  begin
    const FloatRange = FloatRangeAttribute(Attribute);
    Exit(TFloatGenerator.Create(FloatRange.Min, FloatRange.Max,
                                  FloatRange.AllowNaN, FloatRange.AllowInfinity));
  end;

  if Attribute is FloatPositiveAttribute then
  begin
    const FloatPos = FloatPositiveAttribute(Attribute);
    Exit(TFloatGenerator.Create(1e-10, FloatPos.Max, False, False));
  end;

  if Attribute is FloatNegativeAttribute then
  begin
    const FloatNeg = FloatNegativeAttribute(Attribute);
    Exit(TFloatGenerator.Create(FloatNeg.Min, -1e-10, False, False));
  end;

  if Attribute is FloatUnitAttribute then
    Exit(TFloatGenerator.Create(0.0, 1.0, False, False));

  if Attribute is DateRangeAttribute then
  begin
    const DateRange = DateRangeAttribute(Attribute);
    Exit(TDateTimeGenerator.Create(DateRange.MinYear, DateRange.MaxYear, False));
  end;

  if Attribute is DateTimeRangeAttribute then
  begin
    const DateTimeRange = DateTimeRangeAttribute(Attribute);
    Exit(TDateTimeGenerator.Create(DateTimeRange.MinYear, DateTimeRange.MaxYear, True));
  end;

  if Attribute is DateRecentAttribute then
  begin
    const DateRecent = DateRecentAttribute(Attribute);
    const MinDate = Date - DateRecent.Days;
    const MaxDate = Date;
    var MinYear, MaxYear, Dummy: Word;
    DecodeDate(MinDate, MinYear, Dummy, Dummy);
    DecodeDate(MaxDate, MaxYear, Dummy, Dummy);
    Exit(TDateTimeGenerator.Create(MinYear, MaxYear, False));
  end;

  if Attribute is TimeRangeAttribute then
    Exit(TTimeGenerator.Create);

  // Collection strategies require nested generators and are not yet fully supported
  // through the attribute-based factory approach. For now, these would need to be
  // created manually with explicit generator instances.
  if Attribute is ArrayGenAttribute then
    raise Exception.Create('ArrayGenAttribute requires manual generator creation with nested element generators');

  if Attribute is ListGenAttribute then
    raise Exception.Create('ListGenAttribute requires manual generator creation with nested element generators');

  if Attribute is DictionaryGenAttribute then
    raise Exception.Create('DictionaryGenAttribute requires manual generator creation with nested key/value generators');

  raise Exception.CreateFmt('Unsupported attribute type: %s', [Attribute.ClassName]);
end;

end.
