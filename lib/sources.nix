{ lib }:
let
  sourceFilter = fn: sourceRoot: name: type:
    let
      baseName = baseNameOf name;
      pathPrefix = toString sourceRoot;
      relPath = lib.removePrefix pathPrefix name;
      atRoot = builtins.match "^/[^/]*/?$" relPath != null;
      isFile = type == "regular";
      isDir = type == "directory";
      isLink = type == "symlink";
      extMatch = builtins.match "^.*(\\..+)$" name;
      extension = if extMatch != null then builtins.elemAt extMatch 0 else null;
    in lib.applyAutoArgs fn {
      inherit name type baseName relPath atRoot isFile isDir isLink extension;
    };

  # Compose multiple filters into one, suitable for `lib.cleanSourceWith`.
  # The first argument is the source root, and the second is a list of filters.
  # The filters are expected to take the source root as the first argument,
  # which means this function is not compatible with `lib.cleanSourceFilter`.
  # Use the other pre-made filters instead.
  mkSourceFilter = sourceRoot: filters: name: type:
    builtins.all (fn: fn sourceRoot name type) filters;

  defaultSourceFilter = sourceRoot:
    mkSourceFilter sourceRoot [
      unknownSourceFilter
      objectSourceFilter
      vcsSourceFilter
      editorSourceFilter
      flakeSourceFilter
    ];

  # Filter out sockets and other types of files we can't have in the store.
  unknownSourceFilter = sourceFilter ({ type }: !(type == "unknown"));

  objectSourceFilter = sourceFilter ({ isFile, extension }:
    !(isFile && builtins.elem extension [ ".o" ".so" ]));

  # Removes directories for version control systems at any
  # level of nested paths.
  vcsSourceFilter = sourceFilter ({ baseName, isDir }:
    !(
      # Git
      (isDir && baseName == ".git")
      # Apache Subversion
      || (isDir && baseName == ".svn")
      # Mercurial
      || (isDir && baseName == ".hg")
      # Concurrent Versions System
      || (isDir && baseName == "CVS")));

  editorSourceFilter = sourceFilter ({ baseName, isDir }:
    !(
      # Visual Studio Code
      (isDir && baseName == ".vscode")
      # JetBrains
      || (isDir && baseName == ".idea")
      # Eclipse
      || (isDir && baseName == ".eclipse")
      # Backup / swap files
      || (lib.hasSuffix "~" baseName)
      || (builtins.match "^\\.sw[a-z]$" baseName != null)
      || (builtins.match "^\\..*\\.sw[a-z]$" baseName != null)));

  flakeSourceFilter = sourceFilter
    ({ baseName, atRoot, relPath, isDir, isFile, isLink, extension }:
      !(
        # A very common convention is to have a directory for Nix files.
        (atRoot && isDir && baseName == "nix")
        # Also don't want any Nix files in the root.
        # Others might be examples or included,
        # if a project is properly organized they won't be anywhere besides
        # the root anyway.
        || (atRoot && isFile && extension == ".nix")
        # And of course, the `flake.lock`.
        || (atRoot && isFile && baseName == "flake.lock")
        # Filter out `nix-build` result symlinks.
        || (isLink && lib.hasPrefix "result" baseName)));

  # Removes directories that Cargo generates.
  # This filter is careful and will only remove matching names
  # in the source root, but not similarly-named nested paths.
  rustSourceFilter = sourceFilter ({ baseName, atRoot, isDir }:
    !(atRoot && isDir && baseName == "target"));

  # cleanSourceFilter = name: type:
  #   let baseName = baseNameOf (toString name);
  #   in !(
  #     # Filter out version control software files/directories
  #     (baseName == ".git" || type == "directory"
  #       && (baseName == ".svn" || baseName == "CVS" || baseName == ".hg")) ||
  #     # Filter out editor backup / swap files.
  #     lib.hasSuffix "~" baseName || builtins.match "^\\.sw[a-z]$" baseName
  #     != null || builtins.match "^\\..*\\.sw[a-z]$" baseName != null ||

  #     # Filter out generates files.
  #     lib.hasSuffix ".o" baseName || lib.hasSuffix ".so" baseName ||
  #     # Filter out nix-build result symlinks
  #     (type == "symlink" && lib.hasPrefix "result" baseName) ||
  #     # Filter out sockets and other types of files we can't have in the store.
  #     (type == "unknown"));
in {
  inherit sourceFilter mkSourceFilter defaultSourceFilter unknownSourceFilter
    objectSourceFilter vcsSourceFilter editorSourceFilter flakeSourceFilter
    rustSourceFilter;
}
