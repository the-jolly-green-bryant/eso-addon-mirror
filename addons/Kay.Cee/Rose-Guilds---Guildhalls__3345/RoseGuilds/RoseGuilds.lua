local RG = _G["RoseGuilds"] or {}
_G["RoseGuilds"] = RG
RG.name = "RoseGuilds"
RG.Author = "Kay.Cee"
RG.version = "07.14.26"

-- Don't load on NA
if GetWorldName() == "NA Megaserver" then return end

RG.savedVars = {
    MidnightHidden = false,
    SpringHidden = false,
    SummerHidden = false,
    AutumnHidden = false,
    WinterHidden = false,
    RoseMenuX = 175,
    RoseMenuY = 8,
    MidnightX = 215,
    MidnightY = 10,
    SpringX = 250,
    SpringY = 10,
    SummerX = 285,
    SummerY = 10,
    AutumnX = 320,
    AutumnY = 10,
    WinterX = 355,
    WinterY = 10,
    IconAboveHeadVisible = true,
    IconAboveHeadSize = 64,
    IconAboveHeadShowPlayer = true,
    IconAboveHeadGroupOnly = true,    
    IconAboveHeadOffset = 3.2,
}

RG.Controls = {}

local LAM = LibAddonMenu2

local function InitializeIcons()
    if not RG.Icons then
        d(RG.name .. ": Rose Icons failed to initialize")
        return
    end
end

EVENT_MANAGER:RegisterForEvent(RG.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= RG.name then return end
    
    RG:CreateSettingsMenu()
    InitializeIcons()
    RG:CreateRoseButtons()

    ZO_CreateStringId("SI_BINDING_NAME_MISI_HALL", "|c6A5ACDQueenMisi's |cFFFFFFGuildhall")
    ZO_CreateStringId("SI_BINDING_NAME_KAYCEE_HALL", "|c0077FFKay.Cee's |cFFFFFFGuildhall")
    ZO_CreateStringId("SI_BINDING_NAME_SURI_HALL", "|cF1C900SuriValkyrie's |cFFFFFFGuildhall")
    ZO_CreateStringId("SI_BINDING_NAME_RANDOM_HALL", "|cE036FFRandom |cFFFFFFGuildhall")

    SLASH_COMMANDS["/misihall"] = function() RG:MisiHall() end
    SLASH_COMMANDS["/kayceehall"] = function() RG:KayCeeHall() end
    SLASH_COMMANDS["/surihall"] = function() RG:SuriHall() end
    SLASH_COMMANDS["/randomhall"] = function() RG:RandomHall() end
    SLASH_COMMANDS["/resetroses"] = function() RG:ResetRose() end

    EVENT_MANAGER:UnregisterForEvent(RG.name, EVENT_ADD_ON_LOADED)
end)

-- Get players icon
function RG:GetPlayerIcon(username)
    if not self.Icons then return nil end
    return self.Icons:GetStatic(username)
end

-- Check if player has icon
function RG:HasPlayerIcon(username)
    if not self.Icons then return false end
    return self.Icons:HasStatic(username)
end


