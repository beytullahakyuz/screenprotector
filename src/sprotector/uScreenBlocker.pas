unit uScreenBlocker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TSBForm = class(TForm)
    timer: TTimer;
    procedure timerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SBForm: TSBForm;

implementation

{$R *.dfm}

procedure TSBForm.timerTimer(Sender: TObject);
begin
  SetWindowPos(Self.Handle, 0, Self.Left, Self.Top, Self.Width, Self.Height, 0);
end;

end.
