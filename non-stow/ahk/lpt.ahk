#Requires AutoHotkey v2.0
#SingleInstance Force

; Win + o → 切换/启动 Chrome
#o:: {
    chromeWin := WinExist("ahk_exe chrome.exe ahk_class Chrome_WidgetWin_1")
    if (chromeWin) {
        ; 仅当窗口最小化时才恢复，避免不必要的大小变动
        if (WinGetMinMax(chromeWin) = -1) {
            WinRestore(chromeWin)
        }
        WinActivate(chromeWin)
    } else {
        chromePath := "C:\Users\PC\scoop\apps\googlechrome\current\chrome.exe"
        if (FileExist(chromePath)) {
            Run(chromePath)
        } else {
            MsgBox("Chrome 路径不存在：`n" chromePath, "错误", "IconX")
        }
    }
}
; Win + i → 切换/启动 Ghostty (WSLg)，并以最大化窗口显示
#i:: {
    ; 尝试查找已存在的 Ghostty 窗口（RAIL_WINDOW + 标题含 Ghostty）
    ghosttyWin := WinExist("ahk_class RAIL_WINDOW")
    
    if (ghosttyWin) {
        ; 如果窗口最小化，先恢复（避免从最小化直接最大化异常）
        if (WinGetMinMax(ghosttyWin) = -1) {
            WinRestore(ghosttyWin)
        }
        WinActivate(ghosttyWin)
    } else {
        try {
            ; 启动 Ghostty（后台运行）
            Run("wsl -e ghostty", , "Hide")

            ; 等待最多 10 秒，匹配标题含 "Ghostty" 且类为 RAIL_WINDOW 的窗口
            if (!WinWait("Ghostty ahk_class RAIL_WINDOW",, 10)) {
                MsgBox("Ghostty 窗口启动超时！`n请确保已安装 ghostty 并可在 WSL 中运行。", "提示", "IconWarning")
            } else {
                ; 获取刚刚出现的窗口句柄（WinWait 成功后，A_ThisWin 会被设置，但更可靠的是重新获取）
                newWin := WinExist("Ghostty ahk_class RAIL_WINDOW")
                if (newWin) {
                    ; 强制最大化并激活
                    WinMaximize(newWin)
                    WinActivate(newWin)
                }
            }
        } catch as e {
            MsgBox("启动 Ghostty 失败：`n" e.Message, "错误", "IconX")
        }
    }
}