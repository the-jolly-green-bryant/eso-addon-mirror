---------------------
-- DoYouEvenDebuff
-- Version 1.6
---------------------

MU          = {}

MU.version      = "1.6"
MU.varversion   = 6
MU.name         = "DoYouEvenDebuff"
MU.varname      = "DYEDSaved"
MU.website      = ""
MU.EM           = EVENT_MANAGER
MU.ability      = nil
MU.toplevel     = nil
MU.defaults     = {
    ["left"]                = 860,
    ["top"]                 = 420,
    ["immune"]              = true,
    ["bossesonly"]          = true,
    ["taunt"]               = true,
    ["engulfing"]           = true,
    ["alkosh"]              = true,
    ["crusher"]             = true,
    ["majorfracture"]       = false,
    ["minorfracture"]       = false,
    ["minorvulnerability"]  = false,
    ["outofcombat"]         = true,
    ["majorbreach"]         = false,
    ["minorbreach"]         = false,
    ["minormagickasteal"]   = false,
    ["weakening"]           = false,
    ["mode"]                = "rightside", --leftside, splitted and rightside
    ["disabledecimal"]      = false,

}

local mfloor        = math.floor
local strformat     = string.format


function MU:Initialize()
    MU.SV = ZO_SavedVars:New(MU.varname, MU.varversion, nil, MU.defaults)

    MU.EM:RegisterForEvent(MU.name, EVENT_PLAYER_COMBAT_STATE, MU.CombatState) 
    
    MU.toplevel = MUGrid

    MU.toplevel:SetHidden(MU.SV.outofcombat)
    
    MU.BuildAddon()
    MU.SetPosition()
    MU.LoadSettings()
end

function MU.CombatState(eventCode, inCombat)

    if inCombat then

        if MU.SV.bossesonly then

            if GetUnitDifficulty("reticleover") == MONSTER_DIFFICULTY_DEADLY then

                MU.EM:RegisterForUpdate(MU.name.."BossUpdate", 100, MU.BossUpdate)
            end
        else

            MU.EM:RegisterForUpdate(MU.name.."BossUpdate", 100, MU.BossUpdate)
        end

        MU.toplevel:SetHidden(false)
    else

        if MU.SV.outofcombat then
            MU.toplevel:SetHidden(true)
        end

        MU.EM:UnregisterForUpdate(MU.name.."BossUpdate")

        MU.SetToDefault() --fix
    end
end

function MU.SetPosition()
    local left  = MU.SV.left
    local top   = MU.SV.top
    MU.toplevel:ClearAnchors()
    MU.toplevel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function MU.NewPosition()
    MU.SV.left  = MU.toplevel:GetLeft()
	MU.SV.top   = MU.toplevel:GetTop()
end

function MU.BuildAddon()
    MU.ability = MU.Data.BuildAbilities()
    MU.BuildUI()
end


