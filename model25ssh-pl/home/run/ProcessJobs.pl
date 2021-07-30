$JobDirectory = shift;
my $sfiles;
my $Errors;
my $ProcessedSASJobs;
my $SASJobsInRunFiles;
my $SASJobsNotInRunFiles;
#Open working directory and get a listing of its contents.
opendir(DH, $JobDirectory);
@files = readdir(DH);
closedir(DH);
foreach $afile (sort grep(!/^\.\.?$/, @files)){ $sfiles = $sfiles . $afile };
#Process .run files
foreach $afile (sort grep(!/^\.\.?$/, @files)){
    if (lc($afile) =~ /(.run)$/){ProcOneRunFile($afile)}};
#Process .sas files not included in run files
foreach $afile (sort grep(!/^\.\.?$/, @files)){
    if (lc($afile) =~ /(.sas)$/ && $ProcessedSASJobs !~ /$afile/){
    	$SASJobsNotInRunFiles = $SASJobsNotInRunFiles . $afile . "\n";
    	ProcOneSASJob($afile)}};
#Send Email re processed files
SendEmail("Total files processed by SAS:\n\n" . $ProcessedSASJobs .
	"\nSas jobs included in Run files:\n\n" . $SASJobsInRunFiles .
	"\nSas jobs not included in Run files:\n\n" . $SASJobsNotInRunFiles .
	"\nErrors:\n\n" . $Errors);
## END MAIN - START PROCEDURES ###############################################
sub ProcOneRunFile{
    open(INFILE, $JobDirectory . '\/' . $_[0]) or die "Can't open file: $!";
    my @sasjobs = <INFILE>;
    close INFILE;
    foreach $sasjob (@sasjobs){
    	$sasjob =~ s/\s+$//;
    	if (lc($sasjob) =~ /(.sas)$/ && $sfiles =~ /$sasjob/){
    	    ProcOneSASJob($sasjob);
    	    $SASJobsInRunFiles = $SASJobsInRunFiles . $sasjob . "\n"}
    	else {
    	    $Errors = $Errors . $sasjob . " was included in " . $_[0] . " but was not in ftp server for download.\n"}};
}
sub ProcOneSASJob{
    $command = 'sas ' . $JobDirectory . '\/' . $_[0] . ' -LOG ' . $JobDirectory . ' -PRINT ' . $JobDirectory;
    $command .= ' -AUTOEXEC E:\model25ssh-pl\home\run\START.SAS -WORK ' . $JobDirectory;
    chdir($JobDirectory);
    system($command);
    $ProcessedSASJobs = $ProcessedSASJobs . $_[0] . "\n"
}
sub SendEmail{
    use Net::SMTP;
    #Change $server, $fullname, and $from to fit the environment.
    $server 	= "smtphost";
    $to 	= 'jd@domain.org';
    $fullname 	= "SFTP ProcessJobs script";
    $from	= 'jd@domain.org';
    $subject 	= "Downloaded Jobs Processing Result";
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
    $smtp->quit;
}
