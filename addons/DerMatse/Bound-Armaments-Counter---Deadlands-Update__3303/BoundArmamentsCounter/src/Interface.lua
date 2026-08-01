-------------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t/Masel92
-- Created: Sep 27, 2019
--
-- Interface.lua
-- -----------------------------------------------------------------------------

function BAC.DrawUI()
    local c = WINDOW_MANAGER:CreateTopLevelWindow("BACContainer")
    c:SetClampedToScreen(true)
    c:SetDimensions(BAC.preferences.size, BAC.preferences.size)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(BAC.preferences.unlocked)
    c:SetHidden(false)
    c:SetHandler("OnMoveStop", function(...) BAC.SavePosition() end)

    -- Check for valid texture
    -- Potential fix for UI error discovered by Porkjet
    if not BAC.TEXTURE_VARIANTS[BAC.preferences.selectedTexture] then
        -- If texture selection is not a valid option, reset to default
        BAC:Trace(1, 'Invalid texture selection: ' .. BAC.preferences.selectedTexture)
        BAC.preferences.selectedTexture = BAC:GetDefaults().selectedTexture
    end

    local t = WINDOW_MANAGER:CreateControl("BACTexture", c, CT_TEXTURE)
    t:SetTexture(BAC.TEXTURE_VARIANTS[BAC.preferences.selectedTexture].asset)
    t:SetDimensions(BAC.preferences.size, BAC.preferences.size)
    t:SetTextureCoords(BAC.TEXTURE_FRAMES[0].REL, BAC.TEXTURE_FRAMES[1].REL, 0, 1)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    BAC.BACContainer = c
    BAC.BACTexture = t

    BAC.SetPosition(BAC.preferences.positionLeft, BAC.preferences.positionTop)
    BAC.SetSkillColorOverlay('default')

    BAC:Trace(2, "Finished DrawUI()")
end

function BAC.SetSkillColorOverlay(overlayType)

    -- Read saved color
    color = BAC.preferences.colors[overlayType]

    if BAC.preferences.overlay[overlayType] then
        -- Set active color overlay
        BAC.BACTexture:SetColor(color.r, color.g, color.b, color.a)
    else
        -- Set to default if it's set
        if BAC.preferences.overlay.default then
            default = BAC.preferences.colors.default
            BAC.BACTexture:SetColor(default.r, default.g, default.b, default.a)
        else
            -- Set to white AKA none if no default set
            BAC.BACTexture:SetColor(1, 1, 1, 1)
        end

    end
end

function BAC.SetSkillFade(faded)
    -- Only change fade if our options want us to fade
    if BAC.preferences.fadeInactive then
        if faded then
            alpha = BAC.preferences.fadeAmount / 100
            BAC.BACContainer:SetAlpha(alpha)
        else
            BAC.BACContainer:SetAlpha(1)
        end
    end
end

function BAC.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if BAC.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            BAC:Trace(3, "Hiding HUD")
            BAC.HUDHidden = true
            BAC.BACContainer:SetHidden(true)
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            BAC:Trace(3, "Showing HUD")
            BAC.HUDHidden = false
            BAC.BACContainer:SetHidden(false)
        end
    end)

    BAC:Trace(2, "Finished ToggleHUD()")
end

function BAC.LockToReticle(lockToReticle)
    if lockToReticle then
        BAC.preferences.lockedToReticle = true
        BAC:Trace(1, "Locked to Reticle")
    else
        BAC.preferences.lockedToReticle = false
        BAC:Trace(1, "Unlocked from Reticle")
    end
    BAC.SetPosition(BAC.preferences.positionLeft, BAC.preferences.positionTop)
end

function BAC.OnMoveStop()
    BAC:Trace(1, "Moved")
    BAC.SavePosition()
end

function BAC.SavePosition()
    local top   = BAC.BACContainer:GetTop()
    local left  = BAC.BACContainer:GetLeft()

    -- If locked to reticle, but unlocked and moved,
    -- then we are no longer locked to reticle.
    BAC.preferences.lockedToReticle = false

    BAC:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    BAC.preferences.positionLeft = left
    BAC.preferences.positionTop  = top
