unit Hypothesis.Generators.Strings;

interface

uses
  System.SysUtils,
  System.Rtti,
  Spring.Collections,
  Hypothesis.Generators.Interfaces;

type
  TStringCharSet = (Any, Alpha, Numeric, Ascii, Unicode, Email, Url, Regex);

  TStringGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMinLen: Integer;
    FMaxLen: Integer;
    FCharSet: TStringCharSet;
    FIncludeProtocol: Boolean;
    FRegexPattern: string;

    function GenerateChar: Char;
    function SimplifyChar(const Ch: Char): Char;
    function GenerateEmail: string;
    function GenerateUrl: string;
    function GenerateFromRegex: string;

  public
    constructor Create(const MinLen: Integer; const MaxLen: Integer; const CharSet: TStringCharSet); overload;
    constructor Create(const IncludeProtocol: Boolean); overload;
    constructor Create(const RegexPattern: string); overload;

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
  FIncludeProtocol := True;
  FRegexPattern := '';
end;

constructor TStringGenerator.Create(const IncludeProtocol: Boolean);
begin
  inherited Create;
  FMinLen := 0;
  FMaxLen := 0;
  FCharSet := TStringCharSet.Url;
  FIncludeProtocol := IncludeProtocol;
  FRegexPattern := '';
end;

constructor TStringGenerator.Create(const RegexPattern: string);
begin
  inherited Create;
  FMinLen := 0;
  FMaxLen := 0;
  FCharSet := TStringCharSet.Regex;
  FIncludeProtocol := True;
  FRegexPattern := RegexPattern;
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

    TStringCharSet.Ascii:
      Result := Chr(32 + Random(95));

    TStringCharSet.Unicode:
      begin
        // Generate Unicode characters from various ranges
        case Random(4) of
          0: Result := Chr(32 + Random(95));             // Basic Latin
          1: Result := Chr($00A0 + Random(96));          // Latin-1 Supplement
          2: Result := Chr($0100 + Random(128));         // Latin Extended-A
          3: Result := Chr($0370 + Random(128));         // Greek and Coptic
        else
          Result := Chr(32 + Random(95));
        end;
      end;
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

    TStringCharSet.Ascii:
      Result := ' ';

    TStringCharSet.Unicode:
      Result := 'a';
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
  // Handle special string types
  case FCharSet of
    TStringCharSet.Email:
      Exit(TValue.From<string>(GenerateEmail));

    TStringCharSet.Url:
      Exit(TValue.From<string>(GenerateUrl));

    TStringCharSet.Regex:
      Exit(TValue.From<string>(GenerateFromRegex));
  end;

  // Standard character-based generation
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

function TStringGenerator.GenerateEmail: string;
const
  Domains: array[0..4] of string = ('example.com', 'test.com', 'mail.com', 'email.com', 'domain.com');
var
  LocalLen: Integer;
  I: Integer;
  LocalPart: string;
begin
  LocalLen := 3 + Random(8);
  SetLength(LocalPart, LocalLen);
  for I := 1 to LocalLen do
  begin
    if Random(10) = 0 then
      LocalPart[I] := '.'
    else if Random(2) = 0 then
      LocalPart[I] := Chr(Ord('a') + Random(26))
    else
      LocalPart[I] := Chr(Ord('0') + Random(10));
  end;

  Result := LocalPart + '@' + Domains[Random(Length(Domains))];
end;

function TStringGenerator.GenerateUrl: string;
const
  Protocols: array[0..2] of string = ('http://', 'https://', 'ftp://');
  Domains: array[0..4] of string = ('example.com', 'test.com', 'website.org', 'site.net', 'domain.io');
  Paths: array[0..5] of string = ('', '/index', '/page', '/api/data', '/users/profile', '/docs');
var
  Protocol: string;
  Domain: string;
  Path: string;
begin
  if FIncludeProtocol then
    Protocol := Protocols[Random(Length(Protocols))]
  else
    Protocol := '';

  Domain := Domains[Random(Length(Domains))];
  Path := Paths[Random(Length(Paths))];

  Result := Protocol + Domain + Path;
end;

function TStringGenerator.GenerateFromRegex: string;
var
  I: Integer;
  Ch: Char;
  InBracket: Boolean;
  BracketContent: string;
  Builder: TStringBuilder;
begin
  // Simple regex pattern generator - supports basic patterns
  // Supports: literal characters, [abc], [a-z], [0-9], \d, \w, ., *, +, ?
  Builder := TStringBuilder.Create;
  try
    I := 1;
    InBracket := False;
    BracketContent := '';

    while I <= Length(FRegexPattern) do
    begin
      Ch := FRegexPattern[I];

      if Ch = '[' then
      begin
        InBracket := True;
        BracketContent := '';
      end
      else if Ch = ']' then
      begin
        InBracket := False;
        // Generate character from bracket content
        if BracketContent.Contains('-') then
        begin
          // Range like a-z or 0-9
          var Parts := BracketContent.Split(['-']);
          if Length(Parts) = 2 then
          begin
            var StartChar := Parts[0][1];
            var EndChar := Parts[1][1];
            Builder.Append(Chr(Ord(StartChar) + Random(Ord(EndChar) - Ord(StartChar) + 1)));
          end;
        end
        else if BracketContent.Length > 0 then
        begin
          // Literal characters in brackets
          Builder.Append(BracketContent[1 + Random(BracketContent.Length)]);
        end;
      end
      else if InBracket then
      begin
        BracketContent := BracketContent + Ch;
      end
      else if Ch = '\' then
      begin
        Inc(I);
        if I <= Length(FRegexPattern) then
        begin
          case FRegexPattern[I] of
            'd': Builder.Append(Chr(Ord('0') + Random(10)));
            'w': Builder.Append(Chr(Ord('a') + Random(26)));
            's': Builder.Append(' ');
          else
            Builder.Append(FRegexPattern[I]);
          end;
        end;
      end
      else if Ch = '.' then
        Builder.Append(Chr(32 + Random(95)))
      else if Ch = '*' then
      begin
        // Repeat previous character 0-3 times
        if Builder.Length > 0 then
        begin
          var LastChar := Builder.Chars[Builder.Length - 1];
          var RepeatCount := Random(4);
          for var J := 1 to RepeatCount do
            Builder.Append(LastChar);
        end;
      end
      else if Ch = '+' then
      begin
        // Repeat previous character 1-3 times
        if Builder.Length > 0 then
        begin
          var LastChar := Builder.Chars[Builder.Length - 1];
          var RepeatCount := 1 + Random(3);
          for var J := 1 to RepeatCount do
            Builder.Append(LastChar);
        end;
      end
      else if Ch = '?' then
      begin
        // Previous character is optional
        if (Builder.Length > 0) and (Random(2) = 0) then
          Builder.Remove(Builder.Length - 1, 1);
      end
      else
        Builder.Append(Ch);

      Inc(I);
    end;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

end.
