Add sas executable path to environment.

Check the login information for the SFTP server in snd and GetFile scripts.

Check the variables for the SMTP sever for the sendmail functions
in the sendmail, getfiles and processjobs scripts.

The scripts are coded for running in an E: drive.  If this folder is
renamed or located in drive other than the E:, Search the scripts
for instances of "E:\" and edit the scripts.