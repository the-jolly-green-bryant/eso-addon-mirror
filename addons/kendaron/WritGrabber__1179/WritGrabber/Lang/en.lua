
WritGrabberLanguage = {}

local function wgl(obj)
  WritGrabberLanguage.language[#WritGrabberLanguage.language + 1] = obj
  return #WritGrabberLanguage.language
end


WritGrabberLanguage.language = {
  
}

WGL_WRITGRABBER_NAME = wgl("WritGrabber")
WGL_WRITGRABBER_TITLE = wgl("Writ Grabber")

WGL_CHAT_OPTION_TOGGLE = wgl("toggle")
WGL_CHAT_OPTION_SHOW = wgl("show")
WGL_CHAT_OPTION_HIDE = wgl("hide")

WGL_BUTTON_TOOLTIP_RELOAD = wgl("Refresh recipes and ingredients")
WGL_BUTTON_TOOLTIP_CLOSE = wgl("Close")
WGL_BUTTON_TOOLTIP_EXPAND = wgl("Expand")
WGL_BUTTON_TOOLTIP_SHRINK = wgl("Shrink")
WGL_BUTTON_TOOLTIP_COLLAPSE = wgl("Collapse")


WGL_QUEST_ALCHEMIST_WRIT_TITLE = wgl("Alchemist Writ")
WGL_QUEST_ENCHANTER_WRIT_TITLE = wgl("Enchanter Writ")

WGL_NOTIFY_WRIT_ALCHEMY_ADDED = wgl("%s: Added alchemy item %s")
WGL_NOTIFY_WRIT_ENCHANTING_ADDED = wgl("%s: Added enchanting %s")

WGL_NOTIFY_ITEM_COLLECTED = wgl("%s: Collected %s")
WGL_NOTIFY_ITEM_NOT_COLLECTED = wgl("%s: Unable to collect %s")
