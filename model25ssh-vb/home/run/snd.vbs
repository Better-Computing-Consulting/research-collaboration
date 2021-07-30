Option Explicit
Dim Sh
Set Sh = CreateObject("WScript.Shell")

If WScript.Arguments.Count > 0 Then
	Dim afile
	afile = WScript.Arguments(0)
	If (CreateObject("Scripting.FileSystemObject").FileExists(afile)) Then
		PutFile WScript.Arguments(0)
	Else
		Sh.LogEvent 0, "Unexisting file passed to snd script: " & afile
	End If
Else
	Sh.LogEvent 0, "No file passed to snd script."
End If

Sub PutFile(a_file)
	Dim sPath, sFile, sFolder, MyFile, oEx, fso
	'Run pscp to put file
	Set oEx = Sh.Exec("pscp.exe -pw test """ & a_file & """ newuser@sshost:output")
	Do While oEx.Status = 0
     	WScript.Sleep 100
	Loop
	'Move the file to the processed directory
	sFolder = "E:\model25ssh-vb\home\processed\" & myDate() & "-output\"
	Set fso = CreateObject("Scripting.FileSystemObject")
	If not fso.FolderExists(sFolder) Then
		fso.CreateFolder(sFolder)
	End If
	fso.MoveFile a_file, sFolder
	Sh.LogEvent 0, "File put by snd script: " & a_file
End Sub

'#####################################################################################
Function myDate()
    Dim rnow
    rnow = now
    myDate = Year(rnow) & _
	twodigits(Month(rnow)) & _
	twodigits(Day(rnow)) & _
	twodigits(Hour(rnow)) & _
	twodigits(Minute(rnow))
End Function
Function twodigits(intime)
    If intime < 10 Then
        twodigits = "0" & intime
    Else
        twodigits = intime
    End If
End Function