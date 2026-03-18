@echo off
echo ========================================
echo Building StealthMorpher DLL
echo ========================================
echo.

if not exist build mkdir build
cd build

echo Running CMake configuration...
cmake .. -DCMAKE_BUILD_TYPE=Release -A Win32
if %errorlevel% neq 0 (
    echo.
    echo ERROR: CMake configuration failed!
    echo Make sure you have CMake and a C++ compiler installed.
    exit /b 1
)

echo.
echo Building Release configuration...
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Build failed!
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.

copy Release\Release\dinput8.dll ..\dinput8.dll >nul 2>&1
if not exist ..\dinput8.dll copy Release\dinput8.dll ..\dinput8.dll >nul 2>&1

echo The compiled DLL has been copied to:
echo %~dp0dinput8.dll
echo.
echo Copy this file to your WoW directory to use the updated morpher.
echo.
pause
