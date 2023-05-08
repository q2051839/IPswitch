@echo off
chcp 65001
setlocal EnableDelayedExpansion

REM 设置网络适配器名称和 IPv4 地址
set adapter_name="以太网"
set dhcp_ip=0.0.0.0
set static_ip=192.168.1.100
set gateway_ip_1=192.168.1.1
set gateway_ip_2=192.168.1.18
set dns_server=192.168.1.18
set process_name=paofu.exe

REM 获取当前进程是否存在
:check_process
tasklist /FI "IMAGENAME eq %process_name%" 2>NUL | find /I /N "%process_name%">NUL
if "%ERRORLEVEL%"=="0" (
    set is_process_running=1
) else (
    set is_process_running=0
)

REM 判断是否需要切换网络配置
if %is_process_running%==1 (
    REM 进程存在，切换到 DHCP
    if NOT "%current_config%"=="DHCP" (
        echo 正在等待 3 秒后切换到动态IP...
        ping -n 4 127.0.0.1 > nul
        if %is_process_running%==1 (
            netsh interface ip set address %adapter_name% dhcp
            netsh interface ip set dns %adapter_name% dhcp 2>NUL
            set current_config=DHCP
            echo 已切换到动态IP
        )
    )
) else (
    REM 进程不存在，切换到静态IP
    if NOT "%current_config%"=="Static" (
        echo 正在切换到静态IP...
        netsh interface ip set address %adapter_name% static %static_ip% 255.255.255.0 %gateway_ip_2% 1 >nul 2>&1
        netsh interface ip set dns %adapter_name% static %dns_server% >nul 2>&1
        set current_config=Static
        echo 已切换到静态IP
    )
)

REM 等待 5 秒钟后重新检测进程是否存在
ping -n 6 127.0.0.1 > nul
goto check_process
