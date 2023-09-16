let
  intrepid = {
    root =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtXAJRcYBrVT8qAoc+bq6ZoPr3ehypwx0BohKv8HWMF root@intrepid";
    jacob =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHK69yW51FZuJB9MuLY/qzcVp/yXK/7DaFliqjYN/Ad7 jacob@intrepid";
  };

  root = [ intrepid.root ];
  users = [ intrepid.jacob ];
in {
  "root.pia-user-pass.age".publicKeys = root;
  "root.nix-access-tokens-github.age".publicKeys = root;
  "jacob.spotifyd.age".publicKeys = users;
}
