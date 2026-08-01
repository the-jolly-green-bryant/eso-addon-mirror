-- HEX TO RGB
-- Legatus Specific
function RAEIH.HexToRGBforLGT(hex)
	local rHex, gHex, bHex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	local rConv, gConv, bConv = tonumber(rHex, 16), tonumber(gHex, 16), tonumber(bHex, 16)
	local aConv = RAEIH.SavedVars.LegatusBA
	return rConv / 255, gConv / 255, bConv / 255, aConv
end

-- Modules
function RAEIH.HexToRGB(hex)
	local rHex, gHex, bHex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	local rConv, gConv, bConv = tonumber(rHex, 16), tonumber(gHex, 16), tonumber(bHex, 16)
	return rConv / 255, gConv / 255, bConv / 255
end

-- Hex to R
function RAEIH.HexToR(hex)
	local rHex, gHex, bHex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	local rConv, gConv, bConv = tonumber(rHex, 16), tonumber(gHex, 16), tonumber(bHex, 16)
	return rConv / 255
end

-- Hex to G
function RAEIH.HexToG(hex)
	local rHex, gHex, bHex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	local rConv, gConv, bConv = tonumber(rHex, 16), tonumber(gHex, 16), tonumber(bHex, 16)
	return gConv / 255
end

-- Hex to B
function RAEIH.HexToB(hex)
	local rHex, gHex, bHex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	local rConv, gConv, bConv = tonumber(rHex, 16), tonumber(gHex, 16), tonumber(bHex, 16)
	return bConv / 255
end

-- RGB TO HEX
function RAEIH.RGBToHex(r, g, b)
	rConv = r * 255
	gConv = g * 255
	bConv = b * 255
	rConv = rConv <= 255 and rConv >= 0 and rConv or 0
	gConv = gConv <= 255 and gConv >= 0 and gConv or 0
	bConv = bConv <= 255 and bConv >= 0 and bConv or 0
	return string.format("%02x%02x%02x", rConv, gConv, bConv)
end

-- ROUNDING VALUES
function RAEIH.Round(num, idp)
	local mult = 10 ^ (idp or 0)
	if(num >= 0) then
		return math.floor(num * mult + 0.5) / mult
	else
		return math.ceil(num * mult - 0.5) / mult
	end
end

-- BUFFER
local BufferTable = {}
function BufferReached(key, buffer)
	if key == nil then return end
	if BufferTable[key] == nil then BufferTable[key] = {} end
	BufferTable[key].buffer = buffer or 3
	BufferTable[key].now = GetFrameTimeSeconds()
	if BufferTable[key].last == nil then BufferTable[key].last = BufferTable[key].now end
	BufferTable[key].diff = BufferTable[key].now - BufferTable[key].last
	BufferTable[key].eval = BufferTable[key].diff >= BufferTable[key].buffer
	if BufferTable[key].eval then BufferTable[key].last = BufferTable[key].now end
	return BufferTable[key].eval
end

