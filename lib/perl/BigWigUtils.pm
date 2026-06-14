package BigWigUtils;

use strict;
use Exporter;
use File::Copy;
use File::Basename;
our @ISA = 'Exporter';
our @EXPORT = qw(installBwFile, validateBwFile);

sub installBwFile {
  my ($bwFile, $dataFilesDir) = @_;


  print STDERR "Copying file '$bwFile' to '$dataFilesDir'\n";
  copy($bwFile, $dataFilesDir) or die "Copy of '$bwFile' to '$dataFilesDir' failed: $!";
  my $f = basename($bwFile);
  chmod(0664, "$dataFilesDir/$f") or die "Could not chmod $dataFilesDir/$f\n";
}

# return invalid message or 0
sub validateBwFile {
  my ($dir, $fileName) = @_;
  return "Invalid bigwig file: $fileName" if system("isbigwig $dir/$fileName");
  return "Bigwig file too big (> 500M): $fileName" if -s "$dir/$fileName" > (5 * 1024 * 1024);
  return 0;
}

1;
