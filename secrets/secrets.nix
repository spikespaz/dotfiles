let
  jacob = {
    jacob-thinkpad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHK69yW51FZuJB9MuLY/qzcVp/yXK/7DaFliqjYN/Ad7 jacob@jacob-thinkpad";
  };
in {
  "jacob.spotifyd.age".publicKeys = builtins.attrValues jacob;
}
