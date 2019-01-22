#!/usr/bin/perl

$mailfileslocaldir = "/opt/mailsim/mailfiles/" ;

$mailfilesremotedir = "/home/canvas/pub_html/stage/mailfiles" ;


opendir( my $dh, $mailfileslocaldir ) || die "can't opendir $mailfileslocaldir: $1";

@files = grep { /^1/ && -f "$mailfileslocaldir/$_" } readdir($dh);

closedir $dh ;

foreach $filename ( @files ) {
	 print "$filename\n" ;
	`scp -p $mailfileslocaldir/$filename "canvas\@fraser.sfu.ca:$mailfilesremotedir/."` ;
	`mv $mailfileslocaldir/$filename $mailfileslocaldir/sent/` ;

}

