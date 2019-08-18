@ECHO OFF
ECHO *************************************************
ECHO *** OPT-DevServer stopper v0.3                ***
ECHO *** This script stops a local arma dev-server ***
ECHO *************************************************

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

REM Kill the server
REM The loop occurs as long as the killing reports a success status as this means
REM there was a server process in the process table that was sent a kill-signal
REM However this also means that the server is still running and as Windows doesn't really
REM kill the program, we have to continously send the signal until the server is actually dead

ECHO Killing the (potentially) running server. This might take a while...
:SoftKillLoop
TASKKILL /IM %ArmaServerExe% > NUL 2>&1
IF [%errorlevel%] == [0] (
	REM sleep 100ms
	CALL "%%~dp0.\..\helpers\sleep.bat" 100
	GOTO SoftKillLoop
) ELSE (
	:HardKillLoop
	REM sleep 100ms
	CALL "%%~dp0.\..\helpers\sleep.bat" 100

	REM Hardkill
	TASKKILL /F /IM %ArmaServerExe% > NUL 2>&1

	REM Task still active? -> Loop again
	TASKLIST /FI "IMAGENAME EQ %ArmaServerExe%" 2> NUL | FIND /I /N "%ArmaServerExe%" > NUL
	IF "%ERRORLEVEL%"=="0" GOTO HardKillLoop

	REM Check (for reappearing ghost-process) again after short delay
	CALL "%%~dp0.\..\helpers\sleep.bat" 100
	TASKLIST /FI "IMAGENAME EQ %ArmaServerExe%" 2> NUL | FIND /I /N "%ArmaServerExe%" > NUL
	IF "%ERRORLEVEL%"=="0" GOTO HardKillLoop
)
ECHO.
ECHO Successfully killed the server

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
