@ECHO off
REM Spawnable entry point for the CommandCode formatter hook.
REM
REM CommandCode runs hook commands through a plain spawn, so the entry point has
REM to be something Windows can execute without a shell. A .cmd wrapper is that
REM thing: it resolves node.exe and hands over stdin and stdout unchanged.
REM
REM This mirrors the entry point the Grok plugin used, which was arrived at after
REM a bare "node" command and a .ps1 shim both failed to launch there.

SETLOCAL
SET "dp0=%~dp0"

IF EXIST "%dp0%node.exe" (
  SET "_prog=%dp0%node.exe"
) ELSE (
  SET "_prog=node"
)

"%_prog%" "%dp0%format.js" %*
exit /b %ERRORLEVEL%
