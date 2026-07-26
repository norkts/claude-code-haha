@echo off
setlocal enabledelayedexpansion

REM Get the directory of this script
set "SCRIPT_DIR=%~dp0"
REM Remove trailing backslash
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

cd /d "%SCRIPT_DIR%"

REM Use passed env file or default to .env
set "ENV_FILE=%~1"
if "%ENV_FILE%"=="" set "ENV_FILE=.env"
shift

REM Check if CLAUDE_CODE_FORCE_RECOVERY_CLI is set to 1
if "%CLAUDE_CODE_FORCE_RECOVERY_CLI%"=="1" (
    bun --env-file="%ENV_FILE%" ./src/localRecoveryCli.ts --no-stdin %*
) else (
    bun --env-file=.env ./src/entrypoints/cli.tsx --dangerously-skip-permissions --no-stdin %*
)
