package My::Util;
use warnings;
use strict;

use Archive::Tar;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(get_valid_sources fetch_from_source);

my $remote_sources = [
  {
    title => "Download and Build from source: npk r168 (libnpk v27 / npk tool 1.81)",
    url => 'http://npk.googlecode.com/files/npk_r168.tar.gz',
    dir => 'npk',
    version => 'r168',
    sha1num => 'f3a5d9063f41cb9c94a3fe8789b26a7253af92a2',
    compress => COMPRESS_GZIP,
  },
  {
    title => "Download and Build from source: npk r113 (libnpk v24 / npk tool 1.74)",
    url => 'http://npk.googlecode.com/files/npk_r113.tar.gz',
    dir => 'npk',
    version => 'r113',
    sha1num => 'fbc11807c1ef3182e438eda952d77051fcc4bab6',
    compress => COMPRESS_GZIP,
  },
];

sub get_valid_sources {
    $remote_sources;
}

sub fetch_from_source {
    my $url = shift;

    require URI;
    require HTTP::Tiny;

    my $ua = HTTP::Tiny->new;
    my $res = $ua->get($url);
    my $fn = "npk.tgz";
    die unless $res->{success};

    open my $fh, ">", $fn or die $!;
    binmode $fh;
    print { $fh } $res->{content};

    return $fn;
}

1;
