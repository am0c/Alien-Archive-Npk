package My::Build;
use warnings;
use strict;

use lib 'inc';
use My::Util qw(fetch_from_source);

use base 'Module::Build';

use Digest::SHA qw(sha1_hex);
use File::Basename;
use Alien::CMake;
use HTTP::Tiny;
use Archive::Tar;
use File::Spec::Functions;
use File::Path qw(make_path remove_tree);
use File::Copy;
use Try::Tiny;

sub ACTION_code {
    my $self = shift;
    $self->dispatch('npk_build') unless $self->check_build_done_marker;
    $self->SUPER::ACTION_code;
}

sub ACTION_build {
    my $self = shift;
    $self->SUPER::ACTION_build;
}

sub ACTION_npk_fetch {
    my $self = shift;
    my $fn = "npk.tgz";

    my $parm = $self->notes('build_params');
    if (!defined $parm) {
        print "Oops, Not specified the source to download. Skip.\n\n";
        return;
    }
    elsif (-e $fn) {
        return;
    }
    print "Fetching from source, ", $parm->{url}, "\n";

    $self->add_to_cleanup($fn);
    $fn = fetch_from_source($parm->{url});
    my $i;
    while (not $fn) {
        print "Something wrong occured while fetching the source. ";
        if (++$i <= 4) {
            print "Retry.\n";
            $fn = fetch_from_source($parm->{url});
        }
        else {
            print "Give up.\n\n";
            return;
        }
    }

    $self->add_to_cleanup($parm->{dir});
    $self->add_to_cleanup($fn);

    my $sha1 = Digest::SHA->new;
    open my $fh, "<", $fn or die;
    binmode $fh;
    $sha1->addfile($fh);
    die unless $sha1->hexdigest eq $parm->{sha1num};

    $self->config_data('share_subdir', "npk_" . substr(sha1_hex($parm->{title}), 0, 6));
    $self->notes("share_$_", catdir('_share', $self->config_data('share_subdir'), $_))
        for qw(lib include);

    $self->config_data('lib_dir', 'lib');
    $self->config_data('include_dir', 'include');

    print "Extracting the source\n";

    my $tar = Archive::Tar->new($fn, $parm->{compress});
    $tar->extract;
}

sub ACTION_npk_build {
    my $self = shift;

    $self->depends_on('npk_fetch');
    $self->depends_on('npk_cmake');
    $self->depends_on('npk_install');

    $self->touch_build_done_marker;
}

sub ACTION_npk_install {
    my $self = shift;

    $self->depends_on('npk_build');

    $self->add_to_cleanup('_share');
    $self->do_mkdir($self->notes('share_lib'));
    $self->do_mkdir($self->notes('share_include'));

    print "Installing to share directory\n";

    my @libs = glob catfile($self->notes('build_dir'), "libnpk", "libnpk.*");
    $self->do_copy($_, $self->notes('share_lib')) for @libs;
    $self->config_data('libs', [ map { basename($_) } @libs ]);

    my @includes = glob catfile($self->notes('build_params')->{dir}, "libnpk", "include", "*.h");
    $self->do_copy($_, $self->notes('share_include')) for @includes;
    $self->config_data('includes', [ map { basename($_) } @includes ]);
}

sub ACTION_npk_cmake {
    my $self = shift;

    $self->depends_on('npk_build');

    print "Making npk with cmake\n";

    my $build_dir = catdir($self->notes('build_params')->{dir}, 'build');
    my $install_dir = catdir('_share', $self->config_data('share_subdir'));

    $self->notes('install_dir', $install_dir);
    $self->notes('build_dir', $build_dir);

    try {
        $self->do_mkdir($build_dir);
        $self->do_chdir($build_dir);

        my $cm = catfile(Alien::CMake->config("prefix"), "bin", "cmake");
        $self->do_system( $cm, "-DDEV_MODE:BOOL=ON", "-DBUILD_SHARED_LIBS:BOOL=ON",
                          sprintf('-DCMAKE_INSTALL_PREFIX="%s"', $install_dir), ".." ); #XXX

        $self->do_system( $cm, "--build", "." );
        #$self->do_system( $cm, "--build", ".", "--", "test" );
    }
    catch {
        warn "$_ $@ $!" if $_;
    }
    finally {
        $self->do_chdir($self->base_dir);
    };
}

sub check_build_done_marker {
    my $self = shift;
    return -e 'build_done';
}

sub touch_build_done_marker {
    my $self = shift;
    require ExtUtils::Command;
    local @ARGV = ('build_done');
    ExtUtils::Command::touch();
    $self->add_to_cleanup('build_done');
}

sub clean_build_done_marker {
    my $self = shift;
    unlink 'build_done' if -e 'build_done';
}

sub do_copy {
    my $self = shift;
    my ($from, $to) = @_;

    print "Copy $from to $to\n";
    copy $from, $to;
}

sub do_chdir {
    my $self = shift;
    my $dir = shift;

    print "Cd $dir\n";
    chdir $dir;
}

sub do_mkdir {
    my $self = shift;
    my $dir = shift;

    print "Create directory $dir\n";
    make_path $dir;
}

1;
