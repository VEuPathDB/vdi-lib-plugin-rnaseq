package BigWigUtils;

use strict;
use Exporter;
our @ISA = 'Exporter';
our @EXPORT = qw(installBwFile deleteUserDatasetDir);

sub installBwFile {
  my ($userDatasetId, $bwFile) = @_;

  # initialize dir first time through
  mkdir("$ENV{USER_DATASETS_DIR}/$userDatasetId") || die "Can't create user dataset directory '$ENV{USER_DATASETS_DIR}/$userDatasetId' $!" unless -d "$ENV{USER_DATASETS_DIR}/$userDatasetId";

  copy($bwFile, "$ENV{USER_DATASETS_DIR}/$userDatasetId") or die "Copy of '$bwFile' to '$ENV{USER_DATASETS_DIR}/$userDatasetId' failed: $!";
}

sub deleteUserDatasetDir {
  my ($udDirPath) = @_;

  if (-e $udDirPath) {
    opendir(my $udDir, $udDirPath) or die "Cannot open directory '$udDirPath': $!\n";
    foreach my $file (readdir $udDir) {
      die "unexpected directory '$file' in user dataset directory '$udDir'\n" if -d $file;
      unlink("$udDir/$file") || die "could not delete file '$udDir/$file\n";
    }
    rmdir($udDir) || die "could not delete directory '$udDir'\n";
  }

}

1;
