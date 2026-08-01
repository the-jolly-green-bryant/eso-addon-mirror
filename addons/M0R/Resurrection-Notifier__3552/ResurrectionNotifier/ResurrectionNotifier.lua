ResurrectionNotifier = {}
local rn = ResurrectionNotifier -- local var for easy access

rn.name = "ResurrectionNotifier"
rn.enabled = true


local function SetResStatus(text)
	if ZO_TargetUnitFramereticleoverResourceNumbers then
		ZO_TargetUnitFramereticleoverResourceNumbers:SetText(text)
	end
	if BUI_TargetResourceNumbers then
		BUI_TargetResourceNumbers:SetText(text)
	end
	if TESO_TargetFrame_Health_Text_DeadInfo then
		TESO_TargetFrame_Health_Text_DeadInfo:SetText(text)
	end
end

local function check()
	if IsUnitDead('reticleover') then
		if IsUnitBeingResurrected('reticleover') then
			SetResStatus("Being Resurrected")
		elseif DoesUnitHaveResurrectPending('reticleover') then
			SetResStatus("Resurrection Pending")
		else
			SetResStatus("Dead")
		end
	elseif IsUnitReincarnating('reticleover') then
		return -- Target is in ghost form, dont update the text
	else
		return -- Target is alive, dont update the text
	end
end

local function isRes()
	if not DoesUnitExist('reticleover') then -- If no unit in reticle anymore, stop checking for update
		EVENT_MANAGER:UnregisterForUpdate("ResStatusReticleover")
	end
	if IsUnitPlayer('reticleover') then -- Only check resurrection if target is a player
		check()
	end
end

local function OnReticleTargetChanged()
  isRes()
  EVENT_MANAGER:RegisterForUpdate("ResStatusReticleover", 100, isRes)
end





-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function rn.OnAddOnLoaded(event, addonName) -- Runs for all addons which load, so make sure that init is only called for this addon
	if addonName ~= rn.name then return end
	rn:Initialize()
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(rn.name, EVENT_ADD_ON_LOADED, rn.OnAddOnLoaded)

-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function rn:Initialize()
	EVENT_MANAGER:UnregisterForEvent(rn.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("ResStatusReticleChange", EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
end
