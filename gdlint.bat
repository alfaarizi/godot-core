@echo off
setlocal
set VENV_DIR=.gdlint-venv
set ACTIVATE=%VENV_DIR%\Scripts\activate.bat
set PIP=%VENV_DIR%\Scripts\pip.exe
set GDLINT=%VENV_DIR%\Scripts\gdlint.exe

:activate_venv
if not exist "%VENV_DIR%" (
    echo Setting up GDLint environment...
    python -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo Failed to create virtual environment.
        exit /b 1
    )
)
call "%ACTIVATE%"
if not exist "%GDLINT%" (
    echo Installing gdtoolkit...
    "%PIP%" install --upgrade pip
    "%PIP%" install "gdtoolkit==4.*"
    if errorlevel 1 (
        echo Failed to install gdtoolkit.
        exit /b 1
    )
)
goto :eof

:run_lint
call :activate_venv
for /f "delims=" %%f in ('dir /b /s *.gd ^| findstr /v /g:.gdlintignore') do (
    "%GDLINT%" "%%f"
)
goto :eof

:create_hook
call :activate_venv
set HOOK_PATH=.git\hooks\pre-commit
if exist "%HOOK_PATH%" (
    echo Warning: %HOOK_PATH% already exists. It will be overwritten.
)
mkdir .git\hooks 2>nul
> "%HOOK_PATH%" (
    echo @echo off
    echo setlocal
    echo set VENV_DIR=.gdlint-venv
    echo call %VENV_DIR%\Scripts\activate.bat
    echo for /f "delims=" %%%%f in ^('git diff --cached --name-only --diff-filter=ACMR ^| findstr "\.gd$"^) do (
    echo     echo %%%%f ^| findstr /v /g:.gdlintignore ^>nul && %VENV_DIR%\Scripts\gdlint.exe %%%%f || (
    echo         echo GDLint failed. Fix issues before committing.
    echo         exit /b 1
    echo     )
    echo )
    echo exit /b 0
)
echo Git pre-commit hook installed.
goto :eof


:delete_venv
if exist "%VENV_DIR%" (
    echo Deleting GDLint virtual environment...
    rmdir /s /q "%VENV_DIR%"
    echo Virtual environment removed.
) else (
    echo No virtual environment found at %VENV_DIR%
)
goto :eof

:usage
echo GDLint Tool. Usage: gdlint-tool.bat [setup^|check^|hook]
echo   setup    - Install GDLint in a local environment
echo   check    - Run GDLint on all GDScript files
echo   hook     - Set up a Git pre-commit hook
echo   cleanup  - Delete the local GDLint virtual environment
exit /b 1

:: Entry point
if "%1" == "setup" (
    call :activate_venv
    echo GDLint setup complete!
    exit /b
) else if "%1" == "check" (
    call :run_lint
    exit /b
) else if "%1" == "hook" (
    call :create_hook
    exit /b
) else if "%1" == "clean" (
    call :delete_venv
    exit /b
) else (
    call :usage
)