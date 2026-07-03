package BigWigUtils;

use strict;
use Exporter;
use File::Copy;
use File::Basename;
use DBI;
our @ISA = 'Exporter';
our @EXPORT = qw(installBwFile validateBwFile validateBwSequences);

sub installBwFile {
  my ($origBwFile, $dataFilesDir) = @_;

  # .bw extension needed for jbrowse
  my $bwFile = basename($origBwFile);
  $bwFile =~ s/\.bigwig$/.bw/;
  $bwFile = ($bwFile =~ /\.bw$/) ? $bwFile : "$bwFile.bw";
  print STDERR "Copying file '$origBwFile' to '$dataFilesDir/$bwFile'\n";
  copy($origBwFile, "$dataFilesDir/$bwFile") or die "Copy of '$origBwFile' to '$dataFilesDir/$bwFile' failed: $!";
  chmod(0664, "$dataFilesDir/$bwFile") or die "Could not chmod $dataFilesDir/$bwFile\n";
}

# return invalid message or 0
sub validateBwFile {
  my ($filePath) = @_;
  my $fileName = basename($filePath);
  return "Invalid bigwig file: $fileName" if system("isbigwig $filePath");
  my $sz =  -s $filePath;
  return "Bigwig file too big (> 500M): $fileName ($sz)" if ($sz > (500 * 1024 * 1024));
  return undef;
}

# return invalid message or 0
sub validateBwSequences {
  my ($filePath, $orgNameForFiles, $dbh) = @_;

  my $sql = "
select s.source_id
from apidbtuning.genomicseqattributes s, apidbtuning.organismattributes o
where o.name_for_filenames = ?
and o.internal_abbrev = s.org_abbrev
";

  my %knownIds;
  my $stmt = $dbh->prepare($sql);
  $stmt->execute($orgNameForFiles);
  while (my ($sourceid) = $stmt->fetchrow_array()) {
    $knownIds{$sourceid} = 1;
  }
  $stmt->finish();

  die "Database contains no sequence IDs for $orgNameForFiles\n" unless keys %knownIds;

  my $count = 0;
  my @unfoundIds;
  open(CMD, "bigwigSequenceIds $filePath |") or die "couldn't open bigwigSequenceIds: $!";
  while(<CMD>) {
    chomp;
    push(@unfoundIds, $_) unless $knownIds{$_};
    $count += 1;
  }

  my $fileName = basename($filePath);

  return "bigWig file $fileName contains no sequence IDs" unless $count;

  my @examples = @unfoundIds > 10 ? @unfoundIds[0..4] : @unfoundIds;
  my $uCount = @unfoundIds;
  return "bigWig file $fileName contains $uCount of $count IDs that do not match our version of $orgNameForFiles. For example: " . join(",", @examples) .". Seems like the wrong genome." if $uCount > ($count * .2);
  return undef;
}


1;
