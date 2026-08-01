BetterGuardAddon = BetterGuardAddon or {}
local BG = BetterGuardAddon
BG.name = "BetterGuard"
BG.nameSpaced = "Better Guard"
BG.nameTitle = "|c3C80ffBETTER GUARD|r"
BG.version = "2.7"
BG.author = "TheMrPancake"
BG.GUARDS = { -- Guard morphs/levels
    [61511] = true,
    [61529] = true,
    [61536] = true,
    [63323] = true,
    [63329] = true,
    [63335] = true,
    [63341] = true,
    [63346] = true,
    [63351] = true,
}
BG.defaults = {
    alpha = 0.8,
    width = 12,
    safeDistance = 7,
    safeColour = {0, 1, 0, 1}, -- green
    breakingColour = {1, 0, 0, 1}, -- red
    showGuardOnYou = true,
    rainbowLine = false,
    depthBuffer = false,
}
BG.window = GetWindowManager()
BG.unitTag1 = ""
BG.unitTag2 = ""

function BG.CreateUI()
    BG.ctrl = BG.window:CreateControl( "BetterGuardControl", GuiRoot, CT_CONTROL )
    BG.ctrl:SetAnchorFill( GuiRoot )
    BG.ctrl:Create3DRenderSpace()
    BG.ctrl:SetHidden( true )

    BG.depthwin = BG.window:CreateTopLevelWindow( "BetterGuard3DWindow" )
    BG.depthwin:SetDrawLayer( DL_BACKGROUND )
	BG.depthwin:SetDrawTier( DT_LOW )
	BG.depthwin:SetDrawLevel( -999 )
    BG.depthwin:Create3DRenderSpace()

	local frag = ZO_HUDFadeSceneFragment:New( BG.depthwin )
	HUD_UI_SCENE:AddFragment( frag )
    HUD_SCENE:AddFragment( frag )
    LOOT_SCENE:AddFragment( frag )
end


local function OnAddOnLoaded(_, name)
    if name ~= BG.name then return end
    EVENT_MANAGER:UnregisterForEvent(BG.name, EVENT_ADD_ON_LOADED)
    BG.savedVariables = ZO_SavedVars:NewCharacterIdSettings("BetterGuardSavedVariables", 1, nil, BG.defaults)

    EVENT_MANAGER:RegisterForEvent(BG.name, EVENT_GROUP_MEMBER_JOINED, BG.GenerateGroupList)
    EVENT_MANAGER:RegisterForEvent(BG.name, EVENT_GROUP_MEMBER_LEFT, BG.GenerateGroupList)
    EVENT_MANAGER:RegisterForEvent(BG.name.."Generate", EVENT_PLAYER_ACTIVATED, BG.GenerateGroupList)

    EVENT_MANAGER:RegisterForEvent(BG.name, EVENT_LINKED_WORLD_POSITION_CHANGED, BG.GuardLost)
    EVENT_MANAGER:RegisterForEvent(BG.name, EVENT_PLAYER_TELEPORTED_LOCALLY, BG.GuardLost)
    EVENT_MANAGER:RegisterForEvent(BG.name.."Activate", EVENT_PLAYER_ACTIVATED, BG.GuardLost)
    EVENT_MANAGER:RegisterForEvent(BG.name.."Deactivate", EVENT_PLAYER_DEACTIVATED, BG.GuardLost)
    EVENT_MANAGER:RegisterForEvent(BG.name, EVENT_PLAYER_ALIVE, BG.GuardLost)
    EVENT_MANAGER:RegisterForEvent(BG.name, EVENT_PLAYER_DEAD, BG.GuardLost)

    for abilityId in pairs(BG.GUARDS) do
        local eventName = BG.name..abilityId.."EffectGained"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, BG.GuardGained)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
        eventName = BG.name..abilityId.."EffectFaded"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, BG.GuardLost)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
    end

    BG.CreateUI()
    BG.RemoveLine()
    BG.GenerateGroupList()
    if LibAddonMenu2 then
        BG.RegisterLAMPanel()
    end
end

EVENT_MANAGER:RegisterForEvent(BG.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)