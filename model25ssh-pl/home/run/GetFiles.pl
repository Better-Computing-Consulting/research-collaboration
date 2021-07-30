$ls_cmd = 'psftp KPC@vaccinefs1.rei.edu -pw password -b E:\model25ssh-pl\home\run\sftp_ls_cmd';
@output = `$ls_cmd`;
foreach $line (@output){
	$tmpline = $line;
	if($line =~ /([^\s]+.run|[^\s]+.sas)$/i){push @files, "$1\n" };}
if ( @files != '' ){
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	$mytime = $year+1900 . sprintf("%02d", $mon+1) . sprintf("%02d", $mday);
	$mytime .= sprintf("%02d", $hour) . sprintf("%02d", $min);
	$JobDirectory = 'E:\model25ssh-pl\home\rsub\Job-' . $mytime;
	mkdir($JobDirectory);
	chdir($JobDirectory);
	open(OUTFILE, '>E:\model25ssh-pl\home\run\sftp_get_cmds') or die "Can't open output.txt: $!";
	foreach $file (@files){ print OUTFILE "get rsub/$file"."del rsub/$file"; $files .= $file };
	print OUTFILE "quit";
	close OUTFILE;
	system('psftp user@sshost -pw dummypw -b E:\model25ssh-pl\home\run\sftp_get_cmds');
	SendEmail("These files where downloaded from the sftp server:\n\n" . $files);
	exec('ProcessJobs.pl ' . $JobDirectory);}
else{
	SendEmail("There were no new files to download from the sftp server.");}
sub SendEmail{
    use Net::SMTP;
    #Change $server, $fullname, and $from to fit the environment.
    $server 	= smtphost";
    $to 	= 'jd@domain.org';
    $fullname 	= "SFTP GetFiles Script";
    $from	= 'jd@domain.org';
    $subject 	= "SFTP download run result";
    $now 	= localtime;
    $body	= $_[0] . "\n\nJob Ended: " . $now;
    #Send Email
    $smtp = Net::SMTP->new($server);
    $smtp->mail($from);
    $smtp->to($to);
    $smtp->data();
    $smtp->datasend("From: ", $fullname, "<", $from , ">", "\n");
    $smtp->datasend("To: ", $to, "\n");
    $smtp->datasend("Subject: ", $subject, "\n");
    $smtp->datasend("\n");
    $smtp->datasend($body);
    $smtp->dataend();
    $smtp->quit;}
