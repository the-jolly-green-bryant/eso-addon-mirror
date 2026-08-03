--------------------------------------------------------------
-- VCAP2 : Voice Chat Announcer Plus (Narration Filter)
-- Author: SugaComa (Rik Sprint)
-- Version: 2.2.0-test5 ("Main Menu Reopen Flow Test")
-- Console-safe (no XML). PS5/Xbox narration filter + automatic addon tag discovery
--------------------------------------------------------------
--------------------------------------------------------------
-- Core init + helpers
--------------------------------------------------------------
local ADDON = "VCAP2"
VCAP2 = VCAP2 or {}
local VCA = VCAP2
local EM = EVENT_MANAGER
_G["VCAP2"] = VCAP2 -- global for other addons
--------------------------------------------------------------
-- Re-entrancy / recursion guards
--------------------------------------------------------------
VCA._inDebug = false
VCA._inHook = false
--------------------------------------------------------------
-- Debug (loop-safe)
--------------------------------------------------------------
local function Debug(msg)
    if not (VCA.SV and VCA.SV.debug) then return end
    if VCA._inDebug then return end
    VCA._inDebug = true
    d("[VCAP2] " .. tostring(msg))
    VCA._inDebug = false
end
VCA.Debug = Debug
--------------------------------------------------------------
-- TouchSV
--------------------------------------------------------------
local function TouchSV()
    if VCA.SV then
        VCA.SV._dirtyTick = (VCA.SV._dirtyTick or 0) + 1
    end
end
VCA.TouchSV = TouchSV
--------------------------------------------------------------
-- Utilities
--------------------------------------------------------------
local function PrintOnce()
    if VCA._printed then return end
    VCA._printed = true
    d("|c92B0D9VCAP2|r 2.2.0-test5 loaded - automatic addon tag discovery active.")
end

-- Case-normalization helper (console-safe)
local function NormalizeTag(t)
    return t and tostring(t):lower() or nil
end

-- Player name cleanup for narration (strip special chars)
local function CleanName(name)
    if not name then return nil end
    local s = tostring(name)
    s = s:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("^@", "")
    s = s:gsub("[^%w]+", " ")
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" then return nil end
    local tokens = {}
    for part in s:gmatch("%S+") do
        table.insert(tokens, part)
    end
    if #tokens == 0 then return nil end
    local allSingle = true
    for i = 1, #tokens do
        if #tokens[i] ~= 1 then
            allSingle = false
            break
        end
    end
    if allSingle then
        return table.concat(tokens, "")
    end
    return table.concat(tokens, "")
end

local function SanitizeNarrationNames(chatMessage)
    if type(chatMessage) ~= "table" then return end
    local rawText = chatMessage.text or chatMessage.message
    if type(rawText) ~= "string" then return end
    local from = chatMessage.from
    if not from then from = chatMessage.fromDisplayName end
    if not from then from = chatMessage.fromName end
    if not from then from = chatMessage.sender end
    if not from then from = chatMessage.rawFrom end
    if not from then from = chatMessage.owner end
    if not from then return end
    local clean = CleanName(from)
    if not clean then return end
    if clean == from then return end
    chatMessage.text = rawText:gsub(from, clean)
end

--------------------------------------------------------------
-- Chat category model
--
-- ESO narrates chat with CHAT_CATEGORY values, not the old
-- hard-coded 1-19 IDs previously used by VCAP2.  We map the
-- current runtime categories into stable logical setting keys.
--------------------------------------------------------------
local CHANNELS = {}
local CATEGORY_TO_KEY = {}

local function RegisterChannel(key, label, defaultOn, channelId)
    CHANNELS[key] = {
        label = label,
        defaultOn = defaultOn,
    }

    if channelId ~= nil and GetChannelCategoryFromChannel then
        local category = GetChannelCategoryFromChannel(channelId)
        if category ~= nil then
            CATEGORY_TO_KEY[category] = key
        end
    end
end

