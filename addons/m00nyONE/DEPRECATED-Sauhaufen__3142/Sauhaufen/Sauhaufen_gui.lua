Sauhaufen.GUI = {}
Sauhaufen.GUI.MainMenuVisible = false
Sauhaufen.GUI.FirstLoad = true
Sauhaufen.GUI.activeTab = {}
Sauhaufen.GUI.guildhallScrollList = {}
Sauhaufen.GUI.eventsScrollList = {}
Sauhaufen.GUI.gamesScrollList = {}
Sauhaufen.GUI.housingScrollList = {}
Sauhaufen.GUI.lfgTScrollList = {}
Sauhaufen.GUI.lfgHScrollList = {}
Sauhaufen.GUI.lfgDDScrollList = {}
Sauhaufen.GUI.crafterScrollList = {}
Sauhaufen.GUI.werewolfScrollList = {}
Sauhaufen.GUI.vampireScrollList = {}

--[[ Scale ]]--
function Sauhaufen.GUI.Scale(c, from, to)
    if not c then return end
    local a, t = CreateSimpleAnimation(ANIMATION_SCALE, c:GetNamedChild('Texture'))
    a:SetDuration(150)
    a:SetStartScale(from)
    a:SetEndScale(to)
    t:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    t:PlayFromStart()
end



--[[ Scroll lists ]]--


--[[ SORT ]]--
local function SortScrollListSimple(objA, objB) 
    return objA.data.username < objB.data.username
end

local function SortCrafterScrollList(objA, objB)
    if objA.data.isOnline and objB.data.isOnline then
        return objA.data.username < objB.data.username
    end
    if objA.data.isOnline and not objB.data.isOnline then
        return true
    end
    if not objA.data.isOnline and objB.data.isOnline then
        return false
    end
    if not objA.data.isOnline and not objB.data.isOnline then
        return objA.data.username < objB.data.username
    end
end

