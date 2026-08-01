--.----------------.  .----------------.  .-----------------. .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
--| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
--| |    _______   | || |  ____  ____  | || | ____  _____  | || |     ______   | || | ____    ____ | || |     ____     | || |  _________   | || |  _________   | || |    _______   | |
--| |   /  ___  |  | || | |_  _||_  _| | || ||_   \|_   _| | || |   .' ___  |  | || ||_   \  /   _|| || |   .'    `.   | || | |  _   _  |  | || | |_   ___  |  | || |   /  ___  |  | |
--| |  |  (__ \_|  | || |   \ \  / /   | || |  |   \ | |   | || |  / .'   \_|  | || |  |   \/   |  | || |  /  .--.  \  | || | |_/ | | \_|  | || |   | |_  \_|  | || |  |  (__ \_|  | |
--| |   '.___`-.   | || |    \ \/ /    | || |  | |\ \| |   | || |  | |         | || |  | |\  /| |  | || |  | |    | |  | || |     | |      | || |   |  _|  _   | || |   '.___`-.   | |
--| |  |`\____) |  | || |    _|  |_    | || | _| |_\   |_  | || |  \ `.___.'\  | || | _| |_\/_| |_ | || |  \  `--'  /  | || |    _| |_     | || |  _| |___/ |  | || |  |`\____) |  | |
--| |  |_______.'  | || |   |______|   | || ||_____|\____| | || |   `._____.'  | || ||_____||_____|| || |   `.____.'   | || |   |_____|    | || | |_________|  | || |  |_______.'  | |
--| |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | |
--| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
--'----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 
--All Credit and Copyrights go to (ESO EU) Dero - @Deryl
--I did my best to comment the code for others to learn from it ;)

local ESO_SM_EMOTESPACE = 175 --Space left to right to next emote
local ESO_SM_EMOTEPERCOL = 30 --Number of Emotes per Column
local ESO_SM_ROWDISTANCE = 20 --Space top to bottom for each emote 

local ESO_SM_CHATSPERCOL = 3 --Number of Chats per Column

local ESO_SM_INFOHEIGHT = 270 --Setting the Infoheight for Menu Adjustment
local ESO_SM_SETTINGSHEIGHT = 240 --Setting the Settingsheight for Menu Adjustment

local ESO_SM_MAXWIDTH = math.ceil(GetNumEmotes()/ESO_SM_EMOTEPERCOL)*ESO_SM_EMOTESPACE+10 --Max Width of the Menu
if(ESO_SM_MAXWIDTH <= 600)then
	ESO_SM_MAXWIDTH = 600
end
local ESO_SM_MAXHEIGHT = 75 + math.ceil(ESO_SM_EMOTEPERCOL*ESO_SM_ROWDISTANCE) + 150 --Max Height of the Menu
		
--Creation of the Menu
function ESO_SM.buildmenu()
	if (SyncMotesMenu == nil) then
