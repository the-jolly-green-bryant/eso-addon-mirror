LibFilteredChatPanel = LibFilteredChatPanel or {}
local LFCP = LibFilteredChatPanel

----------------------------------------------------------------------
-- Slide wheeeeeeeee
-- /script LibFilteredChatPanel.OnSidebarClicked(MOUSE_BUTTON_INDEX_LEFT)
----------------------------------------------------------------------
function LFCP.OnSidebarClicked(button)
    if (button ~= MOUSE_BUTTON_INDEX_LEFT) then return end

    if (LFCP.savedOptions.expanded) then
        -- Slide it off screen
        FilteredChatPanel.slide:SetDeltaOffsetX(GuiRoot:GetWidth() - LibFilteredChatPanel.savedOptions.window.left)
        FilteredChatPanelContentFooterClose.slide:SetDeltaOffsetX(-LibFilteredChatPanel.savedOptions.window.width - 6)
        FilteredChatPanelContentFooterClose.rotateAnimation:PlayFromStart()
    else
        FilteredChatPanel.slide:SetDeltaOffsetX(LibFilteredChatPanel.savedOptions.window.left - GuiRoot:GetWidth())
        FilteredChatPanelContentFooterClose.slide:SetDeltaOffsetX(LibFilteredChatPanel.savedOptions.window.width + 6)
        FilteredChatPanelContentFooterClose.rotateAnimation:PlayBackward()
    end
    FilteredChatPanel.slideAnimation:PlayFromStart()
    FilteredChatPanelContentFooterClose.slideAnimation:PlayFromStart()
    LFCP.savedOptions.expanded = not LFCP.savedOptions.expanded
end

----------------------------------------------------------------------
-- Upon right clicking the timestamp, put it in the text field for copying
-- /script LibFilteredChatPanel:GetSystemFilter():AddMessage("|H1:item:80725:359:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:0:0|h|h")
-- /script d(string.gmatch("1:item:80725:359:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:0:0", "0:LFCP:"))
----------------------------------------------------------------------
function LFCP.OnLinkClicked(linkText, button, self, linkData)
    if (string.match(linkData, "0:LFCP:")) then
        if (button == MOUSE_BUTTON_INDEX_RIGHT) then
            -- Copy
            local key = string.gsub(linkData, "0:LFCP:", "")
            local filterName = nil
            local index = nil
            for word in string.gmatch(key, "([^=]+)") do
                if (not filterName) then
                    filterName = word
                else
                    index = tonumber(word)
                end
            end

            -- Offset due to cleanup
            local filter = LFCP.filters[filterName]
            if (index > #filter.lines) then
                index = index - LFCP.MAX_HISTORY_LINES
            end

            local line = filter.lines[index]
            LFCP.SetTextAndFocus(line.rawText)
        end
    else
        -- Other links should continue handlers
        ZO_LinkHandler_OnLinkMouseUp(linkText, button, self)
    end
end

----------------------------------------------------------------------
-- Upon clicking filter buttons, toggle the texture and redo buffer
----------------------------------------------------------------------
local function AdjustFilterIcon(control, enabled)
    if (enabled) then
        control:GetNamedChild("Texture"):SetDesaturation(0)
        control:GetNamedChild("Texture"):SetColor(1, 1, 1, 1)
    else
        control:GetNamedChild("Texture"):SetDesaturation(1)
        control:GetNamedChild("Texture"):SetColor(0.5, 0.5, 0.5, 1)
    end
end
LFCP.AdjustFilterIcon = AdjustFilterIcon

function LFCP.OnFilterIconClicked(control)
    local filterName = string.gsub(control:GetName(), "FilteredChatPanelContentHeader", "")

    LFCP.savedOptions.toggles[filterName] = not LFCP.savedOptions.toggles[filterName]

    AdjustFilterIcon(control, LFCP.savedOptions.toggles[filterName])

    LFCP.ResetBuffer()
end
