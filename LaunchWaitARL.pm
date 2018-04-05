# package name (same as filename sans .pm)
package LaunchWaitARL;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

require Exporter;
@ISA = qw( Exporter );

# list of subroutines that we'll want to allow access to
my @stuff = qw( WaitARL );

@EXPORT = ( @stuff );
%EXPORT_TAGS = ( 'vars' => [@stuff], );

use lib ".";
use lib "/usr/local/share/perl";
use lib "/home/bluesky/bluesky_3.5.1/bluesky";

use TimeUtilities;
use LaunchLog;

sub SetWaitInterval
{
  my $waitinterval = 300;
  return($waitinterval);
}

sub SetMaxWait
{
  my $maxwaitsec   = 7200;
  return($maxwaitsec);
}

sub WaitNAM84
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};

  my $datadir = "/bluesky/data/nam/$ymdh";
  my $filesize = 1501616346;
  my @files = ( "nam_forecast-$ymdh\_00-84hr.arl" );
  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status); 
}

sub WaitNAM36
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};

  my $datadir = "/bluesky/data/nam/$ymdh";
  my $filesize = 1915855338;
  my @files = ( "nam_forecast-$ymdh\_00-36hr.arl" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitNAM4km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};
  my $hh   = substr($ymdh,-2);

  my $datadir = "/bluesky/data/NAM4km/$ymdh";
  my $filesize = 2043573036;
  my @files = ( "hysplit.t$hh\z.namsf00.CONUS",
                "hysplit.t$hh\z.namsf06.CONUS",
                "hysplit.t$hh\z.namsf12.CONUS",
                "hysplit.t$hh\z.namsf18.CONUS" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitGFS192
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};

  my $datadir = "/bluesky/data/gfs/$ymdh";
  my $filesize = 56806750;
  my @files = ( "gfs_forecast-$ymdh\_000-192hr.arl" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitFL4km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};

  my $datadir = "/bluesky/data/Florida/$ymdh";
  my $filesize = 281092700;
  my @files = ( "arlout_d02.ARL" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitAK12km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};
  my $hh   = substr($ymdh,-2);

  my $datadir = "/NAM/AK_12km/$ymdh";
  my $filesize = 1526522382;
  my @files = ( "hysplit.t$hh\z.namsf.AK" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitFW1km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};
  my $hh   = substr($ymdh,-2);

  my $datadir  = "/data/ARL/NAM/1km/$ymdh";
  my $filesize = 1000000000;
  my @files = ( "hysplit.t$hh\z.namsf.FW" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitDRI2km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};

  my $datadir = "/DRI_2km/$ymdh";
  my $filesize = 619862712;
  my @files = ( "wrfout_d3.$ymdh.f00-11_12hr01.arl",
                "wrfout_d3.$ymdh.f12-23_12hr02.arl",
                "wrfout_d3.$ymdh.f24-35_12hr03.arl",
                "wrfout_d3.$ymdh.f36-47_12hr04.arl",
                "wrfout_d3.$ymdh.f48-59_12hr05.arl",
                "wrfout_d3.$ymdh.f60-71_12hr06.arl" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitDRI6km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};

  my $datadir = "/DRI_6km/$ymdh";
  my $filesize = 228128028;
  my @files = ( "wrfout_d2.$ymdh.f00-11_12hr01.arl",
                "wrfout_d2.$ymdh.f12-23_12hr02.arl",
                "wrfout_d2.$ymdh.f24-35_12hr03.arl",
                "wrfout_d2.$ymdh.f36-47_12hr04.arl",
                "wrfout_d2.$ymdh.f48-59_12hr05.arl",
                "wrfout_d2.$ymdh.f60-71_12hr06.arl" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub WaitNWRMC4km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};
  my $dt   = get_dt_from_datestr($ymdh);
  my $dtm1 = $dt->clone->add( days => -1 );
  my $ymdhm1 = dt_to_ymdh($dtm1);

  my $datadir  = "/storage/Met/PNW/4km/ARL/$ymdh";
  my $filesize = 322213200;
  my @files    = ( "wrfout_d3.$ymdhm1.f24-35_12hr02.arl",
                   "wrfout_d3.$ymdh.f12-23_12hr01.arl",
                   "wrfout_d3.$ymdh.f24-35_12hr02.arl",
                   "wrfout_d3.$ymdh.f36-47_12hr03.arl",
                   "wrfout_d3.$ymdh.f48-59_12hr04.arl",
                   "wrfout_d3.$ymdh.f60-71_12hr05.arl",
                   "wrfout_d3.$ymdh.f72-83_12hr06.arl" );

  my $status1 =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status1) unless ($$args{name} =~ /CO$/);

  my $status2;
  if ($$args{name} =~ /CO$/) {
    my $datadir  = $$args{pddir}."/$$args{metsource}";
    my @files    = ( "$$args{metsource}_$ymdh\_PDIN" );
    $status2     = 
       CheckWaitPDIN($waitinterval,$maxwaitsec,$datadir,\@files,$args);
  }
  return(($status1&$status2));
}

