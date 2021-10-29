unit mvcValidator.Text.Properties;

interface

uses
  System.SysUtils,
  Vcl.Graphics,
  mvcValidator.Interfaces;

type
  TValidatorTextProperties = class(TinterfacedObject, IValidatorTextProperties)
  private
    FErroStyleColor: TColor;
  protected
    FCustomError: string;
    FLastError: String;
    FOriginalEditColor: TColor;
    [weak]
    FParentConstraint: IValidatorTextConstraints;
    //
    function GetAssignedError: String;
    function GetDefaultErrorMessage: String; virtual; abstract;
    function GetValue: String;
    //
    procedure ClearLastError;
    procedure SetAssignedError;

  public
    const
      DEFAULT_ERROR_STYLE_COLOR = clWebLightCoral;
    //
    class function New(_AparentConstraint: IValidatorTextConstraints): IValidatorTextProperties;
    //
    constructor Create(_AparentConstraint: IValidatorTextConstraints);
    //
    function EndUpdate: IValidatorTextConstraints; virtual;
    function DisplayError: IValidatorTextProperties;
    function EndAll: IValidator;
    function ErrorMessage(_Mgs: string): IValidatorTextProperties;
    function ErrorStyle(_AColor: TColor = DEFAULT_ERROR_STYLE_COLOR): IValidatorTextProperties;
    function GetLastError: String;
    function Validate: IValidatorTextProperties; virtual; abstract;
  end;
  TValidatorTextPropertiesClass = class of TValidatorTextProperties;

implementation

uses
  Vcl.Controls;

type
  TControlAccess = class(TControl)
  end;

{ TValidatorTextProperties }


procedure TValidatorTextProperties.ClearLastError;
begin
  FLastError := '';
end;

constructor TValidatorTextProperties.Create(_AparentConstraint: IValidatorTextConstraints);
begin
  FParentConstraint:= _AparentConstraint;
  FOriginalEditColor := TControlAccess(_AparentConstraint.GetEdit).Color;
  FErroStyleColor := DEFAULT_ERROR_STYLE_COLOR;
end;

function TValidatorTextProperties.DisplayError: IValidatorTextProperties;
begin
  TControlAccess(FParentConstraint.GetEdit).Color := FOriginalEditColor;
  FParentConstraint.GetErrorLabel.Caption := '';
  //
  if not FLastError.IsEmpty then
  begin
    if not FParentConstraint.GetEdit.Focused then
      FParentConstraint.GetEdit.SetFocus;

    TControlAccess(FParentConstraint.GetEdit).Color := FErroStyleColor;
    FParentConstraint.GetErrorLabel.Caption := FLastError;
  end;
end;

function TValidatorTextProperties.EndUpdate: IValidatorTextConstraints;
begin
  Result := FParentConstraint;
end;

function TValidatorTextProperties.EndAll: IValidator;
begin
  Result := FParentConstraint.EndUpdate
end;

function TValidatorTextProperties.ErrorMessage(_Mgs: string): IValidatorTextProperties;
begin
  FCustomError := _Mgs;
  Result := Self;
end;

function TValidatorTextProperties.ErrorStyle(_AColor: TColor): IValidatorTextProperties;
begin
  FErroStyleColor := _AColor;
  Result := Self;
end;

function TValidatorTextProperties.GetAssignedError: String;
begin
  if FCustomError.Trim.IsEmpty then
    Result := GetDefaultErrorMessage
  else
    Result := FCustomError;
end;

function TValidatorTextProperties.GetLastError: String;
begin
  Result := FLastError;
end;

function TValidatorTextProperties.GetValue: String;
begin
  Result := FParentConstraint.GetEdit.Text;
end;

class function TValidatorTextProperties.New(_AparentConstraint: IValidatorTextConstraints): IValidatorTextProperties;
begin
  Result := Self.Create(_AparentConstraint);
end;

procedure TValidatorTextProperties.SetAssignedError;
begin
  FLastError := GetAssignedError;
end;

end.
