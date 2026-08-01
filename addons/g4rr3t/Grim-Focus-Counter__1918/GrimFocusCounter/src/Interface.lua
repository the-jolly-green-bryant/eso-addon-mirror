-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

local WM = WINDOW_MANAGER
local GFC = GFC

GFC.fragment = nil

--- Add fragments to HUD and UI scenes
--- @return nil
function GFC:AddSceneFragments()
    if not self.fragment then
        self:Trace(2, "Adding scene fragments")
        self.fragment = ZO_SimpleSceneFragment:New(self.GFCContainer)
        HUD_UI_SCENE:AddFragment(self.fragment)
        HUD_SCENE:AddFragment(self.fragment)
    end
end

--- Remove fragments from the HUD and UI scenes
--- @return nil
function GFC:RemoveSceneFragments()
    if self.fragment then
        self:Trace(2, "Removing scene fragments")
        HUD_UI_SCENE:RemoveFragment(self.fragment)
        HUD_SCENE:RemoveFragment(self.fragment)
        self.fragment = nil
    end
end

--- Draw the main UI elements
--- @return nil
function GFC:DrawUI()
    local c = WM:CreateTopLevelWindow("GFCContainer")
    c:SetClampedToScreen(true)
    c:SetDimensions(self.preferences.size, self.preferences.size)
    c:ClearAnchors()
    c:SetMouseEnabled(true)
    c:SetAlpha(1)
    c:SetMovable(self.preferences.unlocked)
    c:SetHidden(true)
    c:SetHandler("OnMoveStop", function() self:SavePosition() end)
    c:SetHandler("OnMouseEnter", function()
        if self.preferences.unlocked then
            WM:SetMouseCursor(MOUSE_CURSOR_PAN)
        end
    end)
    c:SetHandler("OnMouseExit", function()
        if self.preferences.unlocked then
            WM:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        end
    end)


    -- Check for valid texture
    -- Potential fix for UI error discovered by Porkjet
    if not self.TEXTURE_VARIANTS[self.preferences.selectedTexture] then
        -- If texture selection is not a valid option, reset to default
        self:Trace(1, 'Invalid texture selection: ' .. self.preferences.selectedTexture)
        self.preferences.selectedTexture = self:GetDefaults().selectedTexture
    end

    local t = WM:CreateControl("GFCTexture", c, CT_TEXTURE)
    t:SetTexture(self.TEXTURE_VARIANTS[self.preferences.selectedTexture].asset)
    t:SetDimensions(self.preferences.size, self.preferences.size)
    t:SetTextureCoords(self.TEXTURE_FRAMES[0].REL, self.TEXTURE_FRAMES[1].REL, 0, 1)
    t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

    self.GFCContainer = c
    self.GFCTexture = t

    self:SetPosition(self.preferences.positionLeft, self.preferences.positionTop)

    self:Trace(2, "Finished DrawUI()")
end

--- Set the color overlay for the given type
--- @param overlayType string Type of color overlay to apply
--- @return nil
function GFC:SetSkillColorOverlay(overlayType)
    -- Read saved color
    local color = self.preferences.colors[overlayType]

    if self.preferences.overlay[overlayType] then
        -- Set active color overlay
        self.GFCTexture:SetColor(color.r, color.g, color.b, color.a)
    else
        -- Set to default if it's set
        if self.preferences.overlay.default then
            local default = self.preferences.colors.default
            self.GFCTexture:SetColor(default.r, default.g, default.b, default.a)
        else
            -- Set to white AKA none if no default set
            self.GFCTexture:SetColor(1, 1, 1, 1)
        end
    end
end

--- Update the addon UI based on current stacks and slotted state
--- @return nil
function GFC:UpdateUI()
    local stacks = self.currentStacks
    local slotted = self.skillSlotted
    local fadeInactive = self.preferences.fadeInactive

    self:SetSkillFade(not slotted and fadeInactive)

    if not slotted then
        self:SetSkillColorOverlay('inactive')
    elseif stacks == 4 then
        self:SetSkillColorOverlay('four')
    elseif stacks == 5 then
        self:SetSkillColorOverlay('proc')
    else
        self:SetSkillColorOverlay('default')
    end

    self:UpdateStacks(stacks)
end

--- Set the faded state
--- @param faded boolean True to fade the display
--- @return nil
function GFC:SetSkillFade(faded)
    -- Only change fade if our options want us to fade
    if self.preferences.fadeInactive and faded then
        local alpha = self.preferences.fadeAmount / 100
        self.GFCContainer:SetAlpha(alpha)
    else
        self.GFCContainer:SetAlpha(1)
    end
end

--- Toggle scene fragments
--- @return nil
function GFC:ToggleHUD()
    if self.fragment then
        self:RemoveSceneFragments()
    else
        self:AddSceneFragments()
    end

    self:Trace(2, "Finished ToggleHUD()")
end

