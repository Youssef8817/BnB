@echo off
:: ==========================================
:: BnB Full Stack Launcher
:: ==========================================
:: HOW TO RUN:
::   Double-click this file   OR
::   From PowerShell: Start-Process "D:\BnB\start.bat"
::
:: WHAT IT DOES:
::   1. Starts the Laravel API backend on http://0.0.0.0:8000
::      (accessible from emulator at http://10.0.2.2:8000)
::   2. Launches the Qt6 desktop admin app (bb-admin.exe)
::
:: TO RUN THE MOBILE APP (separately):
::   1. Open PowerShell
::   2. cd D:\BnB\BnB-Mobile
::   3. flutter emulators --launch Pixel_7
::   4. Wait ~10 seconds, then: flutter run -d emulator-5554
::
:: LOGIN CREDENTIALS:
::   Email    : admin@bb.com
::   Password : password
::
:: REQUIREMENTS:
::   - PHP 8.3 must be at C:\php83\php.exe
::   - bb-admin.exe must be built at D:\BnB\BnB-Desktop\build\
::   - Android SDK is at D:\Android\Sdk (env vars set permanently)
::   - Android AVDs are at D:\Android\avd
:: ==========================================

title B^&B Launcher

echo ==========================================
echo         B^&B Full Stack Launcher
echo ==========================================
echo.
echo  Backend  : http://0.0.0.0:8000  (emulator: http://10.0.2.2:8000)
echo  Login    : admin@bb.com
echo  Password : password
echo.
echo  For mobile: flutter run in D:\BnB\BnB-Mobile
echo.
echo ==========================================
echo.

:: Step 1: Start the Laravel backend in a new terminal window
:: Uses PHP 8.3 and artisan serve on port 8000
:: The window stays open (/k) so you can see backend logs
echo [1/2] Starting Laravel Backend...
start "BnB Backend" cmd /k "cd /d D:\BnB\BnB-Backend && C:\php83\php.exe artisan serve --host=0.0.0.0 --port=8000"

:: Wait 3 seconds for the backend to initialize before launching the app
echo Waiting for backend to start...
timeout /t 3 /nobreak > nul

:: Step 2: Launch the Qt6 desktop app
:: The app connects to the backend at http://127.0.0.1:8000
:: Prepend MSYS2 mingw64 bin so bb-admin.exe finds its runtime DLLs
:: (libgcc_s_seh-1.dll, libstdc++-6.dll, libwinpthread-1.dll, Qt6*.dll)
echo [2/2] Launching Desktop App...
set "PATH=C:\msys64\mingw64\bin;%PATH%"
start "" /D "D:\BnB\BnB-Desktop\build" "D:\BnB\BnB-Desktop\build\bb-admin.exe"

echo.
echo Both started! Close this window anytime.
echo.
echo To run mobile app:
echo   1. cd D:\BnB\BnB-Mobile
echo   2. flutter emulators --launch Pixel_7
echo   3. flutter run -d emulator-5554
pause
