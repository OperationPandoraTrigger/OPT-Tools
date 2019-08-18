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

IF EXIST "%OptClientRepoDir%\@OPT-Client\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptClientRepoDir%\@OPT-Client\"
)

IF NOT EXIST "%OptClientRepoDir%\@OPT-Client\" (
	ECHO Creating directories ...
	MKDIR "%OptClientRepoDir%\@OPT-Client"
	IF NOT EXIST "%OptClientRepoDir%\@OPT-Client\addons\" MKDIR "%OptClientRepoDir%\@OPT-Client\addons"
	IF NOT EXIST "%OptClientRepoDir%\@OPT-Client\keys\" MKDIR "%OptClientRepoDir%\@OPT-Client\keys"
)

IF NOT EXIST "%OptKeysDir%\OPT.bikey" (
	ECHO Creating public/private keypair ...
	"%~dp0.\..\helpers\armake2.exe" keygen "%OptKeysDir%\OPT"
)

IF NOT EXIST "%OptKeysDir%\OPT.biprivatekey" (
	ECHO Creating public/private keypair ...
	"%~dp0.\..\helpers\armake2.exe" keygen "%OptKeysDir%\OPT"
)

FOR /f %%a IN ('DIR "%OptClientRepoDir%\addons\" /AD /B /ON') DO (
	ECHO Packing %%a.pbo ...
	"%~dp0.\..\helpers\armake2.exe" pack -v -k "%OptKeysDir%\OPT.biprivatekey" "%OptClientRepoDir%\addons\%%a" "%OptClientRepoDir%\@OPT-Client\addons\%%a.pbo"
)

ECHO Copying static stuff ...
COPY /Y "%OptClientRepoDir%\mod.cpp" "%OptClientRepoDir%\@OPT-Client\" > NUL
COPY /Y "%OptClientRepoDir%\opt4_icon.paa" "%OptClientRepoDir%\@OPT-Client\" > NUL
COPY /Y "%OptKeysDir%\OPT.bikey" "%OptClientRepoDir%\@OPT-Client\keys\" > NUL

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
