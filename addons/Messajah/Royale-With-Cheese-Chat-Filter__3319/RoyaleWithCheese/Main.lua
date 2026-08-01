-- Constants.
local ALPHABET_CYRILLIC = 1
local ALPHABET_GERMAN = 2
local ALPHABET_SPANISH = 3
local ALPHABET_FRENCH = 4
local ALPHABET_LOOKUP = {
    [1] = "Cyrillic",
    [2] = "German",
    [3] = "Spanish",
    [4] = "French",
}


-- Local references to frequently used functions.
local em = GetEventManager()
local math_min = math.min
local strformat = string.format
local tinsert = table.insert
local utf8_len = utf8.len
local utf8_offset = utf8.offset
local zo_strformat = zo_strformat


-- Addon table.
local addon = {
    name = "RoyaleWithCheese",
    author = "@Messajah (EU)",
    debug = false,

    -- Alphabet lookup hashtable.
    -- NOTE: We include every letter (sorted by frequency) to allow for rapid
    -- detection of any language no matter which character. And yes, this
    -- hardcoded table is by far the fastest and most accurate alphabet
    -- scanning method within the limitations of ESO's Lua engine.
    alphabets = {
        -- Cyrillic.
        -- - Unicode Table: https://www.unicode.org/charts/PDF/U0400.pdf
        -- - Most Frequent Characters: https://www.sttmedia.com/characterfrequency-russian
        -- - NOTE: The Russian characters are all unique codepoints
        --   despite looking similar to Latin alphabets.
        ["О"] = ALPHABET_CYRILLIC,
        ["о"] = ALPHABET_CYRILLIC,
        ["Е"] = ALPHABET_CYRILLIC,
        ["е"] = ALPHABET_CYRILLIC,
        ["А"] = ALPHABET_CYRILLIC,
        ["а"] = ALPHABET_CYRILLIC,
        ["И"] = ALPHABET_CYRILLIC,
        ["и"] = ALPHABET_CYRILLIC,
        ["Н"] = ALPHABET_CYRILLIC,
        ["н"] = ALPHABET_CYRILLIC,
        ["Т"] = ALPHABET_CYRILLIC,
        ["т"] = ALPHABET_CYRILLIC,
        ["С"] = ALPHABET_CYRILLIC,
        ["с"] = ALPHABET_CYRILLIC,
        ["Л"] = ALPHABET_CYRILLIC,
        ["л"] = ALPHABET_CYRILLIC,
        ["В"] = ALPHABET_CYRILLIC,
        ["в"] = ALPHABET_CYRILLIC,
        ["Р"] = ALPHABET_CYRILLIC,
        ["р"] = ALPHABET_CYRILLIC,
        ["К"] = ALPHABET_CYRILLIC,
        ["к"] = ALPHABET_CYRILLIC,
        ["М"] = ALPHABET_CYRILLIC,
        ["м"] = ALPHABET_CYRILLIC,
        ["Д"] = ALPHABET_CYRILLIC,
        ["д"] = ALPHABET_CYRILLIC,
        ["П"] = ALPHABET_CYRILLIC,
        ["п"] = ALPHABET_CYRILLIC,
        ["Ы"] = ALPHABET_CYRILLIC,
        ["ы"] = ALPHABET_CYRILLIC,
        ["У"] = ALPHABET_CYRILLIC,
        ["у"] = ALPHABET_CYRILLIC,
        ["Б"] = ALPHABET_CYRILLIC,
        ["б"] = ALPHABET_CYRILLIC,
        ["Я"] = ALPHABET_CYRILLIC,
        ["я"] = ALPHABET_CYRILLIC,
        ["Ь"] = ALPHABET_CYRILLIC,
        ["ь"] = ALPHABET_CYRILLIC,
        ["Г"] = ALPHABET_CYRILLIC,
        ["г"] = ALPHABET_CYRILLIC,
        ["З"] = ALPHABET_CYRILLIC,
        ["з"] = ALPHABET_CYRILLIC,
        ["Ч"] = ALPHABET_CYRILLIC,
        ["ч"] = ALPHABET_CYRILLIC,
        ["Й"] = ALPHABET_CYRILLIC,
        ["й"] = ALPHABET_CYRILLIC,
        ["Ж"] = ALPHABET_CYRILLIC,
        ["ж"] = ALPHABET_CYRILLIC,
        ["Х"] = ALPHABET_CYRILLIC,
        ["х"] = ALPHABET_CYRILLIC,
        ["Ш"] = ALPHABET_CYRILLIC,
        ["ш"] = ALPHABET_CYRILLIC,
        ["Ю"] = ALPHABET_CYRILLIC,
        ["ю"] = ALPHABET_CYRILLIC,
        ["Ц"] = ALPHABET_CYRILLIC,
        ["ц"] = ALPHABET_CYRILLIC,
        ["Э"] = ALPHABET_CYRILLIC,
        ["э"] = ALPHABET_CYRILLIC,
        ["Щ"] = ALPHABET_CYRILLIC,
        ["щ"] = ALPHABET_CYRILLIC,
        ["Ф"] = ALPHABET_CYRILLIC,
        ["ф"] = ALPHABET_CYRILLIC,
        ["Ё"] = ALPHABET_CYRILLIC,
        ["ё"] = ALPHABET_CYRILLIC,
        ["Ъ"] = ALPHABET_CYRILLIC,
        ["ъ"] = ALPHABET_CYRILLIC,

        -- German.
        -- - Special Characters: https://en.wikipedia.org/wiki/German_orthography#Special_letters
        -- - Most Frequent Characters: https://www.sttmedia.com/characterfrequency-german
        -- - NOTE: Some letters are used by certain Nordic languages too (such as Swedish
        --   and Finnish), but almost every person using them in global chat is German.
        ["Ü"] = ALPHABET_GERMAN,  -- Exists in German, Spanish and French. We classify it as German.
        ["ü"] = ALPHABET_GERMAN,  -- Exists in German, Spanish and French. We classify it as German.
        ["Ä"] = ALPHABET_GERMAN,  -- Also in Nordic languages.
        ["ä"] = ALPHABET_GERMAN,  -- Also in Nordic languages.
        ["ẞ"] = ALPHABET_GERMAN,
        ["ß"] = ALPHABET_GERMAN,
        ["Ö"] = ALPHABET_GERMAN,  -- Also in Nordic languages.
        ["ö"] = ALPHABET_GERMAN,  -- Also in Nordic languages.

        -- Spanish.
        -- - Special Characters: https://www.alt-codes.net/spanish_alt_codes/
        -- - Most Frequent Characters: https://www.sttmedia.com/characterfrequency-spanish
        ["¡"] = ALPHABET_SPANISH,
        ["¿"] = ALPHABET_SPANISH,
        ["Ó"] = ALPHABET_SPANISH,
        ["ó"] = ALPHABET_SPANISH,
        ["Í"] = ALPHABET_SPANISH,
        ["í"] = ALPHABET_SPANISH,
        ["Á"] = ALPHABET_SPANISH,
        ["á"] = ALPHABET_SPANISH,
        --["É"] = ALPHABET_SPANISH,  -- Exists in Spanish and French. Skipped.
        --["é"] = ALPHABET_SPANISH,  -- Exists in Spanish and French. Skipped.
        ["Ñ"] = ALPHABET_SPANISH,
        ["ñ"] = ALPHABET_SPANISH,
        ["Ú"] = ALPHABET_SPANISH,
        ["ú"] = ALPHABET_SPANISH,
        --["Ü"] = ALPHABET_SPANISH,  -- Exists in German, Spanish and French. We classify it as German.
        --["ü"] = ALPHABET_SPANISH,  -- Exists in German, Spanish and French. We classify it as German.

        -- French.
        -- - Special Characters: https://www.alt-codes.net/french_alt_codes/
        -- - Most Frequent Characters: https://www.sttmedia.com/characterfrequency-french
        --["É"] = ALPHABET_FRENCH,  -- Exists in Spanish and French. Skipped.
        --["é"] = ALPHABET_FRENCH,  -- Exists in Spanish and French. Skipped.
        ["À"] = ALPHABET_FRENCH,
        ["à"] = ALPHABET_FRENCH,
        ["È"] = ALPHABET_FRENCH,
        ["è"] = ALPHABET_FRENCH,
        ["Ê"] = ALPHABET_FRENCH,
        ["ê"] = ALPHABET_FRENCH,
        ["Ô"] = ALPHABET_FRENCH,
        ["ô"] = ALPHABET_FRENCH,
        ["Û"] = ALPHABET_FRENCH,
        ["û"] = ALPHABET_FRENCH,
        ["Â"] = ALPHABET_FRENCH,
        ["â"] = ALPHABET_FRENCH,
        ["Î"] = ALPHABET_FRENCH,
        ["î"] = ALPHABET_FRENCH,
        --["Ü"] = ALPHABET_FRENCH,  -- Exists in German, Spanish and French. We classify it as German.
        --["ü"] = ALPHABET_FRENCH,  -- Exists in German, Spanish and French. We classify it as German.
        ["Ù"] = ALPHABET_FRENCH,
        ["ù"] = ALPHABET_FRENCH,
        ["Ë"] = ALPHABET_FRENCH,  -- Looks exactly like Russian but is a unique codepoint.
        ["ë"] = ALPHABET_FRENCH,  -- Looks exactly like Russian but is a unique codepoint.
        ["Œ"] = ALPHABET_FRENCH,
        ["œ"] = ALPHABET_FRENCH,
        ["Ç"] = ALPHABET_FRENCH,
        ["ç"] = ALPHABET_FRENCH,
        ["Ï"] = ALPHABET_FRENCH,
        ["ï"] = ALPHABET_FRENCH,
        ["Æ"] = ALPHABET_FRENCH,
        ["æ"] = ALPHABET_FRENCH,

        -- REGARDING OTHER LANGUAGES:
        -- Players from other languages aren't spammy enough ingame to bother
        -- people, and almost never write anything, so other languages such
        -- as Turkish, Slavic and Scandinavian won't be added to this list.
    },

    -- Default addon settings.
    account_defaults = {
        filter = {
            -- Cyrillic (Russian and related languages).
            ["cyrillic"] = true,
            -- Others/"European" (primarily German, Spanish and French).
            -- NOTE: "Others" is one combined toggle, since there's no way
            -- to reliably differentiate these languages. Heck, they will
            -- even catch some other languages such as Swedish since many
            -- of the European languages share the same alphabets.
            ["others"] = true,
        },
        filter_stats = {
            ["cyrillic"] = 0,
            ["others"] = 0,
        },
        channels = {
            -- General.
            [CHAT_CHANNEL_SAY] = true,
            [CHAT_CHANNEL_YELL] = true,
            [CHAT_CHANNEL_EMOTE] = true,
            [CHAT_CHANNEL_WHISPER] = false,
            [CHAT_CHANNEL_PARTY] = false,  -- Group.
            -- Zone.
            [CHAT_CHANNEL_ZONE] = true,
            [CHAT_CHANNEL_ZONE_LANGUAGE_1] = false,
            [CHAT_CHANNEL_ZONE_LANGUAGE_2] = false,
            [CHAT_CHANNEL_ZONE_LANGUAGE_3] = false,
            [CHAT_CHANNEL_ZONE_LANGUAGE_4] = false,
            [CHAT_CHANNEL_ZONE_LANGUAGE_5] = false,
            -- Guild.
            [CHAT_CHANNEL_GUILD_1] = false,
            [CHAT_CHANNEL_GUILD_2] = false,
            [CHAT_CHANNEL_GUILD_3] = false,
            [CHAT_CHANNEL_GUILD_4] = false,
            [CHAT_CHANNEL_GUILD_5] = false,
            -- Officer.
            [CHAT_CHANNEL_OFFICER_1] = false,
            [CHAT_CHANNEL_OFFICER_2] = false,
            [CHAT_CHANNEL_OFFICER_3] = false,
            [CHAT_CHANNEL_OFFICER_4] = false,
            [CHAT_CHANNEL_OFFICER_5] = false,
        },
    },

    -- Cached player details for quick lookup.
    player_name = nil,
    account_display_name = nil,
}


