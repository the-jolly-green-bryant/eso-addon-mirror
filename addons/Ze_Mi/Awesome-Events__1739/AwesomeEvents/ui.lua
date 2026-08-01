--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: ui.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events

local _lastWidth = 0
local _inSettingsPanel = false
local _position = { left = 1000, top = 30 }

local ui = {
    dragging = false
}

--- after resizing the window, or on first load, the anchors have to be resetted
local function UpdateViewPosition()
    AwesomeEventsView:ClearAnchors()
    if (AE.vars.window.textAlign == TEXT_ALIGN_LEFT) then
        AwesomeEventsView:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, _position.left, _position.top)
    elseif (AE.vars.window.textAlign == TEXT_ALIGN_RIGHT) then
        AwesomeEventsView:SetAnchor(TOPRIGHT, GuiRoot, TOPLEFT, _position.left, _position.top)
    else
        AwesomeEventsView:SetAnchor(TOP, GuiRoot, TOPLEFT, _position.left, _position.top)
    end
end -- UpdateViewPosition

--- change view movability
ui.SetMovable = function()
    AwesomeEventsView:SetMovable(AE.vars.window.movable)
end -- SetMovable

--- change view scale
ui.SetScale = function()
    AwesomeEventsView:SetScale(AE.vars.window.scaling)
    ui.UpdateViewSize()
end -- SetScale

--- change horizontal alignment of all labels, adjust view position
ui.SetTextAlign = function(newTextAlign)
    -- keep the position even if the anchor changes
    if (AE.initialized) then
        local halfWindowWidth, leftShift = math.floor(AwesomeEventsView:GetWidth() / 2), 0
        if (AE.vars.window.textAlign == TEXT_ALIGN_LEFT) then
            leftShift = halfWindowWidth
        elseif (AE.vars.window.textAlign == TEXT_ALIGN_RIGHT) then
            leftShift = 0 - halfWindowWidth
        end
        if (newTextAlign == TEXT_ALIGN_LEFT) then
            leftShift = leftShift - halfWindowWidth
        elseif (newTextAlign == TEXT_ALIGN_RIGHT) then
            leftShift = leftShift + halfWindowWidth
        end
        _position.left = _position.left + leftShift
        AE.vars.window.left = AE.vars.window.left + leftShift
    end
    AE.vars.window.textAlign = newTextAlign

    UpdateViewPosition()
    for i = 2, AwesomeEventsView:GetNumChildren() do
        local child = AwesomeEventsView:GetChild(i)
        child:SetHorizontalAlignment(newTextAlign)
    end
end -- AE.SetTextAlign

ui.SetBackgroundTransparency = function()
    AwesomeEventsViewBg:SetAlpha(AE.vars.window.backgroundAlpha)
end

ui.MarkAllDirty = function()
    for mod_id, mod in AE.core.pairs(AE.core.modules) do
        if (AE.vars[mod_id].enabled) then
            mod.hasUpdate = true
        end
    end
end -- MarkAllDirty

--- update the font size of all labels
ui.UpdateFontSize = function()
    -- starting at 1, but 1 = background, 2 = title
    for i = 3, AwesomeEventsView:GetNumChildren() do
        local child = AwesomeEventsView:GetChild(i)
        local mod_id = AE.core.labelToMod[i]
        local fontSize = 6 - AE.vars[mod_id].fontSize
        if (fontSize < 1) then
            fontSize = 1
        end
        if (fontSize > 5) then
            fontSize = 5
        end
        child:SetFont('ZoFontWinH' .. fontSize)
    end
end -- AE:UpdateFontSize

