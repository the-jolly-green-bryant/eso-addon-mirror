Containerz = Containerz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "ロード済み",
    NOT_LOADED = "ロードされていません",
    
    OPEN_ALL_CONTAINERZ = "すべてのコンテナを開く",
    STOP_OPENING_CONTAINERZ = "コンテナの開封を停止する",
    WILL_OPEN = " %s を 1 つ開く",
    WONT_OPEN = " %s を 1 つ開かない",

    TRANSMUTES_NAME = "変換クリスタルの制限を超えない",
    TRANSMUTES_TOOLTIP = "変換ジオードによって変換クリスタルの制限である 1000 を超える可能性がある場合は、そのジオードを自動的に開かない",
    GLADIATORS_NAME = "1 日に 1 つのアリーナ グラディエーターのリュックサックを開く",
    GLADIATORS_TOOLTIP = "1 日に 1 回だけアリーナ グラディエーターのリュックサックを開くとアリーナ グラディエーターの証が手に入るため、1 日に 1 回だけ自動的に開く",
    SIEGEMASTERS_NAME = "攻城兵の貴重品箱を 1 つだけ開く1日あたり",
    SIEGEMASTERS_TOOLTIP = "攻城兵器長の貴重品箱を開けるとシロディールの攻城兵器の功績を1日1回だけ獲得できるので、1日1回だけ自動的に開けるようにしてください",
    SCROLLKEEPERS_NAME = "1 日に 1 つのスクロール キーパー リュックサックのみを開けます",
    SCROLLKEEPERS_TOOLTIP = "1 日に 1 回のみスクロール キーパー リュックサックを開けたときに巻物を受け取ることができるため、1 日に 1 つだけ自動的に開けます",
    
    GLADIATORS_VERIFY = "今日、グラディエーターリュックサックを開けましたか?\n覚えていない場合は、「はい」と答えてください。",
    SIEGEMASTERS_VERIFY = "今日、シージマスターの貴重品箱を開けましたか?\n覚えていない場合は、「はい」と答えてください。",
}

if Containerz.Localization and #localization == #Containerz.Localization then
    ZO_ShallowTableCopy(localization, Containerz.Localization)
end