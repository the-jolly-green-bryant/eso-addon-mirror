local Drawing = CF.Drawing

local INACTIVE_COMPANION_STATES = {
    [_G.COMPANION_STATE_INACTIVE] = true,
    [_G.COMPANION_STATE_BLOCKED_PERMANENT] = true,
    [_G.COMPANION_STATE_BLOCKED_TEMPORARY] = true,
    [_G.COMPANION_STATE_HIDDEN] = true,
    [_G.COMPANION_STATE_INITIALIZING] = true
}

local PENDING_COMPANION_STATES = {
    [_G.COMPANION_STATE_PENDING] = true,
    [_G.COMPANION_STATE_INITIALIZED_PENDING] = true
}

local ACTIVE_COMPANION_STATES = {
    [_G.COMPANION_STATE_ACTIVE] = true
}

function CF.UpdateCompanionNameAndLevel(companionLevel)
    local companionName = GetUnitName("companion") or ""

    if (not companionLevel) then
        companionLevel = GetActiveCompanionLevelInfo()
    end

    local displayName = ""

    if (CF.Vars.ShowName) then
        displayName = companionName
    end

    if (CF.Vars.ShowLevel) then
        displayName =
            displayName .. (CF.Vars.ShowName and " (" or "") .. companionLevel .. (CF.Vars.ShowName and ")" or "")
    end

    CF.CompanionFrame.Nameplate.Name:SetText(displayName)
end

function CF.OnCompanionExperienceUpdate()
    local companionLevel, currentXPInLevel = GetActiveCompanionLevelInfo()
    local totalXPInLevel = GetNumExperiencePointsInCompanionLevel(companionLevel + 1) or 0
    local isMaxLevel = totalXPInLevel == 0
    local percent = 0

    if (not isMaxLevel) then
        percent = math.max(zo_roundToNearest((currentXPInLevel or 0) / totalXPInLevel, 0.01), 0)
    end

    CF.CompanionFrame.Experience.Bar:SetWidth(percent * (CF.CompanionFrame.Experience:GetWidth() - 4))
    CF.UpdateCompanionNameAndLevel(companionLevel)
end

function CF.OnCompanionRapportUpdate()
    local rapportValue = GetActiveCompanionRapport()
    local rapportMax = GetMaximumRapport()
    local rapportMin = GetMinimumRapport()
    local rdr, rdg, rdb = unpack(CF.Vars.RapportDislikeColour)
    local rmr, rmg, rmb = unpack(CF.Vars.RapportModerateColour)
    local rlr, rlg, rlb = unpack(CF.Vars.RapportLikeColour)

    local rapportPcValue = rapportValue - rapportMin
    local rapportPcMax = rapportMax - rapportMin
    local percent = math.max(zo_roundToNearest(rapportPcValue / rapportPcMax, 0.01), 0)
    local r, g, b = Drawing.Gradient(percent, rlr, rlg, rlb, rmr, rmg, rmb, rdr, rdg, rdb)

    CF.CompanionFrame.Rapport.Bar:SetWidth(percent * (CF.CompanionFrame.Rapport:GetWidth() - 4))
    CF.CompanionFrame.Rapport.Bar:SetColor(r, g, b, 0.5)
    CF.CompanionFrame.Rapport.Current:SetText(rapportValue .. "/" .. rapportMax)
end

function CF.OnCompanionStateChanged(_, newState, _)
    if (INACTIVE_COMPANION_STATES[newState] or PENDING_COMPANION_STATES[newState]) then
        CF.CompanionDeactivated()
    end

    if (ACTIVE_COMPANION_STATES[newState]) then
        CF.SummoningFrame:SetHidden(true)
        CF.CompanionActivated()
    end

    if (PENDING_COMPANION_STATES[newState]) then
        CF.HideDefaultCompanionFrame()

        if (HasPendingCompanion() and not IsCollectibleBlocked(CF.ActiveCompanionCollectibleId) and CF.Vars.Summoning) then
            local pendingCompanionDefId = GetPendingCompanionDefId()
            local pendingCompanionName = GetCompanionName(pendingCompanionDefId)
            local companionName = zo_strformat(_G.SI_COMPANION_NAME_FORMATTER, pendingCompanionName)
            local summoning = GetString(_G.SI_UNIT_FRAME_STATUS_SUMMONING)
            local summoningText = companionName .. ". " .. summoning

            CF.SummoningFrame.Message:SetText(summoningText)
            CF.SummoningFrame:SetHidden(false)
        end
    end
end

function CF.OnPowerUpdate(_, unitTag, _, powerType)
    if (unitTag ~= "companion" or not CF.CompanionFrame) then
        return
    end

    if (DoesUnitExist("companion") and HasActiveCompanion()) then
        if (CF.CompanionFrame.Nameplate.Name:GetText() == "Companion Name (Level)") then
            CF.CompanionActivated()
        end

        if (powerType == _G.COMBAT_MECHANIC_FLAGS_HEALTH) then
            local healthValue, healthMax = GetUnitPower("companion", powerType)
            local percent = math.max(zo_roundToNearest((healthValue or 0) / healthMax, 0.01), 0)
            local percentValue = (percent * 100) .. "%"
            local healthLabel = healthValue

            if (healthValue > 1000000) then
                healthLabel = CF.DisplayNumber(healthValue / 1000000, 3) .. "m"
            elseif (healthValue > 100000) then
                healthLabel = CF.DisplayNumber(healthValue / 1000, 1) .. "k"
            end

            CF.CompanionFrame.Health.Bar:SetWidth(percent * (CF.CompanionFrame.Health:GetWidth() - 4))
            CF.CompanionFrame.Health.Current:SetText(healthLabel)
            CF.CompanionFrame.Health.Percent:SetText(percentValue)
        end
    end
end

function CF.OnPlayerActivated()
    CF.CompanionActivated()
    CF.OnPowerUpdate(nil, "companion", nil, _G.COMBAT_MECHANIC_FLAGS_HEALTH)

    if (SCENE_MANAGER:GetCurrentScene():GetName() == "gameMenuInGame") then
        if (not CF.CompanionFrame:IsHidden()) then
            CF.SetHiddenForReason("disabled", true)
        end
    end
end

function CF.OnUnitDestroyed(_, unitTag)
    if (CF.ActiveCompanionCollectibleId and string.find(unitTag, "pet")) then
        if (GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION) ~= CF.ActiveCompanionCollectibleId) then
            local remainingCooldownTime = GetCollectibleCooldownAndDuration(CF.ActiveCompanionCollectibleId)
            zo_callLater(
                function()
                    if
                        (CF.IsCompanionUsable(CF.ActiveCompanionCollectibleId) and not HasActiveCompanion() and
                            not HasPendingCompanion())
                     then
                        UseCollectible(CF.ActiveCompanionCollectibleId)
                    end
                end,
                remainingCooldownTime + 1000
            )
            EVENT_MANAGER:UnregisterForEvent(CF.Name, EVENT_UNIT_DESTROYED)
        end
    end
end

function CF.OnUnitCreated(_, unitTag)
    if (CF.Vars.Resummon and string.find(unitTag, "pet")) then
        if (GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)) then
            zo_callLater(
                function()
                    CF.CompanionActivated()
                    EVENT_MANAGER:RegisterForEvent(CF.Name, EVENT_UNIT_DESTROYED, CF.OnUnitDestroyed)
                end,
                1000
            )
        end
    end
end

function CF.OnZoneChange()
    CF.OnPlayerActivated()
end