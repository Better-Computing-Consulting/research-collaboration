use Net::SMTP;
$arg = shift;
if ($arg eq "Ronald") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.orgv'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
elsif ($arg eq "xxxxxx") {$to = 'jd@domain.org'}
else {$to = 'sample@sample.org'}
#Change $server, $fullname, and $from to fit the environment.
$server 	= "smtphost";
$fullname 	= "Model 2.5";
$from		= 'jd@domain.org';
open(INFILE, 'E:\model25ssh-pl\makefile_tmp\subject.txt') or die "Can't open input: $!";
$subject 	= <INFILE>;
close INFILE;
unlink 'E:\model25ssh-pl\makefile_tmp\subject.txt';
$smtp = Net::SMTP->new($server);
$smtp->mail($from);
$smtp->to($to);
$smtp->data();
$smtp->datasend("From: ", $fullname, "<", $from , ">", "\n");
$smtp->datasend("To: ", $to, "\n");
$smtp->datasend("Subject: ", $subject, "\n");
$smtp->datasend("\n");
$smtp->dataend();
$smtp->quit;


