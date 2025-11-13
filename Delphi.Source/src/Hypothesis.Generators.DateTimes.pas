unit Hypothesis.Generators.DateTimes;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.DateUtils,
  Spring.Collections,
  Hypothesis.Generators.Interfaces;

type
  /// <summary>
  /// Generator for TDateTime and TDate values.
  /// </summary>
  /// <remarks>
  /// Generates random dates and datetimes within specified year range.
  /// Shrinking behavior: Dates shrink towards year 2000, January 1st, midnight.
  /// </remarks>
  TDateTimeGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMinYear: Word;
    FMaxYear: Word;
    FIncludeTime: Boolean;

    function IsValidDate(Year, Month, Day: Word): Boolean;
  public
    constructor Create(const MinYear: Word; const MaxYear: Word; const IncludeTime: Boolean);

    /// <summary>
    /// Generates a random date or datetime value.
    /// </summary>
    function GenerateValue: TValue;

    /// <summary>
    /// Returns shrink candidates for the given date/datetime value.
    /// </summary>
    function Shrink(const Value: TValue): IList<TValue>;
  end;

  /// <summary>
  /// Generator for TTime values (time of day only).
  /// </summary>
  /// <remarks>
  /// Generates random times between 00:00:00.000 and 23:59:59.999.
  /// Shrinking behavior: Times shrink towards midnight (00:00:00.000).
  /// </remarks>
  TTimeGenerator = class(TInterfacedObject, IValueGenerator)
  public
    /// <summary>
    /// Generates a random time value.
    /// </summary>
    function GenerateValue: TValue;

    /// <summary>
    /// Returns shrink candidates for the given time value.
    /// </summary>
    function Shrink(const Value: TValue): IList<TValue>;
  end;

implementation

{ TDateTimeGenerator }

constructor TDateTimeGenerator.Create(const MinYear: Word; const MaxYear: Word;
                                       const IncludeTime: Boolean);
begin
  inherited Create;
  FMinYear := MinYear;
  FMaxYear := MaxYear;
  FIncludeTime := IncludeTime;
end;

function TDateTimeGenerator.IsValidDate(Year, Month, Day: Word): Boolean;
begin
  try
    EncodeDate(Year, Month, Day);
    Result := True;
  except
    Result := False;
  end;
end;

function TDateTimeGenerator.GenerateValue: TValue;
var
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
  DatePart, TimePart: TDateTime;
begin
  // Generate valid date
  repeat
    Year := FMinYear + Random(FMaxYear - FMinYear + 1);
    Month := 1 + Random(12);
    Day := 1 + Random(31);
  until IsValidDate(Year, Month, Day);

  DatePart := EncodeDate(Year, Month, Day);

  if FIncludeTime then
  begin
    Hour := Random(24);
    Min := Random(60);
    Sec := Random(60);
    MSec := Random(1000);
    TimePart := EncodeTime(Hour, Min, Sec, MSec);
    Result := TValue.From<TDateTime>(DatePart + TimePart);
  end
  else
    Result := TValue.From<TDate>(DatePart);
end;

function TDateTimeGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  DateTime: TDateTime;
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
  Candidates: IList<TValue>;
  Target2000: TDateTime;
begin
  Candidates := TCollections.CreateList<TValue>;
  DateTime := Value.AsExtended;

  DecodeDate(DateTime, Year, Month, Day);

  // Target: Year 2000, Jan 1
  if Year <> 2000 then
  begin
    if IsValidDate(2000, 1, 1) and (2000 >= FMinYear) and (2000 <= FMaxYear) then
    begin
      Target2000 := EncodeDate(2000, 1, 1);
      if FIncludeTime then
        Target2000 := Target2000 + 0.0; // Midnight
      Candidates.Add(TValue.From<TDateTime>(Target2000));
    end;
  end;

  // Shrink towards first of month
  if Day > 1 then
  begin
    if IsValidDate(Year, Month, 1) then
      Candidates.Add(TValue.From<TDateTime>(EncodeDate(Year, Month, 1) + Frac(DateTime)));
  end;

  // Shrink towards January
  if Month > 1 then
  begin
    if IsValidDate(Year, 1, Day) then
      Candidates.Add(TValue.From<TDateTime>(EncodeDate(Year, 1, Day) + Frac(DateTime)));
  end;

  // Shrink year towards 2000
  if Year > 2000 then
  begin
    if IsValidDate(Year - 1, Month, Day) and ((Year - 1) >= FMinYear) then
      Candidates.Add(TValue.From<TDateTime>(EncodeDate(Year - 1, Month, Day) + Frac(DateTime)));
  end
  else if Year < 2000 then
  begin
    if IsValidDate(Year + 1, Month, Day) and ((Year + 1) <= FMaxYear) then
      Candidates.Add(TValue.From<TDateTime>(EncodeDate(Year + 1, Month, Day) + Frac(DateTime)));
  end;

  // If including time, shrink time towards midnight
  if FIncludeTime then
  begin
    DecodeTime(DateTime, Hour, Min, Sec, MSec);

    // Try midnight
    if (Hour <> 0) or (Min <> 0) or (Sec <> 0) or (MSec <> 0) then
      Candidates.Add(TValue.From<TDateTime>(Int(DateTime))); // Remove time part

    // Shrink milliseconds
    if MSec > 0 then
      Candidates.Add(TValue.From<TDateTime>(Int(DateTime) + EncodeTime(Hour, Min, Sec, 0)));

    // Shrink seconds
    if Sec > 0 then
      Candidates.Add(TValue.From<TDateTime>(Int(DateTime) + EncodeTime(Hour, Min, 0, 0)));

    // Shrink minutes
    if Min > 0 then
      Candidates.Add(TValue.From<TDateTime>(Int(DateTime) + EncodeTime(Hour, 0, 0, 0)));
  end;

  Result := Candidates;
end;

{ TTimeGenerator }

function TTimeGenerator.GenerateValue: TValue;
var
  Hour, Min, Sec, MSec: Word;
begin
  Hour := Random(24);
  Min := Random(60);
  Sec := Random(60);
  MSec := Random(1000);
  Result := TValue.From<TTime>(EncodeTime(Hour, Min, Sec, MSec));
end;

function TTimeGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  Time: TDateTime;
  Hour, Min, Sec, MSec: Word;
  Candidates: IList<TValue>;
begin
  Candidates := TCollections.CreateList<TValue>;
  Time := Value.AsExtended;

  DecodeTime(Time, Hour, Min, Sec, MSec);

  // Shrink towards midnight (00:00:00.000)
  if (Hour <> 0) or (Min <> 0) or (Sec <> 0) or (MSec <> 0) then
    Candidates.Add(TValue.From<TTime>(EncodeTime(0, 0, 0, 0)));

  // Shrink milliseconds
  if MSec > 0 then
    Candidates.Add(TValue.From<TTime>(EncodeTime(Hour, Min, Sec, 0)));

  // Shrink seconds
  if Sec > 0 then
    Candidates.Add(TValue.From<TTime>(EncodeTime(Hour, Min, 0, 0)));

  // Shrink minutes
  if Min > 0 then
    Candidates.Add(TValue.From<TTime>(EncodeTime(Hour, 0, 0, 0)));

  Result := Candidates;
end;

end.
