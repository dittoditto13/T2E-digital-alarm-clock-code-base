@echo off
if exist "%TEMP%\AlarmSongPID.txt" (
    for /f "tokens=* delims= " %%a in (%TEMP%\AlarmSongPID.txt) do (
        taskkill /PID %%a /F
        goto :cleanup
    )
    :cleanup
    del "%TEMP%\AlarmSongPID.txt"
) else (
    echo ERROR: PID file not found, alarm process could not be killed.
)