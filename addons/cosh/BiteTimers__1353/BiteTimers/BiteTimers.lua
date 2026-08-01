-- Bite Timers ESO AddOn by Cosh
--------------------------------------------------------------------------------

activeCharName     = GetUnitName("player")
activeCharAlliance = GetUnitAlliance("player")
local activeChar   = nil
local charsCount   = 0

local wm = GetWindowManager()
local em = GetEventManager()

-- create a namespace for BT by declaring a top-level table that will hold everything else.
if BT == nil then BT = {} end
--------------------------------------------------------------------------------

-- The AddOn name
BT.name = "BiteTimers"
BT.version = "6.0.5"
BT.settings = {}
BT.chars = {}
--------------------------------------------------------------------------------

-- register our event handler function to be called to do initialization
em:RegisterForEvent(BT.name, EVENT_ADD_ON_LOADED, function(...) BT.Initialize(...) end)
--------------------------------------------------------------------------------
--
-- This function that will initialize our addon with ESO
--
function BT.Initialize(event, addon)

	if addon ~= BT.name then return end

	em:UnregisterForEvent("BiteTimersInitialize", EVENT_ADD_ON_LOADED)

	-- default values for saved variables
	defaultSavedVars = { chars = {}, showAlliance = false, fontSize = 18, showWerewolves = true, showVampires = true, showPure = true }
	BT.settings = ZO_SavedVars:NewAccountWide("BiteTimersSavedVars", 1, nil, defaultSavedVars)
	
	if (BT.settings.showAlliance   == nil) then BT.settings.showAlliance   = false end
	if (BT.settings.fontSize       == nil) then BT.settings.fontSize       = 18    end
	if (BT.settings.showWerewolves == nil) then BT.settings.showWerewolves = true  end
	if (BT.settings.showVampires   == nil) then BT.settings.showVampires   = true  end
	if (BT.settings.showPure       == nil) then BT.settings.showPure       = true  end

	-- make a label for our keybinding
	ZO_CreateStringId("SI_BINDING_NAME_BITE_TIMERS_TOGGLE", "Toggle Window")

	em:RegisterForEvent("BiteTimersStart", EVENT_PLAYER_ACTIVATED, function(...) BT.OnPlayerActivated(...) end)
end
--------------------------------------------------------------------------------

function compareCharNames( char1, char2 )
	return char1.name < char2.name
end
--------------------------------------------------------------------------------

function BT.ShowOrHideCharacters()

	local column1LastItem = btw.entries.column1.label
	local column2LastItem = btw.entries.column2.label
	
	for i=1, charsCount do

		if 	(not BT.settings.showWerewolves and BT.chars[i].iswerewolf) or
			(not BT.settings.showVampires   and BT.chars[i].isvampire ) or
			(not BT.settings.showPure       and not BT.chars[i].iswerewolf and not BT.chars[i].isvampire)
		then
			--hideChar = true
			btw.entries.column1.items[i]:SetAnchor(TOPLEFT, btw.entries.column1.label, BOTTOMLEFT, 0, 5)
			btw.entries.column2.items[i]:SetAnchor(TOP, btw.entries.column2.label, BOTTOM, 0, 5)
			btw.entries.column1.items[i]:SetHidden(true)
			btw.entries.column2.items[i]:SetHidden(true)
		else
			--hideChar = false
			btw.entries.column1.items[i]:SetAnchor(TOPLEFT, column1LastItem, BOTTOMLEFT, 0, 5)
			btw.entries.column2.items[i]:SetAnchor(TOP, column2LastItem, BOTTOM, 0, 5)
			column1LastItem = btw.entries.column1.items[i]
			column2LastItem = btw.entries.column2.items[i]
			btw.entries.column1.items[i]:SetHidden(false)
			btw.entries.column2.items[i]:SetHidden(false)
		end
	end
end

--------------------------------------------------------------------------------

