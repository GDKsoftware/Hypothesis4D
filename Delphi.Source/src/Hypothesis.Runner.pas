unit Hypothesis.Runner;

interface

uses
  System.SysUtils,
  System.Rtti,
  Hypothesis.Core;

type
  THypothesis = class
  public
    class procedure Run(const TestInstance: TObject; const MethodName: string);
  end;

implementation

uses
  Hypothesis.Attributes,
  Hypothesis.Exceptions;

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

end.
