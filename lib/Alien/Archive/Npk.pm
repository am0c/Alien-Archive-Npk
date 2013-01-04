package Alien::Archive::Npk;

use Alien::Archive::Npk::ConfigData;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions;

our $VERSION = '0.000001_001';

my $SUBDIR = Alien::Archive::Npk::ConfigData->config('share_subdir');
my $DIST = dist_dir('Alien-Archive-Npk');

sub config {
    my ($self, $key) = @_;

    my $value = Alien::Archive::Npk::ConfigData->config($key);
    return unless defined $value;

    if (ref $value eq 'ARRAY') {
        return [ map { catfile($DIST, $SUBDIR, $_) } @$value ];
    }
    else {
        return catfile($DIST, $SUBDIR, $value);
    }
}

1;
__END__

=head1 NAME

Alien::Archive::Npk - Alien for neat package system - npk

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut

