unit Hypothesis.Generators.Interfaces;

interface

uses
  System.Rtti,
  Spring.Collections;

type
  IValueGenerator = interface
    ['{8A3C5E7F-9B2D-4E6A-8C1F-3D5B7E9A2C4F}']

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

implementation

end.
