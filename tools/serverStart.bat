@ECHO OFF
ECHO ******************************************
ECHO *** OPT-DevServer starter v0.4         ***
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

REM Get last mission name
:GETLOGFILE
FOR /F "TOKENS=1" %%a IN ('DIR /B /OD "%ArmaMissionPboDir%\opt_v*.pbo"') DO (
	SET "MISSION=%%~na"
)

REM Replace Mission-Name in server config
COPY "%~dp0.\..\settings\serverConfig.cfg" "%TEMP%\serverConfig.cfg" > NUL
CSCRIPT "%%~dp0.\..\..\helpers\StringReplace.vbs" "%TEMP%\serverConfig.cfg" "MISSIONTEMPLATE" "%MISSION%" > NUL

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
CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptClientRepoDir%%\@opt-client" OPT-Client_Dir

IF ["%LoadClibDev%"] == ["TRUE"] (
	CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptServerRepoDir%%\PBOs\dev\@CLib" CLib_Dir
) ELSE (
	CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptServerRepoDir%%\PBOs\release\@CLib" CLib_Dir
)

CALL "%%~dp0.\..\helpers\DirConvert.bat" "%%OptServerRepoDir%%\PBOs\release\@opt-server" OPT-Server_Dir

REM change directory to ArmA directory (in which the server-exe resides)
CD /D "%ArmaGameDir%"

REM Start the server and minimize it once it's started
ECHO Starting server...
START /MIN %ArmaServerExe% -config=serverConfig.cfg -profiles=OPT_DevServer -serverMod="%CLib_Dir%;%OPT-Server_Dir%" -mod="%OPT-Client_Dir%;%additionalMods%" -debugCallExtension

REM Show live-serverlog if wanted
IF ["%ShowServerLog%"] == ["TRUE"] (
	ECHO Waiting a bit for the logfile being created...
	CALL "%%~dp0.\..\helpers\sleep.bat" 2000
	CALL "%%~dp0.\serverLog.bat" noPause
)

ECHO.
ECHO Done.

IF [%1] == [noPause] GOTO :EOF
IF ["%WaitAtFinish%"] == ["TRUE"] (
	ECHO Press any key to exit.
	PAUSE > NUL
)
