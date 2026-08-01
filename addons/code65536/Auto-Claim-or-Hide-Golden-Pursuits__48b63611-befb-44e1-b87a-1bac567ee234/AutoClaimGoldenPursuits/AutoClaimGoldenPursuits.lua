local NAME = "AutoClaimGoldenPursuits"
local TITLE = "Auto-Claim or Hide Golden Pursuits"
local SV = nil


--------------------------------------------------------------------------------
-- Disable Auto-Pin
--------------------------------------------------------------------------------

TryAutoTrackNextPromotionalEventCampaign = function() end


--------------------------------------------------------------------------------
-- Auto-Claim
--------------------------------------------------------------------------------

local RESPONSE_TIME_LIMIT = 2500
local PendingClaims = { }

local function CheckForAndClaimGoldenPursuits( )
	if (not SV.hideOnly and not IsPromotionalEventSystemLocked()) then
		for i = 1, GetNumActivePromotionalEventCampaigns() do
			local campaignKey = GetActivePromotionalEventCampaignKey(i)
			if (ShouldPromotionalEventCampaignBeVisible(campaignKey) and IsAnyPromotionalEventCampaignRewardClaimable(campaignKey)) then
				local key = Id64ToString(campaignKey)
				local ms = PendingClaims[key] or 0
				PendingClaims[key] = GetGameTimeMilliseconds()
				if (PendingClaims[key] - ms > RESPONSE_TIME_LIMIT) then
					TryClaimAllAvailablePromotionalEventCampaignRewards(campaignKey)
				end
			end
		end
	end
end

local function CheckForGoldenPursuitClaimResult( _, campaignKey )
	local key = Id64ToString(campaignKey)
	if (GetGameTimeMilliseconds() - (PendingClaims[key] or 0) <= RESPONSE_TIME_LIMIT) then
		CHAT_ROUTER:AddSystemMessage(GetString(SI_PROMOTIONAL_EVENT_REWARD_CLAIMED_ANNOUNCEMENT))
		PendingClaims[key] = nil
	end
end


--------------------------------------------------------------------------------
-- Hide Prompt
--
-- PROMOTIONAL_EVENT_MANAGER will always call our function after theirs (unless
-- someone else registers a priority callback, but that is very unlikely), but
-- the callback order of EVENT_PLAYER_ACTIVATED is not deterministic, hence the
-- need for a next-frame delay.
--------------------------------------------------------------------------------

local function HideGoldenPursuitPrompt( )
	PLAYER_TO_PLAYER:RemoveFromIncomingQueue(ZO_INTERACT_TYPE.PROMOTIONAL_EVENT_REWARD)
end

local function HideGoldenPursuitPromptOnNextFrame( )
	EVENT_MANAGER:RegisterForUpdate(NAME, 0, HideGoldenPursuitPrompt, true)
end


--------------------------------------------------------------------------------
-- Settings and Initialization
--------------------------------------------------------------------------------

local function CheckOperationMode( )
	if (not SV.hideOnly) then
		EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED, CheckForAndClaimGoldenPursuits)
		EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PROMOTIONAL_EVENTS_CAMPAIGNS_UPDATED, CheckForAndClaimGoldenPursuits)
		EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PROMOTIONAL_EVENTS_REWARDS_CLAIMED, CheckForGoldenPursuitClaimResult)
		CheckForAndClaimGoldenPursuits()
	else
		EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PROMOTIONAL_EVENTS_CAMPAIGNS_UPDATED)
		EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PROMOTIONAL_EVENTS_REWARDS_CLAIMED)
		EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, HideGoldenPursuitPromptOnNextFrame)
		PROMOTIONAL_EVENT_MANAGER:RegisterCallback("RewardsClaimed", HideGoldenPursuitPrompt)
		PROMOTIONAL_EVENT_MANAGER:RegisterCallback("CampaignsUpdated", HideGoldenPursuitPrompt)
		PROMOTIONAL_EVENT_MANAGER:RegisterCallback("ActivityProgressUpdated", HideGoldenPursuitPrompt)
		HideGoldenPursuitPromptOnNextFrame()
	end
end

local function InitializeSettings( )
	SV = AutoClaimGoldenPursuitsSavedVariables or { }

	local LAM = LibAddonMenu2
	if (LAM) then
		local LANG = GetCVar("Language.2")
		local OPTION_LABEL = { default = "Hide instead of auto-claim", de = "Ausblenden statt Auto-Akzeptieren", es = nil, fr = nil, jp = nil, ru = nil, zh = nil }

		LAM:RegisterAddonPanel(NAME, {
			type = "panel",
			name = TITLE,
			author = "@code65536",
		})

		LAM:RegisterOptionControls(NAME, {
			{
				type = "checkbox",
				name = OPTION_LABEL[LANG] or OPTION_LABEL.default,
				getFunc = function() return SV.hideOnly end,
				setFunc = function( hideOnly )
					SV.hideOnly = hideOnly
					AutoClaimGoldenPursuitsSavedVariables = SV
					CheckOperationMode()
				end,
			},
		})
	end
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function( )
	InitializeSettings()
	CheckOperationMode()
end, true)