local function BuildChannels()
    CHANNELS = {}
    CATEGORY_TO_KEY = {}

    RegisterChannel("say",         "Say",           true,  CHAT_CHANNEL_SAY)
    RegisterChannel("yell",        "Yell",          true,  CHAT_CHANNEL_YELL)
    RegisterChannel("whisperIn",   "Whisper (In)",  true,  CHAT_CHANNEL_WHISPER)
    RegisterChannel("whisperOut",  "Whisper (Out)", true,  CHAT_CHANNEL_WHISPER_SENT)
    RegisterChannel("zone",        "Zone",          true,  CHAT_CHANNEL_ZONE)
    RegisterChannel("group",       "Group",         true,  CHAT_CHANNEL_PARTY)
    RegisterChannel("emote",       "Emote",         true,  CHAT_CHANNEL_EMOTE)
    RegisterChannel("system",      "ESO System",    true,  CHAT_CHANNEL_SYSTEM)

    RegisterChannel("guild1",      "Guild 1",        true, CHAT_CHANNEL_GUILD_1)
    RegisterChannel("guild2",      "Guild 2",        true, CHAT_CHANNEL_GUILD_2)
    RegisterChannel("guild3",      "Guild 3",        true, CHAT_CHANNEL_GUILD_3)
    RegisterChannel("guild4",      "Guild 4",        true, CHAT_CHANNEL_GUILD_4)
    RegisterChannel("guild5",      "Guild 5",        true, CHAT_CHANNEL_GUILD_5)
    RegisterChannel("officer1",    "Officer 1",      true, CHAT_CHANNEL_OFFICER_1)
    RegisterChannel("officer2",    "Officer 2",      true, CHAT_CHANNEL_OFFICER_2)
    RegisterChannel("officer3",    "Officer 3",      true, CHAT_CHANNEL_OFFICER_3)
    RegisterChannel("officer4",    "Officer 4",      true, CHAT_CHANNEL_OFFICER_4)
    RegisterChannel("officer5",    "Officer 5",      true, CHAT_CHANNEL_OFFICER_5)

    -- Language-specific zone categories are narrated separately by ESO,
    -- but the user should still only need one Zone toggle.
    if ZO_OFFICIAL_LANGUAGE_TO_CHAT_INFO then
        for _, info in pairs(ZO_OFFICIAL_LANGUAGE_TO_CHAT_INFO) do
            if type(info) == "table" and info.category ~= nil then
                CATEGORY_TO_KEY[info.category] = "zone"
            end
        end
    end
end

-- Legacy VCAP2 1-19 setting positions -> new stable logical keys.
-- This is used once to preserve the user's existing narration choices.
local LEGACY_FILTER_TO_KEY = {
    [1] = "say",
    [2] = "yell",
    [3] = "whisperIn",
    [4] = "whisperOut",
    [6] = "zone",
    [7] = "group",
    [8] = "emote",
    [10] = "guild1",
    [11] = "guild2",
    [12] = "guild3",
    [13] = "guild4",
    [14] = "guild5",
    [15] = "officer1",
    [16] = "officer2",
    [17] = "officer3",
    [18] = "officer4",
    [19] = "officer5",
}

local function MigrateFilters()
    VCA.SV.categoryFilter = VCA.SV.categoryFilter or {}

    if not VCA.SV.categoryFilterMigrated then
        local oldFilter = VCA.SV.filter or {}
        for oldId, key in pairs(LEGACY_FILTER_TO_KEY) do
            if VCA.SV.categoryFilter[key] == nil and oldFilter[oldId] ~= nil then
                VCA.SV.categoryFilter[key] = oldFilter[oldId] and true or false
            end
        end
        VCA.SV.categoryFilterMigrated = true
    end

    for key, meta in pairs(CHANNELS) do
        if VCA.SV.categoryFilter[key] == nil then
            VCA.SV.categoryFilter[key] = meta.defaultOn
        end
    end

    -- Preserve existing Channel 9 preferences while moving to the
    -- correctly named addon/local message model. The migration marker is
    -- required because ZO_SavedVars may already have filled the new fields
    -- from DEFAULTS before this function runs.
    if not VCA.SV.addonModelMigrated then
        VCA.SV.addonMessageMode = VCA.SV.channel9Mode or "all"
        VCA.SV.readAddonTags = VCA.SV.readChannel9Tags and true or false
        VCA.SV.addonModelMigrated = true
    end

    -- Test2 opt-in model: every known addon tag starts with narration OFF
    -- unless the user has explicitly enabled it in this build.  We use a
    -- new `narrate` field instead of changing the old `muted` field, so a
    -- downgrade to the user's backup build does not reinterpret these choices.
    VCA.SV.customClients = VCA.SV.customClients or {}
    for _, entry in pairs(VCA.SV.customClients) do
        if entry.narrate == nil then
            entry.narrate = false
        end
    end

    if VCA.SV.untaggedAddonNarration == nil then
        VCA.SV.untaggedAddonNarration = false
    end

    -- Keep the legacy fields mirrored for downgrade compatibility.
    VCA.SV.channel9Mode = VCA.SV.addonMessageMode
    VCA.SV.readChannel9Tags = VCA.SV.readAddonTags
