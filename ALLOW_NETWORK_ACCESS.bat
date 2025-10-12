@echo off
echo.
echo =========================================
echo   Adding Windows Firewall Rule
echo   for Node.js Backend Server
echo =========================================
echo.

REM Add inbound rule for port 3000
netsh advfirewall firewall add rule name="Pango Backend Port 3000" dir=in action=allow protocol=TCP localport=3000

REM Add rule for Node.js executable
netsh advfirewall firewall add rule name="Pango Node.js Server" dir=in action=allow program="%ProgramFiles%\nodejs\node.exe" enable=yes

echo.
echo =========================================
echo   Firewall Rules Added Successfully!
echo =========================================
echo.
echo You can now access the backend from your phone
echo Network URL: http://192.168.1.106:3000/api/v1
echo.
pause





