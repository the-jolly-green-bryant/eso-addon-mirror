------------------------------------------------
-- Calamath's BookFont Stylist
-- Simplified Chinese localization
------------------------------------------------
-- Version 1, 2024-03-13, by shijina452
-- Version 2, 2025-10-01.

local SAS = SafeAddString

-- Localization Strings (PC)
SAS(SI_CBFS_UI_SHOW_READER_WND_NAME,	"效果预览", 1)
SAS(SI_CBFS_UI_SHOW_READER_WND_TIPS,	"预览当前书籍字体设置", 1)

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
--	The following does not require translation. Instead, you are free to write something like a pangram that is useful for checking fonts in your language.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- The preview text of the Simplified Chinese version replaced with a quotation from 'Thousand Character Classic' by Zhou Xingsi (470?-521).
SAS(SI_CBFS_UI_PREVIEW_BODY_LOCALE,			"天地玄黃 宇宙洪荒 日月盈昃 辰宿列張 寒來暑往 秋收冬藏 閏餘成歲 律呂調陽 雲騰致雨 露結為霜 金生麗水 玉出崑岡 劍號巨闕 珠稱夜光 果珍李柰 菜重芥薑 海鹹河淡 鱗潛羽翔\n\n", 1)

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
--	The following two are the title and text of the 'dummy' book using on the Lore Reader preview screen. 
--	You (translator) can replace these texts with something else in your language, but please take care never cause any copyright problems.
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- The preview text of the Simplified Chinese version replaced with a quotation from 'Thousand Character Classic' by Zhou Xingsi (470?-521).
SAS(SI_CBFS_UI_PREVIEW_BOOK_TITLE,			"千字文", 1)
SAS(SI_CBFS_UI_PREVIEW_BOOK_BODY, 			"天地玄黃　宇宙洪荒\n日月盈昃　辰宿列張\n寒來暑往　秋收冬藏\n閏餘成歲　律呂調陽\n雲騰致雨　露結為霜\n金生麗水　玉出崑岡\n劍號巨闕　珠稱夜光\n果珍李柰　菜重芥薑\n海鹹河淡　鱗潛羽翔\n\n龍師火帝　鳥官人皇\n始制文字　乃服衣裳\n推位讓國　有虞陶唐\n弔民伐罪　周發殷湯\n坐朝問道　垂拱平章\n愛育黎首　臣伏戎羌\n遐邇壹體　率賓歸王\n鳴鳳在樹　白駒食場\n化被草木　賴及萬方\n\n蓋此身髮　四大五常\n恭惟鞠養　豈敢毀傷\n女慕貞絜　男效才良\n知過必改　得能莫忘\n罔談彼短　靡恃己長\n信使可覆　器欲難量\n墨悲絲染　詩讚羔羊\n\n景行維賢　克念作聖\n德建名立　形端表正\n空谷傳聲　虛堂習聽\n禍因惡積　福緣善慶\n尺璧非寶　寸陰是競\n資父事君　曰嚴與敬\n孝當竭力　忠則盡命\n臨深履薄　夙興溫凊\n似蘭斯馨　如松之盛\n\n川流不息　淵澄取映\n容止若思　言辭安定\n篤初誠美　慎終宜令\n榮業所基　籍甚無竟\n學優登仕　攝職從政\n存以甘棠　去而益詠\n\n樂殊貴賤　禮別尊卑\n上和下睦　夫唱婦隨\n外受傅訓　入奉母儀\n諸姑伯叔　猶子比兒\n孔懷兄弟　同氣連枝\n交友投分　切磨箴規\n仁慈隱惻　造次弗離\n節義廉退　顛沛匪虧\n性靜情逸　心動神疲\n守真志滿　逐物意移\n堅持雅操　好爵自縻\n\n都邑華夏　東西二京\n背邙面洛　浮渭據涇\n宮殿盤鬱　樓觀飛驚\n圖寫禽獸　畫綵仙靈\n丙舍傍啟　甲帳對楹\n肆筵設席　鼓瑟吹笙\n升階納陛　弁轉疑星\n右通廣內　左達承明\n既集墳典　亦聚羣英\n杜稾鍾隸　漆書壁經\n\n府羅將相　路俠槐卿\n戶封八縣　家給千兵\n高冠陪輦　驅轂振纓\n世祿侈富　車駕肥輕\n策功茂實　勒碑刻銘\n磻溪伊尹　佐時阿衡\n奄宅曲阜　微旦孰營\n桓公匡合　濟弱扶傾\n綺迴漢惠　說感武丁\n俊乂密勿　多士寔寧\n\n晉楚更霸　趙魏困橫\n假途滅虢　踐土會盟\n何遵約法　韓弊煩刑\n起翦頗牧　用軍最精\n宣威沙漠　馳譽丹青\n九州禹跡　百郡秦并\n嶽宗恆岱　禪主云亭\n雁門紫塞　雞田赤城\n昆池碣石　鉅野洞庭\n曠遠緜邈　巖岫杳冥\n\n治本於農　務茲稼穡\n俶載南畝　我藝黍稷\n稅熟貢新　勸賞黜陟\n孟軻敦素　史魚秉直\n庶幾中庸　勞謙謹敕\n聆音察理　鑑貌辨色\n貽厥嘉猷　勉其祗植\n省躬譏誡　寵增抗極\n殆辱近恥　林皋幸即\n兩疏見機　解組誰逼\n\n索居閑處　沈默寂寥\n求古尋論　散慮逍遙\n欣奏累遣　慼謝歡招\n渠荷的歷　園莽抽條\n枇杷晚翠　梧桐早凋\n陳根委翳　落葉飄颻\n遊鵾獨運　凌摩絳霄\n\n耽讀翫市　寓目囊箱\n易輶攸畏　屬耳垣墻\n具膳飡飯　適口充腸\n飽飫烹宰　飢厭糟糠\n親戚故舊　老少異糧\n妾御績紡　侍巾帷房\n紈扇圓潔　銀燭煒煌\n晝眠夕寐　藍笋象床\n絃歌酒讌　接盃舉觴\n矯手頓足　悅豫且康\n\n嫡後嗣續　祭祀烝嘗\n稽顙再拜　悚懼恐惶\n牋牒簡要　顧答審詳\n骸垢想浴　執熱願涼\n驢騾犢特　駭躍超驤\n誅斬賊盜　捕獲叛亡\n\n布射遼丸　嵇琴阮嘯\n恬筆倫紙　鈞巧任釣\n釋紛利俗　並皆佳妙\n毛施淑姿　工顰妍笑\n年矢每催　曦暉朗耀\n璇璣懸斡　晦魄環照\n指薪修祜　永綏吉劭\n矩步引領　俯仰廊廟\n束帶矜莊　徘徊瞻眺\n孤陋寡聞　愚蒙等誚\n謂語助者　焉哉乎也\n", 1)
