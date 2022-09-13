#! /usr/bin/env perl

## <https://wiki.hyprland.org/IPC/>

use strict;
use warnings;
no warnings 'experimental';

use 5.010;

use IO::Socket qw(AF_UNIX);


my $his = $ENV{'HYPRLAND_INSTANCE_SIGNATURE'};
die "Hyprland instance signature is not set!" unless $his;

my $socket_path = "/tmp/hypr/$his/.socket2.sock";

my $socket = IO::Socket->new(
    Domain => AF_UNIX,
    Peer => $socket_path
);
die "Could not open socket!" unless $socket;

while (my $line = <$socket>) {
    given ($line) {
        when ($line =~ /^workspace>>(.*)$/) {
            h_WorkspaceFocus($1);
        }
        when ($line =~ /^focusedmon>>(.*),(.*)$/) {
            h_MonitorFocus($1, $2);
        }
        when ($line =~ /^activewindow>>(.*),(.*)$/) {
            h_WindowFocus($1, $2);
        }
        when ($line =~ /^fullscreen>>(.*)$/) {
            h_WindowFullscreen($1);
        }
        when ($line =~ /^monitorremoved>>(.*)$/) {
            h_MonitorRemove($1);
        }
        when ($line =~ /^monitoradded>>(.*)$/) {
            h_MonitorAdd($1);
        }
        when ($line =~ /^createworkspace>>(.*)$/) {
            h_WorkspaceCreate($1);
        }
        when ($line =~ /^destroyworkspace>>(.*)$/) {
            h_WorkspaceDestroy($1);
        }
        when ($line =~ /^moveworkspace>>(.*),(.*)$/) {
            h_WorkspaceMove($1, $2);
        }
        when ($line =~ /^activelayout>>(.*),(.*)$/) {
            h_LayoutChange($1, $2);
        }
        when ($line =~ /^openwindow>>(.*),(.*),(.*),(.*)$/) {
            h_WindowOpen($1, $2, $3, $4);
        }
        when ($line =~ /^closewindow>>(.*)$/) {
            h_WindowClose($1);
        }
        when ($line =~ /^movewindow>>(.*),(.*)$/) {
            h_WindowMove($1, $2);
        }
        when ($line =~ /^submap>>(.*)$/) {
            h_SubmapChange($1);
        }
        default {
            say "UNHANDLED: $line";
        }
    }
}

### WINDOWS ###

sub h_WindowFocus {
    my $window_class = shift;
    my $window_title = shift;
}

sub h_WindowOpen {
    my $window_address = shift;
    my $workspace_name = shift;
    my $window_class = shift;
    my $window_title = shift;
}

sub h_WindowClose {
    my $window_address = shift;
}

sub h_WindowMove {
    my $window_address = shift;
    my $workspace_name = shift;
}

sub h_WindowFullscreen {
    my $fullscreen_state = shift;
}

### WORKSPACES ###

sub h_WorkspaceFocus {
    my $workspace_name = shift;
}

sub h_WorkspaceCreate {
    my $workspace_name = shift;
}

sub h_WorkspaceDestroy {
    my $workspace_name = shift;
}

sub h_WorkspaceMove {
    my $workspace_name = shift;
    my $monitor_name = shift;
}

### MONITORS ###

sub h_MonitorFocus {
    my $monitor_name = shift;
    my $workspace_name = shift;
}

sub h_MonitorAdd {
    my $monitor_name = shift;
}

sub h_MonitorRemove {
    my $monitor_name = shift;
}

### MISCELLANEOUS ###

sub h_LayoutChange {
    my $keyboard_name = shift;
    my $layout_name = shift;
}

sub h_SubmapChange {
    my $submap_name = shift;
}
