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

unit uFunctions;

interface

uses IniFiles, System.SysUtils, System.Math, ShellAPI, Winapi.Windows,
    System.Classes, System.IOUtils, System.Hash, Registry, FMX.Platform.Win;

var
  LANG, MONITOR, LOGFILE: string;
  RENAMING: Boolean;

procedure loadConfigs;
procedure writeConfigs(lang, monitor: string; rename: Boolean);
function getFileName: string;
function runApp(const Filename, Params: string; PriorityClass: DWORD): Boolean;
function getProcessRunning: Boolean;
procedure extractSP(exename: string);
procedure detectAppAndRemoveTemp(ptype: byte);
function checkAdmin: Boolean;
procedure writeLog(msg: string);
function shellExecuteAndWait(const FileName, Parameters: string; ShowCmd: Integer): Cardinal;
function readStartupSetting: Boolean;
function writeStartupSetting(install: integer; param: string): Boolean;
procedure HideTaskbar;

implementation

procedure loadConfigs;
var
  cFile: TIniFile;
begin
  LOGFILE := GetEnvironmentVariable('TEMP') + '\screenprotector.log';
  cFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  LANG := cFile.ReadString('settings', 'lang', 'en');
  MONITOR := cFile.ReadString('settings', 'monitor', '-a');
  RENAMING := cFile.ReadBool('settings', 'renaming', false);
  cFile.Free;
end;

procedure writeConfigs(lang, monitor: string; rename: Boolean);
var
  cFile: TIniFile;
begin
  cFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  cFile.WriteString('settings', 'lang', lang);
  cFile.WriteString('settings', 'monitor', monitor);
  cFile.WriteBool('settings', 'renaming', rename);
  cFile.Free;
end;

