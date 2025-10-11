@echo off
echo ================================================
echo TEMPORARY: Disable Windows Firewall for Testing
echo ================================================
echo.
echo WARNING: This will temporarily disable your firewall.
echo Only for testing! Re-enable it after testing.
echo.
echo You need to run this as Administrator!
echo.
pause

netsh advfirewall set allprofiles state off

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS! Firewall temporarily disabled.
    echo ================================================
    echo.
    echo Now try to register in your mobile app.
    echo.
    echo IMPORTANT: After testing, run RE_ENABLE_FIREWALL.bat
    echo.
) else (
    echo.
    echo ERROR: Run this file as Administrator!
    echo.
)

pause