--[[ ONROWSELECT ]]--
local function OnRowSelectTeleport(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    SetGameCameraUIMode(false)
    Sauhaufen.JumpToHouse(selectedData.username, selectedData.id)
end

local function OnRowSelectWhisper(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    StartChatInput("/w " .. selectedData.username .. " ")
    --GroupInviteByName(selectedData.username)
end

local function OnCrafterRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    if selectedData.isOnline then
        StartChatInput("/w " .. selectedData.username .. " ")
    end
end

--[[ SETUPFUNCTIONS ]]--
local function SetupNPPRow(rowControl, data, scrollList)
    rowControl.name = rowControl:GetNamedChild("Name")
    rowControl.username = rowControl:GetNamedChild("Username")
    rowControl.action = rowControl:GetNamedChild("Action")

    rowControl.name:SetText(data.name)
    rowControl.username:SetText(data.username)
    rowControl.action:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
end

local function SetupGuildhallRow(rowControl, data, scrollList)
    rowControl.name = rowControl:GetNamedChild("Name")
    rowControl.username = rowControl:GetNamedChild("Username")
    rowControl.action = rowControl:GetNamedChild("Action")

    rowControl.name:SetText(data.order .. ". " .. data.name)
    rowControl.username:SetText(data.username)
    rowControl.action:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
end

local function SetupHouseRow(rowControl, data, scrollList)
    rowControl.name = rowControl:GetNamedChild("Name")
    rowControl.house = rowControl:GetNamedChild("House")
    rowControl.username = rowControl:GetNamedChild("Username")
    rowControl.action = rowControl:GetNamedChild("Action")

    rowControl.name:SetText(data.name)
    rowControl.house:SetText(Sauhaufen.GetHouseNameById(data.id))
    rowControl.username:SetText(data.username)
    rowControl.action:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
end

local function SetupLfgRow(rowControl, data, scrollList)
    rowControl:SetText(data.username)
    rowControl:SetFont("ZoFontWinH4")
    rowControl:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
end

local function SetupCrafterRow(rowControl, data, scrollList)
    local text = data.username

    if not data.isOnline then
        text = "|c404040" .. text .. "|r"
    end
    
    rowControl:SetText(text)
    rowControl:SetFont("ZoFontWinH4")
    rowControl:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
end

--[[ CREATE SCROLL LISTS ]]--

-- GUILDHALLS
local function CreateGuildhallScrollList()
    
    local scrollData = {
        name = "GuildhallScrollList",
        parent = SauhaufenMainMenuGuildhalls,
        width = SauhaufenMainMenuGuildhalls:GetWidth(),
        height = SauhaufenMainMenuGuildhalls:GetHeight(),
        rowHeight = 30,
        rowTemplate = "NPPScrollListTemplate",
        selectCallback = OnRowSelectTeleport,
        setupCallback = SetupGuildhallRow,
    }
    
    Sauhaufen.GUI.guildhallScrollList = Sauhaufen.libScroll:CreateScrollList(scrollData)
    Sauhaufen.GUI.guildhallScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuGuildhallsHeaders, BOTTOMLEFT, 0, 10)
    Sauhaufen.GUI.guildhallScrollList:SetAnchor(BOTTOMRIGHT, SauhaufenMainMenuGuildhalls, BOTTOMRIGHT, 0, 0)
    Sauhaufen.GUI.guildhallScrollList:Update(Sauhaufen.guildHalls)
end

-- EVENTS
local function CreateEventsScrollList()
    
    local scrollData = {
        name = "EventsScrollList",
        parent = SauhaufenMainMenuEvents,
        width = SauhaufenMainMenuEvents:GetWidth(),
        rowTemplate = "NPPScrollListTemplate",
        rowHeight = 28,
        sortFunction = SortScrollListSimple,
        selectCallback = OnRowSelectTeleport,
        setupCallback = SetupNPPRow,
    }
    
    Sauhaufen.GUI.eventsScrollList = Sauhaufen.libScroll:CreateScrollList(scrollData)
    Sauhaufen.GUI.eventsScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuEventsHeaders, BOTTOMLEFT, 0, 10)
    Sauhaufen.GUI.eventsScrollList:SetAnchor(BOTTOMRIGHT, SauhaufenMainMenuEvents, BOTTOMRIGHT, 0, 0)
    Sauhaufen.GUI.eventsScrollList:Update(Sauhaufen.eventHouses)
end

-- GAMES
local function CreateGamesScrollList()
    
    local scrollData = {
        name = "GamesScrollList",
        parent = SauhaufenMainMenuGames,
        width = SauhaufenMainMenuGames:GetWidth(),
        rowTemplate = "NPPScrollListTemplate",
        rowHeight = 28,
        sortFunction = SortScrollListSimple,
        selectCallback = OnRowSelectTeleport,
        setupCallback = SetupNPPRow,
    }
    
    Sauhaufen.GUI.gamesScrollList = Sauhaufen.libScroll:CreateScrollList(scrollData)
    Sauhaufen.GUI.gamesScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuGamesHeaders, BOTTOMLEFT, 0, 10)
    Sauhaufen.GUI.gamesScrollList:SetAnchor(BOTTOMRIGHT, SauhaufenMainMenuGames, BOTTOMRIGHT, 0, 0)
    Sauhaufen.GUI.gamesScrollList:Update(Sauhaufen.games)
end

-- HOUSING
local function CreateHousingScrollList()
    
    local scrollData = {
        name = "HousingScrollList",
        parent = SauhaufenMainMenuHousing,
        width = SauhaufenMainMenuHousing:GetWidth(),
        rowTemplate = "HousingScrollListTemplate",
        rowHeight = 28,
        selectCallback = OnRowSelectTeleport,
        setupCallback = SetupHouseRow,
        sortFunction = SortScrollListSimple,
    }

    Sauhaufen.GUI.housingScrollList = Sauhaufen.libScroll:CreateScrollList(scrollData)
    Sauhaufen.GUI.housingScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuHousingHeaders, BOTTOMLEFT, 0, 10)
    Sauhaufen.GUI.housingScrollList:SetAnchor(BOTTOMRIGHT, SauhaufenMainMenuHousing, BOTTOMRIGHT, 0, 0)
    Sauhaufen.GUI.housingScrollList:Update(Sauhaufen.houses)
