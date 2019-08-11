@ECHO OFF
ECHO ***********************************************
ECHO *** OPT-Client starter v0.2                 ***
ECHO *** This script will start an ArmA instance ***
ECHO *** to debug OPT mission and mods.          ***
ECHO ***********************************************

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

:: convert mod-dir absolute pathname so arma can read it properly (relative paths and/or double backslashes)
CALL "%~dp0.\..\helpers\DirConvert.bat" "%OptClientRepoDir%\@OPT-Client" OPT-Client_Dir

:: change directory to ArmA directory (in which the client-exe resides)
CD /D "%ArmaGameDir%"

:: space headed parameter string for noPause-filter in the next step
SET "PARAMS= %*"

:: Start the client
START %ArmaClientExe% -noPause -nosplash -world=empty -skipIntro -filePatching -mod="%additionalMods%;%OPT-Client_Dir%" %PARAMS:noPause=%

ECHO.
ECHO Done.

:: check for "noPause" on any parameter position
ECHO %* | FINDSTR /C:"noPause" 1>NUL
IF NOT ERRORLEVEL 1 GOTO :EOF

IF %WaitAtFinish% == TRUE (
	ECHO Press any key to exit.
	PAUSE > NUL
)
