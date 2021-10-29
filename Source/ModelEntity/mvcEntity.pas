unit mvcEntity;

interface

uses
  mvcConnections.Interfaces,
  mvcDAO.Generic,
  mvcDAO.Interfaces,
  mvcDAO.Types,
  mvcEntity.Interfaces,
  mvcLogger.Interfaces,
  mvcEntity.DTO.Interfaces;

type
  TEntity<T: class, constructor, IDTO> = class(TInterfacedObject, IEntity<T>)
  private
   const
    DML_TO_LOG = [dmlUpdate, dmlDelete];
   var
    FEntityListActions: IEntityList<T>;
    //
    function GetSQLBuilder: ISQL<T>;
    procedure DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
    procedure ExecuteDML(_ADMLOperation: TDMLOperation);
  protected
    FConnection: IConnectorDB;
    FLogger: ILogger;
    FData: T;
  public
    constructor Create;
    function LoadFrom(_AEntityData: T): IEntity<T>;
    class function New: IEntity<T>;
    //
    function Delete: IEntity<T>;
    function EntityData: T;
    function Insert:IEntity<T>;
    function ListActions: IEntityList<T>;
    function Update: IEntity<T>;
    function WithListActions(_AEntityListActions: IEntityList<T>): IEntity<T>;
  end;

implementation

uses
  System.SysUtils,
  mvcEntity.List;

{ TEntity<T> }

constructor TEntity<T>.Create;
begin
//
end;

function TEntity<T>.Delete: IEntity<T>;
begin
  ExecuteDML(dmlDelete);
  Result := Self;
end;

function TEntity<T>.EntityData: T;
begin
  if not Assigned(FData) then
    FData := T.Create;

  Result := FData;
end;

procedure TEntity<T>.ExecuteDML(_ADMLOperation: TDMLOperation);
var
  aSQLStatment : string;
begin
  try
    if not Assigned(FConnection) then
      raise Exception.Create('Connection was not assigned!');
    //
    FConnection.StartTransaction;
    aSQLStatment := GetSQLBuilder.GetDML(_ADMLOperation);
    FConnection.ExecSQL(aSQLStatment);
    FConnection.Commit;
    //
    DoAfterDML(_ADMLOperation, aSQLStatment);
  except
    FConnection.Rollback;
    raise;
  end;
end;

function TEntity<T>.GetSQLBuilder: ISQL<T>;
begin
  Result := TSQLGeneric<T>.New(FData);
end;

function TEntity<T>.Insert: IEntity<T>;
begin
  ExecuteDML(dmlInsert);
  Result := Self;
end;

function TEntity<T>.ListActions: IEntityList<T>;
begin
  Result := FEntityListActions;
end;

function TEntity<T>.LoadFrom(_AEntityData: T): IEntity<T>;
begin
  FData:= _AEntityData;
  Result := Self;
end;

procedure TEntity<T>.DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
begin
  if Assigned(FLogger) then
    if _AOperation in DML_TO_LOG then
      FLogger.AddLog(DML_OPERATION_DESC[_AOperation] + ' >> ' + _SQLStatment)
end;

class function TEntity<T>.New: IEntity<T>;
begin
  Result := Self.Create
end;

function TEntity<T>.Update: IEntity<T>;
begin
  ExecuteDML(dmlUpdate);
  Result := Self
end;

function TEntity<T>.WithListActions(_AEntityListActions: IEntityList<T>): IEntity<T>;
begin
  FEntityListActions := _AEntityListActions;
  Result := Self;
end;

end.
