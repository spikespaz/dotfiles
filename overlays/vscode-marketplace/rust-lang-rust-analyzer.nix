final: prev: {
  vscode-marketplace = prev.vscode-marketplace // {
    rust-lang = prev.vscode-marketplace.rust-lang // {
      rust-analyzer = final.vscode-utils.buildVscodeMarketplaceExtension (let
        extension = {
          lastUpdated = "2023-05-09T00:45:14.083Z";
          name = "rust-analyzer";
          publisher = "rust-lang";
          sha256 = "sha256-VHBxuVz7Dul/yIRnlhep3sKx9qCOOexVjLciBB1c23Y=";
          url =
            "https://rust-lang.gallery.vsassets.io/_apis/public/gallery/publisher/rust-lang/extension/rust-analyzer/0.4.1507/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
          version = "0.4.1507";
        };
      in {
        vsix = final.fetchurl (with extension; {
          inherit url sha256;
          name = "${name}-${version}.zip";
        });
        mktplcRef = { inherit (extension) name version publisher; };
      });
    };
  };
}
