unit mvcEntity;

interface

uses
  mvcDAO.Generic,
  mvcDAO.Interfaces,
  mvcDAO.Types,
  mvcEntity.Interfaces,
  mvcEntity.DTO.Interfaces,
  mvcEntity.Types;

type
  TEntity<T: class, constructor, IDTO> = class(TInterfacedObject, IEntity<T>)
  private
   var
    FOnAfterDML: TAfterDMLProc;
    FEntityListActions: IEntityList<T>;
    procedure DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
    procedure ExecuteDML(_ADMLOperation: TDMLOperation);
  protected
    FDTO: T;
    //
    function GetSQLBuilder: ISQL<T>;
    //
    procedure DoExecDML(_AOperation: TDMLOperation); virtual;
    //
    property OnAfterDML: TAfterDMLProc read FOnAfterDML write FOnAfterDML;
  public
    constructor Create;
    //
    function LoadFrom(_AEntityData: T): IEntity<T>;
    //
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
  if not Assigned(FDTO) then
    FDTO := T.Create;

  Result := FDTO;
end;

procedure TEntity<T>.ExecuteDML(_ADMLOperation: TDMLOperation);
var
  aSQLStatment : string;
begin
  try
    DoExecDML(_ADMLOperation);
    DoAfterDML(_ADMLOperation, aSQLStatment);
  except
    raise;
  end;
end;

function TEntity<T>.GetSQLBuilder: ISQL<T>;
begin
  Result := TSQLGeneric<T>.New(FDTO);
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
  FDTO:= _AEntityData;
  Result := Self;
end;

procedure TEntity<T>.DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
begin
  if Assigned(FOnAfterDML) then
    FOnAfterDML(_AOperation, _SQLStatment);
end;

procedure TEntity<T>.DoExecDML(_AOperation: TDMLOperation);
begin
//
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
