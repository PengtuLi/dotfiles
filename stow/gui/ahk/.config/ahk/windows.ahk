#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================
; 通用函数：切换或启动应用
; ============================
ToggleOrLaunchApp(exeName, launchCmd, winClass := "", maximizeOnLaunch := true, timeout := 10) {
    winTitle := "ahk_exe " exeName
    if (winClass != "")
        winTitle .= " ahk_class " winClass

    winId := WinExist(winTitle)
    if (winId) {
        if (WinGetMinMax(winId) = -1)
            WinRestore(winId)
        WinActivate(winId)
    } else {
        ; 不再检查 FileExist，因为 launchCmd 可能是命令或 .lnk
        Run(launchCmd)

        if (!WinWait("ahk_exe " exeName, , timeout)) {
            MsgBox(exeName " 启动超时（超过 " timeout " 秒）", "提示", "IconWarning")
            return
        }

        newWin := WinExist("ahk_exe " exeName)
        if (newWin) {
            if (maximizeOnLaunch)
                WinMaximize(newWin)
            WinActivate(newWin)
        }
    }
}

; ============================
; 快捷键定义（修复版）
; ============================
; 提升输入级别，确保我们的热键优先于系统
#]::ToggleOrLaunchApp("chrome.exe", "chrome")
#[::ToggleOrLaunchApp("WindowsTerminal.exe", "wt")
#8::ToggleOrLaunchApp("Code.exe", "C:\Users\PC\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\Visual Studio Code")
#9::ToggleOrLaunchApp("wps.exe", "C:\Users\PC\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\WPS Office")
#0::ToggleOrLaunchApp("Spotify.exe", "C:\Users\PC\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\Spotify")