-- Guildhall functions
function RG:RandomHall()
    local accountName = GetDisplayName()
    if accountName == "@QueenMisi" then
        RequestJumpToHouse(47)
        d("Jumping to The Gloam Regent’s Hall")
        return
    elseif accountName == "@Kay.Cee" then
        RequestJumpToHouse(129)
        d("Jumping to Winter's Dancing Spring")
        return
    elseif accountName == "@SuriValkyrie" then
        RequestJumpToHouse(94)
        d("Jumping to The Seaglass Sanctuary")
        return
    else
        local halloptions = {
            { name = "@QueenMisi", houseId = 47, message = "Jumping to The Gloam Regent’s Hall" },
            { name = "@Kay.Cee", houseId = 129, message = "Jumping to Winter's Dancing Spring" },
            { name = "@SuriValkyrie", houseId = 94, message = "Jumping to The Seaglass Sanctuary" }
        }
        local choice = halloptions[math.random(1, #halloptions)]
        JumpToSpecificHouse(choice.name, choice.houseId)
        d(choice.message)
    end
end
function RG:MisiHall()
    local accountName = GetDisplayName()
    if accountName == "@QueenMisi" then
        RequestJumpToHouse(47)
        d("Jumping to The Gloam Regent’s GuildHall")
    else
        JumpToSpecificHouse("@QueenMisi", 47)
        d("Jumping to The Gloam Regent’s GuildHall")
    end
end
function RG:KayCeeHall()
    local accountName = GetDisplayName()
    if accountName == "@Kay.Cee" then
        RequestJumpToHouse(129)
        d("Jumping to Winter's Dancing Spring")
    else
        JumpToSpecificHouse("@Kay.Cee", 129)
        d("Jumping to Winter's Dancing Spring")
    end
end
function RG:SuriHall()
    local accountName = GetDisplayName()
    if accountName == "@SuriValkyrie" then
        RequestJumpToHouse(94)
        d("Jumping to The Seaglass Sanctuary")
    else
        JumpToSpecificHouse("@SuriValkyrie", 94)
        d("Jumping to The Seaglass Sanctuary")
    end
end

-- Menu Setup
local function ShowTooltip(control)
    InitializeTooltip(InformationTooltip, control)
    SetTooltipText(InformationTooltip, "|ce036ffRoseGuilds |cFFFFFFMenu|r")
end

local function HideTooltip()
    ClearTooltip(InformationTooltip)
end

local function OnMouseUp(control, button, upInside)
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
        RG:RandomHall()
	end
end
    
local function DisplayRoseMenu()
    local RoseGuilds = {
        { label = "|cFFFFFFJoin |c6a5acdMidnight Rose", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:586676|hMidnight Rose|h", 1) end },
        { label = "|cFFFFFFJoin |c0077ffWinter Rose", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:422980|hWinter Rose|h", 1) end },
        { label = "|cFFFFFFJoin |c00ff7fSpring Rose", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:496448|hSpring Rose|h", 1) end },
        { label = "|cFFFFFFJoin |cf10000Summer Rose", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:569338|hSummer Rose|h", 1) end },
        { label = "|cFFFFFFJoin |cffd971Autumn Rose", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:553666|hAutumn Rose|h", 1) end }
    }

    local Guildhalls = {
        { label = "|cFFFFFFVisit |cffd971QueenMisi's Guildhall", callback = function() RG:MisiHall() end },
        { label = "|cFFFFFFVisit |c0077ffKay.Cee's Guildhall", callback = function() RG:KayCeeHall() end },
		{ label = "|cFFFFFFVisit |cf10000SuriValkyrie's Guildhall", callback = function() RG:SuriHall() end },
		{ label = "|cce036fSu|cc90085rp|cbc099dri|caa00bbse |c8700e0Me|c302bff!", callback = function() RG:RandomHall() end }
    }

    ClearMenu()
    AddCustomSubMenuItem("|c6a5abdRose |cFFFFFFGuilds", RoseGuilds)
    AddCustomSubMenuItem("|c0077ffRose |cFFFFFFGuild Halls", Guildhalls)
    AddCustomMenuItem("|c00ff7fRose |cFFFFFFWebsite", function() RequestOpenUnsafeURL("https://www.roseguilds.com") end)
    AddCustomMenuItem("|cf10000Rose |cFFFFFFDiscord", function() RequestOpenUnsafeURL("https://discord.gg/roseguilds") end)
    AddCustomMenuItem("|cffd971Crown Trading |cFFFFFFDiscord", function() RequestOpenUnsafeURL("https://discord.gg/kEgFrNW") end)
    ShowMenu()
end

-- Set to default
function RG:ResetRose()
    local SingleRoses = {
        {var = 'MidnightHidden', element = Midnight},
        {var = 'SpringHidden', element = Spring},
        {var = 'SummerHidden', element = Summer},
        {var = 'AutumnHidden', element = Autumn},
        {var = 'WinterHidden', element = Winter}
    }

    for i, item in ipairs(SingleRoses) do
        RG.savedVars[item.var] = item.element:SetHidden(false)
        item.element:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars[item.var .. 'X'], RG.savedVars[item.var .. 'Y'])
    end

    RoseMenu:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 175, 8)
    RG.savedVars.RoseMenuX = 175
    RG.savedVars.RoseMenuY = 8
    Midnight:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 215, 10)
    RG.savedVars.MidnightX = 215
    RG.savedVars.MidnightY = 10
    Spring:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 250, 10)
    RG.savedVars.SpringX = 250
    RG.savedVars.SpringY = 10
    Summer:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 285, 10)
    RG.savedVars.SummerX = 285
    RG.savedVars.SummerY = 10
    Autumn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 320, 10)
    RG.savedVars.AutumnX = 320
    RG.savedVars.AutumnY = 10
    Winter:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 355, 10)
    RG.savedVars.WinterX = 355
    RG.savedVars.WinterY = 10
