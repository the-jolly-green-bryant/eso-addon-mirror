EmoteKEKW = EmoteKEKW or {
    ['Name'] = "EmoteKEKW",
    ['Description'] = "Emote addon for ESO",
    ['Author'] = "voidbiscuit",
    ['APIVersion'] = "101037",
    ['Version'] = "010000",
    ['VariableVersion'] = 1
}
local EmoteKEKW = EmoteKEKW

-- Saved Variables
EmoteKEKW.default_saved_variables = {
    settings = {
        -- # General
        emote_scale = 1.72,
        space_mode_enabled = true,
        tagging = false,
        -- # Debug
        debug_enabled = false
    }
}

EmoteKEKW.saved_variables = {}

EmoteKEKW.values = {
    colour = {
        addon = "|cFFA500",
        debug = "|cAAA500",
        error = "|cFF0000"
    },
    emote_format = "|t%d:%d:%s|t", -- x, y, path
    emote_scale = nil,
    texture_pack = nil,
    original_chat_handler = nil
}

EmoteKEKW.media = {}
EmoteKEKW.media_cache = {}

-- Messages

local function Message(message, colour, ...)
    if type(message) == type("") then
        message = string.format(message, ...);
        CHAT_ROUTER:AddSystemMessage(
            string.format("%s[%s]%s %s", EmoteKEKW.values.colour.addon, EmoteKEKW.Name, colour, message))
    else
        CHAT_ROUTER:AddSystemMessage(tostring(message))
    end
end

function EmoteKEKW.Message(message, ...)
    Message(message, EmoteKEKW.values.colour.addon, ...)
end

function EmoteKEKW.Debug(message, ...)
    if EmoteKEKW.saved_variables.settings.debug_enabled == true then
        Message(message, EmoteKEKW.values.colour.debug, ...)
    end
end

function EmoteKEKW.Error(message, ...)
    Message(message, EmoteKEKW.values.colour.error, ...)
end

-- Helper

local function Map(tbl, func)
    -- Out
    local list = {};
    -- Loop
    for i, v in ipairs(tbl) do
        table.insert(list, func(v));
    end
    -- Return
    return list;
end
EmoteKEKW.Map = Map

local function Filter(tbl, func)
    -- Out
    local list = {};
    -- Loop
    for i, v in ipairs(tbl) do
        if func(v) then
            table.insert(list, v)
        end
    end
    -- Return
    return list
end
EmoteKEKW.Filter = Filter

local function SortedKeys(tbl)
    -- Get keys
    local keys = {}
    -- Iterate
    for k, v in pairs(tbl) do
        table.insert(keys, k)
    end
    -- Sort
    table.sort(keys)
    -- Return
    return keys
end

-- Main

function EmoteKEKW.UpdateEmoteSize()
    local chat_font_size = GetChatFontSize()
    local emote_scale = math.floor(chat_font_size * EmoteKEKW.saved_variables.settings.emote_scale)
    EmoteKEKW.values.emote_scale = emote_scale
end

function EmoteKEKW.EmoteString(emote_path, emote_scale)
    local emote_string = string.format( -- Emote format
    EmoteKEKW.values.emote_format, -- x, y, path
    emote_scale, emote_scale, emote_path)
    return emote_string
end
local EmoteString = EmoteKEKW.EmoteString

