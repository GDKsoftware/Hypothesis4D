unit Hypothesis.Generators.DateTimes.Tests;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  System.SysUtils,
  System.DateUtils,
  Spring.Collections,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.DateTimes;

type
  [TestFixture]
  TDateTimeGeneratorTests = class
  private
    FDateGenerator: IValueGenerator;
    FDateTimeGenerator: IValueGenerator;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestGenerateDateValueReturnsFloatType;

    [Test]
    procedure TestGenerateDateInYearRange;

    [Test]
    procedure TestGenerateDateTimeIncludesTime;

    [Test]
    procedure TestShrinkToYear2000;

    [Test]
    procedure TestShrinkToFirstOfMonth;

    [Test]
    procedure TestShrinkToJanuary;

    [Test]
    procedure TestShrinkTimeToMidnight;

    [Test]
    procedure TestShrinkTimeComponents;
  end;

  [TestFixture]
  TTimeGeneratorTests = class
  private
    FGenerator: IValueGenerator;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestGenerateTimeReturnsFloatType;

    [Test]
    procedure TestGenerateTimeInValidRange;

    [Test]
    procedure TestShrinkToMidnight;

    [Test]
    procedure TestShrinkTimeComponentsIndependently;
  end;

implementation

{ TDateTimeGeneratorTests }

procedure TDateTimeGeneratorTests.Setup;
begin
  FDateGenerator := TDateTimeGenerator.Create(1900, 2100, False);
  FDateTimeGenerator := TDateTimeGenerator.Create(1900, 2100, True);
end;

procedure TDateTimeGeneratorTests.TearDown;
begin
  FDateGenerator := nil;
  FDateTimeGenerator := nil;
end;

procedure TDateTimeGeneratorTests.TestGenerateDateValueReturnsFloatType;
var
  Value: TValue;
begin
  Value := FDateGenerator.GenerateValue;
  Assert.AreEqual(tkFloat, Value.Kind);
end;

procedure TDateTimeGeneratorTests.TestGenerateDateInYearRange;
var
  I: Integer;
  Value: TValue;
  DateTime: TDateTime;
  Year, Month, Day: Word;
begin
  for I := 1 to 100 do
  begin
    Value := FDateGenerator.GenerateValue;
    DateTime := Value.AsExtended;
    DecodeDate(DateTime, Year, Month, Day);

    Assert.IsTrue((Year >= 1900) and (Year <= 2100),
                  Format('Year %d should be in range [1900, 2100]', [Year]));
  end;
end;

procedure TDateTimeGeneratorTests.TestGenerateDateTimeIncludesTime;
var
  Value: TValue;
  DateTime: TDateTime;
  Hour, Min, Sec, MSec: Word;
  HasNonZeroTime: Boolean;
  I: Integer;
begin
  HasNonZeroTime := False;

  // Generate multiple values to find at least one with non-zero time
  for I := 1 to 50 do
  begin
    Value := FDateTimeGenerator.GenerateValue;
    DateTime := Value.AsExtended;
    DecodeTime(DateTime, Hour, Min, Sec, MSec);

    if (Hour <> 0) or (Min <> 0) or (Sec <> 0) or (MSec <> 0) then
    begin
      HasNonZeroTime := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasNonZeroTime, 'DateTime generator should produce values with non-zero time components');
end;

procedure TDateTimeGeneratorTests.TestShrinkToYear2000;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasYear2000: Boolean;
  I: Integer;
  DateTime: TDateTime;
  Year, Month, Day: Word;
begin
  Value := TValue.From<TDateTime>(EncodeDate(2015, 6, 15));
  Shrinks := FDateGenerator.Shrink(Value);

  HasYear2000 := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    DateTime := Shrinks[I].AsExtended;
    DecodeDate(DateTime, Year, Month, Day);
    if Year = 2000 then
    begin
      HasYear2000 := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasYear2000, 'Date should shrink towards year 2000');
end;

procedure TDateTimeGeneratorTests.TestShrinkToFirstOfMonth;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasFirstDay: Boolean;
  I: Integer;
  DateTime: TDateTime;
  Year, Month, Day: Word;
begin
  Value := TValue.From<TDateTime>(EncodeDate(2010, 5, 15));
  Shrinks := FDateGenerator.Shrink(Value);

  HasFirstDay := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    DateTime := Shrinks[I].AsExtended;
    DecodeDate(DateTime, Year, Month, Day);
    if Day = 1 then
    begin
      HasFirstDay := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasFirstDay, 'Date should shrink towards first day of month');
