unit mvcConnections.DB.DatabaseParams;

interface

type
  TDatabaseParams = record   //separe database connection params to user login params
    DatabaseName : string;
    DatabasePort: Integer;
    DatabaseHost: string;
    UserName: string;
    UserPass: string;
  end;

implementation

end.
