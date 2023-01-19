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
    windowfocus      => $ENV{'__HL_HANDLER_WINDOWFOCUS'},
    windowopen       => $ENV{'__HL_HANDLER_WINDOWOPEN'},
    windowclose      => $ENV{'__HL_HANDLER_WINDOWCLOSE'},
    windowmove       => $ENV{'__HL_HANDLER_WINDOWMOVE'},
    windowfullscreen => $ENV{'__HL_HANDLER_WINDOWFULLSCREEN'},
    workspacefocus   => $ENV{'__HL_HANDLER_WORKSPACEFOCUS'},
    workspacecreate  => $ENV{'__HL_HANDLER_WORKSPACECREATE'},
    workspacedestroy => $ENV{'__HL_HANDLER_WORKSPACEDESTROY'},
    workspacemove    => $ENV{'__HL_HANDLER_WORKSPACEMOVE'},
    monitorfocus     => $ENV{'__HL_HANDLER_MONITORFOCUS'},
    monitoradd       => $ENV{'__HL_HANDLER_MONITORADD'},
    monitorremove    => $ENV{'__HL_HANDLER_MONITORREMOVE'},
    layoutchange     => $ENV{'__HL_HANDLER_LAYOUTCHANGE'},
    submapchange     => $ENV{'__HL_HANDLER_SUBMAPCHANGE'},
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

    if ( defined $handlers{windowfocus} ) {
        system( $handlers{windowfocus} );
    }
}

sub h_WindowOpen {
    $ENV{'HL_WINDOW_ADDRESS'} = shift;
    $ENV{'HL_WORKSPACE_NAME'} = shift;
    $ENV{'HL_WINDOW_CLASS'}   = shift;
    $ENV{'HL_WINDOW_TITLE'}   = shift;

    if ( defined $handlers{windowopen} ) {
        system( $handlers{windowopen} );
    }
}

sub h_WindowClose {
    $ENV{'HL_WINDOW_ADDRESS'} = shift;

    if ( defined $handlers{windowclose} ) {
        system( $handlers{windowclose} );
    }
}

sub h_WindowMove {
    $ENV{'HL_WINDOW_ADDRESS'} = shift;
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    if ( defined $handlers{windowmove} ) {
        system( $handlers{windowmove} );
    }
}

sub h_WindowFullscreen {
    $ENV{'HL_FULLSCREEN_STATE'} = shift;

    if ( defined $handlers{windowfullscreen} ) {
        system( $handlers{windowfullscreen} );
    }
}

### WORKSPACES ###

sub h_WorkspaceFocus {
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    if ( defined $handlers{workspacefocus} ) {
        system( $handlers{workspacefocus} );
    }
}

sub h_WorkspaceCreate {
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    if ( defined $handlers{workspacecreate} ) {
        system( $handlers{workspacecreate} );
    }
}

sub h_WorkspaceDestroy {
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    if ( defined $handlers{workspacedestroy} ) {
        system( $handlers{workspacedestroy} );
    }
}

sub h_WorkspaceMove {
    $ENV{'HL_WORKSPACE_NAME'} = shift;
    $ENV{'HL_MONITOR_NAME'}   = shift;

    if ( defined $handlers{workspacemove} ) {
        system( $handlers{workspacemove} );
    }
}

### MONITORS ###

sub h_MonitorFocus {
    $ENV{'HL_MONITOR_NAME'}   = shift;
    $ENV{'HL_WORKSPACE_NAME'} = shift;

    if ( defined $handlers{monitorfocus} ) {
        system( $handlers{monitorfocus} );
    }
}

sub h_MonitorAdd {
    $ENV{'HL_MONITOR_NAME'} = shift;

    if ( defined $handlers{monitoradd} ) {
        system( $handlers{monitoradd} );
    }
}

sub h_MonitorRemove {
    $ENV{'HL_MONITOR_NAME'} = shift;

    if ( defined $handlers{monitorremove} ) {
        system( $handlers{monitorremove} );
    }
}

### MISCELLANEOUS ###

sub h_LayoutChange {
    $ENV{'HL_KEYBOARD_NAME'} = shift;
    $ENV{'HL_LAYOUT_NAME'}   = shift;

    if ( defined $handlers{layoutchange} ) {
        system( $handlers{layoutchange} );
    }
}

sub h_SubmapChange {
    $ENV{'HL_SUBMAP_NAME'} = shift;

    if ( defined $handlers{submapchange} ) {
        system( $handlers{submapchange} );
    }
}
