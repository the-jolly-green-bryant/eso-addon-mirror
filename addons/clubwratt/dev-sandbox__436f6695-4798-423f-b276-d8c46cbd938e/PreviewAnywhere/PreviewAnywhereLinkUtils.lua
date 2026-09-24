-- PreviewAnywhereLinkUtils.lua: Pure helpers for ZO_GamepadLinks instances.

local LinkUtils = {}

---@param linkData PreviewAnywhereGamepadLinksEntry|nil Entry from a ZO_GamepadLinks instance
---@return boolean
function LinkUtils.CanPreviewLinkData(linkData)
    if not linkData then
        return false
    end
    return PreviewAnywhere.PreviewUtils.CanPreviewItemLink(linkData.link)
end

---Collect every previewable item link held by a ZO_GamepadLinks instance so
---the preview scene can cycle through them with LT/RT.
---@param gamepadLinks table ZO_GamepadLinks instance
---@return string[] itemLinks
---@return integer startIndex Index of the currently shown link within itemLinks (1 when not previewable)
function LinkUtils.GetPreviewableLinks(gamepadLinks)
    local itemLinks = {}
    local startIndex = 1
    local currentLinkData = gamepadLinks:GetCurrentLink()

    for _, linkData in ipairs(gamepadLinks:GetLinks()) do
        if LinkUtils.CanPreviewLinkData(linkData) then
            table.insert(itemLinks, linkData.link)
            if linkData == currentLinkData then
                startIndex = #itemLinks
            end
        end
    end

    return itemLinks, startIndex
end

PreviewAnywhere.LinkUtils = LinkUtils
