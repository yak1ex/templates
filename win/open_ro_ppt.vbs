'http://www.alato.ne.jp/kazu-/vb/etc_tip01.htm

Dim strPPTFileName
Dim objPPTApp

'引数のチェック
If WScript.Arguments.Count <> 1 Then WScript.Quit

'ﾌｧｲﾙ名取得
strPPTFileName = WScript.Arguments(0)

'起動
Set objPPTApp = WScript.CreateObject("Powerpoint.Application")
objPPTApp.Visible = True

'読み取り専用で開く
Call objPPTApp.Presentations.Open(strPPTFileName,True)

'終了処理
Set objPPTApp = Nothing
WScript.Quit