end

-- Single Rose options
function RG:SingleRose(showSingleRose)
    local SingleRoses = {
        {var = 'MidnightHidden', element = Midnight},
        {var = 'SpringHidden', element = Spring},
        {var = 'SummerHidden', element = Summer},
        {var = 'AutumnHidden', element = Autumn},
        {var = 'WinterHidden', element = Winter}
    }
    for i, item in ipairs(SingleRoses) do
        if item.element ~= showSingleRose then
            RG.savedVars[item.var] = item.element:SetHidden(true)
            RG.savedVars[item.var] = not RG.savedVars[item.var]
        else
            RG.savedVars[item.var] = item.element:SetHidden(false)
            RG.savedVars[item.var] = RG.savedVars[item.var]

            item.element:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.MidnightX, RG.savedVars.MidnightY)
        end
    end
end

-- Toggle options
local function MidnightToggle()
        RG:SingleRose(Midnight)
        RG.savedVars.MidnightX = 215
end
local function SpringToggle()
    RG:SingleRose(Spring)
        RG.savedVars.SpringX = 215
    end

local function SummerToggle()
    RG:SingleRose(Summer)
        RG.savedVars.SummerX = 215
end
local function AutumnToggle()
    RG:SingleRose(Autumn)
        RG.savedVars.AutumnX = 215
end
local function WinterToggle()
    RG:SingleRose(Winter)
        RG.savedVars.WinterX = 215
end
local function MenuToggle()
    RG:SingleRose(nil)
end
--Slash commands
SLASH_COMMANDS["/midnightrose"] = MidnightToggle
SLASH_COMMANDS["/springrose"] = SpringToggle
SLASH_COMMANDS["/summerrose"] = SummerToggle
SLASH_COMMANDS["/autumnrose"] = AutumnToggle
SLASH_COMMANDS["/winterrose"] = WinterToggle
SLASH_COMMANDS["/rosemenu"] = MenuToggle

