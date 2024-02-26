@ECHO OFF&(PUSHD "%~DP0")&(REG QUERY "HKU\S-1-5-19">NUL 2>&1)||(
powershell -Command "Start-Process '%~sdpnx0' -Verb RunAs"&&EXIT)
chcp 65001 >nul

setlocal EnableDelayedExpansion

REM 设置网络适配器名称和 IPv4 地址
set adapter_name="以太网"
set static_ip=192.168.1.99
set gateway_ip_1=192.168.1.2
set gateway_ip_2=192.168.1.88
set dns_server=192.168.1.88

REM 选择要使用的网络配置
:menu
cls
echo 当前网关地址：
netsh interface ip show address "%adapter_name%" | findstr "Default Gateway"
echo 当前DNS地址：
netsh interface ip show dns "%adapter_name%" | findstr /i "DNS Servers"
echo.
echo 请选择要使用的网络配置：
echo [1] DHCP
echo [2] 旁路网关+DNS
echo [3] 可信DNS
echo [4] 本地AdGuard Home
echo [5] 切换网关
echo [6] 退出脚本

set /p choice=输入选项：

if "!choice!"=="1" (
  echo 正在切换到动态IP...
  netsh interface ip set address %adapter_name% dhcp
  netsh interface ip set dns %adapter_name% dhcp
  ipconfig /flushdns >nul
  echo 重启网络适配器...
  netsh interface set interface %adapter_name% disable >nul 2>&1
  netsh interface set interface %adapter_name% enable >nul 2>&1
  pause
  goto menu
) else if "!choice!"=="2" (
  echo 正在切换到旁路网关+DNS...
  netsh interface ip set address %adapter_name% static %static_ip% 255.255.255.0 !gateway_ip_2! 1 >nul 2>&1
  netsh interface ip set dns %adapter_name% static %dns_server% >nul 2>&1
  ipconfig /flushdns >nul
  echo 重启网络适配器...
  netsh interface set interface %adapter_name% disable >nul 2>&1
  netsh interface set interface %adapter_name% enable >nul 2>&1
  pause
  goto menu
) else if "!choice!"=="3" (
  echo 正在切换到可信DNS...
  netsh interface ip set address %adapter_name% dhcp
  netsh interface ip set dns %adapter_name% static %dns_server% >nul 2>&1
  ipconfig /flushdns >nul
  echo 重启网络适配器...
  netsh interface set interface %adapter_name% disable >nul 2>&1
  netsh interface set interface %adapter_name% enable >nul 2>&1
  pause
  goto menu
) else if "!choice!"=="4" (
  echo 正在切换到本地AdGuard Home...
  netsh interface ip set address %adapter_name% dhcp
  netsh interface ip set dns %adapter_name% static 127.0.0.1 >nul 2>&1
  ipconfig /flushdns >nul
  echo 重启网络适配器...
  netsh interface set interface %adapter_name% disable >nul 2>&1
  netsh interface set interface %adapter_name% enable >nul 2>&1
  pause
  goto menu
) else if "!choice!"=="5" (
  echo 请选择要使用的网关：
  echo [1] %gateway_ip_1%
  echo [2] %gateway_ip_2%
  set /p gateway_choice=输入选项：
  if "!gateway_choice!"=="1" (
    echo 正在切换到网关 %gateway_ip_1%...
    netsh interface ip set address %adapter_name% dhcp
    netsh interface ip set dns %adapter_name% dhcp
    ipconfig /flushdns >nul
    echo 重启网络适配器...
    netsh interface set interface %adapter_name% disable >nul 2>&1
    netsh interface set interface %adapter_name% enable >nul 2>&1
    pause
    goto menu
  ) else if "!gateway_choice!"=="2" (
    echo 正在切换到网关 %gateway_ip_2%...
    netsh interface ip set address %adapter_name% static %static_ip% 255.255.255.0 %gateway_ip_2% 1 >nul 2>&1
    netsh interface ip set dns %adapter_name% static %dns_server% >nul 2>&1
    ipconfig /flushdns >nul
    echo 重启网络适配器...
    netsh interface set interface %adapter_name% disable >nul 2>&1
    netsh interface set interface %adapter_name% enable >nul 2>&1
    pause
    goto menu
  ) else (
    echo 无效的选择。请重新输入。
    pause
    goto menu
  )
) else if "!choice!"=="6" (
  exit
) else (
  echo 无效的选择。请重新输入。
  pause
  goto menu
)