end
--------------------------------------------------------------
-- Addon tag registry
--
-- Tags are auto-discovered from leading [Tag] text on local/addon
-- AddSystemMessage traffic. New tags default to narration OFF.
--------------------------------------------------------------
function VCA:AddCustomClient(tag, displayName)
    if not tag or tag == "" then return end
    local lowerTag = NormalizeTag(tag)
    VCA.SV.customClients = VCA.SV.customClients or {}

    local entry = VCA.SV.customClients[lowerTag] or {}
    entry.original = tag
    entry.name = displayName or entry.name or tag
    if entry.muted == nil then entry.muted = false end -- legacy compatibility
    if entry.narrate == nil then entry.narrate = false end
    if entry.autoDetected == nil then entry.autoDetected = false end
    VCA.SV.customClients[lowerTag] = entry

    TouchSV()
    Debug("Added addon tag [" .. tag .. "] -> narration defaults OFF")
    VCA:_TriggerMenuRebuild()
end

function VCA:EnsureDetectedClient(tag)
    if not tag or tag == "" then return nil, nil end
    local lowerTag = NormalizeTag(tag)
    VCA.SV.customClients = VCA.SV.customClients or {}

    local entry = VCA.SV.customClients[lowerTag]
    if not entry then
        entry = {
            original = tag,
            name = tag,
            muted = false, -- legacy compatibility only
            narrate = false,
            autoDetected = true,
        }
        VCA.SV.customClients[lowerTag] = entry
        TouchSV()
        Debug("Auto-detected addon tag [" .. tag .. "] - narration OFF until enabled.")
        VCA:_TriggerMenuRebuild()
    elseif entry.narrate == nil then
        entry.narrate = false
        TouchSV()
    end

    return lowerTag, entry
end

function VCA:RemoveCustomClient(tag)
    local lowerTag = NormalizeTag(tag)
    if not (VCA.SV and VCA.SV.customClients and VCA.SV.customClients[lowerTag]) then return end
    VCA.SV.customClients[lowerTag] = nil
    TouchSV()
    Debug("Removed addon tag [" .. tostring(tag) .. "]")
    VCA:_TriggerMenuRebuild()
end

-- Legacy API retained for compatibility with older integrations.
function VCA:SetCustomClientMuted(tag, muted)
    local lowerTag = NormalizeTag(tag)
    if not (VCA.SV and VCA.SV.customClients and VCA.SV.customClients[lowerTag]) then return end
    VCA.SV.customClients[lowerTag].muted = muted and true or false
    TouchSV()
end

function VCA:SetCustomClientNarrate(tag, narrate)
    local lowerTag = NormalizeTag(tag)
    if not (VCA.SV and VCA.SV.customClients and VCA.SV.customClients[lowerTag]) then return end
    VCA.SV.customClients[lowerTag].narrate = narrate and true or false
    TouchSV()
end
--------------------------------------------------------------
-- Narration filtering
--
-- CHAT_ROUTER identifies how a message entered chat. AddSystemMessage is
-- the path commonly used by addons and local UI code. VCAP2 auto-discovers
-- a leading [Tag] on that path and uses it as the addon narration identity.
-- Untagged local/addon messages remain anonymous and default to silent.
--------------------------------------------------------------
local function GetNarrationText(chatMessage)
    if type(chatMessage) == "table" then
        return tostring(chatMessage.text or chatMessage.message or "")
    end
    return tostring(chatMessage or "")
end

local function GetPlainNarrationText(rawText)
    return tostring(rawText or "")
        :gsub("|c%x%x%x%x%x%x", "")
        :gsub("|r", "")
        :gsub("%s+", " ")
end

local function GetLeadingTag(plainText)
    local tag = plainText:match("^%s*%[([^%]]+)%]")
    if not tag then return nil, nil, nil end

    local normalized = NormalizeTag(tag)
    local registry = (VCA.SV and VCA.SV.customClients) or {}
    return tag, normalized, registry[normalized]
end

local function StripLeadingTag(plainText)
    return plainText:gsub("^%s*%[[^%]]+%]%s*", "", 1)
end

