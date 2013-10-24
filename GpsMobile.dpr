program GpsMobile;

uses
  System.StartUpCopy,
  FMX.Forms,
  GpsMain in 'GpsMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
