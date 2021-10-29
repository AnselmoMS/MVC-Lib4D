unit mvcDAO.RTTI.StringUtils;

interface

function ArrayStringToStrig(_array: array of string; _delimiter: char = ','): string;
function GetFieldsdValuesUpdate(_arrayFields, _arrayValues: array of string): string;


implementation

uses
  System.SysUtils;

function ArrayStringToStrig(_array: array of string; _delimiter: char = ','): string;
var
  i : Integer;
begin
  Result := '';
  for i := low(_array) to high(_array) do
  begin
    Result := Result + _array[i];
    if i < High(_array) then
      Result := Result + _delimiter
  end;
end;

function GetFieldsdValuesUpdate(_arrayFields, _arrayValues: array of string): string;
var
  i : Integer;
begin
  if Length(_arrayFields) <> Length(_arrayValues) then
    raise Exception.Create('Número de campos e valoes difere');

  Result := '';

  for i := low(_arrayFields) to high(_arrayFields) do
  begin
    Result := Result + _arrayFields[i] + '=' + _arrayValues[i];
    if i < High(_arrayFields) then
      Result := Result + ','
  end;
end;

end.
