Option Explicit
Dim MissingFiles, RunFiles, SasFiles, JobDirectory, result, scrFolder

MissingFiles = FindMissingFiles

If MissingFiles <> "" Then
	GetMissingFiles(MissingFiles)
	LaunchProcessJobScript
    result = "These files were downloaded:" & vbCrLf & vbCrLf & MissingFiles
Else
	result = "There were no files to download from the sftp server."
End If

SendEmail(result)

'#####################################################################################
Function FindMissingFiles
	Dim oEx, tmpMissFiles, tmpline, afile
	Set oEx = CreateObject("WScript.Shell").Exec("psftp newuser@sshost -pw test -b E:\model25ssh-vb\home\run\sftp_ls_cmd")
	Do While oEx.Status = 0
     	WScript.Sleep 100
	Loop
	tmpMissFiles = Split(oEx.StdOut.ReadAll, vbCrLf)
	For each tmpline in tmpMissFiles
		If (InStr( LCase(tmpLine), ".sas") Or InStr( LCase(tmpLine), ".run")) Then
			afile = Right(tmpline, Len(tmpline) - InStrRev(tmpline, " "))
	   		FindMissingFiles = FindMissingFiles & afile & vbCrLf
	   		If (InStr( afile, ".sas")) Then
	   			SasFiles = SasFiles & afile & ";"
	   		Else
	   			RunFiles = RunFiles & afile & ";"
	   		End If
		End If
	Next
End Function

'#####################################################################################
Function GetMissingFiles(Missing_Files)
	Dim tmpFiles, tmpContents, tmpFile, MyFile, oEx
	tmpFiles = split(Missing_Files, vbCrLf)
	JobDirectory = "E:\model25ssh-vb\home\rsub\Job-" & myDate & "\"
	CreateObject("Scripting.FileSystemObject").CreateFolder(JobDirectory)
	tmpContents = "lcd " & JobDirectory  & vbCrLf
	''''Check for file already exists
	For each tmpFile in tmpFiles
		If tmpFile <> "" Then
			tmpContents = tmpContents & "get rsub/" & tmpFile & vbCrLf & "del rsub/" & tmpFile & vbCrLf
		End If
	Next
	tmpContents = tmpContents & "quit"
	Set MyFile = CreateObject("Scripting.FileSystemObject").CreateTextFile("E:\model25ssh-vb\home\run\sftp_get_cmds", True)
	MyFile.Write(tmpContents)
	MyFile.Close
	Set oEx = CreateObject("WScript.Shell").Exec("psftp newuser@sshost -pw test -b E:\model25ssh-vb\home\run\sftp_get_cmds")
	Do While oEx.Status = 0
     	WScript.Sleep 100
	Loop
End Function

'#####################################################################################
Sub LaunchProcessJobScript
    Dim WshShell, oExec, strCommand
    strCommand = "ProcessJobs.vbs" & _
    		" " & Chr(34) & JobDirectory & Chr(34) & _
    		" " & Chr(34) & RunFiles & Chr(34) & _
    		" " & Chr(34) & SasFiles & Chr(34)
    Set WshShell = CreateObject("WScript.Shell")
    WshShell.Run strCommand, 0
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

'#####################################################################################
Sub SendEmail(msg)
    Const cdoSendUsingMethod = "http://schemas.microsoft.com/cdo/configuration/sendusing"
    Const cdoSMTPServer = "http://schemas.microsoft.com/cdo/configuration/smtpserver"
    Const cdoSendUsingPort = 2
    Dim iConf
    Dim Flds
    Set iConf = CreateObject("CDO.Configuration")
    Set Flds = iConf.Fields
    With Flds
	.Item(cdoSendUsingMethod) = cdoSendUsingPort
	.Item(cdoSMTPServer) = "smtphost"
	.Update
    End With
    Dim iMsg
    Set iMsg = CreateObject("CDO.Message")
    With iMsg
	Set .Configuration = iConf
	.To       = "John Doe <jd@domain.edu>"
	.From     = "SFTP Script <jd@domain.edu>"
	.Subject  = "SFTP download run result"
	.TextBody = msg & vbCrLf & vbCrLf & "Job ended @ " & Now()
	.Send
    End With
    Set iMsg = Nothing
End Sub