sub WaitNWRMC4o3km
{
  my $args = shift;

  my $waitinterval = SetWaitInterval();
  my $maxwaitsec   = SetMaxWait();

  my $ymdh = $$args{ymdh};
  my $dt   = get_dt_from_datestr($ymdh);
  my $dtm1 = $dt->clone->add( days => -1 );
  my $ymdhm1 = dt_to_ymdh($dtm1);

  my $datadir = "/storage/Met/PNW/1.33km/ARL/$ymdh";
  #my $filesize = 727963260;
  my $filesize = 1329469260; # new file size w/expanded domain as of 1 Nov 2016
  my @files = ( "wrfout_d4.$ymdhm1.f24-35_12hr02.arl",
                "wrfout_d4.$ymdh.f12-23_12hr01.arl",
                "wrfout_d4.$ymdh.f24-35_12hr02.arl",
                "wrfout_d4.$ymdh.f36-47_12hr03.arl", 
                "wrfout_d4.$ymdh.f48-59_12hr04.arl",
                "wrfout_d4.$ymdh.f60-71_12hr05.arl" );

  my $status =
       CheckWait($waitinterval,$maxwaitsec,$datadir,$filesize,\@files,$args);
  return($status);
}

sub CheckWait
{
  my $waitinterval = shift;
  my $maxwaitsec   = shift;
  my $datadir      = shift;
  my $filesize     = shift;
  my $filesref     = shift;
  my $args         = shift;

  my $not_arrived    = 1;
  my $time_waited    = 0;
  my $files_expected = scalar(@$filesref);
  while ($not_arrived) {

    my $files_available = 0;

    if (-d $datadir) {
      chdir $datadir;

      my $file;
      foreach $file ( @$filesref ) {

        my $actualsize = (-s $file);
        $files_available++ if (( -e $file ) && ($actualsize >= $filesize));

      }
      $not_arrived = 0 if ($files_available == $files_expected);
    }

    if ($not_arrived) {
      if ($time_waited > $maxwaitsec) {
        my $sectomin = $maxwaitsec/60.0;
        my $message = "arl files not available within $sectomin minutes. ".
                      "quitting";
        LogMessage($args,"Checking ARL","Die","Failure",$message);
        FailureEmail($args,$message); 
        die("$0: arl files not available within $maxwaitsec secs. quitting\n");
      }

      my $message = "$files_available files found out of $files_expected ".
                    " expected. Waiting ";
      LogMessage($args,"Checking ARL","Waiting","Warning",$message) if
                ($time_waited%($waitinterval*6) == 0);
      print("$0: $files_available found out of $files_expected expected\n".
            "\twaiting $waitinterval secs before retrying.\n");
      sleep($waitinterval);
      $time_waited += $waitinterval;
    }
  }
  my $message = "All $$args{metsource} ARL files found";
  LogMessage($args,"Checking ARL","Finish","Good",$message);
  return(1);
}

sub CheckWaitPDIN
{
  my $waitinterval = shift;
  my $maxwaitsec   = shift;
  my $datadir      = shift;
  my $filesref     = shift;
  my $args         = shift;

  my $not_arrived    = 1;
  my $time_waited    = 0;

  while ($not_arrived) {

    my $files_available = 0;

    if (-d $datadir) {
      chdir $datadir;

      foreach my $file1 ( @$filesref ) {
        my $file2 = $file1.".001";
        $files_available++ if ( -e $file1 );
        $files_available++ if ( -e $file2 );
      }
      $not_arrived = 0 if ($files_available > 0);
    }
    if ($not_arrived) {
      if ($time_waited > $maxwaitsec) {
        die("$0: pdin file(s) not found. quitting.\n");
        FailureEmail($args,$message); 
      }
      print("$0: $files_available found out of $files_expected expected\n".
            "\twaiting $waitinterval secs before retrying.\n");
      sleep($waitinterval);
      $time_waited += $waitinterval;
    }
  }
  return(1);
}

sub WaitARL
{
  my $args = shift;

  my $metsource = $$args{metsource};

  my $waitsub = "Wait".$metsource;
  my $status = &$waitsub($args);

  die("$0: couldn't find ARL files. failing.\n") unless ($status);
  return(1);
}
