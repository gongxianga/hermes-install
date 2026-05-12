# Hermes Agent 自定义安装脚本
# 运行方式: 右键 -> 用 PowerShell 运行

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "   Hermes Agent 安装程序" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 询问安装路径
$defaultInstall = "C:\Hermes"
$installPath = Read-Host "请输入安装目录 (直接回车使用默认: $defaultInstall)"
if ([string]::IsNullOrWhiteSpace($installPath)) {
    $installPath = $defaultInstall
}

$dataPath = "$installPath\data"

Write-Host ""
Write-Host "安装目录: $installPath" -ForegroundColor Yellow
Write-Host "数据目录: $dataPath" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "确认安装? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "已取消安装。" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "开始安装，请稍候..." -ForegroundColor Green

# 执行官方安装脚本，指定自定义路径
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1))) `
    -InstallDir $installPath `
    -HermesHome $dataPath

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "安装完成！" -ForegroundColor Green
Write-Host "请打开一个新的 PowerShell 窗口" -ForegroundColor Green
Write-Host "然后运行: hermes setup" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
