unit mvcEntity.Types;

interface

uses
  mvcDAO.Types;

type
  TDMLProc = procedure(_ADMLOperation: TDMLOperation) of object;
  TAfterDMLProc = procedure(_AOperation: TDMLOperation; _SQLStatment: String) of object;

implementation

end.
