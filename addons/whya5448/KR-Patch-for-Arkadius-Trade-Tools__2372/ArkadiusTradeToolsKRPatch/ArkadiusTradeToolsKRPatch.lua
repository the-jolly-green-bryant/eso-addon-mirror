function ArkadiusTradeToolsSortFilterList:SetupRow(row, data)
    local index = GetControl(row, "Index")
    index:SetText(data.sortIndex)

    local linkText = GetControl(row, "ItemLinkText")
    local timeStamp = GetControl(row, "TimeStamp")
    if(linkText) then linkText:SetFont("ZoFontGame") end
    if(timeStamp) then timeStamp:SetFont("ZoFontGame") end
    
    ZO_SortFilterList.SetupRow(self, row, data)
end

local function _GetChildren(control)
	local children = {}
	for i = 1, control:GetNumChildren() do
		children[i] = control:GetChild(i)
	end
	return children
end

local function TT_ChangeFont(control)
    local did = false
    for _, t in pairs(control:GetNamedChild("ItemListList")["data"]) do
        local y = t["control"]:GetNamedChild("ItemLink")
        if (y ~= nil) then
            y:SetFont("ZoFontGame")
            did = true
        end
    end
    return did
end

local function TT_POPUP() 
    if(TT_ChangeFont(ArkadiusTradeToolsSalesPopupTooltip)) then
        EVENT_MANAGER:UnregisterForEvent("ArkadiusTradeToolsKRPatch_TT_POPUP", EVENT_CHAT_MESSAGE_CHANNEL)
    end
end
local function TT_LINK() 
    if(TT_ChangeFont(ArkadiusTradeToolsSalesItemTooltip)) then
        EVENT_MANAGER:UnregisterForEvent("ArkadiusTradeToolsKRPatch_TT_LINK", EVENT_CHAT_MESSAGE_CHANNEL)
    end
end

local function ChangeFont()
    for _, t in pairs({ ArkadiusTradeToolsSalesItemTooltip, ArkadiusTradeToolsSalesPopupTooltip }) do
        for __, v in pairs( _GetChildren( t:GetNamedChild("CraftingInfo") ) ) do 
            v:GetNamedChild("ItemLink"):SetFont("ZoFontWinH5") 
        end
    end
    EVENT_MANAGER:UnregisterForEvent("ArkadiusTradeToolsKRPatch_ATT_MAIN", EVENT_CHAT_MESSAGE_CHANNEL)
end

local function RegisterEvents() 
    EVENT_MANAGER:RegisterForEvent("ArkadiusTradeToolsKRPatch_ATT_MAIN", EVENT_CHAT_MESSAGE_CHANNEL, ChangeFont)
    EVENT_MANAGER:RegisterForEvent("ArkadiusTradeToolsKRPatch_TT_POPUP", EVENT_CHAT_MESSAGE_CHANNEL, TT_POPUP)
    EVENT_MANAGER:RegisterForEvent("ArkadiusTradeToolsKRPatch_TT_LINK", EVENT_CHAT_MESSAGE_CHANNEL, TT_LINK)
end

EVENT_MANAGER:RegisterForEvent("ArkadiusTradeToolsKRPatch", EVENT_PLAYER_ACTIVATED, RegisterEvents)
