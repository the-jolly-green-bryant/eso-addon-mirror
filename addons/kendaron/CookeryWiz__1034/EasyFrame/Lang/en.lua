EasyFrameLanguage = {}

local function l(obj)
  EasyFrameLanguage.language[#EasyFrameLanguage.language + 1] = obj
  return #EasyFrameLanguage.language
end


EasyFrameLanguage.language = {
  
}


EASYFRAME_TEXTURE_MINIBAR_ICON_TOOLTIP = l("Toggle %s")
EASYFRAME_TEXTURE_MINIBAR_ICON_DRAG_TOOLTIP = l("Toggle %s. Drag to move.")