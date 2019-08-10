:: This script will build all.

@ECHO OFF

:: Build all
CALL "%~dp0.\buildMission.bat" noPause
CALL "%~dp0.\buildMod_CLib.bat" noPause
CALL "%~dp0.\buildMod_OPT-Client.bat" noPause
CALL "%~dp0.\buildMod_OPT-Server.bat" noPause

ECHO.
ECHO All done.

IF [%1] == [noPause] GOTO :EOF
IF %WaitAtFinish% == TRUE (
	ECHO Press any key to exit.
	PAUSE > NUL
)
