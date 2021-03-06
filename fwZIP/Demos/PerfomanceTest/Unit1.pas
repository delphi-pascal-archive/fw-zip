unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FileCtrl, ComCtrls,
  FWZipWriter, FWZipReader, FWZipConsts, Contnrs;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    Button1: TButton;
    CheckBox1: TCheckBox;
    LabeledEdit2: TLabeledEdit;
    Button2: TButton;
    GroupBox2: TGroupBox;
    LabeledEdit3: TLabeledEdit;
    Button3: TButton;
    CheckBox2: TCheckBox;
    LabeledEdit4: TLabeledEdit;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    Label5: TLabel;
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure LabeledEdit1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure LabeledEdit3Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    InitialHeapSize, MaxHeapSize, AverageHeapSize: Int64;
    TotalGetHeapStatusCount: Integer;
    procedure OnProgress(Sender: TObject; const FileName: string;
      Percent, TotalPercent: Byte);
    procedure UpdateMemoryStatus;
    procedure SetEnabledState(Value: Boolean);
    procedure ClearZipData;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Dir: string;
begin
  if SelectDirectory('??????? ????? ??? ??????', '', Dir) then
    LabeledEdit1.Text := Dir;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  I: Integer;
  TotalSize: Int64;
  Heap: THeapStatus;
  TicCount: DWORD;
  Item: TFWZipWriterItem;
  Writer: TFWZipWriter;
begin
  Writer := TFWZipWriter.Create;
  try
    DeleteFile(
      IncludeTrailingPathDelimiter(LabeledEdit1.Text) + 'FWZipTest.zip');
    Writer.AddFolder('', LabeledEdit1.Text, '');
    TotalSize := 0;
    InitialHeapSize := 0;
    for I := 0 to Writer.Count - 1 do
    begin
      Item := Writer[I];
      Inc(TotalSize, Item.Size);
      Inc(InitialHeapSize, SizeOf(TCentralDirectoryFileHeaderEx));
//      Inc(InitialHeapSize, Length(Item.Comment));
//      Inc(InitialHeapSize, Length(Item.FilePath));
//      Inc(InitialHeapSize, Length(Item.FileName));
//      Inc(InitialHeapSize, Length(Item.Password));
      if LabeledEdit2.Text <> '' then
        Item.Password := AnsiString(LabeledEdit2.Text);
    end;
    Label3.Caption := '????? ?????????? ?????????: ' + IntToStr(Writer.Count);
    Label4.Caption := '????? ?????? ?????????: ' + IntToStr(TotalSize);
    Writer.OnProgress := OnProgress;
    SetEnabledState(False);
    try
      Heap := GetHeapStatus;
      Inc(InitialHeapSize, Heap.Overhead + Heap.TotalAllocated);
      MaxHeapSize := 0;
      AverageHeapSize := 0;
      TotalGetHeapStatusCount := 0;
      TicCount := GetTickCount;
      Writer.BuildZip(
        IncludeTrailingPathDelimiter(LabeledEdit1.Text) + 'FWZipTest.zip');
      if TotalGetHeapStatusCount = 0 then
        TotalGetHeapStatusCount := 1;
      ShowMessage(Format(
        '??????? ?????? ??????: %d ????' + sLineBreak +
        '??????? ?????? ??????: %d ????' + sLineBreak +
        '????? ????? ??????: %d ??????',
        [MaxHeapSize, AverageHeapSize div TotalGetHeapStatusCount,
         (GetTickCount - TicCount) div 1000]));
    finally
      SetEnabledState(True);
    end;
  finally
    Writer.Free;
    ClearZipData;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    LabeledEdit3.Text := OpenDialog1.FileName;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  I: Integer;
  TotalSize: Int64;
  Heap: THeapStatus;
  TicCount: DWORD;
  Path: string;
  Reader: TFWZipReader;
