package RnaSeqHandlerCommon;

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

1;
