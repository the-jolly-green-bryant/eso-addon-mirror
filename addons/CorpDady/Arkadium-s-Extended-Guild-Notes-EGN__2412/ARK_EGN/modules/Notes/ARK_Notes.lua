---------------------------------------------------------
--	ARKadium's Extended Guild Notes Notes file  	    -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 




ARK_EGN              	= ARK_EGN or {}
local EGN 			 	= ARK_EGN
EGN.Notes		 		= ARK_EGN.Notes or{}
local Notes				= ARK_EGN.Notes
Notes.sVars				= {}
Notes.savedVarsVersion 	= 2
Notes.default			= {
     uiTop         = 200, 
     uiLeft        = 200, 
}

Notes.note = {}
Notes.characterTexture = {}
Notes.roleString = {}
Notes.charString = {}
Notes.charStringReverse = {}

Notes.isNoteDirty = false

local wm = WINDOW_MANAGER

do

	function Notes.Initialize()
		--loads saved variables from file or default
		Notes.sVars = ZO_SavedVars:NewAccountWide( "ARK_EGN_SavedVariables", Notes.savedVarsVersion, "Notes", Notes.default )
		

		--initialize settings
		
		--init lists todo : put that in the language file
		Notes.characterTexture[11] = "ARK_EGN/textures/Notes/mag_dk.dds"
		Notes.characterTexture[12] = "ARK_EGN/textures/Notes/stam_dk.dds"
		Notes.characterTexture[21] = "ARK_EGN/textures/Notes/mag_nb.dds"
		Notes.characterTexture[22] = "ARK_EGN/textures/Notes/stam_nb.dds"
		Notes.characterTexture[31] = "ARK_EGN/textures/Notes/mag_sorc.dds"
		Notes.characterTexture[32] = "ARK_EGN/textures/Notes/stam_sorc.dds"
		Notes.characterTexture[41] = "ARK_EGN/textures/Notes/mag_temp.dds"
		Notes.characterTexture[42] = "ARK_EGN/textures/Notes/stam_temp.dds"
		Notes.characterTexture[51] = "ARK_EGN/textures/Notes/mag_ward.dds"
		Notes.characterTexture[52] = "ARK_EGN/textures/Notes/stam_ward.dds"	
		Notes.characterTexture[61] = "ARK_EGN/textures/Notes/mag_cro.dds"	
		Notes.characterTexture[62] = "ARK_EGN/textures/Notes/stam_cro.dds"	
		
		Notes.roleString[1] = "|ce0e0e0DMG. DEALER|r"
		Notes.roleString[2] = "|ce0e0e0HEALER|r"
		Notes.roleString[3] = "|ce0e0e0TANK|r"

		Notes.charString["000"] = "No Character"
		Notes.charString["121"] = "DK Stam DD"
		Notes.charString["123"] = "DK Stam Tank"
		Notes.charString["111"] = "DK Mag DD"
		Notes.charString["113"] = "DK Mag Tank"
		Notes.charString["221"] = "NB Stam DD"
		Notes.charString["223"] = "NB Stam Tank"
		Notes.charString["211"] = "NB Mag DD"
		Notes.charString["213"] = "NB Mag Tank"
		Notes.charString["321"] = "Sorc Stam DD"
		Notes.charString["311"] = "Sorc Mag DD"
		Notes.charString["421"] = "Temp Stam DD"
		Notes.charString["423"] = "Temp Stam Tank"
		Notes.charString["411"] = "Temp Mag DD"
		Notes.charString["412"] = "Temp Mag Heal"
		Notes.charString["413"] = "Temp Mag Tank"
		Notes.charString["521"] = "Ward Stam DD"
		Notes.charString["523"] = "Ward Stam Tank"
		Notes.charString["511"] = "Ward Mag DD"
		Notes.charString["512"] = "Ward Mag Heal"
		Notes.charString["621"] = "Cro Stam DD"
		Notes.charString["623"] = "Cro Stam Tank"
		Notes.charString["611"] = "Cro Mag DD"
		Notes.charString["612"] = "Cro Mag Heal"
	

		

		Notes.charStringReverse["No Character"] = "000" 
		Notes.charStringReverse["DK Stam DD"] = "121" 
		Notes.charStringReverse["DK Stam Tank"] = "123" 
		Notes.charStringReverse["DK Mag DD"] = "111" 
		Notes.charStringReverse["DK Mag Tank"] = "113" 
		Notes.charStringReverse["NB Stam DD"] = "221" 
		Notes.charStringReverse["NB Stam Tank"] = "223" 
		Notes.charStringReverse["NB Mag DD"] = "211" 
		Notes.charStringReverse["NB Mag Tank"] = "213" 
		Notes.charStringReverse["Sorc Stam DD"] = "321" 
		Notes.charStringReverse["Sorc Mag DD"] = "311" 
		Notes.charStringReverse["Temp Stam DD"] = "421" 
		Notes.charStringReverse["Temp Stam Tank"] = "423" 
		Notes.charStringReverse["Temp Mag DD"] = "411" 
		Notes.charStringReverse["Temp Mag Heal"] = "412" 
		Notes.charStringReverse["Temp Mag Tank"] = "413" 
		Notes.charStringReverse["Ward Stam DD"] = "521" 
		Notes.charStringReverse["Ward Stam Tank"] = "523" 
		Notes.charStringReverse["Ward Mag DD"] = "511" 
		Notes.charStringReverse["Ward Mag Heal"] = "512"
		Notes.charStringReverse["Cro Stam DD"] = "621" 
		Notes.charStringReverse["Cro Stam Tank"] = "623" 
		Notes.charStringReverse["Cro Mag DD"] = "611" 
		Notes.charStringReverse["Cro Mag Heal"] = "612"
	 
		
		--intialize ui
		Notes.InitUI()
		
		zo_callLater(function() EGN.Debug( "Notes","Module Loaded" ) end, 2600)
	end


	--[[***********************************************************************************************************
	*************************************                 UTILS               *************************************
	*************************************************************************************************************]] 


	--returns a single digit extracted from a 3 digit string
	-- digitIndex = 1,2 or 3
	function Notes.GetDigit(stringToExtractFrom, digitIndex)

		local digits = {} 
		
		digits[1], _ = math.modf(stringToExtractFrom/100)
		digits[2], _ = math.modf((stringToExtractFrom - digits[1]*100)/10)
		digits[3] = stringToExtractFrom - (digits[1]*100 + digits[2]*10)	

		return digits[digitIndex]
	end

	--returns a 3 digit string where one digit has been changed to newDigit's value
	-- digitIndex = 1,2 or 3
	function Notes.SetDigit(stringToInsertInto, digitIndex, newDigit)
		local digits = {} 
		
		digits[1], _ = math.modf(stringToInsertInto/100)
		digits[2], _ = math.modf((stringToInsertInto - digits[1]*100)/10)
		digits[3] = stringToInsertInto - (digits[1]*100 + digits[2]*10)	

		digits[digitIndex] = newDigit
		return digits[1]*100 + digits[2]*10 + digits[3]
	end


	-- return true if the given note contains "#EGN"
	-- indicating it's been formated for use with this addon
	function Notes.IsExtendedNote(note)
		if string.find(note, "#EGN") then return true end
		
		return false
	end

	--retrieves the guild note for specific user in specific guild
	--control is the guild note control in guild roster UI
	--returns memberNote 
	function Notes.GetMemberNote(control)

		local data = ZO_ScrollList_GetData(control:GetParent())
		
		return data.note	
		
	end

	--parses a string of characters
	--separator used is "#"
	--populates Notes.note[] with all the substrings found 
	function Notes.ParseNote(note)
		
		local lastHashTagOffset = 1, nextHashTagOffset, index
		index = 0
		nextHashTagOffset = string.find(note, "#",lastHashTagOffset+1)
		
		while nextHashTagOffset do
			index = index + 1
			Notes.note[index] = string.sub(note, lastHashTagOffset+1, nextHashTagOffset-1)
			--CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(Notes.note[index])
			lastHashTagOffset = nextHashTagOffset
			nextHashTagOffset = string.find(note, "#",lastHashTagOffset+1)
			
		end
		
	end


	-- returns a complete guild note string
	-- string is concatenation of every sub note from 1 through 14
	--parsing symbol is a "#"
	function Notes.ConcatenateNote()
		if Notes.note[1] ~= nil then
			return "#"..Notes.note[1].."#"..Notes.note[2].."#"..Notes.note[3].."#"..Notes.note[4].."#"..Notes.note[5].."#"..Notes.note[6].."#"..Notes.note[7].."#"..Notes.note[8].."#"..Notes.note[9].."#"..Notes.note[10].."#"..Notes.note[11].."#"..Notes.note[12].."#"..Notes.note[13].."#"..Notes.note[14].."#"
		else
			return ""
		end
	end

	--creates a string containing the class texture and role for a given character
	--addon currently lists 8 characters from index 1 to 8
	function Notes.GetCharacterString(charIndex)

		local characterString = "", charClass, charRole 
		
		--charcters are currently stored in subnotes 3 to 11 hence the "charIndex+2"
		charClass, _ = math.modf(Notes.note[charIndex+2]/10)
		charRole = Notes.note[charIndex+2] - charClass*10
		
		if charClass > 0 then
			characterString = "|t32:32:"..Notes.characterTexture[charClass].."|t  "..Notes.roleString[charRole]..string.char(13,10) 
		end 
		--CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage(characterString)
		return characterString
	end

	function Notes.GetPveLevelString()
		
		local levelsString = "", playerPveLevel 
		--Player PvE level
		playerPveLevel, _ = math.modf(Notes.note[11]/100)
		levelsString = GetString(ARK_EGN_PVE).." :  "
		
		if playerPveLevel == 1 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xoooo.dds|t"
		elseif playerPveLevel == 2 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xxooo.dds|t"
		elseif playerPveLevel == 3 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xxxoo.dds|t"
		elseif playerPveLevel == 4 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xxxxo.dds|t"
		elseif playerPveLevel == 5 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xxxxx.dds|t"
		else
		
		end
		--[[
		for i = 1, 5, 1 do
			if i<=playerPveLevel then
				--insert bright icon
				levelsString = levelsString.."|t32:32:ARK_EGN/textures/Notes/pve_01.dds|t"
			else
				--insert grayed icon
				levelsString = levelsString.."|t32:32:ARK_EGN/textures/Notes/pve_02.dds|t"		
			end
		end]]--
		
		if (Notes.GetDigit(Notes.note[11], 2) == 1) then
			levelsString = levelsString..string.char(13,10).."     Maelstrom : |t40:40:ARK_EGN/textures/Notes/champion_01.dds|t"
		end
		
		if (Notes.GetDigit(Notes.note[11], 3) == 1) then
			levelsString = levelsString..string.char(13,10).."     VDSA :          |t40:40:ARK_EGN/textures/Notes/champion_01.dds|t"
		end
		
		return levelsString
		
	end

	function Notes.GetPvpLevelString()
		
		local levelsString = "", playerPvpLevel 

		--Player PvP level
		playerPvpLevel, _ = math.modf(Notes.note[12]/100)
		levelsString = GetString(ARK_EGN_PVP).." :  "
		
		if playerPvpLevel == 1 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_x.dds|t"
		elseif playerPvpLevel == 2 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xx.dds|t"
		elseif playerPvpLevel == 3 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xxx.dds|t"
		elseif playerPvpLevel == 4 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xxxx.dds|t"
		elseif playerPvpLevel == 5 then
			levelsString = levelsString.."|t140:35:ARK_EGN/textures/Stars/ark_stars_xxxxx.dds|t"
		else
		
		end
		--[[
		for i = 1, 5, 1 do
			if i<=playerPvpLevel then
				--insert bright icon
				levelsString = levelsString.."|t32:32:ARK_EGN/textures/Notes/pvp_aldmeri_01.dds|t"
			else
				--insert grayed icon
				levelsString = levelsString.."|t32:32:ARK_EGN/textures/Notes/pvp_aldmeri_02.dds|t"		
			end
		end]]--
		
		if (Notes.GetDigit(Notes.note[12], 2) == 1) then       
			levelsString = levelsString..string.char(13,10).."     Emperor :      |t35:35:ARK_EGN/textures/Notes/emperor_01.dds|t"
		end
		
		if (Notes.GetDigit(Notes.note[12], 3) == 1) then
			levelsString = levelsString..string.char(13,10).."     Duelist :         |t35:35:ARK_EGN/textures/Notes/emperor_01.dds|t"
		end
		
		return levelsString
	end


	--resets to "" (empty chain) every tooltip field that needs to be
	function Notes.ClearUI()
		ARK_EGN_FakeTooltipBGQuote:SetText("")
		ARK_EGN_FakeTooltipBGCharLeft:SetText("")
		ARK_EGN_FakeTooltipBGCharRight:SetText("")
		ARK_EGN_FakeTooltipBGLevels:SetText("")
	end

	--return texture file for player's crest
	--if no image has been indicated in guild note then uses guild name to find a guild crest
	function Notes.GetPlayerCrest()

		if Notes.note[13] ~="" then
			return "esoui/art/"..Notes.note[13]..".dds"
		else
			local comboBox = WINDOW_MANAGER:GetControlByName("ZO_GuildSelectorComboBoxSelectedItemText")
			--retrieves guild Name from the combo box
			return "ARK_EGN/textures/"..comboBox:GetText()..".dds"
		end
	end


	--[[***********************************************************************************************************
	*************************************    OVERLOAD OF ZOS FUNCTIONS        *************************************
	*************************************       NOTE TOOLTIP DISPLAY          *************************************
	*************************************************************************************************************]] 

	--main display function
	--overload of zos mouseenter function
	-- display a custom "tooltip" instead of the regular one
	--control = the guild note icon in the roster UI
	function ZO_KeyboardGuildRosterRowNote_OnMouseEnter(control)
		
		local memberNote = Notes.GetMemberNote(control)
		
		if not Notes.IsExtendedNote(memberNote) then 
			--note is just a regular guild note -> display usual tooltip
			GUILD_ROSTER_KEYBOARD:Note_OnMouseEnter(control)
			return
		end
		
		--Process the note
		Notes.ParseNote(memberNote)
		--Clear the UI and then fill it up
		Notes.ClearUI()
		-- Player or guild Crest
		ARK_EGN_FakeTooltipBGCrest:SetTexture(Notes.GetPlayerCrest())
		-- Player Quote
		ARK_EGN_FakeTooltipBGQuote:SetText(Notes.note[14])
		
		--Player's Characters
		local numLinesChar, numLinesLevels, leftPanelString, rightPanelString, levelsPanelString
		numLinesChar = 0 
		numLinesLevels = 0
		leftPanelString = ""
		rightPanelString = ""
		levelsPanelString = ""
		
		--odd on the left panel/ even on the right panel
		for index =1, 8, 1 do
			if EGN.IsOdd(index) then 
				if (Notes.note[index+2] ~= "000") then numLinesChar = numLinesChar + 1 end
				leftPanelString = leftPanelString..Notes.GetCharacterString(index)
			else
				rightPanelString = rightPanelString..Notes.GetCharacterString(index)
			end
		end 
		ARK_EGN_FakeTooltipBGCharLeft:SetText(leftPanelString)
		ARK_EGN_FakeTooltipBGCharRight:SetText(rightPanelString)
		
		--player pve and pvp levels
		levelsPanelString = Notes.GetPveLevelString()
		levelsPanelString = levelsPanelString..string.char(13,10)..Notes.GetPvpLevelString()
		ARK_EGN_FakeTooltipBGLevels:SetText(levelsPanelString)
		
		--sets the height of the panels according to the number of lines displayed
		numLinesLevels = Notes.GetDigit(Notes.note[11], 2) + Notes.GetDigit(Notes.note[11], 3) + Notes.GetDigit(Notes.note[12], 2) + Notes.GetDigit(Notes.note[12], 3)
		ARK_EGN_FakeTooltipBGCharLeft:SetHeight(20 + numLinesChar*45) 
		ARK_EGN_FakeTooltipBGCharRight:SetHeight(20 + numLinesChar*45)
		ARK_EGN_FakeTooltipBGLevels:SetHeight(60 + numLinesLevels*38)
		ARK_EGN_FakeTooltipBG:SetDimensionConstraints(384, 224 + numLinesChar*45 + numLinesLevels*38, 384, 224 + numLinesChar*45 + numLinesLevels*38) 
		
		--display the tooltip
		InitializeTooltip(ARK_EGN_FakeTooltip, control, TOPLEFT, -385, 15 + numLinesChar*22 + numLinesLevels*18, TOPLEFT)
		
	end

	--overload of zos mouseexit function
	-- hide the custom "tooltip"
	--control = the guild note icon in the roster UI
	function ZO_KeyboardGuildRosterRowNote_OnMouseExit(control)
		ClearTooltip(ARK_EGN_FakeTooltip)
		GUILD_ROSTER_KEYBOARD:Note_OnMouseExit(control)	
	end


	--[[***********************************************************************************************************
	*************************************             UI MANAGEMENT           *************************************
	*************************************      DISPLAY OF THE NOTE HELPER     *************************************
	*************************************************************************************************************]] 

	--called by the UI (see xml file)
	--save new UI position
	function Notes.OnUIMoveStop()
	  Notes.sVars.uiTop = ARK_EGN_NoteHelper:GetTop()
	  Notes.sVars.uiLeft = ARK_EGN_NoteHelper:GetLeft()
	end

	--reset the Ui anchor to the saved position
	function Notes.RestoreUIPosition()
	  local left = Notes.sVars.uiLeft
	  local top = Notes.sVars.uiTop
	 
	  ARK_EGN_NoteHelper:ClearAnchors()
	  ARK_EGN_NoteHelper:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end

	--attach the notehelper ui to the note edit
	-- creates the 8 ui comboboxes
	--adds a teleport button
	function Notes.InitUI()

		--attach our ui helper to the note edit dialog
		ZO_EditNoteDialog:SetDimensionConstraints(0, 0, 404, 450) 
		ARK_EGN_NoteHelper:SetParent(ZO_EditNoteDialog)
		Notes.RestoreUIPosition()
		--ARK_EGN_NoteHelper:SetAnchor(TOPLEFT, ZO_EditNoteDialogNoteEdit, TOPLEFT, 260, 640)  

		--create comboboxes
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar1)
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar2)
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar3)
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar4)
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar5)
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar6)
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar7)
		Notes.CreateComboBox(ARK_EGN_NoteHelperChar8)

	 end
	 
	--called by the callback of the combobox dropdown
	--somehow, must be placed before the registering function 
	local function OnDropdownChangeValue(dropdown, value)
		
		--CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage("|CFF0000 DropDown |r")
		local newValue = Notes.charStringReverse[value]
		if newValue ~= Notes.note[dropdown.comboBoxIndex+2] then
			Notes.note[dropdown.comboBoxIndex+2] = newValue
			
			ZO_EditNoteDialogNoteEdit:SetText(Notes.ConcatenateNote())
		end		
		
	end 

	 --creates and populates a combobox
	 --parent : ui container for the combobox
	function Notes.CreateComboBox(parent)
		
		--creates combobox
		local comboBox = WINDOW_MANAGER:CreateControlFromVirtual(parent:GetName().."ComboBox", parent, "ZO_ComboBox")
		
		comboBox:SetAnchor(TOPLEFT, parent, TOPLEFT, 52,0)
		comboBox:SetDimensions(130,25)
		
		--retrives the dropdown object from the combobox
		local dropdown = ZO_ComboBox_ObjectFromContainer(comboBox)
		
		dropdown.comboBoxIndex = string.sub(parent:GetName(), string.len(parent:GetName()) ) 
		dropdown:ClearItems() 

		local dropDownList = {"No Character", "DK Stam DD", "DK Stam Tank", "DK Mag DD", "DK Mag Tank", "NB Stam DD", "NB Stam Tank", "NB Mag DD", "NB Mag Tank", "Sorc Stam DD", "Sorc Mag DD", "Temp Stam DD", "Temp Stam Tank", "Temp Mag DD", "Temp Mag Heal", "Temp Mag Tank","Ward Stam DD", "Ward Stam Tank", "Ward Mag DD", "Ward Mag Heal","Cro Stam DD", "Cro Stam Tank", "Cro Mag DD", "Cro Mag Heal"}

		for i = 1, #dropDownList do
			local entry = dropdown:CreateItemEntry(dropDownList[i], OnDropdownChangeValue)
			dropdown:AddItem(entry,2) -- 2 means no sorting of the values
		end 
		
		return comboBox
	end

	--note helper just got displayed on screen along with note edit
	--extract note content and populates UI values
	function Notes.OnEffectivelyShownNoteHelper(control)
		
		if not Notes.IsExtendedNote(ZO_EditNoteDialogNoteEdit:GetText()) then 
		--note is just a regular guild note -> replace it with pre-formated EGN
			Notes.note[1] ="EGN1"
			Notes.note[2] ="0"
			Notes.note[3] ="000"
			Notes.note[4] ="000"
			Notes.note[5] ="000"
			Notes.note[6] ="000"
			Notes.note[7] ="000"
			Notes.note[8] ="000"
			Notes.note[9] ="000"
			Notes.note[10] ="000"
			Notes.note[11] ="100"
			Notes.note[12] ="100"
			Notes.note[13] =""
			Notes.note[14] ="My Quote Here"
			--ZO_EditNoteDialogNoteEdit:SetText(Notes.ConcatenateNote())
		else
			Notes.ParseNote(ZO_EditNoteDialogNoteEdit:GetText())
		end	
		
		--update helper ui with theses values	
		ARK_EGN_NoteHelperSliderPvESlider:SetValue(Notes.GetDigit(Notes.note[11], 1))
		ARK_EGN_NoteHelperSliderPvPSlider:SetValue(Notes.GetDigit(Notes.note[12], 1))
		ARK_EGN_NoteHelperCrestBGEdit:SetText(Notes.note[13])
		ARK_EGN_NoteHelperCrestIcon:SetTexture("esoui/art/"..Notes.note[13]..".dds")
		ARK_EGN_NoteHelperQuoteBGEdit:SetText(Notes.note[14])	
		--
		for index =1, 8, 1 do
			local comboBox = WINDOW_MANAGER:GetControlByName("ARK_EGN_NoteHelperChar"..index.."ComboBox")
			local dropdown = ZO_ComboBox_ObjectFromContainer(comboBox)
			dropdown:SetSelectedItem(Notes.charString[Notes.note[index+2]])
			
		end 
		
		local valueLabel = WINDOW_MANAGER:GetControlByName("ARK_EGN_NoteHelperMael".."Value")
			if Notes.GetDigit(Notes.note[11], 2) == 1 then
				valueLabel:SetText("YES")
				valueLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
			else
				valueLabel:SetText("NO")
				valueLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
			end
		valueLabel = WINDOW_MANAGER:GetControlByName("ARK_EGN_NoteHelperVDSA".."Value")
			if Notes.GetDigit(Notes.note[11], 3) == 1 then
				valueLabel:SetText("YES")
				valueLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
			else
				valueLabel:SetText("NO")
				valueLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
			end	
		valueLabel = WINDOW_MANAGER:GetControlByName("ARK_EGN_NoteHelperEmperor".."Value")
			if Notes.GetDigit(Notes.note[12], 2) == 1 then
				valueLabel:SetText("YES")
				valueLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
			else
				valueLabel:SetText("NO")
				valueLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
			end	
		valueLabel = WINDOW_MANAGER:GetControlByName("ARK_EGN_NoteHelperDuelist".."Value")
			if Notes.GetDigit(Notes.note[12], 3) == 1 then
				valueLabel:SetText("YES")
				valueLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
			else
				valueLabel:SetText("NO")
				valueLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
			end

	end

	--   UI EVENTS   -- 


	 
	--crest icon editbox  has changed
	function Notes.OnCrestEditTextChanged(control)
		--update the note with new value if needed
		local newValue = control:GetText()
		if newValue ~= Notes.note[13] then
			Notes.note[13] = newValue
			ZO_EditNoteDialogNoteEdit:SetText(Notes.ConcatenateNote())
			--update side icon for preview purposes
			ARK_EGN_NoteHelperCrestIcon:SetTexture("esoui/art/"..Notes.note[13]..".dds")
		end		
	end

	--quote editbox has changed
	function Notes.OnQuoteEditTextChanged(control)
		--update the note with new value if needed
		local newValue = control:GetText()
		if newValue ~= Notes.note[14] then
			Notes.note[14] = newValue
			ZO_EditNoteDialogNoteEdit:SetText(Notes.ConcatenateNote())
		end		
	end
	 
	function Notes.OnPvESliderValueChanged(control)
		--update the slider's label with new value
		ARK_EGN_NoteHelperSliderPvESliderValue:SetText(control:GetValue())
		
		--update the note with new value if needed
		local newValue = Notes.SetDigit(Notes.note[11], 1, control:GetValue())
		if newValue ~= Notes.note[11] then
			Notes.note[11] = newValue
			ZO_EditNoteDialogNoteEdit:SetText(Notes.ConcatenateNote())
		end
	end
	 
	function Notes.OnPvPSliderValueChanged(control)
		--update the slider's label with new value
		ARK_EGN_NoteHelperSliderPvPSliderValue:SetText(control:GetValue())
		
		--update the note with new value if needed	
		local newValue = Notes.SetDigit(Notes.note[12], 1, control:GetValue())
		if newValue ~= Notes.note[12] then
			Notes.note[12] = newValue
			ZO_EditNoteDialogNoteEdit:SetText(Notes.ConcatenateNote())
		end
	end

	--changes font color on mouse over the "checkbox"
	function Notes.OnCheckBoxMouseEnter(self)
	 
		local valueLabel = WINDOW_MANAGER:GetControlByName(self:GetName().."Value")
		if valueLabel:GetText() == "YES" then
			valueLabel:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
		else
			valueLabel:SetColor(ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR:UnpackRGBA())
		end
		--self:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
	end

	--changes font color on mouse over the "checkbox"
	function Notes.OnCheckBoxMouseExit(self)

		local valueLabel = WINDOW_MANAGER:GetControlByName(self:GetName().."Value")
		if valueLabel:GetText() == "YES" then
			valueLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
		else
			valueLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
		end
		--self:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	end

	--a checkbox has been clicked
	function Notes.OnCheckBoxMouseUp(self)

		local valueLabel = WINDOW_MANAGER:GetControlByName(self:GetName().."Value")
		if valueLabel:GetText() == "YES" then --current value is "yes" => switch to "no"
			valueLabel:SetText("NO")
			valueLabel:SetColor(ZO_DEFAULT_DISABLED_MOUSEOVER_COLOR:UnpackRGBA())
			if self:GetName() == "ARK_EGN_NoteHelperMael" then
				Notes.note[11] = Notes.SetDigit(Notes.note[11], 2, 0)
			elseif self:GetName() == "ARK_EGN_NoteHelperVDSA" then
				Notes.note[11] = Notes.SetDigit(Notes.note[11], 3, 0)
			elseif self:GetName() == "ARK_EGN_NoteHelperEmperor" then
				Notes.note[12] = Notes.SetDigit(Notes.note[12], 2, 0)
			else --self:GetName() == "ARK_EGN_NoteHelperDuelist"
				Notes.note[12] = Notes.SetDigit(Notes.note[12], 3, 0)
			end
		else --current value is "no" => switch to "yes"
			valueLabel:SetText("YES")
			valueLabel:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
			if self:GetName() == "ARK_EGN_NoteHelperMael" then
				Notes.note[11] = Notes.SetDigit(Notes.note[11], 2, 1)
			elseif self:GetName() == "ARK_EGN_NoteHelperVDSA" then
				Notes.note[11] = Notes.SetDigit(Notes.note[11], 3, 1)
			elseif self:GetName() == "ARK_EGN_NoteHelperEmperor" then
				Notes.note[12] = Notes.SetDigit(Notes.note[12], 2, 1)
			else --self:GetName() == "ARK_EGN_NoteHelperDuelist"
				Notes.note[12] = Notes.SetDigit(Notes.note[12], 3, 1)
			end
		end
		--CHAT_SYSTEM["containers"][1]["currentBuffer"]:AddMessage("mouseup")
		ZO_EditNoteDialogNoteEdit:SetText(Notes.ConcatenateNote())
	 
	end

