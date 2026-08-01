-- CharacterMarkdown - Final Initialization

local CM = CharacterMarkdown

-- Validate all required modules
local validationResults = {
    core = (CM ~= nil),
    utils = (CM.utils ~= nil),
    links = (CM.links ~= nil),
    collectors = (CM.collectors ~= nil),
    generators = (CM.generators ~= nil),
    commands = (CM.commands ~= nil),
    events = (CM.events ~= nil),
    settings = (CM.Settings ~= nil),
}

local allValid = true
for module, isValid in pairs(validationResults) do
    if not isValid then
        CM.Error(string.format("Module '%s' failed to load!", module))
        allValid = false
    end
end

if not allValid then
    CM.Error("Addon initialization incomplete! Some modules failed to load.")
    CM.Error("Try /reloadui to restart the addon.")
    return
end

-- Validate critical functions
local criticalFunctions = {
    { name = "CommandHandler", ref = CM.commands.CommandHandler },
    { name = "GenerateMarkdown", ref = CM.generators.GenerateMarkdown },
    { name = "CollectCharacterData", ref = CM.collectors.CollectCharacterData },
}

for _, func in ipairs(criticalFunctions) do
    if not func.ref or type(func.ref) ~= "function" then
        CM.Error(string.format("Critical function '%s' not available!", func.name))
        allValid = false
    end
end

if not allValid then
    CM.Error("Critical functions missing! Addon may not work correctly.")
    return
end

-- Validate slash command registered (LibSlashCommander registers without SLASH_COMMANDS entry)
local slashCommandRegistered = SLASH_COMMANDS["/markdown"] ~= nil
local libSlashCommanderAvailable = LibSlashCommander ~= nil
if not slashCommandRegistered and not libSlashCommanderAvailable then
    CM.Error("/markdown command not registered!")
    allValid = false
end

if allValid then
    CM.Success("CharacterMarkdown v" .. CM.version .. " loaded successfully")
    CM.Success("Type /markdown to generate a character profile")

    -- Check for optional dependencies and inform user
    if not LibDebugLogger then
        CM.Info(
            "|cFFFF00[CharacterMarkdown] INFO:|r LibDebugLogger not installed - diagnostic logging will show in chat instead"
        )
        CM.Info("|cFFFF00[CharacterMarkdown] INFO:|r For cleaner chat, install LibDebugLogger from ESOUI.com")
    end

    if not LibSlashCommander then
        CM.Info("|cFFFF00[CharacterMarkdown] INFO:|r LibSlashCommander not installed - basic command handling enabled")
        CM.Info(
            "|cFFFF00[CharacterMarkdown] INFO:|r For auto-completion and better help, install LibSlashCommander from ESOUI.com"
        )
    end
else
    CM.Error("Initialization completed with errors")
end
