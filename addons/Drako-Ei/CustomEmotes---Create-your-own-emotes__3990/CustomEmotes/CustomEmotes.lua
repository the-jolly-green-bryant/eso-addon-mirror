CustomEmotes = {
    name = "CustomEmotes",
    version = "1.1.2",
    author = "@Drako-Ei",
    description = "An addon to mix emotes into a single emote",
    storageName = "CustomEmotesVariables",
    storageVersion = 1,
    menuCommand = "/custom-emotes-settings",
    maxEmotesPerFrame = 100, -- Max seems to be 120
    timeFrameForEmotes = 60000, -- 1 minute
    internal = {},
    actions = {
        PLAY = 1,
        WAIT = 2,
        JUMP = 3,
        JUMP_FIRST = 4,
        REPEAT_FROM = 5,
        INTERRUPT = 6,
        PERSONALITY = 7,
        EMPTY_LINE = 90,-- EDITOR ACTION
        MOVE_UP = 96,   -- EDITOR ACTION
        MOVE_DOWN = 97, -- EDITOR ACTION
        DUPLICATE = 98, -- EDITOR ACTION
        DELETE = 99     -- EDITOR ACTION
    },
    menuName = "Custom Emotes Settings",
    savedVars = {},
    defaultVars = {
        emotes = {},
        command = "/ce",
        overrideCommands = true,
        validatesLogic = true,
        preloadDefaultEmotes = true,
        preventServerKick = true
    }
}

local CE = CustomEmotes
local internal = CE.internal

function internal.restoreDefaultVars()
    CE.savedVars.emotes = {}
    CE.savedVars.command = CE.defaultVars.command
    CE.savedVars.overrideCommands = CE.defaultVars.overrideCommands
    CE.savedVars.validatesLogic = CE.defaultVars.validatesLogic
    CE.savedVars.preloadDefaultEmotes = CE.defaultVars.preloadDefaultEmotes
end

function internal.initializeAddon()

    -- Print all vars that get sent to this func
    CE.savedVars = ZO_SavedVars:NewAccountWide(CE.storageName, CE.storageVersion, nil, CE.defaultVars)

    -- Preload default emotes
    if CE.savedVars.preloadDefaultEmotes then
        -- Devault variables insert missing keys, so we use the flag to insert them directly
        for _, emote in pairs(CustomEmotesDefaultEmotes) do
            CE.savedVars.emotes[emote.name] = internal.deepCopy(emote)
        end
    end

    -- Turn off preload default emotes
    CE.savedVars.preloadDefaultEmotes = false

    -- Avoids bad commands
    if string.sub(CE.savedVars.command, 1, 1) ~= "/" then
        CE.savedVars.command = "/" .. CE.savedVars.command
    end

    -- Avoids making the command an infinite loop
    if CE.savedVars.command == CE.menuCommand then
        CE.savedVars.command = "/ce"
    end

    -- Registers the emotes as commands
    for emoteName, _ in pairs(CE.savedVars.emotes) do
        internal.registerEmoteCommand(emoteName)
    end

end

-- Saves an emote and registers command for it
function internal.saveEmote(emote)

    CE.savedVars.emotes[emote.name] = emote
    internal.registerEmoteCommand(emote.name)

end