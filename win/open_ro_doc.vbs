'http://www.alato.ne.jp/kazu-/vb/etc_tip01.htm

Dim strDOCFileName
Dim objDOCApp

'引数のチェック
If WScript.Arguments.Count <> 1 Then WScript.Quit

'ﾌｧｲﾙ名取得
strDOCFileName = WScript.Arguments(0)

'起動
Set objDOCApp = WScript.CreateObject("Word.Application")
objDOCApp.Visible = True

'読み取り専用で開く
Call objDOCApp.Documents.Open(strDOCFileName,,True)

'終了処理
Set objDOCApp = Nothing
WScript.Quit
