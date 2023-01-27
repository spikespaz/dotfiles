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
my $scale_factor;
my $include_pointers = 0;

# Selection modes
my $mode;
my $active = 0;

# Selection options (slurp)
my $show_dimensions = 0;  # -d
my $background_color = '44557733';  # -b
my $select_border_color = '77CC66BB';  # -c
my $select_fill_color = 'FFFFFF00';  # -s
my $window_border_color = 'FFEEFFAA';  # -B
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
my $invalid_filetype = 'Invalid filetype provided,'
    . ' expected one of `png`, `jpeg`, or `ppm`';

use Getopt::Long qw(GetOptions
    :config require_order no_getopt_compat
        no_gnu_compat no_ignore_case
        auto_version auto_help);
use Pod::Usage;

GetOptions (
    # Where to save the file (grim)
    'c|clipboard' => sub {
        $filepath_changed and die $dest_conflict;
        $clipboard = $_[1];
    },
    'd|outdir=s' => sub {
        $clipboard and die $dest_conflict;
        $filepath_changed = 1;
        $outdir = $_[1];
    },
    'n|filename=s' => sub {
        $clipboard and die $dest_conflict;
        $filepath_changed = 1;
        $filename = $_[1];
    },
    'f|filename-format=s' => sub {
        $clipboard and die $dest_conflict;
        $filepath_changed = 1;
        $filename_format = $_[1];
    },
    'p|filepath=s' => sub {
        $clipboard and die $dest_conflict;
        $filepath_changed = 1;
        $filepath = $_[1];
    },

    # How to save the file (grim)
    't|filetype=s' => sub {
        $_[1] =~ /^(png|jpeg|ppm)$/ or die $invalid_filetype;
        $filetype = $_[1];
    },
    'q|jpeg-quality=i' => \$jpeg_quality,
    'l|png-level=i' => \$png_level,

    # Screenshot options (grim)
    's|scale-factor' => \$scale_factor,
    'P|include-pointers' => \$include_pointers,

    # Selection modes
    'm|mode=s' => sub {
        if ($_[1] =~ /^(r|region)$/) {
            $active and die $mode_conflict;
            $mode = "region";
        } elsif ($_[1] =~ /^(w|window)$/) {
            $mode = "window";
        } elsif ($_[1] =~ /^(m|monitor)$/) {
            $mode = "monitor";
        } elsif ($_[1] =~ /^(d|desktop)$/) {
            $active and die $mode_conflict;
            $mode = "desktop";
        } else {
            die "Unknown selection mode: `$_[1]`";
        }
    },
    'a|active' => sub {
        (defined $mode && $mode =~ /^(region|desktop)$/)
            and die $mode_conflict;
        $active = 1;
    },

    # Selection options (slurp)
    'D|show-dimensions' => \$show_dimensions,
    'b|background-color=s' => \$background_color,
    'B|select-border-color=s' => \$select_border_color,
    'S|select-fill-color=s' => \$select_fill_color,
    'w|window-border-color=s' => \$window_border_color,
    'W|border-weight=i' => \$border_weight,
) or die "test";

$mode = 'region' unless defined $mode;

# if clipboard has not been specifically requested
# and the filepath was not explicitly defined
unless ($clipboard || defined $filepath) {
    # if the filename was not explicitly defined
    unless (defined $filename) {
        my $timestamp = strftime $filename_format, localtime();
        # set the default filename
        $filename = "$timestamp.$filetype";
    }

    # if the outdir was not explicitly defined
    unless (defined $outdir) {
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

my $slurp_cmd = 'slurp';
my $grim_cmd = 'grim';

$slurp_cmd = "$slurp_cmd -d" if $show_dimensions;
$slurp_cmd = "$slurp_cmd -b $background_color";
$slurp_cmd = "$slurp_cmd -c $select_border_color";
$slurp_cmd = "$slurp_cmd -s $select_fill_color";
$slurp_cmd = "$slurp_cmd -B $window_border_color";
$slurp_cmd = "$slurp_cmd -w $border_weight";

$grim_cmd = "$grim_cmd -s $scale_factor" if defined $scale_factor;
$grim_cmd = "$grim_cmd -t $filetype";
$grim_cmd = "$grim_cmd -q $jpeg_quality" if $filetype eq 'jpeg';
$grim_cmd = "$grim_cmd -l $png_level" if $filetype eq 'png';
$grim_cmd = "$grim_cmd -c" if $include_pointers;

my $cmd;

if ($mode eq 'region') {
    $cmd = "$grim_cmd -g \"\$($slurp_cmd)\"";
} elsif ($mode eq 'window') {
    if ($active) {
        die 'TODO';
        my $region = 'TODO';
        $cmd = "$grim_cmd -g '$region'";
    } else {
        die 'TODO';
        my $regions = 'TODO';
        $slurp_cmd = "$slurp_cmd -r";
        $cmd = "$grim_cmd -g \"\$($regions | $slurp_cmd)\"";
    }
} elsif ($mode eq 'monitor') {
    if ($active) {
        die 'TODO';
        my $region = 'TODO';
        $cmd = "$grim_cmd -g '$region'";
    } else {
        $slurp_cmd = "$slurp_cmd -B $background_color";
        $slurp_cmd = "$slurp_cmd -o";
        $slurp_cmd = "$slurp_cmd -r";
        $cmd = "$grim_cmd -g \"\$($slurp_cmd)\"";
    }
} elsif ($mode eq 'desktop') {
    $cmd = $grim_cmd;
}

if ($clipboard) {
    $cmd = "$cmd - | wl-copy -t image/$filetype";
} else {
    $cmd = "$cmd '$filepath'";
}

print "$cmd\n";
exec $cmd;
