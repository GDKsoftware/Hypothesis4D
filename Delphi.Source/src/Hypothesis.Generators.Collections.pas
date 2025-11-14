unit Hypothesis.Generators.Collections;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Spring.Collections,
  Hypothesis.Generators.Interfaces,
  System.TypInfo;

type
  TArrayGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMinCount: Integer;
    FMaxCount: Integer;
    FElementGenerator: IValueGenerator;
    FElementTypeInfo: PTypeInfo;

  public
    constructor Create(const MinCount: Integer; const MaxCount: Integer;
                       const ElementGenerator: IValueGenerator;
                       const ElementTypeInfo: PTypeInfo);

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

  TListGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMinCount: Integer;
    FMaxCount: Integer;
    FElementGenerator: IValueGenerator;
    FElementTypeInfo: PTypeInfo;

  public
    constructor Create(const MinCount: Integer; const MaxCount: Integer;
                       const ElementGenerator: IValueGenerator;
                       const ElementTypeInfo: PTypeInfo);

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

  TDictionaryGenerator = class(TInterfacedObject, IValueGenerator)
  private
    FMinCount: Integer;
    FMaxCount: Integer;
    FKeyGenerator: IValueGenerator;
    FValueGenerator: IValueGenerator;
    FKeyTypeInfo: PTypeInfo;
    FValueTypeInfo: PTypeInfo;

  public
    constructor Create(const MinCount: Integer; const MaxCount: Integer;
                       const KeyGenerator: IValueGenerator;
                       const ValueGenerator: IValueGenerator;
                       const KeyTypeInfo: PTypeInfo;
                       const ValueTypeInfo: PTypeInfo);

    function GenerateValue: TValue;
    function Shrink(const Value: TValue): IList<TValue>;
  end;

implementation

{ TArrayGenerator }

constructor TArrayGenerator.Create(const MinCount: Integer; const MaxCount: Integer;
                                   const ElementGenerator: IValueGenerator;
                                   const ElementTypeInfo: PTypeInfo);
begin
  inherited Create;
  FMinCount := MinCount;
  FMaxCount := MaxCount;
  FElementGenerator := ElementGenerator;
  FElementTypeInfo := ElementTypeInfo;
end;

function TArrayGenerator.GenerateValue: TValue;
var
  Count: Integer;
  I: Integer;
  ArrayValue: TValue;
  Elements: array of TValue;
begin
  Count := FMinCount + Random(FMaxCount - FMinCount + 1);
  SetLength(Elements, Count);

  for I := 0 to Count - 1 do
    Elements[I] := FElementGenerator.GenerateValue;

  // Create dynamic array TValue
  // Note: This is a simplified implementation. Full generic array support
  // requires more complex RTTI manipulation based on FElementTypeInfo
  case FElementTypeInfo.Kind of
    tkInteger, tkInt64:
      begin
        var IntArray: TArray<Int64>;
        SetLength(IntArray, Count);
        for I := 0 to Count - 1 do
          IntArray[I] := Elements[I].AsInt64;
        Result := TValue.From<TArray<Int64>>(IntArray);
      end;

    tkUString, tkString, tkWString, tkLString:
      begin
        var StrArray: TArray<string>;
        SetLength(StrArray, Count);
        for I := 0 to Count - 1 do
          StrArray[I] := Elements[I].AsString;
        Result := TValue.From<TArray<string>>(StrArray);
      end;

    tkFloat:
      begin
        var FloatArray: TArray<Double>;
        SetLength(FloatArray, Count);
        for I := 0 to Count - 1 do
          FloatArray[I] := Elements[I].AsExtended;
        Result := TValue.From<TArray<Double>>(FloatArray);
      end;

    tkEnumeration:
      begin
        if FElementTypeInfo = TypeInfo(Boolean) then
        begin
          var BoolArray: TArray<Boolean>;
          SetLength(BoolArray, Count);
          for I := 0 to Count - 1 do
            BoolArray[I] := Elements[I].AsBoolean;
          Result := TValue.From<TArray<Boolean>>(BoolArray);
        end
        else
          raise Exception.Create('Unsupported enumeration type for array generation');
      end;
  else
    raise Exception.CreateFmt('Unsupported type kind for array generation: %d', [Ord(FElementTypeInfo.Kind)]);
  end;
end;

function TArrayGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  Candidates: IList<TValue>;
  ArrayLen: Integer;
  HalfLen: Integer;
begin
  Candidates := TCollections.CreateList<TValue>;

  // Get array length using RTTI
  ArrayLen := Value.GetArrayLength;

  if ArrayLen <= FMinCount then
    Exit(Candidates);

  // Try shorter arrays
  if ArrayLen > FMinCount then
  begin
    // Shrink to minimum length
    // Note: Simplified - full implementation would create actual shortened arrays
  end;

  HalfLen := (ArrayLen + FMinCount) div 2;
  if (HalfLen > FMinCount) and (HalfLen < ArrayLen) then
  begin
    // Shrink to half length
  end;

  // Try shrinking individual elements
  // Note: This requires more complex RTTI manipulation

  Result := Candidates;
end;

{ TListGenerator }

constructor TListGenerator.Create(const MinCount: Integer; const MaxCount: Integer;
                                  const ElementGenerator: IValueGenerator;
                                  const ElementTypeInfo: PTypeInfo);
begin
  inherited Create;
  FMinCount := MinCount;
  FMaxCount := MaxCount;
  FElementGenerator := ElementGenerator;
  FElementTypeInfo := ElementTypeInfo;
