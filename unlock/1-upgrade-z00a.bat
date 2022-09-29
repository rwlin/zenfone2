@echo off

::One-click Zenfone 2 unlock by Sorg
::used some parts of adb/fastboot script made by Social-Design-Concepts

rem cd tools
PATH=..\tools;%PATH%

:try
call :check_status
if "%status%"=="FASTBOOT-ONLINE" goto :start_recovery
if "%status%"=="ADB-ONLINE" (
	echo Rebooting to bootloader.
	adb reboot bootloader
) else (
	echo waiting for connection...
)
ping -n 3 127.0.0.1 >nul
goto :try

:start_recovery
echo Start flashing ..
fastboot flash splashscreen splashscreen_z00a.img
fastboot flash token bom-token_4_21_40_x.bin
fastboot flash dnx dnx_4_21_40_x.bin
fastboot flash ifwi ifwi_4_21_40_134_z00a.bin
fastboot flash fastboot droidboot_4_21_40_134.img
fastboot reboot-bootloader
sleep 4

:try_2
call :check_status
if "%status%"=="FASTBOOT-ONLINE" goto :flash_recovery
if "%status%"=="ADB-ONLINE" (
	echo Rebooting to bootloader.
	adb reboot bootloader
) else (
	echo waiting for connection...
)
ping -n 3 127.0.0.1 >nul
goto :try_2

:flash_recovery
fastboot flash recovery twrp-3.2.1-0-z00a.img

echo Done.
echo.
pause
GOTO:EOF

:check_status
    set tmp=""

    set adbchk="List of devices attached"
    set adbchk2="unknown"
    set fbchk=""
    set deviceinfo=UNKNOWN

:CHECK_ADB
    set tmp=""
    for /f "tokens=1-4" %%a in ( 'adb devices ^2^> nul' ) do (set tmp="%%a %%b %%c %%d")
    if /i %tmp% == %adbchk% ( goto CHECK_FB )
    if /i not %tmp% == %adbchk% ( goto CHECK_AUTHORIZATION )
    set tmp=""
GOTO:EOF

:CHECK_FB
    set tmp=""
    for /f "tokens=1-2" %%a in ( 'fastboot devices ^2^> nul' ) do (set tmp="%%a %%b")
    if /i %tmp% == %fbchk% (set status=UNKNOWN)
    if /i not %tmp% == %fbchk% (set status=FASTBOOT-ONLINE&for /f "tokens=1-2" %%a in ('fastboot devices ^2^> nul' ) do ( set deviceinfo=%%a %%b))
    set tmp=""
GOTO:EOF

:CHECK_AUTHORIZATION
    set tmp=""
    for /f "tokens=1" %%a in ( 'adb get-serialno ^2^> nul' ) do (set tmp="%%a")
    if /i %tmp% == %adbchk2% ( set status=UNAUTHORIZED&for /f "tokens=1-2" %%a in ('adb devices ^2^> nul' ) do ( set deviceinfo=%%a %%b ))
    if /i not %tmp% == %adbchk2% ( set status=ADB-ONLINE&for /f "tokens=1-2" %%a in ('adb devices ^2^> nul' ) do ( set deviceinfo=%%a %%b ))
    set tmp=""
GOTO:EOF
:EOF
