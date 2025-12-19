#Requires AutoHotkey v2.0
#SingleInstance Force

; Win + o → 切换/启动 Chrome
#o:: {
    chromeWin := WinExist("ahk_exe chrome.exe ahk_class Chrome_WidgetWin_1")
    if (chromeWin) {
        if (WinGetMinMax(chromeWin) = -1)
            WinRestore(chromeWin)
        WinActivate(chromeWin)
    } else {
        chromePath := "C:\Users\PC\scoop\apps\googlechrome\current\chrome.exe"
        if (FileExist(chromePath))
            Run(chromePath)
        else
            MsgBox("Chrome 路径不存在：`n" chromePath, "错误", "IconX")
    }
}

; Win + i → 切换/启动 Ghostty (WSLg)，并以最大化窗口显示
#i:: {
    ghosttyWin := WinExist("ahk_class RAIL_WINDOW")
    if (ghosttyWin) {
        if (WinGetMinMax(ghosttyWin) = -1)
            WinRestore(ghosttyWin)
        WinActivate(ghosttyWin)
    } else {
        try {
            Run('wsl.exe ~ -e sh -lc "ghostty"', , 'Hide')
            if (!WinWait("Ghostty ahk_class RAIL_WINDOW",, 10)) {
                MsgBox("Ghostty 窗口启动超时！`n请确保已安装 ghostty 并可在 WSL 中运行。", "提示", "IconWarning")
            } else {
                newWin := WinExist("Ghostty ahk_class RAIL_WINDOW")
                if (newWin) {
                    WinMaximize(newWin)
                    WinActivate(newWin)
                }
            }
        } catch as e {
            MsgBox("启动 Ghostty 失败：`n" e.Message, "错误", "IconX")
        }
    }
}

; Win + 8 → 切换/启动 Code
#8:: {
    codeWin := WinExist("ahk_exe Code.exe")
    if (codeWin) {
        if (WinGetMinMax(codeWin) = -1)
            WinRestore(codeWin)
        WinActivate(codeWin)
    } else {
        ; Code 通常通过 Windows Store 或官方安装，路径较固定
        codePath := "C:\Users\PC\scoop\apps\vscode\current\Code.exe"
        Run(codePath)
            if (!WinWait("ahk_exe Code.exe",, 10)) {
                MsgBox("Code 窗口启动超时", "提示", "IconWarning")
            } else {
                newWin := WinExist("ahk_exe Code.exe")
                if (newWin) {
                    WinMaximize(newWin)
                    WinActivate(newWin)
                }
	}
    }
}

; Win + 9 → 切换/启动 WPS Office (Writer)
#9:: {
    wpsWin := WinExist("ahk_exe wps.exe")
    if (wpsWin) {
        if (WinGetMinMax(wpsWin) = -1)
            WinRestore(wpsWin)
        WinActivate(wpsWin)
    } else {
        ; 尝试常见 WPS 安装路径（支持默认安装和 Scoop 安装）
        wpsPaths := [
            "C:\Users\PC\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
        ]
        launched := false
        for path in wpsPaths {
            Loop Files, path, "R"
            {
                if (A_LoopFilePath) {
                    Run(A_LoopFilePath)
                    launched := true
                    break
                }
            }
            if (launched)
                break
        }
        if (!launched)
            MsgBox("未找到 WPS 安装路径。`n请确保已安装 WPS Office。", "错误", "IconX")
    }
}

; Win + 0 → 切换/启动 Spotify
#0:: {
    spotifyWin := WinExist("ahk_exe Spotify.exe")
    if (spotifyWin) {
        if (WinGetMinMax(spotifyWin) = -1)
            WinRestore(spotifyWin)
        WinActivate(spotifyWin)
    } else {
        ; Spotify 通常通过 Windows Store 或官方安装，路径较固定
        spotifyPath := "C:\Users\PC\scoop\apps\Spotify\current\Spotify.exe"
            Run(spotifyPath)
	     if (!WinWait("ahk_exe Spotify.exe",, 10)) {
                MsgBox("Spotify 窗口启动超时", "提示", "IconWarning")
            } else {
                newWin := WinExist("ahk_exe Spotify.exe")
                if (newWin) {
                    WinMaximize(newWin)
                    WinActivate(newWin)
                }
	}

    }
}
