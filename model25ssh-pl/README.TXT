Add the path of sas.exe, psftp.exe, pscp.exe and the "run" directory
(E:\model25ssh-pl\home\run) to Windows' %PATH% envaironment variable.

Check the login information for the SFTP server in the snd and GetFiles 
scripts.

Check the variables for the SMTP sever for the sendmail functions
in the sendmail, getfiles and processjobs scripts.

The scripts and sas macros are coded for working in this directory 
(model25ssh-pl) located at the root of an E: drive.  If this folder is 
renamed or placed in a diferent drive, search the scripts and the sas 
macros file for instances of "E:\" and edit the scripts and recompile 
the sas macro file.

