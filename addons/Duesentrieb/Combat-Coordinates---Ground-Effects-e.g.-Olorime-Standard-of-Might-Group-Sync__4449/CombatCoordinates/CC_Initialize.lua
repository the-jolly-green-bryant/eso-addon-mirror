local CC = CombatCoordinates

---------------------------------------------------------------------------
-- CREATE BACKGROUND GUI ELEMENTS
---------------------------------------------------------------------------
function CC.CreateGuiElements()
    if CC.PARENT then return end

    CC.PARENT = WINDOW_MANAGER:CreateTopLevelWindow(CC.name .. "Control")
    CC.PARENT:SetAnchorFill(GuiRoot)
    CC.PARENT:SetHidden(false)

    local fragment = ZO_HUDFadeSceneFragment:New(CC.PARENT)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

---------------------------------------------------------------------------
-- CLEANUP ACTIVE EFFECTS
---------------------------------------------------------------------------
function CC.ClearAllEffects()
    for effectId, segments in pairs(CC.trackedVisuals) do
        for _, segment in ipairs(segments) do
            segment.inUse = false
            if segment.control then
                segment.control:SetHidden(true)
            end
        end
    end
    ZO_ClearTable(CC.trackedVisuals)
    ZO_ClearTable(CC.cooldowns)
end

---------------------------------------------------------------------------
-- CLEANUP ON PLAYER ACTIVATION (ZONE CHANGE)
---------------------------------------------------------------------------
function CC.OnPlayerActivated()
    CC.ClearAllEffects()

    for poolIndex, segment in ipairs(CC.segmentPool) do
        if segment.control and not segment.control:Has3DRenderSpace() then
            segment.control:Create3DRenderSpace()
            segment.control:Set3DRenderSpaceUsesDepthBuffer(true)
        end
    end
end

---------------------------------------------------------------------------
-- TEST COMMAND
---------------------------------------------------------------------------
SLASH_COMMANDS["/cctest"] = function()
    local zone, x, y, z = GetUnitRawWorldPosition("player")
    if x and y and z then
        local testSkillId = 32947 

        -- FETCH SPECIFIC SETTINGS (DRY)
        local radius, numSides, lineWidth, heightOffset = CC.GetVisualSettings()
        local offset = CC.SV.standardOffset
        local colorSelf = CC.SV.standardColorSelf
        local duration = CC.supportedSkills[testSkillId].duration

        local fwdX, fwdY, fwdZ = CC.GetForwardPosition("player", x, y, z, offset)
        CC.DrawEffectCircle(fwdX, fwdY, fwdZ, radius, colorSelf, duration, numSides, lineWidth, heightOffset)

        if CC.protocol and CC.protocol:IsFinalized() then
            CC.protocol:Send({ skillId = testSkillId, x = fwdX, y = fwdY, z = fwdZ })
            CC.Debug("Test effect drawn locally and sent to group.")
        else
            CC.Debug("Test effect drawn locally. (Not sent: Protocol inactive or not grouped)")
        end
    end
end

---------------------------------------------------------------------------
-- INITIALIZE ADDON
---------------------------------------------------------------------------
function CC.Initialize()
    CC.isConsole = IsConsoleUI()
    CC.SV = ZO_SavedVars:NewAccountWide(CC.SVName, CC.SVVersion, GetWorldName(), CC.default)

    CC.CreateGuiElements()
    CC.CreateSettings()

    if LibGroupBroadcast then
        local handler = LibGroupBroadcast:RegisterHandler("CombatCoordinates")
        CC.protocol = handler:DeclareProtocol(500, "CombatCoordinates")

        local coordOptions = { numBits = 32, minValue = -10000000, maxValue = 10000000 }

        CC.protocol
            :AddField(LibGroupBroadcast.CreateNumericField("skillId", { numBits = 32 }))
            :AddField(LibGroupBroadcast.CreateNumericField("x", coordOptions))
            :AddField(LibGroupBroadcast.CreateNumericField("y", coordOptions))
            :AddField(LibGroupBroadcast.CreateNumericField("z", coordOptions))

            :OnData(function(unitTag, data)
                if not AreUnitsEqual(unitTag, "player") and CC.SV.enableAddon then
                    local skillData = CC.supportedSkills[data.skillId]
                    if skillData then
                        CC.Debug("Received effect data from: " .. tostring(unitTag) .. " (" .. skillData.name .. ")")

                        -- FETCH SPECIFIC SETTINGS FOR THIS SKILL (DRY)
                        local radius, numSides, lineWidth, heightOffset = CC.GetVisualSettings()
                        local colorGroup = CC.SV.standardColorGroup

                        CC.DrawEffectCircle(data.x, data.y, data.z, radius, colorGroup, skillData.duration, numSides, lineWidth, heightOffset)
                    end
                end
            end)
        CC.protocol:Finalize({ isRelevantInCombat = true })
    end

    if CC.SV.enableAddon then
        CC.Enable()
    end

    EVENT_MANAGER:RegisterForEvent(CC.name, EVENT_PLAYER_ACTIVATED, CC.OnPlayerActivated)
    CC.isLoaded = true
end

---------------------------------------------------------------------------
-- EVENT REGISTRATION
---------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(CC.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == CC.name then
        CC.Initialize()
        EVENT_MANAGER:UnregisterForEvent(CC.name, EVENT_ADD_ON_LOADED)
    end
end)