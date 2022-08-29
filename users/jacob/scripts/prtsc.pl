#! /usr/bin/env perl
use strict;
use warnings;

use POSIX qw(strftime);

# Where to save the file (grim)
my $clipboard = 0;
my $outdir;
my $filename;
my $filename_format = '%a_%b_%d__%H_%M_%S';
my $filepath;

# How to save the file (grim)
my $filetype = 'png';
my $jpeg_quality = 90;
my $png_level = 6;

# Screenshot options (grim)
my $include_pointers = 0;

# Selection modes
my $mode;
my $active = 0;

# Selection options (slurp)
my $show_dimensions = 0;  # -d
my $background_color = '44557733';  # -b
my $select_border_color = '77CC66BB';  # -c
my $select_fill_color = 'FFFFFF00';  # -s
my $region_border_color = 'FFEEFFAA';  # -B
my $border_weight = 1;  # -w

# tracker for filepath-related options
my $filepath_changed = 0;
# error messages
my $dest_conflict = 'Option `--clipboard` conflicts with `--outdir`,'
    . ' `--filename`, `--filename-format` and `--filepath`';
my $mode_conflict = 'Option `--active` conflicts when'
    . ' `--mode` is either `region` or `desktop`';
my $filepath_unable = 'Saving to a default path requires either the'
    . ' `XDG_PICTURES_DIR` or the `HOME` environment variable to be set';

use Getopt::Long qw(GetOptions :config gnu_compat no_getopt_compat auto_version auto_help);
use Pod::Usage;

GetOptions (
    # Where to save the file (grim)
    'cb|clipboard' => sub {
        !$filepath_changed or die $dest_conflict;
        $clipboard = $_[1];
    },
    'od|outdir=s' => sub {
        !$clipboard or die $dest_conflict;
        $filepath_changed = 1;
        $outdir = $_[1];
    },
    'fn|filename=s' => sub {
        !$clipboard or die $dest_conflict;
        $filepath_changed = 1;
        $filename = $_[1];
    },
    'ff|filename-format=s' => sub {
        !$clipboard or die $dest_conflict;
        $filepath_changed = 1;
        $filename_format = $_[1];
    },
    'fp|filepath=s' => sub {
        !$clipboard or die $dest_conflict;
        $filepath_changed = 1;
        $filepath = $_[1];
    },

    # How to save the file (grim)
    'ft|filetype=s' => \$filetype,
    'jq|jpeg-quality=i' => \$jpeg_quality,
    'pl|png-level=i' => \$png_level,

    # Screenshot options (grim)
    'ip|include-pointers' => \$include_pointers,

    # Selection modes
    'm|mode=s' => sub {
        if ($_[1] =~ /^(r|region)$/) {
            !$active or die $mode_conflict;
            $mode = "region";
        } elsif ($_[1] =~ /^(w|window)$/) {
            $mode = "window";
        } elsif ($_[1] =~ /^(m|monitor)$/) {
            $mode = "monitor";
        } elsif ($_[1] =~ /^(d|desktop)$/) {
            !$active or die $mode_conflict;
            $mode = "desktop";
        } else {
            die "Unknown selection mode: `$_[1]`";
        }
    },
    'a|active' => sub {
        !(defined $mode && $mode =~ /^(region|desktop)$/)
            or die $mode_conflict;
        $active = 1;
    },

    # Selection options (slurp)
    'sd|show-dimensions' => \$show_dimensions,
    'bg|background-color=s' => \$background_color,
    'sb|select-border-color=s' => \$select_border_color,
    'sf|select-fill-color=s' => \$select_fill_color,
    'rb|region-border-color=s' => \$region_border_color,
    'bw|border-weight=i' => \$border_weight,
) or die "test";

$mode = 'region' if !defined $mode;

# if clipboard has not been specifically requested
# and the filepath was not explicitly defined
if (!($clipboard || defined $filepath)) {
    # if the filename was not explicitly defined
    if (!defined $filename) {
        my $timestamp = strftime $filename_format, localtime();
        # set the default filename
        $filename = "$timestamp.$filetype";
    }

    # if the outdir was not explicitly defined
    if (!defined $outdir) {
        # set the outdir to the most suitable default
        if (defined $ENV{'XDG_PICTURES_DIR'}) {
            $outdir = "${ENV{'XDG_PICTURES_DIR'}}/Screenshots";
        } elsif (defined $ENV{'HOME'}) {
            $outdir = "${ENV{'HOME'}}/Pictures/Screenshots";
        } else {
            # no suitable default could be attained
            die $filepath_unable;
        }
    }

    # set the filepath
    $filepath = "$outdir/$filename";
}
