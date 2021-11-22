unit mvcLogger;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  System.Classes,
  mvcLogger.Interfaces;

type
  TLogger = class(TInterfacedObject, ILogger)
  var
    class var FInstance: ILogger;
  public
    class function NewInstance: TObject; override;
    class function GetInstance: ILogger;
    procedure AddLog(_ALog: string);
  end;

  TLoggerThread = class(TThread)
  private
    { Private declarations }
    FCriticalSection: TCriticalSection;
    FEvent: TEvent;
    FLogCacheList: TList<string>;
  protected
    procedure Execute; override;
    function ExtractLog: TArray<string>;
    procedure SaveLogCacheToFile;
    class function GeUniquetInstance: TLoggerThread; static;
  public
    procedure AddLog(ALog: string);
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class property GetDefault: TLoggerThread read GeUniquetInstance;
  end;

implementation

uses
  System.SysUtils;

var
  FLogger: TLoggerThread;

  { TLogger }

procedure TLoggerThread.AddLog(ALog: string);
begin
  FCriticalSection.Enter;
  try
    FLogCacheList.Add(ALog);
  finally
    FCriticalSection.Leave;
  end;
  FEvent.SetEvent;
end;

procedure TLoggerThread.AfterConstruction;
begin
  inherited;
  FLogCacheList := TList<string>.Create;
  FCriticalSection := TCriticalSection.Create;
  FEvent := TEvent.Create;
end;

procedure TLoggerThread.BeforeDestruction;
begin
  inherited;
  FLogCacheList.Free;
  FCriticalSection.Free;
  FEvent.Free;
end;

procedure TLoggerThread.Execute;
var
  LWaitResult: TWaitResult;
begin
  while not Self.Terminated do
  begin
    LWaitResult := FEvent.WaitFor(INFINITE);
    FEvent.ResetEvent;
    if LWaitResult = wrSignaled then
      SaveLogCacheToFile;
  end;
end;

function TLoggerThread.ExtractLog: TArray<string>;
begin
  FCriticalSection.Enter;
  try
    Result := FLogCacheList.ToArray;
  finally
    FCriticalSection.Leave;
  end;
  FLogCacheList.Clear;
end;

class function TLoggerThread.GeUniquetInstance: TLoggerThread;
begin
  if FLogger = nil then
  begin
    FLogger := TLoggerThread.Create;
    FLogger.FreeOnTerminate := True;
    //FLogger.Priority := TThreadPriority.tpLowest;  Baixa prioridade (Somente Windows)
  end;
  Result := FLogger;
end;

procedure TLoggerThread.SaveLogCacheToFile;
var
  LFilename: string;
  LTextFile: TextFile;
  LLogCache: TArray<string>;
  I: Integer;
begin
  LLogCache := ExtractLog;
  if Length(LLogCache) > 0 then
  begin
    LFilename := 'Log_' + FormatDateTime('yyyy-mm-dd', Now()) + '.log';
    AssignFile(LTextFile, LFilename);

    if FileExists(LFilename) then
      Append(LTextFile)
    else
      Rewrite(LTextFile);
    try
      for I := Low(LLogCache) to High(LLogCache) do
        Writeln(LTextFile, LLogCache[I]);
    finally
      CloseFile(LTextFile);
    end;
  end;
end;

class function TLogger.GetInstance: ILogger;
begin
  if not Assigned(FInstance) then
    FInstance := Self.Create;
  Result := FInstance;
end;

class function TLogger.NewInstance: TObject;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TLogger(inherited NewInstance);
  end;

  Result := TObject(FInstance);
end;

{ TLogger }

procedure TLogger.AddLog(_ALog: string);
begin
  TLoggerThread.GetDefault.AddLog(_ALog)
end;

initialization
  //TLoggerThread.GetDefault;

finalization
  FLogger.Terminate;
  FreeAndNil(FLogger);


end.
