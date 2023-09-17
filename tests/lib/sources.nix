{ lib }:
let src = "/some/source/root";
in {
  defaultSourceFilter = [
    {
      name = "allow regular file";
      expr = lib.defaultSourceFilter src "${src}/file.txt" "regular";
      expect = true;
    }
    {
      name = "allow directory";
      expr = lib.defaultSourceFilter src "${src}/directory" "directory";
      expect = true;
    }
    {
      name = "allow directory ending with slash";
      expr = lib.defaultSourceFilter src "${src}/directory/" "directory";
      expect = true;
    }
    {
      name = "deny unknown";
      expr = lib.defaultSourceFilter src "${src}/program.sock" "unknown";
      expect = false;
    }
    {
      name = "deny object file";
      expr = lib.defaultSourceFilter src "${src}/library.so" "regular";
      expect = false;
    }
    {
      name = "deny .vscode directory";
      expr = lib.defaultSourceFilter src "${src}/.vscode" "directory";
      expect = false;
    }
    {
      name = "deny nix file";
      expr = lib.defaultSourceFilter src "${src}/flake.nix" "regular";
      expect = false;
    }
  ];
  unknownSourceFilter = [
    {
      name = "allow regular file";
      expr = lib.unknownSourceFilter src "${src}/file.txt" "regular";
      expect = true;
    }
    {
      name = "allow directory";
      expr = lib.unknownSourceFilter src "${src}/directory" "directory";
      expect = true;
    }
    {
      name = "deny unknown";
      expr = lib.unknownSourceFilter src "${src}/program.sock" "unknown";
      expect = false;
    }
  ];
  objectSourceFilter = [
    {
      name = "allow regular file";
      expr = lib.objectSourceFilter src "${src}/file.txt" "regular";
      expect = true;
    }
    {
      name = "allow directory";
      expr = lib.objectSourceFilter src "${src}/directory" "directory";
      expect = true;
    }
    {
      name = "deny object file";
      expr = lib.objectSourceFilter src "${src}/library.so" "regular";
      expect = false;
    }
  ];
  vcsSourceFilter = [
    {
      name = "allow file named .git";
      expr = lib.unknownSourceFilter src "${src}/.git" "regular";
      expect = true;
    }
    {
      name = "deny .git directory";
      expr = lib.unknownSourceFilter src "${src}/.git" "directory";
      expect = false;
    }
    {
      name = "deny nested .git directory";
      expr = lib.unknownSourceFilter src "${src}/subproject/.git" "directory";
      expect = false;
    }
  ];
  editorSourceFilter = [
    {
      name = "allow file named .vscode";
      expr = lib.editorSourceFilter src "${src}/.vscode" "regular";
      expect = true;
    }
    {
      name = "deny .vscode directory";
      expr = lib.editorSourceFilter src "${src}/.vscode" "directory";
      expect = false;
    }
    {
      name = "deny nested .vscode directory";
      expr = lib.editorSourceFilter src "${src}/module/.vscode" "directory";
      expect = false;
    }
    {
      name = "deny backup file";
      expr = lib.editorSourceFilter src "${src}/file.txt~" "regular";
      expect = false;
    }
    {
      name = "deny unnamed swap file";
      expr = lib.editorSourceFilter src "${src}/.swz" "regular";
      expect = false;
    }
    {
      name = "deny swap file";
      expr = lib.editorSourceFilter src "${src}/.file.txt.swz" "regular";
      expect = false;
    }
  ];
  flakeSourceFilter = [
    {
      name = "allow regular file";
      expr = lib.flakeSourceFilter src "${src}/file.txt" "regular";
      expect = true;
    }
    {
      name = "allow nested .nix file";
      expr = lib.flakeSourceFilter src "${src}/modules/something.nix" "regular";
      expect = true;
    }
    {
      name = "allow directory ending with .nix";
      expr = lib.flakeSourceFilter src "${src}/directory.nix" "directory";
      expect = true;
    }
    {
      name = "allow file named result";
      expr = lib.flakeSourceFilter src "${src}/result" "regular";
      expect = true;
    }
    {
      name = "deny nix directory";
      expr = lib.flakeSourceFilter src "${src}/nix" "directory";
      expect = false;
    }
    {
      name = "deny nix file";
      expr = lib.flakeSourceFilter src "${src}/flake.nix" "regular";
      expect = false;
    }
    {
      name = "deny flake.lock";
      expr = lib.flakeSourceFilter src "${src}/flake.lock" "regular";
      expect = false;
    }
    {
      name = "deny result link";
      expr = lib.flakeSourceFilter src "${src}/result" "symlink";
      expect = false;
    }
    {
      name = "deny nested result link";
      expr = lib.flakeSourceFilter src "${src}/packages/result" "symlink";
      expect = false;
    }
  ];
  rustSourceFilter = [
    {
      name = "allow regular file";
      expr = lib.rustSourceFilter src "${src}/file.txt" "regular";
      expect = true;
    }
    {
      name = "allow directory";
      expr = lib.rustSourceFilter src "${src}/directory" "directory";
      expect = true;
    }
    {
      name = "allow file named target";
      expr = lib.rustSourceFilter src "${src}/target" "regular";
      expect = true;
    }
    {
      name = "allow nested target directory";
      expr = lib.rustSourceFilter src "${src}/module/target" "directory";
      expect = true;
    }
    {
      name = "deny target directory";
      expr = lib.rustSourceFilter src "${src}/target" "directory";
      expect = false;
    }
  ];
}
