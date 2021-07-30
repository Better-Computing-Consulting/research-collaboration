use File::Basename;
$afile = shift;
if (-e $afile){
	system('pscp -pw dummypw) ' . $afile . ' user@sshost:output');
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	$mytime = $year+1900 . sprintf("%02d", $mon+1) . sprintf("%02d", $mday);
	$mytime .= sprintf("%02d", $hour) . sprintf("%02d", $min);
	$procdir = 'E:\vbs\processed\sent-'.$mytime.'\\';
	if (!chdir($procdir)){ mkdir($procdir)}
	rename($afile, $procdir . basename($afile));
}