unit mvcDAO.RTTI;

interface

uses
  System.RTTI,
  System.SysUtils,
  mvcDAO.Interfaces;

type
  TSQLRTTI = class
    public
      class function GetInsertSQL<T : class> ( aEntity : T ) : String;
      class function GetDeleteSQL<T : class> ( aEntity : T ) : String;
      class function GetUpdateSQL<T : class> ( aEntity : T ) : String;
  end;

implementation

uses
  mvcDAO.RTTI.Adapter,
  mvcDAO.RTTI.StringUtils,
  mvcDAO.RTTI.Types;

{ TDAORTTI }

class function TSQLRTTI.GetDeleteSQL<T>(aEntity: T): String;
var
  FDaoFinder: ISQLAdapter<T>;
begin
  FDaoFinder := TSQLAdapter<T>.Create(aEntity);
  Result := Format('DELETE FROM %s WHERE %s = %s', [FDaoFinder.GetTableName, ArrayStringToStrig(FDaoFinder.GetKeyFieldNames), ArrayStringToStrig(FDaoFinder.GetKeyFieldValues)]);
end;

class function TSQLRTTI.GetInsertSQL<T>( aEntity : T): String;
var
  FDaoFinder: ISQLAdapter<T>;
begin
  FDaoFinder := TSQLAdapter<T>.Create(aEntity);
  Result := Format('INSERT INTO %s (%s) VALUES (%s)', [FDaoFinder.GetTableName, ArrayStringToStrig(FDaoFinder.GetFieldNames), ArrayStringToStrig(FDaoFinder.GetFieldValues)]);
end;

class function TSQLRTTI.GetUpdateSQL<T>(aEntity: T): String;
var
  FDaoFinder: ISQLAdapter<T>;
begin
  FDaoFinder := TSQLAdapter<T>.Create(aEntity);
  Result := Format('UPDATE %s SET %s WHERE %s = %s', [FDaoFinder.GetTableName,
                                                      GetFieldsdValuesUpdate(FDaoFinder.GetFieldNames(UpdateField), FDaoFinder.GetFieldValues(UpdateField)),
                                                      ArrayStringToStrig(FDaoFinder.GetKeyFieldNames),
                                                      ArrayStringToStrig(FDaoFinder.GetKeyFieldValues)]);
end;

end.
