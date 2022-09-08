{ lib, ... }: let
  ### WEB BROWSER ###
  associations."firefox" = [
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

  ### DOCUMENT VIEWER ###
  associations."org.kde.okular" = [
    "application/pdf"
    "application/epub"
    "application/djvu"
    "application/mobi"
    # "application/x-chm"
    # "application/comicbook"
    # "application/dvi"
    # "application/fax"
    # "application/fb"
    # "application/ghostview"
    # "application/md"
    # "application/plucker"
    # "application/tiff"
    # "application/txt"
    # "application/xps"
  ];

  ### MEDIA PLAYER ###
  associations."haruna" = [
    "audio/*"
    "video/*"
  ];

  ### IMAGE VIEWER ###
  associations."lximage-qt" = [
    "image/*"
  ];

  ### DISCORD ###
  associations."webcord" = [
    "x-scheme-handler/discord"
  ];
in {
  xdg.mimeApps = let
    flipAssoc = n: v: map (x: { "${x}" = "${n}.desktop"; }) v;
    associations' = lib.pipe associations [
      (lib.mapAttrsToList flipAssoc)
      lib.flatten
      lib.zipAttrs
    ];
  in {
    enable = true;
    associations.added = associations';
    defaultApplications = associations';
  };
}
