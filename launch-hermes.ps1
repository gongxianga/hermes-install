# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 优先用 Windows Terminal 启动（字体支持更好，不会显示方块）
$wt = Get-Command wt.exe -ErrorAction SilentlyContinue
if ($wt) {
    Start-Process wt.exe -ArgumentList "powershell.exe -NoExit -ExecutionPolicy Bypass -Command `"chcp 65001 | Out-Null; hermes`""
} else {
    # 没有 Windows Terminal，直接在当前窗口启动
    hermes
}
