unit mvcDBEntity;

interface

uses
  mvcConnections.Interfaces,
  mvcDAO.Generic,
  mvcDAO.Interfaces,
  mvcDAO.Types,
  mvcEntity.Interfaces,
  mvcEntity,
  mvcEntity.DTO.Interfaces;

type
  TDBEntity<T: class, constructor, IDTO> = class(TEntity<T>, IDBEntity<TDBEntity<T>>)
  protected
    FConnection: IConnectorDB;
    procedure DoExecDML(_ADMLOperation: TDMLOperation); override;
  public
    function WithConnection(_AConnection: IConnectorDB): TDBEntity<T>;
  end;

implementation

uses
  System.SysUtils,
  mvcEntity.List;

{ TDBEntity<T> }

procedure TDBEntity<T>.DoExecDML(_ADMLOperation: TDMLOperation);
var
  aSQLStatment : string;
begin
  inherited;
  try
    if not Assigned(FConnection) then
      raise Exception.Create('Connection was not assigned!');
    //
    FConnection.StartTransaction;
    aSQLStatment := GetSQLBuilder.GetDML(_ADMLOperation);
    FConnection.ExecSQL(aSQLStatment);
    FConnection.Commit;
  except
    FConnection.Rollback;
    raise;
  end;
end;

function TDBEntity<T>.WithConnection(_AConnection: IConnectorDB): TDBEntity<T>;
begin
  FConnection := _AConnection;
  Result := Self;
end;

end.
