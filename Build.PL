#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec::Functions;

use lib 'inc';

use My::Util qw(get_valid_sources);
use My::Build;

my $build = My::Build->new(
    module_name => 'Alien::Archive::Npk',
    dist_author => 'Hojung Youn <amorette@cpan.org>',
    license => 'perl',
    requires => {
        'perl' => '5.8.1',
        'File::ShareDir' => 0,
        'File::Spec' => 0,
    },
    build_requires => {
        'URI' => 0,
        'HTTP::Tiny' => 0,
        'Alien::CMake' => 0,
        'Digest::SHA' => 0,
        'File::Basename' => 0,
        'Archive::Tar' => 0,
        'File::Spec' => 0,
        'File::Path' => 0,
        'File::Copy' => 0,
        'Try::Tiny' => 0,
    },
    configure_requires => {
        'Module::Build' => '0.038',
        'File::Spec' => 0,
        'Archive::Tar' => 0,
    },
    share_dir => '_share',
    needs_compiler => 1,
    meta_merge => {
        npk_project_URL => "http://code.google.com/p/npk/",
        npk_project_repository => "http://npk.googlecode.com/svn/trunk/",
        npk_project_license => "MIT License",
    },
);

$build->create_build_script;

$build->clean_build_done_marker;

print "\nNpk installation\n";
print "================\n\n";

print << 'NOTICE';
  Select from the list of installation methods below.
  The installation will not check or use npk library installed in
  the system in this time. Because official npk library does not
  support the way to install them properly, and it's small enough to
  configure and build another one.

NOTICE

my @candidates;

if (my $srcs = get_valid_sources()) {
    push @candidates, @$srcs;
}

my $i;
for my $method (@candidates) {
    print ++$i, ". ", $method->{title}, "\n";
}

print "\n";
my $select; do {
    $select = $build->prompt("Select?", 1);
} until $select >= 1 && $select <= @candidates;

$build->notes('build_params', $candidates[$select-1]);
