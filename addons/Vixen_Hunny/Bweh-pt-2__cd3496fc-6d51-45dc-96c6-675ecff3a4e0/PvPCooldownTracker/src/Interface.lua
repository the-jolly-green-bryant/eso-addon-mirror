-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------

PvPCooldownTracker.UI = {}
PvPCooldownTracker.UI.scaleBase = 100

local scaleBase = PvPCooldownTracker.UI.scaleBase
local WM = WINDOW_MANAGER
local AM = ANIMATION_MANAGER
local function SnapToGrid(position, gridSize)
    -- Round down
    position = math.floor(position)

    -- Return value to closest grid point
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    else
        return position - (position % gridSize)
    end
end
local function SetPosition(key, container, left, top)
    PvPCooldownTracker:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    local context = WM:GetControlByName(key .. container)
    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function SavePosition(key)
    local context = WM:GetControlByName(key .. "_Container")
    local top   = context:GetTop()
    local left  = context:GetLeft()

    if PvPCooldownTracker.preferences.snapToGrid then
        local gridSize = PvPCooldownTracker.preferences.gridSize
        top = SnapToGrid(top, gridSize)
        left = SnapToGrid(left, gridSize)
        SetPosition(key, left, top)
    end

    PvPCooldownTracker:Trace(2, "Saving position for <<1>> - Left: <<2>> Top: <<3>>", key, left, top)

    PvPCooldownTracker.preferences.sets[key].x = left
    PvPCooldownTracker.preferences.sets[key].y = top