end

-- LFG
local function CreateLfgScrollLists()
    
    local thirdOfWidth = (SauhaufenMainMenuLfg:GetWidth() - 30) / 3

    local scrollDataT = {
        name = "LfgTScrollList",
        parent = SauhaufenMainMenuLfg,
        width = thirdOfWidth,
        height = SauhaufenMainMenuLfg:GetHeight() - 40,
        rowHeight = 28,
        selectCallback = OnRowSelectWhisper,
        setupCallback = SetupLfgRow,
        sortFunction = SortScrollListSimple,
    }
    local scrollDataH = {
        name = "LfgHScrollList",
        parent = SauhaufenMainMenuLfg,
        width = thirdOfWidth,
        height = SauhaufenMainMenuLfg:GetHeight() - 40,
        rowHeight = 28,
        selectCallback = OnRowSelectWhisper,
        setupCallback = SetupLfgRow,
        sortFunction = SortScrollListSimple,
    }
    local scrollDataDD = {
        name = "LfgDDScrollList",
        parent = SauhaufenMainMenuLfg,
        width = thirdOfWidth,
        height = SauhaufenMainMenuLfg:GetHeight() - 40,
        rowHeight = 28,
        selectCallback = OnRowSelectWhisper,
        setupCallback = SetupLfgRow,
        sortFunction = SortScrollListSimple,
    }

    Sauhaufen.GUI.lfgTScrollList = Sauhaufen.libScroll:CreateScrollList(scrollDataT)
    Sauhaufen.GUI.lfgTScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuLfg, TOPLEFT, 5, 35)
    Sauhaufen.GUI.lfgTScrollList.bg = WINDOW_MANAGER:CreateControlFromVirtual("TBg", Sauhaufen.GUI.lfgTScrollList, "ZO_DefaultBackdrop")
    Sauhaufen.GUI.lfgTScrollList.bg:SetAnchor(TOPLEFT, Sauhaufen.GUI.lfgTScrollList, TOPLEFT, -2 , -2)
    Sauhaufen.GUI.lfgTScrollList.bg:SetAnchor(BOTTOMRIGHT, Sauhaufen.GUI.lfgTScrollList, BOTTOMRIGHT, 2 , 2)
    Sauhaufen.GUI.lfgTScrollList.Label = WINDOW_MANAGER:CreateControl("TLabel", Sauhaufen.GUI.lfgTScrollList.bg, CT_LABEL)
    Sauhaufen.GUI.lfgTScrollList.Label:SetAnchor(BOTTOM, Sauhaufen.GUI.lfgTScrollList, TOP, 0 , -5)
    Sauhaufen.GUI.lfgTScrollList.Label:SetFont("ZoFontWinH4")
    Sauhaufen.GUI.lfgTScrollList.Label:SetColor(0.32,0.32,0.85)
    Sauhaufen.GUI.lfgTScrollList.Label:SetText("Verteidiger")
    Sauhaufen.GUI.lfgTScrollList:Update(Sauhaufen.RoleT)

    Sauhaufen.GUI.lfgHScrollList = Sauhaufen.libScroll:CreateScrollList(scrollDataH)
    Sauhaufen.GUI.lfgHScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuLfg, TOPLEFT, 15 + thirdOfWidth, 35)
    Sauhaufen.GUI.lfgHScrollList.bg = WINDOW_MANAGER:CreateControlFromVirtual("HBg", Sauhaufen.GUI.lfgHScrollList, "ZO_DefaultBackdrop")
    Sauhaufen.GUI.lfgHScrollList.bg:SetAnchor(TOPLEFT, Sauhaufen.GUI.lfgHScrollList, TOPLEFT, -2 , -2)
    Sauhaufen.GUI.lfgHScrollList.bg:SetAnchor(BOTTOMRIGHT, Sauhaufen.GUI.lfgHScrollList, BOTTOMRIGHT, 2 , 2)
    Sauhaufen.GUI.lfgHScrollList.Label = WINDOW_MANAGER:CreateControl("HLabel", Sauhaufen.GUI.lfgHScrollList.bg, CT_LABEL)
    Sauhaufen.GUI.lfgHScrollList.Label:SetAnchor(BOTTOM, Sauhaufen.GUI.lfgHScrollList, TOP, 0 , -5)
    Sauhaufen.GUI.lfgHScrollList.Label:SetFont("ZoFontWinH4")
    Sauhaufen.GUI.lfgHScrollList.Label:SetColor(0.32,0.85,0.32)
    Sauhaufen.GUI.lfgHScrollList.Label:SetText("Heiler")
    Sauhaufen.GUI.lfgHScrollList:Update(Sauhaufen.RoleH)
    
    Sauhaufen.GUI.lfgDDScrollList = Sauhaufen.libScroll:CreateScrollList(scrollDataDD)
    Sauhaufen.GUI.lfgDDScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuLfg, TOPLEFT, 25 +  2 * thirdOfWidth, 35)
    Sauhaufen.GUI.lfgDDScrollList.bg = WINDOW_MANAGER:CreateControlFromVirtual("DDBg", Sauhaufen.GUI.lfgDDScrollList, "ZO_DefaultBackdrop")
    Sauhaufen.GUI.lfgDDScrollList.bg:SetAnchor(TOPLEFT, Sauhaufen.GUI.lfgDDScrollList, TOPLEFT, -2 , -2)
    Sauhaufen.GUI.lfgDDScrollList.bg:SetAnchor(BOTTOMRIGHT, Sauhaufen.GUI.lfgDDScrollList, BOTTOMRIGHT, 2 , 2)
    Sauhaufen.GUI.lfgDDScrollList.Label = WINDOW_MANAGER:CreateControl("DDLabel", Sauhaufen.GUI.lfgDDScrollList.bg, CT_LABEL)
    Sauhaufen.GUI.lfgDDScrollList.Label:SetAnchor(BOTTOM, Sauhaufen.GUI.lfgDDScrollList, TOP, 0 , -5)
    Sauhaufen.GUI.lfgDDScrollList.Label:SetFont("ZoFontWinH4")
    Sauhaufen.GUI.lfgDDScrollList.Label:SetColor(0.85,0.32,0.32)
    Sauhaufen.GUI.lfgDDScrollList.Label:SetText("Kämpfer")
    Sauhaufen.GUI.lfgDDScrollList:Update(Sauhaufen.RoleDD)
