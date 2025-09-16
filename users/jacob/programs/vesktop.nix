{ lib, pkgs, ... }:
let
  inherit (lib.birdos.colors) grayRGB listRGB;
  gray = p: listRGB (grayRGB p);

  mkRecolorTheme = attrs:
    pkgs.discord-recolor-theme.override {
      themeName = attrs.themeName;
      overrideVariables = removeAttrs attrs [ "themeName" ];
    };

  enablePlugins = lib.mapAttrs (_: value:
    if lib.isBool value then {
      enabled = value;
    } else if value ? enabled then
      value
    else
      value // { enabled = true; });
in {
  programs.vesktop = {
    enable = true;

    settings = {
      arRPC = true;
      clickTrayToShowHide = true;
      discordBranch = "stable";
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
      minimizeToTray = true;
      tray = true;
    };

    vencord.themes = {
      gruvbox-darker = with lib.birdos.colors.formats.listRGB.gruvbox.colors;
        mkRecolorTheme {
          themeName = "GruvBox Darker";

          accentcolor = neutral_orange;
          accentcolor2 = neutral_purple;
          linkcolor = neutral_blue;
          mentioncolor = neutral_aqua;
          successcolor = bright_green;
          warningcolor = bright_yellow;
          dangercolor = bright_red;

          textbrightest = light0_hard;
          textbrighter = light0;
          textbright = light0;
          textdark = dark4;
          textdarker = dark3;
          textdarkest = dark2;

          backgroundaccent = gray 0.12;
          backgroundprimary = gray 8.0e-2;
          backgroundsecondary = gray 6.0e-2;
          backgroundsecondaryalt = gray 5.0e-2;
          backgroundtertiary = gray 4.0e-2;
          backgroundfloating = gray 0;

          font = [ "system-ui" ];
          settingsicons = false;
        };
    };

    vencord.settings = {
      useQuickCss = false;
      enabledThemes = [ "gruvbox-darker.css" ];
    };

    vencord.settings.plugins = enablePlugins {
      # Configurable folder behavior.
      BetterFolders = {
        closeAllFolders = true;
        closeAllHomeButton = false;
        closeOthers = true;
        forceOpen = true;
        sidebar = false;
      };
      # Open the Favorite category in the GIF picker by default.
      BetterGifPicker = true;
      # Add a context menu entry to edit role.
      BetterRoleContext = true;
      # Show more information in the sessions menu.
      BetterSessions = true;
      # Left-click to upload, right-click for menu.
      BetterUploadButton = true;
      # Enlarge the stream preview in voice channels.
      BiggerStreamPreview = true;
      # Blur NSFW content.
      BlurNSFW = true;
      # Show a timer for voice calls.
      CallTimer = { format = "human"; };
      # Remove tracking elements from URLS sent by me.
      ClearURLs = true;
      # Ability to copy and open sticker links.
      CopyStickerLinks = true;
      # Add a context menu entry to copy the user's URL.
      CopyUserURLs = true;
      # Wait longer before considering the client to be idle after inactivity.
      CustomIdle = { idleTimeout = 15; };
      # Custom rich presence message.
      CustomRPC = let
        PLAYING = 0;
        NO_TIMESTAMP = 0;
      in {
        appID = "0660";
        appName = "Rust & Nix Programming";
        type = PLAYING;
        timestampMode = NO_TIMESTAMP;
      };
      # Makes YouTube embed titles and thumbnails use a frame from the video.
      Dearrow = true;
      # Prevent getting kicked from voice call after three minutes.
      DisableCallIdle = true;
      # Clone emotes & stickers to your own server.
      ExpressionCloner = true;
      # Fake Nitro features.
      FakeNitro = { enableEmojiBypass = false; };
      # Put most-used emojis first in autocomplete.
      FavoriteEmojiFirst = true;
      # Add a search bar to favorite GIFs.
      FavoriteGifSearch = true;
      # Prevent loading images as WEBP, favoring higher-quality formats.
      FixImagesQuality = true;
      # Decrease the volume of Spotify embeds when played.
      FixSpotifyEmbeds = true;
      # Bypass blocked YouTube embeds.
      FixYoutubeEmbeds = true;
      # Always show a crown on the server owner, despite a high member count.
      ForceOwnerCrown = true;
      # Add chat commands for managing friend invites.
      FriendInvites = true;
      # Show how long a user has been a friend.
      FriendsSince = true;
      # Add context menu entries for messages in the search panel.
      FullSearchContext = true;
      # Add click handlers for user mentions in the chat box.
      FullUserInChatbox = true;
      # Insert a link from the GIF picker instead of instantly sending.
      GifPaste = true;
      # Display the file name of media uploads in a tooltip.
      ImageFilename = true;
      # Add zoom functionality for images and GIFs.
      ImageZoom = {
        nearestNeighbor = true;
        saveZoomValues = true;
        size = 1000.0;
        square = true;
      };
      # Attempt to restore the last-opened channel on startup.
      KeepCurrentChannel = true;
      # Display a member/online count at the top of the list.
      MemberCount = true;
      # Add fancy click actions to messages.
      # - Backspace + LMB = Delete
      # - Double LMB = Edit or Reply
      MessageClickActions = true;
      # Display an indicator for messages with high latency.
      MessageLatency = true;
      # Render embeds for message links.
      MessageLinkEmbeds = true;
      # Ephemeral message logs for deletions and edits.
      MessageLogger = {
        collapseDeleted = true;
        ignoreBots = true;
        ignoreSelf = true;
      };
      # Allow saving messages to snippets, send with commands.
      MessageTags = true;
      # Show mutual group chats in profile modals.
      MutualGroupDMs = true;
      # Apply default settings for new guilds.
      NewGuildSettings = {
        # suppress @everyone
        everyone = true;
        # mute guild automatically
        guild = true;
        # suppress role mentions
        role = false;
        # show all channels automatically
        showAllChannels = true;
      };
      # Allow jumping to messages from blocked users.
      NoUnblockToJump = true;
      # Remove Canary or PTB subdomain from links.
      NormalizeMessageLinks = true;
      # Only send one ping for multiple messages from a single person.
      OnePingPerDM = {
        allowEveryone = true;
        allowMentions = true;
      };
      # Use URL handlers for links if available.
      OpenInApp = true;
      # Override default forum layout and sort order.
      OverrideForumDefaults = let
        LIST_LAYOUT = 1;
        RECENTLY_ACTIVE = 0;
      in {
        defaultLayout = LIST_LAYOUT;
        defaultSortOrder = RECENTLY_ACTIVE;
      };
      # Disable client-side restrictions for channel permission management.
      # TODO: Unsure if this is needed anymore.
      PermissionFreeWill = false;
      # View the permissions of a user or channel, and the roles of a server.
      PermissionsViewer = true;
      # Add a PIP mode for embed viewers.
      PictureInPicture = true;
      # Pin private channels to the top of the DMs list.
      PinDMs = true;
      # Add a rendered message preview before sending.
      PreviewMessage = true;
      # Add a quick mention/reply button to the message actions bar.
      QuickMention = true;
      QuickReply = true;
      # Notify when friendship with a user changes.
      RelationshipNotifier = { notices = true; };
      # Adds role colors wherever possible.
      RoleColorEverywhere = { chatMentions = false; };
      # Always play the secret/rare version of the ringtone.
      SecretRingToneEnabler = true;
      # View more information about a server.
      ServerInfo = true;
      # Show online friend count.
      ServerListIndicators = let ONLY_FRIEND_COUNT = 2;
      in { mode = ONLY_FRIEND_COUNT; };
      # Show Vencord settings at the bottom of the list.
      Settings = { settingsLocation = "aboveActivity"; };
      # Better code blocks.
      ShikiCodeblocks = {
        customTheme =
          "https://raw.githubusercontent.com/bottledlactose/darkbox/refs/heads/trunk/themes/darkbox.json";
        useDevIcon = "GREYSCALE";
      };
      # Show all message buttons regardless of holding Shift.
      ShowAllMessageButtons = true;
      # Show a user's connected accounts in modals.
      ShowConnections = let COMPACT = 0; in { iconSpacing = COMPACT; };
      # Show users as moderator, when invites are paused, and member timeouts.
      ShowHiddenThings = true;
      # Display usernames next to nicknames.
      ShowMeYourName = {
        inReplies = true;
        mode = "nick-user";
      };
      # Display how much longer a user's timeout will last.
      ShowTimeoutDuration = true;
      # Add a button to the chat bar to toggle sending as a silent message.
      SilentMessageToggle = true;
      # Add a toggle to hide my typing indicator.
      SilentTyping = {
        isEnabled = false;
        showIcon = true;
      };
      # Sort friend requests by date.
      SortFriendRequests = { showDates = true; };
      # Listen-along for free, disable auto-pause, ignore client idle state.
      SpotifyCrack = { keepSpotifyActivityOnIdle = true; };
      # Enable streamer mode when streaming on Discord itself.
      StreamerModeOnStream = true;
      # Change the number of simultaneous super reactions (for performance reasons).
      SuperReactionTweaks = {
        superReactByDefault = false;
        superReactionPlayingLimit = 10;
      };
      # Add a button to translate messages (mine and theirs).
      Translate = true;
      # Show avatars and role colors in the typing indicator.
      TypingTweaks = true;
      # Automatically un-indent code when pasted in a code block.
      Unindent = true;
      # Allow me to unsuppress embeds in messages.
      UnsuppressEmbeds = true;
      # Show an indicator when a user is in a voice channel.
      UserVoiceShow = true;
      # Fix bug where "Message could not be loaded" when hovering on a reply.
      ValidReply = true;
      # Fix bug where mentions show as "@unknown-user".
      ValidUser = true;
      # Clickable avatars and banners.
      ViewIcons = {
        format = "png";
        imgSize = toString 2048;
      };
      # Button to view the raw text/data of a message, channel, or guild.
      ViewRaw = true;
      # Require double-click to join a voice channel (not single-click).
      VoiceChatDoubleClick = true;
      # Allow setting a user's volume above the default maximum.
      VolumeBooster = true;
      # Summons a small pixel art cat to follow the cursor.
      oneko = true;
      # Add a `/petpet` command to add head pets to any image.
      petpet = true;
      # Block ads in YouTube embeds.
      YoutubeAdblock = true;
    };
  };
}
