unit Hypothesis.Runner;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  Hypothesis.Core,
  Hypothesis.Generators.Interfaces,
  Hypothesis.Generators.Strings;

type
  THypothesis = class
  public
    // Original attribute-based execution
    class procedure Run(const TestInstance: TObject; const MethodName: string); overload;

    // New generator-based execution
    class procedure Run(const TestInstance: TObject; const MethodName: string;
                       const Generators: array of IValueGenerator;
                       const Iterations: Integer = 100); overload;

    // ===== ARRAY HELPERS =====

    class function ArrayOfIntegers(const MinCount, MaxCount: Integer;
                                   const MinValue, MaxValue: Int64;
                                   const ExcludeZero: Boolean = False): IValueGenerator;

    class function ArrayOfStrings(const MinCount, MaxCount: Integer;
                                  const MinLen, MaxLen: Integer;
                                  const CharSet: TStringCharSet = TStringCharSet.Any): IValueGenerator;

    class function ArrayOfFloats(const MinCount, MaxCount: Integer;
                                 const MinValue, MaxValue: Double;
                                 const AllowNaN: Boolean = False;
                                 const AllowInfinity: Boolean = False): IValueGenerator;

    class function ArrayOfBooleans(const MinCount, MaxCount: Integer): IValueGenerator;

    class function ArrayOf(const MinCount, MaxCount: Integer;
                          const ElementGenerator: IValueGenerator;
                          const ElementTypeInfo: PTypeInfo): IValueGenerator;

    // ===== LIST HELPERS =====

    class function ListOfIntegers(const MinCount, MaxCount: Integer;
                                  const MinValue, MaxValue: Int64;
                                  const ExcludeZero: Boolean = False): IValueGenerator;

    class function ListOfStrings(const MinCount, MaxCount: Integer;
                                 const MinLen, MaxLen: Integer;
                                 const CharSet: TStringCharSet = TStringCharSet.Any): IValueGenerator;

    class function ListOfFloats(const MinCount, MaxCount: Integer;
                                const MinValue, MaxValue: Double;
                                const AllowNaN: Boolean = False;
                                const AllowInfinity: Boolean = False): IValueGenerator;

    class function ListOfBooleans(const MinCount, MaxCount: Integer): IValueGenerator;

    class function ListOf(const MinCount, MaxCount: Integer;
                         const ElementGenerator: IValueGenerator;
                         const ElementTypeInfo: PTypeInfo): IValueGenerator;

    // ===== DICTIONARY HELPERS =====

    class function DictIntegerToString(const MinCount, MaxCount: Integer;
                                       const KeyMin, KeyMax: Int64;
                                       const ValueMinLen, ValueMaxLen: Integer;
                                       const ValueCharSet: TStringCharSet = TStringCharSet.Any): IValueGenerator;

    class function DictStringToInteger(const MinCount, MaxCount: Integer;
                                       const KeyMinLen, KeyMaxLen: Integer;
                                       const KeyCharSet: TStringCharSet;
                                       const ValueMin, ValueMax: Int64): IValueGenerator;

    class function DictStringToString(const MinCount, MaxCount: Integer;
                                      const KeyMinLen, KeyMaxLen: Integer;
                                      const KeyCharSet: TStringCharSet;
                                      const ValueMinLen, ValueMaxLen: Integer;
                                      const ValueCharSet: TStringCharSet): IValueGenerator;

    class function DictOf(const MinCount, MaxCount: Integer;
                         const KeyGenerator, ValueGenerator: IValueGenerator;
                         const KeyTypeInfo, ValueTypeInfo: PTypeInfo): IValueGenerator;
  end;

implementation

uses
  Hypothesis.Attributes,
  Hypothesis.Exceptions,
  Hypothesis.Generators.Integers,
  Hypothesis.Generators.Booleans,
  Hypothesis.Generators.Floats,
  Hypothesis.Generators.Collections;

class procedure THypothesis.Run(const TestInstance: TObject; const MethodName: string);
var
  Context: TRttiContext;
  RttiType: TRttiType;
  Method: TRttiMethod;
  Runner: TPropertyTestRunner;
begin
  Context := TRttiContext.Create;
  try
    RttiType := Context.GetType(TestInstance.ClassType);
    Method := RttiType.GetMethod(MethodName);

    if Method = nil then
      raise Exception.CreateFmt('Method %s not found', [MethodName]);

    Runner := TPropertyTestRunner.Create;
    try
      try
        Runner.RunPropertyTest(Method, TestInstance);
      except
        on E: TPropertyTestFailure do
          raise;
        on E: Exception do
          raise Exception.CreateFmt('Property test execution error: %s', [E.Message]);
      end;
    finally
      Runner.Free;
    end;
  finally
    Context.Free;
  end;
end;

class procedure THypothesis.Run(const TestInstance: TObject; const MethodName: string;
                               const Generators: array of IValueGenerator;
                               const Iterations: Integer);
var
  Context: TRttiContext;
  RttiType: TRttiType;
  Method: TRttiMethod;
  Runner: TPropertyTestRunner;
begin
  Context := TRttiContext.Create;
  try
    RttiType := Context.GetType(TestInstance.ClassType);
    Method := RttiType.GetMethod(MethodName);

    if Method = nil then
      raise Exception.CreateFmt('Method %s not found', [MethodName]);

    Runner := TPropertyTestRunner.Create;
    try
      try
        Runner.RunWithGenerators(Method, TestInstance, Generators, Iterations);
      except
        on E: TPropertyTestFailure do
          raise;
        on E: Exception do
          raise Exception.CreateFmt('Property test execution error: %s', [E.Message]);
      end;
    finally
      Runner.Free;
    end;
  finally
    Context.Free;
  end;
end;

