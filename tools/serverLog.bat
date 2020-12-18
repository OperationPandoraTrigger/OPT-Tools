@ECHO OFF
ECHO ******************************************
ECHO *** OPT-DevServer LogfileViewer v0.1   ***
ECHO *** This script will provide a         ***
ECHO *** live-view of the server logfile.   ***
ECHO ******************************************

REM Sanity checks
IF NOT EXIST "%~dp0.\..\settings\setMetaData.bat" (
	ECHO setMetaData.bat not found in "settings".
	ECHO "Check your configuration. (Rename example-file and adjust paths)"
	ECHO Press any key to exit.
	PAUSE > NUL
	EXIT 1
)

REM Set meta infos
CALL "%%~dp0.\..\settings\setMetaData.bat"

REM change directory to ArmA directory (in which the server-exe resides)
CD /D "%ArmaGameDir%"

REM Loop until (at least one) logfile is found
:LOOPLOGFILE
IF EXIST "OPT_DevServer\*.rpt" GOTO GETLOGFILE
ECHO No logfile found yet. Waiting a bit...
CALL "%%~dp0.\..\helpers\sleep.bat" 250
GOTO LOOPLOGFILE

REM Get filename of the last logfile
:GETLOGFILE
FOR /F "TOKENS=1" %%a IN ('DIR /B /O-N "OPT_DevServer\*.rpt"') DO (
	SET "LOGFILE=%%a"
	GOTO SHOWLOG
)

REM Show logfile in new powershell-window
:SHOWLOG
ECHO Opening new powershell window to show the logfile...
START POWERSHELL -command "Get-Content OPT_DevServer\%LOGFILE% -Wait -Tail 30"

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
