@ECHO OFF
REM This script will determine the PBO-name based on a file's content (last line will be considered for that.
REM That line may either specify the name as pboName="<The name>" or if it doesn't follow this scheme the complete
REM last line will be taken as the name.
REM The given file will be preprocessed before examination so using macros in order to determine the PBO-name is fine.
REM This script will set the pboName variable that may be accessed in the calling script.

REM Param 0: The path to the file containing the pboName
REM Param 1: The default value that should be used when the extraction of the file fails (The file doesn't exist)

SET FILE=%1
SET default=%2

IF [%FILE%] == [] (
	REM if no FILE is given, use the default
	SET pboName=%default%
	GOTO END
)

IF NOT EXIST %FILE% (
	REM if the given FILE doesn't exist, use the default
	SET pboName=%default%
	GOTO END
) ELSE (
	REM preprocess the file into a local file called
	"%~dp0.\armake2.exe" preprocess -i "%OptServerRepoDir%\dependencies\CLib\addons" %FILE% internal_pboName.h.tmp
	
	REM read the last line of the file (contains the pboName spec)
	FOR /F "delims=" %%x IN (internal_pboName.h.tmp) DO SET pboName=%%x
	
	REM delete the temp-file
	DEL internal_pboName.h.tmp /Q
)


:END
REM replace double-quotes with single quotes as they don't mess up the script on expansion
SET pboName=%pboName:"='%

IF "%pboName:~0,9%" == "pboName='" (
	REM The pboName is given in the format pboName="<actualName>" -> trim to <actualName>
	SET pboName=%pboName:~9,-1%
)

IF NOT "%pboName:~4%" == ".pbo" (
	REM make sure the name actually ends with .pbo
	SET pboName=%pboName%.pbo
)