local SALTI = _G['SALTI']
SALTI.Strings = SALTI:GetLanguage()

------------------------------------------------------------------------------------------------------------------------------------
-- Global Utility functions
------------------------------------------------------------------------------------------------------------------------------------
function SALTI.TColor(color, text) -- Wraps the color tags with the passed color around the given text.
	-- color:		String, hex format color string, for example "ffffff".
	-- text:		The text to format with the given color.

	-- Example: PF.TColor("ff0000", "This is red.")
	-- Returns: "|cff0000This is red.|r"

	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end

function SALTI.Contains(nTable, element) -- Determined if a given element exists in a given table.
	-- nTable:		Table, source to search for element.
	-- element:		String or number to find in the table.

	-- Example: Does the given table contain a key with the given value?
	-- local SourceTable = {[1]="alpha", [2]="beta", [3]="gamma"}
	-- PF.GetKey(nTable, "alpha")
	-- returns: true

	for k,v in pairs(nTable) do
		if v == element then
			return true
		end
	end
	return false
end

function SALTI.GetKey(nTable, element, all) -- Returns the table key(s) that contains a given element value.
	-- nTable:		Table, source to search for element.
	-- element:		String or number to find in the table.
	-- all:			Int, 1 to return first match or 2 for table.

	-- Example 1: Return the key that contains the string (only returns first match of multiple if all = 1 or nil.
	-- local SourceTable = {[1]="alpha", [2]="beta", [3]="gamma"}
	-- PF.GetKey(nTable, "alpha")
	-- returns: 1

	-- Example 2: Return table of keys that contain the value.
	-- local SourceTable = {[1]=3, [2]=2, [3]=1, [4]=3}
	-- PF.GetKey(nTable, 3, 2)
	-- returns: {[1]=true, [4]=true}

	-- Possible use:
	--	local SourceTable = {[1]=3, [2]=2, [3]=1, [4]=3}
	--	local checkKeys = PF.GetKey(SourceTable, 3, 2)
	--		for k, v in pairs(SourceTable) do
	--		if checkKeys[k] then
	--			d("Key "..k.." contains value 3")
	--		end
	--	end
	--
	--	Prints:
	--		Key 4 contains value 3
	--		Key 1 contains value 3

-- Default values:
	all = (all == nil or all ~= 1) and 2 or 1

	local matches = {}
	for k,v in pairs(nTable) do
		if v == element then
			if all ~= 1 then
				return k
			else
				matches[k] = true
			end
		end
	end
	if all ~= 1 then
		return 0
	else
		if #matches > 0 then
			return matches
		end
	end

	return
end

function SALTI.CountKeys(nTable) -- Count the key/value pairs in a hashed table (when #table returns 0).
	-- nTable:		Table, source to search for element.

	-- Example: Count the key/value pairs in a hashed table.
	-- local SourceTable = {["name1"]="alpha", ["name2"]="beta", ["name3"]="gamma"}
	-- PF.CountKeys(nTable)
	-- returns: 3

	local tKeys = 0
	for k, v in pairs(nTable) do
		tKeys = tKeys + 1
	end
	return tKeys
end

------------------------------------------------------------------------------------------------------------------------------------
-- Saved Variables & Init
------------------------------------------------------------------------------------------------------------------------------------
SALTI.cOpts = { -- Saved Variable Character Defaults
	cVals = {},							-- database of tracked character currency values by unique ID
	trackChar = true,					-- achievement completion tracking status (per-character)
}

SALTI.aOpts = { -- Saved Variable Account Defaults
	gVals = {},							-- database of guild bank currency values
	gBank = 0,							-- gold currently banked
	tvBank = 0,							-- telvar currently banked
	apBank = 0,							-- AP currently banked
	wvBank = 0,							-- writ vouchers currently banked

	gAccount = 0,						-- total account gold
	apAccount = 0,						-- total account AP
	tvAccount = 0,						-- total account telvar
	wvAccount = 0,						-- total account writ vouchers

	sEndeavor = 0,						-- total account seals of endeavor
	aTCrystals = 0,						-- total account transmute crystals
	aETickets = 0,						-- total account event tickets
	aOutfit = 0,						-- total account outfit tokens
	aUKeys = 0,							-- total account undaunted keys
	aCGems = 0,							-- total account crown gems
	aCrowns = 0,						-- total account crowns
	aFortunes = 0,						-- total account archival fortunes
	impFrags = 0,						-- total account imperial fragments

	iACShow = true,						-- show class icons in currency display
	sortAlpha=true,						-- sort character list alphabetically or by account
	aCShow = true,						-- show global currency summary on currency display
	gPadding = 16,						-- horizontal gap between global currency items
	gGBShow = false,					-- show guild bank data on currency display
	tIWPos = false,						-- use independent position for currency display

	xpos = 0,							-- independent currency display x-axis position
	ypos = 0,							-- independent currency display y-axis position
}

function SALTI:CurrencyControls() -- Build & Configure Addon Controls
	local tempHeader = {}
	local tempSummary = {}
	local tempChars = {}
	local tempGuilds = {}
	local tempControls = {}
	local tempDiv = {}

--	Build Header Section
	tempHeader.HS = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_HeaderSource', SALTI_Gold, CT_LABEL)
	tempHeader.HG = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_HeaderGold', SALTI_Gold, CT_LABEL)
	tempHeader.HT = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_HeaderTV', SALTI_Gold, CT_LABEL)
	tempHeader.HA = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_HeaderAP', SALTI_Gold, CT_LABEL)
	tempHeader.HW = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_HeaderWV', SALTI_Gold, CT_LABEL)
	tempHeader.HS:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	tempHeader.HS:SetFont("ZoFontGame")
	tempHeader.HG:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempHeader.HG:SetFont("ZoFontGame")
	tempHeader.HT:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempHeader.HT:SetFont("ZoFontGame")
	tempHeader.HA:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempHeader.HA:SetFont("ZoFontGame")
	tempHeader.HW:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempHeader.HW:SetFont("ZoFontGame")

--	Build Currency Summary Section
	tempSummary.TS = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_TotalSource', SALTI_Gold, CT_LABEL)
	tempSummary.TG = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_TotalGold', SALTI_Gold, CT_LABEL)
	tempSummary.TT = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_TotalTV', SALTI_Gold, CT_LABEL)
	tempSummary.TA = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_TotalAP', SALTI_Gold, CT_LABEL)
	tempSummary.TW = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_TotalWV', SALTI_Gold, CT_LABEL)
	tempSummary.BS = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_BankSource', SALTI_Gold, CT_LABEL)
	tempSummary.BG = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_BankGold', SALTI_Gold, CT_LABEL)
	tempSummary.BT = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_BankTV', SALTI_Gold, CT_LABEL)
	tempSummary.BA = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_BankAP', SALTI_Gold, CT_LABEL)
	tempSummary.BW = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_BankWV', SALTI_Gold, CT_LABEL)
	tempSummary.AS = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_ACurrency', SALTI_Gold, CT_LABEL)
	tempSummary.CR = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_ACrowns', SALTI_Gold, CT_LABEL)
	tempSummary.CG = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_ACGems', SALTI_Gold, CT_LABEL)
	tempSummary.CU = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_AUKeys', SALTI_Gold, CT_LABEL)
	tempSummary.OT = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_AOutfit', SALTI_Gold, CT_LABEL)
	tempSummary.ET = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_AETickets', SALTI_Gold, CT_LABEL)
	tempSummary.TC = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_ATCrystals', SALTI_Gold, CT_LABEL)
	tempSummary.SE = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_ASEndeavor', SALTI_Gold, CT_LABEL)
	tempSummary.AF = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_AAFortune', SALTI_Gold, CT_LABEL)
	tempSummary.IF = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_AIFragment', SALTI_Gold, CT_LABEL)
	
	tempSummary.TS:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	tempSummary.TS:SetFont("ZoFontGame")
	tempSummary.TG:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.TG:SetFont("ZoFontGame")
	tempSummary.TT:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.TT:SetFont("ZoFontGame")
	tempSummary.TA:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.TA:SetFont("ZoFontGame")
	tempSummary.TW:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.TW:SetFont("ZoFontGame")
	tempSummary.BS:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	tempSummary.BS:SetFont("ZoFontGame")
	tempSummary.BG:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.BG:SetFont("ZoFontGame")
	tempSummary.BT:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.BT:SetFont("ZoFontGame")
	tempSummary.BA:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.BA:SetFont("ZoFontGame")
	tempSummary.BW:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.BW:SetFont("ZoFontGame")
	tempSummary.AS:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	tempSummary.AS:SetFont("ZoFontGame")
	tempSummary.CR:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.CR:SetFont("ZoFontGame")
	tempSummary.CG:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.CG:SetFont("ZoFontGame")
	tempSummary.CU:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.CU:SetFont("ZoFontGame")
	tempSummary.OT:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.OT:SetFont("ZoFontGame")
	tempSummary.ET:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.ET:SetFont("ZoFontGame")
	tempSummary.TC:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.TC:SetFont("ZoFontGame")
	tempSummary.SE:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.SE:SetFont("ZoFontGame")
	tempSummary.AF:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.AF:SetFont("ZoFontGame")
	tempSummary.IF:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	tempSummary.IF:SetFont("ZoFontGame")

-- Build Dividers
	tempDiv.DIV1 = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_DIV1', SALTI_Gold, CT_TEXTURE)
	tempDiv.DIV2 = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_DIV2', SALTI_Gold, CT_TEXTURE)
	tempDiv.DIV3 = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_DIV3', SALTI_Gold, CT_TEXTURE)
	tempDiv.DIV4 = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_DIV4', SALTI_Gold, CT_TEXTURE)
	tempDiv.DIV1:SetTexture("esoui/art/guild/sectiondivider_left.dds")
	tempDiv.DIV1:SetHeight(4)
	tempDiv.DIV1:SetHidden(true)
	tempDiv.DIV2:SetTexture("esoui/art/guild/sectiondivider_left.dds")
	tempDiv.DIV2:SetHeight(4)
	tempDiv.DIV2:SetHidden(true)
	tempDiv.DIV3:SetTexture("esoui/art/guild/sectiondivider_left.dds")
	tempDiv.DIV3:SetHeight(4)
	tempDiv.DIV3:SetHidden(true)
	tempDiv.DIV4:SetTexture("esoui/art/guild/sectiondivider_left.dds")
	tempDiv.DIV4:SetHeight(4)
	tempDiv.DIV4:SetHidden(true)

	-- Add to controls DB
	tempControls[1] = tempDiv.DIV1
	tempControls[2] = tempDiv.DIV2
	tempControls[3] = tempDiv.DIV3
	tempControls[4] = tempDiv.DIV4

--	Build Guild Currency Tracking Section
	tempGuilds[1] = {name = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG1Name', SALTI_Gold, CT_LABEL), ap = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG1AP', SALTI_Gold, CT_LABEL), tv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG1TV', SALTI_Gold, CT_LABEL), wv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG1WV', SALTI_Gold, CT_LABEL), gold = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG1Gold', SALTI_Gold, CT_LABEL)}
	tempGuilds[2] = {name = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG2Name', SALTI_Gold, CT_LABEL), ap = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG2AP', SALTI_Gold, CT_LABEL), tv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG2TV', SALTI_Gold, CT_LABEL), wv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG2WV', SALTI_Gold, CT_LABEL), gold = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG2Gold', SALTI_Gold, CT_LABEL)}
	tempGuilds[3] = {name = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG3Name', SALTI_Gold, CT_LABEL), ap = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG3AP', SALTI_Gold, CT_LABEL), tv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG3TV', SALTI_Gold, CT_LABEL), wv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG3WV', SALTI_Gold, CT_LABEL), gold = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG3Gold', SALTI_Gold, CT_LABEL)}
	tempGuilds[4] = {name = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG4Name', SALTI_Gold, CT_LABEL), ap = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG4AP', SALTI_Gold, CT_LABEL), tv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG4TV', SALTI_Gold, CT_LABEL), wv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG4WV', SALTI_Gold, CT_LABEL), gold = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG4Gold', SALTI_Gold, CT_LABEL)}
	tempGuilds[5] = {name = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG5Name', SALTI_Gold, CT_LABEL), ap = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG5AP', SALTI_Gold, CT_LABEL), tv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG5TV', SALTI_Gold, CT_LABEL), wv = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG5WV', SALTI_Gold, CT_LABEL), gold = WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName() .. '_GG5Gold', SALTI_Gold, CT_LABEL)}
	for i = 1, 5 do
		tempGuilds[i].name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		tempGuilds[i].name:SetFont("ZoFontGame")
		tempGuilds[i].name:SetHidden(true)
		tempGuilds[i].ap:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempGuilds[i].ap:SetFont("ZoFontGame")
		tempGuilds[i].ap:SetHidden(true)
		tempGuilds[i].tv:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempGuilds[i].tv:SetFont("ZoFontGame")
		tempGuilds[i].tv:SetHidden(true)
		tempGuilds[i].wv:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempGuilds[i].wv:SetFont("ZoFontGame")
		tempGuilds[i].wv:SetHidden(true)
		tempGuilds[i].gold:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempGuilds[i].gold:SetFont("ZoFontGame")
		tempGuilds[i].gold:SetHidden(true)
		-- Add to controls DB
		tempControls[#tempControls + 1] = tempGuilds[i].name
		tempControls[#tempControls + 1] = tempGuilds[i].ap
		tempControls[#tempControls + 1] = tempGuilds[i].tv
		tempControls[#tempControls + 1] = tempGuilds[i].wv
		tempControls[#tempControls + 1] = tempGuilds[i].gold
	end

--	Return Control Tables
	return tempHeader, tempSummary, tempDiv, tempGuilds, tempControls
end

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end
