prev: final:
final.lib.foldl'
(attrs: overlayFile: attrs // ((import overlayFile) final prev)) { }
[ ./rust-lang-rust-analyzer.nix ]
