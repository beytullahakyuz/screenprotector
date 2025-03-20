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

unit uLang;

interface

var rsLang, rsMonitor, rsRunApp, rsUseRename, rsSave, rsPermissions, rsConfigPermission,
    rsAbout, rsSaveSettings, rsProtection, rsMonitor_p, rsMonitor_a, rsLogError, rsParams,
    rsHelpWarning, rsHelpCaption, rsHelpHeader1, rsHelpHeader2, rsHelpH1S2, rsHelpH1S3, rsHelpH2S2, rsHelpH2S3,
    rsHintParams, rsHintLogs, rsHintDocs, rsHintAbout, rsHintExtract, rsExtractSuccess: string;

procedure loadLang(code: string);

implementation

procedure loadLang(code: string);
begin
  if code = 'en' then begin
    rsLang := 'Language:';
    rsMonitor := 'Monitor:';
    rsSave := 'Save';
    rsProtection := 'Protection';
    rsRunApp := 'Run application at windows startup';
    rsUseRename := 'Enable renaming for protection';
    rsAbout := 'Version: 1.0' + sLineBreak + 'License: GPLv3' + sLineBreak + 'Developer: beytullahakyuz' + sLineBreak + sLineBreak + 'Icons: Icons8.com/Pichon8';
    rsSaveSettings := 'Settings saved successfully';
    rsMonitor_p  := 'Primary';
    rsMonitor_a := 'All';
    rsPermissions := 'Not working! Please check permissions.';
    rsConfigPermission := 'Could not be saved! Please check permission.';
    rsLogError := 'Log file not found!';
    rsHelpWarning := 'Warning: The application cleans the .exe files in the folder it is in every time it is run. Do not keep a different .exe file in the folder where the application is located!';
    rsHelpCaption := 'Help';
    rsHelpH1S2 := 'sprotector.exe is extracting to the application location.';
    rsHelpH1S3 := 'Run' + sLineBreak + 'sprotector.exe';
    rsHelpH2S2 := 'sprotector.exe is extracting to the application location and randomly renaming. (for example: asdfsd.exe)';
    rsHelpH2S3 := 'Run renamed application.' + slinebreak+ 'asdfsd.exe';
    rsHelpHeader1 := 'When application working without renaming';
    rsHelpHeader2 := 'When application working with renaming';
    rsHintParams := 'View sprotector params';
    rsHintExtract := 'Extract sprotector app on application location. (file name: _sprotector.exe)';
    rsHintDocs := 'Visit docs website';
    rsHintLogs := 'View error logs';
    rsHintAbout := 'About';
    rsParams := 'sprotector.exe params' + sLineBreak + '------------------------------------' + sLineBreak + '-p: Primary Monitor' +
                sLineBreak + '-a: All Monitors' + sLineBreak + sLineBreak + 'Example usage: sprotector.exe -p';
    rsExtractSuccess := 'sprotector application extracted successfully.';
  end else begin
    rsLang := 'Dil:';
    rsMonitor := 'Monitör:';
    rsSave := 'Kaydet';
    rsProtection := 'Koruma';
    rsRunApp := 'Uygulamayý windows açýlýþýnda çalýþtýr';
    rsUseRename := 'Koruma için yeniden adlandýrmayý etkinleþtir';
    rsAbout := 'Sürüm: 1.0' + sLineBreak + 'Lisans: GPLv3' + sLineBreak + 'Geliþtirici: beytullahakyuz' + sLineBreak + sLineBreak + 'Simgeler: Icons8.com/Pichon8';
    rsSaveSettings := 'Ayarlar baþarýyla kaydedildi.';
    rsMonitor_p := 'Birincil';
    rsMonitor_a := 'Tümü';
    rsPermissions := 'Çalýþmýyor! Lütfen yetkileri kontrol edin.';
    rsConfigPermission := 'Kaydedilemedi! Lütfen yetkileri kontrol edin.';
    rsLogError := 'Hata kayýtlarý bulunamadý!';
    rsHelpWarning := 'Uyarý: Uygulama her çalýþtýrýldýðýnda bulunduðu klasördeki .exe dosyalarýný temizler. Uygulamanýn bulunduðu klasörde farklý bir .exe dosyasý bulundurmayýnýz!';
    rsHelpCaption := 'Yardým';
    rsHelpH1S2 := 'sprotector.exe uygulama konumuna çýkartýlýr.';
    rsHelpH1S3 := 'sprotector.exe çalýþtýrýlýr.';
    rsHelpH2S2 := 'sprotector.exe uygulama konumuna çýkartýlýr ve rastgele yeniden adlandýrýlýr.(örneðin: asdfsd.exe)';
    rsHelpH2S3 := 'Yeniden adlandýrýlan uygulama çalýþtýrýlýr.' + slinebreak+ 'asdfsd.exe';
    rsHelpHeader1 := 'Yeniden adlandýrýlmadan uygulamanýn çalýþmasý';
    rsHelpHeader2 := 'Yeniden adlandýrýlarak uygulamanýn çalýþmasý';
    rsHintParams := 'sprotector parametrelerini göster';
    rsHintExtract := 'sprotector uygulamasýný uygulama konumuna çýkarýn. (dosya adý: _sprotector.exe)';
    rsHintDocs := 'Dökümanlar sitesini ziyaret et.';
    rsHintLogs := 'Hata kayýtlarýný görüntüle';
    rsHintAbout := 'Hakkýnda';
    rsParams := 'sprotector.exe paramatreleri' + sLineBreak + '------------------------------------' + sLineBreak + '-p: Birincil Monitör' +
                sLineBreak + '-a: Tüm Monitörler' + sLineBreak + sLineBreak + 'Örnek kullaným: sprotector.exe -p';
    rsExtractSuccess := 'sprotector uygulamasý baþarýyla çýkartýldý.';
  end;
end;

end.
