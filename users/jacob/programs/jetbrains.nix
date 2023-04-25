{ pkgs, ... }:
let
  ja-netfilter = pkgs.ja-netfilter.override {
    programName = "jetbrains";
    enabledPlugins = [ "dns" "url" "hideme" "power" ];
    pluginConfigs = {
      dns = ''
        [DNS]
        EQUAL,jetbrains.com
        EQUAL,plugin.obroom.com
      '';
      url = ''
        [URL]
        PREFIX,https://account.jetbrains.com/lservice/rpc/validateKey.action
      '';
      power = ''
        [Result]
        ; Suit 220801
        EQUAL,108391492724719606277191711676038310454333436786970899072879934267610324870870961974305689698304529291751931883693569275416671653649715395540162187908455880751887548211257780817773830153477469379663893839249632010489688404104740814832791608983255964373246023808678041003248593298915323068020141515280275870731964298697511434302901212533563571472947179437111243030002421474283363073021442715554541318313064598900684758246291687123240210640543678544269324094608551763049140564128299834843381841274260516105408318037686490277144538983963856617365418526798235932271319705894170543971766101775628884107261100637290512593943587295268337137890353216997114446658051251047509442298463526766678103653729776506979657957966027949436493606289520405331110453990512846697802196701678785414928082416405650857741201229183421400567636999723106788808933737428330992184832395299929033666381663232693108552887968738513151493044369308652310586803160326722967115451573652070286501044484503083240302303438554529551204609089966636092666792347623413483134664670641246129954999815529917163967761617333572567787618346281658716181608204191963817312534492517480248086896060880038259592723773361709406277837609546030729611710076711450268767610513506889086815865283,65537,860106576952879101192782278876319243486072481962999610484027161162448933268423045647258145695082284265933019120714643752088997312766689988016808929265129401027490891810902278465065056686129972085119605237470899952751915070244375173428976413406363879128531449407795115913715863867259163957682164040613505040314747660800424242248055421184038777878268502955477482203711835548014501087778959157112423823275878824729132393281517778742463067583320091009916141454657614089600126948087954465055321987012989937065785013284988096504657892738536613208311013047138019418152103262155848541574327484510025594166239784429845180875774012229784878903603491426732347994359380330103328705981064044872334790365894924494923595382470094461546336020961505275530597716457288511366082299255537762891238136381924520749228412559219346777184174219999640906007205260040707839706131662149325151230558316068068139406816080119906833578907759960298749494098180107991752250725928647349597506532778539709852254478061194098069801549845163358315116260915270480057699929968468068015735162890213859113563672040630687357054902747438421559817252127187138838514773245413540030800888215961904267348727206110582505606182944023582459006406137831940959195566364811905585377246353->31872219281407242025505148642475109331663948030010491344733687844358944945421064967310388547820970408352359213697487269225694990179009814674781374751323403257628081559561462351695605167675284372388551941279783515209238245831229026662363729380633136520288327292047232179909791526492877475417113579821717193807584807644097527647305469671333646868883650312280989663788656507661713409911267085806708237966730821529702498972114194166091819277582149433578383639532136271637219758962252614390071122773223025154710411681628917523557526099053858210363406122853294409830276270946292893988830514538950951686480580886602618927728470029090747400687617046511462665469446846624685614084264191213318074804549715573780408305977947238915527798680393538207482620648181504876534152430149355791756374642327623133843473947861771150672096834149014464956451480803326284417202116346454345929350148770746553056995922154382822307758515805142704373984019252210715650875853634697920708113806880196144197384637328982263167395073688501517286678083973976140696077590122053014085412828620051470085033364773099146103525313018873319293728800442101520384088109603555959893639842091339193857485407672132882577840295039058621747654642202620767068924079813640067442975
        EQUAL,17430805040661904960217142128786500464864043257152786846745016761637330023130385628907046448630022920796670427977354189343808215815509511917604813946812068613694491683253995133209152077919891234968182248857838898199644443355241219225726139665337883043072574125580003765750846684062985504854965420309681346496007525845855594591340548416511522780366831902271789348331613580937547169576595371827264137623285493327295900285658920185041209960394118635722087939857728650109349728410946091579960723986601084785767630072314151995336592750869439606211427735380846313426999664229383327948871862419128418990267247800060898233458,65537,24521566609765666164947017540032021599255701751860227819512057581863724253675446227963662825786216373422117712052647819939094618512591273903731385388945941620956494535886991119537555521717683289574562412249381695575366776196301290570457146763799416784211789775179394339350479765228864277544252534115220169733628333836919758657866915165201332480467127194998195481209996470680276955438320553419743409285076366446411459237915876713514676197204668785300100857270615348770478845912795954436677863461158442534283102154396294509903255539003316675136070586165787963286744036831353098283719024130881707718857451774498022915819->986236757547332986472011617696226561292849812918563355472727826767720188564083584387121625107510786855734801053524719833194566624465665316622563244215340671405971599343902468620306327831715457360719532421388780770165778156818229863337344187575566725786793391480600129482653072861971002459947277805295727097226389568776499707662505334062639449916265137796823793276300221537201727072401742985542559596685092673521228140822200236743113743661549252453726123450722876929538747702356573783116366629850199080495560991841329893037291900147497007197055572787780928474439122050029863368156328679013185403585508633386797793

        [Args]
        EQUAL,65537,24773058818499217187577663886010908531303294206336895556072197892590450942803807164562754911175164262596715237551312004078542654996496301487027034803410086499747369353221485073240039340641397198525027728751956658900801359887190562885573922317930300068615009483578963467556425525328780085523172495307229112069939166202511721671904748968934606589702999279663332403655662225374084460291376706916679151764149324177444374590606643838366605181996272409014933080082205048098737253668016260658830645459388519595314928290853199112791333551144805347785109465401055719331231478162870216035573012645710763533896540021550083104281->3,24773058818499217187577663886010908531303294206336895556072197892590450942803807164562754911175164262596715237551312004078542654996496301487027034803410086499747369353221485073240039340641397198525027728751956658900801359887190562885573922317930300068615009483578963467556425525328780085523172495307229112069939166202511721671904748968934606589702999279663332403655662225374084460291376706916679151764149324177444374590606643838366605181996272409014933080082205048098737253668016260658830645459388519595314928290853199112791333551144805347785109465401055719331231478162870216035573012645710763533896540021550083104281
      '';
    };
  };
  javaAgentJar = "${ja-netfilter}/share/ja-netfilter/ja-netfilter.jar";
  vmopts = ''
    --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED
    --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED
    -javaagent:${javaAgentJar}=jetbrains
  '';
in {
  clion = {
    home.packages = [ (pkgs.jetbrains.clion.override { inherit vmopts; }) ];
  };
  goland = {
    home.packages = [ (pkgs.jetbrains.goland.override { inherit vmopts; }) ];
  };
  webstorm = {
    home.packages = [ (pkgs.jetbrains.webstorm.override { inherit vmopts; }) ];
  };
  idea = {
    home.packages =
      [ (pkgs.jetbrains.idea-ultimate.override { inherit vmopts; }) ];
  };
  pycharm = {
    home.packages =
      [ (pkgs.jetbrains.pycharm-professional.override { inherit vmopts; }) ];
  };
}
