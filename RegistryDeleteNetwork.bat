@echo off

setlocal enabledelayedexpansion

@REM ע���·��
set networkPath="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles"

set /a delete_count = 0
set min=2
set str=
set str_net=
set str_net_word=

@REM �ж��Ƿ�Ϊ����ԱȨ�ޣ��������Զ���ȡȨ��
Net session >nul 2>&1 || start "" mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
@REM cd /d "%~dp0"

for /f "delims=" %%i in ('reg Query %networkPath%') do (
    @REM echo %%i
    for /f "tokens=3,* delims= " %%j in ('reg Query "%%i" /v "ProfileName"') do (
        @REM %%j����<����ĿProfileName��ֵ>��<��Ŀ��ַ>
        set net_word=%%j
        set net_num=%%k

        if not defined net_num (
            @REM ����Ϊ������ŵ�������(ProfileName="����"�����), 
            @REM ��net_num��Ϊ0,��min=0ʱ,ɾ��"����"
            set net_num=0
            set net_name=!net_word!
            @REM echo !net_word!
        ) else (
            set net_name=!net_word! !net_num!
            @REM echo !net_word! !net_num!
        )
        @REM echo !net_name!

        if !net_word!==���� (
            @REM ��Ŵ��ڵ���min
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