local function FilterNarration(chatMessage, category, routerSource)
    if not VCA.SV or not VCA.SV.enabled then
        return false, chatMessage
    end

    local rawText = GetNarrationText(chatMessage)
    local plainText = GetPlainNarrationText(rawText)

    -- Never narrate VCAP2's own debug/status chatter.
    if plainText:find("%[VCAP2%]") then
        return true, chatMessage
    end

    local rawTag, normalizedTag, tagEntry = GetLeadingTag(plainText)
    local isInjectedSystemMessage = (routerSource == "AddSystemMessage")
    local systemCategory = GetChannelCategoryFromChannel and GetChannelCategoryFromChannel(CHAT_CHANNEL_SYSTEM)

    -- Auto-discover tags only from the local/system injection path. This
    -- avoids treating ordinary player chat that happens to begin with
    -- square brackets as an addon identity.
    if isInjectedSystemMessage and rawTag and not tagEntry then
        normalizedTag, tagEntry = VCA:EnsureDetectedClient(rawTag)
    end

    if isInjectedSystemMessage then
        if tagEntry then
            -- Opt-in model: a detected/registered addon is silent until the
            -- user explicitly enables narration for that tag.
            if not tagEntry.narrate then
                return true, chatMessage
            end

            -- The chat line itself is never modified. This replacement is
            -- passed only to SCREEN_NARRATION_MANAGER.
            if not VCA.SV.readAddonTags then
                return false, StripLeadingTag(plainText)
            end
        else
            -- Anonymous local/addon messages cannot be controlled
            -- individually. Keep them silent by default, with one explicit
            -- escape-hatch setting for users who need them narrated.
            if not VCA.SV.untaggedAddonNarration then
                return true, chatMessage
            end
        end
    elseif tagEntry and category == systemCategory then
        -- Compatibility path for already-known tags that reach narration as
        -- system-category text without passing through AddSystemMessage.
        if not tagEntry.narrate then
            return true, chatMessage
        end
        if not VCA.SV.readAddonTags then
            return false, StripLeadingTag(plainText)
        end
    end

    local key = CATEGORY_TO_KEY[category]
    if key and VCA.SV.categoryFilter and VCA.SV.categoryFilter[key] == false then
        return true, chatMessage
    end

    return false, chatMessage
end

--------------------------------------------------------------
-- Chat router source hook
--
-- The source marker exists only during CHAT_ROUTER's synchronous callback
-- chain, which is when the gamepad chat container requests narration.
--------------------------------------------------------------
local BASE_FormatAndAddChatMessage
function VCA:HookChatRouter()
    if BASE_FormatAndAddChatMessage then return end
    if not CHAT_ROUTER or not CHAT_ROUTER.FormatAndAddChatMessage then
        Debug("CHAT_ROUTER missing - source hook skipped.")
        return
    end

    BASE_FormatAndAddChatMessage = CHAT_ROUTER.FormatAndAddChatMessage
    CHAT_ROUTER.FormatAndAddChatMessage = function(router, eventKey, ...)
        local previousSource = VCA._routerSource
        VCA._routerSource = eventKey
        BASE_FormatAndAddChatMessage(router, eventKey, ...)
        VCA._routerSource = previousSource
    end

    Debug("Chat router source hook installed.")
end
--------------------------------------------------------------
-- Narration Hook (loop-safe)
--------------------------------------------------------------
local BASE_NarrateChatMessage
function VCA:HookNarration()
    if BASE_NarrateChatMessage then return end
    if not SCREEN_NARRATION_MANAGER then
        Debug("SCREEN_NARRATION_MANAGER missing - hook skipped.")
        return
    end

    BASE_NarrateChatMessage = SCREEN_NARRATION_MANAGER.NarrateChatMessage
    SCREEN_NARRATION_MANAGER.NarrateChatMessage = function(manager, chatMessage, category)
        if VCA._inHook then
            return BASE_NarrateChatMessage(manager, chatMessage, category)
        end

        VCA._inHook = true
        local block, narrationMessage = FilterNarration(chatMessage, category, VCA._routerSource)

        if not block then
            -- Retain the old table sanitiser for compatibility with any
            -- third-party caller that still passes a structured message.
            SanitizeNarrationNames(narrationMessage)
            BASE_NarrateChatMessage(manager, narrationMessage, category)
        end

        VCA._inHook = false
    end

    Debug("Narration hook installed.")
end
--------------------------------------------------------------
-- DYNAMIC MENU REBUILD SYSTEM
--------------------------------------------------------------
VCA._menuRebuildPending = false
function VCA:_TriggerMenuRebuild()
    if VCA._menuRebuildPending then return end
    VCA._menuRebuildPending = true
    zo_callLater(function()
        VCA._menuRebuildPending = false
        if VCA.menu and VCA.menu.RefreshSettings then
            VCA.menu:RefreshSettings()
        end
    end, 300)
