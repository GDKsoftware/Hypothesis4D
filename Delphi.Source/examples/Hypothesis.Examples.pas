unit Hypothesis.Examples;

interface

type
  TStringUtils = class
  public
    class function Reverse(const Text: string): string;
  end;

  TMathUtils = class
  public
    class function IsEven(const Value: Integer): Boolean;
    class function Add(const A: Integer; const B: Integer): Int64;
  end;

implementation

uses
  System.SysUtils;

class function TStringUtils.Reverse(const Text: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := Text.Length downto 1 do
    Result := Result + Text[I];
end;

class function TMathUtils.IsEven(const Value: Integer): Boolean;
begin
  Result := (Value mod 2) = 0;
end;

class function TMathUtils.Add(const A: Integer; const B: Integer): Int64;
begin
  Result := Int64(A) + Int64(B);
end;

end.