end


--[[ Note content : 


function ARK_EGN.Dump()
	EGN.Debug( "Dump", "Function" )
	
	local guildID = EGN.guildList[EGN.guildName]
	EGN.Debug( guildID, "guildID" )
	
	EGN.dump = ZO_SavedVars:NewAccountWide( "ARK_EGN_SavedVariables", 1, "Dump", {} )
	local guildRoster = {}
	local stringToDump = ""
		
	for member=1, GetNumGuildMembers(guildID) do
		--name,note,rankIndex,playerStatus,secsSinceLogoff = GetGuildMemberInfo()
		local playerPveLevel = 0
		local playerPvpLevel = 0
		
		local name,note,_,_,secsSinceLogoff = GetGuildMemberInfo(guildID,member)
		if note:find("#EGN") then
			local extendedNote = EGN.ParseNote(note)
			playerPveLevel = extendedNote[11]:sub(1, 1)
			playerPvpLevel = extendedNote[12]:sub(1, 1)			
		end
		if secsSinceLogoff == nil then
			secsSinceLogoff = 0 
		end
		table.insert(guildRoster, {userId = name, pve = playerPveLevel, pvp = playerPvpLevel, sec = secsSinceLogoff})		
	end
	
	table.sort( guildRoster, EGN.SortByUserId )
		
	for i in pairs(guildRoster) do
		EGN.Debug( "pve : "..guildRoster[i].pve.." - pvp : "..guildRoster[i].pvp, guildRoster[i].userId)	
		EGN.dump[i] = ";"..guildRoster[i].userId..";"..guildRoster[i].pve..";"..guildRoster[i].pvp..";"..guildRoster[i].sec..";".."0"
	end
		
	EGN.Msg2Chat( EGN.Colorize( "Arka Roster Dumped."))
	EGN.Msg2Chat( EGN.Colorize( "Press ENTER to reload UI and save the file.", WHITE ) )
	CHAT_SYSTEM.textEntry:SetText("/reloadui")
	CHAT_SYSTEM:Maximize()
	CHAT_SYSTEM.textEntry:Open()	
	
end

	
function EGN.SortByUserId(entry1, entry2)
	return entry1.userId < entry2.userId
end


function EGN.EmptyTable(tab)
	for k,v in pairs(tab) do tab[k]=nil end
end

EGN2
image + citation
maitre artisant 0/1
grade pvp max
titre préféré (parmis la liste)

roster(niveau) pve / 5 
roster (niveau) pvp / 3 (possible niveau 0 ? )

4 persos
race classe stat_max role_préféré. (953

date de fin de vacances jj/mm/aa
badges (8/xx)


spé et roles
spé : pve, pvp, tank donj, tank raid, tank pvp, heal donj, heal raid, heal pvp, dps donj, dps raid, dps pvp,
 support pvp, pvp bus, pvp gank, pvp bomb, farm, succès, craft, BG, cité imp, 

]]--