end


local function CreateCrafterScrollLists()
    
    local scrollData = {
        name = "CrafterScrollList",
        parent = SauhaufenMainMenuCrafter,
        width = (SauhaufenMainMenuCrafter:GetWidth() -10) / 3 + 50,
        height = SauhaufenMainMenuCrafter:GetHeight() - 10,
        rowHeight = 28,
        selectCallback = OnRowSelectWhisper,
        setupCallback = SetupCrafterRow,
        sortFunction    = SortCrafterScrollList,
    }

    Sauhaufen.GUI.crafterScrollList = Sauhaufen.libScroll:CreateScrollList(scrollData)
    Sauhaufen.GUI.crafterScrollList:SetAnchor(TOPRIGHT, SauhaufenMainMenuCrafter, TOPRIGHT, -5, 5)
    Sauhaufen.GUI.crafterScrollList.bg = WINDOW_MANAGER:CreateControlFromVirtual("CrafterBg", Sauhaufen.GUI.crafterScrollList, "ZO_DefaultBackdrop")
    Sauhaufen.GUI.crafterScrollList.bg:SetAnchor(TOPLEFT, Sauhaufen.GUI.crafterScrollList, TOPLEFT, -2 , -2)
    Sauhaufen.GUI.crafterScrollList.bg:SetAnchor(BOTTOMRIGHT, Sauhaufen.GUI.crafterScrollList, BOTTOMRIGHT, 2 , 2)
    Sauhaufen.GUI.crafterScrollList.Label = WINDOW_MANAGER:CreateControl("CrafterLabel", Sauhaufen.GUI.crafterScrollList.bg, CT_LABEL)
    Sauhaufen.GUI.crafterScrollList.Label:SetAnchor(TOPLEFT, SauhaufenMainMenuCrafter, TOPLEFT, 5 , 5)
    Sauhaufen.GUI.crafterScrollList.Label:SetFont("ZoFontWinH4")
    Sauhaufen.GUI.crafterScrollList.Label:SetColor(1,0.64,0)
    Sauhaufen.GUI.crafterScrollList.Label:SetText("Hier findet ihr die Meisterhandwerker der Gilde.\n\nSie haben alle Traits erlernt und können euch\nGegenstände zum Analysieren herstellen.")
    Sauhaufen.GUI.crafterScrollList:Update(Sauhaufen.RoleMasterCrafter)
