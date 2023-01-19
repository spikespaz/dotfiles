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
    if ( defined $handlers{windowfocus} ) {
        $ENV{'HL_WINDOW_CLASS'} = shift;
        $ENV{'HL_WINDOW_TITLE'} = shift;
        system( $handlers{windowfocus} );
    }
}

sub h_WindowOpen {
    if ( defined $handlers{windowopen} ) {
        $ENV{'HL_WINDOW_ADDRESS'} = shift;
        $ENV{'HL_WORKSPACE_NAME'} = shift;
        $ENV{'HL_WINDOW_CLASS'}   = shift;
        $ENV{'HL_WINDOW_TITLE'}   = shift;
        system( $handlers{windowopen} );
    }
}

sub h_WindowClose {
    if ( defined $handlers{windowclose} ) {
        $ENV{'HL_WINDOW_ADDRESS'} = shift;
        system( $handlers{windowclose} );
    }
}

sub h_WindowMove {
    if ( defined $handlers{windowmove} ) {
        $ENV{'HL_WINDOW_ADDRESS'} = shift;
        $ENV{'HL_WORKSPACE_NAME'} = shift;
        system( $handlers{windowmove} );
    }
}

sub h_WindowFullscreen {
    if ( defined $handlers{windowfullscreen} ) {
        $ENV{'HL_FULLSCREEN_STATE'} = shift;
        system( $handlers{windowfullscreen} );
    }
}

### WORKSPACES ###

sub h_WorkspaceFocus {
    if ( defined $handlers{workspacefocus} ) {
        $ENV{'HL_WORKSPACE_NAME'} = shift;
        system( $handlers{workspacefocus} );
    }
}

sub h_WorkspaceCreate {
    if ( defined $handlers{workspacecreate} ) {
        $ENV{'HL_WORKSPACE_NAME'} = shift;
        system( $handlers{workspacecreate} );
    }
}

sub h_WorkspaceDestroy {
    if ( defined $handlers{workspacedestroy} ) {
        $ENV{'HL_WORKSPACE_NAME'} = shift;
        system( $handlers{workspacedestroy} );
    }
}

sub h_WorkspaceMove {
    if ( defined $handlers{workspacemove} ) {
        $ENV{'HL_WORKSPACE_NAME'} = shift;
        $ENV{'HL_MONITOR_NAME'}   = shift;
        system( $handlers{workspacemove} );
    }
}

### MONITORS ###

sub h_MonitorFocus {
    if ( defined $handlers{monitorfocus} ) {
        $ENV{'HL_MONITOR_NAME'}   = shift;
        $ENV{'HL_WORKSPACE_NAME'} = shift;
        system( $handlers{monitorfocus} );
    }
}

sub h_MonitorAdd {
    if ( defined $handlers{monitoradd} ) {
        $ENV{'HL_MONITOR_NAME'} = shift;
        system( $handlers{monitoradd} );
    }
}

sub h_MonitorRemove {
    if ( defined $handlers{monitorremove} ) {
        $ENV{'HL_MONITOR_NAME'} = shift;
        system( $handlers{monitorremove} );
    }
}

### MISCELLANEOUS ###

sub h_LayoutChange {
    if ( defined $handlers{layoutchange} ) {
        $ENV{'HL_KEYBOARD_NAME'} = shift;
        $ENV{'HL_LAYOUT_NAME'}   = shift;
        system( $handlers{layoutchange} );
    }
}

sub h_SubmapChange {
    if ( defined $handlers{submapchange} ) {
        $ENV{'HL_SUBMAP_NAME'} = shift;
        system( $handlers{submapchange} );
    }
}
