unit Hypothesis.Generators.Booleans;

interface

uses
  System.Rtti,
  Spring.Collections,
  Hypothesis.Generators.Interfaces;

type
  /// <summary>
  /// Generator for boolean values (True/False).
  /// </summary>
  /// <remarks>
  /// Generates random boolean values with equal probability.
  /// Shrinking behavior: True shrinks to False (False is the minimal value).
  /// </remarks>
  TBooleanGenerator = class(TInterfacedObject, IValueGenerator)
  public
    /// <summary>
    /// Generates a random boolean value.
    /// </summary>
    function GenerateValue: TValue;

    /// <summary>
    /// Returns shrink candidates for the given boolean value.
    /// True shrinks to False. False is already minimal and returns no candidates.
    /// </summary>
    function Shrink(const Value: TValue): IList<TValue>;
  end;

implementation

{ TBooleanGenerator }

function TBooleanGenerator.GenerateValue: TValue;
begin
  Result := TValue.From<Boolean>(Random(2) = 0);
end;

function TBooleanGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  BoolValue: Boolean;
begin
  Result := TCollections.CreateList<TValue>;
  BoolValue := Value.AsBoolean;

  // True shrinks to False
  // False is already the minimal value, no further shrinking
  if BoolValue then
    Result.Add(TValue.From<Boolean>(False));
end;

end.