end

local function CreateWerewolfVampireScrollLists()
    
    local thirdOfWidth = (SauhaufenMainMenuWerewolfVampire:GetWidth() - 30) / 3

    local scrollDataH = {
        name = "WerewolfScrollList",
        parent = SauhaufenMainMenuWerewolfVampire,
        width = thirdOfWidth,
        height = SauhaufenMainMenuWerewolfVampire:GetHeight() - 40,
        rowHeight = 28,
        selectCallback = OnRowSelectWhisper,
        setupCallback = SetupCrafterRow,
        sortFunction    = SortCrafterScrollList,
    }
    local scrollDataDD = {
        name = "VampireScrollList",
        parent = SauhaufenMainMenuWerewolfVampire,
        width = thirdOfWidth,
        height = SauhaufenMainMenuWerewolfVampire:GetHeight() - 40,
        rowHeight = 28,
        selectCallback = OnRowSelectWhisper,
        setupCallback = SetupCrafterRow,
        sortFunction    = SortCrafterScrollList,
    }

    Sauhaufen.GUI.werewolfScrollList = Sauhaufen.libScroll:CreateScrollList(scrollDataH)
    Sauhaufen.GUI.werewolfScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuWerewolfVampire, TOPLEFT, 15 + thirdOfWidth, 35)
    Sauhaufen.GUI.werewolfScrollList.bg = WINDOW_MANAGER:CreateControlFromVirtual("WBg", Sauhaufen.GUI.werewolfScrollList, "ZO_DefaultBackdrop")
    Sauhaufen.GUI.werewolfScrollList.bg:SetAnchor(TOPLEFT, Sauhaufen.GUI.werewolfScrollList, TOPLEFT, -2 , -2)
    Sauhaufen.GUI.werewolfScrollList.bg:SetAnchor(BOTTOMRIGHT, Sauhaufen.GUI.werewolfScrollList, BOTTOMRIGHT, 2 , 2)
    Sauhaufen.GUI.werewolfScrollList.Label = WINDOW_MANAGER:CreateControl("WLabel", Sauhaufen.GUI.werewolfScrollList.bg, CT_LABEL)
    Sauhaufen.GUI.werewolfScrollList.Label:SetAnchor(BOTTOM, Sauhaufen.GUI.werewolfScrollList, TOP, 0 , -5)
    Sauhaufen.GUI.werewolfScrollList.Label:SetFont("ZoFontWinH4")
    Sauhaufen.GUI.werewolfScrollList.Label:SetColor(0.32,0.85,0.32)
    Sauhaufen.GUI.werewolfScrollList.Label:SetText("Werwolf")
    Sauhaufen.GUI.werewolfScrollList:Update(Sauhaufen.RoleWerewolf)
    
    Sauhaufen.GUI.vampireScrollList = Sauhaufen.libScroll:CreateScrollList(scrollDataDD)
    Sauhaufen.GUI.vampireScrollList:SetAnchor(TOPLEFT, SauhaufenMainMenuWerewolfVampire, TOPLEFT, 25 +  2 * thirdOfWidth, 35)
    Sauhaufen.GUI.vampireScrollList.bg = WINDOW_MANAGER:CreateControlFromVirtual("VBg", Sauhaufen.GUI.vampireScrollList, "ZO_DefaultBackdrop")
    Sauhaufen.GUI.vampireScrollList.bg:SetAnchor(TOPLEFT, Sauhaufen.GUI.vampireScrollList, TOPLEFT, -2 , -2)
    Sauhaufen.GUI.vampireScrollList.bg:SetAnchor(BOTTOMRIGHT, Sauhaufen.GUI.vampireScrollList, BOTTOMRIGHT, 2 , 2)
    Sauhaufen.GUI.vampireScrollList.Label = WINDOW_MANAGER:CreateControl("VLabel", Sauhaufen.GUI.vampireScrollList.bg, CT_LABEL)
    Sauhaufen.GUI.vampireScrollList.Label:SetAnchor(BOTTOM, Sauhaufen.GUI.vampireScrollList, TOP, 0 , -5)
    Sauhaufen.GUI.vampireScrollList.Label:SetFont("ZoFontWinH4")
    Sauhaufen.GUI.vampireScrollList.Label:SetColor(0.85,0.32,0.32)
    Sauhaufen.GUI.vampireScrollList.Label:SetText("Vampir")
    Sauhaufen.GUI.vampireScrollList:Update(Sauhaufen.RoleVampire)


    Sauhaufen.GUI.werewolfScrollList.Description = WINDOW_MANAGER:CreateControl("WerewolfVampireDescription", Sauhaufen.GUI.werewolfScrollList.bg, CT_LABEL)
    Sauhaufen.GUI.werewolfScrollList.Description:SetAnchor(TOPLEFT, SauhaufenMainMenuWerewolfVampire, TOPLEFT, 5 , 30)
    Sauhaufen.GUI.werewolfScrollList.Description:SetFont("ZoFontWinH4")
    Sauhaufen.GUI.werewolfScrollList.Description:SetColor(1,0.64,0)
    Sauhaufen.GUI.werewolfScrollList.Description:SetText("Hier seht ihr die Werwölfe und\nVampire der Gilde.\n\nSie können helfen euch in\nschweinige Werwölfe oder\nVampire zu verwandeln.")

