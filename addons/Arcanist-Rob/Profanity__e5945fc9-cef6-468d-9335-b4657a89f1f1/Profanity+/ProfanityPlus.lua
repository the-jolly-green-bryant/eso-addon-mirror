BunnyFilter = {}
BunnyFilter.name = "BunnyFilter"

local replacements = {
    ["fuck"]  = "bunnies",
    ["shit"]  = "kittens",
    ["whore"] = "puppies",
}

local function ReplaceWord(text, word, replacement)
    -- Whole word
    text = text:gsub("%f[%a]" .. word .. "%f[%A]", replacement)

    -- Common variations
    text = text:gsub("%f[%a]" .. word .. "ing%f[%A]", replacement)
    text = text:gsub("%f[%a]" .. word .. "ed%f[%A]", replacement)
    text = text:gsub("%f[%a]" .. word .. "er%f[%A]", replacement)
    text = text:gsub("%f[%a]" .. word .. "ers%f[%A]", replacement)
    text = text:gsub("%f[%a]" .. word .. "s%f[%A]", replacement)

    return text
end

local function FilterMessage(message)
    local filtered = message:lower()

    for word, replacement in pairs(replacements) do
        filtered = ReplaceWord(filtered, word, replacement)
    end

    return filtered
end

local originalFormatAndAddChatMessage = CHAT_ROUTER.FormatAndAddChatMessage

CHAT_ROUTER.FormatAndAddChatMessage = function(self,
    channelType,
    fromName,
    text,
    ...)

    if text and type(text) == "string" then
        text = FilterMessage(text)
    end

    return originalFormatAndAddChatMessage(
        self,
        channelType,
        fromName,
        text,
        ...
    )
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= BunnyFilter.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        BunnyFilter.name,
        EVENT_ADD_ON_LOADED
    )

    d("|c88FF88BunnyFilter loaded!|r")
end

EVENT_MANAGER:RegisterForEvent(
    BunnyFilter.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)