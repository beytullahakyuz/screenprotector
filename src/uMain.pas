{
    This program is distributed under the GNU General Public License version 3
    or (at your option) any later version.
    See the LICENSE file for more details.

    Copyright (C) 2025 Beytullah Akyüz

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License,
    or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU General Public License for more details.
}

unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, Winapi.AclAPI, Winapi.AccCtrl,
  FMX.ListBox, FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, FMX.Platform.Win, Winapi.Windows,
  System.ImageList, FMX.ImgList, FMX.DialogService, FMX.Platform, uFunctions, ShellApi, uLang, uHelp;

type
  ACCESS_ALLOWED_ACE = packed record
    AceType: Byte;
    AceFlags: Byte;
    AceSize: Word;
    Mask: DWORD;
    SidStart: PSID;
  end;

  type
  SID_IDENTIFIER_AUTHORITY = record
    Value: array[0..5] of Byte;
  end;

  PSID = ^SID;
  SID = record
    Revision: Byte;
    SubAuthorityCount: Byte;
    IdentifierAuthority: SID_IDENTIFIER_AUTHORITY;
    SubAuthority: array[0..15] of DWORD;
  end;

  PTOKEN_USER = ^TOKEN_USER;
  TOKEN_USER = record
    User: SID_AND_ATTRIBUTES;
  end;

  SID_AND_ATTRIBUTES = record
    Sid: PSID;
    Attributes: DWORD;
  end;

type
  TfrmMain = class(TForm)
    stylebook: TStyleBook;
    gridpanel: TGridPanelLayout;
    lbllang: TLabel;
    cmbLanguage: TComboBox;
    lblmonitors: TLabel;
    cmbMonitors: TComboBox;
    chkRunstart: TCheckBox;
    chkUserename: TCheckBox;
    btnHelp: TCornerButton;
    Rectangle1: TRectangle;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    btnProtection: TCornerButton;
    statusbar: TStatusBar;
    btnDocs: TCornerButton;
    imagelist: TImageList;
    btnSave: TCornerButton;
    btnAbout: TCornerButton;
    lblStatus: TLabel;
    btnExtract: TCornerButton;
    timer: TTimer;
    timercontrol: TTimer;
    btnLogs: TCornerButton;
    btnParams: TCornerButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure timerTimer(Sender: TObject);
    procedure timercontrolTimer(Sender: TObject);
  private
    { Private declarations }
    procedure loadUI;
    procedure checkSP(terminate: Boolean; pstart: string; prename: string);
    procedure checkProc;
    procedure RestrictProcess;
    function GetMousePos: TPointF;

    const
      SECURITY_MAX_SID_SIZE = 68;
      SECURITY_LOCAL_SYSTEM_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (Value: (0, 0, 0, 0, 0, 5));
      SECURITY_CREATOR_OWNER_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (Value: (0, 0, 0, 0, 0, 9));
      ACL_REVISION = 2;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

function TfrmMain.GetMousePos: TPointF;
var
  MouseService: IFMXMouseService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXMouseService, MouseService) then
    Result := MouseService.GetMousePos
  else
    Result := TPointF.Create(0, 0);
end;

procedure TfrmMain.RestrictProcess;
var
  hToken: THandle;
  pTokenUser: PTOKEN_USER;
  cbBufferSize: DWORD;
  pLocalSystemSid: Pointer;
  pOwnerRightsSid: Pointer;
  cbACL: DWORD;
  _pacl: PACL;
  ea: array[0..2] of EXPLICIT_ACCESS;
  pSD: PSECURITY_DESCRIPTOR;
