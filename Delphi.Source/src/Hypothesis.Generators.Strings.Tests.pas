unit Hypothesis.Generators.Strings.Tests;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  System.SysUtils,
  Spring.Collections,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.Strings;

type
  [TestFixture]
  TStringGeneratorTests = class
  private
    function IsAlpha(const Ch: Char): Boolean;
    function IsNumeric(const Ch: Char): Boolean;
    function IsAscii(const Ch: Char): Boolean;
  public
    [Test]
    procedure TestGenerateAlphaString;

    [Test]
    procedure TestGenerateNumericString;

    [Test]
    procedure TestGenerateAsciiString;

    [Test]
    procedure TestGenerateUnicodeString;

    [Test]
    procedure TestGenerateEmail;

    [Test]
    procedure TestGenerateUrl;

    [Test]
    procedure TestGenerateUrlWithoutProtocol;

    [Test]
    procedure TestGenerateFromRegexSimple;

    [Test]
    procedure TestShrinkStringTowardEmpty;

    [Test]
    procedure TestShrinkStringTowardSimpler;
  end;

implementation

{ TStringGeneratorTests }

function TStringGeneratorTests.IsAlpha(const Ch: Char): Boolean;
begin
  Result := ((Ch >= 'A') and (Ch <= 'Z')) or ((Ch >= 'a') and (Ch <= 'z'));
end;

function TStringGeneratorTests.IsNumeric(const Ch: Char): Boolean;
begin
  Result := (Ch >= '0') and (Ch <= '9');
end;

function TStringGeneratorTests.IsAscii(const Ch: Char): Boolean;
begin
  Result := (Ord(Ch) >= 32) and (Ord(Ch) <= 126);
end;

procedure TStringGeneratorTests.TestGenerateAlphaString;
var
  Generator: IValueGenerator;
  Value: TValue;
  Text: string;
  I: Integer;
begin
  Generator := TStringGenerator.Create(5, 10, TStringCharSet.Alpha);
  Value := Generator.GenerateValue;
  Text := Value.AsString;

  Assert.IsTrue((Text.Length >= 5) and (Text.Length <= 10), 'String length should be in range [5, 10]');

  for I := 1 to Text.Length do
    Assert.IsTrue(IsAlpha(Text[I]), 'All characters should be alphabetic');
end;

procedure TStringGeneratorTests.TestGenerateNumericString;
var
  Generator: IValueGenerator;
  Value: TValue;
  Text: string;
  I: Integer;
begin
  Generator := TStringGenerator.Create(3, 8, TStringCharSet.Numeric);
  Value := Generator.GenerateValue;
  Text := Value.AsString;

  Assert.IsTrue((Text.Length >= 3) and (Text.Length <= 8), 'String length should be in range [3, 8]');

  for I := 1 to Text.Length do
    Assert.IsTrue(IsNumeric(Text[I]), 'All characters should be numeric');
end;

procedure TStringGeneratorTests.TestGenerateAsciiString;
var
  Generator: IValueGenerator;
  Value: TValue;
  Text: string;
  I: Integer;
begin
  Generator := TStringGenerator.Create(5, 15, TStringCharSet.Ascii);
  Value := Generator.GenerateValue;
  Text := Value.AsString;

  Assert.IsTrue((Text.Length >= 5) and (Text.Length <= 15), 'String length should be in range [5, 15]');

  for I := 1 to Text.Length do
    Assert.IsTrue(IsAscii(Text[I]), 'All characters should be ASCII (32-126)');
end;

procedure TStringGeneratorTests.TestGenerateUnicodeString;
var
  Generator: IValueGenerator;
  Value: TValue;
  Text: string;
begin
  Generator := TStringGenerator.Create(5, 15, TStringCharSet.Unicode);
  Value := Generator.GenerateValue;
  Text := Value.AsString;

  Assert.IsTrue((Text.Length >= 5) and (Text.Length <= 15), 'String length should be in range [5, 15]');
  // Unicode strings may contain characters outside basic ASCII range
  Assert.IsTrue(Text.Length > 0, 'Generated string should not be empty');
