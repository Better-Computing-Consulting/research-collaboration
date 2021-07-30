Option Explicit
Const ForReading = 1
Dim fso, f, ms, objArgs
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.OpenTextFile("E:\model25ssh-vb\makefile_tmp\subject.txt", ForReading)
ms =  f.ReadAll
f.close
fso.DeleteFile "E:\model25ssh-vb\makefile_tmp\subject.txt", true
Set objArgs = WScript.Arguments

sendemail TrimText(ms), getAddress(objArgs(0))

Sub SendEmail(msg, sendto)
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
	.To       = sendto
	.From     = "SAS Job Submission<jd@domain.edu>"
	.Subject  = msg
	.TextBody = "Email Notification from VSD Model 2.5 Job (SFTP)" & vbCrLf & vbCrLf & Now()
	.Send
    End With
    Set iMsg = Nothing
End Sub

Function TrimText(intext)
    Dim temp
    temp = intext
    If Asc(Right(temp, 1)) = 10 Then
	temp = Mid(temp, 1, Len(temp) - 2)
    End If
    If InStr(Left(temp, 1), "'") = 1 And _
       InStr(Right(temp, 1), "'") = 1 Then
    	TrimText = Mid(temp, 2, Len(temp) - 2)
    Else
        TrimText = temp
    End If
End Function

Function getAddress(acronym)
   Select Case lcase(acronym)
      Case "scxxxa"	getAddress = "jd@domain.edu"
      Case "scxxxi"	getAddress = "jd@domain.edu"
      Case "ncxxxl"	getAddress = "jd@domain.edu"
      Case "nxxxxs"	getAddress = "jd@domain.edu"
      Case "ncxxxd"	getAddress = "jd@domain.edu"
      Case "ncxxxd"	getAddress = "jd@domain.edu"
      Case "cdxxxb"	getAddress = "jd@domain.edu"
      Case "cxxxxk"	getAddress = "jd@domain.edu"
      Case "cdcxxr"	getAddress = "jd@domain.edu"
      Case "cdcxxt"	getAddress = "jd@domain.edu"
      Case "cdcxxc"	getAddress = "jd@domain.edu"
      Case "cdcxxx"	getAddress = "jd@domain.edu"
      Case Else		getAddress = "jd@domain.edu"
   End Select
End Function