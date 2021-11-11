unit mvcValidator.Text.Properties.OnlyNumber;

interface

uses
  mvcValidator.Interfaces,
  mvcValidator.Text.Properties;

type
  TValidatorTextPropertiesOnlyNumber = class(TValidatorTextProperties)
  private
    var
    FMaxValue,
    FMinValue: Integer;
  protected
    function GetDefaultErrorMessage: String; override;
  public
    function Validate: IValidatorTextProperties; override;
    function Range(_AMinValue, _AMaxValue: Integer): TValidatorTextPropertiesOnlyNumber;

  end;

implementation

uses
  System.RegularExpressions,
  System.SysUtils;

{ TValidatorTextActionsOnlyNumber<T> }

function TValidatorTextPropertiesOnlyNumber.GetDefaultErrorMessage: String;
begin
  Result := Format('O campo aceita apenas números antre %d e %d', [FMinValue, FMaxValue]);
end;

function TValidatorTextPropertiesOnlyNumber.Range(_AMinValue, _AMaxValue: Integer): TValidatorTextPropertiesOnlyNumber;
begin
  FMinValue := _AMinValue;
  FMaxValue := _AMaxValue;
  Result := Self
end;

function TValidatorTextPropertiesOnlyNumber.Validate: IValidatorTextProperties;
var
  aMatch: TMatch;
  val: Integer;
begin
  aMatch := TRegEx.Match(Trim(GetValue), '\d+');
  if aMatch.Success then
  begin
    if TryStrToInt(aMatch.Value, val) then
    begin
      if (val > FMaxValue) or (val < FMinValue) then
        SetAssignedError
      else
        ClearLastError
    end
    else
      SetAssignedError
  end
  else
    SetAssignedError;

  Result := Self;
end;

end.