begin
  SetLength(Path, MAX_PATH);
  Path := LabeledEdit3.Text;
  Path := ChangeFileExt(Path, '');
  Reader := TFWZipReader.Create;
  try
    Reader.LoadFromFile(LabeledEdit3.Text);
    TotalSize := 0;
    for I := 0 to Reader.Count - 1 do
      Inc(TotalSize, Reader[I].UncompressedSize);
    Label3.Caption := '????? ?????????? ?????????: ' + IntToStr(Reader.Count);
    Label4.Caption := '????? ?????? ?????????: ' + IntToStr(TotalSize);
    Reader.OnProgress := OnProgress;
    if LabeledEdit4.Text <> '' then
      Reader.PasswordList.Add(LabeledEdit4.Text);
    SetEnabledState(False);
    try
      Heap := GetHeapStatus;
      InitialHeapSize := Heap.Overhead + Heap.TotalAllocated;
      MaxHeapSize := 0;
      AverageHeapSize := 0;
      TotalGetHeapStatusCount := 0;
      TicCount := GetTickCount;
      Reader.ExtractAll(Path);
      if TotalGetHeapStatusCount = 0 then
        TotalGetHeapStatusCount := 1;
      ShowMessage(Format(
        '??????? ?????? ??????: %d ????' + sLineBreak +
        '??????? ?????? ??????: %d ????' + sLineBreak +
        '????? ????? ??????: %d ??????',
        [MaxHeapSize, AverageHeapSize div TotalGetHeapStatusCount,
         (GetTickCount - TicCount) div 1000]));
    finally
      SetEnabledState(True);
    end;
  finally
    Reader.Free;
    ClearZipData;
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  LabeledEdit2.Enabled := CheckBox1.Checked;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  LabeledEdit4.Enabled := CheckBox2.Checked;
end;

procedure TForm1.ClearZipData;
begin
  Label1.Caption := '??????? ?????? ??????: 0 ????';
  Label2.Caption := '??????? ?????? ??????: 0 ????';
  Label3.Caption := '????? ?????????? ?????????: 0';
  Label4.Caption := '????? ?????? ?????????: 0';
  Label5.Caption := '';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
end;

procedure TForm1.LabeledEdit1Change(Sender: TObject);
begin
  Button2.Enabled := DirectoryExists(LabeledEdit1.Text);
end;

procedure TForm1.LabeledEdit3Change(Sender: TObject);
begin
  Button4.Enabled := FileExists(LabeledEdit3.Text);
end;

procedure TForm1.OnProgress(Sender: TObject; const FileName: string; Percent,
  TotalPercent: Byte);
begin
  Label5.Caption := FileName;
  ProgressBar1.Position := Percent;
  ProgressBar2.Position := TotalPercent;
  UpdateMemoryStatus;
end;

procedure TForm1.SetEnabledState(Value: Boolean);
begin
  Button1.Enabled := Value;
  Button2.Enabled := Value;
  Button3.Enabled := Value;
  Button4.Enabled := Value;
  LabeledEdit1.Enabled := Value;
  LabeledEdit2.Enabled := Value;
  LabeledEdit3.Enabled := Value;
  LabeledEdit4.Enabled := Value;
  CheckBox1.Enabled := Value;
  CheckBox2.Enabled := Value;
end;

procedure TForm1.UpdateMemoryStatus;
var
  HeapStatus: THeapStatus;
  HeapSize: Int64;
begin
  HeapStatus := GetHeapStatus;
  HeapSize := HeapStatus.Overhead + HeapStatus.TotalAllocated;
  Dec(HeapSize, InitialHeapSize);
  if HeapSize > MaxHeapSize then
    MaxHeapSize := HeapSize;
  Inc(TotalGetHeapStatusCount);
  Inc(AverageHeapSize, HeapSize);
  Label1.Caption := '??????? ?????? ??????: ' + IntToStr(HeapSize) + ' ????';
  Label2.Caption := '??????? ?????? ??????: ' + IntToStr(MaxHeapSize) + ' ????';
  Application.ProcessMessages;
end;

end.
