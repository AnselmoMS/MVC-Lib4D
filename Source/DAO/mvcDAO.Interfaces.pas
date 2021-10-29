unit mvcDAO.Interfaces;

interface

uses
  System.SysUtils,
  mvcDAO.RTTI.Types,
  mvcDAO.Types;

type
  ISQL<T : class> = interface
  ['{87D2131F-D09F-4447-8CD1-D716E8376562}']
    function GetDML(_Operation: TDMLOperation): string;
    function Entity : T;
  end;

  ISQLAdapter<T : class> = interface
    ['{C6C76AC9-12D1-4933-9628-28DDF0F0AE84}']
    function GetFieldNames(AtrributeClass: TCustomAttributeClass = nil): TArray<string>;
    function GetFieldValues(AtrributeClass: TCustomAttributeClass = nil): TArray<string>;
    function GetKeyFieldNames: TArray<string>;
    function GetKeyFieldValues: TArray<string>;
    function GetTableName: String;
  end;

implementation

end.
