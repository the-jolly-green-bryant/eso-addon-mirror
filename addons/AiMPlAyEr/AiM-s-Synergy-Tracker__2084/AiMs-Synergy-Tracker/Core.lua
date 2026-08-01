AST                 = {}
AST.name            = "AiMs-Synergy-Tracker"
AST.author          = "AiMPlAyEr [EU], @Amasuriel"
AST.version         = "4.5"
AST.website         = "http://www.esoui.com/downloads/info2084-AiMsSynergyTracker.html"
AST.menuname        = "AiMs Synergy Tracker"
AST.varVersion      = 8
AST.default         = nil
AST.varName         = "ASTSaved"
AST.group           = {}
AST.ids             = {}

local em            = EVENT_MANAGER
local LibUnit       = LibUnits2

local combat        = IsUnitInCombat("player")
local wrapper       = nil
local wrapper2      = nil
local fragment      = nil
local fragment2     = nil


AST.default = {
    ["orb"]         = true,
    ["liq"]         = true,
    ["pur"]         = true,
    ["hea"]         = true,
    ["bon"]         = false,
    ["blo"]         = false,
    ["tra"]         = false,
    ["rad"]         = false,
    ["cha"]         = false,
    ["sha"]         = false,
    ["imp"]         = false,
    ["gra"]         = false,
    ["hir"]         = false,
    ["sol"]         = false,
    ["rob"]         = false,
    ["ago"]         = false,
    ["icy"]         = false,
    ["windowstate"] = false,
    ["windowscale"] = 1,
    ["left"]        = 500,
    ["top"]         = 500,
    ["orientation"] = "horizontal",
    ["alpha"]       = 0.8,
    ["lockwindow"]  = false,
    ["trackerui"]   = true,
    ["healerui"]    = false,
    ["interval"]    = 50,
    ["textures"]    = false,
    ["healer"]      = {
        ["left"]            = 500,
        ["top"]             = 500,
        ["tanksonly"]       = false,
        ["firstsynergy"]    = 1,
        ["secondsynergy"]   = 2,
		["thirdsynergy"]    = 3,
		["fourthsynergy"]   = 4,
        ["alpha"]           = 0.8,
        ["windowscale"]     = 1,
        ["ddsonly"]         = false,
    }
}

