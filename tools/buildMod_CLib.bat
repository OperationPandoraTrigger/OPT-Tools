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

IF NOT EXIST "%OptServerRepoDir%\PBOs\release\@CLib\keys\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\release\@CLib\keys\"
)

IF NOT EXIST "%OptKeysDir%\OPT.bikey" (
	ECHO Creating public/private keypair ...
	"%~dp0.\..\helpers\armake2.exe" keygen "%OptKeysDir%\OPT"
)

IF NOT EXIST "%OptKeysDir%\OPT.biprivatekey" (
	ECHO Creating public/private keypair ...
	"%~dp0.\..\helpers\armake2.exe" keygen "%OptKeysDir%\OPT"
)

ECHO Building release version of CLib Mod...
"%~dp0.\..\helpers\armake2.exe" build -k "%OptKeysDir%\OPT.biprivatekey" "%OptServerRepoDir%\dependencies\CLib\addons\CLib" "%OptServerRepoDir%\PBOs\release\@CLib\addons\%pboName%"
	
ECHO Building dev version of the CLib Mod...
IF EXIST "%OptServerRepoDir%\PBOs\dev\@CLib\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptServerRepoDir%\PBOs\dev\@CLib\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\dev\@CLib\addons\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\dev\@CLib\addons\"
)

IF NOT EXIST "%OptServerRepoDir%\PBOs\dev\@CLib\keys\" (
	ECHO Creating directories ...
	MKDIR "%OptServerRepoDir%\PBOs\dev\@CLib\keys\"
)

REM in order to build the dev-version the ISDEV macro flag has to be set programmatically
COPY /Y "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp" "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp.original" > NUL
ECHO:>> "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp"
ECHO #define ISDEV >> "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp"

"%~dp0.\..\helpers\armake2.exe" build -x isDev.hpp.original -k "%OptKeysDir%\OPT.biprivatekey" "%OptServerRepoDir%\dependencies\CLib\addons\CLib" "%OptServerRepoDir%\PBOs\dev\@CLib\addons\%pboName%"
	
REM restore the isDev.hpp file
DEL "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp" /Q
COPY /Y "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp.original" "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp" > NUL
DEL "%OptServerRepoDir%\dependencies\CLib\addons\CLib\isDev.hpp.original" /Q

ECHO Copying static stuff ...
COPY /Y "%OptServerRepoDir%\dependencies\CLib\*.dll" "%OptServerRepoDir%\PBOs\release\@CLib\" > NUL
COPY /Y "%OptServerRepoDir%\dependencies\CLib\*.dll" "%OptServerRepoDir%\PBOs\dev\@CLib\" > NUL
COPY /Y "%OptServerRepoDir%\dependencies\CLib\README.md" "%OptServerRepoDir%\PBOs\release\@CLib\" > NUL
COPY /Y "%OptServerRepoDir%\dependencies\CLib\README.md" "%OptServerRepoDir%\PBOs\dev\@CLib\" > NUL
COPY /Y "%OptServerRepoDir%\dependencies\CLib\AUTHORS.txt" "%OptServerRepoDir%\PBOs\release\@CLib\" > NUL
COPY /Y "%OptServerRepoDir%\dependencies\CLib\AUTHORS.txt" "%OptServerRepoDir%\PBOs\dev\@CLib\" > NUL
COPY /Y "%OptKeysDir%\OPT.bikey" "%OptServerRepoDir%\PBOs\release\@CLib\keys\" > NUL
COPY /Y "%OptKeysDir%\OPT.bikey" "%OptServerRepoDir%\PBOs\dev\@CLib\keys\" > NUL

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
