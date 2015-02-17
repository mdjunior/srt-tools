#!/usr/bin/env perl

use strict;
use warnings;

use Carp;
use English qw( -no_match_vars );
use Getopt::Long;

use Mojolicious;
use Mojo::JSON qw(j);

our $VERSION = 0.1;

my $infile = qw{ };

#  setting STDOUT to UTF-8
binmode STDOUT, ':encoding(UTF-8)';

GetOptions('file=s' => \$infile,);

if (!defined $infile || !-r $infile) {
    croak 'Error in command line arguments, check README for usage.';
}

#  slurp file content
my $content;
{
    local $INPUT_RECORD_SEPARATOR = undef;
    open my $fh, '<:encoding(UTF-8)', $infile
        or die "Can't open $infile: $ERRNO\n";
    $content = <$fh>;
    close $fh or die "Can't close $infile: $ERRNO\n";
}

# parsing content (in a perl structure)
my $array = j($content);

# generate SRT
my $srt;
my $index = 1;
foreach my $subtitle (@{$array}) {
    $srt
        .= "$index\n$subtitle->{start_time} --> $subtitle->{end_time}\n$subtitle->{subtitle}\n\n";
    $index++;
}

# writing results in file.srt
open my $fh, '>:encoding(UTF-8)', $infile . '.srt'
    or die "Can't open $infile.srt: $ERRNO\n";
print {$fh} $srt or die "Can't write $infile.srt: $ERRNO\n";
close $fh or die "Can't close $infile.srt: $ERRNO\n";