begin
  if not OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, hToken) then
  begin
    writeLog('Error code: 401');
    Exit;
  end;

  GetTokenInformation(hToken, TokenUser, nil, 0, cbBufferSize);
  GetMem(pTokenUser, cbBufferSize);
  if not GetTokenInformation(hToken, TokenUser, pTokenUser, cbBufferSize, cbBufferSize) then
  begin
    writeLog('Error code: 402');
    Exit;
  end;

  GetMem(pLocalSystemSid, SECURITY_MAX_SID_SIZE);
  cbBufferSize := SECURITY_MAX_SID_SIZE;

  if not AllocateAndInitializeSid(@SECURITY_LOCAL_SYSTEM_AUTHORITY, 1, $12, 0, 0, 0, 0, 0, 0, 0, pLocalSystemSid) then
  begin
    writeLog('Error code: 403');
    Exit;
  end;

  GetMem(pOwnerRightsSid, SECURITY_MAX_SID_SIZE);
  cbBufferSize := SECURITY_MAX_SID_SIZE;

  if not AllocateAndInitializeSid(@SECURITY_CREATOR_OWNER_AUTHORITY, 1, $3, 0, 0, 0, 0, 0, 0, 0, pOwnerRightsSid) then
  begin
    writeLog('Error code: 404');
    Exit;
  end;

  cbACL := SizeOf(ACL) +
           SizeOf(ACCESS_ALLOWED_ACE) + GetLengthSid(pTokenUser^.User.Sid) +
           SizeOf(ACCESS_ALLOWED_ACE) + GetLengthSid(pLocalSystemSid) +
           SizeOf(ACCESS_ALLOWED_ACE) + GetLengthSid(pOwnerRightsSid);

  GetMem(_pacl, cbACL);
  if not InitializeAcl(_pacl^, cbACL, ACL_REVISION) then
  begin
    writeLog('Error code: 405');
    Exit;
  end;

  ZeroMemory(@ea[0], SizeOf(EXPLICIT_ACCESS));
  ea[0].grfAccessPermissions := SYNCHRONIZE or PROCESS_QUERY_INFORMATION or PROCESS_TERMINATE;
  ea[0].grfAccessMode := GRANT_ACCESS;
  ea[0].grfInheritance := NO_INHERITANCE;
  ea[0].Trustee.TrusteeForm := TRUSTEE_IS_SID;
  ea[0].Trustee.ptstrName := PChar(pTokenUser^.User.Sid);

  ZeroMemory(@ea[1], SizeOf(EXPLICIT_ACCESS));
  ea[1].grfAccessPermissions := GENERIC_ALL;
  ea[1].grfAccessMode := GRANT_ACCESS;
  ea[1].grfInheritance := NO_INHERITANCE;
  ea[1].Trustee.TrusteeForm := TRUSTEE_IS_SID;
  ea[1].Trustee.ptstrName := PChar(pLocalSystemSid);

  ZeroMemory(@ea[2], SizeOf(EXPLICIT_ACCESS));
  ea[2].grfAccessPermissions := READ_CONTROL;
  ea[2].grfAccessMode := GRANT_ACCESS;
  ea[2].grfInheritance := NO_INHERITANCE;
  ea[2].Trustee.TrusteeForm := TRUSTEE_IS_SID;
  ea[2].Trustee.ptstrName := PChar(pOwnerRightsSid);

  if SetEntriesInAcl(3, @ea, nil, _pacl) <> ERROR_SUCCESS then
  begin
    writeLog('Error code: 406');
    Exit;
  end;

  GetMem(pSD, SizeOf(TSecurityDescriptor));
  if not InitializeSecurityDescriptor(pSD, SECURITY_DESCRIPTOR_REVISION) then
  begin
    writeLog('Error code: 407');
    Exit;
  end;
  if not SetSecurityDescriptorDacl(pSD, True, _pacl, False) then
  begin
    writeLog('Error code: 408');
    Exit;
  end;

  if SetSecurityInfo(GetCurrentProcess(), SE_KERNEL_OBJECT, DACL_SECURITY_INFORMATION, nil, nil, _pacl, nil) <> ERROR_SUCCESS then
  begin
    writeLog('Error code: 409');
    Exit;
  end;
  FreeMem(pTokenUser);
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  if sender = btnSave then begin
     var lang, mon: string;
     var renameparam: string := '';
     if cmbLanguage.ItemIndex = 0 then
      lang := 'en'
      else
      lang := 'tr';
     if cmbMonitors.ItemIndex = 0 then
      mon := '-p'
      else
      mon := '-a';
     if chkUserename.IsChecked then
      renameparam := '-r';
     try
       uFunctions.writeConfigs(lang, mon, chkUserename.IsChecked);
       timer.Enabled := false;
       lblStatus.Text := uLang.rsSaveSettings;
       timer.Enabled := true;
     except
      timer.Enabled := false;
      lblStatus.Text := uLang.rsConfigPermission;
      timer.Enabled := true;
     end;
     uFunctions.loadConfigs;
     if chkRunstart.IsChecked then
        uFunctions.writeStartupSetting(1, ' -s ' + renameparam)
        else
        uFunctions.writeStartupSetting(0, '');
     uLang.loadLang(lang);
     loadUI;
  end else if sender = btnProtection then begin
    if uFunctions.getProcessRunning then begin
      uFunctions.detectAppAndRemoveTemp(1);
    end else begin
      var ren: string := '';
      if chkUserename.IsChecked then
        ren := '-r';
      checkSP(false, '', ren);
    end;
    checkProc;
  end else if sender = btnHelp then begin
    var frmhlp: TfrmHelp;
    var point: TPointF;
    frmhlp := TfrmHelp.Create(nil);
    point := GetMousePos;
    frmhlp.Left := Round(point.X) - Round(frmhlp.Width/2);
    frmhlp.Top := Round(point.Y);
    frmhlp.ShowModal;
    frmhlp.Free;
  end else if sender = btnDocs then begin
    if uFunctions.LANG = 'en' then
      ShellExecute(0, 'open', 'https://beytullahakyuz.gitbook.io/projects/screen-protector', nil, nil, SW_HIDE)
      else
      ShellExecute(0, 'open', 'https://beytullahakyuz.gitbook.io/projects/tr/screen-protector', nil, nil, SW_HIDE);
  end else if sender = btnLogs then begin
    if FileExists(uFunctions.LOGFILE) then
      ShellExecute(0, 'open', PChar(uFunctions.LOGFILE), nil, nil, SW_NORMAL)
      else begin
        timer.Enabled := false;
        lblStatus.Text := uLang.rsLogError;
        timer.Enabled := true;
      end;
  end else if sender = btnAbout then begin
    TDialogService.MessageDialog(uLang.rsAbout, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil, nil);
  end else if sender = btnParams then begin
    TDialogService.MessageDialog(uLang.rsParams, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil, nil);
  end else if sender = btnExtract then begin
    try
      uFunctions.extractSP('_sprotector.exe');
      timer.Enabled := false;
      if FileExists('_sprotector.exe') then begin
        lblStatus.Text := uLang.rsExtractSuccess;
        timer.Enabled := true;
      end;
    except
      lblStatus.Text := uLang.rsConfigPermission;
      timer.Enabled := true;
     end;
  end;
