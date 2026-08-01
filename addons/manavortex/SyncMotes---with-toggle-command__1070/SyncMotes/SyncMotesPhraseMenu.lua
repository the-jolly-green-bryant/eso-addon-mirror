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

PhraseListWidth = 350 --Max Width for the Phraselist
PhraseListHeight = 420

CurrPhrase = 1 --Current Phrase for the Phraselist

--Shows a List of SyncPhrases and their ID in a new Frame
function ESO_SM.buildPhraseList()
	if (PhraseList == nil) then
		--Frame for Phraselist
		ESO_SM_PL = WINDOW_MANAGER:CreateTopLevelWindow("PhraseList")
		ESO_SM_PL:SetDrawLayer(1)
		ESO_SM_PL:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
		ESO_SM_PL:SetDimensions(PhraseListWidth,PhraseListHeight)
		ESO_SM_PL:SetMouseEnabled(true)
		ESO_SM_PL:SetMovable(true)
		ESO_SM_PL_BG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BG",PhraseList,"ZO_DefaultBackdrop")
		
		--Headertext
		ESO_SM_PL_HEADER = WINDOW_MANAGER:CreateControl("ESO_SM_PL_HEAD",PhraseList,CT_LABEL)
		ESO_SM_PL_HEADER:SetText("|c880000SyncMotes|r - |c5555ffSyncPhrase config|r")
		ESO_SM_PL_HEADER:SetFont("ZoFontTooltipTitle")
		ESO_SM_PL_HEADER:SetAnchor(TOP,PhraseList,TOP,0,0)
		
		--X-Button to Close the Menu
		ESO_SM_PL_BTNCLOSE = WINDOW_MANAGER:CreateControl("ESO_SM_PL_BTNCLOSE",PhraseList,CT_BUTTON)
		ESO_SM_PL_BTNCLOSE:SetDimensions(20,20)
		ESO_SM_PL_BTNCLOSE:SetHandler("OnClicked",ESO_SM.openphrasemenu)
		ESO_SM_PL_BTNCLOSE:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
		ESO_SM_PL_BTNCLOSE:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")
		ESO_SM_PL_BTNCLOSE:SetAnchor(TOPRIGHT,PhraseList,TOPRIGHT,0,0)
		
		--Line Below Header LINKED: ESO_SM_PL_SCROLLBOX,
		ESO_SM_PL_LINE1 = WINDOW_MANAGER:CreateControl("ESO_SM_PL_LINE1",PhraseList,CT_TEXTURE)
		ESO_SM_PL_LINE1:SetDimensions(PhraseListWidth+10,2)
		ESO_SM_PL_LINE1:SetAnchor(TOPLEFT,PhraseList,TOPLEFT,-6,30)
		ESO_SM_PL_LINE1:SetTexture("/esoui/art/progression/ability_line.dds")
		
		--Scrolltextbox for Phrases LINKED: ESO_SM_PL_SCROLLBOXLINE, ESO_SM_PL_SCROLLBOXTEXT, ESO_SM_PL_SCROLLBOXSHOW
		ESO_SM_PL_SCROLLBOX = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_SCROLLBOX", PhraseList, "ZO_ScrollContainer")--WINDOW_MANAGER:CreateControl("ESO_SM_PL_SCROLLBOX",PhraseList,CT_SCROLL)
		ESO_SM_PL_SCROLLBOX:SetDimensions(PhraseListWidth,200)
		ESO_SM_PL_SCROLLBOX:SetAnchor(TOPLEFT,ESO_SM_PL_LINE1,TOPLEFT,6,0)

		--Scrolltextbox EndLine LINKED:
		ESO_SM_PL_SCROLLBOXLINE = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SCROLLBOXLINE",ESO_SM_PL_SCROLLBOX,CT_TEXTURE)
		ESO_SM_PL_SCROLLBOXLINE:SetDimensions(PhraseListWidth+10,2)
		ESO_SM_PL_SCROLLBOXLINE:SetAnchor(BOTTOMLEFT,ESO_SM_PL_SCROLLBOX,BOTTOMLEFT,-6,0)
		ESO_SM_PL_SCROLLBOXLINE:SetTexture("/esoui/art/progression/ability_line.dds")

		--Scrolltext SyncPhrase
		ESO_SM_PL_SCROLLBOXTEXT = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SCROLLBOXTEXT",ESO_SM_PL_SCROLLBOX,CT_LABEL)
		ESO_SM_PL_SCROLLBOXTEXT:SetText("Placeholder")
		ESO_SM_PL_SCROLLBOXTEXT:SetFont("ZoFontGame")
		ESO_SM_PL_SCROLLBOXTEXT:SetAnchorFill(ESO_SM_PL_SCROLLBOX)

		--Scrolltext Showing x of y phrases LINKED: ESO_SM_PL_LEFT, ESO_SM_PL_RIGHT
		ESO_SM_PL_SCROLLBOXSHOW = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SCROLLBOXSHOW",ESO_SM_PL_SCROLLBOX,CT_LABEL)
		ESO_SM_PL_SCROLLBOXSHOW:SetText("Showing Placeholder")
		ESO_SM_PL_SCROLLBOXSHOW:SetFont("ZoFontGame")
		ESO_SM_PL_SCROLLBOXSHOW:SetAnchor(BOTTOM,ESO_SM_PL_SCROLLBOX,BOTTOM,0,25)
		
		--Button Scrolltext left arrow
		ESO_SM_PL_LEFT = WINDOW_MANAGER:CreateControl("PL_LEFT",ESO_SM_PL_SCROLLBOXSHOW,CT_BUTTON)
		ESO_SM_PL_LEFT:SetDimensions(25,25)
		ESO_SM_PL_LEFT:SetHandler("OnClicked",ESO_SM.getbeforephrase)
		ESO_SM_PL_LEFT:SetNormalTexture("ESOUI/art/charactercreate/charactercreate_leftarrow_up.dds")
		ESO_SM_PL_LEFT:SetMouseOverTexture("ESOUI/art/charactercreate/charactercreate_leftarrow_over.dds")
		ESO_SM_PL_LEFT:SetAnchor(LEFT,ESO_SM_PL_SCROLLBOXSHOW,LEFT,-28,0)
		
		--Button Scrolltext right arrow
		ESO_SM_PL_RIGHT = WINDOW_MANAGER:CreateControl("PL_RIGHT",ESO_SM_PL_SCROLLBOXSHOW,CT_BUTTON)
		ESO_SM_PL_RIGHT:SetDimensions(25,25)
		ESO_SM_PL_RIGHT:SetHandler("OnClicked",ESO_SM.getnextphrase)
		ESO_SM_PL_RIGHT:SetNormalTexture("ESOUI/art/charactercreate/charactercreate_rightarrow_up.dds")
		ESO_SM_PL_RIGHT:SetMouseOverTexture("ESOUI/art/charactercreate/charactercreate_rightarrow_over.dds")
		ESO_SM_PL_RIGHT:SetAnchor(RIGHT,ESO_SM_PL_SCROLLBOXSHOW,RIGHT,28,0)

		--EditboxText for ID
		ESO_SM_PL_BOXIDTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_BOXIDTX",PhraseList,CT_LABEL)
		ESO_SM_PL_BOXIDTX:SetText("|c888866ID:")
		ESO_SM_PL_BOXIDTX:SetFont("ZoFontGame")
		ESO_SM_PL_BOXIDTX:SetAnchor(TOPLEFT,ESO_SM_PL_SCROLLBOXLINE,TOPLEFT,6,30)
		--Editbox for ID
		ESO_SM_PL_BOXIDBG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXIDBG", PhraseList, "ZO_EditBackdrop")
		ESO_SM_PL_BOXIDBG:SetDimensions(75,25)
		ESO_SM_PL_BOXIDBG:SetAnchor(TOPLEFT,ESO_SM_PL_SCROLLBOXLINE,TOPLEFT,100,30)
		ESO_SM_PL_BOXID = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXID", ESO_SM_PL_BOXIDBG, "ZO_DefaultEditForBackdrop")
		ESO_SM_PL_BOXID:SetResizeToFitDescendents(false)
		ESO_SM_PL_BOXID:SetMouseEnabled(false)
		ESO_SM_PL_BOXID:SetText("")
		
		--EditboxText for Phrase
		ESO_SM_PL_BOXPHTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_BOXPHTX",PhraseList,CT_LABEL)
		ESO_SM_PL_BOXPHTX:SetText("|c888866Phrase:")
		ESO_SM_PL_BOXPHTX:SetFont("ZoFontGame")
		ESO_SM_PL_BOXPHTX:SetAnchor(BOTTOMLEFT,ESO_SM_PL_BOXIDTX,BOTTOMLEFT,0,27)
		--Editbox for Phrase
		ESO_SM_PL_BOXPHBG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXPHBG", PhraseList, "ZO_EditBackdrop")
		ESO_SM_PL_BOXPHBG:SetDimensions(PhraseListWidth-100,25)
		ESO_SM_PL_BOXPHBG:SetAnchor(BOTTOMLEFT,ESO_SM_PL_BOXIDBG,BOTTOMLEFT,0,27)
		ESO_SM_PL_BOXPH = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXPH", ESO_SM_PL_BOXPHBG, "ZO_DefaultEditForBackdrop")
		ESO_SM_PL_BOXPH:SetResizeToFitDescendents(false)
		ESO_SM_PL_BOXPH:SetMouseEnabled(true)
		ESO_SM_PL_BOXPH:SetText("")

		--EditboxText for YourDelay
		ESO_SM_PL_BOXYDTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_BOXYDTX",PhraseList,CT_LABEL)
		ESO_SM_PL_BOXYDTX:SetText("|c888866Your Delay:")
		ESO_SM_PL_BOXYDTX:SetFont("ZoFontGame")
		ESO_SM_PL_BOXYDTX:SetAnchor(TOPLEFT,ESO_SM_PL_BOXPHTX,TOPLEFT,0,27)
		--Editbox for YourDelay
		ESO_SM_PL_BOXYDBG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXYDBG", PhraseList, "ZO_EditBackdrop")
		ESO_SM_PL_BOXYDBG:SetDimensions(75,25)
		ESO_SM_PL_BOXYDBG:SetAnchor(BOTTOMLEFT,ESO_SM_PL_BOXPHBG,BOTTOMLEFT,0,27)
		ESO_SM_PL_BOXYD = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXYD", ESO_SM_PL_BOXYDBG, "ZO_DefaultEditForBackdrop")
		ESO_SM_PL_BOXYD:SetResizeToFitDescendents(false)
		ESO_SM_PL_BOXYD:SetMouseEnabled(true)
		ESO_SM_PL_BOXYD:SetText("")

		--EditboxText for YourEmote
		ESO_SM_PL_BOXYETX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_BOXYETX",PhraseList,CT_LABEL)
		ESO_SM_PL_BOXYETX:SetText("|c888866Your Emote:")
		ESO_SM_PL_BOXYETX:SetFont("ZoFontGame")
		ESO_SM_PL_BOXYETX:SetAnchor(TOPLEFT,ESO_SM_PL_BOXYDTX,TOPLEFT,0,27)
		--Editbox for YourEmote
		ESO_SM_PL_BOXYEBG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXYEBG", PhraseList, "ZO_EditBackdrop")
		ESO_SM_PL_BOXYEBG:SetDimensions(75,25)
		ESO_SM_PL_BOXYEBG:SetAnchor(BOTTOMLEFT,ESO_SM_PL_BOXYDBG,BOTTOMLEFT,0,27)
		ESO_SM_PL_BOXYE = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXYE", ESO_SM_PL_BOXYEBG, "ZO_DefaultEditForBackdrop")
		ESO_SM_PL_BOXYE:SetResizeToFitDescendents(false)
		ESO_SM_PL_BOXYE:SetMouseEnabled(true)
		ESO_SM_PL_BOXYE:SetText("")

		--EditboxText for OtherDelay
		ESO_SM_PL_BOXODTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_BOXODTX",PhraseList,CT_LABEL)
		ESO_SM_PL_BOXODTX:SetText("|c888866Other Delay:")
		ESO_SM_PL_BOXODTX:SetFont("ZoFontGame")
		ESO_SM_PL_BOXODTX:SetAnchor(TOPLEFT,ESO_SM_PL_BOXYETX,TOPLEFT,0,27)
		--Editbox for OtherDelay
		ESO_SM_PL_BOXODBG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXODBG", PhraseList, "ZO_EditBackdrop")
		ESO_SM_PL_BOXODBG:SetDimensions(75,25)
		ESO_SM_PL_BOXODBG:SetAnchor(BOTTOMLEFT,ESO_SM_PL_BOXYEBG,BOTTOMLEFT,0,27)
		ESO_SM_PL_BOXOD = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXOD", ESO_SM_PL_BOXODBG, "ZO_DefaultEditForBackdrop")
		ESO_SM_PL_BOXOD:SetResizeToFitDescendents(false)
		ESO_SM_PL_BOXOD:SetMouseEnabled(true)
		ESO_SM_PL_BOXOD:SetText("")

		--EditboxText for OtherEmote
		ESO_SM_PL_BOXOETX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_BOXOETX",PhraseList,CT_LABEL)
		ESO_SM_PL_BOXOETX:SetText("|c888866Other Emote:")
		ESO_SM_PL_BOXOETX:SetFont("ZoFontGame")
		ESO_SM_PL_BOXOETX:SetAnchor(TOPLEFT,ESO_SM_PL_BOXODTX,TOPLEFT,0,27)
		--Editbox for OtherEmote
		ESO_SM_PL_BOXOEBG = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXOEBG", PhraseList, "ZO_EditBackdrop")
		ESO_SM_PL_BOXOEBG:SetDimensions(75,25)
		ESO_SM_PL_BOXOEBG:SetAnchor(BOTTOMLEFT,ESO_SM_PL_BOXODBG,BOTTOMLEFT,0,27)
		ESO_SM_PL_BOXOE = WINDOW_MANAGER:CreateControlFromVirtual("ESO_SM_PL_BOXOE", ESO_SM_PL_BOXOEBG, "ZO_DefaultEditForBackdrop")
		ESO_SM_PL_BOXOE:SetResizeToFitDescendents(false)
		ESO_SM_PL_BOXOE:SetMouseEnabled(true)
		ESO_SM_PL_BOXOE:SetText("")

		--Button Show Emotes
		ESO_SM_PL_SE = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SE",PhraseList,CT_BUTTON)
		ESO_SM_PL_SE:SetDimensions(150,25)
		ESO_SM_PL_SE:SetHandler("OnClicked",ESO_SM.ShowEmotesEdited)
		ESO_SM_PL_SE:SetNormalTexture("ESOUI/art/buttons/blade_closed_up.dds")
		ESO_SM_PL_SE:SetMouseOverTexture("ESOUI/art/buttons/blade_mouseover.dds")
		ESO_SM_PL_SE:SetAnchor(TOPLEFT,ESO_SM_PL_SCROLLBOXLINE,TOPLEFT,200,30)
		ESO_SM_PL_SETX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SETX",PhraseList,CT_LABEL)
		ESO_SM_PL_SETX:SetText("|c888866Show Emotes|r")
		ESO_SM_PL_SETX:SetFont("ZoFontGame")
		ESO_SM_PL_SETX:SetAnchor(CENTER,ESO_SM_PL_SE,CENTER,0,0)

		--Button Save Selected / New
		ESO_SM_PL_SS = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SS",PhraseList,CT_BUTTON)
		ESO_SM_PL_SS:SetDimensions(150,25)
		ESO_SM_PL_SS:SetHandler("OnClicked",ESO_SM.SaveEdiNew)
		ESO_SM_PL_SS:SetNormalTexture("ESOUI/art/buttons/blade_closed_up.dds")
		ESO_SM_PL_SS:SetMouseOverTexture("ESOUI/art/buttons/blade_mouseover.dds")
		ESO_SM_PL_SS:SetAnchor(TOPLEFT,ESO_SM_PL_SCROLLBOXLINE,TOPLEFT,200,95)
		ESO_SM_PL_SSTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_SSTX",PhraseList,CT_LABEL)
		ESO_SM_PL_SSTX:SetText("|c888866Save Edited / New")
		ESO_SM_PL_SSTX:SetFont("ZoFontGame")
		ESO_SM_PL_SSTX:SetAnchor(CENTER,ESO_SM_PL_SS,CENTER,0,0)

		--Button Create New
		ESO_SM_PL_CN = WINDOW_MANAGER:CreateControl("ESO_SM_PL_CN",PhraseList,CT_BUTTON)
		ESO_SM_PL_CN:SetDimensions(150,25)
		ESO_SM_PL_CN:SetHandler("OnClicked",ESO_SM.CreateNew)
		ESO_SM_PL_CN:SetNormalTexture("ESOUI/art/buttons/blade_closed_up.dds")
		ESO_SM_PL_CN:SetMouseOverTexture("ESOUI/art/buttons/blade_mouseover.dds")
		ESO_SM_PL_CN:SetAnchor(TOPLEFT,ESO_SM_PL_SS,TOPLEFT,0,32)
		ESO_SM_PL_CNTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_CNTX",PhraseList,CT_LABEL)
		ESO_SM_PL_CNTX:SetText("|c888866Create New")
		ESO_SM_PL_CNTX:SetFont("ZoFontGame")
		ESO_SM_PL_CNTX:SetAnchor(CENTER,ESO_SM_PL_CN,CENTER,0,0)

		--Button Delete Selected
		ESO_SM_PL_DS = WINDOW_MANAGER:CreateControl("ESO_SM_PL_DS",PhraseList,CT_BUTTON)
		ESO_SM_PL_DS:SetDimensions(150,25)
		ESO_SM_PL_DS:SetHandler("OnClicked",ESO_SM.DelSel)
		ESO_SM_PL_DS:SetNormalTexture("ESOUI/art/buttons/blade_closed_up.dds")
		ESO_SM_PL_DS:SetMouseOverTexture("ESOUI/art/buttons/blade_mouseover.dds")
		ESO_SM_PL_DS:SetAnchor(TOPLEFT,ESO_SM_PL_CN,TOPLEFT,0,32)
		ESO_SM_PL_DSTX = WINDOW_MANAGER:CreateControl("ESO_SM_PL_DSTX",PhraseList,CT_LABEL)
		ESO_SM_PL_DSTX:SetText("|c888866Delete Selected")
		ESO_SM_PL_DSTX:SetFont("ZoFontGame")
		ESO_SM_PL_DSTX:SetAnchor(CENTER,ESO_SM_PL_DS,CENTER,0,0)

		--BOTTOMRIGHT LINE
		ESO_SM_PL_LINEBOTTOMRIGHT1 = WINDOW_MANAGER:CreateControl("ESO_SM_PL_LINEBOTTOMRIGHT1",PhraseList,CT_TEXTURE)
		ESO_SM_PL_LINEBOTTOMRIGHT1:SetDimensions(PhraseListWidth,5)
		ESO_SM_PL_LINEBOTTOMRIGHT1:SetAnchor(BOTTOMRIGHT,PhraseList,BOTTOMRIGHT,5,35)
		ESO_SM_PL_LINEBOTTOMRIGHT1:SetTexture("/esoui/art/miscellaneous/wide_divider_left.dds")

		--Footertext
		ESO_SM_PL_FOOTER = WINDOW_MANAGER:CreateControl("ESO_SM_PL_FOOTER",PhraseList,CT_LABEL)
		ESO_SM_PL_FOOTER:SetText("Created by: |c880000(ESO-EU) Illuminati - Dero - @Deryl|r")
		ESO_SM_PL_FOOTER:SetFont("ZoFontGame")
		ESO_SM_PL_FOOTER:SetAnchor(BOTTOMRIGHT,PhraseList,BOTTOMRIGHT,0,30)

		--Hide the Menu after building it up
		PhraseList:SetHidden(not PhraseList:IsHidden())
	end