function BT.OnPlayerActivated()

	activeCharName     = GetUnitName("player")
	activeCharAlliance = GetUnitAlliance("player")
	
	if charsCount == 0 then
		for k,v in pairs(BT.settings.chars) do
		
			charsCount = charsCount + 1
			
			--settings checking and correction
			if BT.settings.chars[k].alpha      == nil then BT.settings.chars[k].alpha      = 50    end
			if BT.settings.chars[k].x          == nil then BT.settings.chars[k].x          = 40    end
			if BT.settings.chars[k].y          == nil then BT.settings.chars[k].y          = 450   end
			if BT.settings.chars[k].showtitle  == nil then BT.settings.chars[k].showtitle  = true  end
			if BT.settings.chars[k].shown      == nil then BT.settings.chars[k].shown      = true  end
			if BT.settings.chars[k].readytime  == nil then BT.settings.chars[k].readytime  = -1    end
			if BT.settings.chars[k].isvampire  == nil then BT.settings.chars[k].isvampire  = false end
			if BT.settings.chars[k].iswerewolf == nil then BT.settings.chars[k].iswerewolf = false end
			if BT.settings.chars[k].num        == nil then BT.settings.chars[k].num        = -1    end
			if BT.settings.chars[k].alliance   == nil then BT.settings.chars[k].alliance   = -1    end
			
			BT.chars[charsCount] = {
				["name"] = k,
				["readytime"]  = BT.settings.chars[k].readytime,
				["isvampire"]  = BT.settings.chars[k].isvampire,
				["iswerewolf"] = BT.settings.chars[k].iswerewolf,
				["alliance"]   = BT.settings.chars[k].alliance,
				}
				
			if (k == activeCharName) then activeChar = BT.chars[charsCount] end
			
		end
	end

	--add active character settings
	if BT.settings.chars[activeCharName] == nil then
		charsCount = charsCount + 1
		BT.settings.chars[activeCharName] = {
			["alpha"]      = 50,
			["x"]          = 40,
			["y"]          = 450,
			["showtitle"]  = true,
			["shown"]      = true,
			["readytime"]  = -1,
			["isvampire"]  = false,
			["iswerewolf"] = false,
			["num"]        = charsCount,
			["alliance"]   = activeCharAlliance,
			}

		BT.chars[charsCount] = {}
		activeChar = BT.chars[charsCount]
	end

	--get active character actual parameters
	local readyTimeSec, iswerewolf, isvampire = GetActiveCharBiteReadyTimeSec()
	activeChar.name       = activeCharName
	activeChar.readytime  = readyTimeSec
	activeChar.isvampire  = isvampire
	activeChar.iswerewolf = iswerewolf
	activeChar.alliance   = activeCharAlliance

	--save theese parameters to settings
	activeCharSettings            = BT.settings.chars[activeCharName]
	activeCharSettings.readytime  = math.floor(readyTimeSec)
	activeCharSettings.iswerewolf = iswerewolf
	activeCharSettings.isvampire  = isvampire
	activeCharSettings.alliance   = activeCharAlliance
	
	
	--[[ for test purposes
	local h8full8 = {
		"Major Marquis Warren",
		"John Ruth",
		"Daisy Domergue",
		"Sheriff Chris Mannix",
		"Bob",
		"Oswaldo Mobray",
		"Joe Gage",
		"General Sanford Smithers",
		}
	for i=1, charsCount do
		BT.chars[i].name = h8full8[i]
	end
	--]]
	
	table.sort( BT.chars, compareCharNames )

	BT.RefreshWindow()

	BT.CreateMenu()
end
--------------------------------------------------------------------------------

