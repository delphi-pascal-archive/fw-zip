////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : FWZip
//  * Unit Name : CreateZIPDemo2
//  * Purpose   : Демонстрация изменения добавленных записей
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

// Данный пример показывает различные варианты изменения записей
// в еще не сформированном архиве.

program CreateZIPDemo2;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  ZLib,
  FWZipWriter;

var
  Zip: TFWZipWriter;
  Item: TFWZipWriterItem;
  I: Integer;
begin
  try
    Zip := TFWZipWriter.Create;
    try
      // Для начала добавим в корень архива файлы из корневой директории
      Zip.AddFolder('', '..\..\', '*.*', False);

      // Теперь изменим им свойства:
      for I := 0 to Zip.Count - 1 do
      begin
        Item := Zip[I];
        // Изменим коментарий
        Item.Comment := 'Тестовый коментарий к файлу ' + Item.FileName;
        // Установим пароль
        Item.Password := 'password';
        // Изменим тип сжатия
        Item.CompressionLevel := TCompressionLevel(Byte(I mod 3));
      end;

      // Теперь каждый элемент архива имеет коментарий, зашифрован паролем и
      // имеет собственную степень сжатия в зависимости от своей
      // порядковой позиции в архиве.
      // Ну и сам архив так-же имеет коментарий.
      Zip.Commets := 'Тестовый коментарий ко всему архиву';
      ForceDirectories('..\DemoResults\');
      Zip.BuildZip('..\DemoResults\CreateZIPDemo2.zip');
    finally
      Zip.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