end

--[[

]]--

function Sauhaufen:GUIMenuButtonRestorePosition()
    if self.savedVariables.GUI.SauhaufenMenuButton ~= nil then
        local btnPos = self.savedVariables.GUI.SauhaufenMenuButton
 
        SauhaufenMenuButtonButtonBG:ClearAnchors()
        SauhaufenMenuButtonButtonBG:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btnPos[1], btnPos[2])
    else
        self.savedVariables.GUI.SauhaufenMenuButton = { 0, 0}
    end
end

function Sauhaufen:GUIMainMenuRestorePosition()
    if self.savedVariables.GUI.SauhaufenMainMenu ~= nil then
        local pos = self.savedVariables.GUI.SauhaufenMainMenu
        SauhaufenMainMenu:ClearAnchors()
        SauhaufenMainMenu:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos[1], pos[2])
    else
        self.savedVariables.GUI.SauhaufenMainMenu = { 0, 0}
    end

    if Sauhaufen.GUI.FirstLoad then
        CreateGuildhallScrollList()
        CreateEventsScrollList()
        CreateGamesScrollList()
        CreateHousingScrollList()
        CreateLfgScrollLists()
        CreateCrafterScrollLists()
        CreateWerewolfVampireScrollLists()
        Sauhaufen.GUI.guildhallScrollList:SetHidden(true)
        Sauhaufen.GUI.eventsScrollList:SetHidden(true)
        Sauhaufen.GUI.gamesScrollList:SetHidden(true)
        Sauhaufen.GUI.housingScrollList:SetHidden(true)
        Sauhaufen.GUI.lfgTScrollList:SetHidden(true)
        Sauhaufen.GUI.lfgHScrollList:SetHidden(true)
        Sauhaufen.GUI.lfgDDScrollList:SetHidden(true)
        Sauhaufen.GUI.crafterScrollList:SetHidden(true)
        Sauhaufen.GUI.werewolfScrollList:SetHidden(true)
        Sauhaufen.GUI.vampireScrollList:SetHidden(true)
        SauhaufenMainMenuHousingHeadersName:SetHidden(true)
        SauhaufenMainMenuHousingHeadersHouse:SetHidden(true)
        SauhaufenMainMenuHousingHeadersUsername:SetHidden(true)
        SauhaufenMainMenuEventsHeadersName:SetHidden(true)
        SauhaufenMainMenuEventsHeadersUsername:SetHidden(true)
        SauhaufenMainMenuGuildhallsHeadersName:SetHidden(true)
        SauhaufenMainMenuGuildhallsHeadersUsername:SetHidden(true)
        SauhaufenMainMenuGamesHeadersName:SetHidden(true)
        SauhaufenMainMenuGamesHeadersUsername:SetHidden(true)
        SauhaufenMainMenuNavBarInfoIcon:SetEnabled(false)

        Sauhaufen.GUISetup()

        Sauhaufen.GUI.FirstLoad = false
    end
