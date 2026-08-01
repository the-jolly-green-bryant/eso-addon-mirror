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

EmoteListWidth = 200
EmoteListHeight = 320

--Shows a List of SyncPhrases and their ID in a new Frame
function ESO_SM.buildEmoteMenu()
	if (EmoteList == nil) then
		--Frame for EmoteList
		ESO_SM_EL = WINDOW_MANAGER:CreateTopLevelWindow("EmoteList")
		ESO_SM_EL:SetDrawLayer(1)
		ESO_SM_EL:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
		ESO_SM_EL:SetDimensions(EmoteListWidth,EmoteListHeight)
		ESO_SM_EL:SetMouseEnabled(true)
		ESO_SM_EL:SetMovable(true)
		ESO_SM_EL_BG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_EL_BG",EmoteList,"ZO_DefaultBackdrop")
		
		--Headertext
		ESO_SM_EL_HEADER = WINDOW_MANAGER:CreateControl("ESO_SM_EL_HEAD",EmoteList,CT_LABEL)
		ESO_SM_EL_HEADER:SetText("|c880000SM|r - |c888866EmoteList|r")
		ESO_SM_EL_HEADER:SetFont("ZoFontTooltipTitle")
		ESO_SM_EL_HEADER:SetAnchor(TOP,EmoteList,TOP,0,0)
		
		--X-Button to Close the Menu
		ESO_SM_EL_BTNCLOSE = WINDOW_MANAGER:CreateControl("ESO_SM_EL_BTNCLOSE",EmoteList,CT_BUTTON)
		ESO_SM_EL_BTNCLOSE:SetDimensions(20,20)
		ESO_SM_EL_BTNCLOSE:SetHandler("OnClicked",ESO_SM.openemotemenu)
		ESO_SM_EL_BTNCLOSE:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
		ESO_SM_EL_BTNCLOSE:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")
		ESO_SM_EL_BTNCLOSE:SetAnchor(TOPRIGHT,EmoteList,TOPRIGHT,0,0)
		
		--Line Below Header LINKED: ESO_SM_EL_SCROLLBOX,
		ESO_SM_EL_LINE1 = WINDOW_MANAGER:CreateControl("ESO_SM_EL_LINE1",EmoteList,CT_TEXTURE)
		ESO_SM_EL_LINE1:SetDimensions(EmoteListWidth+10,2)
		ESO_SM_EL_LINE1:SetAnchor(TOPLEFT,EmoteList,TOPLEFT,-6,30)
		ESO_SM_EL_LINE1:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--Scrolltextbox for EMOTES LINKED: ESO_SM_EL_SCROLLBOXLINE
		ESO_SM_EL_SCROLLBOX = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_EL_SCROLLBOX", EmoteList, "ZO_ScrollList")
		ESO_SM_EL_SCROLLBOX:SetDimensions(EmoteListWidth,EmoteListHeight-30)
		ESO_SM_EL_SCROLLBOX:SetAnchor(TOPLEFT,ESO_SM_EL_LINE1,TOPLEFT,6,0)

		--Filling Data for Emotes
		ZO_ScrollList_AddDataType(ESO_SM_EL_SCROLLBOX, 1 , "SyncMotesEmoteMenu", 20,  ESO_SM.SetEmoteListItem)
		EmoteScrollList = ZO_ScrollList_GetDataList(ESO_SM_EL_SCROLLBOX)
		for i = 1, GetNumEmotes() do
			EmoteScrollList[i] = ZO_ScrollList_CreateDataEntry( 1, {EmoteName = GetEmoteSlashNameByIndex(i), EmoteID = i})
		end
		EmoteScrollList[GetNumEmotes()+1] = ZO_ScrollList_CreateDataEntry( 1, {EmoteName = "None", EmoteID = 0})
		
		--SyncPhraseButtons Container -- LINKED: ALL CHATS
		ESO_SM_SPBCONT = WINDOW_MANAGER:CreateControl("ESO_SM_SPBCONT",EmoteList,CT_TEXTURE)
		ESO_SM_SPBCONT:SetDimensions(0,0)
		ESO_SM_SPBCONT:SetAnchor(TOPLEFT,ESO_SM_EL_SCROLLBOX,BOTTOMLEFT,0,0)

		--Line Below Scrollist
		ESO_SM_PL_ELINE = WINDOW_MANAGER:CreateControl("ESO_SM_PL_ELINE",ESO_SM_SPBCONT,CT_TEXTURE)
		ESO_SM_PL_ELINE:SetDimensions(EmoteListWidth+10,2)
		ESO_SM_PL_ELINE:SetAnchor(TOPLEFT,ESO_SM_SPBCONT,TOPLEFT,-6,3)
		ESO_SM_PL_ELINE:SetTexture("/esoui/art/progression/ability_line.dds")

		--Selected Emote: Text
		ESO_SM_PL_SELETX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SELETX",ESO_SM_SPBCONT,CT_LABEL)
		ESO_SM_PL_SELETX:SetText("|c888866Emote:|r")
		ESO_SM_PL_SELETX:SetFont("ZoFontGame")
		ESO_SM_PL_SELETX:SetAnchor(TOPLEFT,ESO_SM_SPBCONT,TOPLEFT,0,5)

		--Fillable Text for Emote
		ESO_SM_PL_SELEFTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SELEFTX",ESO_SM_SPBCONT,CT_LABEL)
		ESO_SM_PL_SELEFTX:SetText("None")
		ESO_SM_PL_SELEFTX:SetFont("ZoFontGame")
		ESO_SM_PL_SELEFTX:SetAnchor(TOPLEFT,ESO_SM_SPBCONT,TOPLEFT,55,5)
		
		--Button take as Your Emote
		ESO_SM_PL_TYE = WINDOW_MANAGER:CreateControl("ESO_SM_PL_TYE",ESO_SM_SPBCONT,CT_BUTTON)
		ESO_SM_PL_TYE:SetDimensions(EmoteListWidth,25)
		ESO_SM_PL_TYE:SetHandler("OnClicked",ESO_SM.TakeAsYourEmote)
		ESO_SM_PL_TYE:SetNormalTexture("ESOUI/art/buttons/blade_closed_up.dds")
		ESO_SM_PL_TYE:SetMouseOverTexture("ESOUI/art/buttons/blade_mouseover.dds")
		ESO_SM_PL_TYE:SetAnchor(TOPLEFT,ESO_SM_SPBCONT,TOPLEFT,0,35)
		ESO_SM_PL_TYETX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_TYETX",ESO_SM_SPBCONT,CT_LABEL)
		ESO_SM_PL_TYETX:SetText("|c888866Take as Your Emote|r")
		ESO_SM_PL_TYETX:SetFont("ZoFontGame")
		ESO_SM_PL_TYETX:SetAnchor(CENTER,ESO_SM_PL_TYE,CENTER,0,0)

		--Button take as Other Emote
		ESO_SM_PL_TOE = WINDOW_MANAGER:CreateControl("ESO_SM_PL_TOE",ESO_SM_SPBCONT,CT_BUTTON)
		ESO_SM_PL_TOE:SetDimensions(EmoteListWidth,25)
		ESO_SM_PL_TOE:SetHandler("OnClicked",ESO_SM.TakeAsOtherEmote)
		ESO_SM_PL_TOE:SetNormalTexture("ESOUI/art/buttons/blade_closed_up.dds")
		ESO_SM_PL_TOE:SetMouseOverTexture("ESOUI/art/buttons/blade_mouseover.dds")
		ESO_SM_PL_TOE:SetAnchor(TOPLEFT,ESO_SM_SPBCONT,TOPLEFT,0,67)
		ESO_SM_PL_TOETX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_TOETX",ESO_SM_SPBCONT,CT_LABEL)
		ESO_SM_PL_TOETX:SetText("|c888866Take as Other Emote|r")
		ESO_SM_PL_TOETX:SetFont("ZoFontGame")
		ESO_SM_PL_TOETX:SetAnchor(CENTER,ESO_SM_PL_TOE,CENTER,0,0)

		--Hide the Menu after building it up
		EmoteList:SetHidden(not EmoteList:IsHidden())
	end
