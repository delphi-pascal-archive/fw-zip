////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : FWZip
//  * Unit Name : CreateZIPDemo1
//  * Purpose   : Демонстрация создания архива используя различные
//  *           : варианты добавления данных
//  * Author    : Александр (Rouse_) Багель
//  * Copyright : © Fangorn Wizards Lab 1998 - 2011.
//  * Version   : 1.0.1
//  * Home Page : http://rouse.drkb.ru
//  ****************************************************************************
//
//  Используемые источники:
//  ftp://ftp.info-zip.org/pub/infozip/doc/appnote-iz-latest.zip
//  http://zlib.net/zlib-1.2.5.tar.gz
//

// ВНИМАНИЕ!!!
// Данный код является демонстрационным и работает с данными по относительным путям.
// Если запускать код не из под отладчика, то относительный путь будет браться
// от расположения утилиты CMD.EXE что приведет к ошибке работы, ибо
// приозойдет попытка архивирования корневой директории.

// Данный пример показывает различные варианты добавления информации в архив
// Для каждого из способов добавления в архиве будет создана отдельная папка

program CreateZIPDemo1;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  FWZipWriter;

  procedure CheckResult(Value: Integer);
  begin
    if Value < 0 then
      raise Exception.Create('Ошибка добавления данных');
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
      // Сначала добавим в архив файлы и папки
      // не существующие физически на диске

      // Создаем и добавляем текстовый файл в корень архива
      S := TStringStream.Create('Тестовый текстовый файл №1');
      try
        S.Position := 0;
        CheckResult(Zip.AddStream('Test.txt', S));
      finally
        S.Free;
      end;

      // Для сохранении файла в определенной папке
      // достаточно указать ее наличие в пути к файлу, например вот так
      S := TStringStream.Create('Тестовый текстовый файл №2');
      try
        S.Position := 0;
        CheckResult(Zip.AddStream(
          'AddStreamData\SubFolder1\Subfolder2\Test.txt', S));
      finally
        S.Free;
      end;

      // Теперь будут показаны три варианта добавления файлов
      // физически присутствующих на диске

      // Вариант первый:
      // добавляем содержимое нашей корневой директории в папку AddFolder
      if Zip.AddFolder('AddFolder', '..\..\', '*.*', False) = 0 then
        raise Exception.Create('Ошибка добавления данных');

      // Вариант второй. Используем те-же файлы из корневой директории,
      // Только добавлять будем руками
      PresentFiles := TStringList.Create;
      try
        // Для начала их все найдем
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

        // Теперь добавим по одному,
        // указывая в какой папке и под каким именем их размещать.
        for I := 0 to PresentFiles.Count - 1 do
          CheckResult(Zip.AddFile('..\..\' + PresentFiles[I],
            'AddFileOrFolder\' + PresentFiles[I]));

        // И последний вариант добавления - добавление списком.
        // Каждый элемент списка долен быть сформирован следующим образом:
        // "Относительный путь и имя в архиве"="Путь к файлу"
        // Т.е. ValueFromIndex указывает на путь к файлу,
        // а Names - относительный путь
        for I := 0 to PresentFiles.Count - 1 do
          PresentFiles[I] :=
            'AddFiles\' + PresentFiles[I] + '=' + '..\..\' + PresentFiles[I];
        if Zip.AddFiles(PresentFiles) <> PresentFiles.Count then
          raise Exception.Create('Ошибка добавления данных');
      finally
        PresentFiles.Free;
      end;

      // Вот собственно и все - осталось создать сам архив
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
