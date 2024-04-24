{ lib, pkgs, ... }:
let inherit (pkgs.nur.repos.rycee) firefox-addons;
in {
  # this nix configuration requires two extensions
  programs.firefox.profiles."jacob.default".extensions = with firefox-addons; [
    ublock-origin
  ];

  # this file adds default user settings to uBlock Origin's config
  # it is pre-configured to use Steven Black's Unified Hosts
  # as an extra filter list,
  # along with special rules for LocalCDN.
  # <https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin>
  #
  # note that LocalCDN expects two more rules:
  #  - `* * 3p-script block`
  #  - `* * 3p-frame block`
  #
  # these are for uBlock "medium" mode:
  # <https://github.com/gorhill/uBlock/wiki/Blocking-mode:-medium-mode>
  # it is probably not necessary because of the aggregate list that is added,
  # and it is definitely not worth breaking sites for your average user.
  home.file.".mozilla/managed-storage/uBlock0@raymondhill.net.json".text =
    builtins.toJSON {
      name = "uBlock0@raymondhill.net";
      description = "ignored";
      type = "storage";
      data = let
        stevenBlackHosts =
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        defaultFilteringString = ''
          behind-the-scene * * noop
          behind-the-scene * 1p-script noop
          behind-the-scene * 3p noop
          behind-the-scene * 3p-frame noop
          behind-the-scene * 3p-script noop
          behind-the-scene * image noop
          behind-the-scene * inline-script noop
        '';
        localcdnFilteringString = ''
          * ajax.googleapis.com * noop
          * ajax.aspnetcdn.com * noop
          * ajax.microsoft.com * noop
          * cdnjs.cloudflare.com * noop
          * code.jquery.com * noop
          * cdn.jsdelivr.net * noop
          * fonts.googleapis.com * noop
          * yastatic.net * noop
          * yandex.st * noop
          * apps.bdimg.com * noop
          * libs.baidu.com * noop
          * cdn.staticfile.org * noop
          * cdn.bootcss.com * noop
          * mat1.gtimg.com * noop
          * lib.sinaapp.com * noop
          * upcdn.b0.upaiyun.com * noop
          * stackpath.bootstrapcdn.com * noop
          * maxcdn.bootstrapcdn.com * noop
          * netdna.bootstrapcdn.com * noop
          * use.fontawesome.com * noop
          * ajax.cloudflare.com * noop
          * akamai-webcdn.kgstatic.net * noop
          * gitcdn.github.io * noop
          * vjs.zencdn.net * noop
          * cdn.plyr.io * noop
          * cdn.materialdesignicons.com * noop
          * cdn.ravenjs.com * noop
          * js.appboycdn.com * noop
          * cdn.embed.ly * noop
          * cdn.datatables.net * noop
          * mathjax.rstudio.com * noop
          * cdn.mathjax.org * noop
          * code.createjs.com * noop
          * sdn.geekzu.org * noop
          * ajax.proxy.ustclug.org * noop
          * unpkg.com * noop
          * pagecdn.io * noop
          * cdnjs.loli.net * noop
          * ajax.loli.net * noop
          * fonts.loli.net * noop
          * lib.baomitu.com * noop
          * cdn.bootcdn.net * noop
          * fonts.gstatic.com * noop
          * ajax.loli.net.cdn.cloudflare.net * noop
          * akamai-webcdn.kgstatic.net.edgesuite.net * noop
          * apps.bdimg.jomodns.com * noop
          * cdn.bootcdn.net.maoyundns.com * noop
          * cdn.bootcss.com.maoyundns.com * noop
          * cdn.embed.ly.cdn.cloudflare.net * noop
          * cdn.jsdelivr.net.cdn.cloudflare.net * noop
          * cdnjs.loli.net.cdn.cloudflare.net * noop
          * cds.s5x3j6q5.hwcdn.net * noop
          * developer.n.shifen.com * noop
          * dualstack.osff.map.fastly.net * noop
          * fonts.loli.net.cdn.cloudflare.net * noop
          * gateway.cname.ustclug.org * noop
          * gstaticadssl.l.google.com * noop
          * iduwdjf.qiniudns.com * noop
          * lb.sae.sina.com.cn * noop
          * lib.baomitu.com.qh-cdn.com * noop
          * mat1.gtimg.com.tegsea.tc.qq.com * noop
          * materialdesignicons.b-cdn.net * noop
          * mscomajax.vo.msecnd.net * noop
          * sdn.inbond.gslb.geekzu.org * noop
          * use.fontawesome.com.cdn.cloudflare.net * noop
          * vo.aicdn.com * noop
        '';
      in {
        adminSettings = builtins.toJSON {
          userSettings = {
            advancedUserEnabled = true;
            dynamicFilteringEnabled = true;
            externalLists = lib.concatStringsSep "\n" [ stevenBlackHosts ];
            importedLists = [ stevenBlackHosts ];
          };
          selectedFilterLists = [
            # Built-in
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            # Ads
            "easylist"
            # Privacy
            "adguard-spyware"
            "adguard-spyware-url"
            "easyprivacy"
            # Malware domains
            "urlhaus-1"
            "curben-phishing"
            "curben-pup"
            # Annoyances
            "adguard-annoyance"
            "adguard-cookies"
            "adguard-mobile-app-banners"
            "adguard-popup-overlays"
            "adguard-social"
            "fanboy-thirdparty_social"
            "fanboy-cookiemonster"
            "fanboy-annoyance"
            "fanboy-social"
            "ublock-annoyances"
            "easylist-newsletters"
            # Multipurpose
            "dpollock-0"
            "plowe-0"
            # Custom
            stevenBlackHosts
          ];
          dynamicFilteringString = ''
            ${defaultFilteringString}
            ${localcdnFilteringString}
          '';
        };
      };
    };
}
