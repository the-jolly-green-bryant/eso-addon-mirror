LibTextFormat = LibTextFormat or {}
local LTF = LibTextFormat

LTF.Core = LTF.Core or { ["v1"] = {} }

LTF.Core["v1"]["item"] = function(ctx, text)
    text = text or ""
    local itemId = ctx.scope:Get("itemId")
    if not itemId then return "" end
    local style = ctx.scope:Get("style") or LINK_STYLE_DEFAULT
    if style == "bracket" then
      style = LINK_STYLE_BRACKETS
    end
    local link = GetItemLink(itemId, style) or ""
    return link
end