--- resize the window to show all visible labels
ui.UpdateViewSize = function()
    if ui.dragging then
        return
    end

    local maxWidth, totalHeight, lastModId, lastLabel, lastModLabelCount = 0, 0, nil, nil, 0
    local lazyAddSpacing = 0

    -- starting at 1, but 1 = background, 2 = title
    for i = 3, AwesomeEventsView:GetNumChildren() do
        local child = AwesomeEventsView:GetChild(i)
        local text = child:GetText()
        -- hide if text is empty
        if (text == '') then
            -- not hidden yet?
            if (child:GetHeight() > 0) then
                child:SetHeight(0)
            end
            -- show label with text
        else
            child:SetWidth(0)
            local mod_id, spacing = AE.core.labelToMod[i], 0
            -- last mod ended ?
            if (lastModId ~= mod_id) then
                -- add bottom spacing to previous label (if mod has multiple label for)
                if (lazyAddSpacing > 0) then
                    lastLabel:SetHeight(lastLabel:GetHeight() + lazyAddSpacing);
                    totalHeight = totalHeight + lazyAddSpacing
                    if (lastModLabelCount > 1 or AE.vars[lastModId].spacingPosition == TEXT_ALIGN_TOP) then
                        lastLabel:SetVerticalAlignment(TEXT_ALIGN_TOP);
                    else
                        lastLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER);
                    end
                    lazyAddSpacing = 0
                end
                lastModLabelCount = 0

                -- add top spacing
                if (AE.vars[mod_id].spacingPosition == TEXT_ALIGN_BOTTOM) then
                    spacing = AE.vars[mod_id].spacing
                    child:SetVerticalAlignment(TEXT_ALIGN_BOTTOM);
                elseif (AE.vars[mod_id].spacingPosition == TEXT_ALIGN_CENTER) then
                    spacing = AE.vars[mod_id].spacing
                    child:SetVerticalAlignment(TEXT_ALIGN_BOTTOM);
                    lazyAddSpacing = spacing
                elseif (AE.vars[mod_id].spacingPosition == TEXT_ALIGN_TOP) then
                    child:SetVerticalAlignment(TEXT_ALIGN_TOP);
                    lazyAddSpacing = AE.vars[mod_id].spacing
                end
            end

            local newHeight = child:GetTextHeight() + spacing
            -- not yet visible or wrong spacing ?
            if (newHeight ~= child:GetHeight()) then
                child:SetHeight(newHeight)
            end
            totalHeight = totalHeight + newHeight
            maxWidth = math.max(maxWidth, child:GetTextWidth())

            lastModLabelCount = lastModLabelCount + 1
            lastModId = mod_id
            lastLabel = child
        end
    end

    if (lazyAddSpacing > 0) then
        lastLabel:SetHeight(lastLabel:GetHeight() + lazyAddSpacing);
        totalHeight = totalHeight + lazyAddSpacing
        if (lastModLabelCount > 1) then
            lastLabel:SetVerticalAlignment(TEXT_ALIGN_TOP);
        else
            lastLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER);
        end
    end

    -- show awesome events label if no other label active
    local child = AwesomeEventsView:GetChild(2)
    local text = child:GetText()
    -- clear all mods disabled hint if labels exist
    if (totalHeight > 0 and text ~= '') then
        child:SetText('')
        child:SetHeight(0)
        -- show all mods disabled hint if no labels exist
    elseif (totalHeight == 0) then
        local numActiveMods = 0
        for mod_id, mod in AE.core.pairs(AE.core.modules) do
            if (mod.active) then
                numActiveMods = numActiveMods + 1
            end
        end

        -- zero mods enabled and hint enabled in settings ? -> show hint
        if (numActiveMods == 0 and AE.vars.showDisabledText) then
            child:SetText(GetString(SI_AWEVS_ALL_MODS_DISABLED))
            child:SetWidth(0)
            totalHeight = child:GetTextHeight()
            child:SetHeight(totalHeight)
            maxWidth = child:GetTextWidth()
            -- non zero mods enabled or text disabled in settings ? -> remove hint
        elseif (text ~= '') then
            child:SetText('')
            child:SetHeight(0)
        end
    end

    maxWidth = (maxWidth + 20)
    totalHeight = totalHeight + 10

    for i = 2, AwesomeEventsView:GetNumChildren() do
        local _child = AwesomeEventsView:GetChild(i)
        _child:SetWidth(maxWidth)
    end

    AwesomeEventsView:SetWidth(maxWidth)
    AwesomeEventsView:SetHeight(totalHeight)

    if (_lastWidth ~= maxWidth) then
        _lastWidth = maxWidth
        UpdateViewPosition();
    end