end

function Sauhaufen.GUIToggleMain()
    Sauhaufen.GUI.MainMenuVisible = not Sauhaufen.GUI.MainMenuVisible
    SauhaufenMainMenu:SetHidden(not Sauhaufen.GUI.MainMenuVisible)

    if Sauhaufen.GUI.MainMenuVisible then
        SauhaufenMainMenuInfoMOTD:SetText(Sauhaufen.motd)
        SetGameCameraUIMode(true)
    end
end

function Sauhaufen.GUIHideAllSubWindows()
    SauhaufenMainMenuInfo:SetHidden(true)
    SauhaufenMainMenuGuildhalls:SetHidden(true)
    SauhaufenMainMenuEvents:SetHidden(true)
    SauhaufenMainMenuGames:SetHidden(true)
    SauhaufenMainMenuHousing:SetHidden(true)
    SauhaufenMainMenuLfg:SetHidden(true)
    SauhaufenMainMenuCrafter:SetHidden(true)
    SauhaufenMainMenuWerewolfVampire:SetHidden(true)

    SauhaufenMainMenuNavBarInfoIcon:SetEnabled(true)
    SauhaufenMainMenuNavBarGuildhallsIcon:SetEnabled(true)
    SauhaufenMainMenuNavBarEventIcon:SetEnabled(true)
    SauhaufenMainMenuNavBarGamesIcon:SetEnabled(true)
    SauhaufenMainMenuNavBarHousingIcon:SetEnabled(true)
    SauhaufenMainMenuNavBarLfgIcon:SetEnabled(true)
    SauhaufenMainMenuNavBarCrafterIcon:SetEnabled(true)
    SauhaufenMainMenuNavBarWerewolfVampireIcon:SetEnabled(true)
end

function Sauhaufen.GUISetup()
    if Sauhaufen.savedVariables.showAddonButton == true then
        SauhaufenMenuButton:SetHidden(false)
        SauhaufenMenuButtonButtonBG:SetHidden(false)
    else
        SauhaufenMenuButton:SetHidden(true)
        SauhaufenMenuButtonButtonBG:SetHidden(true)
    end
end

function Sauhaufen.GUIActivateInfo()
    SauhaufenMainMenuInfo:SetHidden(false)

    SauhaufenMainMenuInfoMOTD:SetText(Sauhaufen.motd)
end

function Sauhaufen.GUIActivateGuildhalls()
    SauhaufenMainMenuGuildhalls:SetHidden(false)
    GuildhallScrollList:SetHidden(false)
    SauhaufenMainMenuGuildhallsHeadersName:SetHidden(false)
    SauhaufenMainMenuGuildhallsHeadersUsername:SetHidden(false)
    Sauhaufen.LoadGuildHalls()

    Sauhaufen.GUI.guildhallScrollList:Update(Sauhaufen.guildHalls)
