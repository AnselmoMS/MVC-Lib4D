unit mvcDBEntity.List;

interface

uses
 mvcEntity.DTO.Interfaces,
 mvcDAO.Interfaces,
 mvcConnections.Interfaces,
 mvcDAO.Types,
 mvcEntity.Interfaces,
 mvcEntity.List,
 mvcEntity.List.DataModule,
 Data.DB;

type
  TDBEntityList<T: class, constructor, IDTO> = class(TEntityList<T>, IDBEntity<TDBEntityList<T>>, IEBEntityList)
    private
      //
    protected
    var
      FConnection: IConnectorDB;
      FDMEntityQuery: TdmEntityQuery;
      //
      procedure DoSelectAll; override;
      procedure DoAfterSelect; override;
      function GetSQLBuilder(_AItem: T): ISQL<T>;
      procedure DoExecDML(_ADMLOperation: TDMLOperation; out _ADMLCommand: String); virtual;
      procedure LoadListFromDataSetResult;
      procedure ExecuteDMLToList(_Operation: TDMLOperation; out DMLCommands: array of String); override;
    public
      constructor Create; override;
      // IDBEntity
      function Connection: IConnectorDB;
      function WithConnection(_AConnection: IConnectorDB): TDBEntityList<T>;
      function SetupDefaultConection: TDBEntityList<T>; virtual; abstract;
      // IDBEntityList
      function GetDataSet: TDataSet;
      function GetDataSource: TDataSource;
      class function New: TDBEntityList<T>;
  end;

implementation

uses
  mvcDAO.Generic,
  System.SysUtils, mvcEntity,
  System.JSON,
  REST.Json;

{ TDBEntityList<T> }

function TDBEntityList<T>.Connection: IConnectorDB;
begin
  Result := FConnection
end;

constructor TDBEntityList<T>.Create;
begin
  inherited;
  FDMEntityQuery := TdmEntityQuery.Create(nil);
end;

procedure TDBEntityList<T>.DoAfterSelect;
begin
  inherited;
  LoadListFromDataSetResult
end;

procedure TDBEntityList<T>.DoExecDML(_ADMLOperation: TDMLOperation; out _ADMLCommand: String);
begin
  FDMEntityQuery.SetConnection(FConnection.Component);
  FDMEntityQuery.CloseQuery;
  FDMEntityQuery.EntityName := '[TableName]';
  FDMEntityQuery.OpenQuery;
end;

procedure TDBEntityList<T>.DoSelectAll;
begin
  inherited;
end;

procedure TDBEntityList<T>.ExecuteDMLToList(_Operation: TDMLOperation; out DMLCommands: array of String);
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

function TDBEntityList<T>.GetDataSet: TDataSet;
begin
  Result := FDMEntityQuery.GetDataSet
end;

function TDBEntityList<T>.GetDataSource: TDataSource;
begin
  Result := FDMEntityQuery.GetDataSource
end;

function TDBEntityList<T>.GetSQLBuilder(_AItem: T): ISQL<T>;
begin
  Result := TSQLGeneric<T>.New(_AItem);
end;

procedure TDBEntityList<T>.LoadListFromDataSetResult;
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

class function TDBEntityList<T>.New: TDBEntityList<T>;
begin
  Result := Self.Create
end;

function TDBEntityList<T>.WithConnection(_AConnection: IConnectorDB): TDBEntityList<T>;
begin
  FConnection := _AConnection;
  Result := Self;
end;

end.
