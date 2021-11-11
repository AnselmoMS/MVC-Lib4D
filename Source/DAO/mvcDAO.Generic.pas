unit mvcDAO.Generic;

interface

uses
  mvcdao.Interfaces,
  System.SysUtils,
  mvcDAO.Types;

type
  TSQLGeneric<T : class, constructor> = class(TInterfacedObject, ISQL<T>)
   private
    [unsafe]
    FEntity : T;
   public
    constructor Create(_AEntity: T);
    destructor Destroy; override;
    class function New(_AEntity: T) : ISQL<T>;
    function Entity : T;
    function GetDML(_Operation: TDMLOperation): string;
  end;

implementation

uses
  mvcDAO.RTTI;

{ TDAOGeneric<T> }

constructor TSQLGeneric<T>.Create(_AEntity: T);
begin
  FEntity := _AEntity
end;

destructor TSQLGeneric<T>.Destroy;
begin
  inherited;
end;

function TSQLGeneric<T>.Entity: T;
begin
  Result := FEntity
end;

function TSQLGeneric<T>.GetDML(_Operation: TDMLOperation): string;
begin
  case _Operation of
    dmlInsert: Result := TSQLRTTI.GetInsertSQL<T>(FEntity);
    dmlUpdate: Result := TSQLRTTI.GetUpdateSQL<T>(FEntity);
    dmlDelete: Result := TSQLRTTI.GetDeleteSQL<T>(FEntity);
  end;
end;

class function TSQLGeneric<T>.New(_AEntity: T): ISQL<T>;
begin
  Result := Self.Create(_AEntity);
end;

end.
