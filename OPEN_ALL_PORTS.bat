@echo off
echo ================================================
echo Pango - Open All Required Ports
echo ================================================
echo.
echo This will add firewall rules for:
echo   - Port 3000 (Main Backend)
echo   - Port 8080 (Test Server)
echo.
echo You need to run this as Administrator!
echo.
pause

netsh advfirewall firewall delete rule name="Pango Backend" >nul 2>&1
netsh advfirewall firewall delete rule name="Pango Test" >nul 2>&1

netsh advfirewall firewall add rule name="Pango Backend" dir=in action=allow protocol=TCP localport=3000
netsh advfirewall firewall add rule name="Pango Test" dir=in action=allow protocol=TCP localport=8080

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS! Ports opened.
    echo ================================================
    echo.
    echo Test on your phone browser:
    echo   http://192.168.1.106:3000/health
    echo   http://192.168.1.106:8080
    echo.
) else (
    echo.
    echo ERROR: Run as Administrator!
    echo.
)

pause






