-- SkipDialogs.lua
if MSI == nil then MSI = MSI or {} end
local MSI = _G['MSI']

MSI.IsPaused = false

--*****************--
-- Dialog Skipping
MSI.OptionsWhitelist = {
    [CHATTER_START_TALK]               = true,
    [CHATTER_TALK_CHOICE]              = true,
    [CHATTER_START_NEW_QUEST_BESTOWAL] = true,
    [CHATTER_START_COMPLETE_QUEST]     = true,
}

local function QuestOffered(eventCode, questIndex)
if not MSI.SVars.IsSkipDialogs then return end
	if type(GetNumChatterOptions) ~= "function" then return end
	local oc = GetNumChatterOptions()
	MSI.ChatterBegin(eventCode, oc)
end

local function SafeGetOptionCurrency(i)
	if type(GetChatterOptionCurrency) == "function" then
		return GetChatterOptionCurrency(i)
	end
	return false, nil, 0
end

local function ShouldPauseInteraction(optCount)
	if MSI.SVars.IsDetectWrit and MSI.HasActiveWrit() then
		MSI.Print("d", "Crafting Writ detected → Pause")
		return true
	end

local function InVet()
	if type(IsUnitInDungeon) ~= "function"
	or type(GetCurrentDifficultySetting) ~= "function" then
		return false
	end

	return IsUnitInDungeon("player")
		and GetCurrentDifficultySetting() == DUNGEON_DIFFICULTY_VETERAN
end

	for i = 1, optCount do
		local txt = GetChatterOption(i)
		if txt then
			local lower = txt:lower()
			for _, kw in ipairs(MSI.SVars.KeyWordBlackList) do
				if kw ~= "" and lower:find(kw:lower(), 1, true) then
					MSI.Print("d", string.format("KeyWord ‘"..kw.."’ → Pause"))
					return true
				end
			end
			if MSI.SVars.IsHardModeDetect and InVet() then
				if lower:find("hard",1,true) or lower:find("suffer",1,true) or lower:find("prove",1,true) then
					MSI.Print("d", "Hard-Mode string → Pause")
					return true
				end
			end
		end
		if MSI.SVars.IsCostDetection then
			local cost, _, amt = SafeGetOptionCurrency(i)
			if cost and amt > 0 then
				MSI.Print("d", string.format("Option %d Costs %d → Pause", i, amt))
				return true
			end
		end
	end
	return false
end

local function ConversationUpdated(_, _, oc) MSI.ChatterBegin(_, oc) end

function MSI.ChatterBegin(_, oc)
if not MSI.SVars.IsSkipDialogs then return end
	if ShouldPauseInteraction(oc) then
		MSI.IsPaused = true
		return
	end

	local allChosen, special = true, nil

	for i = 1, oc do
		local txt, typ, _, imp, chosen = GetChatterOption(i)
		allChosen = allChosen and chosen
		if MSI.SVars.IsSkipDialogs and not chosen and (txt:sub(1,10)=="[Persuade]" or txt:sub(1,11)=="[Intimidate]") then
			special = special or i
		end
    end

    if special then
		MSI.Print("d", "Special Option picked")
		SelectChatterOption(special) return end

	for i = 1, oc do
		local txt, typ,_, imp, chosen = GetChatterOption(i)
		if MSI.SVars.IsSkipDialogs 
		and not chosen 
		and ((not imp) 
			or MSI.SVars.IsSkipImportant) 
		and MSI.OptionsWhitelist[typ] then
			SelectChatterOption(i) return end
	end

	if MSI.SVars.IsSkipDialogs and allChosen then EndInteraction(INTERACTION_CONVERSATION)
	end
end

local function QuestComplete()
	if MSI.IsPaused then return end
	if not MSI.SVars.IsMSIActive then return end
	if MSI.SVars.IsSkipDialogs then CompleteQuest() end
end

local function ChatterEnd()
	if MSI.IsPaused then
	if not MSI.SVars.IsMSIActive then return end
		MSI.IsPaused = false
		MSI.Print("d", "Unpaused")
	end
end

--***************--
-- Skip Dialogs
function MSI.InitModSkipDialogs()
	local function UnRegModuleEvents()
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."DialogOffer", EVENT_QUEST_OFFERED)
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."DialogQuest", EVENT_QUEST_COMPLETE_DIALOG)
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."DialogBegin", EVENT_CHATTER_BEGIN)
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."DialogEnd", EVENT_CHATTER_END)
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."DialogUpdate", EVENT_CONVERSATION_UPDATED)
	end
	local function RegModuleEvents()
		UnRegModuleEvents()
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."DialogOffer", EVENT_QUEST_OFFERED, QuestOffered)
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."DialogQuest", EVENT_QUEST_COMPLETE_DIALOG, QuestComplete)
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."DialogBegin", EVENT_CHATTER_BEGIN, MSI.ChatterBegin)
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."DialogEnd", EVENT_CHATTER_END, ChatterEnd)
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."DialogUpdate", EVENT_CONVERSATION_UPDATED, ConversationUpdated)
	end
	if MSI.SVars.IsSkipDialogs and MSI.SVars.IsMSIActive then
		RegModuleEvents()
		--MSI.Print("d", "Modul enabled!! SkipDialogs Event registered")
	elseif not MSI.SVars.IsSkipDialogs or not MSI.SVars.IsMSIActive then
		UnRegModuleEvents()
		--MSI.Print("d", "Modul disabled!! SkipDialogs Event unregistered")
	else
		UnRegModuleEvents()
		--MSI.Print("d", "MSI |c8B0000not|r Active!! SkipDialogs Event unregistered")
	end
end
--eof