-- THOUSANDS SEPARATORS
-- Point
function RAEIH.ThousandsSeparatorPoint(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

-- Comma
function RAEIH.ThousandsSeparatorComma(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

-- TIME FORMAT CONVERTORS
-- MS to Clock Format
function RAEIH.MStoClockFormat(ms)
	local s = math.floor(ms / 1000)
	local ss = string.format("%02d", math.fmod(s, 60))
	local mm = string.format("%02d", math.fmod((s / 60 ), 60))
	local hh = string.format("%02d", (s / (60 * 60)))
	
	return string.format("%02d:%02d:%02d", hh, mm, ss)		
	-- return string.format("%02d:%02d", hh, mm, ss)		
	-- return string.format("%02d", hh, mm, ss)
end

-- S to Clock Format
function RAEIH.StoClockFormat(s)
	local ss = string.format("%02d", math.fmod(s, 60))
	local mm = string.format("%02d", math.fmod((s / 60 ), 60))
	local hh = string.format("%02d", (s / (60 * 60)))

	return string.format("%02d:%02d:%02d", hh, mm, ss)
	-- return string.format("%02d:%02d", hh, mm, ss)
	-- return string.format("%02d", hh, mm, ss)
end

-- TOTAL SKILL POINTS CALCULATION (Tim's Formula)
function RAEIH.GetTotalSpentSkillPoints()
	local totalSkillPoints = 0
	local numberOfSkillTypes = GetNumSkillTypes()
	for i = 1, numberOfSkillTypes do
		totalSkillPoints = totalSkillPoints + RAEIH.GetSkillPointsSpentPerType(i)
	end
	return totalSkillPoints
end

function RAEIH.GetSkillPointsSpentPerType(skillType)
	local totalSkillPointsSpentPerType = 0
	local numberOfSkillLines = GetNumSkillLines(skillType)
	for i = 1, numberOfSkillLines do
		totalSkillPointsSpentPerType = totalSkillPointsSpentPerType + RAEIH.GetSkillPointsSpentPerLine(skillType, i)
	end
	return totalSkillPointsSpentPerType
end

function RAEIH.GetSkillPointsSpentPerLine(skillType, skillLine)
	local totalSkillPointsSpentPerLine = 0
	local numberOfSkillAbilities = GetNumSkillAbilities(skillType, skillLine)
	for i = 1, numberOfSkillAbilities do
		totalSkillPointsSpentPerLine = totalSkillPointsSpentPerLine + RAEIH.GetSkillPointsSpentPerSkill(skillType, skillLine, i)
	end
	return totalSkillPointsSpentPerLine
end

function RAEIH.GetSkillPointsSpentPerSkill(skillType, skillLine, skillIndex)
	local _, _, _, _, _, purchased, progressionIndex = GetSkillAbilityInfo(skillType, skillLine, skillIndex)
	local startingPoints = RAEIH.GetStartingSkillPoints(skillType, skillLine, skillIndex)
	if purchased == false then
		return 0
	else
		if progressionIndex ~= nil then
			local _, morph = GetAbilityProgressionInfo(progressionIndex)
			if morph > 0 then
				return 2 - startingPoints
			else
				return 1 - startingPoints
			end
		else
			local currentUpgradeLevel, maxUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillLine, skillIndex)
			if currentUpgradeLevel == nil then
				return 1 - startingPoints
			else
				return currentUpgradeLevel - startingPoints
			end
		end
	end
end

function RAEIH.GetStartingSkillPoints(skillType, skillLine, skillIndex)
	if skillType == SKILL_TYPE_WORLD and skillLine == 1 and skillIndex == 2 then
		return 1
	elseif skillType == SKILL_TYPE_TRADESKILL then
		if skillIndex == 1 then
			return 1
		elseif skillIndex == 2 and (skillLine == select(2, GetCraftingSkillLineIndices(CRAFTING_TYPE_ENCHANTING)) or skillLine == select(2, GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING))) then
			return 1
		end
	elseif skillType == SKILL_TYPE_RACIAL and skillLine <= 10 and skillIndex == 1 then
		return 1
	end
	return 0
end

-- BUG REPORT & FEEDBACK

function RAEIH.BugReportFeedback()   
    SCENE_MANAGER:Show('mailSend')
    ZO_MailSendToField:SetText('@P5YCH3')
    ZO_MailSendSubjectField:SetText('RAETIA InfoHub - Bug Report / Feedback')
    ZO_MailSendBodyField:TakeFocus()
end

-- CLIENT SUPPORT

function RAEIH.SendCharacterInfo()
	
	local tName = GetUnitName("player")
	local tGender = GetUnitGender("player")
	local tRace = GetUnitRace("player")
	local tClass = GetUnitClass("player")
	local tTitle = GetUnitTitle("player")
	local tAlliance = GetUnitAlliance("player")
	local tAvaRank = GetUnitAvARank("player")
	local tAvaRankName = GetAvARankName(tGender, tAvaRank)

	local bodyText = ("Name: " .. tName .. "\nGender(Num): " .. tGender .. "\nRace: " .. tRace .. "\nClass: " .. tClass .. "\nTitle: " .. tTitle .. "\nAlliance(Num): " .. tAlliance .. "\nAvA Rank(Num): " .. tAvaRank .. "\nAvA Rank Name: " .. tAvaRankName)

	SCENE_MANAGER:Show('mailSend')
    ZO_MailSendToField:SetText('@P5YCH3')
    ZO_MailSendSubjectField:SetText('RAETIA InfoHub - Client Feedback')
    ZO_MailSendBodyField:SetText(bodyText)

end

-- TOGGLE CHAMBERLAIN

function RAEIH.ToggleChamberlain()
	if RAEIH_Chamberlain ~= nil and RAEIH_Chamberlain:IsHidden() then
		RAEIH_Chamberlain:SetHidden(false)
	elseif RAEIH_Chamberlain ~= nil and RAEIH_Chamberlain:IsHidden() == false then
		RAEIH_Chamberlain:SetHidden(true)
		if RAEIH_Chamberlain_Old ~= nil then RAEIH_Chamberlain_Old:SetHidden(true) end
	end
end

-- TOGGLE HELMET

function RAEIH.ToggleHelmet()
	local helmetStatus = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM)
	if helmetStatus == "1" then
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "0")
	else
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "1")
	end
