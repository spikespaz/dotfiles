#! /usr/bin/env perl

## <https://wiki.hyprland.org/IPC/>

use strict;
use warnings;
use 5.036;
use feature qw(switch);
no warnings 'experimental';

use IO::Socket qw(AF_UNIX);

my $his = $ENV{'HYPRLAND_INSTANCE_SIGNATURE'};
die "Hyprland instance signature is not set!" unless $his;

my $socket_path = "/tmp/hypr/$his/.socket2.sock";

my $socket = IO::Socket->new(
    Domain => AF_UNIX,
    Peer   => $socket_path
);
die "Could not open socket!" unless $socket;

my %handlers = (
    windowfocus      => [ split( ':', $ENV{'__HL_HANDLERS_WINDOWFOCUS'} ) ],
    windowopen       => [ split( ':', $ENV{'__HL_HANDLERS_WINDOWOPEN'} ) ],
    windowclose      => [ split( ':', $ENV{'__HL_HANDLERS_WINDOWCLOSE'} ) ],
    windowmove       => [ split( ':', $ENV{'__HL_HANDLERS_WINDOWMOVE'} ) ],
    windowfullscreen =>
      [ split( ':', $ENV{'__HL_HANDLERS_WINDOWFULLSCREEN'} ) ],
    workspacefocus   => [ split( ':', $ENV{'__HL_HANDLERS_WORKSPACEFOCUS'} ) ],
    workspacecreate  => [ split( ':', $ENV{'__HL_HANDLERS_WORKSPACECREATE'} ) ],
    workspacedestroy =>
      [ split( ':', $ENV{'__HL_HANDLERS_WORKSPACEDESTROY'} ) ],
    workspacemove => [ split( ':', $ENV{'__HL_HANDLERS_WORKSPACEMOVE'} ) ],
    monitorfocus  => [ split( ':', $ENV{'__HL_HANDLERS_MONITORFOCUS'} ) ],
    monitoradd    => [ split( ':', $ENV{'__HL_HANDLERS_MONITORADD'} ) ],
    monitorremove => [ split( ':', $ENV{'__HL_HANDLERS_MONITORREMOVE'} ) ],
    layoutchange  => [ split( ':', $ENV{'__HL_HANDLERS_LAYOUTCHANGE'} ) ],
    submapchange  => [ split( ':', $ENV{'__HL_HANDLERS_SUBMAPCHANGE'} ) ],
);

while ( my $line = <$socket> ) {
    given ($line) {
        when ( $line =~ /^workspace>>(.*)$/ ) {
            h_WorkspaceFocus($1);
        }
        when ( $line =~ /^focusedmon>>(.*),(.*)$/ ) {
            h_MonitorFocus( $1, $2 );
        }
        when ( $line =~ /^activewindow>>(.*),(.*)$/ ) {
            h_WindowFocus( $1, $2 );
        }
        when ( $line =~ /^fullscreen>>(.*)$/ ) {
            h_WindowFullscreen($1);
        }
        when ( $line =~ /^monitorremoved>>(.*)$/ ) {
            h_MonitorRemove($1);
        }
        when ( $line =~ /^monitoradded>>(.*)$/ ) {
            h_MonitorAdd($1);
        }
        when ( $line =~ /^createworkspace>>(.*)$/ ) {
            h_WorkspaceCreate($1);
        }
        when ( $line =~ /^destroyworkspace>>(.*)$/ ) {
            h_WorkspaceDestroy($1);
        }
        when ( $line =~ /^moveworkspace>>(.*),(.*)$/ ) {
            h_WorkspaceMove( $1, $2 );
        }
        when ( $line =~ /^activelayout>>(.*),(.*)$/ ) {
            h_LayoutChange( $1, $2 );
        }
        when ( $line =~ /^openwindow>>(.*),(.*),(.*),(.*)$/ ) {
            h_WindowOpen( $1, $2, $3, $4 );
        }
        when ( $line =~ /^closewindow>>(.*)$/ ) {
            h_WindowClose($1);
        }
        when ( $line =~ /^movewindow>>(.*),(.*)$/ ) {
            h_WindowMove( $1, $2 );
        }
        when ( $line =~ /^submap>>(.*)$/ ) {
            h_SubmapChange($1);
        }
        default {
            say "UNHANDLED: $line";
        }
    }
}

### WINDOWS ###

sub h_WindowFocus {
    $ENV{'HL_WINDOW_CLASS'} = shift;
    $ENV{'HL_WINDOW_TITLE'} = shift;

    foreach my $script ( $handlers{windowfocus}->@* ) {
        system($script);
    }
}

sub h_WindowOpen {
    $ENV{'HL_WINDOW_ADDRESS'} = shift;
    $ENV{'HL_WORKSPACE_NAME'} = shift;
    $ENV{'HL_WINDOW_CLASS'}   = shift;
    $ENV{'HL_WINDOW_TITLE'}   = shift;

    foreach my $script ( $handlers{windowopen}->@* ) {
        system($script);
    }
}

sub h_WindowClose {
    $ENV{'HL_WINDOW_ADDRESS'} = shift;

    foreach my $script ( $handlers{windowclose}->@* ) {
        system($script);
    }
}

sub h_WindowMove {
    $ENV{'HL_WINDOW_ADDRESS'} = shift;
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    foreach my $script ( $handlers{windowmove}->@* ) {
        system($script);
    }
}

sub h_WindowFullscreen {
    $ENV{'HL_FULLSCREEN_STATE'} = shift;

    foreach my $script ( $handlers{windowfullscreen}->@* ) {
        system($script);
    }
}

### WORKSPACES ###

sub h_WorkspaceFocus {
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    foreach my $script ( $handlers{workspacefocus}->@* ) {
        system($script);
    }
}

sub h_WorkspaceCreate {
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    foreach my $script ( $handlers{workspacecreate}->@* ) {
        system($script);
    }
}

sub h_WorkspaceDestroy {
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    foreach my $script ( $handlers{workspacedestroy}->@* ) {
        system($script);
    }
}

sub h_WorkspaceMove {
    $ENV{'HL_WORKSPACE_NAME'} = shift;
    $ENV{'HL_MONITOR_NAME'}   = shift;

    foreach my $script ( $handlers{workspacemove}->@* ) {
        system($script);
    }
}

### MONITORS ###

sub h_MonitorFocus {
    $ENV{'HL_MONITOR_NAME'}   = shift;
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    foreach my $script ( $handlers{monitorfocus}->@* ) {
        system($script);
    }
}

sub h_MonitorAdd {
    $ENV{'HL_MONITOR_NAME'} = shift;

    foreach my $script ( $handlers{monitoradd}->@* ) {
        system($script);
    }
}

sub h_MonitorRemove {
    $ENV{'HL_MONITOR_NAME'} = shift;

    foreach my $script ( $handlers{monitorremove}->@* ) {
        system($script);
    }
}

### MISCELLANEOUS ###

sub h_LayoutChange {
    $ENV{'HL_KEYBOARD_NAME'} = shift;
    $ENV{'HL_LAYOUT_NAME'}   = shift;

    foreach my $script ( $handlers{layoutchange}->@* ) {
        system($script);
    }
}

sub h_SubmapChange {
    $ENV{'HL_SUBMAP_NAME'} = shift;

    foreach my $script ( $handlers{submapchange}->@* ) {
        system($script);
    }
}