function RG:CreateRoseButtons()
    RG.savedVars = ZO_SavedVars:NewAccountWide("RoseGuildsSavedVariables", 1, nil, RG.savedVars)
    -- Guildhall Buttons
    RG.Controls.Midnight = WINDOW_MANAGER:CreateControl("RG_MidnightButton", ZO_ChatWindow, CT_BUTTON)
    RG.Controls.Midnight:SetDimensions(25, 25)
    RG.Controls.Midnight:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "|c6a5acdQueenMisi's |cffffffGuildhall|r") end)
    RG.Controls.Midnight:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    RG.Controls.Midnight:SetHandler("OnClicked", function(control) RG:MisiHall() end)
    RG.Controls.Midnight:SetNormalTexture("RoseGuilds/Icons/Base/Midnight.dds")
    RG.Controls.Midnight:SetHidden(RG.savedVars.MidnightHidden)
    RG.Controls.Midnight:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.MidnightX, RG.savedVars.MidnightY)
    Midnight = RG.Controls.Midnight

    RG.Controls.Spring = WINDOW_MANAGER:CreateControl("RG_SpringButton", ZO_ChatWindow, CT_BUTTON)
    RG.Controls.Spring:SetDimensions(25, 25)
    RG.Controls.Spring:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "|c00ff7fRandom Rose |cffffffGuildhall|r") end)
    RG.Controls.Spring:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    RG.Controls.Spring:SetHandler("OnClicked", function(control) RG:RandomHall() end)
    RG.Controls.Spring:SetNormalTexture("RoseGuilds/Icons/Base/Spring.dds")
    RG.Controls.Spring:SetHidden(RG.savedVars.SpringHidden)
    RG.Controls.Spring:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.SpringX, RG.savedVars.SpringY)
    Spring = RG.Controls.Spring

    RG.Controls.Summer = WINDOW_MANAGER:CreateControl("RG_SummerButton", ZO_ChatWindow, CT_BUTTON)
    RG.Controls.Summer:SetDimensions(25, 25)
    RG.Controls.Summer:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "|cf10000SuriValkyrie's |cffffffGuildhall|r") end)
    RG.Controls.Summer:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    RG.Controls.Summer:SetHandler("OnClicked", function(control) RG:SuriHall() end)
    RG.Controls.Summer:SetNormalTexture("RoseGuilds/Icons/Base/Summer.dds")
    RG.Controls.Summer:SetHidden(RG.savedVars.SummerHidden)
    RG.Controls.Summer:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.SummerX, RG.savedVars.SummerY)
    Summer = RG.Controls.Summer

    RG.Controls.Autumn = WINDOW_MANAGER:CreateControl("RG_AutumnButton", ZO_ChatWindow, CT_BUTTON)
    RG.Controls.Autumn:SetDimensions(25, 25)
    RG.Controls.Autumn:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "|cffd971QueenMisi's |cffffffGuildhall|r") end)
    RG.Controls.Autumn:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    RG.Controls.Autumn:SetHandler("OnClicked", function(control) RG:MisiHall() end)
    RG.Controls.Autumn:SetNormalTexture("RoseGuilds/Icons/Base/Autumn.dds")
    RG.Controls.Autumn:SetHidden(RG.savedVars.AutumnHidden)
    RG.Controls.Autumn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.AutumnX, RG.savedVars.AutumnY)
    Autumn = RG.Controls.Autumn

    RG.Controls.Winter = WINDOW_MANAGER:CreateControl("RG_WinterButton", ZO_ChatWindow, CT_BUTTON)
    RG.Controls.Winter:SetDimensions(25, 25)
    RG.Controls.Winter:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "|c0077ffKay.Cee's |cffffffGuildhall|r") end)
    RG.Controls.Winter:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    RG.Controls.Winter:SetHandler("OnClicked", function(control) RG:KayCeeHall() end)
    RG.Controls.Winter:SetNormalTexture("RoseGuilds/Icons/Base/Winter.dds")
    RG.Controls.Winter:SetHidden(RG.savedVars.WinterHidden)
    RG.Controls.Winter:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.WinterX, RG.savedVars.WinterY)
    Winter = RG.Controls.Winter

    -- Chat Menu Buttons
    RG.Controls.RoseMenu = WINDOW_MANAGER:CreateControl("RG_RoseMenuButton", ZO_ChatWindow, CT_BUTTON)
    RG.Controls.RoseMenu:SetDimensions(30, 30)
    RG.Controls.RoseMenu:SetHandler("OnMouseEnter", ShowTooltip)
    RG.Controls.RoseMenu:SetHandler("OnMouseExit", HideTooltip)
    RG.Controls.RoseMenu:SetHandler("OnClicked", DisplayRoseMenu)
    RG.Controls.RoseMenu:SetHandler("OnMouseUp", OnMouseUp)
    RG.Controls.RoseMenu:SetNormalTexture("RoseGuilds/Icons/UI/RoseGuilds.dds")
    RG.Controls.RoseMenu:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.RoseMenuX, RG.savedVars.RoseMenuY)
    RoseMenu = RG.Controls.RoseMenu
    
    RG.Controls.RoseMenuVertical = WINDOW_MANAGER:CreateControl("RG_RoseMenuVertical", ZO_ChatWindowMinBar, CT_BUTTON)
    RG.Controls.RoseMenuVertical:SetDimensions(30, 30)
    RG.Controls.RoseMenuVertical:SetHandler("OnMouseEnter", ShowTooltip)
    RG.Controls.RoseMenuVertical:SetHandler("OnMouseExit", HideTooltip)
    RG.Controls.RoseMenuVertical:SetHandler("OnClicked", DisplayRoseMenu)
    RG.Controls.RoseMenuVertical:SetHandler("OnMouseUp", OnMouseUp)
    RG.Controls.RoseMenuVertical:SetNormalTexture("RoseGuilds/Icons/UI/RoseGuilds.dds")
    RG.Controls.RoseMenuVertical:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 225)
    RoseMenuVertical = RG.Controls.RoseMenuVertical

    RG.Controls.RoseMenuGuildHome = WINDOW_MANAGER:CreateControl("RG_RoseMenuGuildHome", ZO_GuildHome, CT_BUTTON)
    RG.Controls.RoseMenuGuildHome:SetDimensions(80, 80)
    RG.Controls.RoseMenuGuildHome:SetHandler("OnMouseEnter", ShowTooltip)
    RG.Controls.RoseMenuGuildHome:SetHandler("OnMouseExit", HideTooltip)
    RG.Controls.RoseMenuGuildHome:SetHandler("OnClicked", DisplayRoseMenu)
    RG.Controls.RoseMenuGuildHome:SetHandler("OnMouseUp", OnMouseUp)
    RG.Controls.RoseMenuGuildHome:SetNormalTexture("RoseGuilds/Icons/UI/RoseGuildsHome.dds")
    RG.Controls.RoseMenuGuildHome:SetAnchor(TOPLEFT, ZO_GuildHome, nil, 350, 0)
    RoseMenuGuildHome = RG.Controls.RoseMenuGuildHome

    -- Discord Button
    RG.Controls.RoseGuildsDiscord = WINDOW_MANAGER:CreateControl("RoseGuildsDiscord", ZO_GuildHome, CT_BUTTON)
    RG.Controls.RoseGuildsDiscord:SetDimensions(100, 100)
    RG.Controls.RoseGuildsDiscord:SetAnchor(TOPLEFT, ZO_GuildHome, nil, 435, 5)
	RG.Controls.RoseGuildsDiscord:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "|ce036ffRose |cFFFFFFDiscord|r") end)
	RG.Controls.RoseGuildsDiscord:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
	RG.Controls.RoseGuildsDiscord:SetNormalTexture("RoseGuilds/Icons/UI/Discord.dds")
	RG.Controls.RoseGuildsDiscord:SetHandler("OnClicked", function(...) RequestOpenUnsafeURL("https://www.discord.gg/RoseGuilds") end)
    RoseGuildsDiscord = RG.Controls.RoseGuildsDiscord


