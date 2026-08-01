LibSlashCommander:AddFile("descriptions/jp.lua", 2, function(lib)
    lib.descriptions = {
        [GetString(SI_SLASH_SCRIPT)] = "指定されたテキストをLuaコードとして実行します",
        [GetString(SI_SLASH_CHATLOG)] = "チャットログの表示を切り替えます",
        [GetString(SI_SLASH_GROUP_INVITE)] = "指定された名前をグループに招待します",
        [GetString(SI_SLASH_JUMP_TO_LEADER)] = "グループリーダーの場所に移動します",
        [GetString(SI_SLASH_JUMP_TO_GROUP_MEMBER)] = "指定されたグループメンバーの場所に移動します",
        [GetString(SI_SLASH_JUMP_TO_FRIEND)] = "指定された友達の場所に移動します",
        [GetString(SI_SLASH_JUMP_TO_GUILD_MEMBER)] = "指定されたギルドメンバーの場所に移動します",
        [GetString(SI_SLASH_RELOADUI)] = "ユーザーインターフェースをリロードします",
        [GetString(SI_SLASH_PLAYED_TIME)] = "このキャラクターでプレイした時間を表示します",
        [GetString(SI_SLASH_READY_CHECK)] = "グループ内で準備チェックを開始します",
        [GetString(SI_SLASH_DUEL_INVITE)] = "指定されたプレイヤーに決闘を挑みます",
        [GetString(SI_SLASH_LOGOUT)] = "キャラクター選択に戻ります",
        [GetString(SI_SLASH_CAMP)] = "キャラクター選択に戻ります",
        [GetString(SI_SLASH_QUIT)] = "ゲームを終了します",
        [GetString(SI_SLASH_FPS)] = "FPS表示を切り替えます",
        [GetString(SI_SLASH_LATENCY)] = "遅延表示を切り替えます",
        [GetString(SI_SLASH_STUCK)] = "立ち往生したキャラクターのためのヘルプ画面を開きます",
        [GetString(SI_SLASH_REPORT_BUG)] = "バグ報告画面を開きます",
        [GetString(SI_SLASH_REPORT_FEEDBACK)] = "フィードバック報告画面を開きます",
        [GetString(SI_SLASH_REPORT_HELP)] = "ヘルプ画面を開きます",
        [GetString(SI_SLASH_REPORT_CHAT)] = "プレイヤー報告画面を開きます",
        [GetString(SI_SLASH_ENCOUNTER_LOG)] = "ログを切り替えます。'?' はオプションを表示します",
    }

    -- エモートとチャット切り替えの説明は types.lua で割り当てられます
end)