procedure HideTaskbar;
var
handle: HWND;
lngptr: LONG_PTR;
begin
  handle := FMX.Platform.Win.ApplicationHWND;
  ShowWindow(handle, SW_HIDE);
  lngptr := GetWindowLongPtr(handle, GWL_EXSTYLE);
  SetWindowLongPtr(handle, GWL_EXSTYLE, (lngptr and not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW);
end;

function getFileName: string;
var
  i,rnd1, rnd2: integer;
  fname: string;
  const charset = 'abcdefghijklmnopqrstuvwxyz';
begin
  Randomize;
  fname := '';
  rnd1 := RandomRange(4, 20) - 1;
  for i := 0 to rnd1 do begin
    rnd2 := RandomRange(0, charset.Length - 1);
    fname := fname+ charset.Substring(rnd2, 1);
  end;
  Result := Concat(fname, '.exe');
end;

function runApp(const Filename, Params: string; PriorityClass: DWORD): Boolean;
var
  SEInfo: TShellExecuteInfo;
begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  SEInfo.lpFile := PChar(Filename);
  SEInfo.lpParameters := PChar(Params);
  SEInfo.nShow := SW_NORMAL;
  Result := ShellExecuteEx(@SEInfo);
  if Result and (SEInfo.hProcess <> 0) then
  begin
    SetPriorityClass(SEInfo.hProcess, PriorityClass);
    CloseHandle(SEInfo.hProcess);
  end;
end;

function getProcessRunning: Boolean;
var
  MutexHandle: THandle;
  running: Boolean;
begin
  running := false;
  MutexHandle := OpenMutex(SYNCHRONIZE, false, 'Global\_SProtector_');
  if (MutexHandle <> 0) then
  begin
    CloseHandle(MutexHandle);
    running := true;
  end;
  Result := running;
end;

procedure extractSP(exename: string);
var
  ResStream: TResourceStream;
  FileStream: TFileStream;
  path: string;
begin
  SetLength(path, MAX_PATH);
  GetTempPath(MAX_PATH, PChar(path));
  path := ExtractFilePath(ParamStr(0)) + '\' + exename;

  ResStream := TResourceStream.Create(HInstance, 'sprotector', RT_RCDATA);
  try
    FileStream := TFileStream.Create(path, fmCreate);
    try
      FileStream.CopyFrom(ResStream, ResStream.Size);
    finally
      FileStream.Free;
    end;
  finally
    ResStream.Free;
  end;
end;

function ShellExecuteAndWait(const FileName, Parameters: string; ShowCmd: Integer): Cardinal;
var
  ExecInfo: TShellExecuteInfo;
  ProcessInfo: THandle;
begin
  ZeroMemory(@ExecInfo, SizeOf(ExecInfo));
  ExecInfo.cbSize := SizeOf(TShellExecuteInfo);
  ExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ExecInfo.Wnd := 0;
  ExecInfo.lpVerb := 'open';
  ExecInfo.lpFile := PChar(FileName);
  ExecInfo.lpParameters := PChar(Parameters);
  ExecInfo.lpDirectory := nil;
  ExecInfo.nShow := ShowCmd;

  if ShellExecuteEx(@ExecInfo) then
  begin
    ProcessInfo := ExecInfo.hProcess;
    WaitForSingleObject(ProcessInfo, INFINITE);
    GetExitCodeProcess(ProcessInfo, Result);
    CloseHandle(ProcessInfo);
  end
  else
    Result := GetLastError;
end;

procedure detectAppAndRemoveTemp(ptype: byte);
var
  SearchRec: TSearchRec;
  filename, filepath: string;

begin
  if FindFirst(ExtractFilePath(ParamStr(0)) + '*.exe', faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Attr and faDirectory) = 0 then
      begin
        filename := LowerCase(SearchRec.Name);
        if (filename <> ExtractFileName(ParamStr(0))) then begin
          filepath := '\' + SearchRec.Name;
          if (DeleteFile(PChar(ExtractFilePath(ParamStr(0)) + '\' + filename)) = false) then begin
            if ptype = 1 then begin
              ShellExecuteAndWait('cmd.exe', 'cmd /c taskkill /f /im ' + filename, SW_HIDE);
              detectAppAndRemoveTemp(0);
            end;
          end;
        end;
      end;
    until FindNext(SearchRec) <> 0;
  end;
end;

function checkAdmin: Boolean;
var
  hnd: THandle;
  TKELV: TOKEN_ELEVATION;
  size: DWORD;
begin
  Result := false;
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hnd) then begin
    size := SizeOf(TOKEN_ELEVATION);
    if GetTokenInformation(hnd, TokenElevation, @TKELV, sizeof(TKELV), size) then
      Result := Boolean(TKELV.TokenIsElevated);
    if hnd <> 0 then
      CloseHandle(hnd);
  end;
end;

procedure writeLog(msg: string);
begin
  try
    TFile.AppendAllText(logfile, DateTimeToStr(Now) + #9 + ': ' + msg + sLineBreak + '--------------------------------------------------' + sLineBreak, TEncoding.UTF8);
  except
  end;
end;

function readStartupSetting: Boolean;
var
  reg: TRegistry;
  app, regdata, apppath: string;
begin
  Result := false;
  reg := TRegistry.Create(KEY_READ);
  try
    if checkAdmin then
      reg.RootKey := HKEY_LOCAL_MACHINE
      else
      reg.RootKey := HKEY_CURRENT_USER;
    if not reg.OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion\Run') then begin
      Exit;
    end else begin
      app := TPath.GetFileNameWithoutExtension(ParamStr(0));
      regdata := reg.ReadString(app);
      apppath := ParamStr(0);
      reg.CloseKey;
      if regdata.IndexOf(apppath) >= 0 then
        Result := true;
    end;
  except
    reg.Free;
  end;
end;

function writeStartupSetting(install: integer; param: string): Boolean;
var
  reg: TRegistry;
  app: string;
begin
  Result := false;
  reg := TRegistry.Create(KEY_WRITE);
  try
    if checkAdmin then
      reg.RootKey := HKEY_LOCAL_MACHINE
      else
      reg.RootKey := HKEY_CURRENT_USER;
    if not reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', true) then begin
      Exit;
    end else begin
      app := TPath.GetFileNameWithoutExtension(ParamStr(0));
      if install = 1 then
        reg.WriteString(app, '"' + ParamStr(0) + '"' + param)
        else
        reg.DeleteValue(app);
      reg.CloseKey;
      Result := true;
    end;
  except
    reg.Free;
  end;
end;

end.
