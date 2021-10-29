unit mvcConnections.Interfaces;

interface

uses
  System.JSON,
  System.SysUtils,
  System.Classes,
  mvcLogger.Interfaces,
  mvcConnections.DB.DatabaseParams;

type
  IConnector = interface {Rest, DataBase, ...}
  ['{94C2072D-AE4D-43EE-8A34-F31E602D9643}']
  end;

  IConnectorDB = interface(IConnector)
  ['{6081AF0F-0068-4C93-AF3C-D943D72C99D5}']
  function Commit: IConnectorDB;
  function Component: TComponent;
  function Connect: IConnectorDB;
  function DisConnect: IConnectorDB;
  function ExecSQL(_SQL: string): IConnectorDB;
  function InTransaction: Boolean;
  function Rollback: IConnectorDB;
  function StartTransaction: IConnectorDB;
  function WithComponent(_AComponent: TComponent): IConnectorDB;
  function WithLogger(_ALogger: ILogger): IConnectorDB;
  function WithDataBaseParams(_ADatabaseParams: TDatabaseParams): IConnectorDB;
  end;

implementation

end.
