unit mvcValidator.Text.Properties.NonEmpty;

interface

uses
  System.SysUtils,
  mvcValidator.Interfaces,
  mvcValidator.Text.Properties;

type
  TValidatorTextPropertiesNonEmpty = class(TValidatorTextProperties)
  private
    const
  protected
    function GetDefaultErrorMessage: String; override;
  public
    function Validate: IValidatorTextProperties; override;
  end;

implementation


{ TValidatorTextActionsEmpty<T> }

function TValidatorTextPropertiesNonEmpty.GetDefaultErrorMessage: String;
begin
  Result := 'O campo não pode ficar vazio'
end;

function TValidatorTextPropertiesNonEmpty.Validate: IValidatorTextProperties;
begin
  if Trim(GetValue).IsEmpty then
    SetAssignedError
  else
    ClearLastError;

  Result := Self;
end;

end.