end;

procedure TDateTimeGeneratorTests.TestShrinkToJanuary;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasJanuary: Boolean;
  I: Integer;
  DateTime: TDateTime;
  Year, Month, Day: Word;
begin
  Value := TValue.From<TDateTime>(EncodeDate(2010, 6, 15));
  Shrinks := FDateGenerator.Shrink(Value);

  HasJanuary := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    DateTime := Shrinks[I].AsExtended;
    DecodeDate(DateTime, Year, Month, Day);
    if Month = 1 then
    begin
      HasJanuary := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasJanuary, 'Date should shrink towards January');
end;

procedure TDateTimeGeneratorTests.TestShrinkTimeToMidnight;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasMidnight: Boolean;
  I: Integer;
  DateTime: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  Value := TValue.From<TDateTime>(EncodeDate(2010, 5, 15) + EncodeTime(14, 30, 45, 500));
  Shrinks := FDateTimeGenerator.Shrink(Value);

  HasMidnight := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    DateTime := Shrinks[I].AsExtended;
    DecodeTime(DateTime, Hour, Min, Sec, MSec);
    if (Hour = 0) and (Min = 0) and (Sec = 0) and (MSec = 0) then
    begin
      HasMidnight := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasMidnight, 'DateTime should shrink time towards midnight');
end;

procedure TDateTimeGeneratorTests.TestShrinkTimeComponents;
var
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  Value := TValue.From<TDateTime>(EncodeDate(2010, 5, 15) + EncodeTime(14, 30, 45, 500));
  Shrinks := FDateTimeGenerator.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'DateTime with time should have shrink candidates');
end;

{ TTimeGeneratorTests }

procedure TTimeGeneratorTests.Setup;
begin
  FGenerator := TTimeGenerator.Create;
end;

procedure TTimeGeneratorTests.TearDown;
begin
  FGenerator := nil;
end;

procedure TTimeGeneratorTests.TestGenerateTimeReturnsFloatType;
var
  Value: TValue;
begin
  Value := FGenerator.GenerateValue;
  Assert.AreEqual(tkFloat, Value.Kind);
end;

procedure TTimeGeneratorTests.TestGenerateTimeInValidRange;
var
  I: Integer;
  Value: TValue;
  Time: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  for I := 1 to 100 do
  begin
    Value := FGenerator.GenerateValue;
    Time := Value.AsExtended;
    DecodeTime(Time, Hour, Min, Sec, MSec);

    Assert.IsTrue(Hour < 24, Format('Hour %d should be < 24', [Hour]));
    Assert.IsTrue(Min < 60, Format('Minute %d should be < 60', [Min]));
    Assert.IsTrue(Sec < 60, Format('Second %d should be < 60', [Sec]));
    Assert.IsTrue(MSec < 1000, Format('Millisecond %d should be < 1000', [MSec]));
  end;
end;

procedure TTimeGeneratorTests.TestShrinkToMidnight;
var
  Value: TValue;
  Shrinks: IList<TValue>;
  HasMidnight: Boolean;
  I: Integer;
  Time: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  Value := TValue.From<TTime>(EncodeTime(14, 30, 45, 500));
  Shrinks := FGenerator.Shrink(Value);

  HasMidnight := False;
  for I := 0 to Shrinks.Count - 1 do
  begin
    Time := Shrinks[I].AsExtended;
    DecodeTime(Time, Hour, Min, Sec, MSec);
    if (Hour = 0) and (Min = 0) and (Sec = 0) and (MSec = 0) then
    begin
      HasMidnight := True;
      Break;
    end;
  end;

  Assert.IsTrue(HasMidnight, 'Time should shrink towards midnight');
end;

procedure TTimeGeneratorTests.TestShrinkTimeComponentsIndependently;
var
  Value: TValue;
  Shrinks: IList<TValue>;
begin
  Value := TValue.From<TTime>(EncodeTime(14, 30, 45, 500));
  Shrinks := FGenerator.Shrink(Value);

  Assert.IsTrue(Shrinks.Count > 0, 'Time should have multiple shrink candidates');
  // Should include shrinks for milliseconds, seconds, minutes
end;

end.
