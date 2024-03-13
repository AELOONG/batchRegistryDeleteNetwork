@echo off

setlocal enabledelayedexpansion

@REM 注册表路径
set networkPath="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"

set /a delete_count = 0
set min=2
set str=
set str_net=
set str_net_word=

@REM 判读是否为管理员权限，不是则自动获取权限
Net session >nul 2>&1 || start "" mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
@REM cd /d "%~dp0"

for /f "delims=" %%i in ('reg Query %networkPath%') do (
    @REM echo %%i
    for /f "tokens=3,* delims= " %%j in ('reg Query "%%i" /v "ProfileName"') do (
        @REM %%j包含<子项目ProfileName的值>和<项目地址>
        set net_word=%%j
        set net_num=%%k

        if not defined net_num (
            @REM 可能为不带序号的网络名(ProfileName="网络"的情况), 
            @REM 将net_num设为0,当min=0时,删除"网络"
            set net_num=0
            set net_name=!net_word!
            @REM echo !net_word!
        ) else (
            set net_name=!net_word! !net_num!
            @REM echo !net_word! !net_num!
        )
        @REM echo !net_name!

        if !net_word!==网络 (
            @REM 序号大于等于min
            if !net_num! geq %min% ( 
                echo %%i !net_name!
                reg Delete "%%i" /f
                set /a delete_count+=1
            )
        )
        @REM echo.
    )
)
echo.
echo delete count = %delete_count%
pause
