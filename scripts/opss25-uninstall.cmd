@echo off
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM ===============================
REM Configuration
REM ===============================
SET "DIR=%USERPROFILE%\opss25"
SET "ENV_NAME=opss25"

ECHO ⚠️  WARNING: This will delete the %%USERPROFILE%%\opss25 directory and all its contents,
ECHO and remove the opss25 environment from conda. Type Y to continue, or Ctrl-C to cancel.
SET /P response=Continue? 

IF /I "%response%"=="Y" (
    ECHO Proceeding...
    conda env remove -y -n "%ENV_NAME%"
    rmdir /S /Q "%DIR%"
    ECHO ✅ opss25 environment uninstalled.
) ELSE (
    ECHO Aborting
    EXIT /B 1
)
