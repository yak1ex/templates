'http://www.alato.ne.jp/kazu-/vb/etc_tip01.htm

Dim strDOCFileName
Dim objDOCApp

'�����̃`�F�b�N
If WScript.Arguments.Count <> 1 Then WScript.Quit

'̧�ٖ��擾
strDOCFileName = WScript.Arguments(0)

'�N��
Set objDOCApp = WScript.CreateObject("Word.Application")
objDOCApp.Visible = True

'�ǂݎ���p�ŊJ��
Call objDOCApp.Documents.Open(strDOCFileName,,True)

'�I������
Set objDOCApp = Nothing
WScript.Quit
