local skillExp = {}
SkillExp = skillExp

local components = SkillExpComponents

ZO_CreateStringId("SI_BINDING_NAME_SKILLEXP_HOTKEY", "Toggle SkillExp")

-- ─────────────────────────────────────────────────────────────────────────────
-- Initialization
-- ─────────────────────────────────────────────────────────────────────────────
local function initialize(eventType, addonName)
    if addonName ~= "SkillExp" then return end

    CALLBACK_MANAGER:FireCallbacks("OnSkillExpInitializing")

    local fragment = ZO_SimpleSceneFragment:New(SkillExpContainer)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)

    CALLBACK_MANAGER:FireCallbacks("OnSkillExpInitialized")
end

local function onPlayerActivated(eventCode, initial)
    EVENT_MANAGER:UnregisterForEvent("SkillExp", EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent("SkillExp", EVENT_ADD_ON_LOADED, initialize)
EVENT_MANAGER:RegisterForEvent("SkillExp", EVENT_PLAYER_ACTIVATED, onPlayerActivated)

-- ─────────────────────────────────────────────────────────────────────────────
-- Hotkey
-- ─────────────────────────────────────────────────────────────────────────────
local hotkeyDebouncer = components.Debouncer:New(function(count)
    if count == 1 then
        SkillExp_ToggleSkillsForm()
    elseif count == 2 then
        SkillExp_ToggleSettings()
    end
end)

function SkillExp_Hotkey()
    hotkeyDebouncer:Invoke()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Slash commands
-- ─────────────────────────────────────────────────────────────────────────────
local function slashCommands(args)
    if args == "config" then
        SkillExp_ToggleSettings()
    else
        SkillExp_ToggleSkillsForm()
    end
    CALLBACK_MANAGER:FireCallbacks("OnSkillExpSlashCommand")
end

SLASH_COMMANDS["/skillexp"] = slashCommands
