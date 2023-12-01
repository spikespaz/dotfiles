let
  jacob =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHK69yW51FZuJB9MuLY/qzcVp/yXK/7DaFliqjYN/Ad7 jacob";

  intrepid =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtXAJRcYBrVT8qAoc+bq6ZoPr3ehypwx0BohKv8HWMF root@intrepid";

  odyssey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKReH8gif/uzkgG8CaUu6GoVaft9gNhSLLzF36cBT6NX root@odyssey";

  hosts = [ intrepid odyssey ];
  users = [ jacob ];
in {
  "root.pia-user-pass.age".publicKeys = hosts;
  "root.nix-access-tokens-github.age".publicKeys = hosts;
  "jacob.spotifyd.age".publicKeys = users;
}
