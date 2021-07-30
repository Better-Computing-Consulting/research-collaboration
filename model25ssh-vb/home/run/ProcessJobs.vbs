Dim objArgs, LocalDirectory, sRunFiles, sSasFiles, result, Errors
Dim SASJobsNotInRunFiles, SASJobsInRunFiles, ProcessedSasFiles, fso, f, f2

Set objArgs = WScript.Arguments
LocalDirectory = objArgs(0)
sRunFiles = objArgs(1)
sSasFiles = objArgs(2)

ProcessAllDownloadedFiles

result = "Total files processed by SAS:" & vbCrLf & ProcessedSasFiles & _
    	vbCrLf & vbCrLf & "Sas jobs included in Run files:" & vbCrLf & SASJobsInRunFiles & _
    	vbCrLf & vbCrLf & "Sas jobs not included in Run files:" & vbCrLf & SASJobsNotInRunFiles & _
    	vbCrLf & vbCrLf & "Errors: " & vbCrLf & Errors & vbCrLf & vbCrLf

Set fso = CreateObject("Scripting.FileSystemObject")

Set f = fso.GetFolder("E:\model25ssh-vb\home\run")
If f.files.count > 7 Then
    result = result & "There are leftover files in script directory." & vbCrLf & vbCrLf & vbCrLf
End If
Set f2 = fso.GetFolder("E:\model25ssh-vb\makefile_tmp")
If f2.files.count > 0 Then
    result = result & "There are unuploaded files in temp directory." & vbCrLf & vbCrLf & vbCrLf
End If

SendEmail result

'#####################################################################################
Sub ProcessAllDownloadedFiles()
    Dim f, afile, RunFiles, SasFiles
    If Not IsEmpty(sRunFiles) Then
	RunFiles = Split(sRunFiles, ";", -1, 1)
	For f = 0 to UBound(RunFiles) - 1
	    ProcessOneRunFile LocalDirectory & RunFiles(f)
	Next
    End If
    If Not IsEmpty(sSasFiles) Then
    	SasFiles = Split(sSasFiles, ";", -1, 1)
    	For f = 0 to UBound(SasFiles) - 1
    	    afile = SasFiles(f)
    	    If InStr(LCase(ProcessedSasFiles), LCase(afile)) = 0 Then
		SASJobsNotInRunFiles = SASJobsNotInRunFiles & afile & vbCrLf
		ProcessOneSasFile afile
	    End If
	Next
    End If
End Sub
'#####################################################################################
Sub ProcessOneRunFile(file)
    Const ForReading = 1, ForWriting = 2
    Dim fso, MyFile, ReadLineTextFile
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set MyFile = fso.OpenTextFile(file, ForReading)
    Do While MyFile.AtEndOfStream <> True
        ReadLineTextFile = TrimText(MyFile.ReadLine)
	If InStr(LCase(ReadLineTextFile), ".sas") Then
	    If fso.FileExists( LocalDirectory & ReadLineTextFile ) Then
	        ProcessOneSasFile ReadLineTextFile
	        SASJobsInRunFiles = SASJobsInRunFiles & ReadLineTextFile & vbCrLf
	    Else
	        Errors = Errors & ReadLineTextFile & " was included in file " & _
	        	fso.GetFileName(file) & " but was not included for download. " & vbCrLf
	    End If
	End If
    Loop
    MyFile.Close
End Sub
'#####################################################################################
Sub ProcessOneSasFile(file)
    Dim strCommand, WshShell, oExec, otherargs
    otherargs = " -AUTOEXEC E:\model25ssh-vb\home\START.SAS -WORK E:\model25ssh-vb\SASTEMP"
    If InStr(LCase(Right(file, 4)), ".sas") Then
        strCommand = "sas " & LocalDirectory & file & " -LOG " & LocalDirectory & " -PRINT " & LocalDirectory & " -AUTOEXEC E:\model25ssh-vb\home\run\START.SAS -WORK E:\model25ssh-vb\SASTEMP"
        Set WshShell = WScript.CreateObject("WScript.Shell")
        Set oExec = WshShell.Exec(strCommand)
        Do While oExec.Status = 0
            WScript.Sleep 100
        Loop
        ProcessedSasFiles = ProcessedSasFiles & file & vbCrLf
        Set WshShell = Nothing
    End If
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
Function TrimText(intext)
    TrimText = ""
    If Len(intext) > 4 Then
        Dim temp, tchar
        temp = intext
        tchar = Asc(Right(temp, 1))
        While (tchar <> 83) and (tchar <> 115) and (Len(temp) > 4)
	    temp = Mid(temp, 1, Len(temp) - 1)
    	    tchar = Asc(Right(temp, 1))
        Wend
        If Len(temp) > 4 Then
            TrimText = temp
        Else
            TrimText = ""
        End If
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
	.Item(cdoSMTPServer) = "c040"
	.Update
    End With
    Dim iMsg
    Set iMsg = CreateObject("CDO.Message")
    With iMsg
	Set .Configuration = iConf
	.To       = "John Doe <jd@domain.edu>"
	.From     = "SFTP Script <jd@domain.edu>"
	.Subject  = "SFTP Downloaded Jobs Processing Result"
	.TextBody = msg + "Job ended @ " & Now()
	.Send
    End With
    Set iMsg = Nothing
End Sub