local ADDON_NAME = "HelloWorld"

local function HelloWorldCommand()
    local characterName = zo_strformat("<<1>>", GetUnitName("player"))
    d(string.format("Hello, %s. How are you? I hope you are fine, yes? That's nice!", characterName))
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/helloWorld"] = HelloWorldCommand
    SLASH_COMMANDS["/helloworld"] = HelloWorldCommand

    d("HelloWorld loaded. Type /helloWorld")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
