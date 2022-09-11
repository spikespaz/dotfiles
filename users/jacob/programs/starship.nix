{ lib, ... }: let
  toStringRecur = x:
    if builtins.isAttrs x
    then builtins.mapAttrs (_: toStringRecur) x
    else toString x;

  gruvbox = {
    normal = {
      orange = 166;
      red = 124;
      green = 106;
      yellow = 172;
      blue = 66;
      purple = 132;
      aqua = 72;
      gray = 246;
    };
    bright = {
      orange = 208;
      red = 167;
      green = 142;
      yellow = 214;
      blue = 109;
      purple = 175;
      aqua = 108;
      gray = 245;
    };
    bg = gruvbox.bg0;
    bg0 = 235;
    bg0_h = 234;
    bg0_s = 236;
    bg1 = 237;
    bg2 = 239;
    bg3 = 241;
    bg4 = 143;
    fg = gruvbox.fg1;
    fg0 = 229;
    fg1 = 223;
    fg2 = 250;
    fg3 = 248;
    fg4 = 246;
    inherit (gruvbox.bright) orange red green yellow blue purple aqua gray;
  };

  colors = toStringRecur gruvbox;

  sep = {
    left = " [](${colors.fg3})";
    right = "[](${colors.fg3}) ";
  };
in {
  scan_timeout = 100;
  command_timeout = 1000;

  character = {
    success_symbol = "[](${colors.aqua})";
    error_symbol = "[](${colors.orange})";
    vicmd_symbol = "[](${colors.purple})";
  };

  continuation_prompt = "[﬌](${colors.gray}) ";

  status = {
    disabled = false;
    format = "[$status]($style) ";
    style = "bold ${colors.red}";
    recognize_signal_code = false;
  };

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
    "($status)"
    "$character"
  ];

  right_format = lib.concatStrings [
    "($cmd_duration)"
    "($git_state)"
  ];

  directory = {
    format = "([$read_only ]($read_only_style))[$path]($style) ";
    read_only = "";
    read_only_style = "${colors.orange}";
  };

  git_commit = {
    format = lib.concatStrings [
      "on "
      "[ $hash ](bold ${colors.aqua})"
      "([ $tag ](bold ${colors.yellow}))"
    ];
    tag_symbol = "";
  };

  git_metrics = {
    disabled = false;
  };

  git_status = {
    format = lib.concatStrings [
      "([$stashed](bold ${colors.yellow}) )"
      "([$renamed](bold ${colors.purple}) )"
      "([$deleted](bold ${colors.red}) )"
      "([$modified](bold ${colors.purple}) )"
      "([$conflicted](bold ${colors.red}) )"
      "([$ahead](bold ${colors.green}) )"
      "([$behind](bold ${colors.orange}) )"
      "([$staged](bold ${colors.aqua}) )"
      "([$untracked](bold ${colors.orange}) )"
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
    style = "${colors.bg3}";
  };

  battery = {
    format = " [$symbol $percentage](bold $style)";
    unknown_symbol = " ";  # when docked
    display = [
      {
        threshold = 10; style = "${colors.red}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 20; style = "${colors.red}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 30; style = "${colors.orange}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 40; style = "${colors.orange}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 50; style = "${colors.yellow}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 60; style = "${colors.yellow}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 70; style = "${colors.yellow}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 80; style = "${colors.green}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 90; style = "${colors.green}";
        charging_symbol = ""; discharging_symbol = "";
      }
      {
        threshold = 100; style = "${colors.green}";
        charging_symbol = ""; discharging_symbol = "";
      }
    ];
  };

  memory_usage = {
    disabled = false;
    threshold = 0;
    style = "bold ${colors.fg2}";
  };

  cmd_duration = {
    min_time = 5;
    show_notifications = true;
    min_time_to_notify = 2 * 60 * 1000;
    notification_timeout = 5 * 60 * 1000;
    format = " [ $duration]($style)";
  };

  git_state = {
    format = lib.concatStrings [
      " "
      "[\\[](bold ${colors.fg3})"
      "[$state( $progress_current/$progress_total)]($style)"
      "[\\]](bold ${colors.fg3})"
    ];
    style = "underline bold ${colors.orange}";
    rebase = "REBASE";
    merge = "MERGE";
    revert = "REVERT";
    cherry_pick = "PICK";
    bisect = "BISECT";
  };
}