end

-- Settings
function RG:CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Rose Guilds",
        displayName = "|cE036FFRose |cFFFFFFGuilds",
        author = "|c235cffK|r|c3070ffa|c3d83ffy.|c56a9ffC|c63bdffe|c70d0ffe",
        version = "04.02.26",
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel("RoseGuildsSettings", panelData)

    local optionsData = {}
	table.insert(optionsData, {
        type = "header",
        name = "|cFFFFFFOverhead Icons",
        width = "full",
    })
    table.insert(optionsData, {
        type = "checkbox",
        name = "Show Icon Above Player's Head",
        tooltip = "Show icons above other players heads.",
        getFunc = function() return RG.savedVars.IconAboveHeadVisible end,
        setFunc = function(value) RG.savedVars.IconAboveHeadVisible = value end,
        width = "full",
    })
    table.insert(optionsData, {
        type = "checkbox",
        name = "Only Show Icons When in a Group (Also hides your icon if enabled outside of group)",
        tooltip = "Only show overhead icons when you are in a group.",
        getFunc = function() return RG.savedVars.IconAboveHeadGroupOnly end,
        setFunc = function(value) RG.savedVars.IconAboveHeadGroupOnly = value end,
        width = "full",
    })
    table.insert(optionsData, {
        type = "checkbox",
        name = "Show Your Own Icon Above Head",
        tooltip = "Show your own icon above your head.",
        getFunc = function() return RG.savedVars.IconAboveHeadShowPlayer end,
        setFunc = function(value) 
            RG.savedVars.IconAboveHeadShowPlayer = value
            if RG.TogglePlayerOverheadIcon then RG.TogglePlayerOverheadIcon(value) end
        end,
        width = "full",
        requiresReload = true,
    })
    table.insert(optionsData, {
        type = "slider",
        name = "Overhead Icon Size.",
        tooltip = "Adjust the size of the icons above players heads.",
        min = 16,
        max = 128,
        getFunc = function() return RG.savedVars.IconAboveHeadSize end,
        setFunc = function(value) RG.savedVars.IconAboveHeadSize = value end,
        step = 1,
        width = "full",
    })    table.insert(optionsData, {
        type = "slider",
        name = "Overhead Icon Height",
        tooltip = "Adjust how high above the player's head the icon is. (Default: 3.2).",
        min = 0.5,
        max = 10.0,
        getFunc = function() return RG.savedVars.IconAboveHeadOffset end,
        setFunc = function(value) RG.savedVars.IconAboveHeadOffset = value end,
        step = 0.1,
        width = "full",
    })    table.insert(optionsData, {
        type = "header",
        name = "|cFFFFFFChat icons visibility",
        width = "full",
    })
    table.insert(optionsData,
        {
            type = "button",
            name = "|cffffffOnly show |c6a5acdMidnight Rose", 
            tooltip = "Hides all Rose Guild icons except Midnight Rose and the Rose Menu - Will reset the position.",
            width = "full",
            func = function() MidnightToggle() end,
        })
    table.insert(optionsData,
        {
            type = "button",
            name = "|cffffffOnly show |c00ff7fSpring Rose", 
            tooltip = "Hides all Rose Guild icons except Spring Rose and the Rose Menu - Will reset the position.",
            width = "full",
            func = function() SpringToggle() end,
        })
    table.insert(optionsData,
            {
                type = "button",
                name = "|cffffffOnly show |cf10000Summer Rose",
                tooltip = "Hides all Rose Guild icons except Summer Rose and the Rose Menu - Will reset the position.",
                width = "full",
                func = function() SummerToggle() end,
            })
    table.insert(optionsData,
            {
                type = "button",
                name = "|cffffffOnly show |cffd971Autumn Rose",
                tooltip = "Hides all Rose Guild icons except Autumn Rose and the Rose Menu - Will reset the position.",
                width = "full",
                func = function() AutumnToggle() end,
            })
    table.insert(optionsData,
            {
                type = "button",
                name = "|cffffffOnly show |c0077ffWinter Rose",
                tooltip = "Hides all Rose Guild icons except Winter Rose and the Rose Menu - Will reset the position.",
                width = "full",
                func = function() WinterToggle() end,
            })
    table.insert(optionsData,
        {
            type = "button",
            name = "|cffffffHide All Roses",
            tooltip = "Hide all Rose Guild icons except the Rose Menu",
            width = "full",
            func = function() MenuToggle() end,
        })
    table.insert(optionsData, {
        type = "header",
        name = "|cFFFFFFChat icons position",
        width = "full",
    })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|cE036FFRose Menu|cFFFFFF Horizontal Position",
            tooltip = "Default 175",
            min = 0,
            max = GuiRoot:GetWidth(),
            getFunc = function() return RG.savedVars.RoseMenuX end,
            setFunc = function(value) RG.savedVars.RoseMenuX = value 
            if RoseMenu then RoseMenu:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.RoseMenuX, RG.savedVars.RoseMenuY) end 
            if RoseMenuVertical then RoseMenuVertical:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, RG.savedVars.RoseMenuX, 225) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|cE036FFRose Menu|cFFFFFF Vertical Position",
            tooltip = "Default 8",
            min = 0,
            max = GuiRoot:GetHeight(),
            getFunc = function() return RG.savedVars.RoseMenuY end,
            setFunc = function(value) RG.savedVars.RoseMenuY = value
            if RoseMenu then RoseMenu:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.RoseMenuX, RG.savedVars.RoseMenuY) end 
            if RoseMenuVertical then RoseMenuVertical:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, RG.savedVars.RoseMenuX, RG.savedVars.RoseMenuY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|c6a5acdMidnight|cffffff Horizontal Position",
            tooltip = "Default 215",
            min = 0,
            max = GuiRoot:GetWidth(),
            getFunc = function() return RG.savedVars.MidnightX end,
            setFunc = function(value) RG.savedVars.MidnightX = value 
            if Midnight then Midnight:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.MidnightX, RG.savedVars.MidnightY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|c6a5acdMidnight|cffffff Vertical Position",
            tooltip = "Default 10",
            min = 0,
            max = GuiRoot:GetHeight(),
            getFunc = function() return RG.savedVars.MidnightY end,
            setFunc = function(value) RG.savedVars.MidnightY = value
            Midnight:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.MidnightX, RG.savedVars.MidnightY) end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|c00ff7fSpring|cffffff Horizontal Position",
            tooltip = "Default 250",
            min = 0,
            max = GuiRoot:GetWidth(),
            getFunc = function() return RG.savedVars.SpringX end,
            setFunc = function(value) RG.savedVars.SpringX = value 
            if Spring then Spring:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.SpringX, RG.savedVars.SpringY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|c00ff7fSpring|cffffff Vertical Position",
            tooltip = "Default 10",
            min = 0,
            max = GuiRoot:GetHeight(),
            getFunc = function() return RG.savedVars.SpringY end,
            setFunc = function(value) RG.savedVars.SpringY = value
            if Spring then Spring:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.SpringX, RG.savedVars.SpringY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|cf10000Summer|cffffff Horizontal Position",
            tooltip = "Default 285",
            min = 0,
            max = GuiRoot:GetWidth(),
            getFunc = function() return RG.savedVars.SummerX end,
            setFunc = function(value) RG.savedVars.SummerX = value
            if Summer then Summer:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.SummerX, RG.savedVars.SummerY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|cf10000Summer|cffffff Vertical Position",
            tooltip = "Default 10",
            min = 0,
            max = GuiRoot:GetHeight(),
            getFunc = function() return RG.savedVars.SummerY end,
            setFunc = function(value) RG.savedVars.SummerY = value
            if Summer then Summer:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.SummerX, RG.savedVars.SummerY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|cffd971Autumn|cffffff Horizontal Position",
            tooltip = "Default 320",
            min = 0,
            max = GuiRoot:GetWidth(),
            getFunc = function() return RG.savedVars.AutumnX end,
            setFunc = function(value) RG.savedVars.AutumnX = value 
            if Autumn then Autumn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.AutumnX, RG.savedVars.AutumnY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|cffd971Autumn|cffffff Vertical Position",
            tooltip = "Default 10",
            min = 0,
            max = GuiRoot:GetHeight(),
            getFunc = function() return RG.savedVars.AutumnY end,
            setFunc = function(value) RG.savedVars.AutumnY = value
            if Autumn then Autumn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.AutumnX, RG.savedVars.AutumnY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|c0077ffWinter|cffffff Horizontal Position",
            tooltip = "Default 355",
            min = 0,
            max = GuiRoot:GetWidth(),
            getFunc = function() return RG.savedVars.WinterX end,
            setFunc = function(value) RG.savedVars.WinterX = value 
            if Winter then Winter:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.WinterX, RG.savedVars.WinterY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "slider",
            name = "|c0077ffWinter|cffffff Vertical Position",
            tooltip = "Default 10",
            min = 0,
            max = GuiRoot:GetHeight(),
            getFunc = function() return RG.savedVars.WinterY end,
            setFunc = function(value) RG.savedVars.WinterY = value
            if Winter then Winter:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, RG.savedVars.WinterX, RG.savedVars.WinterY) end end,
            step = 1,
            width = "full",
        })
    table.insert(optionsData,
        {
            type = "button",
            name = "|cffffffRestore Default Positions",
            tooltip = "Restores all Rose Guilds icon positions to default values",
            width = "full",
            func = function() RG:ResetRose() end,
        })

    LAM:RegisterOptionControls("RoseGuildsSettings", optionsData)
end

