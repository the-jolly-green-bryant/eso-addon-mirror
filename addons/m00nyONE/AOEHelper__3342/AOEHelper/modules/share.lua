--[[
local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}


function init()
    LibChatMessage:RegisterCustomChatLink(AOEHelper.URL_LINK_TYPE, function(linkStyle, linkType, data, displayText)
        return ZO_LinkHandler_CreateLinkWithoutBrackets(displayText, nil, AOEHelper.URL_LINK_TYPE, data)
    end)
end

function AOEHelper.serializeColors(colors)
    if type(colors) ~= "table" then return end

    -- serialize to chat
end



local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)
]]--