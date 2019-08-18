@ECHO OFF
ECHO ******************************************************************
ECHO *** OPT-Rebuild v0.5                                           ***
ECHO *** This script will rebuild all mission/mods. Running         ***
ECHO *** server/client will be shut down, and restarted afterwards. ***
ECHO ******************************************************************

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

REM Check for running ArmaServer and shutdown if running
TASKLIST /FI "IMAGENAME EQ %ArmaServerExe%" 2> NUL | FIND /I /N "%ArmaServerExe%" > NUL
IF "%ERRORLEVEL%"=="0" (
	SET ArmaServerActive=TRUE
	CALL "%%~dp0.\serverStop.bat" noPause
)

REM Check for running ArmaClient and shutdown if running
TASKLIST /FI "IMAGENAME EQ %ArmaClientExe%" 2> NUL | FIND /I /N "%ArmaClientExe%" > NUL
IF "%ERRORLEVEL%"=="0" (
	SET ArmaClientActive=TRUE
	CALL "%%~dp0.\clientStop.bat" noPause
)

REM Build all
CALL "%%~dp0.\buildMission.bat" noPause
CALL "%%~dp0.\buildMod_CLib.bat" noPause
CALL "%%~dp0.\buildMod_OPT-Client.bat" noPause
CALL "%%~dp0.\buildMod_OPT-Server.bat" noPause

REM Restart ArmaServer if it was running before
IF [%ArmaServerActive%] == [TRUE] CALL "%%~dp0.\serverStart.bat" noPause

REM Restart ArmaClient if it was running before
IF [%ArmaClientActive%] == [TRUE] CALL "%%~dp0.\clientStartOnline.bat" noPause

ECHO.
ECHO All done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
