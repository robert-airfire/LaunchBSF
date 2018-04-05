# package name (same as filename sans .pm)
package LaunchLog;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

require Exporter;
@ISA = qw( Exporter );

# list of subroutines that we'll want to allow access to
my @stuff = qw( LogMessage FailureEmail );

@EXPORT = ( @stuff );
%EXPORT_TAGS = ( 'vars' => [@stuff], );

use lib ".";
use lib "/home/bluesky/bluesky_3.5.1/bluesky";
use lib "/usr/local/share/perl";
use TimeUtilities;


# script usage
# ex: log-status.py -e http://status-log.airfire.org/status-logs -k KEY -s SECRET -p YOUR_PROCESS_NAME -o [Good|Fail|ect] -f field_a=blah -f field_b=foo

# from bluesky ini file
#    API_ENDPOINT = http://status-log.airfire.org/status-logs
#    API_KEY = 700824e31cfe11e4a89f3c15c2c6639e
#    API_SECRET = 73fa27801cfe11e481873c15c2c6639e

my $API_ENDPOINT = 'https://status-log.airfire.org/status-logs';
my $API_KEY      = "700824e31cfe11e4a89f3c15c2c6639e";
my $API_SECRET   = "73fa27801cfe11e481873c15c2c6639e";

# email failure stuff
my $BSS_SCHEDULER_CMD        = "/usr/local/lib/.pyenv/versions/".
                               "bluesky-scheduler-2.7.3/bin/bss-scheduler";
my $STATUS_LOGS_API_ENDPOINT = 'https://status-log.airfire.org/status-logs';
my $REDIS_URL                = "localhost:6379";
#my $HIPCHAT_INTEGRATION_ID   = "bluesky_failures";
#my $HIPCHAT_INTEGRATION_ID   = "bluesky_status_failures_test";
my $SLACK_INTEGRATION_ID     = "status";
my $EMAIL_SENDER             = 'bluesky-status@airfire.org';
my $EMAIL_RECIPIENTS         = '2063591427@tmomail.net';
my $BIN_DIR                  = "/usr/local/lib/.pyenv/versions/".
                               "bluesky-scheduler-2.7.3/bin";
my $RECIPIENTS_FILE          = "/home/bluesky/bsf_email_recipients.txt";

sub LogMessage
{
  my $args    = shift;
  my $step    = shift;
  my $action  = shift;
  my $status  = shift;
  my $message = shift;

  my $flags     = $$args{flags};
  my $metsource = $$args{metsource};
  my $ymdh      = $$args{ymdh};

# do we really want to send a message to the logger?
  return unless ($flags =~ /l/);

  my $procname  = (split(/\//,$0))[-1];

  my $log_args = "-e \"$API_ENDPOINT\" -k $API_KEY -s $API_SECRET ".
                 "-p $procname -o $status ".
                 "-f \"Met Source\"=\"$metsource\" ".
                 "-f \"Initialization Time\"=$ymdh ".
                 "-f step=\"$step\" ".
                 "-f action=\"$action\" ";

  $log_args = $log_args."-f Comments=\"$message\"" if ($message ne "");

  my $cmd = "/usr/local/bin/log-status.py $log_args";
  system($cmd);
}

# Send a special failure email when the something happens that the launch
# script can't recover from.
sub FailureEmail
{

# run info and message to send
  my $args    = shift;
  my $message = shift;

# extract the run name, the metsource and run date
  my $flags     = $$args{flags};
  my $name      = $$args{name};
  my $metsource = $$args{metsource};
  my $ymdh      = $$args{ymdh};

# do we really want to send a failure email for this run?
  return unless ($flags =~ /f/);

# my programs name
  my $procname  = (split(/\//,$0))[-1];

# my machine that runs me
  my $machine   = `hostname`;
  chomp($machine);

# list of recipients
  my $emaillist = GetEmailRecipients();
  return unless (length($emaillist));

# email content
  my $content   = "$ymdh $name BSF runtime failure on $machine. $message ".
                  "this is an automated message sent to $emaillist.";

# cmd to schedule the email...
  my $cmd = "$BSS_SCHEDULER_CMD emails.ScheduledStatusEmails create ".
            "-c REDIS_URL=$REDIS_URL ".
            "-c STATUS_LOGS_API_ENDPOINT=$STATUS_LOGS_API_ENDPOINT ".
            "-c EMAIL_SENDER=$EMAIL_SENDER ".
            "-p email_recipients=$emaillist ".
            "-p slack_channel=$SLACK_INTEGRATION_ID ".
            "-p email_type=failure ".
            "-p email_subject=\"$name Failure\" ".
            "-p email_content=\"$content\"";

# send it...done
  system($cmd);
}

# retrieve the list of people who are to get the failure email
sub GetEmailRecipients
{
# no file, noone to email to....
  unless (-e $RECIPIENTS_FILE) {
    warn("$0: no recipients to send failure notifications to\n");
    return("");
  }

# loop over lines in recipients file
  my @emailarray;
  open(RECIPIENTS,"<",$RECIPIENTS_FILE);
  while (<RECIPIENTS>) {

# chomp, remove any leading whitespace and skip if empty line or comment
    chomp;
    $_ =~ s/^\s*//;
    next if ((length == 0)||($_ =~ /$\#/));

# otherwise get the first bit and treat as an email address
    my $address = (split)[0];
    push @emailarray,($address);
  }

# close
  close(RECIPIENTS);

# turn array into comma sep list
  my $emaillist = join(',',@emailarray);
  return($emaillist);
}
