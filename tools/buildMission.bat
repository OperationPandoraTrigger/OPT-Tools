@ECHO OFF
ECHO ***********************************************
ECHO *** OPT-Mission builder v0.3               ***
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

REM Kill the client
REM The loop occurs as long as the killing reports a success status as this means
REM there was a client process in the process table that was sent a kill-signal
REM However this also means that the client is still running and as Windows doesn't really
REM kill the program, we have to continously send the signal until the client is actually dead

ECHO Killing the (potentially) running client. This might take a while...
:HardKillLoop
REM sleep 100ms
CALL "%%~dp0.\..\helpers\sleep.bat" 100
TASKKILL /F /IM %ArmaClientExe% > NUL 2>&1

REM Task still active? -> Loop again
TASKLIST /FI "IMAGENAME EQ %ArmaClientExe%" 2> NUL | FIND /I /N "%ArmaClientExe%" > NUL
IF "%ERRORLEVEL%"=="0" GOTO HardKillLoop

REM Check (for reappearing ghost-process) again after short delay
CALL "%%~dp0.\..\helpers\sleep.bat" 100
TASKLIST /FI "IMAGENAME EQ %ArmaClientExe%" 2> NUL | FIND /I /N "%ArmaClientExe%" > NUL
IF "%ERRORLEVEL%"=="0" GOTO HardKillLoop
ECHO Successfully killed the client

REM Increase build-number (changes the #define in description.ext)
ECHO Increasing build-number...
FOR /F "TOKENS=3" %%a IN ('FINDSTR /B /C:"#define __VERSION__ " "%OptMissionRepoDir%\%OptMissionName%\description.ext"') DO (
  SET /A "OLDBUILD=%%a"
  SET /A "NEWBUILD=%%a + 1"
)
"%%~dp0.\..\..\helpers\sed.exe" s/"#define __VERSION__ ""%OLDBUILD%"""/"#define __VERSION__ ""%NEWBUILD%"""/g "%OptMissionRepoDir%\%OptMissionName%\description.ext" > "%TEMP%\description.ext"
MOVE /Y "%TEMP%\description.ext" "%OptMissionRepoDir%\%OptMissionName%\description.ext" > NUL

REM Extract worldname extension
FOR /F "tokens=2 delims=." %%a IN ("%OptMissionName%") DO SET EXT=%%a

ECHO Packing opt_v%NEWBUILD%.%EXT%.pbo ...
"%~dp0.\..\helpers\armake2.exe" pack "%OptMissionRepoDir%\%OptMissionName%" "%ArmaMissionPboDir%\opt_v%NEWBUILD%.%EXT%.pbo"

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