end

-- STRING NORMALIZE
function RAEIH.NormString(string)
	local cIndex = string.find(string, "%^")
	if cIndex ~= nil then
		local nString = string.sub(string, 1, cIndex - 1)
		return nString
	else
		return string
	end
end

-- HIDE CHECK

-- ZO_SimpleSceneFragment:New(RAEIH_LegatusCO)
-- Main = hudui
-- Map = worldMap
-- Settings = gameMenuInGame
-- Conv = interact
-- Book = loreReaderLoreLibrary
-- Craft = smithing

-- function RAEIH.FragmentManager()
-- 	if RAEIH.SavedVars.InfoHubAHGeneral == true then
-- 		local scene = SCENE_MANAGER:GetScene("hud")
-- 		local fGroup = {ZO_SimpleSceneFragment:New(RAEIH_LegatusCO), ZO_SimpleSceneFragment:New(RAEIH_Legatus), ZO_SimpleSceneFragment:New(RAEIH_FPS), ZO_SimpleSceneFragment:New(RAEIH_Latency), ZO_SimpleSceneFragment:New(RAEIH_Zone)}
-- 		scene:AddFragmentGroup(fGroup)
-- 	end
-- end

RAEIH.InfoHubHidingTriggered = false
function RAEIH.HideCheck()	

	local isSettingsMenuHidden = ZO_GameMenu_InGame:IsHidden()
	local isInteractWindowHidden = ZO_InteractWindow:IsHidden()
	local isWorldMapHidden = not (WORLD_MAP_SCENE:IsShowing() or GAMEPAD_WORLD_MAP_SCENE:IsShowing())
	local isCraftingHidden = ZO_CraftingResultsTopLevel:IsHidden()
	local isJournalHidden = ZO_QuestJournal:IsHidden()
	local areGamePanelsHidden = ZO_KeybindStripControl:IsHidden()
	local isMailInboxHidden = ZO_MailInbox:IsHidden()	

	if (RAEIH.SavedVars.InfoHubAHSettingsMenu == true and 
		isSettingsMenuHidden == false) or 
		(RAEIH.SavedVars.InfoHubAHInteract == true and 
		isInteractWindowHidden == false) or 
		(RAEIH.SavedVars.InfoHubAHWorldMap == true and 
		isWorldMapHidden == false) or 
		(RAEIH.SavedVars.InfoHubAHCrafting == true and 
		isCraftingHidden == false) or
		(RAEIH.SavedVars.InfoHubAHJournal == true and 
		isJournalHidden == false) or
		(RAEIH.SavedVars.InfoHubAHGamePanels == true and 
		areGamePanelsHidden == false) or
		(RAEIH.SavedVars.InfoHubAHMailbox == true and 
		isMailInboxHidden == false) then

		RAEIH.InfoHubHidingTriggered = true

		if RAEIH.SavedVars.EnableLegatus == true then
			RAEIH_LegatusCO:SetHidden(true)
		end

		if RAEIH.SavedVars.AutoShowCraftingXP == true and isCraftingHidden == true then
			RAEIH_CraftingXP:SetHidden(true)
		elseif RAEIH.SavedVars.AutoShowCraftingXP == false and RAEIH.SavedVars.ShowCraftingXP == true and isCraftingHidden == false then
			RAEIH_CraftingXP:SetHidden(false)
		end

		if RAEIH.SavedVars.ChamberlainUseAHRules == true and RAEIH_Chamberlain ~= nil then
			RAEIH_Chamberlain:SetHidden(true)
		end

		if RAEIH.SavedVars.ShowLycanthropy == true then
			RAEIH_Lycanthropy:SetHidden(true)
		end

		RAEIH_FPS:SetHidden(true)
		RAEIH_Latency:SetHidden(true)
		RAEIH_LUAMemory:SetHidden(true)
		RAEIH_Time:SetHidden(true)
		RAEIH_Zone:SetHidden(true)
		RAEIH_Coordinates:SetHidden(true)
		RAEIH_LVR:SetHidden(true)
		RAEIH_XVP:SetHidden(true)
		RAEIH_XVPperHour:SetHidden(true)
		RAEIH_Gold:SetHidden(true)
		RAEIH_GoldperHour:SetHidden(true)
		RAEIH_BankedGold:SetHidden(true)
		RAEIH_Durability:SetHidden(true)
		RAEIH_RepairCost:SetHidden(true)
		RAEIH_BagSlots:SetHidden(true)
		RAEIH_BankSlots:SetHidden(true)
		RAEIH_Thievery:SetHidden(true)
		RAEIH_Bounty:SetHidden(true)
		RAEIH_Riding:SetHidden(true)
		RAEIH_Blacksmithing:SetHidden(true)
		RAEIH_Woodworking:SetHidden(true)
		RAEIH_Clothing:SetHidden(true)
		RAEIH_SoulGems:SetHidden(true)
		RAEIH_WeaponCharge:SetHidden(true)
		RAEIH_AttributePoints:SetHidden(true)
		RAEIH_SkyShards:SetHidden(true)
		RAEIH_SkillPoints:SetHidden(true)
		RAEIH_ChampionXP:SetHidden(true)
		RAEIH_AlliancePoints:SetHidden(true)
		RAEIH_AvARank:SetHidden(true)
		RAEIH_AchievementPoints:SetHidden(true)
		RAEIH_Friends:SetHidden(true)
		RAEIH_TimePlayed:SetHidden(true)
		RAEIH_CombatState:SetHidden(true)
		RAEIH_Vampirism:SetHidden(true)		
		RAEIH_Notification:SetHidden(true)		

	elseif RAEIH.InfoHubHidingTriggered == true then		
		
		if RAEIH_LegatusCO ~= nil then RAEIH_LegatusCO:SetHidden(not RAEIH.SavedVars.EnableLegatus) end

		if RAEIH.SavedVars.AutoShowCraftingXP == true and isCraftingHidden == true then
			RAEIH_CraftingXP:SetHidden(true)
		elseif RAEIH.SavedVars.AutoShowCraftingXP == false and RAEIH.SavedVars.ShowCraftingXP == true and isCraftingHidden == false then
			RAEIH_CraftingXP:SetHidden(false)
		end

		if RAEIH.SavedVars.ChamberlainUseAHRules == true and RAEIH_Chamberlain ~= nil then
			RAEIH_Chamberlain:SetHidden(false)
		end
		
		RAEIH_FPS:SetHidden(not RAEIH.SavedVars.ShowFPS)
		RAEIH_Latency:SetHidden(not RAEIH.SavedVars.ShowLatency)
		RAEIH_LUAMemory:SetHidden(not RAEIH.SavedVars.ShowLUAMemory)
		RAEIH_Time:SetHidden(not RAEIH.SavedVars.ShowTime)
		RAEIH_Zone:SetHidden(not RAEIH.SavedVars.ShowZone)
		RAEIH_Coordinates:SetHidden(not RAEIH.SavedVars.ShowCoordinates)
		RAEIH_LVR:SetHidden(not RAEIH.SavedVars.ShowLVR)
		RAEIH_XVP:SetHidden(not RAEIH.SavedVars.ShowXVP)
		RAEIH_XVPperHour:SetHidden(not RAEIH.SavedVars.ShowXVPperHour)
		RAEIH_Gold:SetHidden(not RAEIH.SavedVars.ShowGold)
		RAEIH_GoldperHour:SetHidden(not RAEIH.SavedVars.ShowGoldperHour)
		RAEIH_BankedGold:SetHidden(not RAEIH.SavedVars.ShowBankedGold)
		RAEIH_Durability:SetHidden(not RAEIH.SavedVars.ShowDurability)
		RAEIH_RepairCost:SetHidden(not RAEIH.SavedVars.ShowRepairCost)
		RAEIH_BagSlots:SetHidden(not RAEIH.SavedVars.ShowBagSlots)
		RAEIH_BankSlots:SetHidden(not RAEIH.SavedVars.ShowBankSlots)
		RAEIH_Thievery:SetHidden(not RAEIH.SavedVars.ShowThievery)
		RAEIH_Bounty:SetHidden(not RAEIH.SavedVars.ShowBounty)
		RAEIH_Riding:SetHidden(not RAEIH.SavedVars.ShowRiding)
		RAEIH_Blacksmithing:SetHidden(not RAEIH.SavedVars.ShowBlacksmithing)
		RAEIH_Woodworking:SetHidden(not RAEIH.SavedVars.ShowWoodworking)
		RAEIH_Clothing:SetHidden(not RAEIH.SavedVars.ShowClothing)
		RAEIH_SoulGems:SetHidden(not RAEIH.SavedVars.ShowSoulGems)
		RAEIH_WeaponCharge:SetHidden(not RAEIH.SavedVars.ShowWeaponCharge)
		RAEIH_AttributePoints:SetHidden(not RAEIH.SavedVars.ShowAttributePoints)
		RAEIH_SkyShards:SetHidden(not RAEIH.SavedVars.ShowSkyShards)
		RAEIH_SkillPoints:SetHidden(not RAEIH.SavedVars.ShowSkillPoints)
		RAEIH_ChampionXP:SetHidden(not RAEIH.SavedVars.ShowChampionXP)
		RAEIH_AlliancePoints:SetHidden(not RAEIH.SavedVars.ShowAlliancePoints)
		RAEIH_AvARank:SetHidden(not RAEIH.SavedVars.ShowAvARank)
		RAEIH_AchievementPoints:SetHidden(not RAEIH.SavedVars.ShowAchievementPoints)
		RAEIH_Friends:SetHidden(not RAEIH.SavedVars.ShowFriends)
		RAEIH_TimePlayed:SetHidden(not RAEIH.SavedVars.ShowTimePlayed)
		RAEIH_CombatState:SetHidden(not RAEIH.SavedVars.ShowCombatState)
		RAEIH_Vampirism:SetHidden(not RAEIH.SavedVars.ShowVampirism)
		RAEIH_Lycanthropy:SetHidden(not RAEIH.SavedVars.ShowLycanthropy)
		RAEIH_Notification:SetHidden(not RAEIH.SavedVars.ShowNotification)		

		RAEIH.InfoHubHidingTriggered = false
	
	end
