#!/usr/bin/perl

use Socket;

$port = 2025;

$basedir = "/opt/mailsim/" ;
$logdir = $basedir . "/log/" ;
$logfile = $logdir . "mail-simulator.log" ;

open ( LOGFILE, ">>$logfile" ) or print "$! - $logfile\n";

$maildir = $basedir . "/mailfiles/" ;
	
$mailfilesusername = "canvasuser" ;

$sockaddr = 'S n a4 x8';
$authcount=0;

($name, $aliases, $proto) = getprotobyname('tcp');
print LOGFILE "::: Triple Colon Delimeter :::\n" ;
print LOGFILE "Run Start: " . scalar( localtime() ) . "\n\n" ;
print LOGFILE "Port = $port\n";

$sessionMessages = 0;

$thisaddr = gethostbyname(`hostname`);

$this = pack($sockaddr, AF_INET, $port, $thisaddr);

socket(S, AF_INET, SOCK_STREAM, $proto);

bind(S,$this) || die "bind: $!";
listen(S,5) || die "connect: $!";

select(S); $| = 1; select(stdout);
for(;;) {
   print LOGFILE "Listening for connection....\n";
   ($addr = accept(NS,S)) || die $!;
    $sessionMessages++ ;
    @messageContents = () ;
    $timestamp = time ;
    $mailmessage = $maildir . $timestamp ;
    send(NS,"220 OK TEST SERVER NO SEND\r\n",0);
   ($af,$port,$inetaddr) = unpack($sockaddr,$addr);
   @inetaddr = unpack('C4',$inetaddr);
   print LOGFILE "Connection $timestamp" . "." . "$sessionMessages From: $af $port @inetaddr\n";

   $ctr=0;
   while ($t=<NS>) {
      $ctr++;
      if( substr($t,0,4) eq "QUIT") {
         send(NS,"221 Bye\r\n",0);
         last;
      }
      print LOGFILE $t;
#      push @messageContents, $t ;
 
      if( substr($t,0,1) eq '.') {
         send(NS,"250 Ok: queued as $mailmessage\r\n",0);
	 open( MAILMESSAGE, ">$mailmessage") or print LOGFILE "ERROR -- counter: $ctr $! $mailmessage \n" ;
	 print MAILMESSAGE @messageContents ;
	 close( MAILMESSAGE ) ;
	 `chown $mailfilesusername $mailmessage` ; 
         next;
      }
      $x=substr($t,0,4);

      if( ($x eq "HELO") || ($x eq "MAIL") ||
         ($x eq "RSET") || ($x eq "QUIT")) {
            send(NS,"250 Ok\r\n",0);
      } elsif( ($x eq "DATA") ) {
            send(NS,"354 End data with <CR><LF>.<CR><LF>k\r\n",0);
      } elsif( ($x eq "QUIT") ) {
            send(NS, "221 Bye\r\n",0);
      } elsif( ($x eq "EHLO") ) {
            send(NS, "500 ERROR - EHLO not supported\r\n",0);
      } elsif( ($x eq "RCPT") ) {
	    send(NS,"250 Ok\r\n",0);
	    ($command, $emailaddr ) = split /:/, $t ;
	    $emailaddr =~ s/[<>]//g ;
	    $emailaddr =~ s/\@/AT/g ;
     	    $emailaddr =~ s/^\s+|\s+$//g;
	    $mailmessage = $mailmessage . "-" .  $emailaddr ;
      } else {
	    # write everything that is not a command to the email message
	    push @messageContents, $t ;
      }
   }
   close(NS);
}

