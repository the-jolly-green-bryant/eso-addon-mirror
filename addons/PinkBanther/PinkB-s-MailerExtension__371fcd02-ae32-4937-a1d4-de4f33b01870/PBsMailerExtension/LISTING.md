# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's MailerExtension` there; `## Title` in the manifest does not reach that screen.

---

## Name

PB's MailerExtension

## Overview (JP)

メールに「下書き」「送信済み」「重要」の3つのボックスを追加します。受信箱・送信の隣にタブ
として並び、キーボードUIでもゲームパッドUIでも使えます。書きかけのメールをしまっておき、
送信したメールを記録し、期限切れで消したくない受信メールの本文を期限のない場所へ写します。
（添付アイテムは保存できません。期限内に必ず受け取ってください。）

## Overview (EN)

Adds the three mail boxes the game does not have: Drafts, Sent and Kept. They sit as tabs beside
Inbox and Send, in both the keyboard and the gamepad interface. Put an unfinished letter away
and take it out later; every letter you send is written down as it goes; and a mail you do not
want to lose to the expiry clock can have its text copied somewhere that never expires.
(Attachments cannot be copied -- take those before the mail goes.)

---

## Description (JP)

標準のメールには受信箱と作成画面しかありません。このアドオンは、そこに足りない3つの
ボックスをタブとして追加します。

■ 下書き

　作成画面で「下書きに保存」を押すと、宛先・件名・本文・添付アイテム・添付ゴールドを
　そのまま保存します。「下書き」タブで一覧から選び、作成画面に戻せます。

　添付アイテムは「場所」ではなく「何であったか」で覚えます。復元するときは
　　1. 元のスロット
　　2. 同じスタック（アイテム固有ID）
　　3. 同じ種類（アイテムリンク）
　の順に探すので、バッグの中で動かしていても見つかります。使い切っていて同種が別にあれば
　それを添付します。どうしても無いものは名前を挙げてお知らせします。

■ 送信済み

　ゲーム側は送信したメールの控えを保持しておらず、APIからも読めません。そのため、
　このアドオンが送信の瞬間に自分で記録します。導入前に送ったメールは表示できません。

　「送信済み」タブから作成画面に戻せます。同じ文面を別の人に送るときに便利です。
　なお添付したアイテムは相手に渡っているため、記録に残るのは「何を送ったか」です。
　作成画面に戻すときは同じ種類のものを手持ちから探し、無いものはお知らせします。

■ 重要（期限切れ対策）

　受信箱のメールにはすべて期限があり、いずれサーバー側で削除されます。アドオンにこれを
　止める手段はありません（期限を延ばす、ピン留めする、といったAPIは存在しません）。

　できるのは「本文の写しを、期限のない場所に保存すること」です。受信箱でメールを開いて
　「重要に保存」を押すと、差出人・件名・本文・日付が「重要」タブに保存されます。元のメール
　が消えても、この写しは残ります。アカウント共通なので、どのキャラクターからでも読めます。

　★ 添付は保存できません。

　　アイテムとゴールドは受け取るまでサーバー側のもので、アドオンにアイテムを置く場所は
　　ありません。何が添付されていたかは記録に残しますが、現物は期限が切れる前に必ず
　　受け取ってください。保存時にもその旨を表示します。

　ギルドメールも保存できます（ギルドメールには添付そのものがありません）。

　保存したメールは「重要」タブで本文まで読めます。ゲームパッドでは標準のメール画面と同じ
　レイアウト（差出人・件名・スクロールする本文）で一覧の横に、キーボードでは一覧の下に表示され、「全文を表示」（または /pbmail keep read <n>）でチャットに全文を出せます。

　「重要」タブから作成画面に戻すと、差出人宛ての返信になります。相手が送ってきたアイテムを
　こちらが添付し直すことはありません（本文だけを戻します）。

■ 作成中の自動保存と、送信後の後始末

　作成画面の内容を一定間隔（初期値60秒）で下書きに保存します。クラッシュや離席で書きかけが
　消えないためのものです。増え続けることはありません — 保存されるのは常に1件で、同じ下書きが
　更新されます。自分で保存した下書きとは名前で区別でき、送信するか作成画面をクリアすると
　消えます。設定で間隔を変更でき、0で無効になります。

　下書きから作成画面に戻したメールを送信すると、元の下書きを削除します（下書きは「まだ送って
　いない手紙」なので）。送った内容は送信済みボックスに残ります。この挙動も設定で切れます。

■ 送信はしません

