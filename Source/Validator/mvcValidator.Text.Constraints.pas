unit mvcValidator.Text.Constraints;

interface

uses
  Vcl.StdCtrls,
  System.SysUtils,
  mvcValidator.Interfaces,
  mvcValidator.Text.Properties.NonEmpty,
  mvcValidator.Text.Properties.MinLength,
  mvcValidator.Text.Properties.MaxLength,
  System.Classes,
  System.Generics.Collections,
  mvcValidator.Text.Properties;

type
  TValidatorTextConstraints = class(TInterfacedObject, IValidatorTextConstraints)
  private
    [weak]
    FValidator: IValidator;
  var
    FEdit: TCustomEdit;
    FErrorLabel: TCustomLabel;
    FOriginalOnChange: TNotifyEvent;
    FOriginalOnExit: TNotifyEvent;
    FValidatorTextPropertiesList: TList<IValidatorTextProperties>;
    //
    function GetValidatorTextPropertiesItemByClass(_AValidatorTextPropertiesClass: TValidatorTextPropertiesClass): IValidatorTextProperties;
    //
    procedure EditOnChange(Sender: Tobject);
    procedure EditOnExit(Sender: TObject);
  public
    class function New(_AParent: IValidator; _AEdit: TCustomEdit; AErrorLabel: TCustomLabel): IValidatorTextConstraints;
    //
    constructor Create(_AValidator: IValidator; _AEdit: TCustomEdit; _AErrorLabel: TCustomLabel);
    //
    destructor Destroy; override;
    //
    function DisplayErrors: IValidatorTextConstraints;
    function EndUpdate: IValidator;
    function GetEdit: TCustomEdit;
    function GetErrorLabel: TCustomLabel;
    //
    function MaxLength(_Value: Integer): IValidatorTextProperties;
    function MinLength(_Value: Integer): IValidatorTextProperties;
    function NonEmpty: IValidatorTextProperties;
    //
    function ValidateAll: IValidatorTextConstraints;
    function ValidateAndDisplayErrors: IValidatorTextConstraints;
    //
    procedure AfterConstruction; override;
    procedure DoChanged(Sender: Tobject);
  end;

  //hook para acessar TEdit
  TCustomEditAccess = class(TCustomEdit)
  end;

implementation

uses
  Vcl.Controls;

{ TValidatorTextConstraints<> }

procedure TValidatorTextConstraints.AfterConstruction;
begin
  inherited;
  FValidator.SetOnChanged(DoChanged);
  //OnChange
  FOriginalOnChange := TCustomEditAccess(FEdit).OnChange;
  TCustomEditAccess(FEdit).OnChange := EditOnChange;
  //OnExit;
  FOriginalOnExit := TCustomEditAccess(FEdit).OnExit;
  TCustomEditAccess(FEdit).OnExit := EditOnExit;
end;

constructor TValidatorTextConstraints.Create(_AValidator: IValidator; _AEdit: TCustomEdit; _AErrorLabel: TCustomLabel);
begin
  FValidator  := _AValidator;
  FEdit       := _AEdit;
  FErrorLabel := _AErrorLabel;

  FValidatorTextPropertiesList:= TList<IValidatorTextProperties>.Create;
end;

function TValidatorTextConstraints.NonEmpty: IValidatorTextProperties;
begin
  Result := GetValidatorTextPropertiesItemByClass(TValidatorTextPropertiesNonEmpty);
  if not Assigned(Result) then
    Result := FValidatorTextPropertiesList[FValidatorTextPropertiesList.Add(TValidatorTextPropertiesNonEmpty.New(Self))]
end;

function TValidatorTextConstraints.ValidateAll: IValidatorTextConstraints;
var
  I: Integer;
begin
  for I := 0 to Pred(FValidatorTextPropertiesList.Count) do
    if not FValidatorTextPropertiesList[I].Validate.GetLastError.IsEmpty then
      Exit;

  Result := Self;
end;

function TValidatorTextConstraints.ValidateAndDisplayErrors: IValidatorTextConstraints;
begin
  ValidateAll;
  DisplayErrors;
end;

destructor TValidatorTextConstraints.Destroy;
begin
  inherited;
  FreeAndNil(FValidatorTextPropertiesList);
end;

function TValidatorTextConstraints.DisplayErrors: IValidatorTextConstraints;
var
  I: Integer;
begin
  for I := 0 to Pred(FValidatorTextPropertiesList.Count) do
    if (I = Pred(FValidatorTextPropertiesList.Count)) or (not FValidatorTextPropertiesList[I].Validate.GetLastError.IsEmpty) then
    begin
      FValidatorTextPropertiesList[I].DisplayError;
      Exit;
    end;

  Result := Self;
end;

procedure TValidatorTextConstraints.DoChanged;
begin
  ValidateAndDisplayErrors
end;

procedure TValidatorTextConstraints.EditOnChange(Sender: Tobject);
begin
  if Assigned(FOriginalOnChange) then
    FOriginalOnChange(Sender);

  ValidateAll;
  DisplayErrors;
end;

procedure TValidatorTextConstraints.EditOnExit(Sender: TObject);
begin
  if Assigned(FOriginalOnExit) then
    FOriginalOnExit(Sender);

  ValidateAll;
  DisplayErrors;
end;

function TValidatorTextConstraints.EndUpdate: IValidator;
begin
  Result := FValidator;
end;

function TValidatorTextConstraints.GetEdit: TCustomEdit;
begin
  Result := FEdit
end;

function TValidatorTextConstraints.GetErrorLabel: TCustomLabel;
begin
  Result := FErrorLabel
end;

function TValidatorTextConstraints.GetValidatorTextPropertiesItemByClass(_AValidatorTextPropertiesClass: TValidatorTextPropertiesClass): IValidatorTextProperties;
var
  propIndex: Integer;
begin
  Result := nil;
  for propIndex := 0 to Pred(FValidatorTextPropertiesList.Count) do
    if FValidatorTextPropertiesList[propIndex] is _AValidatorTextPropertiesClass then
      Exit(FValidatorTextPropertiesList[propIndex]);
end;

function TValidatorTextConstraints.MaxLength(_Value: Integer): IValidatorTextProperties;
begin
  Result := GetValidatorTextPropertiesItemByClass(TValidatorTextPropertiesMaxLength);
  if not Assigned(Result) then
    Result := FValidatorTextPropertiesList[FValidatorTextPropertiesList.Add(TValidatorTextPropertiesMaxLength.New(Self, _Value))]
end;

function TValidatorTextConstraints.MinLength(_Value: Integer): IValidatorTextProperties;
begin
  Result := GetValidatorTextPropertiesItemByClass(TValidatorTextPropertiesMinLength);
  if not Assigned(Result) then
    Result := FValidatorTextPropertiesList[FValidatorTextPropertiesList.Add(TValidatorTextPropertiesMinLength.New(Self, _Value))]
end;

class function TValidatorTextConstraints.New(_AParent: IValidator; _AEdit: TCustomEdit; AErrorLabel: TCustomLabel): IValidatorTextConstraints;
begin
  Result := Self.Create(_Aparent, _AEdit, AErrorLabel);
end;

end.
