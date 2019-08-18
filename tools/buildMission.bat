@ECHO OFF
ECHO ***********************************************
ECHO *** OPT-Mission builder v0.21               ***
ECHO *** This script will build the OPT mission. ***
ECHO ***********************************************

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

REM Check/Create symlink for mission folder
IF NOT EXIST "%ArmaMissionSourceDir%\%OptMissionName%" (
	REM Folder doesnt exist. Check for administrator privileges to be able to create it...
	OPENFILES >NUL 2>&1
	IF ERRORLEVEL 1 (
		ECHO [101;93mThis batch script once-only requires administrator privileges to create a symlink.[0m
		ECHO Right-click on[31m %~nx0 [0mand select "[31mRun as administrator[0m".
		ECHO Press any key to exit.
		PAUSE > NUL
		EXIT 1
	)
	ECHO Creating symlink...
	MKLINK /D "%ArmaMissionSourceDir%\%OptMissionName%" "%OptMissionRepoDir%\%OptMissionName%" > NUL
	) ELSE (
	REM Folder exists. Write dummy file to source and look if it appears at the destination...	
	ECHO Mission-Folder exists. Checking if its a valid symlink...
	ECHO. > "%OptMissionRepoDir%\%OptMissionName%\LINKCHECK0815.tmp"
	IF NOT EXIST "%ArmaMissionSourceDir%\%OptMissionName%\LINKCHECK0815.tmp" (
		DEL "%OptMissionRepoDir%\%OptMissionName%\LINKCHECK0815.tmp"
		ECHO The existing mission folder contains something else. Delete or rename it!
		ECHO Press any key to exit.
		PAUSE > NUL
		EXIT 1
	) ELSE (
		ECHO Valid symlink for mission folder found.
		DEL "%OptMissionRepoDir%\%OptMissionName%\LINKCHECK0815.tmp"
	)
)

ECHO Packing %OptMissionName%.pbo ...
"%~dp0.\..\helpers\armake2.exe" pack "%OptMissionRepoDir%\%OptMissionName%" "%ArmaMissionPboDir%\%OptMissionName%.pbo"

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
