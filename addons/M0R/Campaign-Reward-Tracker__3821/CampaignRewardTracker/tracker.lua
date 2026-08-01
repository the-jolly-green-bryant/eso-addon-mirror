CampaignRewardTracker = {}
crt = CampaignRewardTracker
crt.name = "CampaignRewardTracker"
crt.version = "1.0"
crt.varversion = 1

crt.chars = {}
for i = 1, GetNumCharacters() do
	local name, _, _, classID, _, allianceID = GetCharacterInfo(i)
	local charName = zo_strformat("<<1>>", name)
	crt.chars[#crt.chars+1] = {
		name = charName,
		class = classID,
		alliance = allianceID
	}
end
table.sort(crt.chars, function(a, b) return a.name < b.name end)

function crt.updateTier()
	QueryCampaignLeaderboardData(ALLIANCE_NONE)
	crt.updateTime()
	local currentCharecter = GetUnitName("player")
	local tier = GetPlayerCampaignRewardTierInfo(GetAssignedCampaignId())
	--tier = 1
	--d(charName.." is tier "..tier)
	crt.vars[currentCharecter] = tier
end

SLASH_COMMANDS['/tier'] = crt.updateTier


local function setupHooks()
	ZO_PreHook("ReloadUI", crt.updateTier)
	ZO_PreHook("Logout", crt.updateTier)
	ZO_PreHook("Quit", crt.updateTier)
end



function crt.createList()
	local currentChar = 1
	crt.rows = {}
	local parent = CampaignRewardTrackerControl
	local headersControl = parent:GetNamedChild("Headers")

	for i=1,#crt.chars do
		local activeChar = crt.chars[i]

		local control = CreateControlFromVirtual("CampaignRewardsTrackerRow"..currentChar, parent, "CRTListRow")
		if currentChar == 1 then
			control:SetAnchor(TOPLEFT, headersControl, BOTTOMLEFT, 0, 0)
		else
			control:SetAnchor(TOPLEFT, crt.rows[#crt.rows], BOTTOMLEFT, 0, 0)
		end

		control.activeChar = activeChar


		local allianceColor = GetAllianceColor(activeChar.alliance)
		local classIcon = allianceColor:Colorize(string.format('|t32:32:%s:inheritcolor|t', GetClassIcon(activeChar.class)))

		control:GetNamedChild("Name"):SetText(classIcon..activeChar.name)

		local tier = crt.vars[activeChar.name]
		if tier then
			control:GetNamedChild("Tier"):SetText(tier)
			if tier >= 1 then
				control:GetNamedChild("Name"):SetColor(0,1,0)
				control:GetNamedChild("Tier"):SetColor(0,1,0)
			end
		end

		table.insert(crt.rows, control)
		currentChar = currentChar + 1
	end
	local spacer = CreateControlFromVirtual("CampaignRewardTrackerListSpacer", parent, "CRTSpacer")
	spacer:SetAnchor(TOPLEFT, crt.rows[#crt.rows], BOTTOMLEFT, 0, 0)
end


function crt.updateList()
	crt.updateTier()
	for i=1,#crt.rows do
		local control = crt.rows[i]
		local activeChar = control.activeChar

		local allianceColor = GetAllianceColor(activeChar.alliance)
		local classIcon = allianceColor:Colorize(string.format('|t32:32:%s:inheritcolor|t', GetClassIcon(activeChar.class)))

		control:GetNamedChild("Name"):SetText(classIcon..activeChar.name)

		local tier = crt.vars[activeChar.name]
		if tier then
			control:GetNamedChild("Tier"):SetText(tier)
			if tier >= 1 then
				control:GetNamedChild("Name"):SetColor(0,1,0)
				control:GetNamedChild("Tier"):SetColor(0,1,0)
			else
				control:GetNamedChild("Name"):SetColor(1,1,1)
				control:GetNamedChild("Tier"):SetColor(1,1,1)
			end
		end
	end
end


function crt.updateTime()
	local campaign = GetAssignedCampaignId()
	local ruleset = GetCampaignRulesetId(campaign)
	local duration = GetCampaignRulesetDurationInSeconds(ruleset)

	if duration == 2592000 then

		local remainingTime = GetSecondsUntilCampaignEnd(campaign)
		if remainingTime == 0 then return end
		if remainingTime > crt.nextCampaign.remainingTime then
			-- campaign reset
			crt.vars:ResetToDefaults()
		end
		crt.nextCampaign.remainingTime = remainingTime

	end
end




-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function crt.OnAddOnLoaded(event, addonName)

	if addonName ~= crt.name then return end

	crt:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function crt:Initialize()
	-- Addon Settings Menu
	crt.vars = ZO_SavedVars:NewAccountWide("CRTtiers", crt.varversion, nil, {})
	crt.nextCampaign = ZO_SavedVars:NewAccountWide("CRTNextCampaign", crt.varversion, nil, {remainingTime=0})

	crt.updateTime()
	crt.updateTier()
	crt.createList()
	setupHooks()


	local fragment = ZO_HUDFadeSceneFragment:New(CampaignRewardTrackerControl, DEFAULT_SCENE_TRANSITION_TIME, 0)
	SCENE_MANAGER:GetScene("campaignBrowser"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("campaignOverview"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("leaderboards"):AddFragment(fragment)


    local control = CampaignRewardTrackerControl

    fragment:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            crt.updateList()
            control:ClearAnchors()
            control:SetAnchor(TOPRIGHT, ZO_SharedRightBackground, TOPLEFT, -16, 0)
        end
    end)

	EVENT_MANAGER:UnregisterForEvent(crt.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(crt.name, EVENT_ADD_ON_LOADED, crt.OnAddOnLoaded)