object dmEntityQuery: TdmEntityQuery
  OldCreateOrder = False
  Height = 187
  Width = 215
  object FDQuery: TFDQuery
    CachedUpdates = True
    SQL.Strings = (
      'SELECT * FROM !entity')
    Left = 88
    Top = 40
    MacroData = <
      item
        Value = Null
        Name = 'ENTITY'
      end>
  end
  object dsQuery: TDataSource
    DataSet = FDQuery
    Left = 88
    Top = 96
  end
end
