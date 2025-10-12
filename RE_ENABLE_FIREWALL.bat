@echo off
echo ================================================
echo Re-enable Windows Firewall
echo ================================================
echo.
echo This will turn your firewall back on.
echo.
pause

netsh advfirewall set allprofiles state on

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS! Firewall re-enabled.
    echo ================================================
    echo.
) else (
    echo.
    echo ERROR: Run this file as Administrator!
    echo.
)

pause










