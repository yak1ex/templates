'http://www.alato.ne.jp/kazu-/vb/etc_tip01.htm
'http://blog.goo.ne.jp/yandex/e/795fe62044b0e0f3630c099a5e2ee279

Dim strXlsFileName
Dim objXlsApp

'引数のチェック
If WScript.Arguments.Count <> 1 Then WScript.Quit

'ファイル名取得
strXlsFileName = WScript.Arguments(0)

'起動
Set objXlsApp = WScript.CreateObject("Excel.Application")
objXlsApp.Visible = True

'読み取り専用で開く
Call objXlsApp.Workbooks.Open(strXlsFileName,,True)

'終了時に保存を確認しない（ダイアログ非表示）
objXlsApp.DisplayAlerts = False

'終了処理
Set objXlsApp = Nothing
WScript.Quit
