////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : FWZip
//  * Unit Name : ExctractZIPDemo1
//  * Purpose   : ������������ ���������� ������.
//  *           : ������������ ����� ��������� ��������������� CreateZIPDemo1
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

// ������ ������ ���������� ��� �������� ���������� ���������� �� ������.

program ExctractZIPDemo1;

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  SysUtils,
  FWZipReader;

var
  Zip: TFWZipReader;
  Index: Integer;
  S: TStringStream;
  OemString: AnsiString;
begin
  try
    Zip := TFWZipReader.Create;
    try
      // ��������� ����� ��������� �����
      Zip.LoadFromFile('..\DemoResults\CreateZIPDemo1.zip');

      // ������ ������� ���������� - ������ ������ � ������� �������� ������

      // � ������� CreateZIPDemo1 �� ������� � ����� ������ ���� Test.txt
      // ��� ���������� �������� ������ ����� �������� � ������
      Index := Zip.GetElementIndex('test.txt');
      if Index >= 0 then
      begin
        // ����������� ����� � ������:
        S := TStringStream.Create('');
        try
          Zip[Index].ExtractToStream(S, '');
          // ���� ��������, ������� ��� ���������� � ���� �������
          OemString := AnsiString(S.DataString);
          AnsiToOem(PAnsiChar(OemString), PAnsiChar(OemString));
          Writeln(OemString);
        finally
          S.Free;
        end;

        // ����������� ���-�� ����� �� ����:
        Zip[Index].Extract('..\DemoResults\CreateZIPDemo1\ManualExtract\', '');
      end;

      // �����-�� ������� ����� �������� ���������� ��������� ������

      // ������ ������� ���������� - �������������� ���������� ������
      // � ��������� ����� �� �����
      Zip.ExtractAll('..\DemoResults\CreateZIPDemo1\');
    finally
      Zip.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