--- Set the locked to reticle state
--- @param lockToReticle boolean True to lock to reticle
--- @return nil
function GFC:LockToReticle(lockToReticle)
    if lockToReticle then
        self.preferences.lockedToReticle = true
        self:Trace(1, "Locked to Reticle")
    else
        self.preferences.lockedToReticle = false
        self:Trace(1, "Unlocked from Reticle")
    end
    self:SetPosition(self.preferences.positionLeft, self.preferences.positionTop)
end

--- Handler for when moving the display stops
--- @return nil
function GFC:OnMoveStop()
    self:Trace(1, "Moved")
    self:SavePosition()
end

--- Save the current display position
--- @return nil
function GFC:SavePosition()
    local top = self.GFCContainer:GetTop()
    local left = self.GFCContainer:GetLeft()

    -- If locked to reticle, but unlocked and moved,
    -- then we are no longer locked to reticle.
    self.preferences.lockedToReticle = false

    self:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    self.preferences.positionLeft = left
    self.preferences.positionTop  = top
end

--- Set the display position
--- @param left number|nil Left position, optional when lockedToReticle enabled
--- @param top number|nil Top position, optional when lockedToReticle enabled
--- @return nil
function GFC:SetPosition(left, top)
    if self.preferences.lockedToReticle then
        local height = GuiRoot:GetHeight()

        self.GFCContainer:ClearAnchors()
        self.GFCContainer:SetAnchor(CENTER, GuiRoot, TOP, 0, height / 2)
    else
        self:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
        self.GFCContainer:ClearAnchors()
        self.GFCContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

--- Update the number of stacks to display
--- @param stackCount integer Number of stacks to display
--- @return nil
function GFC:UpdateStacks(stackCount)
    local stackFrame

    -- Ignore missing stackCount
    if not stackCount then return end

    if stackCount > 0 then
        self:Trace(1, "Stack #<<1>>", stackCount)
        stackFrame = stackCount
    else
        if self.preferences.showEmptyStacks then
            self:Trace(1, "Stack #0 (Show Empty)")
            stackFrame = 6
        else
            self:Trace(1, "Stack #0")
            stackFrame = 0
        end
    end

    self.GFCTexture:SetTextureCoords(self.TEXTURE_FRAMES[stackFrame].REL, self.TEXTURE_FRAMES[stackFrame + 1].REL, 0, 1)
end

--- Handle slash command input
--- @param command string Slash command input
--- @return nil
function GFC:SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" or command == "debug off" then
        self:Trace(0, "Setting debug level to 0 (Off)")
        self.debugMode = self.debugModes.off
        self.preferences.debugMode = self.debugModes.off
    elseif command == "debug 1" or command == "debug low" then
        self:Trace(0, "Setting debug level to 1 (Low)")
        self.debugMode = self.debugModes.low
        self.preferences.debugMode = self.debugModes.low
    elseif command == "debug 2" or command == "debug medium" then
        self:Trace(0, "Setting debug level to 2 (Medium)")
        self.debugMode = self.debugModes.medium
        self.preferences.debugMode = self.debugModes.medium
    elseif command == "debug 3" or command == "debug high" then
        self:Trace(0, "Setting debug level to 3 (High)")
        self.debugMode = self.debugModes.high
        self.preferences.debugMode = self.debugModes.high

        -- Position Options -------------------------------------------------------
    elseif command == "position reset" then
        self:Trace(0, "Resetting position to reticle")
        local tempPos = self.preferences.lockedToReticle
        self.preferences.lockedToReticle = true
        self:SetPosition()
        self.preferences.lockedToReticle = tempPos
    elseif command == "position show" then
        self:Trace(
            0,
            "Display position is set to: <<1>> x <<2>>",
            self.preferences.positionTop,
            self.preferences.positionLeft
        )
    elseif command == "position lock" then
        self:Trace(0, "Locking display")
        self.preferences.unlocked = false
        self.GFCContainer:SetMovable(false)
    elseif command == "position unlock" then
        self:Trace(0, "Unlocking display")
        self.preferences.unlocked = true
        self.GFCContainer:SetMovable(true)

        -- Manage Registration ----------------------------------------------------
    elseif command == "register" then
        self:Trace(0, "Reregistering all events")
        self:UnregisterEvents()
        self:RegisterEvents()
    elseif command == "unregister" then
        self:Trace(0, "Unregistering all events")
        self:UnregisterEvents()
        self.abilityActive = false
        self:UpdateStacks(0)
    elseif command == "register unfiltered" then
        self:Trace(0, "Unregistering all events")
        self:UnregisterEvents()
        self.abilityActive = false
        self:UpdateStacks(0)
        self:Trace(0, "Registering for ALL events unfiltered")
        self.RegisterUnfilteredEvents()
    elseif command == "unregister unfiltered" then
        self:Trace(0, "Unregistering unfiltered events")
        self:UnregisterUnfilteredEvents()
        self.abilityActive = false
        self:UpdateStacks(0)

        -- Default ----------------------------------------------------------------
    else
        self:Trace(0, "Command not recognized!")
    end
end
