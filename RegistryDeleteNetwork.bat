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
    for /f "delims=" %%j in ('reg Query "%%i" /v "ProfileName"') do (
        @REM %%j包含<子项目ProfileName的值>和<项目地址(即部分%%j=%%i)>
        set str=%%j

        @REM 截取字符串后4位
        set str_net=!str:~-4!
        @REM echo str_net

        @REM 截取字符串前2位
        set str_net_word=!str_net:~0,2!
        @REM echo !str_net_word!

        if !str_net_word!==网络 (
            @REM 带序号网络名，且序号大于等于min
            if !str_net:~-1! geq %min% ( 
                echo %%i !str_net!
                reg Delete "%%i" /f
                set /a delete_count+=1
            )
        )^
        else if %min% equ 0 (
            @REM 不带序号的网络名
            if !str_net:~-2!==网络 ( 
                echo %%i !str_net:~-2! 
                reg Delete "%%i" /f
                set /a delete_count+=1
            )
        )
    )
)

echo delete count = %delete_count%
pause
