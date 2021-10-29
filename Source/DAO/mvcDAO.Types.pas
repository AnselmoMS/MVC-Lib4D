unit mvcDAO.Types;

interface

type
  TDMLOperation = (dmlInsert, dmlUpdate, dmlDelete);
  TDMLOperationSet = set of TDMLOperation;
  TDMLProc = reference to procedure(_ADMLOperation: TDMLOperation; _SQLStatment: String);

const
  DML_OPERATION_DESC : array [TDMLOperation] of string =
    ('INSERT', 'UPDATE', 'DELETE');

implementation

end.
