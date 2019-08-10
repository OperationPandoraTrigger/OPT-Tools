@ECHO OFF
ECHO ******************************************
ECHO *** OPT-DevServer starter v0.1         ***
ECHO *** This script will start a DevServer ***
ECHO *** to debug OPT mission and mods.     ***
ECHO ******************************************

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

:: Replace Mission-Name in server config
CALL "%~dp0.\..\helpers\JREPL.BAT" "MISSIONTEMPLATE" "%OptMissionName%" /F "%~dp0.\..\settings\serverConfig.cfg" > "%TEMP%\serverConfig.cfg"

:: Copy server-config into arma-dir as ArmA can only read configs relative to the exe
ECHO Trying to copy config file. This might take a while...
:copyLoop
MOVE /Y "%TEMP%\serverConfig.cfg" "%ArmaGameDir%" > NUL 2>&1
IF NOT [%errorlevel%] == [0]  (
	:: sleep 100ms
	CALL "%~dp0.\..\helpers\sleep.bat" 100
	GOTO :copyLoop
)

:: convert to absolute pathnames so armaserver can read it properly (relative paths and/or double backslashes)
CALL :DirConvert "%OptServerRepoDir%\PBOs\dev\@CLib" CLib_Dir
CALL :DirConvert "%OptClientRepoDir%\@OPT-Client" OPT-Client_Dir
CALL :DirConvert "%OptServerRepoDir%\PBOs\dev\@OPT" OPT-Server_Dir

:: change directory to ArmA directory (in which the server-exe resides)
CD /D "%ArmaGameDir%"

:: Start the server and minimize it once it's started
START /MIN %ArmaServerExe% -config=serverConfig.cfg -profiles=OPT_DevServer -filePatching -serverMod="%CLib_Dir%;%OPT-Server_Dir%" -mod="%OPT-Client_Dir%;%additionalMods%" -debugCallExtension

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF %WaitAtFinish% == TRUE (
	ECHO Press any key to exit.
	PAUSE > NUL
)

EXIT /B 0

:DirConvert
:: Convert to absolute pathnames
:: Parameter 1: input pathname. relative or absolute, with or without double backslashes
:: Parameter 2: output variable name where the clean path is written to
IF EXIST %1 (
	SETLOCAL ENABLEDELAYEDEXPANSION
	PUSHD %1
	ECHO SET "%2=!CD!" > "%TEMP%\OPT_DirConvert.bat"
	ENDLOCAL
	CALL "%TEMP%\OPT_DirConvert.bat"
	DEL "%TEMP%\OPT_DirConvert.bat"
) ELSE (
	ECHO %1 not found. Not build yet?
	ECHO Press any key to exit.
	PAUSE > NUL
	EXIT 1
)