end -- UpdateViewSize

---
--- SHOW
---

ui.hide = function()
    AwesomeEventsView:SetHidden(true)
end

ui.show = function()
    if (not AE.initialized) then
        return
    end
    if AwesomeEventsView:IsHidden() then
        if (_inSettingsPanel) then
            local sub = {
                [TEXT_ALIGN_LEFT] = AwesomeEventsView:GetWidth(),
                [TEXT_ALIGN_CENTER] = AwesomeEventsView:GetWidth() / 2,
                [TEXT_ALIGN_RIGHT] = 0,
            }
            _position.left = math.floor(GuiRoot:GetWidth() * 0.96) - sub[AE.vars.window.textAlign]
            _position.top = 200

            AwesomeEventsView:SetDrawLayer(DL_OVERLAY)
            AwesomeEventsView:SetMovable(true)
        else
            _position.left = AE.vars.window.left
            _position.top = AE.vars.window.top

            AwesomeEventsView:SetDrawLayer(DL_BACKGROUND)
            AwesomeEventsView:SetMovable(AE.vars.window.movable)
        end
        UpdateViewPosition()
        AwesomeEventsView:SetHidden(false)
    end
end -- show

ui.onMoveStart = function()
    -- start dragging mode
    ui.dragging = true
end -- onMoveStart

ui.onMoveStop = function()
    if (AE.vars.window.textAlign == TEXT_ALIGN_LEFT) then
        _position.left = AwesomeEventsView:GetLeft()
        _position.top = AwesomeEventsView:GetTop()
    elseif (AE.vars.window.textAlign == TEXT_ALIGN_RIGHT) then
        _position.left = AwesomeEventsView:GetRight()
        _position.top = AwesomeEventsView:GetTop()
    else
        _position.left = AwesomeEventsView:GetCenter()
        _position.top = AwesomeEventsView:GetTop()
    end

    -- do not store movement in LAMSettingsPanel
    if (not _inSettingsPanel) then
        AE.vars.window.left = math.floor(_position.left * 100) / 100;
        AE.vars.window.top = math.floor(_position.top * 100) / 100;
    end
    ui.dragging = false
end -- onMoveStop

ui.onSceneStateChanged = function(scene, oldState, newState)
    if (scene.name == 'hud' or scene.name == 'hudui') then
        if (newState == SCENE_HIDING) then
            AwesomeEventsView:SetHidden(true)
        elseif (newState == SCENE_SHOWN) then
            ui.show()
        end
    elseif (scene.name == 'gameMenuInGame') then
        if (newState == SCENE_HIDING) then
            _inSettingsPanel = false
            AwesomeEventsView:SetHidden(true)
        elseif (newState == SCENE_SHOWN) then
            _inSettingsPanel = true
        end
    end
end

local function reset()
    local firstControl = AwesomeEventsView:GetChild(2)
    CALLBACK_MANAGER:FireCallbacks(AE.const.CALLBACK_UI_PRE, "AwesomeEventsLabel", AwesomeEventsView, firstControl)

    ui.SetScale()
    ui.SetMovable()
    ui.SetBackgroundTransparency()
    ui.SetTextAlign(AE.vars.window.textAlign)
    ui.UpdateFontSize()
    ui.UpdateViewSize()

    ui.show()
end

CALLBACK_MANAGER:RegisterCallback(AE.const.CALLBACK_VARS, reset)

AE.ui = ui