end
function PvPCooldownTracker.UI.Draw(key)

    local set = PvPCooldownTracker.Data.Sets[key];
    local container = WM:GetControlByName(key .. "_Container")                                                                             
    -- Enable display
    if set.enabled then

        local saved = PvPCooldownTracker.preferences.sets[key]
        -- Draw UI and create context if it doesn't exist
        if container == nil then
            PvPCooldownTracker:Trace(2, "Drawing: <<1>>", key)

            local c = WM:CreateTopLevelWindow(key .. "_Container")
            c:SetClampedToScreen(true)
            c:SetDimensions(scaleBase, scaleBase)
            c:ClearAnchors()
            c:SetMouseEnabled(true)
            c:SetAlpha(1)
            c:SetMovable(PvPCooldownTracker.preferences.unlocked)
            if PvPCooldownTracker.HUDHidden then
                c:SetHidden(true)
            else
                c:SetHidden(false)
            end
            c:SetScale(saved.size / scaleBase)
            c:SetHandler("OnMoveStop", function(...) SavePosition(key) end)

            local r = WM:CreateControl(key .. "_Texture", c, CT_TEXTURE)
            local setLabel = WM:CreateControl(key .. "_123", c, CT_LABEL)
            setLabel:SetAnchor(CENTER, c, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
            setLabel:SetColor(1, 1, 1, 1)
            setLabel:SetFont("/esoui/common/fonts/univers67.otf|20|soft-shadow-thick")
            setLabel:SetVerticalAlignment(TOP)
            setLabel:SetHorizontalAlignment(RIGHT)
            setLabel:SetPixelRoundingEnabled(true)
            r:SetTexture(set.texture)
            r:SetDimensions(scaleBase, scaleBase)
            r:SetAnchor(CENTER, c, CENTER, PvPCooldownTracker.preferences.sets[key].x, PvPCooldownTracker.preferences.sets[key].y)
            if set.showFrame then
                local f = WM:CreateControl(key .. "_Frame", c, CT_TEXTURE)
                if set.procType == "set" then

                    -- Add 5 to make the frame sit where it should.
                    f:SetTexture("/esoui/art/actionbar/gamepad/gp_abilityframe64.dds")
                    f:SetDimensions(scaleBase, scaleBase)
                end
                f:SetAnchor(CENTER, c, CENTER, PvPCooldownTracker.preferences.sets[key].x, PvPCooldownTracker.preferences.sets[key].y)
            end

            local l = WM:CreateControl(key .. "_Label", c, CT_LABEL)
            l:SetAnchor(CENTER, c, CENTER, PvPCooldownTracker.preferences.sets[key].x, PvPCooldownTracker.preferences.sets[key].y)
            l:SetColor(1, 1, 1, 1)
            l:SetFont("/esoui/common/fonts/univers67.otf|20|soft-shadow-thick")
            l:SetVerticalAlignment(TOP)
            l:SetHorizontalAlignment(RIGHT)
            l:SetPixelRoundingEnabled(true)

            SetPosition(key, "_Container",saved.x, saved.y)

        -- Reuse context
        else
            local setLabel = WM:GetControlByName(key .. "_123")
            if setLabel == nil then
                local setLabel = WM:CreateControl(key .. "_123", container, CT_LABEL)
                setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                setLabel:SetColor(1, 1, 1, 1)
                setLabel:SetFont("/esoui/common/fonts/univers67.otf|20|soft-shadow-thick")
                setLabel:SetVerticalAlignment(TOP)
                setLabel:SetHorizontalAlignment(RIGHT)
                setLabel:SetPixelRoundingEnabled(true)
            else
                setLabel:SetAnchor(CENTER, c, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                setLabel:SetColor(1, 1, 1, 1)
                setLabel:SetFont("/esoui/common/fonts/univers67.otf|20|soft-shadow-thick")
                setLabel:SetVerticalAlignment(TOP)
                setLabel:SetHorizontalAlignment(RIGHT)
                setLabel:SetPixelRoundingEnabled(true)

            end
            if not PvPCooldownTracker.HUDHidden then
                if setLabel == nil then
                    local setLabel = WM:CreateControl(key .. "_123", container, CT_LABEL)
                setLabel:SetAnchor(CENTER, c, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                setLabel:SetColor(1, 1, 1, 1)
                setLabel:SetFont("/esoui/common/fonts/univers67.otf|20|soft-shadow-thick")
                setLabel:SetVerticalAlignment(TOP)
                setLabel:SetHorizontalAlignment(RIGHT)
                setLabel:SetPixelRoundingEnabled(true)
                container:SetHidden(false)
                else
                    setLabel:SetAnchor(CENTER, c, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                setLabel:SetColor(1, 1, 1, 1)
                setLabel:SetFont("/esoui/common/fonts/univers67.otf|5-|soft-shadow-thick")
                setLabel:SetVerticalAlignment(TOP)
                setLabel:SetHorizontalAlignment(RIGHT)
                setLabel:SetPixelRoundingEnabled(true)
                end
                container:SetHidden(false)
            end
        end

    -- Disable display
    else
        local saved = PvPCooldownTracker.preferences.sets[key]
        if container ~= nil then
            local setLabel = GetControlByName(key .. "_123") or CreateControl(key .. "_123", container, CT_LABEL)
                setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                setLabel:SetColor(1, 1, 1, 1)
                setLabel:SetFont("/esoui/common/fonts/univers67.otf|20|soft-shadow-thick")
                setLabel:SetVerticalAlignment(TOP)
                setLabel:SetHorizontalAlignment(RIGHT)
                setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
                setLabel:SetPixelRoundingEnabled(true)
                container:SetHidden(false)
            end
            local setLabel = GetControlByName(key .. "_123") or CreateControl(key .. "_123", container, CT_LABEL)
            setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                setLabel:SetColor(1, 1, 1, 1)
                setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
                setLabel:SetFont("/esoui/common/fonts/univers67.otf|20|soft-shadow-thick")
                setLabel:SetVerticalAlignment(TOP)
                setLabel:SetHorizontalAlignment(RIGHT)
                setLabel:SetPixelRoundingEnabled(true)
                container:SetHidden(true)
        end
        PvPCooldownTracker:Trace(2, "Finished DrawUI()")
    end


function PvPCooldownTracker.UI:SetCombatStateDisplay()
    PvPCooldownTracker:Trace(3, "Setting combat state display, in combat: <<1>>", tostring(PvPCooldownTracker.isInCombat))

    if PvPCooldownTracker.isInCombat or PvPCooldownTracker.preferences.showOutsideCombat and not PvPCooldownTracker.isDead then
        PvPCooldownTracker.UI.ShowIcon(true)
    else
        PvPCooldownTracker.UI.ShowIcon(false)
    end
end

function PvPCooldownTracker.UI.PlaySound(sound)
    if sound.enabled then
        PlaySound(SOUNDS[sound.sound])
    end
end
function PvPCooldownTracker:SetAppearance(x, y, setKey)
        local container = WM:GetControlByName(setKey .. "_Container")
        local texture = WM:GetControlByName(setKey .. "_Texture")
        local f = WM:GetControlByName(setKey .. "_Frame")
        local label = WM:GetControlByName(setKey .. "_Label")
        local setLabel = WM:GetControlByName(setKey .. "_123")
        local saved = PvPCooldownTracker.preferences.sets[setKey]
        if texture and container then
            texture:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.sets[setKey].x, PvPCooldownTracker.preferences.sets[setKey].y)
            f:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.sets[setKey].x, PvPCooldownTracker.preferences.sets[setKey].y)
            label:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.sets[setKey].x, PvPCooldownTracker.preferences.sets[setKey].y)
            container:SetScale(saved.size / scaleBase)
        end
        if setLabel and container then
            container:SetScale(saved.size / scaleBase)
            setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
            setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
        end
    end
function PvPCooldownTracker:Check_Cooldown(setKey)
    local set = PvPCooldownTracker.Data.Sets[setKey]
    if set.onCooldown == true then
        return true
    else
        return false
    end
end
function PvPCooldownTracker.UI.Update(setKey)

    local set = PvPCooldownTracker.Data.Sets[setKey]
    local container = WM:GetControlByName(setKey .. "_Container")
    local texture = WM:GetControlByName(setKey .. "_Texture")
    local label = WM:GetControlByName(setKey .. "_Label")
    local setLabel = WM:GetControlByName(setKey .. "_123")
    local countdown = (set.timeOfProc + set.cooldownDurationMs - GetGameTimeMilliseconds()) / 1000
    if PvPCooldownTracker.first_run == true then
            d(setKey .. " first run")
            PvPCooldownTracker.first_run = false
            local animation = AM:CreateTimeline(true)
            local animslideY = animation:InsertAnimation(ANIMATION_TRANSLATE, setLabel, 0)
            local animFade = animation:InsertAnimation(ANIMATION_ALPHA, setLabel, 1500)
            animslideY:SetTranslateOffsets(PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y - 250)
            animslideY:SetDuration(1500)
            setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
            animFade:SetAlphaValues(setLabel:GetAlpha(), 0)
            animFade:SetEasingFunction(ZO_EaseOutCubic)
            animslideY:SetEasingFunction(ZO_EaseInCubic)
            animFade:SetDuration(400)
            animation:SetHandler("OnPlay", function(animation) 
                setLabel:SetText(string.format("|c%s%s Cooldown Started!|r", PvPCooldownTracker.preferences.set_active, setKey))
            end)
            animation:SetHandler("OnStop", function(completed) 
                    local saved = PvPCooldownTracker.preferences.sets[setKey]
                    setLabel:SetText(string.format("|c%s%s", PvPCooldownTracker.preferences.set_active, setKey))
                    setLabel:SetAlpha(1)
                    setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                    setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
            
        end)
        animation:PlayFromStart()
    end
    if PvPCooldownTracker:Check_Cooldown(setKey) == true then
       --PvPCooldownTracker:Trace(3, "Countdown: " .. countdown)
    if set.onCooldown == false then
        setLabel:SetText("")
        label:SetText("")
        return
    end
    texture:SetColor(0.5, 0.5, 0.5, 1)
    if (countdown <= 0) then
        if set.onCooldown == true then
            set.onCooldown = false
            EVENT_MANAGER:UnregisterForUpdate(PvPCooldownTracker.name .. setKey .. "Count")
            label:SetText("")
            texture:SetColor(1, 1, 1, 1)
            local animation = AM:CreateTimeline(true)
            local animslideY = animation:InsertAnimation(ANIMATION_TRANSLATE, setLabel, 0)
            local animFade = animation:InsertAnimation(ANIMATION_ALPHA, setLabel, 2000)
            animslideY:SetTranslateOffsets(PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y - 250)
            animslideY:SetDuration(2000)
            setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
            animFade:SetAlphaValues(setLabel:GetAlpha(), 0)
            animFade:SetEasingFunction(ZO_EaseOutCubic)
            animslideY:SetEasingFunction(ZO_EaseInCubic)
            animFade:SetDuration(400)
            animation:SetHandler("OnPlay", function(animation) 
                setLabel:SetText(string.format("|c%s%s Cooldown Expired!|r",PvPCooldownTracker.preferences.cooldown_expired, setKey))
            end)
            animation:SetHandler("OnStop", function(completed) 
                    local saved = PvPCooldownTracker.preferences.sets[setKey]
                    setLabel:SetText("")
                    setLabel:SetAlpha(1)
                    setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
                    setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
            
        end)
        animation:PlayFromStart()
        texture:SetColor(1, 1, 1, 1)
        PvPCooldownTracker.UI.PlaySound(PvPCooldownTracker.preferences.sets[setKey].sounds.onReady)
        
    end

    elseif (countdown < 10) then
        if set.onCooldown == false then
            label:SetText("")
            setLabel:SetText("")
        else
            set.onCooldown = true
            label:SetText(string.format("%.1f", countdown))
        end

    else
        if set.onCooldown == false then
            label:SetText("")
            setLabel:SetText("")
            return
        else
            set.onCooldown = true
            label:SetText(string.format("%.1f", countdown))
        end

    end
else

    end

end

function PvPCooldownTracker.UI.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if PvPCooldownTracker.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            PvPCooldownTracker:Trace(3, "Hiding HUD")
            PvPCooldownTracker.HUDHidden = true
            PvPCooldownTracker.UI:SetCombatStateDisplay()
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            PvPCooldownTracker:Trace(3, "Showing HUD")
            PvPCooldownTracker.HUDHidden = false
            PvPCooldownTracker.UI:SetCombatStateDisplay()
        end
    end)

    PvPCooldownTracker:Trace(2, "Finished ToggleHUD()")
