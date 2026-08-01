Sauhaufen = {}
Sauhaufen.name = "Sauhaufen"
Sauhaufen.color = "FFC0CB"
Sauhaufen.guildId = 614590
Sauhaufen.guildedLink = "https://www.guilded.gg/i/kdDDMQqk"
Sauhaufen.motd = ""
Sauhaufen.motdPattern = "%-%-%-%-"
Sauhaufen.credits = "@m00nyONE"
Sauhaufen.slashCmd = "/sh"
Sauhaufen.recruitmentText = ""
Sauhaufen.variableVersion = 2
Sauhaufen.defaultVariables = {
    showMOTD = true,
    showOnline = true,
    showAddonButton = true,
    GUI = {
        SauhaufenMenuButton = {10,10},
        SauhaufenMainMenu = {20,20},
    },
}

local SAUHAUFEN_ICONS = {
    "Sauhaufen/media/logo/logo_button_256x256.dds",
}

ZO_CreateStringId("SI_BINDING_NAME_SAUHAUFEN_OPEN", "GUI öffnen")
ZO_CreateStringId("SI_BINDING_NAME_SAUHAUFEN_POST_DISCORD_LINK", "Poste Discord Link in den Chat")
ZO_CreateStringId("SI_BINDING_NAME_SAUHAUFEN_RECRUIT", "Poste Gildenwerbung")


--- utility functions
function Sauhaufen.ColorString(str, color) if color == nil then color = Sauhaufen.color end return "|c" .. color .. str .. "|r" end
function Sauhaufen.SplitString(inputstr, sep) if sep == nil then sep = "%s" end local t={} for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end return t end
function Sauhaufen.TagToTable(str) return Sauhaufen.SplitString(str, ";") end
function Sauhaufen.GetTagsFromString(str, tag) local tags = {} for w in string.gfind(str, tag .. "%(.-%)") do t = string.sub(w, 2 + #tag, #w - 1) table.insert(tags, t) end return tags end
function Sauhaufen.GetHouseNameById(id) if id == 0 then return "Kein Haus" end local h = GetCollectibleName(GetCollectibleIdForHouse(id)) local i, j = string.find(h, "%^") return string.sub(h, 1, i-1) end
function Sauhaufen.GetID(obj) local str = tostring(obj) local i, j = string.find( str, ":") return string.sub(str, i + 2, #str) end


local function AddPlayerToGuild(name, guildid)
    d(zo_strformat("<<C:1>> wurde in den Sauhaufen eingeladen", name))
    GuildInvite(guildid, name)
end
 
local ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
CHAT_SYSTEM.ShowPlayerContextMenu = function(self, name, rawName, ...)
    ShowPlayerContextMenu(self, name, rawName, ...)
 
    if DoesPlayerHaveGuildPermission(Sauhaufen.guildId, GUILD_PERMISSION_INVITE) then
        AddMenuItem("|cFFC0CBIn den Sauhaufen einladen|r", function() AddPlayerToGuild(name, Sauhaufen.guildId) end)
    end

    if ZO_Menu_GetNumMenuItems() > 0 then
        ShowMenu()
    end
end


function Sauhaufen.GetOnlineCount()
    local _, onlineCount, _, _ = GetGuildInfo(Sauhaufen.guildId)
    return onlineCount - 1
end

---- initialization functions
function Sauhaufen.LoadMotD()
    local completeMotD = GetGuildMotD(Sauhaufen.guildId)
    local _, j = string.find(completeMotD, Sauhaufen.motdPattern .. "\n")
    if j ~= nil then
        local beginMotD = string.sub(completeMotD, j+1, #completeMotD)
        local i, _ = string.find(beginMotD, "\n" .. Sauhaufen.motdPattern)
        if i ~= nil then
            Sauhaufen.motd = string.sub(beginMotD, 1, i-1)
        end
    end
end

function Sauhaufen.LoadRecruitmentText()
    local i = GetGuildMemberIndexFromDisplayName(Sauhaufen.guildId, "@Sauhaufen")
    local _, note, _, _, _ = GetGuildMemberInfo(Sauhaufen.guildId, i)
    Sauhaufen.recruitmentText = note
end

function Sauhaufen.Donate(amount)
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(
		function()
			ZO_MailSendToField:SetText("@m00nyONE")
			ZO_MailSendSubjectField:SetText("Donation for Addon")
			QueueMoneyAttachment(amount)
			ZO_MailSendBodyField:TakeFocus() 
		end, 
	200)
end

function Sauhaufen.Welcome()
    if Sauhaufen.CheckIfGuildMember() ~= true then
        CHAT_ROUTER:AddSystemMessage("Du bist leider kein Mitglied unserer Gilde.")
        CHAT_ROUTER:AddSystemMessage("Das kannst du jedoch ändern, indem du dich einfach bei uns auf Guilded bewirbst.")
        CHAT_ROUTER:AddSystemMessage(Sauhaufen.guildedLink)
        return
    end

    -- print out welcome & motd
    if Sauhaufen.savedVariables.showMOTD then
        Sauhaufen.PrintMotD()
    end
    if Sauhaufen.savedVariables.showOnline then
        Sauhaufen.PrintInfo()
    end

    if Sauhaufen.activeEvent then
        CHAT_ROUTER:AddSystemMessage(Sauhaufen.ColorString("Es läuft gerade ein Event! Schau doch mal vorbei"))

        for i = 1, table.getn(Sauhaufen.eventHouses) do
            CHAT_ROUTER:AddSystemMessage("/sh ev" .. i .. " - |cFFFFFFPorte zum Event \"" .. Sauhaufen.eventHouses[i].name .. "\" bei " .. Sauhaufen.eventHouses[i].username .. "|r")
        end

    end
end

function Sauhaufen.CheckIfGuildMember()
    local guildCount = GetNumGuilds()
    for idx = 1, guildCount do
        if GetGuildId(idx) == Sauhaufen.guildId then
            return true
        end
    end 
    return false
end

function Sauhaufen:Startup()
    EVENT_MANAGER:UnregisterForEvent("SauhaufenInit", EVENT_PLAYER_ACTIVATED)
    
    -- load all important variables
    Sauhaufen.LoadGuildHalls()
    Sauhaufen.LoadEventHouses()
    Sauhaufen.LoadMotD()
    Sauhaufen.LoadRecruitmentText()

    -- print welcome message 5 seconds delayed because the ESO API and its events suck
    zo_callLater(function () Sauhaufen.Welcome() end, 5000)
end

function Sauhaufen:Initialize()
    EVENT_MANAGER:RegisterForEvent("SauhaufenInit", EVENT_PLAYER_ACTIVATED, self.Startup)
    
    Sauhaufen.savedVariables = Sauhaufen.savedVariables or {}
    Sauhaufen.savedVariables = ZO_SavedVars:NewAccountWide("SauhaufenVars", Sauhaufen.variableVersion, nil, Sauhaufen.defaultVariables, GetWorldName())

    self:GUIMenuButtonRestorePosition()
    self:GUIMainMenuRestorePosition()


    if OSI and OSI.AddCustomIconPack then
        -- add your list of icons
        OSI.AddCustomIconPack( SAUHAUFEN_ICONS )
    end
end

function Sauhaufen.OnAddOnLoaded(event, addonName)
  if addonName == Sauhaufen.name then
    Sauhaufen:Initialize()
  end
end

-- event listener for initialization
EVENT_MANAGER:RegisterForEvent(Sauhaufen.name, EVENT_ADD_ON_LOADED, Sauhaufen.OnAddOnLoaded)