function AST:Initialize()
    em:RegisterForEvent(AST.name.."Combat", EVENT_PLAYER_COMBAT_STATE, AST.combatState)

    for k, v in pairs(AST.Data.SynergyData) do
        em:RegisterForEvent(AST.name.."Synergy"..k,EVENT_COMBAT_EVENT , AST.Tracking.synergyCheck)
        em:AddFilterForEvent(AST.name.."Synergy"..k,EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end

    AST.SV = ZO_SavedVars:New(AST.varName, AST.varVersion, nil, AST.default)

    if not AST.SV.healer.firstsynergy then AST.SV.healer.firstsynergy = 1 end
    if not AST.SV.healer.secondsynergy then AST.SV.healer.secondsynergy = 2 end
	if not AST.SV.healer.thirdsynergy then AST.SV.healer.thirdsynergy = 3 end
	if not AST.SV.healer.fourthsynergy then AST.SV.healer.fourthsynergy = 4 end

    AST.Tracker:Initialize(AST.SV.trackerui)
    AST.Healer:Initialize(AST.SV.healerui)

    if AST.SV.trackerui then
        wrapper = ASTGrid
        fragment = ZO_SimpleSceneFragment:New(wrapper)
    end
    if AST.SV.healerui then
        wrapper2 = ASTHealerUI
        fragment2 = ZO_SimpleSceneFragment:New(wrapper2)
    end

    AST.LoadSettings()
    AST.combatState()
    AST.SetWindowLock(AST.SV.lockwindow)
end

function AST.windowState()
    if AST.SV.windowstate then
        if AST.SV.trackerui then
            ASTGrid:SetHidden(true)
            HUD_SCENE:RemoveFragment(fragment)
            HUD_UI_SCENE:RemoveFragment(fragment)
        end

        if AST.SV.healerui then
            ASTHealerUI:SetHidden(true)
            HUD_SCENE:RemoveFragment(fragment2)
            HUD_UI_SCENE:RemoveFragment(fragment2)
        end

        d(zo_strformat("|cfd6a02[AiMs Synergy Tracker]|r |cffffffTrackers are now <<1>> outside of combat", "|cdc143chidden|r"))
    else
        if AST.SV.trackerui then
            ASTGrid:SetHidden(false)
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
        end

        if AST.SV.healerui then
            ASTHealerUI:SetHidden(false)
            HUD_SCENE:AddFragment(fragment2)
            HUD_UI_SCENE:AddFragment(fragment2)
        end
        d(zo_strformat("|cfd6a02[AiMs Synergy Tracker]|r |cffffffTrackers are now <<1>> outside of combat", "|c32cd32visible|r"))
    end
end

function AST.SetWindowLock(value)
    if not value then
        if AST.SV.trackerui and ASTGrid then
            ASTGrid:SetMovable(true)
        end

        if AST.SV.healerui and ASTHealerUI then
            ASTHealerUI:SetMovable(true)
        end
    else
        if AST.SV.trackerui and ASTGrid then
            ASTGrid:SetMovable(false)
        end

        if AST.SV.healerui and ASTHealerUI then
            ASTHealerUI:SetMovable(false)
        end
    end
end

function AST.HealerUIVisibility(value)
    if not value then
        ASTHealerUI:SetHidden(true)
        HUD_SCENE:RemoveFragment(fragment2)
        HUD_UI_SCENE:RemoveFragment(fragment2)
    else
        ASTHealerUI:SetHidden(false)
        HUD_SCENE:AddFragment(fragment2)
        HUD_UI_SCENE:AddFragment(fragment2)
    end
end

function AST.combatState(event, inCombat)
    if not AST.SV.windowstate then
        if AST.SV.trackerui then
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
        end

        if AST.SV.healerui then
            HUD_SCENE:AddFragment(fragment2)
            HUD_UI_SCENE:AddFragment(fragment2)
        end
    else
        if inCombat ~= combat then
            combat = inCombat
            if inCombat then
                if AST.SV.trackerui then ASTGrid:SetHidden(false) end
                if AST.SV.healerui then ASTHealerUI:SetHidden(false) end
            else
                if AST.SV.trackerui then ASTGrid:SetHidden(true) end
                if AST.SV.healerui then ASTHealerUI:SetHidden(true) end
            end
        end
        if AST.SV.trackerui then
            HUD_SCENE:RemoveFragment(fragment)
            HUD_UI_SCENE:RemoveFragment(fragment)
        end
        if AST.SV.healerui then
            HUD_SCENE:RemoveFragment(fragment2)
            HUD_UI_SCENE:RemoveFragment(fragment2)
        end
    end
end

function AST.time(nd, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * mult + 0.5)/mult
end

function AST.GetUnitName(unitId)

    local name, role = "", 0

    if AST.ids[unitId] and AST.ids[unitId].name then
      name = AST.ids[unitId].name
      role = GetGroupMemberSelectedRole(AST.ids[unitId].tag)
    end

    return name, role

    -- local unit = LibUnit:GetDisplayNameForUnitId(unitId)

    -- if unit ~= "" or unit ~= nil then
    --     return zo_strformat("<<1>>", unit)
    -- else
    --     return ""
    -- end
end

SLASH_COMMANDS["/asttoggle"]   = AST.windowState

function AST.OnAddOnLoaded(event, addonName)
    if addonName ~= AST.name then return end
    em:UnregisterForEvent(AST.name, EVENT_ADD_ON_LOADED)
    AST:Initialize()
end

em:RegisterForEvent(AST.name, EVENT_ADD_ON_LOADED, AST.OnAddOnLoaded)
