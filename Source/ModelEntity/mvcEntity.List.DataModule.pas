unit mvcEntity.List.DataModule;

interface

uses
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  System.Generics.Collections,
  System.Classes,
  System.JSON;

type
  TdmEntityQuery = class(TDataModule)
    FDQuery: TFDQuery;
    dsQuery: TDataSource;
  private
    FEntityName: String;
    procedure SetEntityName(const Value: String);
    { Private declarations }
  public
    { Public declarations }
      procedure SetConnection(_AConnection: TComponent);
      procedure CloseQuery;
      procedure OpenQuery;
      function GetDataSet: TDataSet;
      function GetDataSetAsJson: TJsonArray;
      function GetDataSource: TDataSource;
      //
      property EntityName : String  read FEntityName write SetEntityName;
  end;

implementation

uses
  DataSet.Serialize;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmEntityQuery }

procedure TdmEntityQuery.CloseQuery;
begin
  FDQuery.Close;
end;

function TdmEntityQuery.GetDataSetAsJson: TJsonArray;
begin
  Result := FDQuery.ToJSONArray;
end;

function TdmEntityQuery.GetDataSet: TDataSet;
begin
  Result := FDQuery
end;

function TdmEntityQuery.GetDataSource: TDataSource;
begin
  Result := dsQuery;
end;

procedure TdmEntityQuery.OpenQuery;
begin
  FDQuery.Open('SELECT * FROM ' + FEntityName + ' ORDER BY 1')
end;

procedure TdmEntityQuery.SetConnection(_AConnection: TComponent);
begin
  FDQuery.Connection := TFDconnection(_AConnection);
end;

procedure TdmEntityQuery.SetEntityName(const Value: String);
begin
  FEntityName := Value;
end;

end.
