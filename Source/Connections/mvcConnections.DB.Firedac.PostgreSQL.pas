unit mvcConnections.DB.Firedac.PostgreSQL;

interface

uses
  mvcConnections.Interfaces,
  System.SysUtils,
  System.Classes,
  //
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Phys.PG,
  Data.DB,
  FireDAC.Comp.Client,
  mvcLogger.Interfaces,
  mvcConnections.DB.DatabaseParams;

type
  TConnectorDBFiredacPostgreSQL = class(TInterfacedObject, IConnectorDB)
    private
      class var FInstance: IConnectorDB;
      class var FDConnection: TFDConnection;
      class var PgDriverLink: TFDPhysPgDriverLink;
      class var FDGUIxWaitCursor: TFDGUIxWaitCursor;
      //class var AsyncExecuteDialog: TFDGUIxAsyncExecuteDialog;
      class procedure FreeObjects;
      class procedure CreateObjects;
      class procedure ConfigureObjects;
      procedure DoAfterExecSQL(_SQL: string);
      //constructor Create;
    protected
      [weak]
      FLogger: ILogger; { TODO -oansel -c : Move to base class 17/10/2021 00:27:27 }
    public
      destructor Destroy; override;
      //
      class function NewInstance: TObject; override;
      class function GetInstance: IConnectorDB;
      function Commit: IConnectorDB;
      function Component: TComponent;
      function ExecSQL(_SQL: String): IConnectorDB;
      function InTransaction: Boolean;
      function DisConnect: IConnectorDB;
      function Connect: IConnectorDB;
      function Rollback: IConnectorDB;
      function StartTransaction: IConnectorDB;
      function WithComponent(_AComponent: TComponent): IConnectorDB;
      function WithDataBaseParams(_ADatabaseParams: TDatabaseParams): IConnectorDB;
      function WithLogger(_ALogger: ILogger): IConnectorDB;
  end;

implementation

{ TConnectorDBPostgreSQL }

function TConnectorDBFiredacPostgreSQL.Commit: IConnectorDB;
begin
  FDConnection.Commit;
  Result := Self;
end;

function TConnectorDBFiredacPostgreSQL.Component: TComponent;
begin
  Result := FDConnection
end;

class procedure TConnectorDBFiredacPostgreSQL.ConfigureObjects;
begin
  PgDriverLink.VendorLib := 'libpq.dll' ;//GetCurrentDir + '\pglib\libpq.dll'; { TODO -oansel -c : Load From Ini File 15/10/2021 22:11:14 }
  //
  FDGUIxWaitCursor.Name := 'FDGUIxWaitCursor';
  FDGUIxWaitCursor.Provider := 'Forms';
  //
  {
  AsyncExecuteDialog.Name := 'AsyncExecuteDialog';
  AsyncExecuteDialog.Provider := 'Forms';
  AsyncExecuteDialog.Caption := 'CM Application Test';
  AsyncExecuteDialog.Prompt := 'Aguarde enquanto carregamos os dados...';
  }
  //
  FDConnection.Params.Clear;
  FDConnection.Params.Add('DriverID=PG');
  FDConnection.Params.Add('ApplicationName=Application - Test');

  FDConnection.LoginPrompt := True;
end;

function TConnectorDBFiredacPostgreSQL.Connect: IConnectorDB;
begin
  FDConnection.Connected := True;
  Result := Self;
end;

class procedure TConnectorDBFiredacPostgreSQL.CreateObjects;
begin
  PgDriverLink := TFDPhysPgDriverLink.Create(nil);
  FDGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);
  //AsyncExecuteDialog := TFDGUIxAsyncExecuteDialog.Create(nil);
  FDConnection := TFDConnection.Create(nil);
end;

destructor TConnectorDBFiredacPostgreSQL.Destroy;
begin
  FreeObjects;
  inherited;
end;

function TConnectorDBFiredacPostgreSQL.DisConnect: IConnectorDB;
begin
  FDConnection.Connected := False;
  Result := Self;
end;

procedure TConnectorDBFiredacPostgreSQL.DoAfterExecSQL(_SQL: string);
begin
  if Assigned(FLogger) and not _SQL.StartsWith('INSERT INTO') then  //improve operation detection and make configurable
    FLogger.AddLog(FormatDateTime('dd/mm/YYYY HH:MM:SS ', Now()) + ' >> ' + _SQL);
end;

function TConnectorDBFiredacPostgreSQL.ExecSQL(_SQL: String): IConnectorDB;
begin
  FDConnection.ExecSQL(_SQL);
  DoAfterExecSQL(_SQL);
  Result := Self;
end;

class procedure TConnectorDBFiredacPostgreSQL.FreeObjects;
begin
  FreeAndNil(FDConnection);
  FreeAndNil(PgDriverLink);
  FreeAndNil(FDGUIxWaitCursor);
//  AsyncExecuteDialog.Free;
end;

class function TConnectorDBFiredacPostgreSQL.GetInstance: IConnectorDB;
begin
  if not Assigned(FInstance) then
    FInstance := TConnectorDBFiredacPostgreSQL(NewInstance);
  Result := FInstance;
end;

function TConnectorDBFiredacPostgreSQL.InTransaction: Boolean;
begin
  Result := FDConnection.InTransaction
end;

class function TConnectorDBFiredacPostgreSQL.NewInstance: TObject;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TConnectorDBFiredacPostgreSQL(inherited NewInstance);
    ConfigureObjects;
  end;
  Result := TObject(FInstance);
end;

function TConnectorDBFiredacPostgreSQL.Rollback: IConnectorDB;
begin
  FDConnection.Rollback;
  Result := Self
end;

function TConnectorDBFiredacPostgreSQL.StartTransaction: IConnectorDB;
begin
  FDConnection.StartTransaction;
  Result := Self;
end;

function TConnectorDBFiredacPostgreSQL.WithComponent(_AComponent: TComponent): IConnectorDB;
begin
  FDConnection := TFDConnection(_AComponent);
  Result := Self;
end;

function TConnectorDBFiredacPostgreSQL.WithDataBaseParams(_ADatabaseParams: TDatabaseParams): IConnectorDB;
begin
  DisConnect;
  FDConnection.Params.Add('Database=' + _ADatabaseParams.DatabaseName);
  FDConnection.Params.Add('Password=' + _ADatabaseParams.UserPass);
  FDConnection.Params.Add('Server=localhost');
  FDConnection.Params.Add('User_Name='+_ADatabaseParams.UserName);
  Connect;
  Result := Self;
end;

function TConnectorDBFiredacPostgreSQL.WithLogger(_ALogger: ILogger): IConnectorDB;
begin
  FLogger := _ALogger;
  Result := Self;
end;

initialization
  TConnectorDBFiredacPostgreSQL.CreateObjects;
finalization
  TConnectorDBFiredacPostgreSQL.FreeObjects;

end.
