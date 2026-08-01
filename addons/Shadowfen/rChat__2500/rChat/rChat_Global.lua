-- This is always the first source file loaded so that
-- it can create the addon table/namespace.

-- It also loads strings for the proper language.


local SF = LibSFUtils

rChat = {
    name = "rChat",
    version = SF.colors.gold:Colorize("2.0.5"),
    settingName = "rChat",
    settingDisplayName = SF.colors.gold:Colorize("rChat"),
    author =  SF.colors.purple:Colorize("Shadowfen"),
    savedvar = "RCHAT_OPTS",
    sv_version = 2,
    evtmgr = SF.EvtMgr:New("rChat"),
    hookmgr = SF.HookManager:New("rChat"),
}

rChat_Logger = SF.SafeLoggerFunction(rChat, "logger", "rChat")

SF.LoadLanguage(rChat_localization_strings, "en")

rChat.data = {
    cachedMessages = {}, -- This must be init before OnAddonLoaded because it will receive data before this event.
}

rChat_Logger = SF.SafeLoggerFunction(rChat, "logger", "rChat")

--[[
    The following SetDebug() call is commented out because it severely slows down 
    addon operation. Turning it on does however provide lots and lots of debug logging.
    Never leave this uncommented when releasing!!
--]]
--rChat_Logger():SetDebug(true)

-- convenience function for a call to rChat_Logger():Debug(SF.str(...))
-- only done for Debug() because there is no special handling for the other message levels
-- always returns nil
function rChat.logDebug(...)
    local n = select("#", ...)
    if n == 0 then return end

    local logger = rChat_Logger()
    -- skip parameter processing if they are not going to be used.
    if not logger.enabled or not logger.SFenableDebug then return end

    if n == 1 then
        logger:Debug(...)

    else
        logger:Debug(SF.str(...))
   end
end
