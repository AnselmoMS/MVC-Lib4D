unit mvcValidator.Text.Properties.MinLength;
interface

uses
  System.SysUtils,
  mvcValidator.Interfaces,
  mvcValidator.Text.Properties;

type
  TValidatorTextPropertiesMinLength = class(TValidatorTextProperties)
  private
  var
    FMinLength: Integer;
  const
    LOWER_MIN_LENGTH = 1;

  protected
    function GetDefaultErrorMessage: String; override;

  public
    class function New(_AParentConstraints: IValidatorTextConstraints; _MinLength: Integer): IValidatorTextProperties;
    //
    constructor Create(_AParentConstraints: IValidatorTextConstraints; _MinLength: Integer);
    //
    function MinLength(_AMinLength: Integer): TValidatorTextPropertiesMinLength;
    function Validate: IValidatorTextProperties; override;
  end;

implementation

{ TValidatorTextPropertiesMinLength }

function TValidatorTextPropertiesMinLength.GetDefaultErrorMessage: String;
begin
  Result := Format('Limite mínimo de %d caracteres não alcançado', [FMinLength]);
end;

function TValidatorTextPropertiesMinLength.MinLength(_AMinLength: Integer): TValidatorTextPropertiesMinLength;
begin
  if _AMinLength <= LOWER_MIN_LENGTH then
    raise Exception.Create('Valor mínimo é ' + LOWER_MIN_LENGTH.ToString);

  FMinLength := _AMinLength;

  Result := Self;
end;

class function TValidatorTextPropertiesMinLength.New(_AParentConstraints: IValidatorTextConstraints; _MinLength: Integer): IValidatorTextProperties;
begin
  Result := Self.Create(_AParentConstraints, _MinLength);
end;

constructor TValidatorTextPropertiesMinLength.Create(_AParentConstraints: IValidatorTextConstraints; _MinLength: Integer);
begin
  inherited Create(_AParentConstraints);
  MinLength(_MinLength);
end;

function TValidatorTextPropertiesMinLength.Validate: IValidatorTextProperties;
begin
  if GetValue.Length < FMinLength then
    SetAssignedError
  else
    ClearLastError;

  Result := Self;
end;

end.
