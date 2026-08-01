-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Aug 23, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

function MOON.DrawUI()

    local container = WINDOW_MANAGER:GetControlByName("MOONContainer")

    if MOON.enabled then
        if container == nil then
            local c = WINDOW_MANAGER:CreateTopLevelWindow("MOONContainer")
            c:SetClampedToScreen(true)
            c:SetDimensions(MOON.preferences.size, MOON.preferences.size)
            c:ClearAnchors()
            c:SetMouseEnabled(true)
            c:SetAlpha(1)
            c:SetMovable(MOON.preferences.unlocked)
            c:SetHidden(false)
            c:SetHandler("OnMoveStop", function(...) MOON.SavePosition() end)
            c:SetHandler("OnMouseEnter", function(...) toggleDraggable(true) end)
            c:SetHandler("OnMouseExit", function(...) toggleDraggable(false) end)

            local t = WINDOW_MANAGER:CreateControl("MOONTexture", c, CT_TEXTURE)
            t:SetTexture("FullMoon/art/textures/FullMoon.dds")
            t:SetDimensions(MOON.preferences.size, MOON.preferences.size)
            t:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

            local l = WINDOW_MANAGER:CreateControl("MOONLabel", c, CT_LABEL)
            l:SetAnchor(CENTER, c, CENTER, 0, 0)
            l:SetColor(0.12, 0.11, 0.18, 1)
            l:SetFont("$(BOLD_FONT)|50|thin-outline")
            l:SetVerticalAlignment(TOP)
            l:SetHorizontalAlignment(LEFT)
            l:SetPixelRoundingEnabled(true)
            l:SetText("0")

            MOON.Container = c
            MOON.Texture = t
            MOON.Label = l

            MOON.SetFontSize(MOON.preferences.size)
            MOON.SetPosition(MOON.preferences.positionLeft, MOON.preferences.positionTop)
        else
            MOON:ShowIcon(true)
        end
    else
        if container ~= nil then
            MOON:ShowIcon(false)
        end
    end

    MOON:Trace(2, "Finished DrawUI()")
end

function MOON.SetFontSize(size)
    local scale = size / 100
    MOON.Label:SetScale(scale)
end

function MOON.PlaySound(sound)
    PlaySound(SOUNDS[sound])
end

function toggleDraggable(state)
    if MOON.preferences.unlocked then
        if state then
            WINDOW_MANAGER:SetMouseCursor(12)
        else
            WINDOW_MANAGER:SetMouseCursor(0)
        end
    end
end

function MOON.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if MOON.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            MOON.HUDHidden = true
            MOON:SetCombatStateDisplay()
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            MOON.HUDHidden = false
            MOON:SetCombatStateDisplay()
        end
    end)

    MOON:Trace(2, "Finished ToggleHUD()")
end

function MOON:ShowIcon(state)
    local container = WINDOW_MANAGER:GetControlByName("MOONContainer")
    MOON:Trace(3, "Show Icon: <<1>>", tostring(state))
    if container ~= nil then
        if MOON.ForceShow then
            container:SetHidden(false)
        elseif (state and MOON.enabled and not MOON.HUDHidden) then
            container:SetHidden(false)
        else
            container:SetHidden(true)
        end
    end

end

function MOON:SetCombatStateDisplay()
    MOON:Trace(3, "Setting combat state display - inCombat: <<1>> HideOOC: <<2>> isDead: <<3>>",
        tostring(MOON.isInCombat),
        tostring(MOON.preferences.hideOOC),
        tostring(MOON.isDead))

    if (MOON.isInCombat or not MOON.preferences.hideOOC) and not MOON.isDead then
        MOON:ShowIcon(true)
    else
        MOON:ShowIcon(false)
    end
end

function MOON.OnMoveStop()
    MOON:Trace(1, "Moved")
    MOON.SavePosition()
end

function MOON.SavePosition()
    local top   = MOON.Container:GetTop()
    local left  = MOON.Container:GetLeft()

    MOON:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    MOON.preferences.positionLeft = left
    MOON.preferences.positionTop  = top
end

function MOON.SetPosition(left, top)
    if MOON.preferences.lockedToReticle then
        local height = GuiRoot:GetHeight()

        MOON.Container:ClearAnchors()
        MOON.Container:SetAnchor(CENTER, GuiRoot, TOP, 0, height/2)
    else
        MOON:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
        MOON.Container:ClearAnchors()
        MOON.Container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

function MOON.Update()

    -- Frenzied Update
    if MOON.onProc then

        local procCountdown = (MOON.timeOfProc + MOON.procDurationMs - GetGameTimeMilliseconds()) / 1000

        if procCountdown <= 0 then
            MOON.Frenzied(false)
        else
            MOON.Label:SetText(string.format("%.1f", procCountdown))
        end

    -- Cooldown Update
    elseif MOON.onCooldown then

        local cooldownCountdown = (MOON.timeOfProc + MOON.cooldownDurationMs - GetGameTimeMilliseconds()) / 1000

        if cooldownCountdown <= 0 then
            MOON.onCooldown = false
            MOON.Label:SetText("0")
            MOON.Label:SetColor(0.12, 0.11, 0.18, 1)
        elseif cooldownCountdown < 10 then

            local output = string.format("%.1f", cooldownCountdown)

            -- Silly fix for 10.0 still showing up
            if output == "10.0" then
                MOON.Label:SetText("10")
            else
                MOON.Label:SetText(output)
            end

        else
            MOON.Label:SetText(string.format("%.0f", cooldownCountdown))
        end

    else
        EVENT_MANAGER:UnregisterForUpdate(MOON.name .. "FRENZIED")
    end

end

function MOON.UpdateStacks(stackCount)

    -- Ignore missing stackCount
    if not stackCount then return end

    MOON.Label:SetText(stackCount)
end

function MOON.Frenzied(isFrenzied)
    MOON.onProc = isFrenzied
    if isFrenzied then
        MOON.Texture:SetTexture("FullMoon/art/textures/BloodMoon.dds")
        MOON.Label:SetColor(1, 0.88, 0.70, 1)
        if MOON.preferences.soundEnabled then
            MOON.PlaySound(MOON.preferences.sound)
        end
    else
        MOON.Texture:SetTexture("FullMoon/art/textures/FullMoon.dds")
        MOON.Label:SetColor(0.22, 0.2, 0.31, 0.85)
    end

end

function MOON.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(MOON.prefix .. "Setting debug level to 0 (Off)")
        MOON.debugMode = 0
        MOON.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(MOON.prefix .. "Setting debug level to 1 (Low)")
        MOON.debugMode = 1
        MOON.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(MOON.prefix .. "Setting debug level to 2 (Medium)")
        MOON.debugMode = 2
        MOON.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(MOON.prefix .. "Setting debug level to 3 (High)")
        MOON.debugMode = 3
        MOON.preferences.debugMode = 3

    -- Default ----------------------------------------------------------------
    else
        d(MOON.prefix .. "Command not recognized!")
    end
end

