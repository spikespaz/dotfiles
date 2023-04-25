let
  jacob-thinkpad = {
    root =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtXAJRcYBrVT8qAoc+bq6ZoPr3ehypwx0BohKv8HWMF root@jacob-thinkpad";
    jacob =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHK69yW51FZuJB9MuLY/qzcVp/yXK/7DaFliqjYN/Ad7 jacob@jacob-thinkpad";
  };

  root = [ jacob-thinkpad.root ];
  users = [ jacob-thinkpad.jacob ];
in {
  "root.pia.age".publicKeys = root;
  "jacob.spotifyd.age".publicKeys = users;
}