end

--Delete selected SyncPhrase
function ESO_SM.DelSel()
	IDToDel = ESO_SM_PL_BOXID:GetText()
	table.remove(ESO_SM_SavedData.SynPhrase, IDToDel)
	ESO_SM.UpdatePhraseListText(CurrPhrase)
end

--Clear the Inputboxes and prepare for new SyncPhrase
function ESO_SM.CreateNew()
	ESO_SM_PL_BOXID:SetText(table.getn(ESO_SM_SavedData.SynPhrase)+1)
	ESO_SM_PL_BOXPH:SetText("")
	ESO_SM_PL_BOXYD:SetText("")
	ESO_SM_PL_BOXYE:SetText("")
	ESO_SM_PL_BOXOD:SetText("")
	ESO_SM_PL_BOXOE:SetText("")
	ESO_SM_PL_SCROLLBOXTEXT:SetText("|c00ff00ID|r - Its automatic and can't be edited.\n|c00ff00Phrase|r - The Phrase to play an Emote to.\n|c00ff00Your Delay|r - Wait x ms if |cff0000YOU|r say the Phrase.\n|c00ff00Your Emote|r - Emote you play if |cff0000YOU|r say the Phrase. ('0' or 'none' = No Emote)\n|c00ff00Other Delay|r - Wait x ms if |cff0000OTHERS|r say the Phrase.\n|c00ff00Other Emote|r - Emote you play if |cff0000OTHERS|r say the Phrase. ('0' or 'none' = No Emote)")
	ESO_SM_PL_SCROLLBOXSHOW:SetText("Create a new SyncPhrase")