end

function Sauhaufen.GUIActivateEvents()
    SauhaufenMainMenuEvents:SetHidden(false)
    EventsScrollList:SetHidden(false)
    SauhaufenMainMenuEventsText:SetHidden(true)
    SauhaufenMainMenuEventsHeadersName:SetHidden(false)
    SauhaufenMainMenuEventsHeadersUsername:SetHidden(false)
    Sauhaufen.LoadEventHouses()
    Sauhaufen.GUI.eventsScrollList:Update(Sauhaufen.eventHouses)

    if table.getn(Sauhaufen.eventHouses) == 0 then
        SauhaufenMainMenuEventsText:SetHidden(false)
        SauhaufenMainMenuEventsHeadersName:SetHidden(true)
        SauhaufenMainMenuEventsHeadersUsername:SetHidden(true)
    end
end

function Sauhaufen.GUIActivateGames()
    SauhaufenMainMenuGames:SetHidden(false)
    GamesScrollList:SetHidden(false)
    SauhaufenMainMenuGamesText:SetHidden(true)
    SauhaufenMainMenuGamesHeadersName:SetHidden(false)
    SauhaufenMainMenuGamesHeadersUsername:SetHidden(false)
    Sauhaufen.LoadGames()
    Sauhaufen.GUI.gamesScrollList:Update(Sauhaufen.games)

    if table.getn(Sauhaufen.games) == 0 then
        SauhaufenMainMenuGamesText:SetHidden(false)
        SauhaufenMainMenuGamesHeadersName:SetHidden(true)
        SauhaufenMainMenuGamesHeadersUsername:SetHidden(true)
    end
end

function Sauhaufen.GUIActivateHousing()
    SauhaufenMainMenuHousing:SetHidden(false)
    HousingScrollList:SetHidden(false)
    SauhaufenMainMenuHousingText:SetHidden(true)
    SauhaufenMainMenuHousingHeadersName:SetHidden(false)
    SauhaufenMainMenuHousingHeadersHouse:SetHidden(false)
    SauhaufenMainMenuHousingHeadersUsername:SetHidden(false)

    Sauhaufen.LoadHouses()
    Sauhaufen.GUI.housingScrollList:Update(Sauhaufen.houses)

    if table.getn(Sauhaufen.houses) == 0 then
        SauhaufenMainMenuHousingText:SetHidden(false)
    end
end

function Sauhaufen.GUIActivateLfg()
    SauhaufenMainMenuLfg:SetHidden(false)
    LfgTScrollList:SetHidden(false)
    LfgHScrollList:SetHidden(false)
    LfgDDScrollList:SetHidden(false)

    Sauhaufen.LoadRoles()
    Sauhaufen.GUI.lfgTScrollList:Update(Sauhaufen.RoleT)
    Sauhaufen.GUI.lfgHScrollList:Update(Sauhaufen.RoleH)
    Sauhaufen.GUI.lfgDDScrollList:Update(Sauhaufen.RoleDD)
end

function Sauhaufen.GUIActivateCrafter()
    SauhaufenMainMenuCrafter:SetHidden(false)
    CrafterScrollList:SetHidden(false)

    Sauhaufen.LoadRoles()
    Sauhaufen.GUI.crafterScrollList:Update(Sauhaufen.RoleMasterCrafter)
end

function Sauhaufen.GUIActivateWerewolfVampire()
    SauhaufenMainMenuWerewolfVampire:SetHidden(false)
    VampireScrollList:SetHidden(false)
    WerewolfScrollList:SetHidden(false)

    Sauhaufen.LoadRoles()
    Sauhaufen.GUI.vampireScrollList:Update(Sauhaufen.RoleVampire)
    Sauhaufen.GUI.werewolfScrollList:Update(Sauhaufen.RoleWerewolf)
end