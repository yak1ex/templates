'http://www.alato.ne.jp/kazu-/vb/etc_tip01.htm
'http://blog.goo.ne.jp/yandex/e/795fe62044b0e0f3630c099a5e2ee279

Dim strXlsFileName
Dim objXlsApp

'�����̃`�F�b�N
If WScript.Arguments.Count <> 1 Then WScript.Quit

'�t�@�C�����擾
strXlsFileName = WScript.Arguments(0)

'�N��
Set objXlsApp = WScript.CreateObject("Excel.Application")
objXlsApp.Visible = True

'�ǂݎ���p�ŊJ��
Call objXlsApp.Workbooks.Open(strXlsFileName,,True)

'�I�����ɕۑ����m�F���Ȃ��i�_�C�A���O��\���j
objXlsApp.DisplayAlerts = False

'�I������
Set objXlsApp = Nothing
WScript.Quit
