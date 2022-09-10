{ lib, ... }: let
  gruvbox = {
    red = "#fb4934";
    green = "#b8bb26";
    yellow = "#fabd2f";
    blue = "#83a598";
    purple = "#d3869b";
    aqua = "#8ec07c";
    orange = "#fe8019";
    gray = "#a89984";
    bg0_s = "#32302f";
    bg0 = "#282828";
    bg1 = "#3c3836";
    bg2 = "#504945";
    fg4 = "#a89984";
    fg2 = "#bdae93";
  };
  sep = {
    left = " [](${gruvbox.fg2})";
    right = "[](${gruvbox.fg2}) ";
  };
in {
  scan_timeout = 100;
  command_timeout = 1000;

  character = {
    success_symbol = "[](${gruvbox.aqua})";
    error_symbol = "[](${gruvbox.orange})";
  };

  continuation_prompt = "[﬌](${gruvbox.gray}) ";

  format = lib.concatStrings [
    "($directory${sep.right})"
    "($git_branch${sep.right})"
    "($git_commit${sep.right})"
    "($git_metrics${sep.right})"
    "($git_status${sep.right})"
    "$fill"
    "(${sep.left}$battery)"
    "(${sep.left}$memory_usage)"
    "$line_break"
    "$character"
  ];

  right_format = lib.concatStrings [
    "($cmd_duration)"
    "($git_state)"
  ];

  directory = {
    format = "([$read_only ]($read_only_style))[$path]($style) ";
    read_only = "";
    read_only_style = "${gruvbox.orange}";
  };

  git_commit = {
    format = lib.concatStrings [
      "[ $hash ](bold ${gruvbox.aqua})"
      "[ $tag ](bold ${gruvbox.yellow})"
    ];
    tag_symbol = "";
  };

  git_metrics = {
    disabled = false;
  };

  git_status = {
    format = lib.concatStrings [
      "([$stashed](bold ${gruvbox.yellow}) )"
      "([$renamed](bold ${gruvbox.purple}) )"
      "([$deleted](bold ${gruvbox.red}) )"
      "([$modified](bold ${gruvbox.purple}) )"
      "([$conflicted](bold ${gruvbox.red}) )"
      "([$ahead](bold ${gruvbox.green}) )"
      "([$behind](bold ${gruvbox.orange}) )"
      "([$staged](bold ${gruvbox.aqua}) )"
      "([$untracked](bold ${gruvbox.orange}) )"
    ];  
    conflicted =	" $count";
    ahead = " $count";
    behind = " $count";
    up_to_date = "";
    untracked = " $count";
    stashed = " $count";
    modified = " $count";
    staged = " $count";
    renamed = " $count";
    deleted = " $count";
    ignore_submodules = false;
  };

  fill = {
    symbol = "·";
    style = "${gruvbox.bg2}";
  };

  battery = {
    format = " [$symbol $percentage](bold $style)";
    full_symbol = "";
    charging_symbol = "⚡";
    discharging_symbol = "";
    unknown_symbol = "";  # when docked
    empty_symbol = "";
    display =  [
      {
        threshold = 100; style = "${gruvbox.green}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 90; style = "${gruvbox.green}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 80; style = "${gruvbox.green}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 70; style = "${gruvbox.yellow}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 60; style = "${gruvbox.yellow}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 50; style = "${gruvbox.yellow}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 40; style = "${gruvbox.orange}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 30; style = "${gruvbox.orange}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 20; style = "${gruvbox.red}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
      {
        threshold = 10; style = "${gruvbox.red}";
        charging_symbol = "⚡"; discharging_symbol = "";
      }
    ];
  };

  memory_usage = {
    disabled = false;
    threshold = 0;
    format = " [ $ram]($style)";
  };

  cmd_duration = {
    min_time = 5;
    show_notifications = true;
    min_time_to_notify = 2 * 60 * 1000;
    notification_timeout = 5 * 60 * 1000;
    format = "[  $duration]($style)";
  };

  git_state = {
    format = lib.concatStrings [
      " "
      "[\\[](bold ${gruvbox.fg2})"
      "[$state( $progress_current/$progress_total)]($style)"
      "[\\]](bold ${gruvbox.fg2})"
    ];
    style = "underline bold ${gruvbox.orange}";
    rebase = "REBASE";
    merge = "MERGE";
    revert = "REVERT";
    cherry_pick = "PICK";
    bisect = "BISECT";
  };
}
