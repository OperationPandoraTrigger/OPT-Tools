@ECHO OFF
ECHO **************************************************
ECHO *** OPT-Client-Mod builder v0.2                ***
ECHO *** This script will build the OPT-Client mod. ***
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

IF EXIST "%OptClientRepoDir%\@OPT-Client\" (
	ECHO Deleting old build ...
	RMDIR /S /Q "%OptClientRepoDir%\@OPT-Client\"
)

IF NOT EXIST "%OptClientRepoDir%\@OPT-Client\" (
	ECHO Creating directories ...
	MKDIR "%OptClientRepoDir%\@OPT-Client"
	IF NOT EXIST "%OptClientRepoDir%\@OPT-Client\addons\" MKDIR "%OptClientRepoDir%\@OPT-Client\addons"
)

FOR /f %%a IN ('DIR "%OptClientRepoDir%\addons\" /AD /B /ON') DO (
	ECHO Packing %%a.pbo ...
	"%~dp0.\..\helpers\armake2.exe" pack -v "%OptClientRepoDir%\addons\%%a" "%OptClientRepoDir%\@OPT-Client\addons\%%a.pbo"
)

ECHO Copying static stuff ...
COPY /Y "%OptClientRepoDir%\mod.cpp" "%OptClientRepoDir%\@OPT-Client\" > NUL
COPY /Y "%OptClientRepoDir%\opt4_icon.paa" "%OptClientRepoDir%\@OPT-Client\" > NUL

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF %WaitAtFinish% == TRUE (
	ECHO Press any key to exit.
	PAUSE > NUL
)
