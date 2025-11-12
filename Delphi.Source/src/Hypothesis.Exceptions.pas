unit Hypothesis.Exceptions;

interface

uses
  System.SysUtils,
  System.Rtti,
  Spring.Collections;

type
  TPropertyTestFailure = class(Exception)
  private
    FOriginalValues: IList<TValue>;
    FMinimalValues: IList<TValue>;
    FIterationNumber: Integer;
    FSeed: Integer;

  public
    constructor Create(const Msg: string; const OriginalValues: IList<TValue>; const MinimalValues: IList<TValue>; const IterationNumber: Integer; const Seed: Integer);

    property OriginalValues: IList<TValue> read FOriginalValues;
    property MinimalValues: IList<TValue> read FMinimalValues;
    property IterationNumber: Integer read FIterationNumber;
    property Seed: Integer read FSeed;
  end;

implementation

constructor TPropertyTestFailure.Create(const Msg: string; const OriginalValues: IList<TValue>; const MinimalValues: IList<TValue>; const IterationNumber: Integer; const Seed: Integer);
begin
  inherited Create(Msg);
  FOriginalValues := OriginalValues;
  FMinimalValues := MinimalValues;
  FIterationNumber := IterationNumber;
  FSeed := Seed;
end;

end.
