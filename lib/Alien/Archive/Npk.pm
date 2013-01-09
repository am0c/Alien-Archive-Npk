package Alien::Archive::Npk;

use Alien::Archive::Npk::ConfigData;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions;

our $VERSION = '0.000001_002';

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

Alien::Archive::Npk - Alien for Neat Package System - npk

=head1 SYNOPSIS

  use Alien::Archive::Npk;

  my @config_key = qw(
    prefix
    lib_dir include_dir
    libs includes
    libs_paths includes_paths
  );

  for (@config_key) {
    print Alien::Archive::Npk->config(
        ref($_) eq 'ARRAY' ? "@$_" : $_;
      ), "\n";
  }

=head1 DESCRIPTION

B<npk> is simple file packager and its file format, pronounced as I<en-pack>.

If you're finding a platform independent, easy-to-use and also secure
packageing system, npk is for you. It works on most of modern operating
systems, and also supports powerful tools for manipulating packages.

CPAN modules based on C<Alien::> namespace are to intall specified external
libraries that are not pure perl and provide the caller with enough
information to use it. See L<Alien>.

When you install L<Alien::Archive::Npk>, it will ensure that your system is
ready to use npk library, regardless of the platform it is installed on.
It will fetch B<libnpk> from the archive by network to build, so
network is required to install this module.

If you're writing some module which requires npk library to operate,
You can add Alien::Archive::Npk as a dependency to it rather
than code configuration stuffs manually.

The module has C<config()> method which provides configuration values or
noticable paths of npk library installed by Alien::Archive::Npk.

=head1 METHODS

=over 4

=item config("prefix")

The root directory path configured to be of the installed npk.
The module will build npk again even though there is already one on the system.
So this install prefix might be sub-directory of the one of C<@INC>.

=item config("lib_dir")

The path where the loadable shared library of npk will be placed.

=item config("include_dir")

The path where the header files of npk will be placed.

=item config("libs")

The list of shared library file basenames returned as an array reference.

=item config("libs_path")

The list of shared library file paths returned as an array reference.

=item config("includes")

The list of header file basenames returned as an array reference.

=item config("includes_path")

The list of header files paths returned as an array reference.

=back

=head1 BUGS

Please report bugs to L<github issues|http://github.com/am0c/Alien-Archive-Npk/issues>.

=head1 AUTHOR

Hojung Youn C<< <amorette@cpan.org> >>

=head1 LICENSE

Same as perl itself.

=cut

