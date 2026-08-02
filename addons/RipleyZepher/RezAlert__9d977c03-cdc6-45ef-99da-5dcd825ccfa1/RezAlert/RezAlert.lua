-- RezAlert Addon
RezAlert = {}
RezAlert.name = "RezAlert"
RezAlert.version = "1.0.13"
-- Initialize the addon
function RezAlert:Initialize()
    -- Store both containers and labels
    self.containers = {
        RezAlertTop,
        RezAlertRight,
        RezAlertBottom,
        RezAlertLeft
    }

    self.labels = {
        RezAlertTopLeft,
        RezAlertTopRight,
        RezAlertBottomLeft,
        RezAlertBottomRight
    }

    -- Initialize containers
    for i, container in ipairs(self.containers) do
        if container then
            container:SetHidden(true)
        end
    end

    -- Initialize labels
    for i, label in ipairs(self.labels) do
        if label then
            label:SetFont("ZoFontGameLargeBold|42")
            label:SetAlpha(1.0)
            label:SetColor(1, 0, 0, 1)
        end
    end

    -- Register for combat events
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
end

-- Get the role of a unit
function RezAlert:GetUnitRole(unitTag)
    if IsUnitGrouped(unitTag) then
        local role = GetGroupMemberSelectedRole(unitTag)
        if role == LFG_ROLE_TANK then
            return "Tank"
        elseif role == LFG_ROLE_HEAL then
            return "Healer"
        end
    end
    return nil
end

-- Handle combat events
function RezAlert:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                                 sourceName, sourceType, targetName, targetType, hitValue, powerType,
                                 damageType, log, sourceUnitId, targetUnitId, abilityId)

    if result == ACTION_RESULT_DIED then
        -- Check if the dead unit is in the group and has a role
        if IsUnitGrouped("player") then
            -- Check group members (including the player)
            for i = 1, GetGroupSize() do
                local unitTag = GetGroupUnitTagByIndex(i)
                if unitTag then
                    local name = GetUnitName(unitTag)
                    -- Use zo_strformat to strip formatting codes from both names
                    if zo_strformat("<<1>>", name) == zo_strformat("<<1>>", targetName) then
                        local role = self:GetUnitRole(unitTag)
                        if role then
                            self:ShowAlert(role)
                            return
                        end
                    end
                end
            end
        end
    end
end

-- Show the alert message
function RezAlert:ShowAlert(role)
    local message = "Rez " .. role

    -- Update and show all labels
    for i, label in ipairs(self.labels) do
        label:SetFont("ZoFontGameLargeBold|42")
        label:SetText(message)
        label:SetAlpha(1.0)
        label:SetColor(1, 0, 0, 1)
    end

    -- Show all containers
    for i, container in ipairs(self.containers) do
        container:SetAlpha(1.0)
        container:SetHidden(false)
    end

    -- Play alert sound
    PlaySound(SOUNDS.ABILITY_ULTIMATE_READY)

    -- Hide the message after 5 seconds
    zo_callLater(function()
        for _, container in ipairs(self.containers) do
            container:SetHidden(true)
        end
    end, 5000)
end

-- Test function to trigger alerts manually
function RezAlert:Test(role)
    -- Check if addon is initialized
    if not self.labels or not self.containers then
        return
    end

    -- Check if containers and labels exist
    for i, container in ipairs(self.containers) do
        if not container then
            return
        end
    end

    for i, label in ipairs(self.labels) do
        if not label then
            return
        end
    end

    if not role or role == "" then
        -- Default to testing with a healer alert
        role = "Healer"
    elseif role:lower() == "tank" then
        role = "Tank"
    elseif role:lower() == "healer" or role:lower() == "heal" then
        role = "Healer"
    else
        return
    end

    self:ShowAlert(role)
end

-- Slash command handler
SLASH_COMMANDS["/rezalert"] = function(args)
    if args == "test" then
        RezAlert:Test("Healer")
    elseif args == "test tank" then
        RezAlert:Test("Tank")
    elseif args == "test healer" or args == "test heal" then
        RezAlert:Test("Healer")
    end
end

-- Event handler for addon loaded
function RezAlert.OnAddOnLoaded(event, addonName)
    if addonName == RezAlert.name then
        RezAlert:Initialize()
        EVENT_MANAGER:UnregisterForEvent(RezAlert.name, EVENT_ADD_ON_LOADED)
    end
end

-- Register for addon loaded event
EVENT_MANAGER:RegisterForEvent(RezAlert.name, EVENT_ADD_ON_LOADED, RezAlert.OnAddOnLoaded)
