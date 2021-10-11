////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : FWZip
//  * Unit Name : CreateZIPDemo1
//  * Purpose   : ������������ �������� ������ ��������� ���������
//  *           : �������� ���������� ������
//  * Author    : ��������� (Rouse_) ������
//  * Copyright : � Fangorn Wizards Lab 1998 - 2011.
//  * Version   : 1.0.1
//  * Home Page : http://rouse.drkb.ru
//  ****************************************************************************
//
//  ������������ ���������:
//  ftp://ftp.info-zip.org/pub/infozip/doc/appnote-iz-latest.zip
//  http://zlib.net/zlib-1.2.5.tar.gz
//

// ��������!!!
// ������ ��� �������� ���������������� � �������� � ������� �� ������������� �����.
// ���� ��������� ��� �� �� ��� ���������, �� ������������� ���� ����� �������
// �� ������������ ������� CMD.EXE ��� �������� � ������ ������, ���
// ���������� ������� ������������� �������� ����������.

// ������ ������ ���������� ��������� �������� ���������� ���������� � �����
// ��� ������� �� �������� ���������� � ������ ����� ������� ��������� �����

program CreateZIPDemo1;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  FWZipWriter;

  procedure CheckResult(Value: Integer);
  begin
    if Value < 0 then
      raise Exception.Create('������ ���������� ������');
  end;

var
  Zip: TFWZipWriter;
  S: TStringStream;
  PresentFiles: TStringList;
  SR: TSearchRec;
  I: Integer;
begin
  try
    Zip := TFWZipWriter.Create;
    try
      // ������� ������� � ����� ����� � �����
      // �� ������������ ��������� �� �����

      // ������� � ��������� ��������� ���� � ������ ������
      S := TStringStream.Create('�������� ��������� ���� �1');
      try
        S.Position := 0;
        CheckResult(Zip.AddStream('Test.txt', S));
      finally
        S.Free;
      end;

      // ��� ���������� ����� � ������������ �����
      // ���������� ������� �� ������� � ���� � �����, �������� ��� ���
      S := TStringStream.Create('�������� ��������� ���� �2');
      try
        S.Position := 0;
        CheckResult(Zip.AddStream(
          'AddStreamData\SubFolder1\Subfolder2\Test.txt', S));
      finally
        S.Free;
      end;

      // ������ ����� �������� ��� �������� ���������� ������
      // ��������� �������������� �� �����

      // ������� ������:
      // ��������� ���������� ����� �������� ���������� � ����� AddFolder
      if Zip.AddFolder('AddFolder', '..\..\', '*.*', False) = 0 then
        raise Exception.Create('������ ���������� ������');

      // ������� ������. ���������� ��-�� ����� �� �������� ����������,
      // ������ ��������� ����� ������
      PresentFiles := TStringList.Create;
      try
        // ��� ������ �� ��� ������
        if FindFirst('..\..\*.pas', faAnyFile, SR) = 0 then
        try
          repeat
            if (SR.Name = '.') or (SR.Name = '..') then Continue;
            if SR.Attr and faDirectory <> 0 then
              Continue
            else
              PresentFiles.Add(SR.Name);
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;

        // ������ ������� �� ������,
        // �������� � ����� ����� � ��� ����� ������ �� ���������.
        for I := 0 to PresentFiles.Count - 1 do
          CheckResult(Zip.AddFile('..\..\' + PresentFiles[I],
            'AddFileOrFolder\' + PresentFiles[I]));

        // � ��������� ������� ���������� - ���������� �������.
        // ������ ������� ������ ����� ���� ����������� ��������� �������:
        // "������������� ���� � ��� � ������"="���� � �����"
        // �.�. ValueFromIndex ��������� �� ���� � �����,
        // � Names - ������������� ����
        for I := 0 to PresentFiles.Count - 1 do
          PresentFiles[I] :=
            'AddFiles\' + PresentFiles[I] + '=' + '..\..\' + PresentFiles[I];
        if Zip.AddFiles(PresentFiles) <> PresentFiles.Count then
          raise Exception.Create('������ ���������� ������');
      finally
        PresentFiles.Free;
      end;

      // ��� ���������� � ��� - �������� ������� ��� �����
      ForceDirectories('..\DemoResults\');
      Zip.BuildZip('..\DemoResults\CreateZIPDemo1.zip');

    finally
      Zip.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