function BT.RefreshWindow()
	
	if BT.window == nil then BT.CreateWindow() end
	
	local readyTimeSec, iswerewolf, isvampire = GetActiveCharBiteReadyTimeSec()
	readyTimeSec = math.floor(readyTimeSec)
	activeCharSettings.readytime  = readyTimeSec
	activeCharSettings.iswerewolf = iswerewolf
	activeCharSettings.isvampire  = isvampire
	
	activeChar.readytime  = readyTimeSec
	activeChar.iswerewolf = iswerewolf
	activeChar.isvampire  = isvampire

	for i=1, charsCount do

		if BT.chars[i].iswerewolf then
			btw.entries.column1.items[i]:SetColor(.9, .3, .3, 1)
		elseif BT.chars[i].isvampire then
			btw.entries.column1.items[i]:SetColor(.1, .6, 1, 1)
		else
			btw.entries.column1.items[i]:SetColor(.8, .8, .8, 1)
		end

		local alliance = BT.chars[i].alliance
		local allianceName
		if alliance == 1 then --Aldmeri Dominuon
			allianceName = "(AD)"
		elseif alliance == 2 then --Ebonheart Pact
			allianceName = "(EP)"
		elseif alliance == 3 then --Daggerfall Covenant
			allianceName = "(DC)"
		else
			allianceName = "    "
		end
		
		local sname = BT.chars[i].name
		if btw.showAlliance then sname = sname.." "..allianceName end
		btw.entries.column1.items[i]:SetText(sname)
		
		readyTimeSec = BT.chars[i].readytime
		if readyTimeSec == -1 then
			btw.entries.column2.items[i]:SetColor(.8, .8, .8, 1)
			btw.entries.column2.items[i]:SetText("no ability")
		else
			local remainingTimeSec = readyTimeSec - GetTimeStamp()
			if remainingTimeSec < 0 then remainingTimeSec = 0 end
			
			if remainingTimeSec == 0 then
				if BT.chars[i].iswerewolf or BT.chars[i].isvampire then
					btw.entries.column2.items[i]:SetColor(.1, .9, .1, 1)
					btw.entries.column2.items[i]:SetText("Ready")
				else
					btw.entries.column2.items[i]:SetColor(.5, .5, .5, 1)
					btw.entries.column2.items[i]:SetText("?")
				end
			else
				local stime = ""
				remainingTimeSec = math.floor(remainingTimeSec)
				local days = math.floor(remainingTimeSec/86400)
				if(days>0) then stime = stime..days.."d " end
				remainingTimeSec = remainingTimeSec - (days*86400)
				local hours = math.floor(remainingTimeSec/3600)
				if(hours>0) then stime = stime..hours.."h " end
				remainingTimeSec = remainingTimeSec - (hours*3600)
				local minutes = math.floor(remainingTimeSec/60)
				if(minutes>0) then stime = stime..minutes.."m " end
				remainingTimeSec = remainingTimeSec - (minutes*60)
				local seconds = remainingTimeSec
				stime = stime..seconds.."s"
				
				btw.entries.column2.items[i]:SetColor(.9, .9, .8, 1)
				btw.entries.column2.items[i]:SetText(stime)
			end
		end
	end
--
	
	btw:SetHidden(ZO_CompassFrame:IsHidden() or not activeCharSettings.shown)
end
--------------------------------------------------------------------------------
--
function BT.SetFontSize(value)

	btw.fontSize = value
	btw.title:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
	btw.entries.column1.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
	btw.entries.column2.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
	for i=1, charsCount do
		btw.entries.column1.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
		btw.entries.column2.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
	end
