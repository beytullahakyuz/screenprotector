program screenprotector;



{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  Winapi.Windows,
  FMX.Platform.Win,
  uMain in 'uMain.pas' {frmMain},
  uFunctions in 'uFunctions.pas',
  uLang in 'uLang.pas',
  uHelp in 'pages\uHelp.pas' {frmHelp};

{$R *.res}

begin
  var MutexHandle: THandle;
  MutexHandle := CreateMutex(nil, True, 'Global\_ScreenProtector_');
  if (MutexHandle <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    ExitProcess(0);
  end;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
