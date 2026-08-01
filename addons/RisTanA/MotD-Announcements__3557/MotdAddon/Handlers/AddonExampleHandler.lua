--#region Usings

--#region Framework usings
---@type Array
local Array = EsoAddonFramework_Framework_Array
---@type Color
local Color = EsoAddonFramework_Framework_Color
---@type Console
local Console = EsoAddonFramework_Framework_Console
---@type Event
local Event = EsoAddonFramework_Framework_Eso_Event
---@type EventManager
local EventManager = EsoAddonFramework_Framework_Eso_EventManager
---@type FrameworkMessageType
local FrameworkMessageType = EsoAddonFramework_Framework_MessageType
---@type Log
local Log = EsoAddonFramework_Framework_Log
---@type LogLevel
local LogLevel = EsoAddonFramework_Framework_LogLevel
---@type Map
local Map = EsoAddonFramework_Framework_Map
---@type Messenger
local Messenger = EsoAddonFramework_Framework_Messenger
---@type Pack
local Pack = EsoAddonFramework_Framework_Eso_Pack
---@type Storage
local Storage = EsoAddonFramework_Framework_Storage
---@type StorageScope
local StorageScope = EsoAddonFramework_Framework_StorageScope
---@type String
local String = EsoAddonFramework_Framework_String
---@type StringBuilder
local StringBuilder = EsoAddonFramework_Framework_StringBuilder
---@type Type
local Type = EsoAddonFramework_Framework_Eso_Type
---@type UnitTag
local UnitTag = EsoAddonFramework_Framework_Eso_UnitTag
--#endregion

--#region Addon usings
local AddonMessageType = MotdAddon_Types_MessageType
local Lang = MotdAddon_Lang
--#endregion\\\\\\

--#endregion

-- Constants

local DefaultSettings = {
    MotdShouldAnnounce = true,
    MotdLifetime = 10,
    MotdChatbox = true,
    AnnounceMotdUpdate = true,
    GuildChoice = 0,
}

local Name = "MotdAddon_Handlers_MotdAddonHandler"

-- Fields

local _log
local _settings

-- Global functions

---@param guildIdx number # esoui type: `luaindex`
function PrintConsoleMotd(guildIdx)
    if (not _settings.MotdChatbox) then --break on settings disable
        return
    end

    Console.Write(String.Format("MotD for {1}: {2}", GetGuildName(GetGuildId(guildIdx)), GetGuildMotD(GetGuildId(guildIdx))))
end

---@param guildIdx number # esoui type: `luaindex`
function PrintScreenMotd(guildIdx)
    if (not _settings.MotdShouldAnnounce) then --break on settings disable
        return
    end

    local lifespanMS = _settings.MotdLifetime*1000

    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_COMPLETED)

    messageParams:SetText("MotD for " .. GetGuildName(GetGuildId(guildIdx)) .. ":", GetGuildMotD(GetGuildId(guildIdx)))
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENLIGHTENMENT_GAINED)
    messageParams:SetLifespanMS(lifespanMS)

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function ShowMotd()
local guildNum = GetNumGuilds()
--d("current guild choice: " .. _settings.GuildChoice)
--d("guild num: " .. guildNum)

    --loop through and display all MotDs
    if guildNum > 0 and _settings.GuildChoice == 0 then
        --d("do all guilds")
        for i = 1, guildNum, 1 do
            PrintConsoleMotd(i)
            PrintScreenMotd(i)
        end

    --print selected guild after validation
    elseif _settings.GuildChoice <= guildNum and _settings.GuildChoice ~= 0 then
        --d("do guild choice")
        PrintConsoleMotd(guildNum)
        PrintScreenMotd(guildNum)

    --not in a guild
    elseif guildNum == 0 then
        --do nothing if not in a guild
        --d("do not in guild")

    --not in a guild
    else
        --d("do guild error")
        d("MotD Announce cannot find a guild to announce, please update your 'Guild To Announce' settings in settings>Addons>MotD Announcements")
    end
end

-- Local functions

local function OnInitialActivation()
    ShowMotd()
end

local function OnSettingsControlsRequest()
    local settingsControls = {
        {
            type = "checkbox",
            name = "MotD Center Screen Announce",
            getFunc = function() return _settings.MotdShouldAnnounce end,
            setFunc = function(value) _settings.MotdShouldAnnounce = value end
        },
        {
            type = "slider",
            name = "MotD Display Time (Seconds)",
            tooltip = "Slider's tooltip text.",
	        min = 1,
	        max = 20,
	        step = 1,	--(optional)
	        getFunc = function() return _settings.MotdLifetime end,
	        setFunc = function(value) _settings.MotdLifetime = value end,
	        default = 10
            
        },
        {
            type = "checkbox",
            name = "MotD Chatbox Announce",
            getFunc = function() return _settings.MotdChatbox end,
            setFunc = function(value) _settings.MotdChatbox = value end
        },
        {
            type = "checkbox",
            name = "Announce On MotD Updated",
            getFunc = function() return _settings.AnnounceMotdUpdate end,
            setFunc = function(value) _settings.AnnounceMotdUpdate = value end
        },
        {
            type = "dropdown",
            name = "Guild To Announce",
            choices = {"All Guilds", "Guild 1", "Guild 2", "Guild 3", "Guild 4", "Guild 5"},
            choicesValues = {0,1,2,3,4,5},
            getFunc = function() return _settings.GuildChoice end,
            setFunc = function(value) _settings.GuildChoice = value end
        }
    }

    return {
        DisplayName = String.Format("MotD settings"),
        Controls = settingsControls
    }
end

local function OnGuildMotdChanged(event, guildId)
    if (_settings.AnnounceMotdUpdate) then
        --d("OnGuildMotD changed")
        local guildNum = GetNumGuilds()

        if guildNum > 0 then
            for i = 1, guildNum, 1 do --find matching guild index and initiate a bark
                if guildId == GetGuildId(i)then --do update on match
                    --d("found guild id match" .. guildId .. "to" .. GetGuildId(i))
                    if (_settings.GuildChoice == 0 or _settings.GuildChoice == guildNum) then
                        PrintScreenMotd(i)
                        PrintConsoleMotd(i)
                    end
                end
            end
        end
    end
end

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
    _log = Log.CreateInstance(Name)

    Messenger.Subscribe(FrameworkMessageType.InitialActivation, OnInitialActivation)
    Messenger.Subscribe(FrameworkMessageType.SettingsControlsRequest, OnSettingsControlsRequest)

    EventManager:RegisterForEvent(Name, Event.GuildMotdChanged, OnGuildMotdChanged)

    _settings = Storage.GetEntry(Name, DefaultSettings, StorageScope.Account)
end

EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)