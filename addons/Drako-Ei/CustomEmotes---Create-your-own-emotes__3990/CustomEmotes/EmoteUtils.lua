-- Shortcuts
local CE = CustomEmotes
local LAM = LibAddonMenu2
local internal = CE.internal
local actions = CE.actions
local CONS = internal.constants

internal.emoteList = {}
internal.personalityList = {}

-- Initializes the utils
function internal.initializeUtils()
    local max = GetNumEmotes()
	for i = 1, max do
        local slashName, categoryId, id, displayName = GetEmoteInfo(i)
        if slashName and slashName ~= "" then
            local collectibleId = GetEmoteCollectibleId(i)
            local unlocked = (collectibleId == nil) or IsCollectibleUnlocked(collectibleId)
            internal.emoteList[slashName] = {
                categoryId = categoryId,
                collectibleId = collectibleId,
                slashName = slashName,
                id = id,
                index = i,
                displayName = displayName,
                unlocked = unlocked
            }
        end
	end

    -- No personality option
    internal.personalityList[0] = {
        collectibleId = 0,
        name = CONS.NO_PERSONALITY,
        index = 0
    }

    local personalityIndex = 1
    while true do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, personalityIndex)
        if not collectibleId or collectibleId < 1 then break end
        if IsCollectibleUnlocked(collectibleId) then
            internal.personalityList[collectibleId] = {
                collectibleId = collectibleId,
                name = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(collectibleId)),
                index = personalityIndex
            }
        end
        personalityIndex = personalityIndex + 1
    end

end

function internal.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function internal.deepCopy(original)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        
        local new_table = {}
        lookup_table[obj] = new_table
        for key, value in pairs(obj) do
            new_table[_copy(key)] = _copy(value)
        end
        return new_table
    end
    return _copy(original)
end

-- Hack to stop current emote
function internal.interruptEmote(strength, callback)

    -- Save and set the UI volume to 0
    local currentUIVolume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, "0")

    -- Change the callback to restore the volume
    local newCallback = function()
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, currentUIVolume)
        if callback then callback() end
    end

    internal.inventoryEmoteInterruptHack(strength, newCallback)
    
end

-- Opens the inventory after a delay, closes after a delay and executes callback
function internal.inventoryEmoteInterruptHack(msInvOpened, callback)

    SCENE_MANAGER:Show("stats")
    zo_callLater(function()
        SCENE_MANAGER:Hide("stats")
        if callback then callback() end
    end, msInvOpened)

end

function internal.getValidatedEmoteName(name)
    local result = string.lower(string.gsub(name, "%s+", ""))
    if string.sub(result, 1, 1) ~= "/" then
        result = "/" .. result
    end
    return result
end

function internal.getEmoteByName(name)
    return internal.emoteList[internal.getValidatedEmoteName(name)]
end

function internal.isEmoteUnlocked(name)
    return internal.emoteList[internal.getValidatedEmoteName(name)].unlocked
end

