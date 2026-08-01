LibFilteredChatPanel = LibFilteredChatPanel or {}
local LFCP = LibFilteredChatPanel

----------------------------------------------------------------------
----------------------------------------------------------------------
function LFCP.OnTextFieldEnter()
    local text = FilteredChatPanelContentFooterTextField:GetText()
    if (not text or text == "") then return end

    LFCP.filters["Player"]:AddMessage(text)

    FilteredChatPanelContentFooterTextField:SetText("")
end

function LFCP.OnTextFieldEscape()
    FilteredChatPanelContentFooterTextField:SetText("")
    FilteredChatPanelContentFooterTextField:LoseFocus()
end

function LFCP.SetTextAndFocus(text)
    FilteredChatPanelContentFooterTextField:SetText(text)
    FilteredChatPanelContentFooterTextField:TakeFocus()
end
