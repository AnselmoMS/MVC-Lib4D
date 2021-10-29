unit mvcDAO.RTTI.Types;

interface

uses
  System.RTTI,
  System.SysUtils;

{$M+}

type
  TAttrType = (tpInteger, tpString, tpCurrency);

  Entity = class(TCustomAttribute)
  private
    FEntityName: String;
    procedure SetEntityName(const Value: String);
  published
    constructor Create ( aTableName : String );
    property EntityName : String read FEntityName write SetEntityName;
  end;

  FieldType = class(TCustomAttribute)
  private
    FAttrType: TAttrType;
    procedure SetAttrType(const Value: TAttrType);
  published
    constructor Create ( aAttrType : TAttrType );
    property AttrType : TAttrType read FAttrType write SetAttrType;
  end;

  UpdateField = class(TCustomAttribute)
  end;

  PKey = class(TCustomAttribute)
  end;

  FieldCaption = class(TCustomAttribute)
  private
    FCaption: String;
  published
    constructor Create( _ACaption : String);
    property Caption : String read FCaption write FCaption;  { TODO -oansel -c : Create Caption Adapter 17/10/2021 11:34:51 }
  end;

  TCustomAttributeClass = class of TCustomAttribute;

implementation

{ TableName }

constructor Entity.Create(aTableName: String);
begin
  FEntityName := aTableName;
end;

procedure Entity.SetEntityName(const Value: String);
begin
  FEntityName := Value;
end;

{ FieldType }

constructor FieldType.Create(aAttrType: TAttrType);
begin
  FAttrType := aAttrType;
end;

procedure FieldType.SetAttrType(const Value: TAttrType);
begin
  FAttrType := Value;
end;

{ FieldCaption }

constructor FieldCaption.Create(_ACaption: String);
begin
  FCaption := _ACaption
end;

end.