-- Event handler: Addon loaded.
-- @return nil
local function OnAddonLoaded(event, name)
    if name ~= addon.name then return end
    em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    addon:Initialize()
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)


-- Addon initialization.
-- @return nil
function addon:Initialize()
    self.account = ZO_SavedVars:NewAccountWide("ROYALEWITHCHEESE_DB", 1, nil, self.account_defaults)

    self.player_name = GetUnitName("player")
    self.account_display_name = GetDisplayName()

    self:HookChatEvents()
    self:RegisterSettingsGUI()

    -- TODO: Remove this after a month, when the new name migration is complete for every existing user.
    if _G["ENGLISHMFKR_DB"] ~= nil then
        -- Import filter stats for any zero-count stats in new DB, and all settings from the old addon.
        local old_db = _G["ENGLISHMFKR_DB"]["Default"]
        local new_db = _G["ROYALEWITHCHEESE_DB"]["Default"]
        for account_name, account_data in pairs(old_db) do
            if new_db[account_name] ~= nil then
                local old_data = account_data["$AccountWide"]
                local new_data = new_db[account_name]["$AccountWide"]

                local first_import = false
                for filter_name, filter_count in pairs(old_data["filter_stats"]) do
                    if new_data["filter_stats"][filter_name] < 1 then
                        first_import = true
                        new_data["filter_stats"][filter_name] = filter_count
                    end
                end

                if first_import then
                    for _, import_k in ipairs({"filter", "channels"}) do
                        for k, v in pairs(old_data[import_k]) do
                            new_data[import_k][k] = v
                        end
                    end
                end
            end
        end

        -- It's too early during loading to print any messages yet. We'll instead be annoying and output the warning
        -- on "player activated", meaning after login and after EVERY loading screen, to ensure swift compliance!
        local function OnPlayerActivated(event, initial)
            self:PrintWarn("Warning: The \"English Mfkr, Do You Speak It?\" addon has been renamed to \"Royale With Cheese\" to have a more neutral name and to avoid offending a few very soft and sensitive people who can't even take a joke from a popular cult movie these days. It was decided that it's simpler to rename the addon than to deal with the nagging by such people, since they tend to have way too much free time and their nagging would just get worse if the original name stays.")
            self:PrintWarn("You currently have both addon versions installed. Please simply |cEE82EEdelete|cFF7900 your \"|cEE82EEDocuments/Elder Scrolls Online/live/AddOns/EnglishMfkr|cFF7900\" folder manually to remove the old version and then restart the game. After that, this warning will disappear and the chat filtering addon will function correctly! This is a quick, one-time process and will never happen again. All previous settings and stats have been imported into the new addon. Thank you and sorry for the inconvenience during this addon renaming process.")
        end
        em:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end


