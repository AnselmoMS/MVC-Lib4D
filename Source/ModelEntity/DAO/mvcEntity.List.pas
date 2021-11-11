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
  mvcEntity.DTO.Interfaces;

type
  TEntityList<T: class, constructor, IDTO> = class(TInterfacedObject, IEntityList<T>)
  protected
  var
    FList: TList<T>;
    procedure DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
    procedure DoAfterSelect; virtual;
    procedure DoSelectAll; virtual;
    procedure ExecuteDMLToList(_Operation: TDMLOperation; out DMLCommands: array of String); overload; virtual;
    procedure ExecuteDMLToList(_Operation: TDMLOperation); overload;
  public
    constructor Create; virtual;
    //
    function DeleteAll: IEntityList<T>;
    function GetDataList: TList<T>;
    function InsertAll: IEntityList<T>;
    function LoadFromList(_SourceList: TList<T>): IEntityList<T>;
    function SelectAll: IEntityList<T>;
    function UpdateAll: IEntityList<T>;
  end;

implementation

constructor TEntityList<T>.Create;
begin
  FList := TList<T>.Create;
end;

function TEntityList<T>.DeleteAll: IEntityList<T>;
begin
  ExecuteDMLToList(dmlDelete);
  Result := Self;
end;

procedure TEntityList<T>.DoAfterDML(_AOperation: TDMLOperation; _SQLStatment: String);
begin
  //
end;

procedure TEntityList<T>.DoAfterSelect;
begin
//
end;

procedure TEntityList<T>.DoSelectAll;
begin
//
end;

procedure TEntityList<T>.ExecuteDMLToList(_Operation: TDMLOperation);
var
  sDMLCommands: array of string;
begin
  ExecuteDMLToList(_Operation, sDMLCommands);
end;

procedure TEntityList<T>.ExecuteDMLToList(_Operation: TDMLOperation; out DMLCommands: array of String);
begin
//
end;

function TEntityList<T>.GetDataList: TList<T>;
begin
  Result := TList<T>.Create;
  Result.AddRange(FList.ToArray);
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

function TEntityList<T>.SelectAll: IEntityList<T>;
begin
  inherited;
  DoSelectAll;
  DoAfterSelect;
  Result := Self;
end;

function TEntityList<T>.UpdateAll: IEntityList<T>;
begin
  ExecuteDMLToList(dmlUpdate);
  Result := Self;
end;

end.
