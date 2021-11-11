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
    [unsafe]
    FConnection: IConnectorDB;
    function GetSQLBuilder: ISQL<T>;
    //
    procedure DoExecDML(_ADMLOperation: TDMLOperation; out _ADMLCommand: String); override;
    //
  public
    //IDBEntity
    function Connection: IConnectorDB;
    function WithConnection(_AConnection: IConnectorDB): TDBEntity<T>;
    function SetupDefaultConection: TDBEntity<T>; virtual; abstract;
  end;

implementation

uses
  System.SysUtils;

{ TDBEntity<T> }

function TDBEntity<T>.Connection: IConnectorDB;
begin
  Result := FConnection
end;

procedure TDBEntity<T>.DoExecDML(_ADMLOperation: TDMLOperation; out _ADMLCommand: String);
var
  aSQLStatment : string;
begin
  inherited;
  if not Assigned(FConnection) then
    raise Exception.Create('Connection was not assigned!');
  try
    //aSQLStatment := GetSQLBuilder.GetDML(_ADMLOperation);
    aSQLStatment := 'Select * from teste';
    //TSQLGeneric<T>.New(aDTO).GetDML(_ADMLOperation);

    FConnection
      .StartTransaction
      .ExecSQL(aSQLStatment)
      .Commit;
    _ADMLCommand := aSQLStatment;
  except
    FConnection.Rollback;
    raise;
  end;
end;

function TDBEntity<T>.GetSQLBuilder: ISQL<T>;
begin
  Result := TSQLGeneric<T>.New(FDTO);
end;

function TDBEntity<T>.WithConnection(_AConnection: IConnectorDB): TDBEntity<T>;
begin
  FConnection := _AConnection;
  Result := Self;
end;

end.