-- Register the chat filter hooks.
-- @return nil
function addon:HookChatEvents()
    if pChat then  -- pChat addon.
        ZO_PreHook(pChat, "FormatMessage", function(...)
            return self:ChatFilter(...)
        end)
    else  -- Built-in Chat.
        ZO_PreHook(CHAT_ROUTER:GetRegisteredMessageFormatters(), EVENT_CHAT_MESSAGE_CHANNEL, function(...)
            return self:ChatFilter(...)
        end)
    end
end


-- Register the addon settings GUI controls.
-- @return nil
function addon:RegisterSettingsGUI()
    local options = {}

    local function add_header(text, half_width)
        tinsert(options, {
            type = "header",
            name = text,
            width = (not half_width) and "full" or "half",
        })
    end

    local function add_description(title, text)
        tinsert(options, {
            type = "description",
		    title = title,  -- nil allowed.
		    text = (text ~= nil) and text or "",  -- Hidden if empty.
            width = "full",
        })
    end

    local function add_filter_stats(filter_key, name, tooltip_name)
        tinsert(options, {
            type = "editbox",
            name = strformat("%s Messages Blocked", name),
            tooltip = strformat("How many %s messages the addon has blocked since you installed it.", tooltip_name),
            getFunc = function()
                local count = 0
                if (filter_key ~= nil) then
                    count = self.account.filter_stats[filter_key]
                else
                    for k, v in pairs(self.account.filter_stats) do
                        count = count + v
                    end
                end
                return count
            end,
            setFunc = function(value) end,
            isMultiline = false,
            textType = TEXT_TYPE_NUMERIC,
            width = "full",
            disabled = true,
        })
    end

    local function add_filter_setting(filter_key, name, tooltip_ending)
        tinsert(options, {
            type = "checkbox",
            name = strformat("Block %s Messages", name),
            tooltip = strformat("Enable this to block all messages containing %s", tooltip_ending),
            default = self.account_defaults.filter[filter_key],
            getFunc = function()
                return self.account.filter[filter_key]
            end,
            setFunc = function(state)
                self.account.filter[filter_key] = state
            end,
            width = "full",
            disabled = false,
        })
    end

    local function add_channel_setting(channel_id, name)
        tinsert(options, {
            type = "checkbox",
            name = strformat("  %s", name),
            tooltip = strformat("Enable this to block messages on the %s channel.", name),
            default = self.account_defaults.channels[channel_id],
            getFunc = function()
                return self.account.channels[channel_id]
            end,
            setFunc = function(state)
                self.account.channels[channel_id] = state
            end,
            width = "full",
            disabled = false,
        })
    end

    add_header("Statistics")

    add_filter_stats("cyrillic", "Cyrillic", "Cyrillic")
    add_filter_stats("others", "European", "European (German, Spanish, French, ...)")
    add_filter_stats(nil, "Total", "total")

    add_header("Language Filters")

    add_filter_setting("cyrillic", "Cyrillic", "the Cyrillic (Russian) alphabet.")
    add_filter_setting("others", "European", "various European alphabets (such as German, Spanish, French, ...).")

    add_header("Filtered Channels")

    add_description("General:")
    add_channel_setting(CHAT_CHANNEL_SAY, "Say")
    add_channel_setting(CHAT_CHANNEL_YELL, "Yell")
    add_channel_setting(CHAT_CHANNEL_EMOTE, "Emote")
    add_channel_setting(CHAT_CHANNEL_WHISPER, "Tell/Whisper")
    add_channel_setting(CHAT_CHANNEL_PARTY, "Group")

    add_description("Zone:")
    add_channel_setting(CHAT_CHANNEL_ZONE, "Zone")
    add_channel_setting(CHAT_CHANNEL_ZONE_LANGUAGE_1, "Zone - English")
    add_channel_setting(CHAT_CHANNEL_ZONE_LANGUAGE_2, "Zone - French")
    add_channel_setting(CHAT_CHANNEL_ZONE_LANGUAGE_3, "Zone - German")
    add_channel_setting(CHAT_CHANNEL_ZONE_LANGUAGE_4, "Zone - Japanese")
    add_channel_setting(CHAT_CHANNEL_ZONE_LANGUAGE_5, "Zone - Russian")

    add_description("Guilds:")
    add_channel_setting(CHAT_CHANNEL_GUILD_1, "Guild 1")
    add_channel_setting(CHAT_CHANNEL_OFFICER_1, "Officer 1")
    add_channel_setting(CHAT_CHANNEL_GUILD_2, "Guild 2")
    add_channel_setting(CHAT_CHANNEL_OFFICER_2, "Officer 2")
    add_channel_setting(CHAT_CHANNEL_GUILD_3, "Guild 3")
    add_channel_setting(CHAT_CHANNEL_OFFICER_3, "Officer 3")
    add_channel_setting(CHAT_CHANNEL_GUILD_4, "Guild 4")
    add_channel_setting(CHAT_CHANNEL_OFFICER_4, "Officer 4")
    add_channel_setting(CHAT_CHANNEL_GUILD_5, "Guild 5")
    add_channel_setting(CHAT_CHANNEL_OFFICER_5, "Officer 5")

    local LAM = LibAddonMenu2
    local LAM_Panel_Var = "LAM_Panel_RoyaleWithCheese"  -- WARNING: Global variable name!
    LAM:RegisterAddonPanel(LAM_Panel_Var, {
        type = "panel",
        name = "Royale With Cheese (Chat Filter)",
        author = self.author,
        -- Allow user to "reset to default".
        registerForDefaults = true,
        -- When one setting changes (and whenever panel is opened), the state of all
        -- other settings will be refreshed too, ensuring linked settings are correct.
        registerForRefresh = true,
    })
    LAM:RegisterOptionControls(LAM_Panel_Var, options)
