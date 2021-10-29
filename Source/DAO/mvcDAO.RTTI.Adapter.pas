unit mvcDAO.RTTI.Adapter;

interface

uses
  System.RTTI,
  System.SysUtils,
  System.Generics.Collections,
  mvcDAO.Interfaces,
  mvcDAO.RTTI.Types;

type
  TSQLAdapter<T : class> = class (TinterfacedObject, ISQLAdapter<T>)
  private
  [weak]
  FEntity: T;
  FRTTIContext : TRttiContext;
  FRTTIType : TRttiType;
  function GetFieldValue(APropRTTI : TRttiProperty): String;
  public
    constructor Create(AEntity: T);
    destructor Destroy; override;
    //
    function GetFieldNames(AtrributeClass: TCustomAttributeClass = nil): TArray<string>;
    function GetFieldValues(AtrributeClass: TCustomAttributeClass = nil): TArray<string>;

    function GetKeyFieldNames: TArray<string>;
    function GetKeyFieldValues: TArray<string>;

    function GetTableName: String;
  end;

implementation

constructor TSQLAdapter<T>.Create(AEntity: T);
begin
  FEntity := AEntity;
  FRTTIContext:= TRttiContext.Create;
  FRTTIType:= FRTTIContext.GetType(AEntity.ClassInfo);
end;

destructor TSQLAdapter<T>.Destroy;
begin
  FRTTIContext.Free;
end;

function TSQLAdapter<T>.GetFieldNames(AtrributeClass: TCustomAttributeClass): TArray<string>;
var
  propRTTI : TRttiProperty;
  ListNames: TList<string>;
  attribRTTI: TCustomAttribute;
begin
  ListNames := TList<string>.Create;
  try
    for propRTTI in FRTTIType.GetProperties do
      for attribRTTI in propRTTI.GetAttributes do
        if (AtrributeClass = nil) or (attribRTTI is AtrributeClass) then
          if not ListNames.Contains(propRTTI.Name) then
            ListNames.Add(propRTTI.Name);
    Result := ListNames.ToArray
  finally
    ListNames.Free;
  end;
end;

function TSQLAdapter<T>.GetFieldValue(APropRTTI: TRttiProperty): String;
var
  attrRTTI : TCustomAttribute;
begin
  for attrRTTI in APropRTTI.GetAttributes do
  begin
    if attrRTTI is FieldType then
    begin
      case FieldType(attrRTTI).AttrType of
        tpInteger :  Result := IntToStr(APropRTTI.GetValue(Pointer(FEntity)).AsInteger);
        tpString :   Result := QuotedStr(APropRTTI.GetValue(Pointer(FEntity)).AsString);
        tpCurrency : Result := FormatFloat('#0.00', APropRTTI.GetValue(Pointer(FEntity)).AsCurrency, TFormatSettings.Invariant);
      end;
    end;
  end;
end;

function TSQLAdapter<T>.GetFieldValues(AtrributeClass: TCustomAttributeClass): TArray<string>;
var
  attrRTTI : TCustomAttribute;
  propRTTI : TRttiProperty;
  ListValues : Tlist<string>;
  ListNames: Tlist<string>;
begin
  ListValues := Tlist<string>.Create;
  ListNames:= Tlist<string>.Create;
  try
    for propRTTI in FRTTIType.GetProperties do
      for attrRTTI in propRTTI.GetAttributes do
        if (AtrributeClass = nil) or (attrRTTI is AtrributeClass) then
          if not ListNames.Contains(propRTTI.Name) then
          begin
            ListValues.Add(GetFieldValue(propRTTI));
            ListNames.Add(propRTTI.Name);
          end;

    Result := ListValues.ToArray;
  finally
    ListValues.Free;
    ListNames.Free;
  end;
end;

function TSQLAdapter<T>.GetKeyFieldNames: TArray<string>;
begin
  Result := GetFieldNames(PKey);
end;

function TSQLAdapter<T>.GetKeyFieldValues: TArray<string>;
begin
  Result := GetFieldValues(PKey);
end;

function TSQLAdapter<T>.GetTableName: String;
var
  attrRTTI : TCustomAttribute;
begin
  for attrRTTI in FRTTIType.GetAttributes do
    if attrRTTI is Entity then
      Exit(Entity(attrRTTI).EntityName);
end;



end.
