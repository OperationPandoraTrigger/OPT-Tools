@ECHO OFF
ECHO ********************************************
ECHO *** CLib-Mod builder v0.3                ***
ECHO *** This script will build the CLib mod. ***
ECHO ********************************************

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

REM This batch file will set the pboName variable
CALL "%%~dp0.\..\helpers\getPBOName.bat" "%%OptServerRepoDir%%\dependencies\CLib\addons\CLib\pboName.h" clib

REM build release
IF EXIST "%OptServerRepoDir%\PBOs\release\@CLib\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptServerRepoDir%\PBOs\release\@CLib\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\release\@CLib\addons\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\release\@CLib\addons\"
)

ECHO Building release version of CLib Mod...
"%~dp0.\..\helpers\armake2.exe" build  "%OptServerRepoDir%\dependencies\CLib\addons\CLib" "%OptServerRepoDir%\PBOs\release\@CLib\addons\%pboName%"
	
REM build dev
IF EXIST "%OptServerRepoDir%\PBOs\dev\@CLib\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptServerRepoDir%\PBOs\dev\@CLib\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\dev\@CLib\addons\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\dev\@CLib\addons\"
)

ECHO Building dev version of the CLib Mod...
	
REM in order to build the dev-version the ISDEV macro flag has to be set programmatically
COPY /Y "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp" "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp.original" > NUL
ECHO:>> "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp"
ECHO #define ISDEV >> "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp"

"%~dp0.\..\helpers\armake2.exe" build -x isDev.hpp.original "%OptServerRepoDir%\dependencies\CLib\addons\CLib" "%OptServerRepoDir%\PBOs\dev\@CLib\addons\%pboName%"
	
REM restore the isDev.hpp file
DEL "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp" /Q
COPY /Y "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp.original" "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp" > NUL
DEL "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp.original" /Q

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