end

function BAC.SetPosition(left, top)
    if BAC.preferences.lockedToReticle then
        local height = GuiRoot:GetHeight()

        BAC.BACContainer:ClearAnchors()
        BAC.BACContainer:SetAnchor(CENTER, GuiRoot, TOP, 0, height/2)
    else
        BAC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
        BAC.BACContainer:ClearAnchors()
        BAC.BACContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

function BAC.UpdateStacks(stackCount)

    -- Ignore missing stackCount
    if not stackCount then return end

    if stackCount > 0 then

        -- Show stacks
        BAC.BACTexture:SetTextureCoords(BAC.TEXTURE_FRAMES[stackCount].REL, BAC.TEXTURE_FRAMES[stackCount+1].REL, 0, 1)

    else

        -- Show zero stack indicator for active ability
        if BAC.preferences.showEmptyStacks and (BAC.abilityActive or BAC.isInCombat) then
            BAC:Trace(1, "Stack #0 (Show Empty)")
            BAC.BACTexture:SetTextureCoords(BAC.TEXTURE_FRAMES[6].REL, BAC.TEXTURE_FRAMES[7].REL, 0, 1)
            return
        end

        -- Skill dead or do not show empty stacks
        BAC:Trace(1, "Skill inactive or don't show empty stacks")
        BAC.BACTexture:SetTextureCoords(BAC.TEXTURE_FRAMES[0].REL, BAC.TEXTURE_FRAMES[1].REL, 0, 1)

    end
end

function BAC.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(BAC.prefix .. "Setting debug level to 0 (Off)")
        BAC.debugMode = 0
        BAC.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(BAC.prefix .. "Setting debug level to 1 (Low)")
        BAC.debugMode = 1
        BAC.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(BAC.prefix .. "Setting debug level to 2 (Medium)")
        BAC.debugMode = 2
        BAC.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(BAC.prefix .. "Setting debug level to 3 (High)")
        BAC.debugMode = 3
        BAC.preferences.debugMode = 3

    -- Position Options -------------------------------------------------------
    elseif command == "position reset" then
        d(BAC.prefix .. "Resetting position to reticle")
        local tempPos = BAC.preferences.lockedToReticle
        BAC.preferences.lockedToReticle = true
        BAC.SetPosition()
        BAC.preferences.lockedToReticle = tempPos
    elseif command == "position show" then
        d(BAC.prefix .. "Display position is set to: [" ..
            BAC.preferences.positionTop ..
            ", " ..
            BAC.preferences.positionLeft ..
            "]")
    elseif command == "position lock" then
        d(BAC.prefix .. "Locking display")
        BAC.preferences.unlocked = false
        BAC.BACContainer:SetMovable(false)
    elseif command == "position unlock" then
        d(BAC.prefix .. "Unlocking display")
        BAC.preferences.unlocked = true
        BAC.BACContainer:SetMovable(true)

    -- Manage Registration ----------------------------------------------------
    elseif command == "register" then
        d(BAC.prefix .. "Reregistering all events")
        BAC.UnregisterEvents()
        BAC.RegisterEvents()
    elseif command == "unregister" then
        d(BAC.prefix .. "Unregistering all events")
        BAC.UnregisterEvents()
        BAC.abilityActive = false
        BAC.UpdateStacks(0)
    elseif command == "register unfiltered" then
        d(BAC.prefix .. "Unregistering all events")
        BAC.UnregisterEvents()
        BAC.abilityActive = false
        BAC.UpdateStacks(0)
        d(BAC.prefix .. "Registering for ALL events unfiltered")
        BAC.RegisterUnfilteredEvents()
    elseif command == "unregister unfiltered" then
        d(BAC.prefix .. "Unregistering unfiltered events")
        BAC.UnregisterUnfilteredEvents()
        BAC.abilityActive = false
        BAC.UpdateStacks(0)

    -- Default ----------------------------------------------------------------
    else
        d(BAC.prefix .. "Command not recognized!")
    end
end

