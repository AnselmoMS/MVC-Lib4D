unit mvcValidator.Interfaces;

interface

uses
  Vcl.Graphics,
  System.Classes,
  System.SysUtils,
  Vcl.StdCtrls;

type
  IValidator = interface;
  IValidatorTextConstraints = interface;

  IValidatorTextProperties = interface
    ['{F696D178-B8AC-4D38-B857-E24167E7E443}']
    function DisplayError: IValidatorTextProperties;
    function EndUpdate: IValidatorTextConstraints;
    function EndAll: IValidator;
    function ErrorMessage(_Mgs: string): IValidatorTextProperties;
    function ErrorStyle(_AColor: TColor = clRed): IValidatorTextProperties;
    function GetLastError: String;
    function Validate: IValidatorTextProperties;
  end;

  IValidatorTextConstraints = interface
    ['{A390FF49-8BCB-4A79-9E4A-EFCCADFDE099}']
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
  end;

  IValidator = interface
    ['{B9961C81-8BE8-4316-B30F-5CEE47251901}']
    function Changed(Sender: TObject = nil): IValidator;
    function DisplayErrors: IValidator;
    function EditLabel(_AEdit: TCustomEdit; AErrorLabel: TCustomLabel): IValidatorTextConstraints;
    function SetOnChanged(_AProc: TNotifyEvent): IValidator;
    function ValidateAll: IValidator;
  end;

implementation

end.