end

--shows phrase before current one
function ESO_SM.getbeforephrase()
	CurrPhrase = CurrPhrase - 1
	ESO_SM.UpdatePhraseListText(CurrPhrase)
end

--Save Edited / New SyncPhrase
function ESO_SM.SaveEdiNew()
	if(ESO_SM_PL_BOXPH:GetText() == "" or ESO_SM_PL_BOXYD:GetText() == "" or ESO_SM_PL_BOXYE:GetText() == "" or ESO_SM_PL_BOXOD:GetText() == "" or ESO_SM_PL_BOXOE:GetText() == "") then
		ESO_SM_PL_SCROLLBOXTEXT:SetText("Please fill out every Inputbox!")
	else
		NewAddPhrase = "Slaceholder " .. ESO_SM_PL_BOXPH:GetText() .. " " .. ESO_SM_PL_BOXYD:GetText() .. " " .. ESO_SM_PL_BOXYE:GetText() .. " " .. ESO_SM_PL_BOXOD:GetText() .. " " .. ESO_SM_PL_BOXOE:GetText()
		NewArgArray = {}
		NewArgArrayNum = 1
		for i in string.gmatch(NewAddPhrase, "%S+") do
			NewArgArray[NewArgArrayNum] = i
			NewArgArrayNum = NewArgArrayNum + 1
		end
		if(tonumber(ESO_SM_PL_BOXID:GetText()) > table.getn(ESO_SM_SavedData.SynPhrase)) then
			ESO_SM.AddPhrase(NewArgArray)
		else
			ESO_SM.AddPhrase(NewArgArray,tonumber(ESO_SM_PL_BOXID:GetText()))
		end
	end