end;

procedure TStringGeneratorTests.TestGenerateEmail;
var
  Generator: IValueGenerator;
  Value: TValue;
  Email: string;
  AtPos: Integer;
begin
  Generator := TStringGenerator.Create(0, 0, TStringCharSet.Email);
  Value := Generator.GenerateValue;
  Email := Value.AsString;

  Assert.IsTrue(Email.Contains('@'), 'Email should contain @ symbol');
  Assert.IsTrue(Email.Length > 3, 'Email should have minimum length');

  AtPos := Email.IndexOf('@');
  Assert.IsTrue(AtPos > 0, 'Email should have local part before @');
  Assert.IsTrue(AtPos < Email.Length - 1, 'Email should have domain after @');
end;

procedure TStringGeneratorTests.TestGenerateUrl;
var
  Generator: IValueGenerator;
  Value: TValue;
  Url: string;
begin
  Generator := TStringGenerator.Create(True); // With protocol
  Value := Generator.GenerateValue;
  Url := Value.AsString;

  Assert.IsTrue(Url.Length > 0, 'URL should not be empty');
  Assert.IsTrue(Url.Contains('.'), 'URL should contain a domain');
  Assert.IsTrue(Url.StartsWith('http://') or Url.StartsWith('https://') or Url.StartsWith('ftp://'),
                'URL with protocol should start with http://, https://, or ftp://');
end;

procedure TStringGeneratorTests.TestGenerateUrlWithoutProtocol;
var
  Generator: IValueGenerator;
  Value: TValue;
  Url: string;
begin
  Generator := TStringGenerator.Create(False); // Without protocol
  Value := Generator.GenerateValue;
  Url := Value.AsString;

  Assert.IsTrue(Url.Length > 0, 'URL should not be empty');
  Assert.IsTrue(Url.Contains('.'), 'URL should contain a domain');
  Assert.IsFalse(Url.Contains('://'), 'URL without protocol should not contain ://');
end;

procedure TStringGeneratorTests.TestGenerateFromRegexSimple;
var
  Generator: IValueGenerator;
  Value: TValue;
  Text: string;
begin
  Generator := TStringGenerator.Create('[a-z][0-9]');
  Value := Generator.GenerateValue;
  Text := Value.AsString;

  Assert.AreEqual(2, Text.Length, 'Pattern [a-z][0-9] should generate 2 characters');
  Assert.IsTrue((Text[1] >= 'a') and (Text[1] <= 'z'), 'First character should be lowercase letter');
  Assert.IsTrue((Text[2] >= '0') and (Text[2] <= '9'), 'Second character should be digit');
end;

procedure TStringGeneratorTests.TestShrinkStringTowardEmpty;
var
  Generator: IValueGenerator;
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  Generator := TStringGenerator.Create(0, 100, TStringCharSet.Alpha);
  Value := TValue.From<string>('ABCDEF');
  Shrinks := Generator.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'String should shrink to simpler candidates');

  // First shrink candidate should be empty string
  Assert.AreEqual('', Shrinks[0].AsString, 'First shrink candidate should be empty string');
end;

procedure TStringGeneratorTests.TestShrinkStringTowardSimpler;
var
  Generator: IValueGenerator;
  Value: TValue;
  Shrinks: IList<TValue>;
  I: Integer;
  ShrunkLength: Integer;
  OriginalLength: Integer;
begin
  Generator := TStringGenerator.Create(0, 100, TStringCharSet.Alpha);
  Value := TValue.From<string>('HELLO');
  Shrinks := Generator.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'String should shrink to simpler candidates');

  OriginalLength := 5;
  for I := 0 to Shrinks.Count - 1 do
  begin
    ShrunkLength := Shrinks[I].AsString.Length;
    Assert.IsTrue(ShrunkLength <= OriginalLength,
                  'Each shrink candidate should be shorter than or equal to original');
  end;
end;

end.