end

-- ICON STRING POSITIONING ADJUSTMENT FOR MODULES
function RAEIH.IconStrPosAdjusting(iHeight)
	local nsY = nil
	if tostring(iHeight) == "16" then
		nsY = 3
	elseif tostring(iHeight) == "24" then
		nsY = 4.5
	elseif tostring(iHeight) == "32" then
		nsY = 6
	elseif tostring(iHeight) == "40" then
		nsY = 9
	elseif tostring(iHeight) == "48" then
		nsY = 12
	elseif tostring(iHeight) == "56" then
		nsY = 18
	elseif tostring(iHeight) == "64" then
		nsY = 24
	else
		d("Error getting New String Y Position from one of the free modules! NSY Value is: " .. tostring(nsY) .. " - iHeight is: " .. tostring(iHeight))
	end
	return nsY
end

-- SETTINGS RESET ADJUSTMENTS
function RAEIH.SetResetAdjs()
	RAEIH.SavedVars.LgtCreateFirstTime = true
	RAEIH.SavedVars.XL1CName = nil
	RAEIH.SavedVars.XL2CName = nil
	RAEIH.SavedVars.XL3CName = nil
	RAEIH.SavedVars.XL4CName = nil
	RAEIH.SavedVars.XL5CName = nil
	RAEIH.SavedVars.XL6CName = nil
	RAEIH.SavedVars.XL7CName = nil
	RAEIH.SavedVars.XL8CName = nil
	RAEIH.SavedVars.XL9CName = nil
	RAEIH.SavedVars.XL10CName = nil
	RAEIH.SavedVars.XL11CName = nil
	RAEIH.SavedVars.XL12CName = nil
	RAEIH.SavedVars.XL13CName = nil
	RAEIH.SavedVars.XL14CName = nil
	RAEIH.SavedVars.XL15CName = nil
	RAEIH.SavedVars.XL16CName = nil
	RAEIH.SavedVars.XL17CName = nil
	RAEIH.SavedVars.XL18CName = nil
	RAEIH.SavedVars.XL19CName = nil
	RAEIH.SavedVars.XL20CName = nil
	RAEIH.SavedVars.ReticleFirstTime = true
	RAEIH.ReticleMode()
	RAEIH.SavedVars.SubtitlesFirstTime = true
	RAEIH.NewSubPosition()
	RAEIH.SavedVars.GridSize = RAEIH.DefaultSavedVars.GridSize
	RAEIH.SavedVars.InfoHubFirstTime = true
	ReloadUI()
