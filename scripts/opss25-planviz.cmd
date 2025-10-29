@echo off
REM Exit on error
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM ===============================
REM Configuration
REM ===============================
SET "DIR=%USERPROFILE%\opss25\packages\PlanViz\external\PlanViz"

REM Run Python script with all arguments passed to this CMD script
python "%DIR%\script\run.py" %*