end
-- Rebuild the dynamic addon-tag section.
-- This section is deliberately kept LAST in the menu, so removing from its
-- header to the end cannot delete Debugging or normal chat controls.
function VCA:_RebuildAddonTagsSection(menu)
    local LHA = LibHarvensAddonSettings
    if not LHA then return end

    local hasSettingsTable = (menu and menu.settings and type(menu.settings) == "table")
    if hasSettingsTable then
        local startIdx
        for i, setting in ipairs(menu.settings) do
            if setting.type == LHA.ST_SECTION and setting.label == "Detected Addon Tags" then
                startIdx = i
                break
            end
        end

        if startIdx then
            for i = #menu.settings, startIdx, -1 do
                table.remove(menu.settings, i)
            end
        end
    end

    menu:AddSetting({ type = LHA.ST_SECTION, label = "Detected Addon Tags" })
    menu:AddSetting({
        type = LHA.ST_LABEL,
        label = "New addon tags are detected and saved immediately. A newly found tag may not appear in this list until you reload the UI or log out and back in.",
        tooltip = "VCAP2 stores a newly detected [AddonTag] as soon as it sees it. If the tag is not visible below yet, reload the UI to rebuild this settings list. The tag will remain saved and will default to narration OFF.",
    })
    menu:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Refresh Detected Addon Tags",
        tooltip = "Reloads the ESO user interface now so newly detected addon tags appear in this settings list. On gamepad, highlight this option and press X to reload.",
        buttonText = "Reload UI Now",
        clickHandler = function()
            if ReloadUI then
                -- Persist a one-shot reopen request across /reloadui.
                -- It is cleared after success or after the final retry, so a
                -- failed reopen can never trap the player in a loop.
                VCA.SV.reopenSettingsAfterReload = true
                TouchSV()
                ReloadUI("ingame")
            else
                d("[VCAP2] ReloadUI is unavailable. Please type /reloadui in chat.")
            end
        end,
    })

    local registry = VCA.SV.customClients or {}
    local tags = {}
    for lowerTag, entry in pairs(registry) do
        table.insert(tags, { lower = lowerTag, entry = entry })
    end

    table.sort(tags, function(a, b)
        return tostring(a.entry.original):lower() < tostring(b.entry.original):lower()
    end)

    if #tags == 0 then
        menu:AddSetting({
            type = LHA.ST_LABEL,
            label = "No addon tags detected yet. New [Tags] will appear automatically with narration OFF.",
        })
    else
        menu:AddSetting({
            type = LHA.ST_LABEL,
            label = string.format("%d addon tag(s) detected/registered:", #tags),
        })

        for _, item in ipairs(tags) do
            local entry = item.entry
            local tag = entry.original
            local display = entry.name or tag
            local tagKey = item.lower
            menu:AddSetting({
                type = LHA.ST_CHECKBOX,
                label = string.format("[%s] %s", tag, display),
                tooltip = "ON: narrate messages from this tagged addon. New tags default OFF.",
                getFunction = function()
                    local current = VCA.SV.customClients[tagKey]
                    return current and current.narrate == true or false
                end,
                setFunction = function(v)
                    VCA:SetCustomClientNarrate(tagKey, v)
                end,
            })
        end
    end

    menu:AddSetting({
        type = LHA.ST_LABEL,
        label = "Tags remain visible in chat. VCAP2 only filters narration. Untagged local/addon messages are controlled by the master option above.",
    })
    menu:AddSetting({
        type = LHA.ST_EDIT,
        label = "New Tag",
        tooltip = "Optional manual fallback. Example: [Combat Alerts] or Combat Alerts. Manually added tags also start with narration OFF.",
        getFunction = function() return VCA._tagDraft or "" end,
        setFunction = function(value) VCA._tagDraft = value end,
    })
    menu:AddSetting({
        type = LHA.ST_EDIT,
        label = "Display Name (optional)",
        tooltip = "Optional label shown in the list.",
        getFunction = function() return VCA._nameDraft or "" end,
        setFunction = function(value) VCA._nameDraft = value end,
    })
    menu:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Add Tag",
        buttonText = "Add",
        clickHandler = function()
            local raw = tostring(VCA._tagDraft or "")
            local tag = raw:gsub("^%s*%[", ""):gsub("%]%s*$", "")
            tag = tag:gsub("^%s+", ""):gsub("%s+$", "")
            if tag == "" then
                d("[VCAP2] Enter a tag first.")
                return
            end

            local name = tostring(VCA._nameDraft or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if name == "" then name = tag end

            VCA:AddCustomClient(tag, name)
            VCA._tagDraft = ""
            VCA._nameDraft = ""
        end,
    })
    menu:AddSetting({
        type = LHA.ST_EDIT,
        label = "Remove Tag",
        tooltip = "Enter tag text to remove (brackets optional).",
        getFunction = function() return VCA._removeDraft or "" end,
        setFunction = function(value) VCA._removeDraft = value end,
    })
    menu:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Remove Tag",
        buttonText = "Remove",
        clickHandler = function()
            local raw = tostring(VCA._removeDraft or "")
            local tag = raw:gsub("^%s*%[", ""):gsub("%]%s*$", "")
            tag = tag:gsub("^%s+", ""):gsub("%s+$", "")
            if tag == "" then
                d("[VCAP2] Enter a tag to remove.")
                return
            end

            VCA:RemoveCustomClient(tag)
            VCA._removeDraft = ""
        end,
    })

    Debug(string.format("Addon tag section rebuilt (%d tag(s)).", #tags))
end

-- Backward-compatible internal alias for older VCAP2 integrations.
VCA._RebuildChannel9Section = VCA._RebuildAddonTagsSection
--------------------------------------------------------------
-- MENU (Harven Settings Panel)
--------------------------------------------------------------
-- Main menu creation
local function CreateVCAPMenu()
    local LHA = LibHarvensAddonSettings
    if not LHA then
        Debug("LibHarvensAddonSettings not loaded - menu skipped.")
        return
    end

    local menu = LHA:AddAddon("VCAP2", {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            VCA.SV.enabled = true
            VCA.SV.debug = false
            VCA.SV.addonMessageMode = "registered"
            VCA.SV.channel9Mode = "all"
            VCA.SV.readAddonTags = false
            VCA.SV.readChannel9Tags = false
            VCA.SV.untaggedAddonNarration = false
            VCA.SV.categoryFilter = {}

            for key, meta in pairs(CHANNELS) do
                VCA.SV.categoryFilter[key] = meta.defaultOn
            end

            TouchSV()
        end,
    })
    if not menu then return end

    VCA.menu = menu

    ----------------------------------------------------------
    -- Core Settings
    ----------------------------------------------------------
    menu:AddSetting({ type = LHA.ST_SECTION, label = "Core Settings" })
    menu:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Enable VCAP2 Filtering",
        tooltip = "Turn narration filtering on or off globally.",
        getFunction = function() return VCA.SV.enabled end,
        setFunction = function(v)
            VCA.SV.enabled = v
            TouchSV()
        end,
    })

    ----------------------------------------------------------
    -- Addon / local injected messages
    ----------------------------------------------------------
    menu:AddSetting({ type = LHA.ST_SECTION, label = "Addon / Local Messages" })
    menu:AddSetting({
        type = LHA.ST_LABEL,
        label = "Addon narration is opt-in. VCAP2 auto-detects leading [Tags], stores them, and adds an OFF-by-default narration toggle below. Tags always remain visible in chat.",
    })
    menu:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Narrate Untagged Addon / Local Messages",
        tooltip = "OFF (recommended): anonymous local/addon messages are not narrated.\nON: narrate untagged local/system-injected messages even though VCAP2 cannot identify their addon source.",
        getFunction = function()
            return VCA.SV.untaggedAddonNarration and true or false
        end,
        setFunction = function(v)
            VCA.SV.untaggedAddonNarration = v and true or false
            TouchSV()
        end,
    })
    menu:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Read Addon Tags",
        tooltip = "ON: narrator includes the leading [Addon Tag].\nOFF: the tag stays visible in chat but is removed from the spoken narration.",
        getFunction = function()
            return VCA.SV.readAddonTags and true or false
        end,
        setFunction = function(v)
            VCA.SV.readAddonTags = v and true or false
            VCA.SV.readChannel9Tags = VCA.SV.readAddonTags
            TouchSV()
            Debug("Read Addon Tags = " .. tostring(v))
        end,
    })

    ----------------------------------------------------------
    -- Debugging
    ----------------------------------------------------------
    menu:AddSetting({ type = LHA.ST_SECTION, label = "Debugging" })
    menu:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Debug Logging",
        getFunction = function() return VCA.SV.debug end,
        setFunction = function(v)
            VCA.SV.debug = v
            TouchSV()
        end,
    })

    ----------------------------------------------------------
    -- Chat category toggles
    ----------------------------------------------------------
    menu:AddSetting({ type = LHA.ST_SECTION, label = "Chat Narration (ON = voice)" })
    local list = {}
    for key, meta in pairs(CHANNELS) do
        table.insert(list, { key = key, label = meta.label })
    end
    table.sort(list, function(a, b) return a.label < b.label end)

    for _, item in ipairs(list) do
        local settingKey = item.key
        local settingLabel = item.label
        menu:AddSetting({
            type = LHA.ST_CHECKBOX,
            label = settingLabel,
            getFunction = function()
                return VCA.SV.categoryFilter[settingKey]
            end,
            setFunction = function(v)
                VCA.SV.categoryFilter[settingKey] = v and true or false
                TouchSV()
            end,
        })
    end

    ----------------------------------------------------------
    -- Dynamic addon tags MUST remain the final menu section.
    ----------------------------------------------------------
    menu.onRefresh = function()
        VCA:_RebuildAddonTagsSection(menu)
    end
    VCA:_RebuildAddonTagsSection(menu)

    Debug("Harven menu initialized.")