　このアドオンは SendMail を呼びません。下書きを戻すのは作成画面に書き込むところまでで、
　内容を確認して「送る」を押すのはこれまでどおりご自身です。送信はこの画面で唯一
　取り返しのつかない操作なので、アドオンが行うべきものではないと考えています。

■ 作成画面への戻し方

　タブで選ぶと、その場で作成画面に書き込み、「送信タブに切り替えてください」と表示します。
　タブの切り替えはご自身で行ってください。アドオンが勝手にタブを切り替えると、クライアント
　が自前の画面をアドオンのフレームの上で組むことになり、「送る」ボタンが動かなくなります
　（実機で確認済みです）。ボタン1回ぶんの手間は、その代わりの安全です。

■ 保存領域の空き表示

　メール画面の下部に、アドオンの保存領域の空き容量と、本アドオンの使用量を表示します。
　手紙を溜める機能なので、どれだけ余裕があるかが見えるようにしてあります。残りが1割を切ると
　赤字になります。/pbmail disk でも同じ内容を表示できます。

■ 保存件数

　下書きは初期値50件、送信済みは初期値100件、重要は初期値100件。いずれも設定で1〜1000件に
　変更できます。

　下書きと重要は上限に達すると保存を断ります（古いものを勝手に捨てません。どちらも残すと
　決めたものだからです）。送信済みは上限に達すると古いものから捨てます（記録を止めてしまって
　はログの意味がないためです）。

　上限を下げても、その場では何も削除しません。送信済みは次に送信したときに新しい件数まで
　整理され、下書きは上限を下回るまで新規保存を断るだけです。設定スライダーはドラッグ中の
　値も届くので、行き過ぎた1目盛りで記録が消えないようにしてあります。

■ 代金引換について

　金額欄は1つしかなく、それが「添付ゴールド」か「代金引換」かはラジオボタンが決めます。
　ボタンに触れずに数値だけ入れると、送信ボタンの隣で金額に間違った名前が付くため、
　代金引換は設定せず「いくらだったか」をお知らせします。手動で設定してください。

■ コマンド

　同じ操作はすべてチャットからも行えます。

　/pbmail save [名前]        作成画面の内容を下書きに保存
　/pbmail list               下書き一覧
　/pbmail load <n>           下書きを作成画面に戻す
　/pbmail delete <n> | all   下書きを削除
　/pbmail sent               送信済み一覧
　/pbmail sent load <n>      送信済みを作成画面に戻す
　/pbmail sent delete <n>    送信済みの記録を削除
　/pbmail keep save          開いている受信メールを「重要」に保存
　/pbmail keep               重要一覧
　/pbmail keep read <n>      重要メールの全文をチャットに表示
　/pbmail keep load <n>      差出人宛ての返信として作成画面に戻す
　/pbmail keep delete <n>    重要の保存を削除
　/pbmail autosave <秒|off>  作成中メールの自動保存
　/pbmail onsend [on|off]    送信したら元の下書きを削除
　/pbmail max                保存件数の確認と変更
　/pbmail where              作成画面を認識できているかの確認

　短縮形は /pbm です。

■ 保存場所

　アカウント共通で保存します。宛先はアカウント名であり、書きかけの手紙は特定のキャラクター
　の持ち物ではないためです。どのキャラクターからでも同じ下書き・送信済み・重要が見えます。

必須ライブラリはありません。LibHarvensAddonSettings があれば設定パネルが追加されます。
なくても /pbmail max で保存件数を変更できます。

## Description (EN)

The mail window has an inbox and a page to write on, and nothing else. This adds the three
boxes that are missing, as tabs beside them.

■ Drafts

　Press Save as draft on the page you write on, and the addressee, subject, body, attached
　items and attached gold are put away together. The Drafts tab lists them; pick one and put
　it back on the page.

　An attachment is remembered as what it was rather than where it was. Putting a letter back
　looks for
　　1. the slot it came from
　　2. that exact stack, wherever it has moved to
　　3. another of the same kind of item
　in that order, so an item you have shuffled around your backpack is still found, and a stack
　you used up is replaced by another if you have one. Anything that is simply gone is named.

■ Sent

　The game keeps no copy of a mail you sent and the API cannot read one, so this add-on writes
　each letter down as it goes. Nothing sent before you installed it can appear.

　Any of them can be put back on the page — handy for sending the same thing to somebody else.
　The items themselves went with the letter, so what the record keeps is what they were; it
　looks for another of the same kind and names anything it cannot find.