end

-- CREATE MODULE TABLE
function RAEIH.CreateModuleTable()
	local guiNumChildren = GuiRoot:GetNumChildren()
	for i = 1, guiNumChildren do
	   local userData = GuiRoot:GetChild(i)
	   if userData ~= nil then
	      local controlName = userData:GetName()
	      if controlName:match("RAEIH_") and controlName ~= "RAEIH_Subtitles" and controlName ~= "RAEIH_Reticle" then
	      	table.insert(RAEIH.MD.CName, controlName)
	      	local cFName = string.sub(controlName, 7)
	      	table.insert(RAEIH.MD.CFName, cFName)
	      	table.insert(RAEIH.MD.UD, userData)
	      end
	   end
	end
end

-- CREATE/UPDATE MODULE SAFE CHECK TABLE
function RAEIH.MSCTable()
	RAEIH.MDSC =
	{
		RAEIH.SavedVars.L1CName,
		RAEIH.SavedVars.L2CName,
		RAEIH.SavedVars.L3CName,
		RAEIH.SavedVars.L4CName,
		RAEIH.SavedVars.L5CName,
		RAEIH.SavedVars.L6CName,
		RAEIH.SavedVars.L7CName,
		RAEIH.SavedVars.L8CName,
		RAEIH.SavedVars.L9CName,
		RAEIH.SavedVars.L10CName, 
		RAEIH.SavedVars.L11CName,
		RAEIH.SavedVars.L12CName,
		RAEIH.SavedVars.L13CName,
		RAEIH.SavedVars.L14CName,
		RAEIH.SavedVars.L15CName,
		RAEIH.SavedVars.L16CName,
		RAEIH.SavedVars.L17CName,
		RAEIH.SavedVars.L18CName,
		RAEIH.SavedVars.L19CName,
		RAEIH.SavedVars.L20CName
	}