end
--------------------------------------------------------------
-- Safe Loader
--------------------------------------------------------------
local function SafeCreateMenu()
    if LibHarvensAddonSettings then
        local ok, err = pcall(CreateVCAPMenu)
        if not ok then
            Debug("Menu error: " .. tostring(err))
        end
    else
        EM:RegisterForEvent(ADDON .. "_WaitHarven", EVENT_ADD_ON_LOADED, function(_, lib)
            if lib == "LibHarvensAddonSettings" then
                local ok, err = pcall(CreateVCAPMenu)
                if not ok then
                    Debug("Menu error: " .. tostring(err))
                end
                EM:UnregisterForEvent(ADDON .. "_WaitHarven", EVENT_ADD_ON_LOADED)
            end
        end)
    end
end
--------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------
local function Msg(text, force)
    if force or (VCA.SV and VCA.SV.debug) then
        d("[VCAP2] " .. text)
    end
end
SLASH_COMMANDS["/vcap2debug"] = function()
    VCA.SV = VCA.SV or {}
    VCA.SV.debug = not (VCA.SV.debug or false)
    Msg("Debug: " .. (VCA.SV.debug and "ON" or "OFF"), true)
end
SLASH_COMMANDS["/vcap2clients"] = function()
    local regs = VCA.SV and VCA.SV.customClients or {}
    if not next(regs) then
        Msg("No addon tags detected or registered.", true)
        return
    end
    local t = {}
    for lower, e in pairs(regs) do
        table.insert(t, string.format("[%s]=%s (%s)", e.original, e.name or e.original, e.narrate and "narration ON" or "narration OFF"))
    end
    table.sort(t)
    Msg("Tags: " .. table.concat(t, "; "), true)
