unit GpsMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  System.Sensors, FMX.Edit, FMX.Sensors,
  FMX.Helpers.Android, Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Location, Androidapi.JNIBridge, Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Os;

type
  TForm1 = class(TForm)
    Button1: TButton;
    LocationSensor1: TLocationSensor;
    EditLat: TEdit;
    Label1: TLabel;
    EditLog: TEdit;
    Label2: TLabel;
    AniIndicator1: TAniIndicator;
    EditALT: TEdit;
    Label3: TLabel;
    Button2: TButton;
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    function GetAndroidAlt : String;
    function GetAndroidAlt2 : String;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button2Click(Sender: TObject);
begin
  EditALT.Text := GetAndroidAlt;
end;



function TForm1.GetAndroidAlt : string;
var
  LocationManagerService : JObject;
  LocationManager : JLocationManager;
  Location : JLocation;
const
  MIN_DISTANCE_CHANGE_FOR_UPDATES = 10; // 10 meters
  MIN_TIME_BW_UPDATES = 1000 * 60 * 1; // 1 minute
begin
  LocationManager := TJLocationManager.Wrap( ((SharedActivity.getSystemService(TJContext.JavaClass.LOCATION_SERVICE)) as ILocalObject).GetObjectID);

  if LocationManager.isProviderEnabled(TJLocationManager.JavaClass.GPS_PROVIDER) then
  Begin

    LocationManagerService := SharedActivityContext.getSystemService( TJContext.JavaClass.LOCATION_SERVICE);

    if LocationManagerService = nil then
      raise Exception.Create( 'Não pode recuperá Location Service.' );
      LocationManager := TJLocationManager.Wrap( (LocationManagerService as ILocalObject).GetObjectID);
    if LocationManager = nil then
      raise Exception.Create( 'Não é possível acessar Location Manager.' );

      //Location :=  locationManager.requestLocationUpdates(TJLocationManager.JavaClass.GPS_PROVIDER, MIN_TIME_BW_UPDATES, MIN_DISTANCE_CHANGE_FOR_UPDATES, );
      //use the gps provider to get current lat, long and altitude.
    Location := LocationManager.getLastKnownLocation( TJLocationManager.JavaClass.GPS_PROVIDER);


    if Location = nil then
      raise Exception.Create( 'Não é possível acessar Ultimo Localização.' );
  end else
  Begin
    raise Exception.Create( 'Provedor GPS não esta Ativado. Verifique por favor!' );
  End;
  if LocationManager.isProviderEnabled(TJLocationManager.JavaClass.NETWORK_PROVIDER) then
  Begin

  End else
  Begin
    raise Exception.Create( 'Provedor NETWORK não esta Ativado. Verifique por favor!' );
  End;
  Result := Location.getAltitude.ToString;
end;


function TForm1.GetAndroidAlt2 : string;
var
  LocationManagerService: JObject;
  LocationManager: JLocationManager;
  providers : JList;
  Location : JLocation;
  I: Integer;
  AltDbl    : double;
begin
  Result := '';

  LocationManagerService := SharedActivityContext.getSystemService(TJContext.JavaClass.LOCATION_SERVICE);
  if LocationManagerService = nil then Exit;

  LocationManager := TJLocationManager.Wrap((LocationManagerService as ILocalObject).GetObjectID);
  if LocationManager = nil then Exit;

  providers := LocationManager.getProviders(True);
  if providers = nil then Exit;

  // Loop over the list backwards, as it is ordered from least accurate to most accurate
  for I := providers.size-1 downto 0 do
    begin
    Location := LocationManager.getLastKnownLocation( providers.get(I).ToString );
    if location <> nil then
      begin
      if Location.hasAltitude() then
        begin
        AltDbl := Location.getAltitude();
        Result := FormatFloat( '###0.0## Meters', AltDbl );
        Exit;
        end;
      end;
    end;
end;



procedure TForm1.Button1Click(Sender: TObject);
begin
  AniIndicator1.Visible := True;
  AniIndicator1.Enabled := True;
  LocationSensor1.OnLocationChanged := LocationSensor1LocationChanged;
  LocationSensor1.Active := True;
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
  EditLat.Text := FloatToStr(NewLocation.Latitude);
  EditLog.Text := FloatToStr(NewLocation.Longitude);
end;

end.
