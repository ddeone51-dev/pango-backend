@echo off
echo ================================================
echo Pango Backend - Proper Firewall Setup
echo ================================================
echo.
echo This will:
echo   1. Re-enable Windows Firewall (for security)
echo   2. Add rule to allow port 3000 (for Pango)
echo.
echo You need to run this as Administrator!
echo.
pause

echo.
echo Step 1: Re-enabling Windows Firewall...
netsh advfirewall set allprofiles state on

echo.
echo Step 2: Adding rule for port 3000...
netsh advfirewall firewall delete rule name="Pango Backend" >nul 2>&1
netsh advfirewall firewall add rule name="Pango Backend" dir=in action=allow protocol=TCP localport=3000

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS! Firewall configured properly.
    echo ================================================
    echo.
    echo Your firewall is ON (secure)
    echo Port 3000 is allowed (for Pango app)
    echo.
    echo Try registration again - it should work!
    echo.
) else (
    echo.
    echo ================================================
    echo ERROR: Failed to configure firewall.
    echo ================================================
    echo.
    echo Please run this file as Administrator:
    echo   1. Right-click FIX_FIREWALL.bat
    echo   2. Select "Run as administrator"
    echo.
)

pause






