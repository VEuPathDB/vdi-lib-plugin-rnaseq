package BigWigUtils;

use strict;
use Exporter;
use File::Copy;
our @ISA = 'Exporter';
our @EXPORT = qw(installBwFile deleteUserDatasetDir);

sub installBwFile {
  my ($userDatasetId, $bwFile, $userDatasetsDir) = @_;

  my $userDatasetDir = "$userDatasetsDir/$userDatasetId";

  # initialize dir first time through
  unless ( -e $userDatasetDir) {
    print STDERR "Creating directory $userDatasetDir\n";
    mkdir($userDatasetDir) || die "Can't create user dataset directory '$userDatasetDir' $!";
  }

  print STDERR "Copying file '$bwFile' to '$userDatasetDir'\n";
  copy($bwFile, $userDatasetDir) or die "Copy of '$bwFile' to '$userDatasetDir' failed: $!";
}

sub deleteUserDatasetDir {
  my ($udDirPath) = @_;

  if (-e $udDirPath) {
    opendir(my $udDir, $udDirPath) or die "Cannot open directory '$udDirPath': $!\n";
    foreach my $file (readdir $udDir) {
      next if $file =~ /^\.+$/;
      die "Unexpected directory '$file' in user dataset directory '$udDirPath'\n" if -d "$udDirPath/$file";
      print STDERR "Deleting file $udDirPath/$file\n";
      unlink("$udDirPath/$file") || die "Could not delete file '$udDirPath/$file\n";
    }
    print STDERR "Removing dir $udDirPath\n";
    rmdir($udDirPath) || die "Could not delete directory '$udDirPath'\n";
  }

}

1;
