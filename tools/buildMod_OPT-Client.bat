@ECHO OFF
ECHO **************************************************
ECHO *** OPT-Client-Mod builder v0.4                ***
ECHO *** This script will build the OPT-Client mod. ***
ECHO **************************************************

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

REM Increase build-number (changes the #define in script_version.hpp)
ECHO Increasing build-number...
FOR /F "TOKENS=3" %%a IN ('FINDSTR /B /C:"#define BUILD " "%OptClientRepoDir%\addons\main\script_version.hpp"') DO (
  SET /A "OLDBUILD=%%a"
  SET /A "NEWBUILD=%%a + 1"
)
CSCRIPT "%%~dp0.\..\..\helpers\StringReplace.vbs" "%OptClientRepoDir%\addons\main\script_version.hpp" "#define BUILD %OLDBUILD%" "#define BUILD %NEWBUILD%" > NUL

REM build release
IF EXIST "%OptClientRepoDir%\@opt-client\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptClientRepoDir%\@opt-client\"
)

ECHO Building release version of OPT Client-Mod...
PUSHD "%OptClientRepoDir%"
IF EXIST addons\*.pbo DEL addons\*.pbo
IF EXIST keys RMDIR /S /Q keys
IF EXIST releases RMDIR /S /Q releases

"%~dp0.\..\helpers\hemtt.exe" build --release --force-release
IF ERRORLEVEL 1 (
	ECHO [101;93mAN ERROR HAS OCCURRED![0m
	ECHO Press any key to exit.
	PAUSE > NUL
	EXIT 1
)

FOR /f %%d in ('"%~dp0.\..\helpers\hemtt.exe" var version') DO @SET VERSION=%%d

ECHO Copying static stuff ...
XCOPY /S "releases\%VERSION%\@opt-client" "%OptClientRepoDir%\@opt-client\" > NUL

POPD
ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