end

-- ADJUST COMPASS FOR LEGATUS
function RAEIH.LegatusCFAdj(fromSettings)
	if RAEIH.SavedVars.LegatusCF == true and RAEIH_LegatusCO ~= nil then
		local lgtW, lgtH = RAEIH_LegatusCO:GetDimensions()
		ZO_CompassFrame:ClearAnchors()
		ZO_CompassFrame:SetAnchor(TOP, GuiRoot, TOP, 0, lgtH * 2)
	elseif RAEIH.SavedVars.LegatusCF == false and fromSettings == true and RAEIH_LegatusCO ~= nil then
		ReloadUI()
	end
end

-- UPDATE MODULE STATUSES
function RAEIH.UpdateModuleStatuses()

	local mdStatus = nil	

	mdStatus = RAEIH_FPS:IsHidden()
	RAEIH.SavedVars.ShowFPS = not mdStatus

	mdStatus = RAEIH_Latency:IsHidden()
	RAEIH.SavedVars.ShowLatency = not mdStatus

	mdStatus = RAEIH_LUAMemory:IsHidden()
	RAEIH.SavedVars.ShowLUAMemory = not mdStatus

	mdStatus = RAEIH_Time:IsHidden()
	RAEIH.SavedVars.ShowTime = not mdStatus
			
	mdStatus = RAEIH_Zone:IsHidden()
	RAEIH.SavedVars.ShowZone = not mdStatus
			
	mdStatus = RAEIH_Coordinates:IsHidden()
	RAEIH.SavedVars.ShowCoordinates = not mdStatus
	
	mdStatus = RAEIH_LVR:IsHidden()			
	RAEIH.SavedVars.ShowLVR = not mdStatus
	
	mdStatus = RAEIH_XVP:IsHidden()		
	RAEIH.SavedVars.ShowXVP = not mdStatus
			
	mdStatus = RAEIH_XVPperHour:IsHidden()
	RAEIH.SavedVars.ShowXVPperHour = not mdStatus
	
	mdStatus = RAEIH_Gold:IsHidden()
	RAEIH.SavedVars.ShowGold = not mdStatus
	
	mdStatus = RAEIH_GoldperHour:IsHidden()
	RAEIH.SavedVars.ShowGoldperHour = not mdStatus
	
	mdStatus = RAEIH_BankedGold:IsHidden()
	RAEIH.SavedVars.ShowBankedGold = not mdStatus
	
	mdStatus = RAEIH_Durability:IsHidden()
	RAEIH.SavedVars.ShowDurability = not mdStatus
	
	mdStatus = RAEIH_RepairCost:IsHidden()
	RAEIH.SavedVars.ShowRepairCost = not mdStatus
	
	mdStatus = RAEIH_BagSlots:IsHidden()
	RAEIH.SavedVars.ShowBagSlots = not mdStatus
			
	mdStatus = RAEIH_BankSlots:IsHidden()
	RAEIH.SavedVars.ShowBankSlots = not mdStatus

	mdStatus = RAEIH_Thievery:IsHidden()
	RAEIH.SavedVars.ShowThievery = not mdStatus	

	mdStatus = RAEIH_Bounty:IsHidden()
	RAEIH.SavedVars.ShowBounty = not mdStatus	
			
	mdStatus = RAEIH_Riding:IsHidden()
	RAEIH.SavedVars.ShowRiding = not mdStatus
			
	mdStatus = RAEIH_Blacksmithing:IsHidden()	
	RAEIH.SavedVars.ShowBlacksmithing = not mdStatus
			
	mdStatus = RAEIH_Woodworking:IsHidden()
	RAEIH.SavedVars.ShowWoodworking = not mdStatus
			
	mdStatus = RAEIH_Clothing:IsHidden()
	RAEIH.SavedVars.ShowClothing = not mdStatus
			
	mdStatus = RAEIH_SoulGems:IsHidden()
	RAEIH.SavedVars.ShowSoulGems = not mdStatus
			
	mdStatus = RAEIH_WeaponCharge:IsHidden()
	RAEIH.SavedVars.ShowWeaponCharge = not mdStatus
			
	mdStatus = RAEIH_AttributePoints:IsHidden()
	RAEIH.SavedVars.ShowAttributePoints = not mdStatus
			
	mdStatus = RAEIH_SkyShards:IsHidden()			
	RAEIH.SavedVars.ShowSkyShards = not mdStatus
			
	mdStatus = RAEIH_SkillPoints:IsHidden()
	RAEIH.SavedVars.ShowSkillPoints = not mdStatus

	mdStatus = RAEIH_ChampionXP:IsHidden()
	RAEIH.SavedVars.ShowChampionXP = not mdStatus
			
	mdStatus = RAEIH_AlliancePoints:IsHidden()
	RAEIH.SavedVars.ShowAlliancePoints = not mdStatus

	mdStatus = RAEIH_AvARank:IsHidden()
	RAEIH.SavedVars.ShowAvARank = not mdStatus
			
	mdStatus = RAEIH_AchievementPoints:IsHidden()
	RAEIH.SavedVars.ShowAchievementPoints = not mdStatus
			
	mdStatus = RAEIH_Friends:IsHidden()
	RAEIH.SavedVars.ShowFriends = not mdStatus
			
	mdStatus = RAEIH_TimePlayed:IsHidden()
	RAEIH.SavedVars.ShowTimePlayed = not mdStatus
			
	mdStatus = RAEIH_CombatState:IsHidden()
	RAEIH.SavedVars.ShowCombatState = not mdStatus
			
	mdStatus = RAEIH_Vampirism:IsHidden()
	RAEIH.SavedVars.ShowVampirism = not mdStatus

	mdStatus = RAEIH_Lycanthropy:IsHidden()
	RAEIH.SavedVars.ShowLycanthropy = not mdStatus

	mdStatus = RAEIH_CraftingXP:IsHidden()
	RAEIH.SavedVars.ShowCraftingXP = not mdStatus
			
	mdStatus = RAEIH_Notification:IsHidden()
	RAEIH.SavedVars.ShowNotification = not mdStatus	
end