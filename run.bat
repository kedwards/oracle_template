@echo off

IF [%1]==[/?] GOTO :help

echo %* | find "/?" > nul
IF errorlevel 1 GOTO :main

:help

echo.
echo %SCRIPT_TITLE%
echo ----------------------------
echo Usage: %0 PASS ENV [USER]
echo ------
echo    ENV  -- enviornment to run agains.
echo    PASS -- password.
echo    USER -- user (default: user).

GOTO :end

:main

set TNS_ADMIN=%~dp0oracle
set PATH=%PATH%;%~dp0oracle\instantclient_XX_X

set Pswd=%1
set Env=%2

if "%3"=="" (
  set User=wdcnv
) else (
  set User=%3
)

if "%Pswd%"=="" set /p Pswd=What is the password?
if "%Env%"=="" set /p Env=What is the environment [P1, P2, P3]?

echo.>"%~dp0queries\1.sql"
echo @%~dp0pre_load.sql >> "%~dp0queries\1.sql"
echo @%~dp0pre_load_1.sql >> "%~dp0queries\1.sql"
echo exit >> "%~dp0queries\1.sql"

echo.>"%~dp0queries\2.sql"
echo @%~dp0post_load.sql >> "%~dp0queries\2.sql"
echo @%~dp0post_load_1.sql >> "%~dp0queries\2.sql"
echo exit >> "%~dp0queries\2.sql"

sqlplus.exe %User%/%Pswd%@%Env% @queries\1.sql

sqlldr userid=%User%/%Pswd%@%Env% control=%file_name%.ctl log=logs/%file_name%.log \
  bad=logs/%file_name%.bad discard=logs/%file_name%.dsc

sqlplus.exe %User%/%Pswd%@%Env% @queries\2.sql

del queries\1.sql
del queries\2.sql

:end
