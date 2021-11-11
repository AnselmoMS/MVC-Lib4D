unit mvcNullable;

interface

uses
  System.SysUtils,
  Generics.Defaults;

type
  Nullable<T> = record
  strict private type
    Null = interface end;
  private
    FValue: T;
    FHasValue: IInterface;
    function GetValue: T;
    function GetIsNull: Boolean;
    procedure SetAsVariant(const Value: Variant);
    procedure SetNull;
    function GetAsVariant: Variant;
  public
    constructor Create(AValue: T);
    function GetValueOrDefault: T; overload;
    function GetValueOrDefault(Default: T): T; overload;

    property IsNull: Boolean read GetIsNull;
    property Value: T read GetValue;

    property AsVariant: Variant read GetAsVariant write SetAsVariant;

    class operator NotEqual(const ALeft, ARight: Nullable<T>): Boolean;
    class operator Equal(ALeft, ARight: Nullable<T>): Boolean;
    class operator Implicit(const value: Null): Nullable<T>;
    class operator Implicit(Value: Nullable<T>): T;
    class operator Implicit(Value: T): Nullable<T>;
    class operator Implicit(Value: Variant): Nullable<T>;
    class operator Explicit(Value: Nullable<T>): T;
  end;

procedure SetFlagInterface(var Intf: IInterface);

implementation

uses
  System.RTTI,
  System.Variants;

function NopAddref(inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopRelease(inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopQueryInterface(inst: Pointer; const IID: TGUID; out Obj): HResult; stdcall;
begin
  Result := E_NOINTERFACE;
end;

const
  FlagInterfaceVTable: array[0..2] of Pointer =
  (
    @NopQueryInterface,
    @NopAddref,
    @NopRelease
  );

  FlagInterfaceInstance: Pointer = @FlagInterfaceVTable;

procedure SetFlagInterface(var Intf: IInterface);
begin
  Intf := IInterface(@FlagInterfaceInstance);
end;


{ Nullable<T> }

constructor Nullable<T>.Create(AValue: T);
begin
  FValue := AValue;
  SetFlagInterface(FHasValue);
end;

class operator Nullable<T>.Equal(ALeft, ARight: Nullable<T>): Boolean;
var
  Comparer: IEqualityComparer<T>;
begin
  if (ALeft.IsNull and ARight.IsNull) then
    Result := True //Null = Null
  else
    if not ALeft.IsNull and not ARight.IsNull then // compare values
    begin
      Comparer := TEqualityComparer<T>.Default;
      Result := Comparer.Equals(ALeft.Value, ARight.Value);
    end
    else
      Result := False;
end;

class operator Nullable<T>.Explicit(Value: Nullable<T>): T;
begin
  Result := Value.Value;
end;

function Nullable<T>.GetAsVariant: Variant;
begin
  if IsNull then
    Result := System.Variants.Null
  else
    Result := TValue.From<T>(Self.Value).AsType<Variant>;
end;

function Nullable<T>.GetIsNull: Boolean;
begin
  Result := FHasValue = nil;
end;

function Nullable<T>.GetValue: T;
begin
  if IsNull then
    raise Exception.Create('Invalid operation, Nullable type has no value');
  Result := FValue;
end;

function Nullable<T>.GetValueOrDefault: T;
begin
  if IsNull then
    Result := Default(T)
  else
    Result := FValue;
end;

function Nullable<T>.GetValueOrDefault(Default: T): T;
begin
  if IsNull then
    Result := Default
  else
    Result := FValue;
end;

class operator Nullable<T>.Implicit(Value: Nullable<T>): T;
begin
  Result := Value.GetValueOrDefault;
end;

class operator Nullable<T>.Implicit(Value: T): Nullable<T>;
begin
  Result := Nullable<T>.Create(Value);
end;

class operator Nullable<T>.Implicit(const value: Null): Nullable<T>;
var
  v: Nullable<T>;
begin
  Result := v;
end;

class operator Nullable<T>.NotEqual(const ALeft, ARight: Nullable<T>): Boolean;
var
  Comparer: IEqualityComparer<T>;
begin
  if ALeft.IsNull and ARight.IsNull then
    Result := False // Null = Null [NotEqual = False]
  else
    if not ALeft.IsNull and not ARight.IsNull then
    begin
      Comparer := TEqualityComparer<T>.Default;
      Result := not Comparer.Equals(ALeft.Value, ARight.Value);
    end
    else
      Result := True; // Null <> [Not Null] = [NotEqual = True]
end;

procedure Nullable<T>.SetAsVariant(const Value: Variant);
begin
  if VarIsNull(Value) or VarIsEmpty(Value) then
    SetNull
  else
    Self := TValue.FromVariant(Value).AsType<T>;
end;

procedure Nullable<T>.SetNull;
begin
  FHasValue := nil;
  FValue := Default(T);
end;

class operator Nullable<T>.Implicit(Value: Variant): Nullable<T>;
var
  newvalue: Nullable<T>;
begin
  if not VarIsNull(Value) then
    newvalue.SetAsVariant(Value);
  Result := newvalue
end;

end.