end
SLASH_COMMANDS["/vcap2filtest"] = function()
    local testMessage = "[VCAP2Test] Testing automatic tag discovery and opt-in addon narration..."
    d("[VCAP2 TEST] Sending through CHAT_ROUTER:AddSystemMessage")
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(testMessage)
    else
        d("[VCAP2] CHAT_ROUTER missing.")
    end
end
--------------------------------------------------------------
-- One-shot reopen after ReloadUI
--------------------------------------------------------------
local function ClearReopenRequest()
    if VCA.SV then
        VCA.SV.reopenSettingsAfterReload = false
        TouchSV()
    end
end

-- LHAS console initializes only when ESO's main gamepad menu is shown.
-- Opening that scene first mirrors the real route: Main Menu > Add-ons > VCAP2.
local function ShowMainMenuForReopen()
    if not (SCENE_MANAGER and SCENE_MANAGER.Show) then
        Debug("Reopen settings: scene manager not ready to show main menu.")
        return false
    end

    local ok, err = pcall(function()
        SCENE_MANAGER:Show("mainMenuGamepad")
    end)
    if not ok then
        Debug("Reopen settings: main menu open failed: " .. tostring(err))
        return false
    end

    Debug("Reopen settings: main gamepad menu requested.")
    return true
end

local function TryInitializeLHASForReopen()
    local LHA = LibHarvensAddonSettings
    if not LHA then
        Debug("Reopen settings: LibHarvensAddonSettings not loaded yet.")
        return false
    end

    if LHA.initialized then
        return true
    end

    -- Normally MAIN_MENU_GAMEPAD_SCENE's StateChange callback initializes LHAS
    -- synchronously when the main menu is shown. If the menu was already showing
    -- or the callback did not fire for any reason, Initialize() is idempotent and
    -- guarded by LHAS itself, so this is a safe fallback.
    if LHA.Initialize then
        local ok, err = pcall(function()
            LHA:Initialize()
        end)
        if not ok then
            Debug("Reopen settings: LHAS initialize fallback failed: " .. tostring(err))
            return false
        end
    end

    return LHA.initialized and true or false
