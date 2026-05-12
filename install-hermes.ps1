Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 主窗口
$form = New-Object System.Windows.Forms.Form
$form.Text = "Hermes Agent 安装程序"
$form.Size = New-Object System.Drawing.Size(520, 420)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 250)

# 顶部标题栏
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(520, 70)
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 60)
$form.Controls.Add($headerPanel)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Hermes Agent"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::White
$titleLabel.Location = New-Object System.Drawing.Point(20, 10)
$titleLabel.Size = New-Object System.Drawing.Size(300, 35)
$headerPanel.Controls.Add($titleLabel)

$subLabel = New-Object System.Windows.Forms.Label
$subLabel.Text = "Windows 安装程序"
$subLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$subLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 220)
$subLabel.Location = New-Object System.Drawing.Point(22, 44)
$subLabel.Size = New-Object System.Drawing.Size(200, 20)
$headerPanel.Controls.Add($subLabel)

# 安装目录标签
$dirLabel = New-Object System.Windows.Forms.Label
$dirLabel.Text = "安装目录"
$dirLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$dirLabel.Location = New-Object System.Drawing.Point(20, 95)
$dirLabel.Size = New-Object System.Drawing.Size(200, 22)
$form.Controls.Add($dirLabel)

# 目录输入框
$dirBox = New-Object System.Windows.Forms.TextBox
$dirBox.Text = "C:\Hermes"
$dirBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$dirBox.Location = New-Object System.Drawing.Point(20, 120)
$dirBox.Size = New-Object System.Drawing.Size(370, 28)
$form.Controls.Add($dirBox)

# 浏览按钮
$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Text = "浏览..."
$browseBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$browseBtn.Location = New-Object System.Drawing.Point(400, 119)
$browseBtn.Size = New-Object System.Drawing.Size(80, 28)
$browseBtn.BackColor = [System.Drawing.Color]::FromArgb(220, 220, 235)
$browseBtn.FlatStyle = "Flat"
$form.Controls.Add($browseBtn)

$browseBtn.Add_Click({
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderDialog.Description = "选择安装目录"
    $folderDialog.SelectedPath = $dirBox.Text
    if ($folderDialog.ShowDialog() -eq "OK") {
        $dirBox.Text = $folderDialog.SelectedPath
    }
})

# 提示信息
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = "数据目录将自动创建在安装目录下的 \data 文件夹中"
$infoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$infoLabel.ForeColor = [System.Drawing.Color]::Gray
$infoLabel.Location = New-Object System.Drawing.Point(20, 153)
$infoLabel.Size = New-Object System.Drawing.Size(460, 18)
$form.Controls.Add($infoLabel)

# 日志输出框标签
$logLabel = New-Object System.Windows.Forms.Label
$logLabel.Text = "安装日志"
$logLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$logLabel.Location = New-Object System.Drawing.Point(20, 180)
$logLabel.Size = New-Object System.Drawing.Size(200, 22)
$form.Controls.Add($logLabel)

# 日志输出框
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logBox.Location = New-Object System.Drawing.Point(20, 205)
$logBox.Size = New-Object System.Drawing.Size(460, 120)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 35)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(180, 255, 180)
$logBox.ReadOnly = $true
$logBox.BorderStyle = "None"
$form.Controls.Add($logBox)

# 进度条
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 335)
$progressBar.Size = New-Object System.Drawing.Size(460, 12)
$progressBar.Style = "Continuous"
$progressBar.Value = 0
$form.Controls.Add($progressBar)

# 安装按钮
$installBtn = New-Object System.Windows.Forms.Button
$installBtn.Text = "开始安装"
$installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$installBtn.Location = New-Object System.Drawing.Point(170, 355)
$installBtn.Size = New-Object System.Drawing.Size(160, 38)
$installBtn.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 60)
$installBtn.ForeColor = [System.Drawing.Color]::White
$installBtn.FlatStyle = "Flat"
$installBtn.FlatAppearance.BorderSize = 0
$form.Controls.Add($installBtn)

function Write-Log {
    param($msg, $color = "LightGreen")
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor = [System.Drawing.Color]::$color
    $logBox.AppendText("$msg`n")
    $logBox.ScrollToCaret()
    $form.Refresh()
}

$installBtn.Add_Click({
    $installPath = $dirBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($installPath)) {
        [System.Windows.Forms.MessageBox]::Show("请选择安装目录！", "提示")
        return
    }

    $installBtn.Enabled = $false
    $browseBtn.Enabled = $false
    $dirBox.Enabled = $false
    $logBox.Clear()
    $progressBar.Value = 0

    Write-Log ">>> 开始安装 Hermes Agent"
    Write-Log ">>> 安装目录: $installPath"
    $progressBar.Value = 10

    Write-Log ">>> 正在下载安装脚本..."
    $progressBar.Value = 30

    try {
        $dataPath = "$installPath\data"
        $scriptBlock = [scriptblock]::Create((Invoke-RestMethod https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1))
        Write-Log ">>> 正在安装，请稍候..."
        $progressBar.Value = 50

        & $scriptBlock -InstallDir $installPath -HermesHome $dataPath -SkipSetup

        $progressBar.Value = 70
        Write-Log ">>> 正在创建启动器..."

        # 下载启动器脚本到安装目录
        $launcherUrl = "https://raw.githubusercontent.com/gongxianga/hermes-install/main/launch-hermes.ps1"
        $launcherPath = "$installPath\launch-hermes.ps1"
        Invoke-WebRequest -Uri $launcherUrl -OutFile $launcherPath

        # 在桌面创建快捷方式
        $desktopPath = [System.Environment]::GetFolderPath("Desktop")
        $shortcutPath = "$desktopPath\Hermes Agent.lnk"
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -File `"$launcherPath`""
        $shortcut.WorkingDirectory = $installPath
        $shortcut.Description = "启动 Hermes Agent"
        $shortcut.Save()

        $progressBar.Value = 90
        Write-Log ">>> 桌面快捷方式已创建！" "Cyan"
        Write-Log ">>> 安装完成！" "Cyan"
        $progressBar.Value = 100

        [System.Windows.Forms.MessageBox]::Show(
            "安装成功！`n`n桌面已创建「Hermes Agent」快捷方式，双击即可启动。`n`n首次运行请在 PowerShell 中执行：`n  hermes setup",
            "安装完成",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } catch {
        Write-Log ">>> 错误: $_" "Red"
        [System.Windows.Forms.MessageBox]::Show("安装失败：$_", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $installBtn.Enabled = $true
        $browseBtn.Enabled = $true
        $dirBox.Enabled = $true
    }
})

$form.ShowDialog()
