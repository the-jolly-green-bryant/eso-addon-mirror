BannerTracker = BannerTracker or { }
local BannerTracker = BannerTracker


BannerTracker.name = 'BannerTracker'
BannerTracker.isUIUnlocked = false
BannerTracker.initialLogin = false
BannerTracker.version = "1.0.5"



local DEBUG = false

BannerTracker.defaults = {
    x = 300,
    y = 300,
    isBannerActive = false,
    currentZoneId = nil,
    isBannerEquipped = false,
    isCombatOnly = false,
}
BannerTracker.addonLoaded = false




function BannerTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()
    if BannerTracker.isBannerSkillSlotted() then
        BannerTracker.LoadAddon()
    else
        BannerTracker.UnloadAddon()
    end
    BannerTracker.refreshUi()
end




function BannerTracker.OnReticleHiddenChanged(eventCode, hidden)
    if hidden and BannerTracker.isUIUnlocked == false then
        BannerTracker_UI:SetHidden(true)
    else
        BannerTracker.refreshUi()
    end
end






function BannerTracker.LoadAddon()
    if BannerTracker.addonLoaded == false then
        -- load events
        if DEBUG then d("Loading Banner Tracker") end

        for k, v in pairs(BannerTracker.bannersEffects) do

            EVENT_MANAGER:RegisterForEvent(BannerTracker.name..k, EVENT_EFFECT_CHANGED, BannerTracker.ecBanner)
            EVENT_MANAGER:AddFilterForEvent(BannerTracker.name..k, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
            EVENT_MANAGER:AddFilterForEvent(BannerTracker.name..k, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, v)

        end

        EVENT_MANAGER:RegisterForEvent(BannerTracker.name, EVENT_RETICLE_HIDDEN_UPDATE, BannerTracker.OnReticleHiddenChanged)



        BannerTracker.sv.isBannerActive = BannerTracker.IsBannerActive()

        BannerTracker.addonLoaded=true
	end
end

function BannerTracker.UnloadAddon()
    if BannerTracker.addonLoaded == true then
        -- unload events
        if DEBUG then d("Unloading Banner Tracker") end

        for k, v in pairs(BannerTracker.bannersEffects) do
            EVENT_MANAGER:UnregisterForEvent(BannerTracker.name..k, EVENT_EFFECT_CHANGED)
        end


        EVENT_MANAGER:UnregisterForEvent(BannerTracker.name, EVENT_RETICLE_HIDDEN_UPDATE)

        BannerTracker_UI:SetHidden(true)

        BannerTracker.sv.isBannerActive = false
	    BannerTracker.addonLoaded=false
	end
end


function BannerTracker.skillInfoBySlot(slot,bar)
    local value = 0
    local crafted1 = 0
    local crafted2 = 0
    local crafted3 = 0

    local id = 0
    local slotType = 0


    id = GetSlotBoundId(slot, bar)
    slotType = GetSlotType(slot, bar)


    if slotType == ACTION_TYPE_CRAFTED_ABILITY then
        crafted1, crafted2, crafted3 = GetCraftedAbilityActiveScriptIds(id)
        value = GetAbilityIdForCraftedAbilityId(id)
    else
        value = id
    end
    --d("bar"..bar.. " slot".. slot.." v:"..value.." c1:"..crafted1.." c2:"..crafted2.." c3:"..crafted3)
    return value, crafted1, crafted2, crafted3
end

-- print the banner in slot 1
--function BannerTracker.printBanner()
--    local id, c1, c2, c3 = BannerTracker.skillInfoBySlot(3,1)
--    local name = GetAbilityName(id)
--    d("   [" .. id .. "] = {\"" .. name .. "\"},")
--end


BannerTracker.bannerSkills = {
    [217699] = {true}, -- Shattering Banner, Magical Banner, Fortifying Banner, Sundering Banner, Restorative Banner, Shocking Banner
    [252259] = {true}, -- Fiery Banner
    [230289] = {true}, -- Binding Banner
}


BannerTracker.bannersEffects = {
--   Banner Name              EffectAbilityId
   ["Shattering Banner"] =    227004,
   ["Fiery Banner"] =         227003,
   ["Binding Banner"] =       227009,
   ["Magical Banner"] =       217705,
   ["Fortifying Banner"] =    227008,
   ["Sundering Banner"] =     217704,
   ["Restorative Banner"] =   227007,
   ["Shocking Banner"] =      217706
}

BannerTracker.slottedBannerName = ""
function BannerTracker.IsBannerActive()
    if BannerTracker.slottedBannerName=="" then
        return false
    end
    local activeBannerName = BannerTracker.getActiveBannerName()

	for i=1,GetNumBuffs("player") do
		local buffName, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player",i)
        if buffName == activeBannerName then

            return true
        end
    end

    return false
end



function BannerTracker.isBannerAbility(slot, bar)
    local id, c1, c2, c3 = BannerTracker.skillInfoBySlot(slot,bar)

    if BannerTracker.bannerSkills [id] == nil then
        return false
    else

        BannerTracker.slottedBannerName = GetAbilityName(id)
        --BannerTracker.slottedBanner = id
        return true
    end

end

function BannerTracker.checkIfOakensoulEquipped()
	local oakensoul = 0
	_,_,_,oakensoul = GetItemLinkSetInfo("|H1:item:187658:364:50:45884:370:50:31:0:0:0:0:0:0:0:2049:0:0:1:0:0:0|h|h",true)
	if oakensoul>=1 then
		return true
	else
		return false
	end
end


function BannerTracker.isBannerSkillSlotted()
    local hasBannerFrontbar = false
    local hasBannerBackbar = false

    for hotbarSlot = 3, 7 do
        if BannerTracker.isBannerAbility(hotbarSlot, HOTBAR_CATEGORY_PRIMARY) then
            hasBannerFrontbar = true
        end
        if BannerTracker.isBannerAbility(hotbarSlot, HOTBAR_CATEGORY_BACKUP) then
            hasBannerBackbar = true
        end
    end
    if (hasBannerFrontbar and hasBannerBackbar) or (BannerTracker.checkIfOakensoulEquipped() and (hasBannerFrontbar or hasBannerBackbar)) then
        BannerTracker.sv.isBannerEquipped = true
        return true
    else
        BannerTracker.sv.isBannerEquipped = false
        BannerTracker.slottedBannerName = ""
        return false
    end
end



function BannerTracker.refreshUi()
    if BannerTracker.sv.isBannerEquipped and BannerTracker.sv.isBannerActive == false and (IsReticleHidden()==false or BannerTracker.isUIUnlocked == true) then
        if BannerTracker.sv.isCombatOnly == false or IsUnitInCombat("player") then
            BannerTracker_UI:SetHidden(false)
        else
            BannerTracker_UI:SetHidden(true)
        end
    else
        BannerTracker_UI:SetHidden(true)
    end
end


-- If player entered new zone or just logged in Banner is deactivated, therefore ui should do the same
function BannerTracker.OnPlayerActivated(eventCode, initial)
    local zoneId = GetUnitWorldPosition('player')
    if (BannerTracker.initialLogin and initial) or zoneId ~= BannerTracker.sv.currentZoneId then
        BannerTracker.initialLogin = false
        BannerTracker.sv.currentZoneId = zoneId
        BannerTracker.sv.isBannerActive = false
    end

    BannerTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()
    BannerTracker.refreshUi()
end

-- Save ui location after moving
function  BannerTracker.OnMoveStop()
    BannerTracker.sv.x, BannerTracker.sv.y = BannerTracker_UI:GetCenter()
end

function BannerTracker.getActiveBannerName()
    return BannerTracker.slottedBannerName
end

function BannerTracker.getActiveBannerEffect()
    if BannerTracker.slottedBannerName=="" then
        return 0
    else
        return BannerTracker.bannersEffects[BannerTracker.slottedBannerName]
    end
end

function BannerTracker.ecBanner(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
	if unitTag=="player" then
        if BannerTracker.getActiveBannerEffect() == abilityID then
            if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then

                BannerTracker.sv.isBannerActive = true
                BannerTracker.refreshUi()

                if DEBUG then d("Banner up") end

            elseif changeType == EFFECT_RESULT_FADED then
                if BannerTracker.IsBannerActive() == false then


                    BannerTracker.sv.isBannerActive = false
                    BannerTracker.refreshUi()


                    if DEBUG then d("Banner down") end
                end
            end
        else
            if DEBUG then d("rejected effect changed: "..effectName.." [".. abilityID.."]") end

        end

    else
        if DEBUG then d("ecBanner wrong filter: "..effectName .."("..abilityID..") "..unitTag ) end

	end
end

function BannerTracker.toggleUiLock()
    BannerTracker.isUIUnlocked = not BannerTracker.isUIUnlocked
    BannerTracker_UI:SetMouseEnabled(BannerTracker.isUIUnlocked)
    BannerTracker_UI:SetMovable(BannerTracker.isUIUnlocked)
end



function BannerTracker.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Branddi's Banner Tracker",
		displayName = "|cff2424B|r|cff4949r|r|cff6d6da|r|cff9292n|r|cffb6b6d|r|cffdbdbd|r|cffffffi|r's Banner Tracker",
		author = "Branddi",
		version = ""..BannerTracker.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(BannerTracker.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
		type = "button",
		name = "Lock/Unlock UI",
		func = function() BannerTracker.toggleUiLock() end,
		width = "full"
        },

   		{
			type = "checkbox",
			name = "In Combat Only",
			tooltip = "(DEFAULT OFF)",
			getFunc = function() return BannerTracker.sv.isCombatOnly end,
			setFunc = function(value)
				BannerTracker.sv.isCombatOnly = value
			end
		}


    }
    LAM:RegisterOptionControls(BannerTracker.name.."Options", options)
end

function BannerTracker.OnPlayerCombatState(event, inCombat)
    if DEBUG then d("BannerTracker.OnPlayerCombatState") end
    BannerTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()
    BannerTracker.refreshUi()
end

function BannerTracker.OnSkillBarChanged(eventCode, slotId)
    if DEBUG then d("Skill slot " .. slotId .. " has been updated!") end
    BannerTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()
end




function BannerTracker.OnAddonLoaded(eventCode, addonName)
    if addonName == BannerTracker.name then
        EVENT_MANAGER:UnregisterForEvent(BannerTracker.name, eventCode)

        BannerTracker.initialLogin = true

        BannerTracker.sv = ZO_SavedVars:NewAccountWide('BannerTrackerSV', 1, nil, BannerTracker.defaults)

        BannerTracker_UI:ClearAnchors()
        BannerTracker_UI:SetAnchor(CENTER, GuiRoot, TOPLEFT, BannerTracker.sv.x, BannerTracker.sv.y)

        local colour = {0, 0, 0, 0.0}
        BannerTracker_UI_Backdrop:SetCenterColor(unpack(colour))
        BannerTracker_UI_Icon:SetAlpha(0.8)
        BannerTracker_UI:SetHidden(true)

        EVENT_MANAGER:RegisterForEvent(BannerTracker.name, EVENT_ACTION_SLOT_UPDATED,  BannerTracker.OnSkillBarChanged)



        EVENT_MANAGER:RegisterForEvent(BannerTracker.name, EVENT_PLAYER_ACTIVATED, BannerTracker.OnPlayerActivated)

        EVENT_MANAGER:RegisterForEvent(BannerTracker.name, EVENT_PLAYER_COMBAT_STATE, BannerTracker.OnPlayerCombatState)



        BannerTracker.setupMenu()

    end
end

EVENT_MANAGER:RegisterForEvent(BannerTracker.name, EVENT_ADD_ON_LOADED, BannerTracker.OnAddonLoaded)


