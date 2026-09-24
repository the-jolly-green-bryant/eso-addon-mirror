-- PreviewAnywherePreviewUtils.lua: Pure helpers for the item preview system.

local PreviewUtils = {}

-- Key registered into ITEM_PREVIEW_GAMEPAD.previewTypeObjects. A string key
-- cannot collide with the numeric ZO_ITEM_PREVIEW_* type constants, including
-- ones ZOS adds in future updates.
PreviewUtils.ITEM_LINK_PREVIEW_TYPE = "PreviewAnywhere_ItemLink"

---Whether an arbitrary link can be rendered by the item preview system.
---Only item links are supported: PreviewItemLink is the one public
---preview-by-link entry point (PreviewCollectible is private on console).
---@param link string|nil
---@return boolean
function PreviewUtils.CanPreviewItemLink(link)
    if not link or link == "" then
        return false
    end
    return GetLinkType(link) == ITEM_LINK_TYPE and CanItemLinkBePreviewed(link)
end

PreviewAnywhere.PreviewUtils = PreviewUtils
