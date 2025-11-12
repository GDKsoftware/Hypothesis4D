unit Hypothesis.Generators.Strings;

interface

uses
  System.SysUtils,
  System.Rtti,
  Spring.Collections,
  Hypothesis.Generators.Interfaces;

type
  TStringCharSet = (Any, Alpha, Numeric);

  TStringGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMinLen: Integer;
    FMaxLen: Integer;
    FCharSet: TStringCharSet;

    function GenerateChar: Char;
    function SimplifyChar(const Ch: Char): Char;

  public
    constructor Create(const MinLen: Integer; const MaxLen: Integer; const CharSet: TStringCharSet);

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

implementation

constructor TStringGenerator.Create(const MinLen: Integer; const MaxLen: Integer; const CharSet: TStringCharSet);
begin
  inherited Create;
  FMinLen := MinLen;
  FMaxLen := MaxLen;
  FCharSet := CharSet;
end;

function TStringGenerator.GenerateChar: Char;
begin
  case FCharSet of
    TStringCharSet.Alpha:
      begin
        if Random(2) = 0 then
          Result := Chr(Ord('A') + Random(26))
        else
          Result := Chr(Ord('a') + Random(26));
      end;

    TStringCharSet.Numeric:
      Result := Chr(Ord('0') + Random(10));

    TStringCharSet.Any:
      Result := Chr(32 + Random(95));
  else
    Result := ' ';
  end;
end;

function TStringGenerator.SimplifyChar(const Ch: Char): Char;
begin
  case FCharSet of
    TStringCharSet.Alpha:
      begin
        if (Ch >= 'a') and (Ch <= 'z') then
          Result := 'a'
        else if (Ch >= 'A') and (Ch <= 'Z') then
          Result := 'A'
        else
          Result := Ch;
      end;

    TStringCharSet.Numeric:
      Result := '0';

    TStringCharSet.Any:
      Result := ' ';
  else
    Result := Ch;
  end;
end;

function TStringGenerator.GenerateValue: TValue;
var
  Len: Integer;
  Builder: TStringBuilder;
  I: Integer;
begin
  Len := FMinLen + Random(FMaxLen - FMinLen + 1);
  Builder := TStringBuilder.Create(Len);
  try
    for I := 1 to Len do
      Builder.Append(GenerateChar);

    Result := TValue.From<string>(Builder.ToString);
  finally
    Builder.Free;
  end;
end;

function TStringGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  StrValue: string;
  Candidates: IList<TValue>;
  NewLen: Integer;
  HalfLen: Integer;
  I: Integer;
  Simplified: string;
begin
  Candidates := TCollections.CreateList<TValue>;
  StrValue := Value.AsString;

  if StrValue.Length <= FMinLen then
    Exit(Candidates);

  if StrValue.Length > FMinLen then
  begin
    Candidates.Add(TValue.From<string>(StrValue.Substring(0, FMinLen)));
  end;

  HalfLen := (StrValue.Length + FMinLen) div 2;
  if (HalfLen > FMinLen) and (HalfLen < StrValue.Length) then
  begin
    Candidates.Add(TValue.From<string>(StrValue.Substring(0, HalfLen)));
  end;

  NewLen := StrValue.Length - 1;
  if NewLen >= FMinLen then
  begin
    Candidates.Add(TValue.From<string>(StrValue.Substring(0, NewLen)));
  end;

  if StrValue.Length > 0 then
  begin
    Simplified := StrValue;
    for I := 1 to Simplified.Length do
    begin
      if Simplified[I] <> SimplifyChar(Simplified[I]) then
      begin
        Simplified[I] := SimplifyChar(Simplified[I]);
        Candidates.Add(TValue.From<string>(Simplified));
        Break;
      end;
    end;
  end;

  Result := Candidates;
end;

end.
