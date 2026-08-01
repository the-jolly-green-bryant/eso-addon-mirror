
ColourfulESO = {}

ColourfulESO.default = {

}

ColourfulESO.version = 1
ColourfulESO.name = "ColourfulESO"
local savedVars = {}

local colouredStrings = {}

local function StripColorAndWhitespace(text)
    text = zo_strtrim(text)
    text = string.gsub(text, "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]", "")
    text = string.gsub(text, "|r", "")
    return text
end

local function shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit()  return GetDate()==20170401  or GetDisplayName()=="@Dolgubon"  end


local replace = "'"..GetString(SI_SMITHING_HEADER_TRAIT).."'"--SI_ITEMTRAITTYPE18
local function GetId(index)
    local id = _G[zo_strformat("SI_ITEMTRAITTYPE<<1>>", index)]
    return id
end

local function IsCheeseNice(t)
	local total = t[1] + t[2] + t[3] 
	local factor = (3-math.sqrt( total))
	for i = 1, 3 do
		t[i] = t[i]*factor
		if t[i]>1 then t[i] = 1 end
		if t[i]<0 then t[i] = 0 end
	end
	local low = t[1]-0.2
	local high = t[1]+0.2
	if high>1 then
		low = low -high +1
		high = 1
	elseif low<0 then
		high = high - low
		low = 0
	end
	if t[2]>low and t[2]<high and t[3]>low and t[3]<high then
		return false
	else
		return true
	end
end
local function GetNiceCheese()
	local t = {math.random(),math.random(),math.random()}
	while true do
		if IsCheeseNice(t) then
			break
		else
			t = {math.random(),math.random(),math.random()}
		end
	end
	return t
end
-- 0-360, 48-100, 40-71
local function SheogorathsCheese()
	

	local t= {math.random(0,360),math.random(50,100),math.random(25,60)}
	--local f = (t[1]%60)/60
	t[2] = t[2]/100
	t[3] = 1-t[3]/100
	local i = math.floor(t[1]/60)
	local f = t[1]/60-i
	local p = 1-t[3]*(1-t[2])
	local q = 1-t[3]*(1-f*t[2])
	local s = 1-t[3]*(1-(1-f)*t[3])

	if t[1]<60 then
		return{t[3],s,p}
	elseif t[1]<120 then
		return {q,t[3],p}
	elseif t[1]<180 then
		return {p,t[3],s}
	elseif t[1]<240 then
		return {p,q,t[3]}
	elseif t[1]<300 then
		return {s,p,t[3]}
	else
		return {t[3],p,q}
	end
	return {r,g,b}

end


local function setupReplacement(object, functionName, positionOfText)
	local original = object[functionName]
	
	if positionOfText == 1 then
		object[functionName] = function(self, text, ...)
		if not text then return end
			local heisenbergsCheese = colouredStrings[text]
			
			if not heisenbergsCheese then
				
				local curedCheese = ZO_ColorDef:New(unpack(SheogorathsCheese())):Colorize(text)
				colouredStrings[text] = curedCheese
				
				original(self, curedCheese, ...)
			else
				original(self, heisenbergsCheese, ...)
			end
		end
	else
	end
end
setupReplacement(InformationTooltip, "AddLine", 1)

local function normalCheeseLovers()
return 
{
	-- Reticles
	ZO_ReticleContainerInteractContext,
	ZO_ReticleContainerInteractKeybindButton,
	ZO_ReticleContainerNonInteractText,
	-- Compass Label
	ZO_CompassCenterOverPinLabel,
	-- Dialog Confirmation
	ZO_Dialog1Text,
	-- Death buttons
	ZO_DeathReleaseOnlyButton1NameLabel,
	ZO_DeathTwoOptionButton2NameLabel,
	ZO_DeathTwoOptionButton1NameLabel,
	--subtitles
	ZO_SubtitlesText,
	-- Interact window
	ZO_InteractWindowTargetAreaBodyText,
	ZO_InteractWindowTargetAreaTitle,

	-- Chat tabs (Not functional atm)
	--
	ZO_ChatWindowTabTemplate1Text,
	ZO_ChatWindowTabTemplate2Text,
	ZO_ChatWindowTabTemplate3Text,
	ZO_ChatWindowTabTemplate4Text,
	ZO_ChatWindowTabTemplate5Text,
	ZO_ChatWindowTabTemplate6Text,
	ZO_ChatWindowTabTemplate7Text,
	ZO_ChatWindowTabTemplate8Text,
	ZO_ChatWindowTabTemplate9Text,
	ZO_ChatWindowNumUnreadMail,
	ZO_ChatWindowNumOnlineFriends,
	ZO_ChatWindowNumNotifications,--]]
	-- Levels (Not functional)
	ZO_PlayerProgressLevel,
	ZO_PlayerProgressLevelType,
	ZO_PlayerProgressChampionPoints,
}
end

