@ECHO OFF
ECHO ******************************************
ECHO *** OPT-DevServer starter v0.3         ***
ECHO *** This script will start a DevServer ***
ECHO *** to debug OPT mission and mods.     ***
ECHO ******************************************

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

REM Replace Mission-Name in server config
CALL "%%~dp0.\..\helpers\JREPL.BAT" "MISSIONTEMPLATE" "%%OptMissionName%%" /F "%%~dp0.\..\settings\serverConfig.cfg" > "%TEMP%\serverConfig.cfg"

REM Copy server-config into arma-dir as ArmA can only read configs relative to the exe
ECHO Trying to copy config file. This might take a while...
:copyLoop
MOVE /Y "%TEMP%\serverConfig.cfg" "%ArmaGameDir%" > NUL 2>&1
IF NOT [%errorlevel%] == [0]  (
	REM sleep 100ms
	CALL "%%~dp0.\..\helpers\sleep.bat" 100
	GOTO :copyLoop
)

REM convert to absolute pathnames so armaserver can read it properly (relative paths and/or double backslashes)
CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptClientRepoDir%%\@OPT-Client" OPT-Client_Dir

IF ["%LoadClibDev%"] == ["TRUE"] (
	CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptServerRepoDir%%\PBOs\dev\@CLib" CLib_Dir
) ELSE (
	CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptServerRepoDir%%\PBOs\release\@CLib" CLib_Dir
)

IF ["%LoadOptDev%"] == ["TRUE"] (
	CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptServerRepoDir%%\PBOs\dev\@OPT" OPT-Server_Dir
) ELSE (
	CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptServerRepoDir%%\PBOs\release\@OPT" OPT-Server_Dir
)

REM change directory to ArmA directory (in which the server-exe resides)
CD /D "%ArmaGameDir%"

REM Start the server and minimize it once it's started
START /MIN %ArmaServerExe% -config=serverConfig.cfg -profiles=OPT_DevServer -filePatching -serverMod="%CLib_Dir%;%OPT-Server_Dir%" -mod="%OPT-Client_Dir%;%additionalMods%" -debugCallExtension

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
