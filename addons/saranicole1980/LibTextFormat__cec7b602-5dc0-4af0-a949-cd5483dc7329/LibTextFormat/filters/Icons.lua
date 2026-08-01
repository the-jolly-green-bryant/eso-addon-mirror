LibTextFormat = LibTextFormat or {}
local LTF = LibTextFormat

LTF.Core = LTF.Core or { ["v1"] = {} }

LTF.Core["v1"]["icon"] = function(ctx, text)
  text = text or ""
  local link = ctx.scope:Get("link")
  local width = ctx.scope:Get("width")
  local height = ctx.scope:Get("height") or width or 16
  return text..zo_iconFormat(link, width, height)
end
