@echo off
echo ================================================
echo Pango Backend - Windows Firewall Setup
echo ================================================
echo.
echo This will allow incoming connections on port 3000
echo so your mobile phone can connect to the backend.
echo.
echo You need to run this as Administrator!
echo.
pause

netsh advfirewall firewall delete rule name="Pango Backend" >nul 2>&1
netsh advfirewall firewall add rule name="Pango Backend" dir=in action=allow protocol=TCP localport=3000

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS! Firewall rule added.
    echo ================================================
    echo.
    echo Port 3000 is now accessible from your phone.
    echo Try registering again in your mobile app.
    echo.
) else (
    echo.
    echo ================================================
    echo ERROR: Failed to add firewall rule.
    echo ================================================
    echo.
    echo Please run this file as Administrator:
    echo   1. Right-click ENABLE_FIREWALL.bat
    echo   2. Select "Run as administrator"
    echo.
)

pause










