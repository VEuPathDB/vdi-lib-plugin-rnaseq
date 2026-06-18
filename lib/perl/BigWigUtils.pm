package BigWigUtils;

use strict;
use Exporter;
use File::Copy;
use File::Basename;
our @ISA = 'Exporter';
our @EXPORT = qw(installBwFile validateBwFile);

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
  return 0;
}


1;
