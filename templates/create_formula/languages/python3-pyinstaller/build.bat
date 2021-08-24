:: Python parameters
echo off
SETLOCAL
SET BIN_FOLDER=bin
SET BIN_WINDOWS=%BIN_FOLDER%\windows
SET SRC_FOLDER=src
SET BAT_FILE=%BIN_FOLDER%\run.bat

:build
    call :checkCommand python3
    call :checkCommand pip3
    call :checkCommand pyinstaller

    mkdir %BIN_FOLDER%
    pip3 install -r %SRC_FOLDER%/requirements.txt

    CALL :BAT_WINDOWS
    CALL :CP_DOCKER
    CALL :PYTHON_BIN
    GOTO DONE

:PYTHON_BIN
    pyinstaller -y --distpath %BIN_WINDOWS% --onefile --clean %SRC_FOLDER%\main.py
    rmdir /S /Q %SRC_FOLDER%\__pycache__
    rmdir /S /Q build
    GOTO DONE

:BAT_WINDOWS
    echo @ECHO OFF > %BAT_FILE%
    echo SET mypath=%%~dp0 >> %BAT_FILE%
    echo start /B /D "%%mypath%%" /WAIT ./windows/main.exe >> %BAT_FILE%

:CP_DOCKER
    copy Dockerfile %BIN_FOLDER%
    copy set_umask.sh %BIN_FOLDER%
    GOTO DONE

:checkCommand
    WHERE %1 >nul 2>nul
    IF %ERRORLEVEL% NEQ 0 ECHO %1 required 1>&2 && exit 1

:DONE
