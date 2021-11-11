unit mvcValidator;

interface

uses
  Vcl.Graphics,
  System.Classes,
  System.SysUtils,
  Vcl.StdCtrls,
  System.Generics.Collections,
  mvcValidator.Interfaces,
  mvcValidator.Text.Constraints;

type
  TValidator = Class(TInterfacedObject, IValidator)
    private
      FOnChanged: TNotifyEvent;
      FTextConstraintsList: TList<IValidatorTextConstraints>;
    protected
      function OnChanged: TNotifyEvent;
    public
      class function New: IValidator;
      //
      destructor Destroy; override;
      //
      function Changed(Sender: TObject = nil): IValidator;
      function DisplayErrors: IValidator;
      function EditLabel(_AEdit: TCustomEdit; AErrorLabel: TCustomLabel): IValidatorTextConstraints;
      function &End: IValidator;
      function SetOnChanged(_AProc: TNotifyEvent): IValidator;
      function ValidateAll: IValidator;
     //
     function ResetErrors: IValidator;
  end;


implementation

{ TValidator }

function TValidator.Changed(Sender: TObject = nil): IValidator;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Sender);
  Result := Self;
end;

destructor TValidator.Destroy;
begin
  FreeAndNil(FTextConstraintsList);
  inherited;
end;

function TValidator.DisplayErrors: IValidator;
var
  c: IValidatorTextConstraints;
begin
  for c in FTextConstraintsList do
    c.DisplayErrors;
  Result := Self;
end;

function TValidator.EditLabel(_AEdit: TCustomEdit; AErrorLabel: TCustomLabel): IValidatorTextConstraints;
begin
  if not Assigned(FTextConstraintsList) then
    FTextConstraintsList := TList<IValidatorTextConstraints>.Create;

  Result := FTextConstraintsList[FTextConstraintsList.Add(TValidatorTextConstraints.New(Self, _AEdit, AErrorLabel))];
end;

function TValidator.&End: IValidator;
begin
  Result:= Self;
end;

class function TValidator.New: IValidator;
begin
  Result:= Self.Create;
end;

function TValidator.OnChanged: TNotifyEvent;
begin
  Result := FOnChanged;
end;

function TValidator.ResetErrors: IValidator;
var
  c: IValidatorTextConstraints;
begin
  for c in FTextConstraintsList do
    c.ResetErrors;
  Result := Self;
end;

function TValidator.SetOnChanged(_AProc: TNotifyEvent): IValidator;
begin
  FOnChanged := _AProc;
  Result := Self;
end;

function TValidator.ValidateAll: IValidator;
var
  I: IValidatorTextConstraints;
begin
  for I in FTextConstraintsList do
    I.ValidateAll;
  Result := Self;
end;

end.
