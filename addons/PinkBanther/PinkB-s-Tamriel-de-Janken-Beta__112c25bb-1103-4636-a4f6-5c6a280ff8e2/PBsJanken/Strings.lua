PBJ = PBJ or {}
local ja = {
    eyebrow="TAMRIEL · A MOMENT BETWEEN ADVENTURES",
    trainingPartner="練習相手", remaining="残り %d 秒", noHand="未選択",
    timeLoss="時間切れで、あなたの負けです。", timeWin="相手が時間切れのため、あなたの勝ちです！",
    bothTimeLoss="双方が時間切れです。双方とも負けになります。",
    timeLossPending="時間切れで、あなたの負けです。相手の結果を確認しています…",
    noDiagnostic="記録された通信エラーはありません。",
    title="タムリエル de じゃんけん", subtitle="冒険の合間に、じゃんけんを。", menu="タムリエル de じゃんけん",
    rock="グー", paper="パー", scissors="チョキ", hidden="未公開", you="あなた", opponent="対戦相手",
    idle="対人インタラクトメニューからグループの相手を選んでください。", inviting="対戦を申し込みました。相手の承諾を待っています…",
    invited="じゃんけんのお誘いが届きました。承諾すると手を選べます。", choosing="出す手を選んでください。選択後は変更できません。",
    locked="手を確定しました。相手の選択を待っています…", win="あなたの勝ち！", lose="あなたの負け", draw="あいこ！",
    accept="対戦を承諾", again="もう一度遊ぶ", close="閉じる", cancel="中止", decline="辞退",
    cancelled="対戦を中止しました。", peerCancelled="相手が対戦を中止しました。", timeout="時間切れです。双方でアドオンが有効か確認してください。",
    unavailable="相手が不在・通信制限中、または戦闘が始まったため中止しました。",
    invalidReveal="手の照合に失敗しました。この対戦は戦績に含めません。", sendFailed="送信できませんでした。LibGroupBroadcastの設定を確認してください。",
    groupRequired="双方でPB's Tamriel de Jankenを有効にし、同じグループに参加してください。",
    missingLibrary="オンライン対戦には双方でLibGroupBroadcastの導入・有効化が必要です。",
    protocolFailed="通信の初期化に失敗しました。詳細確認：/pbj debug。練習：/pbj practice",
    busy="進行中の対戦を終えるか、中止してください。", practice="練習モード • ローカル対戦", online="グループ対戦",
    rules="グーはチョキに勝つ  •  チョキはパーに勝つ  •  パーはグーに勝つ",
    stats="勝ち %d   負け %d   あいこ %d", practiceHint="/pbj practice：練習   /pbj：対戦画面を表示",
}
function PBJ.Text(key)
    return ja[key] or key
end
