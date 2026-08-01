-- Inspect Vestige by LuckyRome13
-- Settings.lua -- LibAddonMenu-2.0 options panel. LAM is a REQUIRED dependency (see the manifest):
-- it's the only way to reach the privacy toggles, and defaulting to "share" with no way to opt out
-- isn't acceptable. The nil-check below is just belt-and-suspenders in case it fails to load.

local IV = InspectVestige

function IV.SetupSettings()
    local LAM = _G.LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type               = "panel",
        name               = IV.L.TITLE,
        displayName        = "|cFFD700" .. IV.L.TITLE .. "|r",
        author             = IV.author,
        version            = IV.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    IV.settingsPanel = LAM:RegisterAddonPanel("InspectVestigePanel", panelData)

    local options = {
        {
            type = "description",
            text = "Full inspect works only when the other player is in your group and also runs Inspect Vestige (data travels over ESO's group channel). Everyone else shows a basic public card. Self-inspect always works.",
        },
        { type = "header", name = "Privacy" },
        {
            type    = "checkbox",
            name    = "Share my loadout when asked",
            tooltip = "When a group member running Inspect Vestige inspects you, respond with your build. Turn off to keep your loadout private.",
            getFunc = function() return IV.sv.respondToRequests end,
            setFunc = function(v) IV.sv.respondToRequests = v end,
            default = true,
        },
        {
            type    = "checkbox",
            name    = "Share with friends only",
            tooltip = "Only share your loadout with group members on your friends list. Anyone else who inspects you is told you share with friends only. " ..
                      "Note: the group channel physically delivers to everyone in the group, so this marks the message for your friends and other copies of the addon discard it -- it is not encryption.",
            getFunc = function() return IV.sv.friendsOnly end,
            setFunc = function(v) IV.sv.friendsOnly = v end,
            disabled = function() return IV.sv.respondToRequests == false end,
            default = false,
        },
        {
            type    = "checkbox",
            name    = "Pre-share so inspects are instant",
            tooltip = "Automatically send your loadout to group members running the addon (only when at least one is present) so they can inspect you instantly. " ..
                      "Turn off to conserve the shared group channel -- you'll still be inspectable, but the first inspect of you takes a few seconds. Requests you make of others are unaffected either way.",
            getFunc = function() return IV.sv.proactiveShare end,
            setFunc = function(v) IV.sv.proactiveShare = v end,
            disabled = function() return IV.sv.respondToRequests == false end,
            default = true,
        },
        { type = "header", name = "Interface" },
        {
            type         = "checkbox",
            name         = "Add option to the interact wheel",
            tooltip      = "Inject an 'Inspect Vestige' entry into the hold-interact radial. Uses internal game hooks; if a patch breaks it, the keybind still works. Requires a UI reload.",
            getFunc      = function() return IV.sv.wheelInject end,
            setFunc      = function(v) IV.sv.wheelInject = v end,
            default      = true,
            requiresReload = true,
        },
        { type = "header", name = "Cache" },
        {
            type    = "button",
            name    = "Clear cached loadouts",
            tooltip = "Forget every loadout previously received from other players (this server).",
            func    = function()
                if IV.cache then IV.cache.entries = {} end
                IV.Msg("cache cleared.")
            end,
        },
        { type = "header", name = "Advanced" },
        {
            type    = "checkbox",
            name    = "Debug logging",
            tooltip = "Print diagnostic messages to chat (peer sync, menu registration, wheel hook).",
            getFunc = function() return IV.sv.debug end,
            setFunc = function(v) IV.sv.debug = v end,
            default = false,
        },
    }
    LAM:RegisterOptionControls("InspectVestigePanel", options)
end