end

function ESO_SM.SetEmoteListItem(control,data)
	local ListedEmote = control:GetNamedChild( "Name" )
	ListedEmote:SetText(data.EmoteName .. " (ID: " .. data.EmoteID .. ")")	
	ListedEmote:SetWidth(EmoteListWidth - 8)
	ListedEmote:SetColor(0.53,0.53,0.4,1)
	ListedEmote:SetHandler("OnMouseDown",function() ListedEmote:SetColor(0.6,0,0,1) ESO_SM.PlayMote(data.EmoteID) ESO_SM_PL_SELEFTX:SetText(data.EmoteName) end)
	ListedEmote:SetHandler("OnMouseEnter",function() ListedEmote:SetColor(0.7,0.7,0.6,1) end)
	ListedEmote:SetHandler("OnMouseExit",function() ListedEmote:SetColor(0.53,0.53,0.4,1) end)
end

--Plays the selected Emote
function ESO_SM.PlayMote(arg)
	PlayEmoteByIndex(arg)
end

--Takes selected Emote as Your Emote
function ESO_SM.TakeAsYourEmote()
	ESO_SM_PL_BOXYE:SetText(ESO_SM_PL_SELEFTX:GetText())
end

--Takes selected Emote as Other Emote
function ESO_SM.TakeAsOtherEmote()
	ESO_SM_PL_BOXOE:SetText(ESO_SM_PL_SELEFTX:GetText())
end