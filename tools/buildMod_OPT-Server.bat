@ECHO OFF
ECHO **************************************************
ECHO *** OPT-Server-Mod builder v0.2                ***
ECHO *** This script will build the OPT-Server mod. ***
ECHO **************************************************

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

IF NOT EXIST "%OptServerRepoDir%\dependencies\CLib\addons\CLib\" (
	ECHO Can't find the CLib submodule - did you initialize it via "git submodule update"?
	ECHO Press any key to exit.
	PAUSE > NUL
	EXIT 1
)

:: This batch file will set the pboName variable
CALL "%~dp0.\..\helpers\getPBOName.bat" "%OptServerRepoDir%\addons\OPT\pboName.h" opt

:: build release
IF EXIST "%OptServerRepoDir%\PBOs\release\@OPT\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptServerRepoDir%\PBOs\release\@OPT\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\release\@OPT\addons\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\release\@OPT\addons\"
)

ECHO Building release version of OPT Mod...
"%~dp0.\..\helpers\armake2.exe" build -i "%OptServerRepoDir%\dependencies\CLib\addons" "%OptServerRepoDir%\addons\OPT" "%OptServerRepoDir%\PBOs\release\@OPT\addons\%pboName%"

:: build dev
IF EXIST "%OptServerRepoDir%\PBOs\dev\@OPT\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptServerRepoDir%\PBOs\dev\@OPT\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\dev\@OPT\addons\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\dev\@OPT\addons\"
)

ECHO Building dev version of the OPT Mod...
	
:: in order to build the dev-version the ISDEV macro flag has to be set programmatically
COPY /Y "%OptServerRepoDir%\addons\OPT\isDev.hpp" "%OptServerRepoDir%\addons\OPT\isDev.hpp.original" > NUL
ECHO:>> "%OptServerRepoDir%\addons\OPT\isDev.hpp"
ECHO #define ISDEV >> "%OptServerRepoDir%\addons\OPT\isDev.hpp"

"%~dp0.\..\helpers\armake2.exe" build -i "%OptServerRepoDir%\dependencies\CLib\addons" -x isDev.hpp.original "%OptServerRepoDir%\addons\OPT" "%OptServerRepoDir%\PBOs\dev\@OPT\addons\%pboName%"

::restore the isDev.hpp file
DEL "%OptServerRepoDir%\addons\OPT\isDev.hpp" /q
COPY /Y "%OptServerRepoDir%\addons\OPT\isDev.hpp.original" "%OptServerRepoDir%\addons\OPT\isDev.hpp" > NUL
DEL "%OptServerRepoDir%\addons\OPT\isDev.hpp.original" /q

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF %WaitAtFinish% == TRUE (
	ECHO Press any key to exit.
	PAUSE > NUL
)
