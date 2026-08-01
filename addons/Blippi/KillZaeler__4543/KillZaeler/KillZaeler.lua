KillZaeler = {
    name = "KillZaeler",
}

local function FormatKills(n)
    local s = tostring(n or 0)
    if #s <= 3 then return s end
    return s:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function KillZaeler.SavePosition()
    KillZaeler.db.x = KillZaelerWindow:GetLeft()
    KillZaeler.db.y = KillZaelerWindow:GetTop()
end

function KillZaeler.OnCombatEvent(_, result, _, _, _, _, _, _, _, targetType, ...)
    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then
        if result == ACTION_RESULT_KILLER_KILLED or result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then
            KillZaeler.db.totalKills = KillZaeler.db.totalKills + 1
            KillZaelerCount:SetText(FormatKills(KillZaeler.db.totalKills))
        end
    end
end

function KillZaeler.Init(event, addonName)
    if addonName ~= KillZaeler.name then return end
    
    -- Wir laden die Daten. Falls x oder y nicht existieren, nutzen wir nil
    KillZaeler.db = ZO_SavedVars:NewCharacterIdSettings("KillZaelerSV", 1, nil, {totalKills = 0})
    
    -- SICHERHEITS-CHECK FÜR DIE POSITION
    KillZaelerWindow:ClearAnchors()
    if KillZaeler.db.x and KillZaeler.db.y then
        -- Wenn wir gespeicherte Daten haben, nutzen wir diese
        KillZaelerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, KillZaeler.db.x, KillZaeler.db.y)
    else
        -- FALLS NICHT: Direkt in die Mitte werfen!
        KillZaelerWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    KillZaelerWindow:SetHandler("OnMoveStop", KillZaeler.SavePosition)
    KillZaelerCount:SetText(FormatKills(KillZaeler.db.totalKills))

    -- HUD FRAGMENTE (Damit es im Spiel eingeblendet wird)
    if KillZaelerWindow.fragment == nil then
        KillZaelerWindow.fragment = ZO_HUDFadeSceneFragment:New(KillZaelerWindow)
        HUD_SCENE:AddFragment(KillZaelerWindow.fragment)
        HUD_UI_SCENE:AddFragment(KillZaelerWindow.fragment)
    end

    EVENT_MANAGER:RegisterForEvent(KillZaeler.name, EVENT_COMBAT_EVENT, KillZaeler.OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(KillZaeler.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

EVENT_MANAGER:RegisterForEvent(KillZaeler.name .. "Loaded", EVENT_ADD_ON_LOADED, KillZaeler.Init)