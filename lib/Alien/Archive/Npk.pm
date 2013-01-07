package Alien::Archive::Npk;

use Alien::Archive::Npk::ConfigData;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions;

our $VERSION = '0.000001_001';

our $SUBDIR = Alien::Archive::Npk::ConfigData->config('share_subdir');
our $DIST = dist_dir('Alien-Archive-Npk');

my $kv = do {
    my @prefix = ($DIST, $SUBDIR);

    my $lib_dir = Alien::Archive::Npk::ConfigData->config('lib_dir');
    my $include_dir = Alien::Archive::Npk::ConfigData->config('include_dir');
    my $libs = Alien::Archive::Npk::ConfigData->config('libs');
    my $includes = Alien::Archive::Npk::ConfigData->config('includes');

    return {
        prefix      => catdir(@prefix),
        lib_dir     => catdir(@prefix, $lib_dir),
        include_dir => catdir(@prefix, $include_dir),
        libs        => $libs,
        includes    => $includes,
        libs_path     => [ map { catfile(@prefix, $lib_dir, $_) } @$libs ],
        includes_path => [ map { catfile(@prefix, $include_dir, $_) } @$includes ],
    };
};

sub config {
    my ($self, $key) = @_;

    if (exists $kv->{$key}) {
        return $kv->{$key};
    }
    elsif (my $v = Alien::Archive::Npk::ConfigData->config($key)) {
        return $v;
    }
    else {
        return;
    }
}

1;
__END__

=head1 NAME

Alien::Archive::Npk - Alien for neat package system - npk

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut

