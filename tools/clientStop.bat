@ECHO OFF
ECHO ********************************************************
ECHO *** ArmA stopper v0.1                                ***
ECHO *** This script stops a running local ArmA instance. ***
ECHO ********************************************************

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

:: Kill the client
:: The loop occurs as long as the killing reports a success status as this means
:: there was a client process in the process table that was sent a kill-signal
:: However this also means that the client is still running and as Windows doesn't really
:: kill the program, we have to continously send the signal until the client is actually dead
ECHO Killing the (potentially) running client. This might take a while...
:killLoop
	TASKKILL /IM %ArmaClientExe% > NUL 2>&1
	
	IF [%errorlevel%] == [0] (
		:: sleep 100ms
		CALL "%~dp0.\..\helpers\sleep.bat" 100
		GOTO :killLoop
	) ELSE (
		:: wait another 100ms and check again if the client was _really_ (hard)killed
		CALL "%~dp0.\..\helpers\sleep.bat" 100
		TASKKILL /F /IM %ArmaClientExe% > NUL 2>&1
		IF [%errorlevel%] == [0] (
			:: apparently the client isn't as dead as it seemed
			GOTO :killLoop
		)
	)
ECHO.
ECHO Successfully killed the client

IF [%1] == [noPause] GOTO :EOF
IF %WaitAtFinish% == TRUE (
	ECHO Press any key to exit.
	PAUSE > NUL
)