--------------------------------------------------------------------------------------------------------------------------
-- MAINPART -- MAINPART -- MAINPART -- MAINPART -- MAINPART -- MAINPART -- MAINPART -- MAINPART -- MAINPART -- MAINPART --
--------------------------------------------------------------------------------------------------------------------------
		--Basemenu
		ESO_SM_MENU = WINDOW_MANAGER:CreateTopLevelWindow("SyncMotesMenu")
		ESO_SM_MENU:SetDrawLayer(1)
		ESO_SM_MENU:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,(1920-ESO_SM_MAXWIDTH)/2,70)
		ESO_SM_MENU:SetDimensions(ESO_SM_MAXWIDTH,ESO_SM_MAXHEIGHT)
		ESO_SM_MENU:SetMouseEnabled(true)
		ESO_SM_MENU:SetMovable(true)
		ESO_SM_MENU_BG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_Back",SyncMotesMenu,"ZO_DefaultBackdrop")
		
		--SyncMotes icon Left
		ESO_SM_SML_I = WINDOW_MANAGER:CreateControl("ESO_SM_SML_I",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_SML_I:SetDimensions(50,50)
		ESO_SM_SML_I:SetAnchor(TOPLEFT,SyncMotesMenu,TOPLEFT,300,-12)
		ESO_SM_SML_I:SetTexture("/esoui/art/charactercreate/charactercreate_bodyicon_up.dds")

		--SyncMotes icon Right
		ESO_SM_SMR_I = WINDOW_MANAGER:CreateControl("ESO_SM_SMR_I",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_SMR_I:SetDimensions(50,50)
		ESO_SM_SMR_I:SetAnchor(TOPRIGHT,SyncMotesMenu,TOPRIGHT,-300,-12)
		ESO_SM_SMR_I:SetTexture("/esoui/art/charactercreate/charactercreate_bodyicon_up.dds")
		
		--Headertext
		ESO_SM_HEADER = WINDOW_MANAGER:CreateControl("ESO_SM_HEAD",SyncMotesMenu,CT_LABEL)
		ESO_SM_HEADER:SetText("|c880000SyncMotes|r  ver." .. ESO_SM.version)
		ESO_SM_HEADER:SetFont("ZoFontTooltipTitle")
		ESO_SM_HEADER:SetAnchor(TOP,SyncMotesMenu,TOP,0,0)
		
		--Headertext SyncMotes Status
		ESO_SM_HEADERSM = WINDOW_MANAGER:CreateControl("ESO_SM_HEADERSM",SyncMotesMenu,CT_LABEL)
		ESO_SM_HEADERSM:SetText("|c880000SM|r: |cff0000OFF|r")
		ESO_SM_HEADERSM:SetFont("ZoFontTooltipTitle")
		ESO_SM_HEADERSM:SetAnchor(TOPLEFT,SyncMotesMenu,TOPLEFT,0,0)
		
		--Headertext SyncPhrase Status
		ESO_SM_HEADERSP = WINDOW_MANAGER:CreateControl("ESO_SM_HEADERSP",SyncMotesMenu,CT_LABEL)
		ESO_SM_HEADERSP:SetText("|c5555ffSP|r: |cff0000OFF|r")
		ESO_SM_HEADERSP:SetFont("ZoFontTooltipTitle")
		ESO_SM_HEADERSP:SetAnchor(TOPLEFT,SyncMotesMenu,TOPLEFT,90,0)

		--Headertext CaseSensitivity Status
		ESO_SM_HEADERCS = WINDOW_MANAGER:CreateControl("ESO_SM_HEADERCS",SyncMotesMenu,CT_LABEL)
		ESO_SM_HEADERCS:SetText("|c888800CS|r: |cff0000OFF|r")
		ESO_SM_HEADERCS:SetFont("ZoFontTooltipTitle")
		ESO_SM_HEADERCS:SetAnchor(TOPLEFT,SyncMotesMenu,TOPLEFT,180,0)
		
		--X-Button to Close the Menu
		ESO_SM_BTNCLOSE = WINDOW_MANAGER:CreateControl("ESO_SM_BTNCLS",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNCLOSE:SetDimensions(20,20)
		ESO_SM_BTNCLOSE:SetHandler("OnClicked",ESO_SM.openmenu)
		ESO_SM_BTNCLOSE:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
		ESO_SM_BTNCLOSE:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")
		ESO_SM_BTNCLOSE:SetAnchor(TOPRIGHT,SyncMotesMenu,TOPRIGHT,0,0)

		--BOTTOMRIGHT LINE
		ESO_SM_LINEBOTTOMRIGHT1 = WINDOW_MANAGER:CreateControl("ESO_SM_L_BOTTOMRIGHT1",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINEBOTTOMRIGHT1:SetDimensions(375,5)
		ESO_SM_LINEBOTTOMRIGHT1:SetAnchor(BOTTOMRIGHT,SyncMotesMenu,BOTTOMRIGHT,5,35)
		ESO_SM_LINEBOTTOMRIGHT1:SetTexture("/esoui/art/miscellaneous/wide_divider_left.dds")

		--Footertext
		ESO_SM_FOOTER = WINDOW_MANAGER:CreateControl("ESO_SM_FOOT",SyncMotesMenu,CT_LABEL)
		ESO_SM_FOOTER:SetText("Created by: |c880000(ESO-EU) Illuminati - Dero - @Deryl|r")
		ESO_SM_FOOTER:SetFont("ZoFontGame")
		ESO_SM_FOOTER:SetAnchor(BOTTOMRIGHT,SyncMotesMenu,BOTTOMRIGHT,0,30)

--------------------------------------------------------------------------------------------------------------------------
-- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES -- EMOTES --
--------------------------------------------------------------------------------------------------------------------------
		
		--EMOTE LINE1 -- LINKED: ESO_SM_ELISTEN_I, ESO_SM_BTNCA, ESO_SM_BTNUCA, ESO_SM_LINEEMOTES2
		ESO_SM_LINEEMOTES1 = WINDOW_MANAGER:CreateControl("ESO_SM_LINEEMOTES1",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINEEMOTES1:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINEEMOTES1:SetAnchor(TOPLEFT,SyncMotesMenu,TOPLEFT,-6,30)
		ESO_SM_LINEEMOTES1:SetTexture("/esoui/art/progression/ability_line.dds")

		--Play this Emotes text and Icon
		ESO_SM_ELISTEN_I = WINDOW_MANAGER:CreateControl("ESO_SM_ELISTEN_I",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_ELISTEN_I:SetDimensions(40,40)
		ESO_SM_ELISTEN_I:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES1,TOPLEFT,-5,-5)
		ESO_SM_ELISTEN_I:SetTexture("/esoui/art/charactercreate/charactercreate_faceicon_up.dds")
		ESO_SM_ELISTEN = WINDOW_MANAGER:CreateControl("ESO_SM_ELISTEN",SyncMotesMenu,CT_LABEL)
		ESO_SM_ELISTEN:SetText(" - |c880000SyncMotes - play this Emotes:")
		ESO_SM_ELISTEN:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_ELISTEN:SetAnchor(TOPLEFT,ESO_SM_ELISTEN_I,TOPLEFT,30,10)

		--Check all EmoteButton
		ESO_SM_BTNCA = WINDOW_MANAGER:CreateControl("ESO_SM_BTNCA",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNCA:SetDimensions(25,25)
		ESO_SM_BTNCA:SetHandler("OnClicked",ESO_SM.checkall)
		ESO_SM_BTNCA:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_BTNCA:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNCA:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES1,TOPLEFT,356,5)
		ESO_SM_TXTCA = WINDOW_MANAGER:CreateControl("TXTCA",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTCA:SetFont("ZoFontGame")
		ESO_SM_TXTCA:SetText("|c888866Check all")
		ESO_SM_TXTCA:SetAnchor(TOPLEFT,ESO_SM_BTNCA,TOPLEFT,28,2)
		
		--Uncheck all EmoteButton
		ESO_SM_BTNUCA = WINDOW_MANAGER:CreateControl("ESO_SM_BTNUCA",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNUCA:SetDimensions(25,25)
		ESO_SM_BTNUCA:SetHandler("OnClicked",ESO_SM.uncheckall)
		ESO_SM_BTNUCA:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_BTNUCA:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNUCA:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES1,TOPLEFT,456,5)
		ESO_SM_TXTUCA = WINDOW_MANAGER:CreateControl("TXTUCA",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTUCA:SetFont("ZoFontGame")
		ESO_SM_TXTUCA:SetText("|c888866Uncheck all")
		ESO_SM_TXTUCA:SetAnchor(TOPLEFT,ESO_SM_BTNUCA,TOPLEFT,28,2)
		
		--Show/Hide Emotes Button
		ESO_SM_TXTSHE = WINDOW_MANAGER:CreateControl("TXTSHE",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTSHE:SetFont("ZoFontGame")
		ESO_SM_TXTSHE:SetText("Show Emotes")
		ESO_SM_TXTSHE:SetAnchor(TOPRIGHT,ESO_SM_LINEEMOTES1,TOPRIGHT,-30,5)
		ESO_SM_BTNSHE = WINDOW_MANAGER:CreateControl("ESO_SM_BTNSHE",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNSHE:SetDimensions(30,30)
		ESO_SM_BTNSHE:SetHandler("OnClicked",ESO_SM.SwitchEmoteList)
		ESO_SM_BTNSHE:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHE:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_BTNSHE:SetAnchor(TOPRIGHT,ESO_SM_TXTSHE,TOPRIGHT,31,-5)
		--Call for SetEmoteList set to the Complete Bottom to Avoid nil errors
		
		--EMOTE LINE2
		ESO_SM_LINEEMOTES2 = WINDOW_MANAGER:CreateControl("ESO_SM_LINEEMOTES2",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINEEMOTES2:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINEEMOTES2:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES1,TOPLEFT,0,30)
		ESO_SM_LINEEMOTES2:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--EMOTE Container -- LINKED: ALL EMOTES
		ESO_SM_EMOTECONT = WINDOW_MANAGER:CreateControl("ESO_SM_EMOTECONT",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_EMOTECONT:SetDimensions(0,0)
		ESO_SM_EMOTECONT:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES2,TOPLEFT,6,0)
		
		--Placing of Checkboxes and texts with modulo (omg is this a good idea?)
		ESO_SM_CBOX = {}
		ESO_SM_TXT = {}
		for i=1,GetNumEmotes(),1 do
			ESO_SM_CBOX[i] = WINDOW_MANAGER:CreateControl("BOX"..i,ESO_SM_EMOTECONT,CT_BUTTON)
			ESO_SM_CBOX[i]:SetDimensions(25,25)
			ESO_SM_CBOX[i]:SetAnchor(TOPLEFT,ESO_SM_EMOTECONT,TOPLEFT,math.floor((i-1)/ESO_SM_EMOTEPERCOL)*ESO_SM_EMOTESPACE,((i-1)%ESO_SM_EMOTEPERCOL)*ESO_SM_ROWDISTANCE)
			ESO_SM_CBOX[i]:SetHandler("OnClicked",function() ESO_SM.switchmode(i,ESO_SM_CBOX[i]) end)
			ESO_SM_CBOX[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
			ESO_SM_CBOX[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
			ESO_SM_TXT[i] = WINDOW_MANAGER:CreateControl("TXT"..i,ESO_SM_EMOTECONT,CT_LABEL)
			ESO_SM_TXT[i]:SetFont("ZoFontGame")
			ESO_SM_TXT[i]:SetText("|c888866" .. GetEmoteSlashNameByIndex(i):gsub("/", "") .. " (" .. i .. ")")
			ESO_SM_TXT[i]:SetAnchor(TOPLEFT,ESO_SM_CBOX[i],TOPLEFT,28,2)
			ESO_SM.setmode(i,ESO_SM_CBOX[i])
		end

--------------------------------------------------------------------------------------------------------------------------
-- EMOTESRP -- EMOTESRP -- EMOTESRP -- EMOTESRP -- EMOTESRP -- EMOTESRP -- EMOTESRP -- EMOTESRP -- EMOTESRP -- EMOTESRP --
--------------------------------------------------------------------------------------------------------------------------
		
		--EMOTE LINERP1 -- LINKED: ESO_SM_ELISTEN_IRP, ESO_SM_BTNCARP, ESO_SM_BTNUCARP, ESO_SM_LINEEMOTESRP2
		ESO_SM_LINEEMOTESRP1 = WINDOW_MANAGER:CreateControl("ESO_SM_LINEEMOTESRP1",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINEEMOTESRP1:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINEEMOTESRP1:SetAnchor(TOPLEFT,SyncMotesMenu,TOPLEFT,-6,30) --ANCHOR DELETE
		ESO_SM_LINEEMOTESRP1:SetTexture("/esoui/art/progression/ability_line.dds")

		--Listen to these Emotes text and IconRP
		ESO_SM_ELISTEN_IRP = WINDOW_MANAGER:CreateControl("ESO_SM_ELISTEN_IRP",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_ELISTEN_IRP:SetDimensions(40,40)
		ESO_SM_ELISTEN_IRP:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTESRP1,TOPLEFT,-5,-5)
		ESO_SM_ELISTEN_IRP:SetTexture("/esoui/art/charactercreate/charactercreate_faceicon_up.dds")
		--ESO_SM_ELISTEN_IRP:SetColor(0.4,0.4,1,1)
		ESO_SM_ELISTENRP = WINDOW_MANAGER:CreateControl("ESO_SM_ELISTENRP",SyncMotesMenu,CT_LABEL)
		ESO_SM_ELISTENRP:SetText(" - |c5555ffSyncPhrases - play this Emotes:")
		ESO_SM_ELISTENRP:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_ELISTENRP:SetAnchor(TOPLEFT,ESO_SM_ELISTEN_IRP,TOPLEFT,30,10)

		--Check all EmoteButtonRP
		ESO_SM_BTNCARP = WINDOW_MANAGER:CreateControl("ESO_SM_BTNCARP",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNCARP:SetDimensions(25,25)
		ESO_SM_BTNCARP:SetHandler("OnClicked",ESO_SM.checkallRP)
		ESO_SM_BTNCARP:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_BTNCARP:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNCARP:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTESRP1,TOPLEFT,356,5)
		ESO_SM_TXTCARP = WINDOW_MANAGER:CreateControl("TXTCARP",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTCARP:SetFont("ZoFontGame")
		ESO_SM_TXTCARP:SetText("|c888866Check all")
		ESO_SM_TXTCARP:SetAnchor(TOPLEFT,ESO_SM_BTNCARP,TOPLEFT,28,2)
		
		--Uncheck all EmoteButtonRP
		ESO_SM_BTNUCARP = WINDOW_MANAGER:CreateControl("ESO_SM_BTNUCARP",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNUCARP:SetDimensions(25,25)
		ESO_SM_BTNUCARP:SetHandler("OnClicked",ESO_SM.uncheckallRP)
		ESO_SM_BTNUCARP:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_BTNUCARP:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNUCARP:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTESRP1,TOPLEFT,456,5)
		ESO_SM_TXTUCARP = WINDOW_MANAGER:CreateControl("TXTUCARP",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTUCARP:SetFont("ZoFontGame")
		ESO_SM_TXTUCARP:SetText("|c888866Uncheck all")
		ESO_SM_TXTUCARP:SetAnchor(TOPLEFT,ESO_SM_BTNUCARP,TOPLEFT,28,2)
		
		--Show/Hide Emotes Button
		ESO_SM_TXTSHERP = WINDOW_MANAGER:CreateControl("TXTSHERP",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTSHERP:SetFont("ZoFontGame")
		ESO_SM_TXTSHERP:SetText("Show Emotes")
		ESO_SM_TXTSHERP:SetAnchor(TOPRIGHT,ESO_SM_LINEEMOTESRP1,TOPRIGHT,-30,5)
		ESO_SM_BTNSHERP = WINDOW_MANAGER:CreateControl("ESO_SM_BTNSHERP",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNSHERP:SetDimensions(30,30)
		ESO_SM_BTNSHERP:SetHandler("OnClicked",ESO_SM.SwitchEmoteListRP)
		ESO_SM_BTNSHERP:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHERP:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_BTNSHERP:SetAnchor(TOPRIGHT,ESO_SM_TXTSHERP,TOPRIGHT,31,-5)
		--Call for SetEmoteListRP set to the Complete Bottom to Avoid nil errors
		
		--EMOTE LINE2
		ESO_SM_LINEEMOTESRP2 = WINDOW_MANAGER:CreateControl("ESO_SM_LINEEMOTESRP2",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINEEMOTESRP2:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINEEMOTESRP2:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTESRP1,TOPLEFT,0,30)
		ESO_SM_LINEEMOTESRP2:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--EMOTE Container -- LINKED: ALL EMOTES
		ESO_SM_EMOTECONTRP = WINDOW_MANAGER:CreateControl("ESO_SM_EMOTECONTRP",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_EMOTECONTRP:SetDimensions(0,0)
		ESO_SM_EMOTECONTRP:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTESRP2,TOPLEFT,6,0)
		
		--Placing of Checkboxes and texts with modulo (omg is this a good idea?)
		ESO_SM_CBOXRP = {}
		ESO_SM_TXTRP = {}
		for i=1,GetNumEmotes(),1 do
			ESO_SM_CBOXRP[i] = WINDOW_MANAGER:CreateControl("ESO_SM_CBOXRP"..i,ESO_SM_EMOTECONTRP,CT_BUTTON)
			ESO_SM_CBOXRP[i]:SetDimensions(25,25)
			ESO_SM_CBOXRP[i]:SetAnchor(TOPLEFT,ESO_SM_EMOTECONTRP,TOPLEFT,math.floor((i-1)/ESO_SM_EMOTEPERCOL)*ESO_SM_EMOTESPACE,((i-1)%ESO_SM_EMOTEPERCOL)*ESO_SM_ROWDISTANCE)
			ESO_SM_CBOXRP[i]:SetHandler("OnClicked",function() ESO_SM.switchmodeRP(i,ESO_SM_CBOXRP[i]) end)
			ESO_SM_CBOXRP[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
			ESO_SM_CBOXRP[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
			ESO_SM_TXTRP[i] = WINDOW_MANAGER:CreateControl("ESO_SM_TXTRP"..i,ESO_SM_EMOTECONTRP,CT_LABEL)
			ESO_SM_TXTRP[i]:SetFont("ZoFontGame")
			ESO_SM_TXTRP[i]:SetText("|c888866" .. GetEmoteSlashNameByIndex(i):gsub("/", "") .. " (" .. i .. ")")
			ESO_SM_TXTRP[i]:SetAnchor(TOPLEFT,ESO_SM_CBOXRP[i],TOPLEFT,28,2)
			ESO_SM.setmodeRP(i,ESO_SM_CBOXRP[i])
		end
--------------------------------------------------------------------------------------------------------------------------
-- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- CHATS -- 
--------------------------------------------------------------------------------------------------------------------------

		--CHAT LINE1 -- LINKED: ESO_SM_LINECHATS2, ESO_SM_CLISTEN_I, ESO_SM_BTNUCAC, ESO_SM_BTNCAC
		ESO_SM_LINECHATS1 = WINDOW_MANAGER:CreateControl("ESO_SM_LINECHATS1",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINECHATS1:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINECHATS1:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES2,TOPLEFT,0,ESO_SM_EMOTEPERCOL*ESO_SM_ROWDISTANCE+3)
		ESO_SM_LINECHATS1:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--SM Listen to these Chats text
		ESO_SM_CLISTEN_I = WINDOW_MANAGER:CreateControl("ESO_SM_CLISTEN_I",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_CLISTEN_I:SetDimensions(40,40)
		ESO_SM_CLISTEN_I:SetAnchor(TOPLEFT,ESO_SM_LINECHATS1,TOPLEFT,-5,-5)
		ESO_SM_CLISTEN_I:SetTexture("/esoui/art/hud/radialicon_whisper_up.dds")
		ESO_SM_CLISTEN = WINDOW_MANAGER:CreateControl("ESO_SM_CLISTEN",SyncMotesMenu,CT_LABEL)
		ESO_SM_CLISTEN:SetText(" - |c880000SyncMotes - listen to this Chats:")
		ESO_SM_CLISTEN:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_CLISTEN:SetAnchor(TOPLEFT,ESO_SM_CLISTEN_I,TOPLEFT,30,10)

		--Check all ChatsButton
		ESO_SM_BTNCA = WINDOW_MANAGER:CreateControl("ESO_SM_BTNCAC",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNCAC:SetDimensions(25,25)
		ESO_SM_BTNCAC:SetHandler("OnClicked",ESO_SM.checkallchat)
		ESO_SM_BTNCAC:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_BTNCAC:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNCAC:SetAnchor(TOPLEFT,ESO_SM_LINECHATS1,TOPLEFT,356,5)
		ESO_SM_TXTCAC = WINDOW_MANAGER:CreateControl("ESO_SM_TXTCAC",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTCAC:SetFont("ZoFontGame")
		ESO_SM_TXTCAC:SetText("|c888866Check all")
		ESO_SM_TXTCAC:SetAnchor(TOPLEFT,ESO_SM_BTNCAC,TOPLEFT,28,2)
		
		--Uncheck all ChatsButton
		ESO_SM_BTNUCAC = WINDOW_MANAGER:CreateControl("ESO_SM_BTNUCAC",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNUCAC:SetDimensions(25,25)
		ESO_SM_BTNUCAC:SetHandler("OnClicked",ESO_SM.uncheckallchat)
		ESO_SM_BTNUCAC:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_BTNUCAC:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNUCAC:SetAnchor(TOPLEFT,ESO_SM_LINECHATS1,TOPLEFT,456,5)
		ESO_SM_TXTUCAC = WINDOW_MANAGER:CreateControl("TXTUCAC",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTUCAC:SetFont("ZoFontGame")
		ESO_SM_TXTUCAC:SetText("|c888866Uncheck all")
		ESO_SM_TXTUCAC:SetAnchor(TOPLEFT,ESO_SM_BTNUCAC,TOPLEFT,28,2)
		
		--CHAT LINE2 -- LINKED: ESO_SM_CHATCONT, ESO_SM_LINESET1
		ESO_SM_LINECHATS2 = WINDOW_MANAGER:CreateControl("ESO_SM_LINECHATS2",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINECHATS2:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINECHATS2:SetAnchor(TOPLEFT,ESO_SM_LINECHATS1,TOPLEFT,0,30)
		ESO_SM_LINECHATS2:SetTexture("/esoui/art/progression/ability_line.dds")

		--Show/Hide Chats Button
		ESO_SM_TXTSHC = WINDOW_MANAGER:CreateControl("TXTSHC",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTSHC:SetFont("ZoFontGame")
		ESO_SM_TXTSHC:SetText("Show Emotes")
		ESO_SM_TXTSHC:SetAnchor(TOPRIGHT,ESO_SM_LINECHATS1,TOPRIGHT,-30,5)
		ESO_SM_BTNSHC = WINDOW_MANAGER:CreateControl("ESO_SM_BTNSHC",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNSHC:SetDimensions(30,30)
		ESO_SM_BTNSHC:SetHandler("OnClicked",ESO_SM.SwitchChatList)
		ESO_SM_BTNSHC:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHC:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_BTNSHC:SetAnchor(TOPRIGHT,ESO_SM_TXTSHC,TOPRIGHT,31,-5)
		--Call for SetChatList set to the Complete Bottom to Avoid nil errors
		
		--CHAT Container -- LINKED: ALL CHATS
		ESO_SM_CHATCONT = WINDOW_MANAGER:CreateControl("ESO_SM_CHATCONT",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_CHATCONT:SetDimensions(0,0)
		ESO_SM_CHATCONT:SetAnchor(TOPLEFT,ESO_SM_LINECHATS2,TOPLEFT,6,0)
		
		--Placing of Channellist to listen to
		ESO_SM_CBOX_Chat = {}
		ESO_SM_TXT_Chat = {}
		--0 Say ,1 Yell,4 Tell,6 Emote,8 NSC,12 Guild1,13 Guild2,14 Guild3,15 Guild4,16 Guild5,17 GuildOfficer1,18 GuildOfficer2,19 GuildOfficer3,20 GuildOfficer4,21 GuildOfficer5,31 Gebiet
		chatstocheck = {{0,"Say"}, {12,"G1"}, {17,"O1"}, {1,"Yell"}, {13,"G2"}, {18,"O2"}, {4,"Tell"}, {14,"G3"}, {19,"O3"}, {6,"Emote"}, {15,"G4"}, {20,"O4"}, {31,"Zone"}, {16,"G5"}, {21,"O5"}, {3,"Group"}}
		for i=1,table.getn(chatstocheck),1 do
			ESO_SM_CBOX_Chat[i] = WINDOW_MANAGER:CreateControl("BOXC"..i,ESO_SM_CHATCONT,CT_BUTTON)
			ESO_SM_CBOX_Chat[i]:SetDimensions(25,25)
			ESO_SM_CBOX_Chat[i]:SetAnchor(TOPLEFT,ESO_SM_CHATCONT,TOPLEFT,math.floor((i-1)/ESO_SM_CHATSPERCOL)*ESO_SM_EMOTESPACE,((i-1)%ESO_SM_CHATSPERCOL)*ESO_SM_ROWDISTANCE)
			ESO_SM_CBOX_Chat[i]:SetHandler("OnClicked",function() ESO_SM.switchmodechat(i,ESO_SM_CBOX_Chat[i],chatstocheck[i][1]) end)
			ESO_SM_CBOX_Chat[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
			ESO_SM_CBOX_Chat[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
			ESO_SM_TXT_Chat[i] = WINDOW_MANAGER:CreateControl("TXTC"..i,ESO_SM_CHATCONT,CT_LABEL)
			ESO_SM_TXT_Chat[i]:SetFont("ZoFontGame")
			if GetDynamicChatChannelName(chatstocheck[i][1]) == "" then
				checktext = chatstocheck[i][2]
			else
				if (string.len (GetDynamicChatChannelName(chatstocheck[i][1])) >=16) then
					checktext= chatstocheck[i][2] .. ": " .. string.sub (GetDynamicChatChannelName(chatstocheck[i][1]), 1, 15) .."."
				else
					checktext = chatstocheck[i][2] .. ": " .. GetDynamicChatChannelName(chatstocheck[i][1])
				end
			end
			ESO_SM_TXT_Chat[i]:SetText("|c888866" .. checktext)
			ESO_SM_TXT_Chat[i]:SetAnchor(TOPLEFT,ESO_SM_CBOX_Chat[i],TOPLEFT,28,2)
			ESO_SM.setmodechat(i,ESO_SM_CBOX_Chat[i])
		end

--------------------------------------------------------------------------------------------------------------------------
-- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -- CHATSRP -
--------------------------------------------------------------------------------------------------------------------------

		--CHATRP LINE1 -- LINKED: ESO_SM_LINECHATSRP2, ESO_SM_CLISTEN_IRP, ESO_SM_BTNUCACRP, ESO_SM_BTNCACRP
		ESO_SM_LINECHATSRP1 = WINDOW_MANAGER:CreateControl("ESO_SM_LINECHATSRP1",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINECHATSRP1:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINECHATSRP1:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES2,TOPLEFT,0,ESO_SM_EMOTEPERCOL*ESO_SM_ROWDISTANCE+3) -- ANKER
		ESO_SM_LINECHATSRP1:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--Listen to these ChatsRP text
		ESO_SM_CLISTEN_IRP = WINDOW_MANAGER:CreateControl("ESO_SM_CLISTEN_IRP",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_CLISTEN_IRP:SetDimensions(40,40)
		ESO_SM_CLISTEN_IRP:SetAnchor(TOPLEFT,ESO_SM_LINECHATSRP1,TOPLEFT,-5,-5)
		ESO_SM_CLISTEN_IRP:SetTexture("/esoui/art/hud/radialicon_whisper_up.dds")
		--ESO_SM_CLISTEN_IRP:SetColor(0.4,0.4,1,1)
		ESO_SM_CLISTENRP = WINDOW_MANAGER:CreateControl("ESO_SM_CLISTENRP",SyncMotesMenu,CT_LABEL)
		ESO_SM_CLISTENRP:SetText(" - |c5555ffSyncPhrases - listen to this Chats:")
		ESO_SM_CLISTENRP:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_CLISTENRP:SetAnchor(TOPLEFT,ESO_SM_CLISTEN_IRP,TOPLEFT,30,10)

		--Check all ChatsButton
		ESO_SM_BTNCARP = WINDOW_MANAGER:CreateControl("ESO_SM_BTNCACRP",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNCACRP:SetDimensions(25,25)
		ESO_SM_BTNCACRP:SetHandler("OnClicked",ESO_SM.checkallchatRP)
		ESO_SM_BTNCACRP:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_BTNCACRP:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNCACRP:SetAnchor(TOPLEFT,ESO_SM_LINECHATSRP1,TOPLEFT,356,5)
		ESO_SM_TXTCACRP = WINDOW_MANAGER:CreateControl("ESO_SM_TXTCACRP",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTCACRP:SetFont("ZoFontGame")
		ESO_SM_TXTCACRP:SetText("|c888866Check all")
		ESO_SM_TXTCACRP:SetAnchor(TOPLEFT,ESO_SM_BTNCACRP,TOPLEFT,28,2)
		
		--Uncheck all ChatsButton
		ESO_SM_BTNUCACRP = WINDOW_MANAGER:CreateControl("ESO_SM_BTNUCACRP",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNUCACRP:SetDimensions(25,25)
		ESO_SM_BTNUCACRP:SetHandler("OnClicked",ESO_SM.uncheckallchatRP)
		ESO_SM_BTNUCACRP:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_BTNUCACRP:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
		ESO_SM_BTNUCACRP:SetAnchor(TOPLEFT,ESO_SM_LINECHATSRP1,TOPLEFT,456,5)
		ESO_SM_TXTUCACRP = WINDOW_MANAGER:CreateControl("ESO_SM_TXTUCACRP",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTUCACRP:SetFont("ZoFontGame")
		ESO_SM_TXTUCACRP:SetText("|c888866Uncheck all")
		ESO_SM_TXTUCACRP:SetAnchor(TOPLEFT,ESO_SM_BTNUCACRP,TOPLEFT,28,2)
		
		--CHAT LINE2 -- LINKED: ESO_SM_CHATCONT, ESO_SM_LINESET1
		ESO_SM_LINECHATSRP2 = WINDOW_MANAGER:CreateControl("ESO_SM_LINECHATSRP2",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINECHATSRP2:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINECHATSRP2:SetAnchor(TOPLEFT,ESO_SM_LINECHATSRP1,TOPLEFT,0,30)
		ESO_SM_LINECHATSRP2:SetTexture("/esoui/art/progression/ability_line.dds")

		--Show/Hide Chats Button
		ESO_SM_TXTSHCRP = WINDOW_MANAGER:CreateControl("ESO_SM_TXTSHCRP",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTSHCRP:SetFont("ZoFontGame")
		ESO_SM_TXTSHCRP:SetText("Show Emotes")
		ESO_SM_TXTSHCRP:SetAnchor(TOPRIGHT,ESO_SM_LINECHATSRP1,TOPRIGHT,-30,5)
		ESO_SM_BTNSHCRP = WINDOW_MANAGER:CreateControl("ESO_SM_BTNSHCRP",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNSHCRP:SetDimensions(30,30)
		ESO_SM_BTNSHCRP:SetHandler("OnClicked",ESO_SM.SwitchChatListRP)
		ESO_SM_BTNSHCRP:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHCRP:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_BTNSHCRP:SetAnchor(TOPRIGHT,ESO_SM_TXTSHCRP,TOPRIGHT,31,-5)
		--Call for SetChatListRP set to the Complete Bottom to Avoid nil errors
		
		--CHAT Container -- LINKED: ALL CHATS
		ESO_SM_CHATCONTRP = WINDOW_MANAGER:CreateControl("ESO_SM_CHATCONTRP",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_CHATCONTRP:SetDimensions(0,0)
		ESO_SM_CHATCONTRP:SetAnchor(TOPLEFT,ESO_SM_LINECHATSRP2,TOPLEFT,6,0)
		
		--Placing of Channellist to listen to
		ESO_SM_CBOX_ChatRP = {}
		ESO_SM_TXT_ChatRP = {}
		--0 Say ,1 Yell,4 Tell,6 Emote,8 NSC,12 Guild1,13 Guild2,14 Guild3,15 Guild4,16 Guild5,17 GuildOfficer1,18 GuildOfficer2,19 GuildOfficer3,20 GuildOfficer4,21 GuildOfficer5,31 Gebiet
		chatstocheckRP = {{0,"Say"}, {12,"G1"}, {17,"O1"}, {1,"Yell"}, {13,"G2"}, {18,"O2"}, {4,"Tell"}, {14,"G3"}, {19,"O3"}, {6,"Emote"}, {15,"G4"}, {20,"O4"}, {31,"Zone"}, {16,"G5"}, {21,"O5"}, {3,"Group"}}
		for i=1,table.getn(chatstocheckRP),1 do
			ESO_SM_CBOX_ChatRP[i] = WINDOW_MANAGER:CreateControl("BOXCRP"..i,ESO_SM_CHATCONTRP,CT_BUTTON)
			ESO_SM_CBOX_ChatRP[i]:SetDimensions(25,25)
			ESO_SM_CBOX_ChatRP[i]:SetAnchor(TOPLEFT,ESO_SM_CHATCONTRP,TOPLEFT,math.floor((i-1)/ESO_SM_CHATSPERCOL)*ESO_SM_EMOTESPACE,((i-1)%ESO_SM_CHATSPERCOL)*ESO_SM_ROWDISTANCE)
			ESO_SM_CBOX_ChatRP[i]:SetHandler("OnClicked",function() ESO_SM.switchmodechatRP(i,ESO_SM_CBOX_ChatRP[i],chatstocheckRP[i][1]) end)
			ESO_SM_CBOX_ChatRP[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
			ESO_SM_CBOX_ChatRP[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
			ESO_SM_TXT_ChatRP[i] = WINDOW_MANAGER:CreateControl("ESO_SM_TXTCRP"..i,ESO_SM_CHATCONTRP,CT_LABEL)
			ESO_SM_TXT_ChatRP[i]:SetFont("ZoFontGame")
			if GetDynamicChatChannelName(chatstocheckRP[i][1]) == "" then
				checktextRP = chatstocheckRP[i][2]
			else
				if (string.len (GetDynamicChatChannelName(chatstocheckRP[i][1])) >=16) then
					checktextRP = chatstocheckRP[i][2] .. ": " .. string.sub (GetDynamicChatChannelName(chatstocheckRP[i][1]), 1, 15) .."."
				else
					checktextRP = chatstocheckRP[i][2] .. ": " .. GetDynamicChatChannelName(chatstocheckRP[i][1])
				end
			end
			ESO_SM_TXT_ChatRP[i]:SetText("|c888866" .. checktextRP)
			ESO_SM_TXT_ChatRP[i]:SetAnchor(TOPLEFT,ESO_SM_CBOX_ChatRP[i],TOPLEFT,28,2)
			ESO_SM.setmodechatRP(i,ESO_SM_CBOX_ChatRP[i])
		end

--------------------------------------------------------------------------------------------------------------------------
-- SETTINGS -- SETTINGS -- SETTINGS -- SETTINGS -- SETTINGS -- SETTINGS -- SETTINGS -- SETTINGS -- SETTINGS -- SETTINGS --
--------------------------------------------------------------------------------------------------------------------------

		--SETTINGS LINE1 -- LINKED: ESO_SM_SETT_I, ESO_SM_TXTSHS
		ESO_SM_LINESETT1 = WINDOW_MANAGER:CreateControl("ESO_SM_LINESETT1",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINESETT1:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINESETT1:SetAnchor(TOPLEFT,ESO_SM_LINECHATS2,TOPLEFT,0,0)
		ESO_SM_LINESETT1:SetTexture("/esoui/art/progression/ability_line.dds")

		--Settings text
		ESO_SM_SETT_I = WINDOW_MANAGER:CreateControl("ESO_SM_SETT_I",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_SETT_I:SetDimensions(35,35)
		ESO_SM_SETT_I:SetAnchor(TOPLEFT,ESO_SM_LINESETT1,TOPLEFT,-3,-3)
		ESO_SM_SETT_I:SetTexture("/esoui/art/menubar/menubar_mainmenu_over.dds")
		ESO_SM_SETT = WINDOW_MANAGER:CreateControl("ESO_SM_SETT",SyncMotesMenu,CT_LABEL)
		ESO_SM_SETT:SetText(" - |c880000Settings:")
		ESO_SM_SETT:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_SETT:SetAnchor(TOPLEFT,ESO_SM_SETT_I,TOPLEFT,30,8)

		--Show/Hide Settings Button
		ESO_SM_TXTSHS = WINDOW_MANAGER:CreateControl("TXTSHS",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTSHS:SetFont("ZoFontGame")
		ESO_SM_TXTSHS:SetText("Show Settings")
		ESO_SM_TXTSHS:SetAnchor(TOPRIGHT,ESO_SM_LINESETT1,TOPRIGHT,-30,5)
		ESO_SM_BTNSHS = WINDOW_MANAGER:CreateControl("ESO_SM_BTNSHS",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNSHS:SetDimensions(30,30)
		ESO_SM_BTNSHS:SetHandler("OnClicked",ESO_SM.SwitchSettingsList)
		ESO_SM_BTNSHS:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHS:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_BTNSHS:SetAnchor(TOPRIGHT,ESO_SM_TXTSHS,TOPRIGHT,31,-5)
		--Call for SetSettingsList set to the Complete Bottom to Avoid nil errors

		--SETTINGS LINE2 -- LINKED: ESO_SM_CHATCONT
		ESO_SM_LINESETT2 = WINDOW_MANAGER:CreateControl("ESO_SM_LINESETT2",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINESETT2:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINESETT2:SetAnchor(TOPLEFT,ESO_SM_LINESETT1,TOPLEFT,0,30)
		ESO_SM_LINESETT2:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--SETTINGS Container -- LINKED: ALL CHATS
		ESO_SM_SETTCONT = WINDOW_MANAGER:CreateControl("ESO_SM_SETTCONT",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_SETTCONT:SetDimensions(0,0)
		ESO_SM_SETTCONT:SetAnchor(TOPLEFT,ESO_SM_LINESETT2,TOPLEFT,6,0)
		
		--Enable / Disable SyncMotes Text -- LINKED: ESO_SM_SMSTATUS_I
		ESO_SM_TXTENDI = WINDOW_MANAGER:CreateControl("ESO_SM_TXTENDI",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTENDI:SetText("|c00ff00Enable |r/ |cff0000Disable|r |c880000SyncMotes|r:")
		ESO_SM_TXTENDI:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_TXTENDI:SetAnchor(TOPLEFT,ESO_SM_SETTCONT,TOPLEFT,0,5)
		
		--SetStatus icon -- LINKED: ESO_SM_ON, ESO_SM_OFF, ESO_SM_BOTDIV1
		ESO_SM_SMSTATUS_I = WINDOW_MANAGER:CreateControl("ESO_SM_SMSTATUS_I",ESO_SM_SETTCONT,CT_TEXTURE)
		ESO_SM_SMSTATUS_I:SetDimensions(50,50)
		ESO_SM_SMSTATUS_I:SetAnchor(BOTTOMLEFT,ESO_SM_TXTENDI,BOTTOMLEFT,-12,50)
		ESO_SM_SMSTATUS_I:SetTexture("/esoui/art/charactercreate/charactercreate_bodyicon_up.dds")
		
		--ON Button
		ESO_SM_ON = WINDOW_MANAGER:CreateControl("ESO_SM_ON",ESO_SM_SETTCONT,CT_BUTTON)
		ESO_SM_ON:SetDimensions(20,18)
		ESO_SM_ON:SetHandler("OnClicked",ESO_SM.activate)
		ESO_SM_ON:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
		ESO_SM_ON:SetMouseOverTexture("/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds")
		ESO_SM_ON:SetAnchor(TOPLEFT,ESO_SM_SMSTATUS_I,TOPLEFT,50,15)
		ESO_SM_TXTON = WINDOW_MANAGER:CreateControl("ESO_SM_TXTON",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTON:SetFont("ZoFontGame")
		ESO_SM_TXTON:SetText("|c00ff00On|r")
		ESO_SM_TXTON:SetAnchor(TOPLEFT,ESO_SM_ON,TOPLEFT,28,-2)
		
		--OFF Button
		ESO_SM_OFF = WINDOW_MANAGER:CreateControl("ESO_SM_OFF",ESO_SM_SETTCONT,CT_BUTTON)
		ESO_SM_OFF:SetDimensions(20,18)
		ESO_SM_OFF:SetHandler("OnClicked",ESO_SM.deactivate)
		ESO_SM_OFF:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
		ESO_SM_OFF:SetMouseOverTexture("/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds")
		ESO_SM_OFF:SetAnchor(TOPLEFT,ESO_SM_SMSTATUS_I,TOPLEFT,110,15)
		ESO_SM_TXTOFF = WINDOW_MANAGER:CreateControl("ESO_SM_TXTOFF",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTOFF:SetFont("ZoFontGame")
		ESO_SM_TXTOFF:SetText("|cff0000Off|r")
		ESO_SM_TXTOFF:SetAnchor(TOPLEFT,ESO_SM_OFF,TOPLEFT,28,-2)
		
		--SyncMotes Settings Description
		ESO_SM_TXTDISBOX = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_TXTDISBOX", ESO_SM_SETTCONT, "ZO_ScrollContainer")
		ESO_SM_TXTDISBOX:SetDimensions(ESO_SM_MAXWIDTH-250,90)
		ESO_SM_TXTDISBOX:SetAnchor(TOPLEFT,ESO_SM_TXTENDI,TOPLEFT,250,0)
		ESO_SM_TXTDIS = WINDOW_MANAGER:CreateControl("ESO_SM_TXTDIS",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTDIS:SetFont("ZoFontGame")
		ESO_SM_TXTDIS:SetText("|c880000SM Settings Description:|r If SyncMotes is set to On, you will do Emotes selected in the SyncMotes Emote-List if the Command is prompted in one of the selected SyncMotes Chats. If SyncMotes is set to Off, you will not do any SyncMotes Emotes, but will still be able to give SyncMotes Commands.")
		ESO_SM_TXTDIS:SetAnchorFill(ESO_SM_TXTDISBOX)
		
		--BOTTOM DIVIDER SyncMotes
		ESO_SM_BOTDIV1 = WINDOW_MANAGER:CreateControl("ESO_SM_BOTDIV1",ESO_SM_SETTCONT,CT_TEXTURE)
		ESO_SM_BOTDIV1:SetDimensions(ESO_SM_MAXWIDTH,5)
		ESO_SM_BOTDIV1:SetAnchor(BOTTOMLEFT,ESO_SM_SMSTATUS_I,BOTTOMLEFT,4,5)
		ESO_SM_BOTDIV1:SetTexture("/esoui/art/quest/questjournal_divider.dds")

		--Enable / Disable SynPhrases Text -- LINKED: ESO_SM_SMSTATUS_IRP
		ESO_SM_TXTENDIRP = WINDOW_MANAGER:CreateControl("ESO_SM_TXTENDIRP",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTENDIRP:SetText("|c00ff00Enable |r/ |cff0000Disable|r |c5555ffSyncPhrases|r:")
		ESO_SM_TXTENDIRP:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_TXTENDIRP:SetAnchor(TOPLEFT,ESO_SM_SETTCONT,TOPLEFT,0,85)
		
		--SetStatus icon RP -- LINKED: ESO_SM_ONRP, ESO_SM_OFFRP, ESO_SM_BOTDIV2
		ESO_SM_SMSTATUS_IRP = WINDOW_MANAGER:CreateControl("ESO_SM_SMSTATUS_IRP",ESO_SM_SETTCONT,CT_TEXTURE)
		ESO_SM_SMSTATUS_IRP:SetDimensions(50,50)
		ESO_SM_SMSTATUS_IRP:SetAnchor(BOTTOMLEFT,ESO_SM_TXTENDIRP,BOTTOMLEFT,-12,50)
		ESO_SM_SMSTATUS_IRP:SetTexture("/esoui/art/menubar/menubar_social_over.dds")
		
		--ON RP Button
		ESO_SM_ONRP = WINDOW_MANAGER:CreateControl("ESO_SM_ONRP",ESO_SM_SETTCONT,CT_BUTTON)
		ESO_SM_ONRP:SetDimensions(20,18)
		ESO_SM_ONRP:SetHandler("OnClicked",ESO_SM.activateRP)
		ESO_SM_ONRP:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
		ESO_SM_ONRP:SetMouseOverTexture("/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds")
		ESO_SM_ONRP:SetAnchor(TOPLEFT,ESO_SM_SMSTATUS_IRP,TOPLEFT,50,15)
		ESO_SM_TXTONRP = WINDOW_MANAGER:CreateControl("ESO_SM_TXTONRP",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTONRP:SetFont("ZoFontGame")
		ESO_SM_TXTONRP:SetText("|c00ff00On|r")
		ESO_SM_TXTONRP:SetAnchor(TOPLEFT,ESO_SM_ONRP,TOPLEFT,28,-2)		
		
		--OFF RP Button
		ESO_SM_OFFRP = WINDOW_MANAGER:CreateControl("ESO_SM_OFFRP",ESO_SM_SETTCONT,CT_BUTTON)
		ESO_SM_OFFRP:SetDimensions(20,18)
		ESO_SM_OFFRP:SetHandler("OnClicked",ESO_SM.deactivateRP)
		ESO_SM_OFFRP:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
		ESO_SM_OFFRP:SetMouseOverTexture("/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds")
		ESO_SM_OFFRP:SetAnchor(TOPLEFT,ESO_SM_SMSTATUS_IRP,TOPLEFT,110,15)
		ESO_SM_TXTOFFRP = WINDOW_MANAGER:CreateControl("ESO_SM_TXTOFFRP",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTOFFRP:SetFont("ZoFontGame")
		ESO_SM_TXTOFFRP:SetText("|cff0000Off|r")
		ESO_SM_TXTOFFRP:SetAnchor(TOPLEFT,ESO_SM_OFFRP,TOPLEFT,28,-2)

		--SyncPhrases Settings Description
		ESO_SM_TXTDISBOXRP = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_TXTDISBOXRP", ESO_SM_SETTCONT, "ZO_ScrollContainer")
		ESO_SM_TXTDISBOXRP:SetDimensions(ESO_SM_MAXWIDTH-250,90)
		ESO_SM_TXTDISBOXRP:SetAnchor(TOPLEFT,ESO_SM_TXTENDIRP,TOPLEFT,250,0)
		ESO_SM_TXTDISRP = WINDOW_MANAGER:CreateControl("ESO_SM_TXTDISRP",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTDISRP:SetFont("ZoFontGame")
		ESO_SM_TXTDISRP:SetText("|c5555ffSP Settings Description:|r If SyncPhrases is set to On, you will do Emotes selected in the SyncPhrases Emote-List if a defined SyncPhrase (see /sm phrase) is prompted in one of the selected SyncPhrase Chats. If SyncPhrases is set to Off, you will not do any SyncPhrase Emotes.")
		ESO_SM_TXTDISRP:SetAnchorFill(ESO_SM_TXTDISBOXRP)

		--BOTTOM DIVIDER SyncPhrases
		ESO_SM_BOTDIV2 = WINDOW_MANAGER:CreateControl("ESO_SM_BOTDIV2",ESO_SM_SETTCONT,CT_TEXTURE)
		ESO_SM_BOTDIV2:SetDimensions(ESO_SM_MAXWIDTH,5)
		ESO_SM_BOTDIV2:SetAnchor(BOTTOMLEFT,ESO_SM_SMSTATUS_IRP,BOTTOMLEFT,4,5)
		ESO_SM_BOTDIV2:SetTexture("/esoui/art/quest/questjournal_divider.dds")

		--Enable / Disable Case-Sensitivity Text --LINKED: ESO_SM_SMSTATUS_ICS
		ESO_SM_TXTENDICS = WINDOW_MANAGER:CreateControl("ESO_SM_TXTENDICS",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTENDICS:SetText("|c00ff00Enable |r/ |cff0000Disable|r |c888800CaseSensitivity|r:")
		ESO_SM_TXTENDICS:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_TXTENDICS:SetAnchor(TOPLEFT,ESO_SM_SETTCONT,TOPLEFT,0,165)

		--SetStatus icon CS -- LINKED: ESO_SM_ONCS, ESO_SM_OFFCS
		ESO_SM_SMSTATUS_ICS = WINDOW_MANAGER:CreateControl("ESO_SM_SMSTATUS_ICS",ESO_SM_SETTCONT,CT_TEXTURE)
		ESO_SM_SMSTATUS_ICS:SetDimensions(50,50)
		ESO_SM_SMSTATUS_ICS:SetAnchor(BOTTOMLEFT,ESO_SM_TXTENDICS,BOTTOMLEFT,-12,50)
		ESO_SM_SMSTATUS_ICS:SetTexture("/esoui/art/guild/tabicon_roster_up.dds")

		--ON CS Button
		ESO_SM_ONCS = WINDOW_MANAGER:CreateControl("ESO_SM_ONCS",ESO_SM_SETTCONT,CT_BUTTON)
		ESO_SM_ONCS:SetDimensions(20,18)
		ESO_SM_ONCS:SetHandler("OnClicked",ESO_SM.activateCS)
		ESO_SM_ONCS:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip.dds")
		ESO_SM_ONCS:SetMouseOverTexture("/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds")
		ESO_SM_ONCS:SetAnchor(TOPLEFT,ESO_SM_SMSTATUS_ICS,TOPLEFT,50,15)
		ESO_SM_TXTONCS = WINDOW_MANAGER:CreateControl("ESO_SM_TXTONCS",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTONCS:SetFont("ZoFontGame")
		ESO_SM_TXTONCS:SetText("|c00ff00On|r")
		ESO_SM_TXTONCS:SetAnchor(TOPLEFT,ESO_SM_ONCS,TOPLEFT,28,-2)		

		--OFF CS Button
		ESO_SM_OFFCS = WINDOW_MANAGER:CreateControl("ESO_SM_OFFCS",ESO_SM_SETTCONT,CT_BUTTON)
		ESO_SM_OFFCS:SetDimensions(20,18)
		ESO_SM_OFFCS:SetHandler("OnClicked",ESO_SM.deactivateCS)
		ESO_SM_OFFCS:SetNormalTexture("/esoui/art/charactercreate/triangle_selector_pip_disabled.dds")
		ESO_SM_OFFCS:SetMouseOverTexture("/esoui/art/charactercreate/triangle_selector_pip_mouseover.dds")
		ESO_SM_OFFCS:SetAnchor(TOPLEFT,ESO_SM_SMSTATUS_ICS,TOPLEFT,110,15)
		ESO_SM_TXTOFFCS = WINDOW_MANAGER:CreateControl("ESO_SM_TXTOFFCS",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTOFFCS:SetFont("ZoFontGame")
		ESO_SM_TXTOFFCS:SetText("|cff0000Off|r")
		ESO_SM_TXTOFFCS:SetAnchor(TOPLEFT,ESO_SM_OFFCS,TOPLEFT,28,-2)

		--CaseSensitivity Settings Description
		ESO_SM_TXTDISBOXCS = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_TXTDISBOXCS", ESO_SM_SETTCONT, "ZO_ScrollContainer")
		ESO_SM_TXTDISBOXCS:SetDimensions(ESO_SM_MAXWIDTH-250,90)
		ESO_SM_TXTDISBOXCS:SetAnchor(TOPLEFT,ESO_SM_TXTENDICS,TOPLEFT,250,0)
		ESO_SM_TXTDISCS = WINDOW_MANAGER:CreateControl("ESO_SM_TXTDISCS",ESO_SM_SETTCONT,CT_LABEL)
		ESO_SM_TXTDISCS:SetFont("ZoFontGame")
		ESO_SM_TXTDISCS:SetText("|c888800CS Settings Description:|r If CaseSensitivity is set to On, all Commands and Phrases are Case-Sensitive. If CaseSensitivity is set to Off, all Commands are not Case-Sensitive. That means for SyncMotes you can also use /sm HoRn instead of /sm horn, and for SyncPhrases if your Phrase is 'Hello', it will also respond to 'HeLLo'.")
		ESO_SM_TXTDISCS:SetAnchorFill(ESO_SM_TXTDISBOXCS)
		------------------------
		--Place all new Settings in Settings Container!!!
		------------------------

--------------------------------------------------------------------------------------------------------------------------
-- INFO/HELP -- INFO/HELP -- INFO/HELP -- INFO/HELP -- INFO/HELP -- INFO/HELP -- INFO/HELP -- INFO/HELP -- INFO/HELP --
--------------------------------------------------------------------------------------------------------------------------
		
		--INFO LINE1 -- LINKED: ESO_SM_INFO_I, ESO_SM_TXTSHI
		ESO_SM_LINEINFO1 = WINDOW_MANAGER:CreateControl("ESO_SM_LINEINFO1",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINEINFO1:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINEINFO1:SetAnchor(TOPLEFT,ESO_SM_LINESETT2,TOPLEFT,0,0)
		ESO_SM_LINEINFO1:SetTexture("/esoui/art/progression/ability_line.dds")

		--INFOings text
		ESO_SM_INFO_I = WINDOW_MANAGER:CreateControl("ESO_SM_INFO_I",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_INFO_I:SetDimensions(35,35)
		ESO_SM_INFO_I:SetAnchor(TOPLEFT,ESO_SM_LINEINFO1,TOPLEFT,-3,-3)
		ESO_SM_INFO_I:SetTexture("/esoui/art/help/help_tabicon_tutorial_up.dds")
		ESO_SM_INFO = WINDOW_MANAGER:CreateControl("ESO_SM_INFO",SyncMotesMenu,CT_LABEL)
		ESO_SM_INFO:SetText(" - |c880000Help / Info:")
		ESO_SM_INFO:SetFont("ZoFontGameLargeBoldShadow")
		ESO_SM_INFO:SetAnchor(TOPLEFT,ESO_SM_INFO_I,TOPLEFT,30,8)

		--Show/Hide Info Button
		ESO_SM_TXTSHI = WINDOW_MANAGER:CreateControl("TXTSHI",SyncMotesMenu,CT_LABEL)
		ESO_SM_TXTSHI:SetFont("ZoFontGame")
		ESO_SM_TXTSHI:SetText("Show Help / Info")
		ESO_SM_TXTSHI:SetAnchor(TOPRIGHT,ESO_SM_LINEINFO1,TOPRIGHT,-30,5)
		ESO_SM_BTNSHI = WINDOW_MANAGER:CreateControl("ESO_SM_BTNSHI",SyncMotesMenu,CT_BUTTON)
		ESO_SM_BTNSHI:SetDimensions(30,30)
		ESO_SM_BTNSHI:SetHandler("OnClicked",ESO_SM.SwitchInfoList)
		ESO_SM_BTNSHI:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHI:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_BTNSHI:SetAnchor(TOPRIGHT,ESO_SM_TXTSHI,TOPRIGHT,31,-5)
		--Call for SetInfoList set to the Complete Bottom to Avoid nil errors

		--INFO LINE2 -- LINKED: ESO_SM_CHATCONT
		ESO_SM_LINEINFO2 = WINDOW_MANAGER:CreateControl("ESO_SM_LINEINFO2",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_LINEINFO2:SetDimensions(ESO_SM_MAXWIDTH+10,2)
		ESO_SM_LINEINFO2:SetAnchor(TOPLEFT,ESO_SM_LINEINFO1,TOPLEFT,0,30)
		ESO_SM_LINEINFO2:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--INFO Container -- LINKED: ALL CHATS
		ESO_SM_INFOCONT = WINDOW_MANAGER:CreateControl("ESO_SM_INFOCONT",SyncMotesMenu,CT_TEXTURE)
		ESO_SM_INFOCONT:SetDimensions(0,0)
		ESO_SM_INFOCONT:SetAnchor(TOPLEFT,ESO_SM_LINEINFO2,TOPLEFT,6,0)
		
		--Infotext
		ESO_SM_TXTINFO1 = WINDOW_MANAGER:CreateControl("TXTINFO1",ESO_SM_INFOCONT,CT_LABEL)
		ESO_SM_TXTINFO1:SetFont("ZoFontGame")
		ESO_SM_TXTINFO1:SetText("INFO:\n|cffff00/sm menu|r - Opens this Menu (You can also set a Hotkey in the Settings of ESO)\n|cffff00/sm list|r - Shows the SyncMotes EmoteList\n|cffff00/sm on|r - Start listening to selected Chats\n|cffff00/sm off|r - Stop listening to selected Chats\n|cffff00/sm [EMOTE-ID]|r - Enters the SyncMotes command line into Chat !!(you need to hit Enter afterwards)!!\n|cffff00/sm [EMOTENAME]|r - Enters the SyncMotes command line into Chat !!(you need to hit Enter afterwards)!!\n|cffff00/sm add [Phrase] [YourDelay(ms)] [YourEmote-ID] [OthersDelay(ms)] [OthersEmote-ID]|r - Adds a SyncPhrase\n|cffff00/sm phrase|r - Shows the SyncPhrase config to add/edit/remove SyncPhrases (You can also set a Hotkey in the Settings of ESO)\n\n|cff0000Any suggestions? Send an ingame Mail (ESO-EU) to Dero or @Deryl\nPlease report any Errors/Bugs to me by Ingame mail or ESOUI.com Forum.")
		ESO_SM_TXTINFO1:SetAnchor(TOPLEFT,ESO_SM_INFOCONT,TOPLEFT,0,3)
		
		------------------------
		--Place all new Infos in INFO Container and adjust ESO_SM_INFOHEIGHT at the top of this script if requiered !!!
		------------------------
		
		--Set the Mode for the Lists
		ESO_SM.SetChatList()
		ESO_SM.SetEmoteList()
		ESO_SM.SetChatListRP()
		ESO_SM.SetEmoteListRP()
		ESO_SM.SetSettingsList()
		ESO_SM.SetInfoList()
		
		--Hide the Menu after building it up
		SyncMotesMenu:SetHidden(not SyncMotesMenu:IsHidden())
	end	
end

--Sets the correct Icon for Emotelist and Anchor for following Category Chatlist
function ESO_SM.SetEmoteList()
	if (ESO_SM_SavedData.EmotesHidden == 1) then
		ESO_SM_TXTSHE:SetText("Show Emotes")
		ESO_SM_BTNSHE:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHE:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_LINECHATS1:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES2,TOPLEFT,0,0)
		ESO_SM_EMOTECONT:SetHidden(true)
	else		
		ESO_SM_TXTSHE:SetText("Hide Emotes")
		ESO_SM_BTNSHE:SetNormalTexture("ESOUI/art/buttons/pointsminus_up.dds")
		ESO_SM_BTNSHE:SetMouseOverTexture("ESOUI/art/buttons/pointsminus_over.dds")
		ESO_SM_LINECHATS1:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTES2,TOPLEFT,0,ESO_SM_EMOTEPERCOL*ESO_SM_ROWDISTANCE+3)
		ESO_SM_EMOTECONT:SetHidden(false)
	end
	ESO_SM.AdjustMenuSize()
end

--Sets the correct Icon for Chatlist and Anchor for following Category EmotelistRP
function ESO_SM.SetChatList()
	if (ESO_SM_SavedData.ChatsHidden == 1) then
		ESO_SM_TXTSHC:SetText("Show Chats")
		ESO_SM_BTNSHC:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHC:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
--ANCHOR FOR EMOTELISTRP
ESO_SM_LINEEMOTESRP1:SetAnchor(TOPLEFT,ESO_SM_LINECHATS2,TOPLEFT,0,0)
		ESO_SM_CHATCONT:SetHidden(true)
	else
		ESO_SM_TXTSHC:SetText("Hide Chats")
		ESO_SM_BTNSHC:SetNormalTexture("ESOUI/art/buttons/pointsminus_up.dds")
		ESO_SM_BTNSHC:SetMouseOverTexture("ESOUI/art/buttons/pointsminus_over.dds")
--ANCHOR FOR EMOTELISTRPEXPANDED
ESO_SM_LINEEMOTESRP1:SetAnchor(TOPLEFT,ESO_SM_LINECHATS2,TOPLEFT,0,ESO_SM_CHATSPERCOL*ESO_SM_ROWDISTANCE+3)
		ESO_SM_CHATCONT:SetHidden(false)
	end
	ESO_SM.AdjustMenuSize()
end

--Sets the correct Icon for EmotelistRP
function ESO_SM.SetEmoteListRP()
	if (ESO_SM_SavedData.EmotesHiddenRP == 1) then
		ESO_SM_TXTSHERP:SetText("Show Emotes")
		ESO_SM_BTNSHERP:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHERP:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_LINECHATSRP1:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTESRP2,TOPLEFT,0,0)
		ESO_SM_EMOTECONTRP:SetHidden(true)
	else		
		ESO_SM_TXTSHERP:SetText("Hide Emotes")
		ESO_SM_BTNSHERP:SetNormalTexture("ESOUI/art/buttons/pointsminus_up.dds")
		ESO_SM_BTNSHERP:SetMouseOverTexture("ESOUI/art/buttons/pointsminus_over.dds")
		ESO_SM_LINECHATSRP1:SetAnchor(TOPLEFT,ESO_SM_LINEEMOTESRP2,TOPLEFT,0,ESO_SM_EMOTEPERCOL*ESO_SM_ROWDISTANCE+3)
		ESO_SM_EMOTECONTRP:SetHidden(false)
	end
	ESO_SM.AdjustMenuSize()
end

--Sets the correct Icon for ChatlistRP
function ESO_SM.SetChatListRP()
	if (ESO_SM_SavedData.ChatsHiddenRP == 1) then
		ESO_SM_TXTSHCRP:SetText("Show Chats")
		ESO_SM_BTNSHCRP:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHCRP:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_LINESETT1:SetAnchor(TOPLEFT,ESO_SM_LINECHATSRP2,TOPLEFT,0,0)
		ESO_SM_CHATCONTRP:SetHidden(true)
	else
		ESO_SM_TXTSHCRP:SetText("Hide Chats")
		ESO_SM_BTNSHCRP:SetNormalTexture("ESOUI/art/buttons/pointsminus_up.dds")
		ESO_SM_BTNSHCRP:SetMouseOverTexture("ESOUI/art/buttons/pointsminus_over.dds")
		ESO_SM_LINESETT1:SetAnchor(TOPLEFT,ESO_SM_LINECHATSRP2,TOPLEFT,0,ESO_SM_CHATSPERCOL*ESO_SM_ROWDISTANCE+3)
		ESO_SM_CHATCONTRP:SetHidden(false)
	end
	ESO_SM.AdjustMenuSize()
end

--Sets the correct Icon for Settingslist
function ESO_SM.SetSettingsList()
	if (ESO_SM_SavedData.SettingsHidden == 1) then
		ESO_SM_TXTSHS:SetText("Show Settings")
		ESO_SM_BTNSHS:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHS:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		ESO_SM_LINEINFO1:SetAnchor(TOPLEFT,ESO_SM_LINESETT2,TOPLEFT,0,0)
		ESO_SM_SETTCONT:SetHidden(true)
	else
		ESO_SM_TXTSHS:SetText("Hide Settings")
		ESO_SM_BTNSHS:SetNormalTexture("ESOUI/art/buttons/pointsminus_up.dds")
		ESO_SM_BTNSHS:SetMouseOverTexture("ESOUI/art/buttons/pointsminus_over.dds")
		ESO_SM_LINEINFO1:SetAnchor(TOPLEFT,ESO_SM_LINESETT2,TOPLEFT,0,ESO_SM_SETTINGSHEIGHT)
		ESO_SM_SETTCONT:SetHidden(false)
	end
	ESO_SM.AdjustMenuSize()
end

--Sets the correct Icon for Infolist
function ESO_SM.SetInfoList()
	if (ESO_SM_SavedData.InfoHidden == 1) then
		ESO_SM_TXTSHI:SetText("Show Help / Info")
		ESO_SM_BTNSHI:SetNormalTexture("ESOUI/art/buttons/pointsplus_up.dds")
		ESO_SM_BTNSHI:SetMouseOverTexture("ESOUI/art/buttons/pointsplus_over.dds")
		--RESETTING ANCHORS FOR NEXT CATEGORY!!!
		ESO_SM_INFOCONT:SetHidden(true)
	else
		ESO_SM_TXTSHI:SetText("Hide Help / Info")
		ESO_SM_BTNSHI:SetNormalTexture("ESOUI/art/buttons/pointsminus_up.dds")
		ESO_SM_BTNSHI:SetMouseOverTexture("ESOUI/art/buttons/pointsminus_over.dds")
		--RESETTING ANCHORS FOR NEXT CATEGORY!!!
		ESO_SM_INFOCONT:SetHidden(false)
	end
	ESO_SM.AdjustMenuSize()
end

--Shows / Hides the Emotelist
function ESO_SM.SwitchEmoteList()
	if (ESO_SM_SavedData.EmotesHidden == 1) then
		ESO_SM_SavedData.EmotesHidden = 0
	else
		ESO_SM_SavedData.EmotesHidden = 1
	end
	ESO_SM.SetEmoteList()
end

--Shows / Hides the Chatlist
function ESO_SM.SwitchChatList()
	if (ESO_SM_SavedData.ChatsHidden == 1) then
		ESO_SM_SavedData.ChatsHidden = 0
	else
		ESO_SM_SavedData.ChatsHidden = 1
	end
	ESO_SM.SetChatList()
end

--Shows / Hides the EmotelistRP
function ESO_SM.SwitchEmoteListRP()
	if (ESO_SM_SavedData.EmotesHiddenRP == 1) then
		ESO_SM_SavedData.EmotesHiddenRP = 0
	else
		ESO_SM_SavedData.EmotesHiddenRP = 1
	end
	ESO_SM.SetEmoteListRP()
end

--Shows / Hides the ChatlistRP
function ESO_SM.SwitchChatListRP()
	if (ESO_SM_SavedData.ChatsHiddenRP == 1) then
		ESO_SM_SavedData.ChatsHiddenRP = 0
	else
		ESO_SM_SavedData.ChatsHiddenRP = 1
	end
	ESO_SM.SetChatListRP()
end

--Shows / Hides the Settingslist
function ESO_SM.SwitchSettingsList()
	if (ESO_SM_SavedData.SettingsHidden == 1) then
		ESO_SM_SavedData.SettingsHidden = 0
	else
		ESO_SM_SavedData.SettingsHidden = 1
	end
	ESO_SM.SetSettingsList()
end

--Shows / Hides the Infolist
function ESO_SM.SwitchInfoList()
	if (ESO_SM_SavedData.InfoHidden == 1) then
		ESO_SM_SavedData.InfoHidden = 0
	else
		ESO_SM_SavedData.InfoHidden = 1
	end
	ESO_SM.SetInfoList()
end

--Adjust the Menu Height depending on open Categories
function ESO_SM.AdjustMenuSize()
	ESO_SM_MAXHEIGHT = 27+30+30+30+30+30+30
	if (ESO_SM_SavedData.EmotesHidden == 0) then
		ESO_SM_MAXHEIGHT = ESO_SM_MAXHEIGHT + (ESO_SM_EMOTEPERCOL * ESO_SM_ROWDISTANCE+3)
	end
	if (ESO_SM_SavedData.EmotesHiddenRP == 0) then
		ESO_SM_MAXHEIGHT = ESO_SM_MAXHEIGHT + (ESO_SM_EMOTEPERCOL * ESO_SM_ROWDISTANCE+3)
	end
	if (ESO_SM_SavedData.ChatsHidden == 0) then
		ESO_SM_MAXHEIGHT = ESO_SM_MAXHEIGHT + (ESO_SM_CHATSPERCOL * ESO_SM_ROWDISTANCE+3)
	end
	if (ESO_SM_SavedData.ChatsHiddenRP == 0) then
		ESO_SM_MAXHEIGHT = ESO_SM_MAXHEIGHT + (ESO_SM_CHATSPERCOL * ESO_SM_ROWDISTANCE+3)
	end
	if (ESO_SM_SavedData.SettingsHidden == 0) then
		ESO_SM_MAXHEIGHT = ESO_SM_MAXHEIGHT + ESO_SM_SETTINGSHEIGHT
	end
	if (ESO_SM_SavedData.InfoHidden == 0) then
		ESO_SM_MAXHEIGHT = ESO_SM_MAXHEIGHT + ESO_SM_INFOHEIGHT
	end
	ESO_SM_MENU:SetDimensions(ESO_SM_MAXWIDTH,ESO_SM_MAXHEIGHT)
end

--Set the correct Icon for the EmoteMode
function ESO_SM.setmode(id,box)
	if (ESO_SM_SavedData.Mode[id] == 0) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end
	if (ESO_SM_SavedData.Mode[id] == 1) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end
end

--Set the correct Icon for the EmoteModeRP
function ESO_SM.setmodeRP(id,box)
	if (ESO_SM_SavedData.ModeRP[id] == 0) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end
	if (ESO_SM_SavedData.ModeRP[id] == 1) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end
end

--Switch the checked EmoteMode
function ESO_SM.switchmode(id,box)
	if (ESO_SM_SavedData.Mode[id] == 0) then
		ESO_SM_SavedData.Mode[id] = 1
		ESO_SM.setmode(id,box)
	elseif (ESO_SM_SavedData.Mode[id] == 1) then
		ESO_SM_SavedData.Mode[id] = 0
		ESO_SM.setmode(id,box)
	end
end

--Switch the checked EmoteModeRP
function ESO_SM.switchmodeRP(id,box)
	if (ESO_SM_SavedData.ModeRP[id] == 0) then
		ESO_SM_SavedData.ModeRP[id] = 1
		ESO_SM.setmodeRP(id,box)
	elseif (ESO_SM_SavedData.ModeRP[id] == 1) then
		ESO_SM_SavedData.ModeRP[id] = 0
		ESO_SM.setmodeRP(id,box)
	end
end

--Set the correct Icon for the ChatMode
function ESO_SM.setmodechat(id,box)
	if (ESO_SM_SavedData.ModeC[id] == 0) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end
	if (ESO_SM_SavedData.ModeC[id] == 1) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end
end

--Set the correct Icon for the ChatModeRP
function ESO_SM.setmodechatRP(id,box)
	if (ESO_SM_SavedData.ModeCRP[id] == 0) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end
	if (ESO_SM_SavedData.ModeCRP[id] == 1) then
		box:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		box:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end
end

--Switch the checked ChatMode
function ESO_SM.switchmodechat(id,box)
	if (ESO_SM_SavedData.ModeC[id] == 0) then
		ESO_SM_SavedData.ModeC[id] = 1
		ESO_SM.setmodechat(id,box)
	elseif (ESO_SM_SavedData.ModeC[id] == 1) then
		ESO_SM_SavedData.ModeC[id] = 0
		ESO_SM.setmodechat(id,box)
	end
end

--Switch the checked ChatModeRP
function ESO_SM.switchmodechatRP(id,box)
	if (ESO_SM_SavedData.ModeCRP[id] == 0) then
		ESO_SM_SavedData.ModeCRP[id] = 1
		ESO_SM.setmodechatRP(id,box)
	elseif (ESO_SM_SavedData.ModeCRP[id] == 1) then
		ESO_SM_SavedData.ModeCRP[id] = 0
		ESO_SM.setmodechatRP(id,box)
	end
end

--Uncheck all Emoteboxes
function ESO_SM.uncheckall()
	for i=1,GetNumEmotes(),1 do
		ESO_SM_SavedData.Mode[i] = 0
		ESO_SM_CBOX[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_CBOX[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end	
end

--Uncheck all EmoteboxesRP
function ESO_SM.uncheckallRP()
	for i=1,GetNumEmotes(),1 do
		ESO_SM_SavedData.ModeRP[i] = 0
		ESO_SM_CBOXRP[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_CBOXRP[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end	
end

--Check all Emoteboxes
function ESO_SM.checkall()
	for i=1,GetNumEmotes(),1 do
		ESO_SM_SavedData.Mode[i] = 1
		ESO_SM_CBOX[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_CBOX[i]:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end	
end

--Check all EmoteboxesRP
function ESO_SM.checkallRP()
	for i=1,GetNumEmotes(),1 do
		ESO_SM_SavedData.ModeRP[i] = 1
		ESO_SM_CBOXRP[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_CBOXRP[i]:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end	
end

--Uncheck all Chatboxes
function ESO_SM.uncheckallchat()
	for i=1,table.getn(chatstocheck),1 do
		ESO_SM_SavedData.ModeC[i] = 0
		ESO_SM_CBOX_Chat[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_CBOX_Chat[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end	
end

--Uncheck all ChatboxesRP
function ESO_SM.uncheckallchatRP()
	for i=1,table.getn(chatstocheckRP),1 do
		ESO_SM_SavedData.ModeCRP[i] = 0
		ESO_SM_CBOX_ChatRP[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
		ESO_SM_CBOX_ChatRP[i]:SetMouseOverTexture("ESOUI/art/cadwell/check.dds")
	end	
end

--Check all Chatboxes
function ESO_SM.checkallchat()
	for i=1,table.getn(chatstocheck),1 do
		ESO_SM_SavedData.ModeC[i] = 1
		ESO_SM_CBOX_Chat[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_CBOX_Chat[i]:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end	
end

--Check all ChatboxesRP
function ESO_SM.checkallchatRP()
	for i=1,table.getn(chatstocheckRP),1 do
		ESO_SM_SavedData.ModeCRP[i] = 1
		ESO_SM_CBOX_ChatRP[i]:SetNormalTexture("ESOUI/art/cadwell/checkboxicon_checked.dds")
		ESO_SM_CBOX_ChatRP[i]:SetMouseOverTexture("ESOUI/art/cadwell/checkboxicon_unchecked.dds")
	end	
end

--Defaultdata to load if there are no Savedvars (vllt. variable Arraygröße mit hilfe von Gentnumemotes() -Mode und table.getn(chatstocheck) -ModeC)
function ESO_SM.Initdata()
	ESO_SM_DATA = {
		["Mode"] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		["ModeRP"] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		["ModeC"] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		["ModeCRP"] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		["SynPhrase"] = {},
		CapsCheck = 0,
		IsActivated = 1,
		IsActivatedRP = 1,
		ChatsHidden = 1 ,
		ChatsHiddenRP = 1 ,
		EmotesHidden = 1 ,
		EmotesHiddenRP = 1 ,
		SettingsHidden = 1 ,
		InfoHidden = 1 ,
		["Tooltip"] = {"asd","das","dsa","ads"},
	}
end