end

--shows next phrase
function ESO_SM.getnextphrase()
	CurrPhrase = CurrPhrase + 1
	ESO_SM.UpdatePhraseListText(CurrPhrase)
end

--Updates the Phrasearray, the textbox and editboxes
function ESO_SM.UpdatePhraseListText(NextPhrase)
	PhraseListText = {}
	for i = 1, table.getn(ESO_SM_SavedData.SynPhrase) , 1 do		
		PhraseListText[i] = "|cff0000ID:|r " .. i .. "\n|cff0000Phrase:|r " .. ESO_SM_SavedData.SynPhrase[i][1] .. "\n|cff0000Delays:|r Your: " .. ESO_SM_SavedData.SynPhrase[i][2] .. " ms,  Others: " .. ESO_SM_SavedData.SynPhrase[i][4] .. " ms\n|cff0000Emotes:|r Your: " .. ESO_SM_SavedData.SynPhrase[i][3] .. " (" .. GetEmoteSlashNameByIndex(ESO_SM_SavedData.SynPhrase[i][3]) .. "),  Others: " .. ESO_SM_SavedData.SynPhrase[i][5] .. " (" .. GetEmoteSlashNameByIndex(ESO_SM_SavedData.SynPhrase[i][5]) ..  ")"
	end	
	if(tonumber(NextPhrase) > table.getn(ESO_SM_SavedData.SynPhrase)) then
		CurrPhrase = 1
		NextPhrase = CurrPhrase
	elseif(tonumber(NextPhrase) < 1) then
		CurrPhrase = table.getn(ESO_SM_SavedData.SynPhrase)
		NextPhrase = CurrPhrase
	end
	if(table.getn(ESO_SM_SavedData.SynPhrase) >= 1) then
		ESO_SM_PL_SCROLLBOXTEXT:SetText("Selected Phrase:\n" .. PhraseListText[NextPhrase] .. "\n\nTo Edit this SyncPhrase just edit the Parameters below and hit the [Save Edited / New] button.")
		ESO_SM_PL_BOXID:SetText(NextPhrase)
		ESO_SM_PL_BOXPH:SetText(ESO_SM_SavedData.SynPhrase[NextPhrase][1])
		ESO_SM_PL_BOXYD:SetText(ESO_SM_SavedData.SynPhrase[NextPhrase][2])
		ESO_SM_PL_BOXYE:SetText(GetEmoteSlashNameByIndex(ESO_SM_SavedData.SynPhrase[NextPhrase][3]):gsub("/", ""))
		if(ESO_SM_PL_BOXYE:GetText() == "")then
			ESO_SM_PL_BOXYE:SetText("none")
		end
		ESO_SM_PL_BOXOD:SetText(ESO_SM_SavedData.SynPhrase[NextPhrase][4])
		ESO_SM_PL_BOXOE:SetText(GetEmoteSlashNameByIndex(ESO_SM_SavedData.SynPhrase[NextPhrase][5]):gsub("/", ""))
		if(ESO_SM_PL_BOXOE:GetText() == "")then
			ESO_SM_PL_BOXOE:SetText("none")
		end
		ESO_SM_PL_SCROLLBOXSHOW:SetText("Showing ID: " .. NextPhrase .. " of " .. table.getn(ESO_SM_SavedData.SynPhrase))
	else
		ESO_SM.CreateNew()
	end
end