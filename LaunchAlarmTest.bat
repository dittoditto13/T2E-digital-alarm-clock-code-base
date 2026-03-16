@echo off

REM Snapshot existing MATLAB PIDs before launch
set "BEFORE=%TEMP%\MatLabBefore.txt"
set "AFTER=%TEMP%\MatLabAfter.txt"
set "PIDFILE=%TEMP%\AlarmSongPID.txt"

tasklist /FI "IMAGENAME eq matlab.exe" /FO table | findstr /r "[0-9]" > "%BEFORE%"

REM Launch the alarm
start "AlarmSongInstance" matlab -batch "AlarmSong"

REM Wait for new MATLAB to appear
timeout /t 5 /nobreak >nul

REM Snapshot PIDs after launch
tasklist /FI "IMAGENAME eq matlab.exe" /FO table | findstr /r "[0-9]" > "%AFTER%"

REM Find the PID that is in AFTER but not in BEFORE
for /f "tokens=2" %%a in (%AFTER%) do (
    findstr /c:"%%a" "%BEFORE%" >nul
    if errorlevel 1 (
        echo %%a > "%PIDFILE%"
        goto :done
    )
)
:done
del "%BEFORE%"
del "%AFTER%"
echo Alarm started and PID saved.