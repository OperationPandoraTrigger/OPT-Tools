:: This script will build the OPT mission.

@ECHO OFF

:: Sanity checks
IF NOT EXIST "%~dp0.\..\settings\setMetaData.bat" (
	ECHO setMetaData.bat not found in "settings".
	ECHO "Check your configuration. (Rename example-file and adjust paths)"
	ECHO Press any key to exit.
	PAUSE > NUL
	EXIT 1
)

:: Set meta infos
CALL "%~dp0.\..\settings\setMetaData.bat"

ECHO Packing %OptMissionName%.pbo ...
"%~dp0.\..\helpers\armake2.exe" pack "%OptMissionRepoDir%\%OptMissionName%" "%ArmaMissionPboDir%\%OptMissionName%.pbo"

ECHO.
ECHO Done.

IF %WaitAtFinish% == TRUE (
	ECHO Press any key to exit.
	PAUSE > NUL
)
