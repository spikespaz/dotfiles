{ulib, ...}:
ulib.mkMimeApps {
  ### FILE BROWSER ###
  "org.kde.dolphin" = [
    "inode/directory"
    "x-directory/normal"
  ];

  ### WEB BROWSER ###
  "firefox" = [
    "text/html"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "application/xhtml+xml"
    "application/xhtml_xml"
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xhtml"
    "application/x-extension-xht"
  ];

  ### DISCORD ###
  "webcord" = [
    "x-scheme-handler/discord"
  ];
}
