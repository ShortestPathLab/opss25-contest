@echo off
REM Exit on error
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM ===============================
REM Configuration
REM ===============================
SET "DIR=%USERPROFILE%\opss25\packages\PlanViz\external\PlanViz"
SET "ENV_NAME=opss25"

IF NOT "%CONDA_DEFAULT_ENV%" == "%ENV_NAME%" (
        ECHO You must be in the %ENV_NAME% conda environment. Please activate it first by running 'conda activate %ENV_NAME%'. Aborting.
        EXIT /B 1
)

REM Run Python script with all arguments passed to this CMD script
python "%DIR%\script\run.py" %*
