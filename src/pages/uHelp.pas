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

unit uHelp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Header, FMX.Objects,
  FMX.Memo.Types, uFunctions, uLang, Winapi.Windows, FMX.Platform.Win;

type
  TfrmHelp = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    Rectangle1: TRectangle;
    Panel1: TPanel;
    lblHeader1: TLabel;
    Panel2: TPanel;
    Label2: TLabel;
    Path3: TPath;
    Rectangle2: TRectangle;
    lblH1S2: TLabel;
    Path4: TPath;
    Rectangle3: TRectangle;
    lblH1S3: TLabel;
    Panel3: TPanel;
    lblHeader2: TLabel;
    Panel4: TPanel;
    Rectangle4: TRectangle;
    Label6: TLabel;
    Path1: TPath;
    Rectangle5: TRectangle;
    lblH2S2: TLabel;
    Z: TRectangle;
    lblH2S3: TLabel;
    Path5: TPath;
    Rectangle6: TRectangle;
    lblWarning: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHelp: TfrmHelp;

implementation

{$R *.fmx}

procedure TfrmHelp.FormCreate(Sender: TObject);
begin
  lblHeader1.Text := uLang.rsHelpHeader1;
  lblHeader2.Text := uLang.rsHelpHeader2;
  lblWarning.Text := uLang.rsHelpWarning;
  lblH1S2.Text := uLang.rsHelpH1S2;
  lblH1S3.Text := uLang.rsHelpH1S3;
  lblH2S2.Text := uLang.rsHelpH2S2;
  lblH2S3.Text := uLang.rsHelpH2S3;
  self.Caption := uLang.rsHelpCaption;
end;

procedure TfrmHelp.FormShow(Sender: TObject);
var
  WinHandle: HWND;
begin
  WinHandle := WindowHandleToPlatform(Self.Handle).Wnd;
  SetWindowDisplayAffinity(WinHandle, WDA_MONITOR);
end;

end.
