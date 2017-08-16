@echo off
IF "%1"=="" GOTO BLANK

type header.txt


powershell -executionpolicy remotesigned -Noninteractive -Command ".\main.ps1 -s \"%1""
GOTO DONE

:BLANK
ECHO No Parameter
exit 1

:DONE
ECHO Done!
exit 0