end
--------------------------------------------------------------------------------
--
function BT.CreateWindow()

	-- main window
	BT.window = wm:CreateTopLevelWindow("BiteTimers")

    btw = BT.window
	btw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, activeCharSettings.x, activeCharSettings.y)
	btw:SetMovable(true)
	btw:SetHidden(not activeCharSettings.shown)
	btw:SetMouseEnabled(true)
	btw:SetDimensions(0,0)
	btw:SetResizeToFitDescendents(true)
	btw:SetHandler("OnMoveStop", function()
		activeCharSettings.x = btw:GetLeft()
		activeCharSettings.y = btw:GetTop()
	end)
	btw:SetDrawLayer(DL_TEXT)
	
	btw.fontSize       = BT.settings.fontSize
	btw.showAlliance   = BT.settings.showAlliance
	btw.showWerewolves = BT.settings.showWerewolves
	btw.showVampires   = BT.settings.showVampires
	btw.showPure       = BT.settings.showPure

	-- give it a backdground (backdrop) for the frame
	btw.bg = wm:CreateControl("BTBackground", btw, CT_BACKDROP)
	btw.bg:SetAnchorFill(btw)
	btw.bg:SetCenterColor(0, 0, 0, activeCharSettings.alpha / 100)
	btw.bg:SetEdgeColor(0, 0, 0, 0)
	btw.bg:SetEdgeTexture(nil, 1, 1, 0, 0)
	btw.bg:SetInsets(-16, -8, 16, 16)
	btw.bg:SetExcludeFromResizeToFitExtents(true)

	-- give it a header
	btw.title = wm:CreateControl("BTTitle", btw, CT_LABEL)
	btw.title:SetAnchor(TOP, btw, TOP, 0, 5)
	btw.title:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
	btw.title:SetColor(.1, .9, .9, 1)
	btw.title:SetStyleColor(0, 0, 0, 1)
	if activeCharSettings.shown then
		btw.title:SetText("CHARACTERS' BITES COOLDOWN")
	end
	btw.title:SetHidden(not activeCharSettings.showtitle)

	-- make a container for the list entries
	btw.entries = wm:CreateControl("BTEntries", btw, CT_CONTROL)
	
	if activeCharSettings.showtitle then
		btw.entries:SetAnchor(TOP, btw.title, BOTTOM, 0, 0)
	else
		btw.entries:SetAnchor(TOP, btw, TOP, 0, 0)
	end

	btw.entries:SetHidden(false)
	btw.entries:SetResizeToFitDescendents(true)

	--
	btw.entries.column1 = wm:CreateControl("BTColumn1", btw.entries, CT_CONTROL)
	btw.entries.column1:SetAnchor(TOPLEFT, btw.entries, TOPLEFT, 0, 5)
	btw.entries.column1:SetHidden(false)
	btw.entries.column1:SetResizeToFitDescendents(true)
	btw.entries.column1:SetResizeToFitPadding(2, 0)

	btw.entries.column1.label = wm:CreateControl("BTColumn1Label", btw.entries.column1, CT_LABEL)
	btw.entries.column1.label:SetAnchor(TOPLEFT, btw.entries.column1, TOPLEFT, 0, 0)
	btw.entries.column1.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
	btw.entries.column1.label:SetColor(1, 1, 1, 1)
	btw.entries.column1.label:SetStyleColor(0, 0, 0, 1)
	local column1LastItem = btw.entries.column1.label
	
	--
	btw.entries.column2 = wm:CreateControl("BTColumn2", btw.entries, CT_CONTROL)
	btw.entries.column2:SetAnchor(TOPLEFT, btw.entries.column1, TOPRIGHT, 15, 0)
	btw.entries.column2:SetHidden(false)
	btw.entries.column2:SetResizeToFitDescendents(true)
	btw.entries.column2:SetResizeToFitPadding(2, 0)

	btw.entries.column2.label = wm:CreateControl("BTColumn2Label", btw.entries.column2, CT_LABEL)
	btw.entries.column2.label:SetAnchor(TOP, btw.entries.column2, TOP, 0, 0)
	btw.entries.column2.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
	btw.entries.column2.label:SetStyleColor(0, 0, 0, 1)
	btw.entries.column2.label:SetColor(1, 1, 1, 1)
	local column2LastItem = btw.entries.column2.label
	

	btw.entries.column1.items = {}
	btw.entries.column2.items = {}
	

	for i=1, charsCount do
		btw.entries.column1.items[i] = wm:CreateControl("BTColumn1Item" .. i, btw.entries.column1, CT_LABEL)
		local col1item = btw.entries.column1.items[i]
		col1item:SetAnchor(TOPLEFT, column1LastItem, BOTTOMLEFT, 0, 5)
		col1item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
		col1item:SetColor(.9, .9, .9, 1)
		col1item:SetStyleColor(0, 0, 0, 1)
		col1item:SetText("HWSChar"..i)
		column1LastItem = col1item

		btw.entries.column2.items[i] = wm:CreateControl("BTColumn2Item" .. i, btw.entries.column2, CT_LABEL)
		local col2item = btw.entries.column2.items[i]
		col2item:SetAnchor(TOP, column2LastItem, BOTTOM, 0, 5)
		col2item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..btw.fontSize.."|soft-shadow-thin")
		col2item:SetColor(.9, .9, .9, 1)
		col2item:SetStyleColor(0, 0, 0, 1)
		col2item:SetText("0d 0h 0m 0s")
		column2LastItem = col2item
	end
	
	BT.ShowOrHideCharacters();

	-- hide our window when the compass frame gets hidden, if it's not hidden already
	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...) oldHandler(...) if activeCharSettings.shown then btw:SetHidden(false) end end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) if activeCharSettings.shown then btw:SetHidden(false) end end)
	end
	
	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...) oldHandler(...) if activeCharSettings.shown then btw:SetHidden(true) end end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) if activeCharSettings.shown then btw:SetHidden(true) end end)
	end
	
	EVENT_MANAGER:RegisterForUpdate("BiteTimersUpdate", 1000, BiteTimersUpdate) 

