; Copyright (C) 2016 Max Lee (https://github.com/Phoenix616/)
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the Mozilla Public License as published by
; the Mozilla Foundation, version 2.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; Mozilla Public License v2.0 for more details.
;
; You should have received a copy of the Mozilla Public License v2.0
; along with this program. If not, see <http://mozilla.org/MPL/2.0/>.

#Persistent
#InstallKeybdHook
SetBatchLines, -1
Process, Priority,, High

global name := "StopFocusSteal"
global version := "1.1"

global previous := -1
global current := -1

global lastNewWindow := 0

global logToFile := false ; Log everything to file
global showTrayTip := true ; Show tray tip when steal was blocked
global inputOnly := true ; Only stop stealing when keyboard typing is detected

global inStartMenu := false ; Whether or not the user is in the start menu
global inLaunchy := false ; Whether or not the user is in launchy
global modifier := false ; Whether or not the last input was a modifier key without real input

global preventInput := 1000 ; Number of milliseconds in which we should prevent input in newly created windows

if(FileExist(name . ".ini")) {
    IniRead , logToFile, %name%.ini, Settings, filelog, false
    IniRead , showTrayTip, %name%.ini, Settings, notifications, true
    IniRead , inputOnly, %name%.ini, Settings, inputonly, true
    IniRead , preventInput, %name%.ini, Settings, preventinput, 1000
} else {
    FileAppend , [Settings]`nfilelog=false`nnotifications=true`ninputonly=true`npreventinput=1000, %name%.ini
}

logToFile := logToFile && logToFile != "false"
showTrayTip := showTrayTip && showTrayTip != "false"
inputOnly := inputOnly && inputOnly != "false"

FileLog(name . " v" . version . " started!")
FileLog("Settings:")
FileLog(" logToFile: " . logToFile)
FileLog(" showTrayTip: " . showTrayTip)
FileLog(" inputOnly: " . inputOnly)
ShowTip(name . " v" . version . " started!", "[Settings] logToFile: " . logToFile . " showTrayTip: " . showTrayTip . " inputOnly: " . inputOnly)

; React on all the windows
Gui +LastFound
hWnd := WinExist()

DllCall( "RegisterShellHookWindow", UInt,hWnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

Return
   
ShellMessage(wParam, lParam) {
    WinGetTitle, Title, ahk_id %lParam%
    msg := lParam . " | " . wParam . " | " . Title
    if(wParam = 1) { ;  HSHELL_WINDOWCREATED := 1
        lastNewWindow := A_TickCount
        if(StopStealing(lParam)) {
            DllCall("FlashWindow", UInt, lParam , Int, 1)
            msg .= " <<< Stealing stopped! (Debug: " . A_TimeIdlePhysical . " " . inStartMenu . " " . inLaunchy . " " . ctrlClick . ")"
            ShowTip("Stopped Focus Steal", "Thief: " . Title . " (" . A_TimeIdlePhysical . " " . inStartMenu . " " . inLaunchy . " " . ctrlClick . ")")
        } else {            
            ;ShowTip("Not stopping window Focus Steal", "Thief: " . Title . " (" . lParam . ") " . current . " " . A_TimeIdlePhysical)
        }
    } 
    
    if(lParam > 0 && wParam = 32772) { 
    ; HSHELL_WINDOWDESTROYED:=2
    ; HSHELL_GETMINRECT:=5
    ; HSHELL_REDRAW:=6
    ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms644991(v=vs.85).aspx
        if(LogCurrent(lParam)) {
            msg .= " <<< Set current (previous: " . previous . ", current: " . current . ")"
        }
    }
    
    ; reset all state vars as they don't matter anymore after the first window changed
    inLaunchy := false
    inStartMenu := false
    modifier := false
    
    ; log it if it's enabled, useful for debugging stuff
    FileLog(msg)
}
    
ShowTip(title, text) {
    if(showTrayTip) {
        TrayTip, %title%, %text%, 10, 16
    }
    return
}

FileLog(text) {
    if(logToFile ) {
        FormatTime, CurrentDateTime,, yy-MM-dd HH:mm:ss
        FileAppend , `n[%CurrentDateTime%] %text%, %name%.log
    }
    return
}

StopStealing(id) {
    if(inputOnly)
        if(A_TimeIdlePhysical > 2000 || inLaunchy || inStartMenu || modifier)
            return false
            
    if(current > 0 && current != id) {
        WinActivate, ahk_id %current%
        return true
    } else if(previous > 0 && previous != id) {
        WinActivate, ahk_id %previous%
        return true
    }
    return false
}

LogCurrent(id){
    if(id != current){
        previous = %current%
        current = %id%
        return true
    }
    return false
}

$Enter::
    IfWinActive, ahk_class DV2ControlHost
        IfWinActive, ahk_exe explorer.exe
            inStartMenu := true
    IfWinActive, ahk_class QTool 
        IfWinActive, ahk_exe Launchy.exe
            inLaunchy := true
    if(lastNewWindow + preventInput < A_TickCount)
        SendInput {Enter}
    return

$Esc::
    if(inLaunchy || inStartMenu) {
        inLaunchy := false
        inStartMenu := false
    }
    if(lastNewWindow + preventInput < A_TickCount)
        SendInput {Esc}
    return

~+::
~!::
~#::
~^::
    modifier := true
    return