function MU.BuildUI()
    local lindex = 0
    local tindex = 0
    local rindex = 0
    local total = 0

    if MU.SV.mode == "splitted" then
        
        for _, v in ipairs(MU.ability) do
            if v.debuffType == 1 and v.enabled then
                total = total + 1
            end
        end
    
        for _, v in ipairs(MU.ability) do
            if not v.ignoreDebuff then
            MU.toplevel:GetNamedChild(v.name):SetHidden(not v.enabled)
                if v.enabled then
                    if v.debuffType == 1 then
                        MU.toplevel:GetNamedChild(v.name):SetAnchor(CENTER, MU.toplevel, TOP, MU.Data.positioningTable[total][tindex].x, MU.Data.positioningTable[total][tindex].y)
                        tindex = tindex + 1
                    end
                    if v.debuffType == 2 then
                        MU.toplevel:GetNamedChild(v.name):SetAnchor(CENTER, MU.toplevel, RIGHT, -30 + (-50 * (mfloor(rindex / 3))), -30 + (30 * (rindex % 3)))
                        rindex = rindex + 1
                    elseif v.debuffType == 3 then
                        MU.toplevel:GetNamedChild(v.name):SetAnchor(CENTER, MU.toplevel, LEFT, 30 - (50 * (mfloor(lindex / 3))), -30 + (30 * (lindex % 3)))
                        lindex = lindex + 1
                    end
                end
            end
        end

        MU.toplevel:GetNamedChild("Taunt"):SetAnchor(CENTER, MU.toplevel, CENTER, 0, 0)
        MU.toplevel:SetDimensions(200,150)
    elseif MU.SV.mode == "leftside" then
        local index = 0

        for _, v in ipairs(MU.ability) do
            if not v.ignoreDebuff then
                MU.toplevel:GetNamedChild(v.name):SetHidden(not v.enabled)
                if (v.name ~= "Taunt" and v.enabled) then
                        MU.toplevel:GetNamedChild(v.name):SetAnchor(LEFT, MU.toplevel, LEFT, -50 * (mfloor(index / 3)), -30 + (30 * (index % 3)))
                    index = index + 1
                end
            end
        end

        MU.toplevel:GetNamedChild("Taunt"):SetAnchor(LEFT, MU.toplevel, LEFT, 40, 0)
        MU.toplevel:SetDimensions(250,100)
    elseif MU.SV.mode == "rightside" then
        local index = 0

        for _, v in ipairs(MU.ability) do
            if not v.ignoreDebuff then
                MU.toplevel:GetNamedChild(v.name):SetHidden(not v.enabled)
                if (v.name ~= "Taunt" and v.enabled) then
                    MU.toplevel:GetNamedChild(v.name):SetAnchor(LEFT, MU.toplevel, LEFT, 115 + (50 * (mfloor(index / 3))), -30 + (30 * (index % 3)))
                    index = index + 1
                end
            end
        end

        MU.toplevel:GetNamedChild("Taunt"):SetAnchor(LEFT, MU.toplevel, LEFT, 40, 0)
        MU.toplevel:SetDimensions(250,100)
    end
end


function MU.BossUpdate(_)
    local immune = 0

    if DoesUnitExist("reticleover") then

        for i = 1,GetNumBuffs('reticleover') do
            local auraName, _, finish, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo('reticleover', i)

            local remainingTime = MU.calcTime(finish)

            local convertedTime
            if MU.SV.disabledecimal then
                convertedTime = strformat("%.0f", remainingTime)
            else
                convertedTime = strformat("%.1f", remainingTime)
            end

            for _, v in ipairs(MU.ability) do

                if (v.abilityID == abilityId) and (abilityId ~= 52788) then

                    if remainingTime <= 0.1 then
                        MU.toplevel:GetNamedChild(v.name):SetText(v.shortcode)
                    else
                        MU.toplevel:GetNamedChild(v.name):SetText(convertedTime)
                    end

                    break
                end
            end

            if abilityId == 52788 and remainingTime >= 0 then
                immune = remainingTime
            elseif remainingTime < 0 then
                immune = 0
            end

            if immune >= 0.1 then
                MU.toplevel:GetNamedChild("Immune"):SetHidden(false)
                MU.toplevel:GetNamedChild("Immune"):SetText(strformat("%.1f", remainingTime));
            else
                MU.toplevel:GetNamedChild("Immune"):SetHidden(true)
                MU.toplevel:GetNamedChild("Immune"):SetText("0.0");
            end
        end
    else

        MU.SetToDefault()
    end
end

function MU.SetToDefault()
    for _, v in ipairs(MU.ability) do
        MU.toplevel:GetNamedChild(v.name):SetText(v.shortcode)
    end
end

function MU.calcTime(finish)
    return mfloor((finish - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function MU.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= MU.name then return end
    MU.EM:UnregisterForEvent(MU.name, EVENT_ADD_ON_LOADED)
    MU:Initialize()
end

MU.EM:RegisterForEvent(MU.name, EVENT_ADD_ON_LOADED, MU.OnAddOnLoaded)