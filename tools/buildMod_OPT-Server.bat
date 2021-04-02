@ECHO OFF
ECHO **************************************************
ECHO *** OPT-Server-Mod builder v0.5                ***
ECHO *** This script will build the OPT-Server mod. ***
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

IF NOT EXIST "%OptServerRepoDir%\dependencies\CLib\addons\CLib\" (
	ECHO Can't find the CLib submodule - did you initialize it via "git submodule update --init --recursive"?
	ECHO Press any key to exit.
	PAUSE > NUL
	EXIT 1
)

REM Increase build-number (changes the #define in script_version.hpp)
ECHO Increasing build-number...
FOR /F "TOKENS=3" %%a IN ('FINDSTR /B /C:"#define BUILD " "%OptServerRepoDir%\addons\main\script_version.hpp"') DO (
  SET /A "OLDBUILD=%%a"
  SET /A "NEWBUILD=%%a + 1"
)
CSCRIPT "%%~dp0.\..\..\helpers\StringReplace.vbs" "%OptServerRepoDir%\addons\main\script_version.hpp" "#define BUILD %OLDBUILD%" "#define BUILD %NEWBUILD%" > NUL

REM This batch file will set the pboName variable
CALL "%%~dp0.\..\helpers\getPBOName.bat" "%%OptServerRepoDir%%\addons\main\pboName.h" opt

REM build release
IF EXIST "%OptServerRepoDir%\PBOs\release\@OPT\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptServerRepoDir%\PBOs\release\@OPT\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\release\@OPT\addons\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\release\@OPT\addons\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\release\@OPT\keys\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\release\@OPT\keys\"
)

IF NOT EXIST "%OptKeysDir%\OPT.bikey" (
	ECHO Creating public/private keypair ...
	"%~dp0.\..\helpers\armake2.exe" keygen "%OptKeysDir%\OPT"
)

IF NOT EXIST "%OptKeysDir%\OPT.biprivatekey" (
	ECHO Creating public/private keypair ...
	"%~dp0.\..\helpers\armake2.exe" keygen "%OptKeysDir%\OPT"
)

ECHO Building release version of OPT Mod...
"%~dp0.\..\helpers\armake2.exe" build -k "%OptKeysDir%\OPT.biprivatekey" -i "%OptServerRepoDir%\dependencies\CLib\addons" "%OptServerRepoDir%\addons\main" "%OptServerRepoDir%\PBOs\release\@OPT\addons\%pboName%"

ECHO Copying static stuff ...
COPY /Y "%OptServerRepoDir%\README.md" "%OptServerRepoDir%\PBOs\release\@OPT\" > NUL
COPY /Y "%OptServerRepoDir%\LICENSE" "%OptServerRepoDir%\PBOs\release\@OPT\" > NUL
COPY /Y "%OptKeysDir%\OPT.bikey" "%OptServerRepoDir%\PBOs\release\@OPT\keys\" > NUL

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