■ Kept (against the expiry clock)

　Every mail in the inbox expires, and the server deletes it when the day comes. No add-on can
　change that -- there is no call to extend a mail, pin one, or stop its clock.

　What can be done is to copy what the letter said somewhere nothing expires. Open a mail and
　press Keep this mail, and its sender, subject, body and date are written into the Kept tab.
　The copy outlives the mail, and it is account-wide, so any character can read it.

　★ Attachments cannot be copied.

　　Items and gold are the server's until you take them, and an add-on has nowhere to put an
　　item. The record notes what was attached so you know what to look for, but you have to take
　　it before the mail expires. The add-on says so when it keeps a mail that had anything on it.

　Guild mail can be kept too (it has no attachments to begin with).

　A kept mail can be read in the tab: beside the list on a controller, in the same layout the
　mail window itself uses -- sender, subject and a scrolling letter -- and under the list on a
　keyboard;
　and the whole of it goes to chat with Read it, or /pbmail keep read <n>.

　Putting a kept letter back on the page addresses a reply to whoever sent it, and puts back its
　words only -- never your own copies of what they sent you.

■ While you write, and after you send

　The letter on the Send page is saved to the drafts box every so often (60 seconds by default),
　so an unfinished one survives a crash or walking away. It never piles up: it is one draft kept
　up to date, named so you can tell it from the ones you saved yourself, and it goes when the
　letter is sent or the page is cleared. The interval is a setting, and 0 turns it off.

　A letter put on the page from the drafts box takes its draft with it when it goes -- a draft
　is a letter you have not sent yet, and the sent box has the copy. That is a setting too.

■ It never sends anything

　The add-on does not call SendMail. Putting a letter back fills the page in front of you, and
　you read it and press Send yourself, exactly as you do now. Sending is the one irreversible
　act in this window, and it is not an add-on's business.

■ How putting one back works

　Picking a letter writes it onto the page and asks you to go to the Send tab yourself. That
　last step is deliberate: an add-on that changes the tab for you makes the client rebuild its
　own screen on top of an add-on frame, and the Send button then stops working. Measured on a
　console. One button press is the price of not doing that.

■ Room left for saved data

　Along the bottom of the mail window: how much of the console's add-on storage allowance is
　free, and how much of it this add-on is using. Three boxes of letters is a thing that grows,
　and the allowance is shared with every other add-on. It turns red under a tenth left, and
　/pbmail disk says the same.

■ How much it keeps

　Drafts start at 50, sent letters at 100, kept mails at 100, and all three are settings from
　1 to 1000.

　The drafts and kept boxes refuse when full, and never throw the oldest away -- both hold
　things you chose to keep. The sent box drops the oldest to make room, because a log that
　stops recording has stopped being a log.

　Lowering a limit deletes nothing on the spot. The sent box is trimmed the next time you send;
　the drafts box simply takes no new ones until it is back under. The settings slider reports
　every step of a drag, so a limit that deleted on the way past would turn one notch too far
　into letters gone for good.

■ C.O.D.

　The page has one money field, and whether it means attached gold or C.O.D. is decided by a
　radio button. Setting the number without the button would show the wrong word next to your
　money on the screen where you press Send, so a C.O.D. is reported back to you to set
　yourself.

■ Commands

　Everything is on the chat box as well.

　/pbmail save [name]        put what is on the page into the drafts box
　/pbmail list               the drafts box, numbered
　/pbmail load <n>           put a draft back on the page
　/pbmail delete <n> | all   throw a draft away
　/pbmail sent               what you have sent
　/pbmail sent load <n>      put a sent letter back on the page
　/pbmail sent delete <n>    forget a sent letter
　/pbmail keep save          copy the mail you have open into the Kept box
　/pbmail keep               what you have kept
　/pbmail keep read <n>      the whole of a kept letter, in chat
　/pbmail keep load <n>      answer a kept letter on the page
　/pbmail keep delete <n>    forget a kept letter
　/pbmail autosave <s|off>   saving the letter you are writing
　/pbmail onsend [on|off]    delete a draft once its letter is sent
　/pbmail max                how many each box keeps, and changing it
　/pbmail where              whether the add-on can see the page right now

　/pbm is the short form.

■ Where it is kept

　Account-wide. The addressee is an account name and an unfinished letter is not the property
　of the character who started it, so every character sees the same drafts, sent letters and kept mails.

No required libraries. LibHarvensAddonSettings adds the settings panel if you have it; the
limits are reachable from /pbmail max without it.
