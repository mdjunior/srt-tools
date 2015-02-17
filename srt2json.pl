#!/usr/bin/env perl

use strict;
use warnings;

use Carp;
use English qw( -no_match_vars );
use Getopt::Long;
use utf8;
use feature 'unicode_strings';

use Mojolicious;
use Mojo::JSON qw(j);
use Mojo::UserAgent;
use Readonly;

our $VERSION = 0.1;

#  constants
Readonly my $GOOGLE_APIS_ENDPOINT =>
    'https://www.googleapis.com/language/translate/v2';


my $infile = qw{ };
my $source;
my $target;
my $translate;
my $count;
my $verbose;

#  setting STDOUT to UTF-8
binmode STDOUT, ':encoding(UTF-8)';

GetOptions(
    'file=s'    => \$infile,
    'in=s'      => \$source,
    'of=s'      => \$target,
    'translate' => \$translate,
    'count'     => \$count,
    'verbose+'  => \$verbose,
);

#  check file permissions
if ($verbose) {
    print "-> Checking file permissions ($infile)\n"
        or die "Can't write verbose file permissions: $ERRNO\n";
}
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

# removing CR LF
$content =~ s/\r\n/\n/smxg;

# parsing SRT file
my $array_parsed = parse_srt($content);

# verbose progress
my $progress = 1;
my $total    = scalar @{$array_parsed};

# translating the content (if -t was specified in the program call)
my @array_translated;
foreach my $subtitle (@{$array_parsed}) {
    my %translated;

    # verify if -t was specified in the program call
    if ($translate) {

        if ($verbose) {
            print "-> Translating $progress of $total\n"
                or die "Can't write verbose progress: $ERRNO\n";
        }

        if (defined $subtitle->{formated}) {

            # for formatted text
            $translated{subtitle}
                = get_translation($source, $target, $subtitle->{text});
            $translated{subtitle}
                = $subtitle->{prefix}
                . $translated{subtitle}
                . $subtitle->{suffix};
        }
        else {
            # for unformatted text
            $translated{subtitle}
                = get_translation($source, $target, $subtitle->{subtitle});
        }
    }
    else {
        # does not translate
        $translated{subtitle} = $subtitle->{subtitle};

        # if -c was specified in the program call
        if ($count) {
            $count += length $subtitle->{subtitle};
        }
    }

    # the other fields remain the same
    $translated{original}   = $subtitle->{subtitle};
    $translated{start_time} = $subtitle->{start_time};
    $translated{end_time}   = $subtitle->{end_time};

    push @array_translated, \%translated;
    $progress++;
}

# writing results in file.json (if -c was not specified in the program call)
if (!$count) {
    open my $fh, '>:encoding(UTF-8)', $infile . '.json'
        or die "Can't open result file $infile.json: $ERRNO\n";
    print {$fh} j(\@array_translated)
        or die "Can't write result file $infile.json: $ERRNO\n";
    close $fh or die "Can't close result file $infile.json: $ERRNO\n";

    if ($verbose) {
        print "-> Write results file ($infile.json)\n\n"
            or die "Can't write verbose file output: $ERRNO\n";
    }
}

# print results (if -v was specified in the program call)
if (defined $verbose && $verbose >= 2) {
    print j(\@array_translated) or die "Can't show results: $ERRNO\n";
}

# print count results
if ($count) {
    print "\nCharacters: $count\n"
        or die "Can't print count results: $ERRNO\n";
}

#
# parse_srt function takes a string with the contents of a SubRip file (without
#   CR LF) and returns one of the possible array of hashes:
#   [
#       {
#           start_time => "00:33:51,258",
#           end_time   => "00:33:53,058",
#           subtitle   => "Hey, Zoe.",
#       }
#   ]
#
#   or (for formatted text)
#
#   [
#       {
#            end_time   => "00:13:40,376",
#            formated   => "y",
#            prefix     => "<i>",
#            start_time => "00:13:38,576",
#            subtitle   => "<i>Eu disse que ia empurrar para que empurrar.</i>",
#            suffix     => "</i>",
#            text       => "Eu disse que ia empurrar para que empurrar.",
#       }
#   ]
#
sub parse_srt {
    my $file_content = shift;
    my @result;

    # break file for better parsing
    my @subtitles = split /\n\n/smx, $file_content;

    foreach my $subtitle (@subtitles) {
        if (
            $subtitle =~ m{\d+\s*\n
                        (?<start_time>\d+:\d+:\d+,\d+)\s+\-\-\>\s+(?<end_time>\d+:\d+:\d+,\d+)\s*\n
                        (?<subtitle>.+)}smx
            )
        {
            my %tmp_sub;
            $tmp_sub{start_time} = $LAST_PAREN_MATCH{start_time};
            $tmp_sub{end_time}   = $LAST_PAREN_MATCH{end_time};
            $tmp_sub{subtitle}   = $LAST_PAREN_MATCH{subtitle};

            if ($tmp_sub{subtitle}
                =~ /(?<prefix><[^>]+>)(?<text>.*)(?<suffix><[^>]+>)/smx)
            {
                $tmp_sub{text}     = $LAST_PAREN_MATCH{text};
                $tmp_sub{prefix}   = $LAST_PAREN_MATCH{prefix};
                $tmp_sub{suffix}   = $LAST_PAREN_MATCH{suffix};
                $tmp_sub{formated} = 'y';
            }

            push @result, \%tmp_sub;
        }
    }

    return \@result;
}


#
# get_translation function takes a source language, a target language and
#   string and translate it using the Google Translate API and returns a string
#   with the translated text.
#
sub get_translation {
    my $src   = shift;
    my $trg   = shift;
    my $query = shift;

    my $ua = Mojo::UserAgent->new;
    return $ua->get(
        $GOOGLE_APIS_ENDPOINT => form => {
            key    => $ENV{GOOGLE_TRANSLATE_API_KEY},
            source => $src,
            target => $trg,
            q      => $query,
        }
    )->res->json('/data/translations/0/translatedText');
}