end;

function TListGenerator.GenerateValue: TValue;
var
  Count: Integer;
  I: Integer;
begin
  Count := FMinCount + Random(FMaxCount - FMinCount + 1);

  // Create Spring.Collections list based on element type
  case FElementTypeInfo.Kind of
    tkInteger, tkInt64:
      begin
        var IntList := TCollections.CreateList<Int64>;
        for I := 1 to Count do
          IntList.Add(FElementGenerator.GenerateValue.AsInt64);
        Result := TValue.From<IList<Int64>>(IntList);
      end;

    tkUString, tkString, tkWString, tkLString:
      begin
        var StrList := TCollections.CreateList<string>;
        for I := 1 to Count do
          StrList.Add(FElementGenerator.GenerateValue.AsString);
        Result := TValue.From<IList<string>>(StrList);
      end;

    tkFloat:
      begin
        var FloatList := TCollections.CreateList<Double>;
        for I := 1 to Count do
          FloatList.Add(FElementGenerator.GenerateValue.AsExtended);
        Result := TValue.From<IList<Double>>(FloatList);
      end;

    tkEnumeration:
      begin
        if FElementTypeInfo = TypeInfo(Boolean) then
        begin
          var BoolList := TCollections.CreateList<Boolean>;
          for I := 1 to Count do
            BoolList.Add(FElementGenerator.GenerateValue.AsBoolean);
          Result := TValue.From<IList<Boolean>>(BoolList);
        end
        else
          raise Exception.Create('Unsupported enumeration type for list generation');
      end;
  else
    raise Exception.CreateFmt('Unsupported type kind for list generation: %d', [Ord(FElementTypeInfo.Kind)]);
  end;
end;

function TListGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  Candidates: IList<TValue>;
begin
  Candidates := TCollections.CreateList<TValue>;

  // Shrinking for Spring.Collections IList<T>
  // Note: Requires extracting the IList<T> interface and manipulating it

  Result := Candidates;
end;

{ TDictionaryGenerator }

constructor TDictionaryGenerator.Create(const MinCount: Integer; const MaxCount: Integer;
                                        const KeyGenerator: IValueGenerator;
                                        const ValueGenerator: IValueGenerator;
                                        const KeyTypeInfo: PTypeInfo;
                                        const ValueTypeInfo: PTypeInfo);
begin
  inherited Create;
  FMinCount := MinCount;
  FMaxCount := MaxCount;
  FKeyGenerator := KeyGenerator;
  FValueGenerator := ValueGenerator;
  FKeyTypeInfo := KeyTypeInfo;
  FValueTypeInfo := ValueTypeInfo;
end;

function TDictionaryGenerator.GenerateValue: TValue;
var
  Count: Integer;
  I: Integer;
  Key: TValue;
  Val: TValue;
begin
  Count := FMinCount + Random(FMaxCount - FMinCount + 1);

  // Create Spring.Collections dictionary based on key/value types
  // Simplified: Support common type combinations
  if (FKeyTypeInfo.Kind in [tkInteger, tkInt64]) and
     (FValueTypeInfo.Kind in [tkUString, tkString, tkWString, tkLString]) then
  begin
    var Dict := TCollections.CreateDictionary<Int64, string>;
    for I := 1 to Count do
    begin
      Key := FKeyGenerator.GenerateValue;
      Val := FValueGenerator.GenerateValue;
      // Ensure unique keys
      if not Dict.ContainsKey(Key.AsInt64) then
        Dict.Add(Key.AsInt64, Val.AsString);
    end;
    Result := TValue.From<IDictionary<Int64, string>>(Dict);
  end
  else if (FKeyTypeInfo.Kind in [tkUString, tkString, tkWString, tkLString]) and
          (FValueTypeInfo.Kind in [tkInteger, tkInt64]) then
  begin
    var Dict := TCollections.CreateDictionary<string, Int64>;
    for I := 1 to Count do
    begin
      Key := FKeyGenerator.GenerateValue;
      Val := FValueGenerator.GenerateValue;
      if not Dict.ContainsKey(Key.AsString) then
        Dict.Add(Key.AsString, Val.AsInt64);
    end;
    Result := TValue.From<IDictionary<string, Int64>>(Dict);
  end
  else if (FKeyTypeInfo.Kind in [tkUString, tkString, tkWString, tkLString]) and
          (FValueTypeInfo.Kind in [tkUString, tkString, tkWString, tkLString]) then
  begin
    var Dict := TCollections.CreateDictionary<string, string>;
    for I := 1 to Count do
    begin
      Key := FKeyGenerator.GenerateValue;
      Val := FValueGenerator.GenerateValue;
      if not Dict.ContainsKey(Key.AsString) then
        Dict.Add(Key.AsString, Val.AsString);
    end;
    Result := TValue.From<IDictionary<string, string>>(Dict);
  end
  else
    raise Exception.CreateFmt('Unsupported type combination for dictionary: Key=%d, Value=%d',
                              [Ord(FKeyTypeInfo.Kind), Ord(FValueTypeInfo.Kind)]);
end;

function TDictionaryGenerator.Shrink(const Value: TValue): IList<TValue>;
var
  Candidates: IList<TValue>;
begin
  Candidates := TCollections.CreateList<TValue>;

  // Shrinking for Spring.Collections IDictionary<K,V>
  // Note: Requires extracting the dictionary and manipulating it

  Result := Candidates;
end;

end.