end

local function TryReopenVCAPSettings()
    if not (VCA.SV and VCA.SV.reopenSettingsAfterReload) then
        return true
    end

    if not TryInitializeLHASForReopen() then
        Debug("Reopen settings: LHAS is not initialized yet.")
        return false
    end

    if not (VCA.menu and VCA.menu.Select) then
        Debug("Reopen settings: VCAP2 menu object not ready yet.")
        return false
    end

    if not (SCENE_MANAGER and SCENE_MANAGER.Push) then
        Debug("Reopen settings: scene manager not ready yet.")
        return false
    end

    if SCENE_MANAGER.GetScene and not SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene") then
        Debug("Reopen settings: LHAS settings scene not ready yet.")
        return false
    end

    -- Match LHAS's own Add-ons submenu callback: select the addon first,
    -- then push the LHAS settings scene from the main-menu stack.
    local okSelect, selectErr = pcall(function()
        VCA.menu:Select()
    end)
    if not okSelect then
        Debug("Reopen settings: VCAP2 Select failed: " .. tostring(selectErr))
        return false
    end

    local okScene, sceneErr = pcall(function()
        SCENE_MANAGER:Push("LibHarvensAddonSettingsScene")
    end)
    if not okScene then
        Debug("Reopen settings: LHAS scene open failed: " .. tostring(sceneErr))
        return false
    end

    ClearReopenRequest()
    Debug("Reopened VCAP2 settings through main gamepad menu flow after ReloadUI.")
    return true
end

local function ScheduleReopenAfterActivation()
    if not (VCA.SV and VCA.SV.reopenSettingsAfterReload) then return end

    -- Give the world and base gamepad UI a moment to finish player activation.
    zo_callLater(function()
        if not (VCA.SV and VCA.SV.reopenSettingsAfterReload) then return end

        -- Critical Test 5 change: LHAS does not create its console Add-ons panel
        -- until the main gamepad menu is shown at least once.
        ShowMainMenuForReopen()

        -- First state-driven attempt after the menu has had time to enter SHOWING.
        zo_callLater(function()
            if TryReopenVCAPSettings() then return end

            -- Second and final attempt. Re-request the main menu in case another
            -- scene transition interrupted the first request, then retry once.
            ShowMainMenuForReopen()
            zo_callLater(function()
                if TryReopenVCAPSettings() then return end

                -- Failsafe: clear the one-shot flag and leave the player in the
                -- normal main menu/game UI. Never loop and never auto-reload again.
                ClearReopenRequest()
                d("[VCAP2] Settings could not reopen automatically. Open Add-ons > VCAP2 manually.")
            end, 2000)
        end, 750)
    end, 1500)
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------
local function OnAddOnLoaded(_, name)
    if name ~= ADDON then return end
    EM:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    BuildChannels()

    -- Keep SavedVariables version 7 so existing console settings are not
    -- discarded. New fields are migrated in place.
    local defaultsVersion = 7
    local DEFAULTS = {
        version = defaultsVersion,
        enabled = true,
        debug = false,
        readChannel9Tags = false,
        channel9Mode = "registered",
        readAddonTags = false,
        addonMessageMode = "registered",
        filter = {},
        categoryFilter = {},
        customClients = {},
        untaggedAddonNarration = false,
        reopenSettingsAfterReload = false,
    }

    VCA.SV = ZO_SavedVars:NewAccountWide("VCAP2_SV", defaultsVersion, nil, DEFAULTS)
    MigrateFilters()

    if VCA.SV.reopenSettingsAfterReload then
        EM:RegisterForEvent(ADDON .. "_ReopenSettings", EVENT_PLAYER_ACTIVATED, function()
            EM:UnregisterForEvent(ADDON .. "_ReopenSettings", EVENT_PLAYER_ACTIVATED)
            ScheduleReopenAfterActivation()
        end)
    end

    zo_callLater(function()
        -- Source hook must be installed before the final narration hook.
        VCA:HookChatRouter()
        VCA:HookNarration()
    end, 1000)

    SafeCreateMenu()
    PrintOnce()
end
EM:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
