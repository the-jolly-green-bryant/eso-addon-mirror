-------------------------------------------
-- jp - 日本語:japanese
-- Author: BowmoreLover
-------------------------------------------
cl.ln = {
    com = {
        show = "表示",
        midnight = "真夜中",
        sunrise = "日の出",
        noon = "正午",
        sunset = "日没",
        reset = "リセット",
        resetTxt = "Clockをリセットしました。",
        resetui = "UIのリセット",
        resetUITxt = "ClockのUIをリセットしました。",
        resettime = "時間のリセット",
        resetTimeTxt = "Clockの時間をリセットしました。",
        us = "us",
        usOn = "時間は午前/午後の12時間表記となります。",
        usOff = "時間は24時間表記となります。",
        num = "num",
        numOn = "足りない桁をゼロで埋めます。",
        numOff = "足りない桁をゼロで埋めません。",
        sec = "sec",
        secOn = "秒数を表示します。",
        secOff = "秒数を表示しません。",
        active = "active",
        activeOn = "Clock - TST はオンです。",
        activeOff = "Clock - TST はオフです。",
        move = "move",
        moveOn = "Clockは移動可能です。",
        moveOff = "Clockは固定されました。",
        moon = "moon",
        moonOn = "月を表示します。",
        moonOff = "月を表示しません。",
        ldate = "gdate",
        ldateOn = "伝承の日付を表示します。",
        ldateOff = "伝承の日付を表示しません。",
        fldate = "fldate",
        fldateOn = "偽伝承の日付を表示します。",
        fldateOff = "偽伝承の日付を表示しません。",
        rt = "rt",
        rtOn = "実時間を表示します。",
        rtOff = "実時間を表示しません。",
        date = "date",
        dateOn = "日付を表示します。",
        dateOff = "日付を表示しせん。",
        text = "|cFFD700Clock|r - TST by |c5175ea@Tyx|r [EU] のヘルプメニューにようこそ\n"
                .. "現在のデータベース時間を表示するには:\n"
                .. "\t\cl show\n"
                .. "現在の時間をタムリエルの真夜中/日の出/正午/日没に設定するには:\n"
                .. "\t\cl midnight\n\t\cl sunrise\n\t\cl noon\n\t\cl sunset\n"
                .. "現在のデータベースをリセットし、見た目や時間をデフォルト値にリセットするには:\n"
                .. "\t\cl reset\n\t\cl resetUI\t\cl resetTime\n"
                .. "時間の表示形式(12時間/24時間)を切り替えるには:\n"
                .. "\t\cl us\n"
                .. "1桁の時間の前に追加されたゼロを削除するには:\n"
                .. "\t\cl num\n"
                .. "秒数の表示有無を切り替えるには:\n"
                .. "\t\cl sec\n"
                .. "現在の月齢を表示するには:\n"
                .. "\t\cl moon\n"
                .. "日付(伝承/偽伝承/実)を表示するには:\n"
                .. "\t\cl ldate\n\t\cl fldate\t\cl date\n"
                .. "Clockを移動可能/固定するには:\n"
                .. "\t\cl move\n"
                .. "Clockの使用を無効化/有効化するには:\n"
                .. "\t\cl active\n\n"
                .. "設定メニューを表示するには:\n"
                .. "\t\clsettings\n",
    },
    gui = {
        com = "/clsettings",
        -- Language
        lang = "言語",
        langTxt = "Clockの設定画面とコマンドの言語を選択します。\n 警告: UIをリロードします。",
        -- Toggle
        togOpt = "設定のオン/オフ",
        togOptTxt = "Clockの見た目を変更します。",
        sClock = "Clockの表示",
        sTime = "時間の表示",
        sMove = "移動可能",
        tMove = "Clockが移動可能になります。",
        sAHide = "自動的に隠す",
        tAHide = "メニューを開くとClockが非表示になります。",
        sFormat = "12時間形式",
        sAMPM = "午前/午後の表示",
        sJap = "真夜中を0時として表示",
        sNum = "ゼロ追加",
        tNum = "1桁の数字にゼロを追加します: 1:24 -> 01:24",
        sSec = "秒数の表示",
        sMoon = "月齢の表示",
        tMoon = "現在の月齢を示す小さなアイコンと次の月相までの時間を表示します。",
        sLDate = "伝承の日付を表示",
        tLDate = "Clockにタムリエル日付の表示行を追加します。",
        sFLDate = "偽伝承の日付を表示",
        tFLDate = "Clockにタムリエル日付の表示行を追加します。",
        sRT = "実時間の表示",
        tRT = "ClockにOS時間の表示行を追加します。",
        sDate = "実日付の表示",
        tDate = "ClockにOS日付の表示行を追加します。",
        nsBg = "背景の表示",
        tsBg = "Clockの背景を追加します。",
        -- Look
        look = "見た目のオプション",
        lookTxt = "Clockの見た目を変更する様々なオプションです。",
        nColPick = "色",
        tColPick = "Clockの色を変更します。",
        nFont = "フォント",
        tFont = "Clockのフォントを変更します。",
        nStyle = "スタイル",
        tStyle = "Clockのスタイルを変更します。",
        nSize = "サイズ",
        tSize = "Clockのサイズを変更します。",
        nMoonStyle = "ムーンスタイル",
        tMoonStyle = "ムーンラベルのスタイルを変更します。",
        nMoonSize = "ムーンサイズ",
        tMoonSize = "表示される時刻のサイズを次の月の段階に変更します。",
        dMoonSize = "Clock |cFFA4000.7.9|r\n月のサイズと時間のサイズを別々に変更することが可能になりました。 設定メニュー（設定 - >アドオン - >Clock）で確認してください。\nClock |cFFA4000.7.9|rを使用していただきありがとうございます :)",
        nMoonOffsetY = "月のyオフセット",
        tMoonOffsetY = "月を垂直方向に移動します。",
        --real
        nSepLR = "別の見た目",
        tSepLR = "実日付を伝承の日付と異なる見た目にします。",
        nRColPick = "色",
        tRColPick = "Clockの色を変更します。",
        nRFont = "フォント",
        tRFont = "Clockのフォントを変更します。",
        nRStyle = "スタイル",
        tRStyle = "Clockのスタイルを変更します。",
        nRSize = "サイズ",
        tRSize = "Clockのサイズを変更します。",
        nBg = "背景",
        tBg = "Clockの背景を選択します。",
        sHor = "横に並べる",
        tHor = "伝承時間と実時間を横に並べます。",
        descEditLookY = "Clockの表示形式を変更します。変数の前に '_' を付けてください！\n"
                .. "年/月/日",
        descEditLookYTxt = "年: Y = 582 (14)\tYY = 2E 582 (2014)\n"
                .. "月: M = 4\tMM = 04\tMMM = 恵雨の月 (4月)\n"
                .. "日: D = 4\tDD = 04\tDDD = フレダス (金曜日)",
        descEditLookD = "時/分/秒",
        descEditLookDTxt = "時: h = 9\thh = 09\n"
                .. "分: m = 9\tmm = 09\n"
                .. "秒: s = 9\tss = 09",
        descEditLookE = "例",
        descEditLookETxt = "_YY年 _MMM _D日 _DDD _hh:_mm:_ss\n"
                .. "2E 582年 恵雨の月 4日 金曜日\n"
                .. "2014年 4月 4日 金曜日",
        nELore = "伝承時間の表示形式",
        tELore = "伝承時間の表示形式をここに記述します。",
        nEReal = "実時間の表示形式",
        tEReal = "実時間の表示形式をここに記述します。",
        -- Data
        day = "同期 [日]",
        dayTxt = "好みに合わせて一日の長さを調整します。",
        descDB = "同期 [真夜中/日の出/正午/日没]",
        descDBTxt = "Clockの時間を同期します。\n例えば、太陽がコンパスの南針にある場合は正午を選択します。",
        nMid = "今は真夜中だ！",
        tMid = "月が最高点にある場合はこれを選択します。",
        nRise = "今は日の出だ！",
        tRise = "非推奨です！ 日の出はとても曖昧です。正午を使ってください！",
        nNoon = "今は正午だ！",
        tNoon = "太陽がコンパスの南針にある場合はこれを選択します。",
        nSet = "今は日没だ！",
        tSet = "非推奨です！ 日没はとても曖昧です。正午を使ってください！",
        descDS = "同期 [一日の長さ]",
        descDSTxt = "Clockの一日の長さを同期します。",
        nDayH = "時",
        tDayH = "ゲーム内の一日がどれだけの実時間に相当するか(時)。",
        nDayM = "分",
        tDayM = "ゲーム内の一日がどれだけの実時間に相当するか(分)。",
        nDayS = "秒",
        tDayS = "ゲーム内の一日がどれだけの実時間に相当するか(秒)。",
        nAplyData = "計算",
        tAplyData = "選択した一日の長さと同期した(またはデフォルトの)開始時間を元に、タムリエルにおける現在時刻を計算します。",
        -- Moon
        moon = "同期 [月齢]",
        moonTxt = "好みに合わせて月齢の始まりと各月相の長さを調整します。",
        nFull = "今は満月だ！",
        tFull = "満月の始まりの場合はこれを選択します。",
        nNew = "今は新月だ！",
        tNew = "新月の始まりの場合はこれを選択します。",
        descMS = "同期 [月齢]",
        descMSTxt = "Clockの月齢を同期します。\n各月相の始まりに実行してください。",
        descMoon = "同期 [各月相の長さ]",
        descMoonTxt = "満月または新月のときに一度だけClockを同期する必要があります。\n"
                .. "月齢の周期はゲーム内の30日です。以下のスライダーで各月相の割合を選択します。",
        nNightF = "満月の日数(割合)",
        tNightF = "満月の終わりまでの長さを選択します。",
        nNightW = "下弦/上弦の日数(割合)",
        tNightW = "下弦/上弦の終わりまでの長さを選択します。",
        nNightN = "新月の日数(割合)",
        tNightN = "新月の終わりまでの長さを選択します。",
        nAplyMoon = "計算",
        tAplyMoon = "選択した長さと同期した(またはデフォルトの)開始時間を元に現在の月齢を計算します。",
        -- Reset
        reset = "リセットオプション",
        resetTxt = "Clock全体または一部をリセットする様々なオプションです。",
        nResFull = "全てリセット",
        tResFull = "全てをデフォルト値にリセットします。",
        wResFull = "カスタマイズ内容はすべてデフォルト値に置き換えられます！\nUIをリロードします！",
        nResUI = "UIのリセット",
        tResUI = "Clockの見た目と位置をデフォルト値にリセットします。",
        wResUI = "UIに関するカスタマイズ内容はデフォルト値に置き換えられます！",
        nResTime = "時間のリセット",
        tResTime = "カスタイマイズしたClockの同期点と長さをデフォルト値にリセットします。",
        wResTime = "時間に関するカスタマイズ内容はデフォルト値に置き換えられます！\nUIをリロードします！",
        nDeprecated = "Outdated version ",
        tDeprecated = "This is an outdated version of Clock.\n"
                .. "Most likely it will still work for a very long time, but I will not update it anymore.\n"
                .. "However, I wrote a whole new version from scratch, which is nicer and eats less power.",
    },
    vi = {
        dbTS = {
            [1] = "真夜中 (0:00 TST) まで後 ",
            [2] = "日の出 (4:00 TST) まで後 ",
            [3] = "正午 (12:00 TST) まで後 ",
            [4] = "日没 (20:00 TST) まで後 ",
            [5] = "一日の長さは ",
            [6] = "\n",
        },
        date = {
            first = "",
            second = "",
            third = "",
            allNum = "",
            lore = {
                week = {
                    [1] = "モーンダス",
                    [2] = "ティルダス",
                    [3] = "ミダス",
                    [4] = "トゥルダス",
                    [5] = "フレダス",
                    [6] = "ロレダス",
                    [7] = "サンダス",
                },
                months = {
                    [1] = "暁星の月",
                    [2] = "薄明の月",
                    [3] = "蒔種の月",
                    [4] = "恵雨の月",
                    [5] = "栽培の月",
                    [6] = "真央の月",
                    [7] = "南中の月",
                    [8] = "収穫の月",
                    [9] = "炉火の月",
                    [10] = "降霜の月",
                    [11] = "黄昏の月",
                    [12] = "星霜の月",
                },
                year = "2E ",
            },
            real = {
                week = {
                    [1] = "月曜日",
                    [2] = "火曜日",
                    [3] = "水曜日",
                    [4] = "木曜日",
                    [5] = "金曜日",
                    [6] = "土曜日",
                    [7] = "日曜日",
                },
                months = {
                    [1] = "1月",
                    [2] = "2月",
                    [3] = "3月",
                    [4] = "4月",
                    [5] = "5月",
                    [6] = "6月",
                    [7] = "7月",
                    [8] = "8月",
                    [9] = "9月",
                    [10] = "10月",
                    [11] = "11月",
                    [12] = "12月",
                },
            },
        },
    },
}
