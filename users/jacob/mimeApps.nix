{ lib, ... }:
let
  flipAssocs = assocs:
    lib.pipe assocs [
      (lib.mapAttrsToList mapMimeListToXDGAttrs)
      lib.flatten
      lib.zipAttrs
    ];
  mapMimeListToXDGAttrs = prog: map (type: { "${type}" = "${prog}.desktop"; });
in {
  xdg.mimeApps = let
    associations = flipAssocs {
      ### FILE BROWSER ###
      "org.kde.dolphin" = [ "inode/directory" "x-directory/normal" ];

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
      "webcord" = [ "x-scheme-handler/discord" ];

      ### DOCUMENT VIEWER ###
      "org.kde.okular" = [
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
      "haruna" = [
        "application/ogg"
        "application/x-ogg"
        "application/mxf"
        "application/sdp"
        "application/smil"
        "application/x-smil"
        "application/streamingmedia"
        "application/x-streamingmedia"
        "application/vnd.rn-realmedia"
        "application/vnd.rn-realmedia-vbr"
        "audio/aac"
        "audio/x-aac"
        "audio/vnd.dolby.heaac.1"
        "audio/vnd.dolby.heaac.2"
        "audio/aiff"
        "audio/x-aiff"
        "audio/m4a"
        "audio/x-m4a"
        "application/x-extension-m4a"
        "audio/mp1"
        "audio/x-mp1"
        "audio/mp2"
        "audio/x-mp2"
        "audio/mp3"
        "audio/x-mp3"
        "audio/mpeg"
        "audio/mpeg2"
        "audio/mpeg3"
        "audio/mpegurl"
        "audio/x-mpegurl"
        "audio/mpg"
        "audio/x-mpg"
        "audio/rn-mpeg"
        "audio/musepack"
        "audio/x-musepack"
        "audio/ogg"
        "audio/scpls"
        "audio/x-scpls"
        "audio/vnd.rn-realaudio"
        "audio/wav"
        "audio/x-pn-wav"
        "audio/x-pn-windows-pcm"
        "audio/x-realaudio"
        "audio/x-pn-realaudio"
        "audio/x-ms-wma"
        "audio/x-pls"
        "audio/x-wav"
        "video/mpeg"
        "video/x-mpeg2"
        "video/x-mpeg3"
        "video/mp4v-es"
        "video/x-m4v"
        "video/mp4"
        "application/x-extension-mp4"
        "video/divx"
        "video/vnd.divx"
        "video/msvideo"
        "video/x-msvideo"
        "video/ogg"
        "video/quicktime"
        "video/vnd.rn-realvideo"
        "video/x-ms-afs"
        "video/x-ms-asf"
        "audio/x-ms-asf"
        "application/vnd.ms-asf"
        "video/x-ms-wmv"
        "video/x-ms-wmx"
        "video/x-ms-wvxvideo"
        "video/x-avi"
        "video/avi"
        "video/x-flic"
        "video/fli"
        "video/x-flc"
        "video/flv"
        "video/x-flv"
        "video/x-theora"
        "video/x-theora+ogg"
        "video/x-matroska"
        "video/mkv"
        "audio/x-matroska"
        "application/x-matroska"
        "video/webm"
        "audio/webm"
        "audio/vorbis"
        "audio/x-vorbis"
        "audio/x-vorbis+ogg"
        "video/x-ogm"
        "video/x-ogm+ogg"
        "application/x-ogm"
        "application/x-ogm-audio"
        "application/x-ogm-video"
        "application/x-shorten"
        "audio/x-shorten"
        "audio/x-ape"
        "audio/x-wavpack"
        "audio/x-tta"
        "audio/AMR"
        "audio/ac3"
        "audio/eac3"
        "audio/amr-wb"
        "video/mp2t"
        "audio/flac"
        "audio/mp4"
        "application/x-mpegurl"
        "video/vnd.mpegurl"
        "application/vnd.apple.mpegurl"
        "audio/x-pn-au"
        "video/3gp"
        "video/3gpp"
        "video/3gpp2"
        "audio/3gpp"
        "audio/3gpp2"
        "video/dv"
        "audio/dv"
        "audio/opus"
        "audio/vnd.dts"
        "audio/vnd.dts.hd"
        "audio/x-adpcm"
        "application/x-cue"
        "audio/m3u"
      ];

      ### IMAGE VIEWER ###
      "lximage-qt" = [
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/jpg"
        "image/png"
        "image/tiff"
        "image/x-bmp"
        "image/x-pcx"
        "image/x-tga"
        "image/x-portable-pixmap"
        "image/x-portable-bitmap"
        "image/x-targa"
        "image/x-portable-greymap"
        "application/pcx"
        "image/svg+xml"
        "image/svg-xml"
      ];
    };
  in {
    enable = true;
    associations.added = associations;
    defaultApplications = associations;
  };
}
