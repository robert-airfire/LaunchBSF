# package name (same as filename sans .pm)
package LaunchArchiveRsync;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

require Exporter;
@ISA = qw( Exporter );

# list of subroutines that we'll want to allow access to
my @stuff = qw( LaunchArchiveRsync LaunchBSF ArchiveBSF RsyncBSF
                RsyncBSF2 ArchiveBSF2 );

@EXPORT = ( @stuff );
%EXPORT_TAGS = ( 'vars' => [@stuff], );

use lib ".";
use lib "/usr/local/share/perl";
use lib "/home/bluesky/bluesky_3.5.1/bluesky";

use LaunchLog;

sub LaunchArchiveRsync
{

  my $args = shift;

  LaunchBSF($args);
  ArchiveBSF($args);
  RsyncBSF($args);
  
}

sub LaunchBSF
{
  my $args = shift;

# clean up prior runs outputs if they exists....
  my $full_output = "$$args{outdir}/$$args{archive}";
  system("rm -R $full_output") if ( -e $full_output );

# move to bsdir
  chdir $$args{bsdir};

# file to send log info
  my $log = "log/$$args{ini}-$$args{ymdh}.log";

# lets start the log with what time we started
  my $local_time = `date`;
  my $echo_string = "starting bluesky at $local_time\n";
  system("echo $echo_string > $log");

# launch bluesky
  my $bluesky_cmd = "./bluesky -d $$args{ymdh} ".
                                 "$$args{bs_options} ".
                                 "$$args{ini} ".
                                 ">> $log";
  print "bluesky: $bluesky_cmd\n";
  my $status = system($bluesky_cmd);
  my $message = "error: bluesky exited with non-zero status: $status.";
  print "$message\n"              if ($status);
  system("echo $message >> $log") if ($status);

# send a failure message if we exited with a non-zero status
  FailureEmail($args,$message) if ($status);

# what time did we finish
  $local_time = `date`;
  $echo_string = "finished bluesky at $local_time\n";
  system("echo $echo_string >> $log");

# fatal error if bluesky exits with a non-zero status
  die("$message\n")            if ($status);
}

sub ArchiveBSF
{
  my $args = shift;

# archive output
  chdir $$args{outdir};

# make a link to the directory name for archive transfer unless
# same as archive
  symlink $$args{archive},$$args{archivelink} 
     unless ( $$args{archive} eq $$args{archivelink} );
  my $tar_file = "$$args{archivelink}-$$args{suffix}.tgz";
  my $tar_cmd = "tar hczvf $tar_file $$args{archivelink}";
  print "tar: $tar_cmd\n";
  system($tar_cmd);
}

sub ArchiveBSF2
{
  my $args = shift;

  my $step = "Archive BSF Output";
  my $action = "Start";
  my $status = "Good";
  my $message = "";
  LogMessage($args,$step,$action,$status,$message);

# archive output
  chdir $$args{outdir};

  unless (-e $$args{archive} ) {
    $action = "Die";
    $status = "Failure";
    $message = "$$args{archive} does not exists";
    LogMessage($args,$step,$action,$status,$message);
    return;
  }

# like above just a new symlink (if it is define)
  unlink $$args{archivelink2} if ( -e $$args{archivelink2} );
  symlink $$args{archive},$$args{archivelink2};
  my $tar_file = "$$args{archivelink2}.tgz";
  my $tar_cmd = "tar hczvf $tar_file $$args{archivelink2}";
  print "tar: $tar_cmd\n";
  system($tar_cmd);

  my $stat_rs8 = $? >> 8;
  if ($stat_rs8 == 0) {
    $action = "Finish";
    $status = "Good";
    $message = "$$args{archivelink2} archive created"; 
  }
  else {
    $action = "Finish";
    $status = "Failure";
    $message = "archive of $$args{$archivelink2} exited with $stat_rs8";
  }
  LogMessage($args,$step,$action,$status,$message);
}

sub RsyncBSF
{
  my $args = shift;

# rsync to vacuum
  my $step = "Rsync BSF Output to vacuum";
  my $action = "Start";
  my $status = "Good";
  my $message = "";
  LogMessage($args,$step,$action,$status,$message);

  chdir $$args{outdir};
  my $tar_file = "$$args{archivelink}-$$args{suffix}.tgz";
  my $rsync_cmd = "rsync $tar_file ".
                  'bluesky@vacuum.atmos.washington.edu:'.
                  "$$args{dest}/$tar_file";
  print "rsync: $rsync_cmd\n";
  system($rsync_cmd);
  my $stat_rs8 = $? >> 8;
  if ( $stat_rs8 == 0 ) {
    $message = "rsync completed succesfully";
    $action  = "Finish";
    $status  = "Good";
  }
  else {
    $action = "Finish";
    $status = "Failure";
    if ($? == -1) {
      $message = "rsync failed to execute: $!";
    }
    elsif ($? & 127) {
      $message = sprintf("rsync died with signal %d",($? & 127));
    }
    else {
      $message = "rsync exited with value $stat_rs8";
    }
    LogMessage($args,$step,$action,$status,$message);
  }
}

sub RsyncBSF2
{ 
  my $args = shift;

# rsync to vacuum
  foreach my $remote_destination ( 'bluesky@haze.airfire.org',
                                   'bluesky@vacuum.atmos.washington.edu' ) {

# setup up some basic info for log info
    my $step = "Rsync BSF Output to $remote_destination";
    my $action = "Start";
    my $status = "Good";
    my $message = "";
    LogMessage($args,$step,$action,$status,$message);

# where is the file we want to move and what is it?
    chdir $$args{outdir};
    my $tar_file = "$$args{archivelink2}.tgz";
    my $dest = "/storage/bluesky/output_archive/Incoming";

# setup the rsync command
    my $rsync_cmd = "rsync $tar_file $remote_destination:$dest/$tar_file";
#                  'bluesky@vacuum.atmos.washington.edu:'.
#                  "$dest/$tar_file";
    print "rsync: $rsync_cmd\n";
    system($rsync_cmd);

    my $stat_rs8 = $? >> 8;
    if ( $stat_rs8 == 0 ) {
      $message = "";
      $action  = "Finish";
      $status  = "Good";
    }
    else {
      $action = "Finish";
      $status = "Failure";
      if ($? == -1) {
        $message = "rsync failed to execute: $!";
      }
      elsif ($? & 127) {
        $message = sprintf("rsync died with signal %d",($? & 127));
      }
      else {
        $message = "rsync exited with value $stat_rs8";
      }
    }
    LogMessage($args,$step,$action,$status,$message);
  }
}

sub PreProcBSF
{
}

sub PostProcBSF
{
}