end

function PvPCooldownTracker.UI.ShowIcon(shouldShow)

    for key, set in pairs(PvPCooldownTracker.Data.Sets) do
        local context = WM:GetControlByName(key .. "_Container")
        if context ~= nil then
            if PvPCooldownTracker.ForceShow and set.enabled then
                context:SetHidden(false)
            elseif (shouldShow and set.enabled and not PvPCooldownTracker.HUDHidden) then
                context:SetHidden(false)
            else
                context:SetHidden(true)
            end
        end
    end

end

function PvPCooldownTracker.UI.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 0 (Off)")
        PvPCooldownTracker.debugMode = 0
        PvPCooldownTracker.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 1 (Low)")
        PvPCooldownTracker.debugMode = 1
        PvPCooldownTracker.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 2 (Medium)")
        PvPCooldownTracker.debugMode = 2
        PvPCooldownTracker.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 3 (High)")
        PvPCooldownTracker.debugMode = 3
        PvPCooldownTracker.preferences.debugMode = 3

    -- Unfiltered Events
    elseif command == "all on" then
        d(PvPCooldownTracker.prefix .. "Registering unfiltered events, setting debug mode to 1")
        PvPCooldownTracker.debugMode = 1
        PvPCooldownTracker.preferences.debugMode = 1
        PvPCooldownTracker.Tracking.RegisterUnfiltered()
    elseif command == "all off" then
        d(PvPCooldownTracker.prefix .. "Unregistering unfiltered events, setting debug mode to 0")
        PvPCooldownTracker.Tracking.UnregisterUnfiltered()
        PvPCooldownTracker.debugMode = 0
        PvPCooldownTracker.preferences.debugMode = 0

    -- Default ----------------------------------------------------------------
    else
        d(PvPCooldownTracker.prefix .. "Command not recognized!")
    end
end
