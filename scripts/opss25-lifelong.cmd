@echo off
REM Exit on error
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM ===============================
REM Configuration
REM ===============================
SET IMAGE_NAME=ghcr.io/shortestpathlab/opss25-startkit:latest

REM Get current working directory
SET "CURRENT_DIR=%CD%"

REM Check if GPU is available (nvidia-smi must be in PATH)
nvidia-smi >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO GPU is available.
    SET "ARGS=--gpus all"
) ELSE (
    ECHO GPU is not available.
    SET "ARGS="
)

REM Run Docker container, mount current dir, and pass through all script args
REM %* passes all arguments from the CMD script
docker run %ARGS% --rm -v "%CURRENT_DIR%":/data -w /data %IMAGE_NAME% %*
