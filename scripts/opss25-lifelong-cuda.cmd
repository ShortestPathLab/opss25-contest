@echo off
REM Exit on error
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM ===============================
REM Configuration
REM ===============================
SET IMAGE_NAME=ghcr.io/shortestpathlab/opss25-startkit-cuda:latest

REM Get current working directory
SET "CURRENT_DIR=%CD%"

REM Run Docker container, mount current dir, and pass through all script args
REM %* passes all arguments from the CMD script
docker run --pull always --gpus all --rm -v "%CURRENT_DIR%":/data -w /data %IMAGE_NAME% %*