local function generateSkilledCheeseLovers()
	local skilledCheeseLovers = 
	{
		ZO_SkillsSkillInfoName,
		ZO_SkillsSkillInfoRank,
	}
	for i = 1, 9 do
		skilledCheeseLovers[#skilledCheeseLovers + 1] =  GetControl("ZO_SkillsAbilityList1Row"..i.."Name")
	end
	for i = 1, 8 do
		skilledCheeseLovers[#skilledCheeseLovers + 1] =  GetControl("ZO_SkillsNavigationContainerScrollChildZO_SkillIconHeader"..i.."Text")
	end
	for i = 1, 3 do
		skilledCheeseLovers[#skilledCheeseLovers + 1] =  GetControl("ZO_SkillsAbilityList2Row"..i.."Label")
	end
	for i = 1, 29 do
		skilledCheeseLovers[#skilledCheeseLovers + 1] =  GetControl("ZO_SkillsNavigationContainerScrollChildZO_SkillsNavigationEntry"..i)
	end
	return skilledCheeseLovers
end
local function generateAdventerousCheeseLovers()
	local adventerousCheeseLovers = 
	{
		ZO_QuestJournalTitleText,
		ZO_QuestJournalLevelText,
		ZO_QuestJournalRepeatableText,
		ZO_QuestJournalBGText,
		ZO_QuestJournalStepText,
		ZO_QuestJournalTasksText,
		ZO_QuestJournalOptionalStepTextLabel,
		ZO_QuestJournalConditionTextOrLabel,
	}
	for i = 1, 25 do
		adventerousCheeseLovers[#adventerousCheeseLovers + 1]= GetControl("ZO_QuestJournalNavigationContainerScrollChildZO_QuestJournalNavigationEntry"..i)
	end
	return adventerousCheeseLovers
end

ColourFails = {}

local function feedTheCheeseLovers(appliedCheeseLover, functionName)
	if type(appliedCheeseLover) ~="table" then
		d("Non table passed")
		return
	end
	for i = 1, #appliedCheeseLover do
		if appliedCheeseLover[i] and type(appliedCheeseLover[i]) == "userdata" then

			setupReplacement(appliedCheeseLover[i], functionName, 1)
			if appliedCheeseLover[i].GetText and appliedCheeseLover[i].SetText then
				appliedCheeseLover[i]:SetText(appliedCheeseLover[i]:GetText() or "")
			end
		elseif appliedCheeseLover[i] == nil then
			ColourFails[#ColourFails + 1] = i
		end
	end
end
local runOnce = 
{
}
local scene = "skills"
local function addCheeseLovingScene(scene, cheeseGenerator)
	if type(cheeseGenerator) == "function" then
		SCENE_MANAGER.scenes[scene]:RegisterCallback("StateChange", function() if not runOnce[scene] then 
		runOnce[scene] = runOnce[scene] == false or runOnce[scene]
		feedTheCheeseLovers(cheeseGenerator(), "SetText") end end )
	end
end
addCheeseLovingScene("skills", generateSkilledCheeseLovers)
addCheeseLovingScene("questJournal",generateAdventerousCheeseLovers)

scene = "questJournal"
SCENE_MANAGER.scenes["questJournal"]:RegisterCallback("StateChange", function() if not runOnce['questJournal'] then 
	runOnce['questJournal'] = runOnce['questJournal'] == false or runOnce['questJournal']
	feedTheCheeseLovers(generateAdventerousCheeseLovers(), "SetText") end end )

function ColourfulESO:RegisterCheeseLover(newCheeseLover, optionalFunctionName, optionalTextPosition)
	if newCheeseLover == nil then d("Nil value") return end
	setupReplacement(newCheeseLover, optionalFunctionName or "SetText", optionalTextPosition or 1)
end

--[[	str = StripColorAndWhitespace(str)
	local Cheese = SheogorathsCheese()
	str = ZO_ColorDef:New(unpack(Cheese)):Colorize(str)

	Override(index, str)]]
--[[
local function Override(index, value)

    SafeAddString(index, value, 2) end
function divineSeeingString(index, force)
	str = GetString(index)
	if string.find(str,"/") or string.find(str,"_") or string.find(str,"<") or string.find(str,"|") then
		if index==SI_INVENTORY_HEADER or index == SI_ABILITY_TOOLTIP_NAME or index==SI_QUEST_JOURNAL_QUEST_NAME_FORMAT or index==SI_GUILD_HIRED_TRADER 
			or force
			then
		else
			return 
		end
	end
	if string.find(str,"Guild")  then
		if string.find(str,"Thieves Guild") or string.find(str,"Guild Trader") or index>2900 or index<2100 then
		else
			return
		end
	end


end]]
local originalFormat = zo_strformat--[[
if shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit() then
stringTables = {}
tester = {}
zo_strformat = function(str,...)
	local oriStr = str
	str = originalFormat(str,...)
	if string.find(str,"Gold Claw") then tester[#tester+1] = {oriStr,str,string.len(str)} return str end
	if stringTables[str] then return stringTables[str][1]end
	local fstr = str
	str = ZO_ColorDef:New(unpack (SheogorathsCheese())):Colorize(str)
	stringTables[fstr] = {str,oriStr}
	return str
end
end]]
--[[
	local low = t[1]-0.15
	local high = t[1]+0.15
	if high>1 then
		low = low -high +1
		high = 1
	elseif low<0 then
		high = high - low
		low = 0
	end
	if t[2]>low and t[2]<high and t[3]>low and t[3]<high then
		return false
	else
		return true
	end
local total = t[1] + t[2] + t[3] 
	local factor = 3.5/total
	for i = 1, 3 do
		t[i] = t[i]*factor
		if t[i]>1 then t[i] = 1 end
	end]]


local function divinityProtocol()
	if true then return end
    --
    local t = {

	{SI_ABILITYUPGRADELEVEL0, SI_GAMECAMERAACTIONTYPE1 },
	{SI_GAMECAMERAACTIONTYPE24 , SI_CADWELLPROGRESSIONLEVEL2}

}
--SI_GAMECAMERAACTIONTYPE1
--SI_GAMECAMERAACTIONTYPE24
    for k, v in pairs(t) do 
		for i = v[1], v[2] do
			divineSeeingString(i)
		end
	end

	divineSeeingString(SI_ABILITY_TOOLTIP_NAME,true)
	divineSeeingString(SI_ABILITY_NAME_AND_RANK,true)

	divineSeeingString(SI_ABILITY_NAME_AND_UPGRADE_LEVELS,true)
	divineSeeingString(SI_ABILITY_TOOLTIP_DESCRIPTION_HEADER,true)
	--SI_SKILLS_ENTRY_NAME_FORMAT/
	--[[
	local CheeseHaterGroups = {
	{[1] = SI_GAME_MENU_SETTINGS, [2] = SI_ADDON_MANAGER_AUTHOR},
	 {[1] = SI_ADDONLOADSTATE6,[2] = SI_NONSTR_ZOGUIENUMS_LAST_ENTRY},
	 {[1] = SI_GUILDPERMISSION1, [2] = SI_GUILDEVENTTYPE43},
	 {[1] = SI_GAMEPAD_GUILD_HUB_SCREEN_EXPLANATION,[2] = SI_GAMEPAD_GUILD_HISTORY_SUBCATEGORY_ALL},
	 {[1]= SI_GUILD_NUM_MEMBERS_ONLINE_FORMAT,[2] = SI_GUILD_EVENT_NO_PARAM_FORMAT},
	 {[1] = SI_DEATH_PROMPT_HERE, [2] = SI_DEATH_RECAP_TOGGLE_KEYBIND,},
	}
	table.sort(CheeseHaterGroups,function(a,b) return a[1]<b[1]end)
	local CheeseHaterPpl = {SI_NOTIFICATIONTYPE11,SI_KEYBINDINGS_LAYER_DIALOG,SI_GAME_MENU_LOGOUT,
	SI_DIALOG_BUTTON_TEXT_LOGOUT_CANCEL,SI_NEW,SI_GUILD_UPDATES_HEADER,SI_GUILD_BACKGROUND_INFO_HEADER,SI_DEATH_RECAP_TOGGLE_KEYBIND,}
	table.sort(CheeseHaterPpl)
	local i = 1
	local lastCheeseHater = 1
	local lastCheeseHaterPerson = 1
	while i<SI_WEAPON_INDICATOR_TOOLTIP do 
		for j = lastCheeseHater, #CheeseHaterGroups do
			if i==CheeseHaterGroups[j][1] then
				i = CheeseHaterGroups[j][2]
			end
		end
		if CheeseHaterPpl[lastCheeseHaterPerson]==i then
			lastCheeseHaterPerson = lastCheeseHaterPerson + 1
		else
			divineSeeingString(i)
		end
		i = i+1
	end]]
end



function ColourfulESO:Initialize()
	--[[LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsWritCrafter", ColourfulESO.settings["panel"])
	ColourfulESO.settings["options"] = ColourfulESO.langOptions()
	LAM:RegisterOptionControls("DolgubonsWritCrafter", ColourfulESO.settings["options"])]]

	ColourfulESO.savedVars = ZO_SavedVars:NewAccountWide("colourfuleso", ColourfulESO.version, nil, ColourfulESO.default)
	divinityProtocol()
	
	checkThisTest = ZO_Dialog1Text
	feedTheCheeseLovers(normalCheeseLovers(), "SetText")
	
end
--feedTheCheeseLovers(normalCheeseLovers(), "SetText")

--local function closeWindow () ColourfulESOWindow:SetHidden(not ColourfulESOWindow:IsHidden()) end


function ColourfulESO.OnAddOnLoaded(event,initial)
	if initial then
		--ColourfulESO:Initialize()
	end
	if initial == ColourfulESO.name then
		ColourfulESO:Initialize()
	end

end 

EVENT_MANAGER:RegisterForEvent(ColourfulESO.name, EVENT_ADD_ON_LOADED, ColourfulESO.OnAddOnLoaded)