function EmoteKEKW.BuildEmoteCache(emotes, table_path)
    -- Init table path
    if table_path == nil then
        table_path = {}
    end
    -- Iterate emotes
    for k, v in pairs(emotes) do
        if nil then
        elseif v == nil then -- Ignore
        elseif type(v) == type({}) then
            -- Check table type
            if nil then
                -- Emote
            elseif v.type == "emote" then
                -- Follow tree to node
                local node = EmoteKEKW.media_cache
                for part_index = 1, #table_path do
                    local part = table_path[part_index]
                    node[part] = node[part] or {}
                    node = node[part]
                end
                -- Set emote
                local emote_string = EmoteKEKW.EmoteString(k, EmoteKEKW.values.emote_scale * v.scale)
                -- Emote tagging
                if EmoteKEKW.saved_variables.settings.tagging then
                    emote_string = string.format("%s (%s)", emote_string, k)
                end
                -- Spacing
                emote_string = string.format(" %s ", emote_string)
                -- Format emote
                local emote_format = " :%s:? "
                -- Regular
                node[string.format(emote_format, k)] = emote_string
                -- Lowercase and uppercase
                node[string.format(emote_format, string.lower(k))] = emote_string
                node[string.format(emote_format, string.upper(k))] = emote_string
                -- Other
                local plain_emote_string = string.gsub(emote_string, "|", "||")
                EmoteKEKW.Debug("Emote cached %s : %s", plain_emote_string, emote_string)
            else
                -- Add to path, sublist, then remove
                table.insert(table_path, k)
                EmoteKEKW.BuildEmoteCache(v, table_path)
                table.remove(table_path, #table_path)
            end
        else

        end
    end
end

function EmoteKEKW.BuildAllEmoteCache()
    EmoteKEKW.BuildEmoteCache(EmoteKEKW.media)
end

function EmoteKEKW.RegisterEmotes(emote_pack, emotes, table_path)
    -- Init table path
    if table_path == nil then
        table_path = {}
    end
    -- Iterate emotes
    for k, v in pairs(emotes or {}) do
        if nil then
        elseif v == nil then -- Ignore
        elseif type(v) == type({}) then
            -- Check table type
            if nil then
                -- Emote
            elseif v.type == "emote" then
                EmoteKEKW.Debug("Registering emote %s", k)
                local texture = LibTextureProxy.Texture:Create({
                    name = k,
                    frames = v.paths
                })
                emote_pack:RegisterTexture(texture)
            else
                -- Add to path, sublist, then remove
                table.insert(table_path, k)
                EmoteKEKW.RegisterEmotes(emote_pack, v, table_path)
                table.remove(table_path, #table_path)
            end
        end
    end
end

function EmoteKEKW.EmoteFormatter(buffer, emote_cache)
    -- Track if there's been a change
    local emote_found = false
    if type(emote_cache) == type({}) then
        for k, v in pairs(emote_cache) do
            if nil then
            elseif v == nil then -- Ignore
            elseif type(v) == type({}) then
                local emote_found_in_table = nil
                buffer, emote_found_in_table = EmoteKEKW.EmoteFormatter(buffer, v)
                emote_found = emote_found or emote_found_in_table
            elseif type(v) == type("") then
                -- Check if the emote is in the string
                emote_found = emote_found or string.match(buffer, k) ~= nil
                -- Do it twice, to allow adjacent identical emotes to be parsed (it's a stupid thing with spaces)
                buffer = string.gsub(buffer, k, v)
                buffer = string.gsub(buffer, k, v)
            else
                EmoteKEKW.Debug("emote_cache node is of type %s", tostring(type(emote_cache)))
            end
        end
    end
    return buffer, emote_found
end

function EmoteKEKW.MainFormatter(from_name, buffer)
    if buffer ~= nil then
        -- Add leading and trailing space to match regex
        buffer = " " .. buffer .. " "
        -- Custom
        local emote_found = false
        buffer, emote_found = EmoteKEKW.EmoteFormatter(buffer, EmoteKEKW.media_cache)
        -- Remove leading and trailing space again
        buffer = string.sub(buffer, 2, -2)
        -- Do spacing
        local lines = math.floor((EmoteKEKW.saved_variables.settings.emote_scale - 0.01) / 2)
        if EmoteKEKW.saved_variables.settings.space_mode_enabled and 0 < lines and emote_found == true then
            -- Add one to spacing
            lines = lines + 1
            -- Calculate spacing
            local blank = "|t8:8:/esoui/art/icons/heraldrycrests_misc_blank_01.dds|t"
            local spacing = string.rep(blank .. "\n", lines)
            -- Add it to buffer
            buffer = spacing .. buffer .. spacing
        end
    else
        EmoteKEKW.Debug("Message is nil")
    end
    -- Return
    return from_name, buffer
end

-- Handlers

local function GetChatHandler()
    return CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
end

function EmoteKEKW.ChatHandler(messageType, fromName, text, isFromCustomerService, fromDisplayName)
    -- Replace message
    fromName, text = EmoteKEKW.MainFormatter(fromName, text)
    -- Return
    return EmoteKEKW.values.original_chat_handler(messageType, fromName, text, isFromCustomerService, fromDisplayName)
end

function EmoteKEKW.RegisterChatHandler()
    EmoteKEKW.values.original_chat_handler = GetChatHandler()
    CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, EmoteKEKW.ChatHandler)
end

-- Addon Menu

local function AddonMenuEmoteString(emote_path)
    return EmoteString(emote_path, 20)
end

local function AddonMenuEmote(emote_name, emote_data)
    local emote_string = AddonMenuEmoteString(emote_name)
    return string.format("%s %s", emote_string, emote_name)
end

local function AddonMenuEmotePackControl(emote_pack_name, emote_pack)
    -- Build emote pack controls
    local emote_list = {}
    for _, emote_name in pairs(SortedKeys(emote_pack)) do
        local emote_data = emote_pack[emote_name]
        local emote_string = AddonMenuEmote(emote_name, emote_data)
        table.insert(emote_list, emote_string)
        --
    end
    emote_list = table.concat(emote_list, "\n")
    -- Create UI
    local emote_pack_control = {
        type = "submenu",
        name = emote_pack_name,
        controls = {{
            type = "description",
            text = emote_list
        }}
    }
    return emote_pack_control
end

local function AddonMenuEmotePackCategoryControl(emote_pack_category_name, emote_packs)
    -- Build emote pack category controls
    local emote_pack_category_controls = {}
    for _, emote_pack_name in pairs(SortedKeys(emote_packs)) do
        local emote_pack = emote_packs[emote_pack_name]
        local emote_pack_control = AddonMenuEmotePackControl(emote_pack_name, emote_pack)
        table.insert(emote_pack_category_controls, emote_pack_control)
        --
    end
    -- Create UI
    local emote_pack_category_control = {
        type = "submenu",
        name = emote_pack_category_name,
        controls = emote_pack_category_controls
    }
    return emote_pack_category_control
end

local function AddonMenuEmoteList()
    -- Buffer
    local addon_menu_emote_list_controls = {}
    -- Build
    local media = EmoteKEKW.media
    for _, emote_pack_category_name in ipairs(SortedKeys(media)) do
        local emote_packs = media[emote_pack_category_name]
        local emote_pack_category_control = AddonMenuEmotePackCategoryControl(emote_pack_category_name, emote_packs)
        table.insert(addon_menu_emote_list_controls, emote_pack_category_control)
    end
    -- Return
    local addon_menu_emote_list_control = {
        type = "submenu",
        name = "Emotes",
        controls = addon_menu_emote_list_controls
    }
    return addon_menu_emote_list_control
end

function EmoteKEKW.AddonMenu()
    -- Addon Menu
    local LAM = LibAddonMenu2
    local panel_name = EmoteKEKW.Name .. "SettingsPanel"
    local panel_data = {
        type = "panel",
        name = EmoteKEKW.Name,
        author = EmoteKEKW.Author
    }
    local panel = LAM:RegisterAddonPanel(panel_name, panel_data)
    local options_data = {{
        type = "header",
        name = "General",
        width = "full"
    }, {
        type = "description",
        text = 
[[
To type emotes in chat, use :emotename or :emotename.
Emotes are case sensitive, but you may also use full lowercase, or full uppercase.
Emote tagging tags emotes with their name in brackets to the right hand side.
]] .. string.format("Using :KEKW or :KEKW: in chat would result in %s and (KEKW) if emote tagging is turned on.", AddonMenuEmoteString("KEKW"))
    }, {
        type = "checkbox",
        name = "Emote Tagging",
        getFunc = function()
            return EmoteKEKW.saved_variables.settings.tagging
        end,
        setFunc = function(value)
            EmoteKEKW.saved_variables.settings.tagging = value;
            EmoteKEKW.BuildEmoteCache(EmoteKEKW.media)
        end,
        default = EmoteKEKW.saved_variables.settings.tagging
    }, {
        type = "header",
        name = "Emote Scale",
        width = "full"
    }, {
        type = "description",
        text =
[[
Emotes will resize with the size of the chat (Settings > Social > Text Size), but can also be adjusted here.
Emote spacing is only active at emote scale greater than 2, and displays messages which contain emotes over multiple lines to avoid text overlapping.

Default emote scale is 1.72
]]
    }, {
        type = "slider",
        name = "Emote Scale",
        getFunc = function()
            return EmoteKEKW.saved_variables.settings.emote_scale
        end,
        setFunc = function(value)
            EmoteKEKW.saved_variables.settings.emote_scale = value
            EmoteKEKW.UpdateEmoteSize()
            EmoteKEKW.BuildAllEmoteCache()
        end,
        min = 0.8,
        max = 10,
        step = 0.01,
        decimals = 2,
        default = EmoteKEKW.default_saved_variables.settings.emote_scale
    }, {
        type = "checkbox",
        name = "Spacing",
        getFunc = function()
            return EmoteKEKW.saved_variables.settings.space_mode_enabled
        end,
        setFunc = function(value)
            EmoteKEKW.saved_variables.settings.space_mode_enabled = value
        end
    }, AddonMenuEmoteList()}
    LAM:RegisterOptionControls(panel_name, options_data)
end

-- Initialization
function EmoteKEKW:Initialize()
    -- Saved Variables
    EmoteKEKW.saved_variables = ZO_SavedVars:NewAccountWide(
        EmoteKEKW.Name .. "SavedVariables",
        EmoteKEKW.VariableVersion,
        nil,
        EmoteKEKW.default_saved_variables,
        GetWorldName()
    )
    -- Build texture pack
    local texture_pack = LibTextureProxy.TexturePack:Create({
        name = EmoteKEKW.name
    })
    LibTextureProxy.RegisterTexturePack(texture_pack)
    EmoteKEKW.values.texture_pack = texture_pack
    EmoteKEKW.RegisterEmotes(texture_pack, EmoteKEKW.media)
    -- Build emote cache
    EmoteKEKW.UpdateEmoteSize()
    EmoteKEKW.BuildAllEmoteCache()
    -- Addon Menu
    EmoteKEKW.AddonMenu()
    -- Register parsers
    local event_register_chat_handler = EmoteKEKW.Name .. "RegisterChatHandler"
    EVENT_MANAGER:RegisterForEvent(event_register_chat_handler, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(event_register_chat_handler, EVENT_PLAYER_ACTIVATED)
        EmoteKEKW.RegisterChatHandler()
    end)
end

-- Addon Load
EmoteKEKW.initialised = false
function EmoteKEKW.OnAddOnLoaded(event, addonName)
    if addonName == EmoteKEKW.Name then
        EVENT_MANAGER:UnregisterForEvent(EmoteKEKW.Name, EVENT_ADD_ON_LOADED)
        EmoteKEKW:Initialize()
        EmoteKEKW.initialised = true
    end
end

EVENT_MANAGER:RegisterForEvent(EmoteKEKW.Name, EVENT_ADD_ON_LOADED, EmoteKEKW.OnAddOnLoaded)
