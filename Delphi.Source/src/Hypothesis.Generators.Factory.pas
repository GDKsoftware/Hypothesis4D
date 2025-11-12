unit Hypothesis.Generators.Factory;

interface

uses
  System.SysUtils,
  System.Rtti,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.Integers,
  Hypothesis.Generators.Strings;

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

  raise Exception.CreateFmt('Unsupported attribute type: %s', [Attribute.ClassName]);
end;

end.