end
--------------------------------------------------------------------------------

function GetActiveCharBiteReadyTimeSec()
	
	local hasBitAnAlly = false
	local hasFedOnAlly = false
	local readyTimeSec = -1
	local numBuffs = GetNumBuffs("player")
	
	local iswerewolf = false
	local isvampire = false

	for buffIndex = 1, numBuffs do
		local _, _, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", buffIndex)
		if abilityId == 40525 then
			--d("Bit an ally found.")
			hasBitAnAlly = true
			readyTimeSec = endTime - (GetFrameTimeMilliseconds()/1000) + GetTimeStamp()
			--break
		elseif abilityId == 40359 then
			--d("Fed on ally found.")
			hasFedOnAlly = true
			readyTimeSec = endTime - (GetFrameTimeMilliseconds()/1000) + GetTimeStamp()
			--break
		elseif abilityId == 35658 then
			--d("Lycanthropy found.")
			iswerewolf = true
		elseif (abilityId == 135397) or (abilityId == 135399) or (abilityId == 135400) or (abilityId == 135402) or (abilityId == 135412) then
			--d("Stage 1-5 Vampirism found.")
			isvampire = true
		end
	end

	--local hasBloodmoon = hasBitAnAlly
	--local hasBloodRitual = hasFedOnAlly
	
	if (hasBitAnAlly == false) and (hasFedOnAlly == false) then
		local numSkillLines = GetNumSkillLines(SKILL_TYPE_WORLD)
		for skillIndex = 1, numSkillLines do
			local numSkillAbilities = GetNumSkillAbilities(SKILL_TYPE_WORLD, skillIndex)
			for abilityIndex = 1, numSkillAbilities do
				local name, _, _, passive, _, purchased, _ = GetSkillAbilityInfo(SKILL_TYPE_WORLD, skillIndex, abilityIndex)
				if purchased then
					local abilityId = GetSkillAbilityId(SKILL_TYPE_WORLD, skillIndex, abilityIndex, false)
					if abilityId == 32639 then
						--d("Bloodmoon found.")
						--hasBloodmoon = true
						readyTimeSec = 0
						break
					elseif abilityId == 33091 then
						--d("Blood Ritual found.")
						--hasBloodRitual = true
						readyTimeSec = 0
						break
					end
				end
			end
		end
	end
	
	return readyTimeSec, iswerewolf, isvampire
end
--------------------------------------------------------------------------------

function BiteTimersUpdate()

	BT.RefreshWindow()
	--EVENT_MANAGER:UnregisterForUpdate("BiteTimersUpdate")
end
--------------------------------------------------------------------------------
--
-- Show or hide the window
--
function BT.ToggleWindow()
	local ishidden = btw:IsHidden()
	-- refresh the window if we're about to show it
	if ishidden then BT.RefreshWindow() end
	activeCharSettings.shown = ishidden
	btw:SetHidden(not ishidden)

	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", btSettingsPanel)
end
--------------------------------------------------------------------------------
