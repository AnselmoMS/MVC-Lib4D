unit mvcValidator.Text.Properties.MaxLength;
interface

uses
  System.SysUtils,
  mvcValidator.Interfaces,
  mvcValidator.Text.Properties;

type
  TValidatorTextPropertiesMaxLength = class(TValidatorTextProperties)
  private
  var
    FMaxLength: Integer;
  const
    DEFAULT_ERROR_MESSAGE = '';
  protected
    function GetDefaultErrorMessage: String; override;
  public
    class function New(_AParentConstraints: IValidatorTextConstraints; _MaxLength: Integer): IValidatorTextProperties;
    //
    constructor Create(_AParentConstraints: IValidatorTextConstraints; _MaxLength: Integer);
    //
    function MaxLength(_AValue: Integer): IValidatorTextProperties;
    function Validate: IValidatorTextProperties; override;
  end;

implementation

{ TValidatorTextPropertiesMaxLength }

function TValidatorTextPropertiesMaxLength.GetDefaultErrorMessage: String;
begin
  Result := Format('Limite máximo de %d caracteres ultrapassado', [FMaxLength]);
end;

function TValidatorTextPropertiesMaxLength.MaxLength(_AValue: Integer): IValidatorTextProperties;
begin
  FMaxLength := _AValue
end;

class function TValidatorTextPropertiesMaxLength.New(_AParentConstraints: IValidatorTextConstraints; _MaxLength: Integer): IValidatorTextProperties;
begin
  Result := Self.Create(_AParentConstraints, _MaxLength);
end;

constructor TValidatorTextPropertiesMaxLength.Create(_AParentConstraints: IValidatorTextConstraints; _MaxLength: Integer);
begin
  inherited Create(_AParentConstraints);
  MaxLength(_MaxLength);
end;

function TValidatorTextPropertiesMaxLength.Validate: IValidatorTextProperties;
begin
  if GetValue.Length > FMaxLength then
    SetAssignedError
  else
    ClearLastError;

  Result := Self;
end;

end.
