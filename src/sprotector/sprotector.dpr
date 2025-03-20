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

program sprotector;

{$R *.res}

{$APPTYPE GUI}

uses
  System.SysUtils,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Winapi.Windows,
  Vcl.Graphics,
  System.Math,
  Winapi.AccCtrl,
  System.IOUtils,
  Winapi.AclAPI,
  uScreenBlocker in 'uScreenBlocker.pas' {SBForm};

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

var
  AppForms: TArray<TSBForm>;
const
  SECURITY_MAX_SID_SIZE = 68;
  SECURITY_LOCAL_SYSTEM_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_CREATOR_OWNER_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (Value: (0, 0, 0, 0, 0, 9));
  ACL_REVISION = 2;

procedure HideTaskbar;
var
  handle: HWND;
  lngptr: LONG_PTR;
begin
  handle := Application.Handle;
  ShowWindow(handle, SW_HIDE);
  lngptr := GetWindowLongPtr(handle, GWL_EXSTYLE);
  SetWindowLongPtr(handle, GWL_EXSTYLE, (lngptr and not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW);
end;

procedure writeLog(msg: string);
var
  tmpfile: string;
begin
  tmpfile := GetEnvironmentVariable('TEMP') + '\screenprotector.log';
  try
    TFile.AppendAllText(tmpfile, DateTimeToStr(Now) + #9 + ': ' + msg + sLineBreak + '--------------------------------------------------' + sLineBreak, TEncoding.UTF8);
  except
  end;
end;

function getRandomName: string;
var
  i,rnd1, rnd2: integer;
  fname: string;
  const charset = 'abcdefghijklmnopqrstuvwxyz';
begin
  Randomize;
  fname := '';
  rnd1 := RandomRange(4, 30) - 1;
  for i := 0 to rnd1 do begin
    rnd2 := RandomRange(0, charset.Length - 1);
    fname := fname+ charset.Substring(rnd2, 1);
  end;
  Result := fname;
end;

procedure RestrictProcess;
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


begin
  if (TOSVersion.Major = 6) and (TOSVersion.Minor = 0) or (TOSVersion.Major < 6) or (TOSVersion.Platform <> pfWindows)then
  begin
    writeLog('Unsupported OS! ScreenProtector >= Win7');
    Application.Terminate;
  end;
  var MutexHandle: THandle;
  var i: integer;
  MutexHandle := CreateMutex(nil, True, 'Global\_SProtector_');
  if (MutexHandle <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    ExitProcess(0);
  end;
  RestrictProcess;
  try
    Application.Initialize;
    var params: string;
    params := ParamStr(1);
    if params = '-p' then begin
      SetLength(AppForms, 1);
      var TargetMonitor: TMonitor;
      TargetMonitor := Screen.PrimaryMonitor;
      AppForms[0] := TSBForm.Create(nil);
      AppForms[0].Caption := getRandomName;
      AppForms[0].Width := TargetMonitor.Width;
      AppForms[0].Height := TargetMonitor.Height;
      AppForms[0].Left := TargetMonitor.Left;
      AppForms[0].Top := TargetMonitor.Top;
      AppForms[0].Color := clWhite;
      AppForms[0].TransparentColor := True;
      AppForms[0].TransparentColorValue := clWhite;
      AppForms[0].BorderStyle := bsNone;
      AppForms[0].FormStyle := fsStayOnTop;
      AppForms[0].WindowState := wsMaximized;
      AppForms[0].Show;
      if (TOSVersion.Major = 6) and (TOSVersion.Minor > 0) or (TOSVersion.Major > 6) then
            SetWindowDisplayAffinity(AppForms[0].Handle, WDA_MONITOR);
    end else if params = '-a' then begin
      SetLength(AppForms, Screen.MonitorCount);
      var monlen: integer := Screen.MonitorCount - 1;
      for i := 0 to monlen do begin
        var TargetMonitor: TMonitor;
        TargetMonitor := Screen.Monitors[i];
        AppForms[i] := TSBForm.Create(nil);
        AppForms[i].Caption := getRandomName;
        AppForms[i].Width := TargetMonitor.Width;
        AppForms[i].Height := TargetMonitor.Height;
        AppForms[i].Left := TargetMonitor.Left;
        AppForms[i].Top := TargetMonitor.Top;
        AppForms[i].Color := clWhite;
        AppForms[i].TransparentColor := True;
        AppForms[i].TransparentColorValue := clWhite;
        AppForms[i].BorderStyle := bsNone;
        AppForms[i].FormStyle := fsStayOnTop;
        AppForms[i].WindowState := wsMaximized;
        AppForms[i].Show;
        if (TOSVersion.Major = 6) and (TOSVersion.Minor > 0) or (TOSVersion.Major > 6) then
            SetWindowDisplayAffinity(AppForms[i].Handle, WDA_MONITOR);
      end;
    end else
      ExitProcess(0);
    HideTaskbar;
    repeat
      Sleep(10);
      Application.ProcessMessages;
    until (false);
  except
    on E: Exception do
      writeLog('Error code: 410');
  end;
end.
