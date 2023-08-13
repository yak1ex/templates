; https://github.com/k-ayaki/IMEv2.ahk
#Include "IMEv2.ahk"

; For Discord and Google Japanese Input,
; Force sane key binding: enter -> line break / ctrl + enter -> submit
;     For Google Japanese Input, IME_GetConverting() doesn't return 1.
;     Thus, quick and dirty hack is employed, which may be fragile.

; wait status is cleared after this delay passed
WAIT_CLEAR := 2000
; check if candidate window keeps for detecting conversion state after this delay passed
WAIT_CHECK := 50

g_wait := False

WinActiveAndImeOff(criteria)
{
    hwnd := WinActive(criteria)
    criteria := Format("ahk_id {}", hwnd)
    ; IME off -> swap
    ; IME on && converting -> not swap
    ; IME on && wait -> not swap
    return hwnd && (NOT IME_GET(criteria) || (NOT IME_GetConverting(criteria) = 2 && NOT g_wait))
}

WinActiveAndImeConverting(criteria)
{
    hwnd := WinActive(criteria)
    criteria := Format("ahk_id {}", hwnd)
    return hwnd && IME_GET(criteria) && IME_GetConverting(criteria) = 2
}

WinActiveAndImeWait(criteria)
{
    hwnd := WinActive(criteria)
    criteria := Format("ahk_id {}", hwnd)
    return hwnd && g_wait
}

#HotIf WinActiveAndImeOff("ahk_class Chrome_WidgetWin_1 ahk_exe Discord.exe")
enter::
{
    Send "+{Enter}"
    global g_wait := False
}
^enter::
{
    Send "{Enter}"
    global g_wait := False
}
#HotIf WinActiveAndImeConverting("ahk_class Chrome_WidgetWin_1 ahk_exe Discord.exe")
~Space::
{
    Sleep WAIT_CHECK
    global g_wait := NOT IME_GetConverting("ahk_class Chrome_WidgetWin_1 ahk_exe Discord.exe")
    SetTimer clear, -WAIT_CLEAR
    clear() {
        g_wait := False
    }
}
#HotIf WinActiveAndImeWait("ahk_class Chrome_WidgetWin_1 ahk_exe Discord.exe")
~enter::
{
    global g_wait := False
}