end;

procedure TfrmMain.checkProc;
begin
  btnProtection.Text := uLang.rsProtection;
  if uFunctions.getProcessRunning then
    btnProtection.ImageIndex := 2
  else
    btnProtection.ImageIndex := 1;
end;

procedure TfrmMain.checkSP(terminate: Boolean; pstart: string; prename: string);
var
  exename: string;
begin
  if terminate = true then begin
    if pstart = '-s' then begin
      exename := 'sprotector.exe';
      if prename = '-r' then
        exename := uFunctions.getFileName;
      uFunctions.detectAppAndRemoveTemp(0);
      uFunctions.extractSP(exename);
      var exepath: string := ExtractFileDir(ParamStr(0)) + '\' + exename;
      if FileExists(exepath) then begin
        uFunctions.RunApp(exepath, uFunctions.MONITOR, IDLE_PRIORITY_CLASS);
      end else
        TDialogService.MessageDialog('Not working! Check permission.', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil, nil);
      Application.Terminate;
    end;
  end else begin
    exename := 'sprotector.exe';
    if prename = '-r' then
      exename := uFunctions.getFileName;
    uFunctions.detectAppAndRemoveTemp(0);
    try
      uFunctions.extractSP(exename);
    except
      timer.Enabled := false;
      lblStatus.Text := uLang.rsPermissions;
      timer.Enabled := true;
    end;
    if FileExists(exename) then
      uFunctions.RunApp(exename, uFunctions.MONITOR, IDLE_PRIORITY_CLASS);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  RestrictProcess;
  if (TOSVersion.Major = 6) and (TOSVersion.Minor = 0) or (TOSVersion.Major < 6) or (TOSVersion.Platform <> pfWindows)then
  begin
    TDialogService.ShowMessage('Unsupported OS! ScreenProtector >= Win7');
    Application.Terminate;
  end;
  if ParamStr(1) = '-s' then
    uFunctions.HideTaskbar;
  uFunctions.loadConfigs;
  uLang.loadLang(uFunctions.LANG);
  checkSP(true, ParamStr(1), ParamStr(2));
  if uFunctions.LANG = 'en' then begin
    uLang.loadLang('en');
    cmbLanguage.ItemIndex := 0;
  end else begin
    uLang.loadLang('tr');
    cmbLanguage.ItemIndex := 1;
  end;
  if uFunctions.MONITOR = '-p' then
    cmbMonitors.ItemIndex := 0
    else
    cmbMonitors.ItemIndex := 1;
  if uFunctions.readStartupSetting then
    chkRunstart.IsChecked := true
    else
    chkRunstart.IsChecked := false;
  chkUserename.IsChecked := uFunctions.RENAMING;
  loadUI;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  WinHandle: HWND;
begin
  if (TOSVersion.Major = 6) and (TOSVersion.Minor > 0) or (TOSVersion.Major > 6)
  then
  begin
    WinHandle := WindowHandleToPlatform(Self.Handle).Wnd;
    SetWindowDisplayAffinity(WinHandle, WDA_MONITOR);
  end;
end;

procedure TfrmMain.loadUI;
begin
  lbllang.Text := uLang.rsLang;
  lblmonitors.Text := uLang.rsMonitor;
  chkRunstart.Text := ulang.rsRunApp;
  chkUserename.Text := ulang.rsUseRename;
  btnSave.Text := uLang.rsSave;
  var itemindex := cmbMonitors.ItemIndex;
  cmbMonitors.Items.Clear;
  cmbMonitors.Items.Add(uLang.rsMonitor_p);
  cmbMonitors.Items.Add(uLang.rsMonitor_a);
  cmbMonitors.ItemIndex := itemindex;
  if uFunctions.getProcessRunning then begin
    btnProtection.Text := uLang.rsProtection;
    btnProtection.ImageIndex := 2;
  end else begin
    btnProtection.Text := uLang.rsProtection;
    btnProtection.ImageIndex := 1;
  end;
  btnDocs.Hint := uLang.rsHintDocs;
  btnAbout.Hint := uLang.rsHintAbout;
  btnExtract.Hint := uLang.rsHintExtract;
  btnLogs.Hint := uLang.rsHintLogs;
  btnParams.Hint := uLang.rsHintParams;
end;

procedure TfrmMain.timercontrolTimer(Sender: TObject);
begin
  checkProc;
end;

procedure TfrmMain.timerTimer(Sender: TObject);
begin
  timer.Enabled := false;
  lblStatus.Text := '';
end;

end.
