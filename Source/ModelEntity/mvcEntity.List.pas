unit mvcEntity.List;

interface

uses
  Data.DB,
  System.Generics.Collections,
  mvcEntity.Interfaces,
  mvcDAO.Types,
  mvcDAO.Interfaces,
  mvcConnections.Interfaces,
  mvcLogger.Interfaces,
  mvcEntity,
  mvcEntity.List.DataModule,
  mvcEntity.DTO.Interfaces;

type
  TEntityList<T: class, constructor, IDTO> = class(TInterfacedObject, IEntityList<T>)
  private
    const
      DML_TO_LOG = [dmlUpdate, dmlDelete];
    var
    procedure ExecuteDMLToList(_Operation: TDMLOperation);
  protected
  var
    FDMEntityQuery: TdmEntityQuery;
    FList: TList<T>;
    FConnection: IConnectorDB;
    FLogger: ILogger;
    function GetSQLBuilder(_AItem: T): ISQL<T>;
    function GetEntityName: string; virtual; abstract;
    procedure DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
    procedure DoAfterSelect;
    procedure LoadListFromDataSetResult;
  public
    constructor Create;
    //
    function DeleteAll: IEntityList<T>;
    function GetDataList: TList<T>;
    function GetDataSet: TDataSet;
    function GetDataSource: TDataSource;
    function InsertAll: IEntityList<T>;
    function LoadFromList(_SourceList: TList<T>): IEntityList<T>;
    function SelectAll: IEntityList<T>;
    function UpdateAll: IEntityList<T>;
  end;

implementation

uses
  System.SysUtils,
  mvcDAO.Generic,
  Winapi.Windows,
  System.JSON,
  REST.Json;

constructor TEntityList<T>.Create;
begin
  FList := TList<T>.Create;

  FDMEntityQuery := TdmEntityQuery.Create(nil);
end;

function TEntityList<T>.DeleteAll: IEntityList<T>;
begin
  ExecuteDMLToList(dmlDelete);
  Result := Self;
end;

procedure TEntityList<T>.DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
begin
  if Assigned(FLogger) then
    if _AOperation in DML_TO_LOG then
      FLogger.AddLog(DML_OPERATION_DESC[_AOperation] + ' >> ' + _SQLStatment);

  OutputDebugString(PChar(_SQLStatment));
end;

procedure TEntityList<T>.DoAfterSelect;
begin
  LoadListFromDataSetResult
end;

procedure TEntityList<T>.ExecuteDMLToList(_Operation: TDMLOperation);
var
  aSQLStatment : string;
  aItem: T;
  aEntityItem: IEntity<T>;
begin
  try
    if not Assigned(FConnection) then
      raise Exception.Create('Connection was not assigned!');

    FConnection.StartTransaction;

    aEntityItem := TEntity<T>.New;
    for aItem in FList do
    begin
      aEntityItem.LoadFrom(aItem);
      aSQLStatment := GetSQLBuilder(aItem).GetDML(_Operation);

      FConnection.ExecSQL(aSQLStatment);
    end;

    FConnection.Commit;
  except
    FConnection.Rollback;
    raise;
  end;
end;

function TEntityList<T>.GetDataList: TList<T>;
begin
  Result := TList<T>.Create;
  Result.AddRange(FList.ToArray);
end;

function TEntityList<T>.GetDataSet: TDataSet;
begin
  Result := FDMEntityQuery.GetDataSet
end;

function TEntityList<T>.GetDataSource: TDataSource;
begin
  Result := FDMEntityQuery.GetDataSource
end;

function TEntityList<T>.GetSQLBuilder(_AItem: T): ISQL<T>;
begin
  Result := TSQLGeneric<T>.New(_AItem);
end;

function TEntityList<T>.InsertAll: IEntityList<T>;
begin
  ExecuteDMLToList(dmlInsert);
  Result := Self;
end;

function TEntityList<T>.LoadFromList(_SourceList: TList<T>): IEntityList<T>;
begin
  FList.Clear;
  FList.AddRange(_SourceList.ToArray);
  Result := Self;
end;

procedure TEntityList<T>.LoadListFromDataSetResult;
var
  jsArray: TJSONArray;
  jsItem: TJsonValue;
  aItem: T;
begin
  FList.Clear;
  if FDMEntityQuery.GetDataSet.RecordCount = 0 then
    Exit;

  jsArray := FDMEntityQuery.GetDataSetAsJson;

  for jsItem in jsArray do
  begin
    aItem := TJson.JsonToObject<T>(jsItem.ToJSON);
    FList.Add(aItem);
  end;
end;

function TEntityList<T>.SelectAll: IEntityList<T>;
begin
  FDMEntityQuery.SetConnection(FConnection.Component);
  FDMEntityQuery.CloseQuery;
  FDMEntityQuery.EntityName := GetEntityName;
  FDMEntityQuery.OpenQuery;
  //OutputDebugString(Pchar(GetDataSet.RecordCount));
  DoAfterSelect;
  Result := Self;
end;

function TEntityList<T>.UpdateAll: IEntityList<T>;
begin
  ExecuteDMLToList(dmlUpdate);
  Result := Self;
end;

end.
