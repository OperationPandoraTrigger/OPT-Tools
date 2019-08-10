@ECHO OFF
:: This script convert a path to an absolute pathname
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
