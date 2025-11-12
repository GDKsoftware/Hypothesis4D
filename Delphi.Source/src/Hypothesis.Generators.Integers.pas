unit Hypothesis.Generators.Integers;

interface

uses
  System.SysUtils,
  System.Rtti,
  Spring.Collections,
  Hypothesis.Generators.Interfaces;

type
  TIntegerGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMin: Int64;
    FMax: Int64;
    FExcludeZero: Boolean;

  public
    constructor Create(const Min: Int64; const Max: Int64; const ExcludeZero: Boolean = False);

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

implementation

constructor TIntegerGenerator.Create(const Min: Int64; const Max: Int64; const ExcludeZero: Boolean);
begin
  inherited Create;
  FMin := Min;
  FMax := Max;
  FExcludeZero := ExcludeZero;
end;

function TIntegerGenerator.GenerateValue: TValue;
var
  Generated: Int64;
  Range: Int64;
  RandValue: Double;
begin
  Range := FMax - FMin + 1;

  repeat
    if Range <= High(Integer) then
      Generated := FMin + Random(Integer(Range))
    else
    begin
      RandValue := Random;
      Generated := FMin + Trunc(RandValue * Range);
    end;
  until (not FExcludeZero) or (Generated <> 0);

  Result := TValue.From<Int64>(Generated);
end;

function TIntegerGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  IntValue: Int64;
  Candidates: IList<TValue>;
  Step: Int64;
  Candidate: Int64;
begin
  Candidates := TCollections.CreateList<TValue>;
  IntValue := Value.AsInt64;

  if IntValue = 0 then
    Exit(Candidates);

  if (IntValue >= FMin) and (IntValue <= FMax) then
  begin
    if (IntValue > 0) and (FMin <= 0) and (not FExcludeZero) then
      Candidates.Add(TValue.From<Int64>(0));

    if (IntValue < 0) and (FMax >= 0) and (not FExcludeZero) then
      Candidates.Add(TValue.From<Int64>(0));

    Step := Abs(IntValue) div 2;
    while Step > 0 do
    begin
      if IntValue > 0 then
      begin
        Candidate := IntValue - Step;
        if (Candidate >= FMin) and (Candidate <> IntValue) then
        begin
          if (not FExcludeZero) or (Candidate <> 0) then
            Candidates.Add(TValue.From<Int64>(Candidate));
        end;
      end
      else
      begin
        Candidate := IntValue + Step;
        if (Candidate <= FMax) and (Candidate <> IntValue) then
        begin
          if (not FExcludeZero) or (Candidate <> 0) then
            Candidates.Add(TValue.From<Int64>(Candidate));
        end;
      end;

      Step := Step div 2;
    end;
  end;

  Result := Candidates;
end;

end.
