# package name (same as filename sans .pm)
package LaunchSmoke;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

require Exporter;
@ISA = qw( Exporter );

# list of subroutines that we'll want to allow access to
my @stuff = qw( RenamePDOUT CreateSETUPCFG );
               
@EXPORT = ( @stuff );
%EXPORT_TAGS = ( 'vars' => [@stuff], );

use lib "/usr/local/share/perl";
use TimeUtilities;
use DateTime;

sub CreateSETUPCFG
{
# args list
  my $args = shift;

# get some vars that we may need
  my $setupdir  = $$args{setupdir};
  my $ymdh      = $$args{ymdh};
  my $metsource = $$args{metsource};

# set the names of the input template and output cfg files
  my $template  = "SETUP_$metsource\_pinpf.TEMPLATE";
  my $setupcfg  = "SETUP_$metsource\_pinpf.CFG";

# chdir and remove setupcfg if it exists already...can only run one carryover
# run at a time per metsource
  chdir $setupdir;
  unlink $setupcfg if (-e $setupcfg);

# open input template and output cfg fils
  open(TEMPLATE,"<",$template) or 
       die("$0: can open $template file for carryover smoke\n");
  open(SETUPCFG,">",$setupcfg);

# loop over lines in template change required fields and write to cfg files
  my $line;
  while ($line = <TEMPLATE>) {
     $line =~ s/YYYYMMDDHH/$ymdh/;
     print SETUPCFG $line;
  }

# close
  close(TEMPLATE);
  close(SETUPCFG);

  return;
}

# rename the pardump output file to include the ymdh of its start time
sub RenamePDOUT
{

# args list
  my $args = shift;

# pardump location and original output name
  my $pardump_dir = $$args{bsdir}."/pardump/".$$args{metsource};
  my $pardump_old = $$args{metsource}."_PDOUT";

# ymdh of the simulation
  my $ymdh        = $$args{ymdh};
  my $dt          = get_dt_from_datestr($ymdh);

# 24 hours in the future
  my $dt_p_24     = $dt->clone->add( days => 1 );
  my $ymdh_p_24   = dt_to_ymdh($dt_p_24);

# need to figure out if it is a single or multipcroc run....
# if the pardump_old file exists assume it is single, if not
# assume it is multi and treat appropriately.
  chdir $pardump_dir;
  my $singleproc = ( -e $pardump_old ) ? 1 : 0 ;


# if single rename the file...return 1
  if ( $singleproc ) { 

# new pardump output name for single proc run
    my $pardump_new = $$args{metsource}."_".$ymdh_p_24."_PDIN";
    printf stderr "$0: rename pdout file for $ymdh to ".
                  "pdin file for $ymdh_p_24\n";
    rename $pardump_old,$pardump_new;
    return(1);
  }

# it wasn't single so assume multi-proc...need to figure out how many procs
  my $template = $pardump_old.'.(\d{3})';
  opendir(INDIR,$pardump_dir);
  my @pdumpfiles = sort grep { ( $_ =~ /$template/ )} readdir(INDIR); 
  closedir(INDIR);
  if (scalar(@pdumpfiles) == 0) {
    warn("$0: no pdump files found for $ymdh.\n");
    return(0);
  }

# get the number of procs based on the name of the last file (we sorted)
  my $lastfile = pop(@pdumpfiles);
  $lastfile =~ /$template/;
  my $ncpus = $1;

# loop of ncpus ....
  printf stderr "$0: rename pdout files for $ymdh to ".
                "pdin files for $ymdh_p_24\n";
  foreach my $cpu ( 1 .. $ncpus ) {
    my $old = sprintf("%s.%03d",$pardump_old,$cpu);
    my $new = sprintf("%s\_%s\_PDIN.%03d",$$args{name},$ymdh_p_24,$cpu);
    rename $old,$new; 
  }
  return(1);
}