// ===== ARRAY HELPERS =====

class function THypothesis.ArrayOfIntegers(const MinCount, MaxCount: Integer;
                                          const MinValue, MaxValue: Int64;
                                          const ExcludeZero: Boolean): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TIntegerGenerator.Create(MinValue, MaxValue, ExcludeZero);
  Result := TArrayGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(Int64));
end;

class function THypothesis.ArrayOfStrings(const MinCount, MaxCount: Integer;
                                         const MinLen, MaxLen: Integer;
                                         const CharSet: TStringCharSet): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TStringGenerator.Create(MinLen, MaxLen, CharSet);
  Result := TArrayGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(string));
end;

class function THypothesis.ArrayOfFloats(const MinCount, MaxCount: Integer;
                                        const MinValue, MaxValue: Double;
                                        const AllowNaN, AllowInfinity: Boolean): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TFloatGenerator.Create(MinValue, MaxValue, AllowNaN, AllowInfinity);
  Result := TArrayGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(Double));
end;

class function THypothesis.ArrayOfBooleans(const MinCount, MaxCount: Integer): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TBooleanGenerator.Create;
  Result := TArrayGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(Boolean));
end;

class function THypothesis.ArrayOf(const MinCount, MaxCount: Integer;
                                  const ElementGenerator: IValueGenerator;
                                  const ElementTypeInfo: PTypeInfo): IValueGenerator;
begin
  Result := TArrayGenerator.Create(MinCount, MaxCount, ElementGenerator, ElementTypeInfo);
end;

// ===== LIST HELPERS =====

class function THypothesis.ListOfIntegers(const MinCount, MaxCount: Integer;
                                         const MinValue, MaxValue: Int64;
                                         const ExcludeZero: Boolean): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TIntegerGenerator.Create(MinValue, MaxValue, ExcludeZero);
  Result := TListGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(Int64));
end;

class function THypothesis.ListOfStrings(const MinCount, MaxCount: Integer;
                                        const MinLen, MaxLen: Integer;
                                        const CharSet: TStringCharSet): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TStringGenerator.Create(MinLen, MaxLen, CharSet);
  Result := TListGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(string));
end;

class function THypothesis.ListOfFloats(const MinCount, MaxCount: Integer;
                                       const MinValue, MaxValue: Double;
                                       const AllowNaN, AllowInfinity: Boolean): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TFloatGenerator.Create(MinValue, MaxValue, AllowNaN, AllowInfinity);
  Result := TListGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(Double));
end;

class function THypothesis.ListOfBooleans(const MinCount, MaxCount: Integer): IValueGenerator;
begin
  const ElementGen: IValueGenerator = TBooleanGenerator.Create;
  Result := TListGenerator.Create(MinCount, MaxCount, ElementGen, TypeInfo(Boolean));
end;

class function THypothesis.ListOf(const MinCount, MaxCount: Integer;
                                 const ElementGenerator: IValueGenerator;
                                 const ElementTypeInfo: PTypeInfo): IValueGenerator;
begin
  Result := TListGenerator.Create(MinCount, MaxCount, ElementGenerator, ElementTypeInfo);
end;

// ===== DICTIONARY HELPERS =====

class function THypothesis.DictIntegerToString(const MinCount, MaxCount: Integer;
                                              const KeyMin, KeyMax: Int64;
                                              const ValueMinLen, ValueMaxLen: Integer;
                                              const ValueCharSet: TStringCharSet): IValueGenerator;
begin
  const KeyGen: IValueGenerator = TIntegerGenerator.Create(KeyMin, KeyMax, False);
  const ValueGen: IValueGenerator = TStringGenerator.Create(ValueMinLen, ValueMaxLen, ValueCharSet);
  Result := TDictionaryGenerator.Create(MinCount, MaxCount, KeyGen, ValueGen, TypeInfo(Int64), TypeInfo(string));
end;

class function THypothesis.DictStringToInteger(const MinCount, MaxCount: Integer;
                                              const KeyMinLen, KeyMaxLen: Integer;
                                              const KeyCharSet: TStringCharSet;
                                              const ValueMin, ValueMax: Int64): IValueGenerator;
begin
  const KeyGen: IValueGenerator = TStringGenerator.Create(KeyMinLen, KeyMaxLen, KeyCharSet);
  const ValueGen: IValueGenerator = TIntegerGenerator.Create(ValueMin, ValueMax, False);
  Result := TDictionaryGenerator.Create(MinCount, MaxCount, KeyGen, ValueGen, TypeInfo(string), TypeInfo(Int64));
end;

class function THypothesis.DictStringToString(const MinCount, MaxCount: Integer;
                                             const KeyMinLen, KeyMaxLen: Integer;
                                             const KeyCharSet: TStringCharSet;
                                             const ValueMinLen, ValueMaxLen: Integer;
                                             const ValueCharSet: TStringCharSet): IValueGenerator;
begin
  const KeyGen: IValueGenerator = TStringGenerator.Create(KeyMinLen, KeyMaxLen, KeyCharSet);
  const ValueGen: IValueGenerator = TStringGenerator.Create(ValueMinLen, ValueMaxLen, ValueCharSet);
  Result := TDictionaryGenerator.Create(MinCount, MaxCount, KeyGen, ValueGen, TypeInfo(string), TypeInfo(string));
end;

class function THypothesis.DictOf(const MinCount, MaxCount: Integer;
                                 const KeyGenerator, ValueGenerator: IValueGenerator;
                                 const KeyTypeInfo, ValueTypeInfo: PTypeInfo): IValueGenerator;
begin
  Result := TDictionaryGenerator.Create(MinCount, MaxCount, KeyGenerator, ValueGenerator, KeyTypeInfo, ValueTypeInfo);
end;

end.
