Loop
{
    pid := ProcessWait("WindowsTerminal.exe")
    WinWaitActive Format("ahk_pid {}", pid)
    ; NFER(to hiragana) -> KANJI(ime off)
    Send "{vk1d}{vk19}"
    ProcessWaitClose(pid)
}