end


-- Print a message to the chatbox.
-- @param text string Message.
-- @return nil
function addon:Print(text)
    CHAT_SYSTEM:AddMessage(text)
end


-- Print a formatted message to the chatbox.
-- @param text string Message with formatting specifiers.
-- @vararg any Extra variables for format.
-- @return nil
function addon:PrintF(text, ...)
    self:Print(strformat(text, ...))
end


-- Print a warning message to the chatbox.
-- @param text string Message.
-- @return nil
function addon:PrintWarn(text)
    self:PrintF("|cFF7900%s|r", text)
end


-- Print a formatted warning message to the chatbox.
-- @param text string Message with formatting specifiers.
-- @vararg any Extra variables for format.
-- @return nil
function addon:PrintWarnF(text, ...)
    self:PrintF(strformat("|cFF7900%s|r", text), ...)
end


-- Chat filter callback.
--- @param message_type number Channel ID.
--- @param from_name string Name of the account it is sent from.
--- @param text string Message.
--- @param is_from_customer_service boolean If the message is from a customer service agent.
--- @param from_display_name string Name of the character that sent the message.
--- @return boolean True if the message should be filtered out, otherwise false.
function addon:ChatFilter(message_type, from_name, text, is_from_customer_service, from_display_name)
    if is_from_customer_service then return false end
    if not self.account.channels[message_type] then return false end

    -- Start the benchmark. (Be sure that debug is disabled, since printing is slow.)
    -- NOTE: This code is only left here in case someone is curious about performance.
    --local start_millis = GetGameTimeMilliseconds()

    -- ---------------------------------------------------------------------- --

    -- ESO'S LUA UTF8 IMPLEMENTATION RANT / INFORMATION:
    --
    -- The game uses a modified version of Lua 5.1, with the Lua 5.3 "UTF8"
    -- library included (but in a very broken state).
    --
    -- The UTF8 support in ESO is AWFUL. They have the UTF8 library, but the
    -- great "utf8.codes()" function isn't whitelisted as an "unprotected
    -- function", meaning that addons can't use it and therefore can't split
    -- the string into its individual UTF8 codepoints. Their "utf8.charpattern"
    -- is incapable of extracting UTF8 characters due to ESO's broken string
    -- search functions (which reject high bytes). Their "utf8.char()" literally
    -- crashes the whole game, etc. So that's no help. They do have "str:find()",
    -- but unlike normal LUA they don't support searching for the actual high
    -- UTF8 bytes (i.e. "\xD0[\x80-\xBF]"), and they don't support character
    -- ranges either (such as "[Ѐ-ӿ]"), nor character sets (such as "[Ѐӿ]")
    -- since each character is multibyte and confuses the pattern matcher.
    -- Strangely enough, "\xD0\x80" fails but "\208\128" (the decimal variant)
    -- works. But trying to specify a decimal range ("\208[\128-\191]") fails,
    -- and that's because ESO has modified the Lua code for the "[]" pattern
    -- to throw away all non-ASCII numbers (meaning anything above 127),
    -- since that technique works in normal Lua but not in ESO, which also
    -- explains why Lua's official "utf8.charpattern" fails in ESO's "find()".
    --
    -- There are various 3rd party "pure Lua UTF8 libraries", but they're all
    -- extremely bloated and slow and aren't fast enough for what we need, since
    -- they have to deal with the actual raw UTF8 encoding, which is very complex.
    -- The first UTF8 byte uses a "110xxxxx"-style pattern and subsequent bytes
    -- use a "10xxxxxx" pattern, and every "x" needs to be combined and bit-shifted
    -- into one binary sequence which contains the final value. Lua is too slow,
    -- which is why the native UTF8 functions in Lua 5.3 are written in C.
    -- Sadly, ESO uses an old, custom version of Lua 5.1 with broken UTF8 support.
    --
    -- So what exactly does ESO support? Well, finding individual UTF8 characters
    -- and words, but not character ranges unless they are plain ASCII (0-127)...
    --
    -- But doing repeated calls to "str:find()" one individual alphabet-character
    -- at a time would be extremely slow and stupid, since each call would have
    -- to re-scan the entire message-string every time (and that's exactly what
    -- all the other, poorly written "chat blocker" addons do...).
    --
    -- We will instead use another technique below, where we'll crawl through
    -- the string one UTF8 multibyte character at a time and check our lookup
    -- table until we find a match. This technique is extremely fast and
    -- allows us very flexible scanning that covers entire alphabets.
    --
    -- NOTE: The technique below has been benchmarked on the maximum length
    -- messages the game allows. The scan time is usually 0 milliseconds
    -- even for the max-length messages even when no matches are found and
    -- every character is scanned. The worst result I've observed was a mere
    -- 2 milliseconds. If a match is found, it stops scanning early.
    -- In other words, it's very FAST and is optimized for high efficiency!

    -- ---------------------------------------------------------------------- --

    -- Determine how far into the string we'll scan (max 200 UTF8 characters).
    -- NOTE: We have a high limit because of metadata text such as item-links
    -- (which are at least ~60 chars) possibly appearing at the start.
    -- NOTE: The game itself seems to be capped at 350 BYTES per message.
    local text_len = utf8_len(text)
    if text_len <= 0 then return false end
    local end_char = math_min(200, text_len)

    -- Loop through each UTF8 character one by one, starting at the first.
    local alphabet = nil
    local filter_alphabets = self.account.filter
    local current_char = 1
    local current_byte = 1
    repeat
        -- Determine the offset of the "next character's first byte".
        -- NOTE: We ask for the 2nd ("next") byte after our current byte's
        -- binary offset. The function always returns what WOULD BE the
        -- next byte when our "current_byte" is the first byte of the FINAL
        -- character in the string, so it works perfectly at end string too.
        -- However, IF we'd ask for 3rd char after END of string, we'd get nil.
        local next_char_byte = utf8_offset(text, 2, current_byte)

        -- Extract all of the bytes for the current character.
        local char = text:sub(current_byte, next_char_byte - 1)
        if self.debug then self:PrintF("Extracted: <%s>", char) end

        -- Scan for a non-latin alphabet by checking our lookup-hashtable.
        alphabet = self.alphabets[char]
        if alphabet ~= nil then
            if (alphabet == ALPHABET_CYRILLIC and not filter_alphabets["cyrillic"])
            or (alphabet ~= ALPHABET_CYRILLIC and not filter_alphabets["others"]) then
                alphabet = nil  -- We found an alphabet but the user doesn't want to filter it.
            else
                break  -- Quit early since we found a filtered alphabet.
            end
        end

        -- Update the byte offset to point at the next character.
        current_byte = next_char_byte

        -- Count chars to ensure we don't go beyond our maximum scan length.
        current_char = current_char + 1
    until current_char > end_char

    if self.debug then
        self:PrintF("Alphabet: <%s>", alphabet or "Latin-based/English or Not Filtered")
    end

    -- Determine whether the message should be hidden.
    local filter = false
    if alphabet ~= nil then
        -- Warn the player if they're the one sending the filtered language.
        -- NOTE: The names can contain some garbage which "zo_strformat" cleans up.
        local raw_name = zo_strformat("<<1>>", from_name)
        local raw_display_name = zo_strformat("<<1>>", from_display_name)
        if (self.player_name == raw_name or self.account_display_name == raw_display_name) then
            self:PrintWarnF("Warning: You've sent a message containing a filtered alphabet (%s). You will not see the replies if others reply in that language.", ALPHABET_LOOKUP[alphabet])
            filter = false
        else
            filter = true
        end
    end

    -- Update the filter statistics.
    if filter then
        local key = (alphabet == ALPHABET_CYRILLIC) and "cyrillic" or "others"
        self.account.filter_stats[key] = self.account.filter_stats[key] + 1

        if self.debug then
            self:PrintF("Filtering (#%d): <%s: %s>", self.account.filter_stats[key], zo_strformat("<<1>>", from_name), text)
        end
    end

    -- End the benchmark.
    --self:PrintF("Scan took: <%d> millis", GetGameTimeMilliseconds() - start_millis)

    return filter
end
