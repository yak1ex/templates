'http://www.alato.ne.jp/kazu-/vb/etc_tip01.htm

Dim strPPTFileName
Dim objPPTApp

'�����̃`�F�b�N
If WScript.Arguments.Count <> 1 Then WScript.Quit

'̧�ٖ��擾
strPPTFileName = WScript.Arguments(0)

'�N��
Set objPPTApp = WScript.CreateObject("Powerpoint.Application")
objPPTApp.Visible = True

'�ǂݎ���p�ŊJ��
Call objPPTApp.Presentations.Open(strPPTFileName,True)

'�I������
Set objPPTApp = Nothing
WScript.Quit
