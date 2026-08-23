--[[
    FancyTitles UI
    Version: 5.3.0
    
    Redesigned UI - Exotic color palette, submenu structure
    Original list generation logic preserved exactly
]]--

FancyTitles = FancyTitles or {}

local LAM = nil
local currentSearchFilter = ""
local currentChatSearchFilter = ""

-- ============================================
-- Exotic Color Palette
-- ============================================
local C = {
    ROSE        = "FF6B9D",
    VIOLET      = "C084FC",
    CYAN        = "67E8F9",
    GOLD        = "FDE68A",
    MINT        = "6EE7B7",
    TANGERINE   = "FB923C",
    LABEL       = "E0D4FF",
    DIM         = "7A7A9E",
    WHITE       = "FFFFFF",
    MUTED       = "555577",
    NEONPINK    = "FF44CC",
    HOTPINK     = "F472B6",
    AMETHYST    = "A78BFA",
    DANGER      = "FF4466",
    SUCCESS     = "4ADE80",
}

local function IsCurrentPlayerAdmin()
    local name = GetDisplayName():lower()
    if name:sub(1, 1) ~= "@" then name = "@" .. name end
    return FancyTitles.ADMIN_ACCOUNTS[name] == true
end

local function MatchesSearch(playerName, playerData, searchTerm)
    if not searchTerm or searchTerm == "" then return true end
    searchTerm = searchTerm:lower()
    return playerName:lower():find(searchTerm, 1, true) or 
           playerData.rank:lower():find(searchTerm, 1, true) or 
           playerData.title:lower():find(searchTerm, 1, true)
end

-- ============================================
-- Logo
-- ============================================
local function GenerateGradientLogo()
    local title = FancyTitles.CreateMultiGradientText("FancyTitles", {"FF6B9D", "C084FC", "87A0FF", "67E8F9"})
    return title .. " |c" .. C.DIM .. "by " .. FancyTitles.author .. "|r"
end

-- ============================================
-- ORIGINAL list generators - EXACT same logic
-- that was proven to work in the original UI
-- ============================================
local function GeneratePlayerListText(searchTerm)
    local players = FancyTitles.GetAllPlayers()
    local lines, total = {}, 0
    for _, rankId in ipairs({"creator", "exclusive", "enjoyer"}) do
        local rankPlayers = {}
        for name, data in pairs(players) do
            if data.rank == rankId and MatchesSearch(name, data, searchTerm) then 
                table.insert(rankPlayers, {name = name, data = data}) 
            end
        end
        if #rankPlayers > 0 then
            table.sort(rankPlayers, function(a, b) return a.name < b.name end)
            table.insert(lines, "")
            table.insert(lines, "|cFFD700" .. rankId:sub(1,1):upper() .. rankId:sub(2) .. "|r (" .. #rankPlayers .. ")")
            for _, player in ipairs(rankPlayers) do
                local formattedTitle = FancyTitles.GetFormattedTitle(player.name) or player.data.title or ""
                table.insert(lines, "  |c888888" .. player.name .. "|r - " .. formattedTitle)
                total = total + 1
            end
        end
    end
    return total == 0 and (searchTerm ~= "" and "|cFF4444No matches found|r" or "|c888888No players|r") or table.concat(lines, "\n")
end

local function GenerateChatPlayerListText(searchTerm)
    local chatPlayers = FancyTitles.GetAllChatPlayers()
    local sorted, total = {}, 0
    for name, data in pairs(chatPlayers) do
        if not searchTerm or searchTerm == "" 
           or name:lower():find(searchTerm:lower(), 1, true)
           or (data.displayName and data.displayName:lower():find(searchTerm:lower(), 1, true)) then
            table.insert(sorted, {name = name, data = data})
            total = total + 1
        end
    end
    if total == 0 then
        return searchTerm and searchTerm ~= "" and "|cFF4444No matches found|r" or "|c888888No chat players|r"
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)
    local lines = {}
    for _, entry in ipairs(sorted) do
        local nc = entry.data.nameColor
        if not nc or nc == "" or #nc ~= 6 then nc = "FFFFFF" end
        local display = entry.data.displayName ~= "" 
            and (" -> |c" .. nc .. entry.data.displayName .. "|r") 
            or ""
        local cs = entry.data.msgColorStart or entry.data.messageColor or "FF0000"
        if not cs or cs == "" or #cs ~= 6 then cs = "FF0000" end
        local ce = entry.data.msgColorEnd or cs
        if not ce or ce == "" or #ce ~= 6 then ce = cs end
        local preview = FancyTitles.CreateMultiGradientText("This is a Chat Message", { cs, ce })
        table.insert(lines, "  |c" .. nc .. entry.name .. "|r" .. display .. " - Chat: " .. preview)
    end
    return table.concat(lines, "\n")
end

local function GenerateStatisticsText()
    local counts = FancyTitles.GetPlayerCounts()
    local server = GetWorldName() or "Unknown"
    local lines = {
        "|c" .. C.CYAN .. "Server:|r  |c" .. C.WHITE .. server .. "|r",
        "|c" .. C.CYAN .. "Total Players:|r  |c" .. C.WHITE .. counts.total .. "|r",
    }
    local rankColors = { creator = "FFD700", exclusive = "E6007E", enjoyer = "DC143C" }
    for _, rankId in ipairs({"creator", "exclusive", "enjoyer"}) do
        local rc = rankColors[rankId]
        table.insert(lines, "|c" .. rc .. rankId:sub(1,1):upper() .. rankId:sub(2) .. ":|r  |c" .. C.WHITE .. counts[rankId] .. "|r")
    end
    return table.concat(lines, "\n")
end

local function GenerateWishPreview()
    local db = FancyTitles.db
    if not db or not db.wishTitle or db.wishTitle == "" then 
        return "|c888888Enter a title to see preview|r" 
    end
    local startC = (db.wishColorStart and db.wishColorStart ~= "") and db.wishColorStart or "FFFFFF"
    local endC = (db.wishColorEnd and db.wishColorEnd ~= "") and db.wishColorEnd or "FFFFFF"
    if not FancyTitles.IsValidHexColor(startC) then startC = "FFFFFF" end
    if not FancyTitles.IsValidHexColor(endC) then endC = "FFFFFF" end
    local preview = FancyTitles.CreateMultiGradientText(db.wishTitle, {startC, endC})
    return string.format("%s\n\n|c888888Gradient: |c%s%s|r -> |c%s%s|r",
        preview, startC, startC, endC, endC)
end

-- ============================================
-- Build Options Table
-- ============================================
local function BuildOptionsTable()
    local db = FancyTitles.db
    local options = {}
    local isAdmin = IsCurrentPlayerAdmin()
    
    -- Logo Header
    table.insert(options, {
        type = "description",
        text = GenerateGradientLogo()
    })
    
    table.insert(options, { type = "divider" })
    
    -- =====================
    -- General Settings (Violet)
    -- =====================
    table.insert(options, { 
        type = "submenu", 
        name = "|c" .. C.VIOLET .. "General Settings|r",
        controls = {
            { 
                type = "description", 
                text = "|c" .. C.DIM .. "Core toggles for the addon. Enable or disable features globally.|r" 
            },
            { 
                type = "checkbox", 
                name = "|c" .. C.LABEL .. "Enable Addon|r", 
                tooltip = "Enable or disable FancyTitles completely. When disabled, no custom titles are shown.",
                getFunc = function() return db.enabled end, 
                setFunc = function(v) db.enabled = v FancyTitles.RegisterAllTitles() end 
            },
            { type = "divider" },
            { 
                type = "checkbox", 
                name = "|c" .. C.LABEL .. "Show Own Title|r", 
                tooltip = "Display your own custom title above your character",
                getFunc = function() return db.showOwnTitle end, 
                setFunc = function(v) db.showOwnTitle = v FancyTitles.RegisterAllTitles() end 
            },
            { 
                type = "checkbox", 
                name = "|c" .. C.LABEL .. "Show Other Players' Titles|r", 
                tooltip = "Display custom titles from other FancyTitles players",
                getFunc = function() return db.showOtherTitles end, 
                setFunc = function(v) db.showOtherTitles = v FancyTitles.RegisterAllTitles() end 
            },
            { 
                type = "checkbox", 
                name = "|c" .. C.LABEL .. "Show ESO Title|r", 
                tooltip = "Combine the original ESO title with the custom title.\nExample: Godslayer - Custom Title",
                getFunc = function() return db.showEsoTitle end, 
                setFunc = function(v) db.showEsoTitle = v FancyTitles.RegisterAllTitles() end 
            },
            { type = "divider" },
            { 
                type = "checkbox", 
                name = "|c" .. C.LABEL .. "Show Tooltip Info|r", 
                tooltip = "Show FancyTitles rank, title and chat color when hovering over players or clicking their name in chat",
                getFunc = function() return db.tooltipEnabled end, 
                setFunc = function(v) db.tooltipEnabled = v end 
            },
        }
    })
    
    -- =====================
    -- Chat Coloring (Rose Pink)
    -- =====================
    table.insert(options, { 
        type = "submenu", 
        name = "|c" .. C.ROSE .. "Chat Coloring|r",
        controls = {
            { 
                type = "description", 
                text = "|c" .. C.DIM .. "Highlight messages from FancyTitles players with custom solid colors or gradients. Only the message text is colored, names remain untouched.|r" 
            },
            { 
                type = "checkbox", 
                name = "|c" .. C.LABEL .. "Enable Chat Coloring|r", 
                tooltip = "Color the messages of players listed in the Chat Data database",
                getFunc = function() return db.chatColorEnabled end, 
                setFunc = function(v) db.chatColorEnabled = v end 
            },
            { 
                type = "description", 
                text = function()
                    local count = FancyTitles.GetChatPlayerCounts()
                    return "|c" .. C.CYAN .. "Chat Data Players:|r  |c" .. C.WHITE .. count .. "|r"
                end
            },
            { type = "divider" },
            { 
                type = "description", 
                text = "|c" .. C.DIM .. "Preview how chat messages will look with a gradient. This is a preview tool only - actual player colors are assigned by the Addon Creator.|r" 
            },
            { 
                type = "editbox", 
                name = "|c" .. C.LABEL .. "Preview Text|r", 
                tooltip = "Type a message to preview the gradient effect",
                isMultiline = false, 
                getFunc = function() return db.chatPreviewText or "This is a chat message with gradient!" end, 
                setFunc = function(v) db.chatPreviewText = v end 
            },
            { 
                type = "colorpicker", 
                name = "|c" .. C.TANGERINE .. "Gradient Start|r", 
                tooltip = "The color at the beginning of the chat message",
                getFunc = function()
                    local hex = db.chatPreviewStart or "FF0000"
                    if not FancyTitles.IsValidHexColor(hex) then hex = "FF0000" end
                    local r = tonumber(hex:sub(1,2), 16) / 255
                    local g = tonumber(hex:sub(3,4), 16) / 255
                    local b = tonumber(hex:sub(5,6), 16) / 255
                    return r, g, b
                end, 
                setFunc = function(r, g, b)
                    db.chatPreviewStart = string.format("%02X%02X%02X", 
                        math.floor(r*255+0.5), 
                        math.floor(g*255+0.5), 
                        math.floor(b*255+0.5))
                end, 
                width = "half",
                disabled = function() return not db.chatColorEnabled end,
            },
            { 
                type = "colorpicker", 
                name = "|c" .. C.TANGERINE .. "Gradient End|r", 
                tooltip = "The color at the end of the chat message.\nSet same as start for a solid color.",
                getFunc = function()
                    local hex = db.chatPreviewEnd or "FFAA00"
                    if not FancyTitles.IsValidHexColor(hex) then hex = "FFAA00" end
                    local r = tonumber(hex:sub(1,2), 16) / 255
                    local g = tonumber(hex:sub(3,4), 16) / 255
                    local b = tonumber(hex:sub(5,6), 16) / 255
                    return r, g, b
                end, 
                setFunc = function(r, g, b)
                    db.chatPreviewEnd = string.format("%02X%02X%02X", 
                        math.floor(r*255+0.5), 
                        math.floor(g*255+0.5), 
                        math.floor(b*255+0.5))
                end, 
                width = "half",
                disabled = function() return not db.chatColorEnabled end,
            },
            { 
                type = "description", 
                title = "|c" .. C.CYAN .. "Live Chat Preview:|r", 
                text = function()
                    local previewText = db.chatPreviewText or "This is a chat message with gradient!"
                    if previewText == "" then return "|c888888Type a message above to see preview|r" end
                    local startC = db.chatPreviewStart or "FF0000"
                    local endC = db.chatPreviewEnd or "FFAA00"
                    if not FancyTitles.IsValidHexColor(startC) then startC = "FF0000" end
                    if not FancyTitles.IsValidHexColor(endC) then endC = "FFAA00" end
                    local playerName = GetDisplayName() or "@Player"
                    local charName = GetUnitName("player") or "Character"
                    local preview = FancyTitles.CreateMultiGradientText(previewText, {startC, endC})
                    return string.format("|cFFFFFF[%s]|r: %s\n\n|c888888Gradient: |c%s%s|r -> |c%s%s|r\nColor |cFFFFFFcan be set by the Creator|r",
                        charName, preview, startC, startC, endC, endC, startC, endC)
                end 
            },
        }
    })
    
    -- =====================
    -- Statistics & Info (Cyan)
    -- =====================
    table.insert(options, { 
        type = "submenu", 
        name = "|c" .. C.CYAN .. "Statistics & Info|r",
        controls = {
            {
                type = "description",
                text = function() return GenerateStatisticsText() end
            },
            { type = "divider" },
            { 
                type = "button", 
                name = "|c" .. C.SUCCESS .. "Reload Titles|r", 
                tooltip = "Reload all custom titles from the database",
                func = function() 
                    FancyTitles.RegisterAllTitles() 
                    d("|c888888[FancyTitles]|r |c" .. C.SUCCESS .. "Titles reloaded|r") 
                end, 
                width = "half" 
            },
            { 
                type = "button", 
                name = "|c" .. C.TANGERINE .. "Export Database|r", 
                tooltip = "Export all player data to chat in a copy-paste format",
                func = function()
                    d("FancyTitles_Data = {")
                    for name, data in pairs(FancyTitles.GetAllPlayers()) do
                        local line = string.format('    ["%s"] = { rank = "%s", title = "%s"', name, data.rank, data.title)
                        if data.colorStart and data.colorStart ~= "" then 
                            line = line .. string.format(', colorStart = "%s", colorEnd = "%s"', data.colorStart, data.colorEnd or "") 
                        end
                        d(line .. " },")
                    end
                    d("}")
                end, 
                width = "half" 
            },
        }
    })
    
    -- =====================
    -- Request Custom Title (Gold)
    -- =====================
    table.insert(options, { 
        type = "submenu", 
        name = "|c" .. C.GOLD .. "Request Custom Title|r",
        controls = {
            { 
                type = "description", 
                text = "|c" .. C.DIM .. "Want your own custom title or chat color?\nJoin our Discord or whisper |cFFFFFF@haze068|c" .. C.DIM .. " on EU server!|r" 
            },
            { 
                type = "button", 
                name = "|c7289DAJoin Discord|r", 
                tooltip = "Opens the FancyTitles Discord server in your browser",
                func = function() RequestOpenUnsafeURL(FancyTitles.discordUrl) end, 
                width = "full" 
            },
            { type = "divider" },
            { 
                type = "description", 
                text = "|c" .. C.DIM .. "Design your dream title below and preview how it would look with a gradient. This is just a preview - submit your request on Discord!|r" 
            },
            { 
                type = "editbox", 
                name = "|c" .. C.LABEL .. "Your Desired Title|r", 
                tooltip = "Enter the title text you want to request",
                isMultiline = false, 
                getFunc = function() return db.wishTitle or "" end, 
                setFunc = function(v) db.wishTitle = v end 
            },
            { 
                type = "colorpicker", 
                name = "|c" .. C.TANGERINE .. "Gradient Start Color|r", 
                tooltip = "The color at the beginning of your title gradient",
                getFunc = function()
                    local hex = db.wishColorStart or "FFFFFF"
                    local r = tonumber(hex:sub(1,2), 16) / 255
                    local g = tonumber(hex:sub(3,4), 16) / 255
                    local b = tonumber(hex:sub(5,6), 16) / 255
                    return r, g, b
                end, 
                setFunc = function(r, g, b)
                    db.wishColorStart = string.format("%02X%02X%02X", 
                        math.floor(r*255+0.5), 
                        math.floor(g*255+0.5), 
                        math.floor(b*255+0.5))
                end, 
                width = "half" 
            },
            { 
                type = "colorpicker", 
                name = "|c" .. C.TANGERINE .. "Gradient End Color|r", 
                tooltip = "The color at the end of your title gradient",
                getFunc = function()
                    local hex = db.wishColorEnd or "FFFFFF"
                    local r = tonumber(hex:sub(1,2), 16) / 255
                    local g = tonumber(hex:sub(3,4), 16) / 255
                    local b = tonumber(hex:sub(5,6), 16) / 255
                    return r, g, b
                end, 
                setFunc = function(r, g, b)
                    db.wishColorEnd = string.format("%02X%02X%02X", 
                        math.floor(r*255+0.5), 
                        math.floor(g*255+0.5), 
                        math.floor(b*255+0.5))
                end, 
                width = "half" 
            },
            { 
                type = "description", 
                title = "|c" .. C.CYAN .. "Live Preview:|r", 
                text = function() return GenerateWishPreview() end 
            },
        }
    })
    
    -- =====================
    -- Admin Panel (Neon Pink)
    -- =====================
    if isAdmin then
        table.insert(options, { 
            type = "header", 
            name = "|c" .. C.NEONPINK .. "Admin Panel|r" 
        })
        
        -- Title Player List
        table.insert(options, { 
            type = "submenu", 
            name = "|c" .. C.AMETHYST .. "Title Player List|r |c" .. C.DIM .. "(" .. FancyTitles.GetPlayerCounts().total .. " players)|r", 
            controls = {
                { 
                    type = "editbox", 
                    name = "|c" .. C.LABEL .. "Search Players|r", 
                    tooltip = "Search by name, rank, or title",
                    isMultiline = false, 
                    getFunc = function() return currentSearchFilter end, 
                    setFunc = function(text) currentSearchFilter = text end 
                },
                { 
                    type = "button", 
                    name = "|c" .. C.DANGER .. "Clear Search|r", 
                    func = function() currentSearchFilter = "" end, 
                    width = "half" 
                },
                { 
                    type = "description", 
                    text = function() return GeneratePlayerListText(currentSearchFilter) end 
                },
            }
        })
        
        -- Chat Data List
        table.insert(options, { 
            type = "submenu", 
            name = "|c" .. C.HOTPINK .. "Chat Data List|r |c" .. C.DIM .. "(" .. FancyTitles.GetChatPlayerCounts() .. " players)|r", 
            controls = {
                { 
                    type = "editbox", 
                    name = "|c" .. C.LABEL .. "Search Chat Players|r", 
                    tooltip = "Search by name or display name",
                    isMultiline = false, 
                    getFunc = function() return currentChatSearchFilter end, 
                    setFunc = function(text) currentChatSearchFilter = text end 
                },
                { 
                    type = "button", 
                    name = "|c" .. C.DANGER .. "Clear Search|r", 
                    func = function() currentChatSearchFilter = "" end, 
                    width = "half" 
                },
                { 
                    type = "description", 
                    text = function() return GenerateChatPlayerListText(currentChatSearchFilter) end 
                },
            }
        })
        
        -- Admin Commands Reference
        table.insert(options, { 
            type = "submenu", 
            name = "|c" .. C.TANGERINE .. "Command Reference|r", 
            controls = {
                { 
                    type = "description", 
                    text = "|c" .. C.GOLD .. "--- Title Management ---|r\n\n" ..
                           "|c" .. C.MINT .. "Add Player:|r  |c" .. C.WHITE .. "/ft add @name rank title|r\n" ..
                           "|c" .. C.DIM .. "Register a new player with a rank and custom title.|r\n\n" ..
                           "|c" .. C.MINT .. "Remove Player:|r  |c" .. C.WHITE .. "/ft remove @name|r\n" ..
                           "|c" .. C.DIM .. "Permanently delete a player and their title from the database.|r\n\n" ..
                           "|c" .. C.MINT .. "Change Title:|r  |c" .. C.WHITE .. "/ft settitle @name title|r\n" ..
                           "|c" .. C.DIM .. "Update the displayed title text for an existing player.|r\n\n" ..
                           "|c" .. C.MINT .. "Change Rank:|r  |c" .. C.WHITE .. "/ft setrank @name rank|r\n" ..
                           "|c" .. C.DIM .. "Move a player to a different rank tier.|r\n\n" ..
                           "|c" .. C.MINT .. "Set Gradient:|r  |c" .. C.WHITE .. "/ft setcolor @name START END|r\n" ..
                           "|c" .. C.DIM .. "Apply a color gradient to the title (6-digit hex, e.g. FF0000 00FF00).|r\n\n" ..
                           "|c" .. C.MINT .. "Reset Gradient:|r  |c" .. C.WHITE .. "/ft resetcolor @name|r\n" ..
                           "|c" .. C.DIM .. "Remove custom gradient and revert to the default rank color.|r\n\n" ..
                           "|c" .. C.CYAN .. "Available Ranks:|r  |cFFD700creator|r  |c" .. C.MUTED .. "-|r  |cE6007Eexclusive|r  |c" .. C.MUTED .. "-|r  |cDC143Cenjoyer|r"
                },
                { type = "divider" },
                { 
                    type = "description", 
                    text = "|c" .. C.ROSE .. "--- Chat Data Management ---|r\n\n" ..
                           "|c" .. C.MINT .. "Add Chat Entry:|r  |c" .. C.WHITE .. "/ft chatadd @name NAMECOL MSGSTART MSGEND [display]|r\n" ..
                           "|c" .. C.DIM .. "Add a player to chat coloring. All colors are 6-digit hex. Display name is optional.|r\n\n" ..
                           "|c" .. C.MINT .. "Remove Chat Entry:|r  |c" .. C.WHITE .. "/ft chatremove @name|r\n" ..
                           "|c" .. C.DIM .. "Remove a player from the chat coloring system entirely.|r\n\n" ..
                           "|c" .. C.MINT .. "Set Name Color:|r  |c" .. C.WHITE .. "/ft chatname @name COLOR|r\n" ..
                           "|c" .. C.DIM .. "Change the color of a player's name in chat (6-digit hex).|r\n\n" ..
                           "|c" .. C.MINT .. "Set Message Gradient:|r  |c" .. C.WHITE .. "/ft chatmsg @name START [END]|r\n" ..
                           "|c" .. C.DIM .. "Set the gradient for chat messages. Omit END for a solid color.|r\n\n" ..
                           "|c" .. C.MINT .. "Set Display Name:|r  |c" .. C.WHITE .. "/ft chatdisplay @name name|r\n" ..
                           "|c" .. C.DIM .. "Set an alternative display name shown in chat instead of account name.|r\n\n" ..
                           "|c" .. C.MINT .. "List Chat Entries:|r  |c" .. C.WHITE .. "/ft chatlist|r\n" ..
                           "|c" .. C.DIM .. "Show all players currently registered for chat coloring.|r\n\n" ..
                           "|c" .. C.MINT .. "Chat Info:|r  |c" .. C.WHITE .. "/ft chatinfo @name|r\n" ..
                           "|c" .. C.DIM .. "Show detailed chat data for a specific player.|r\n\n" ..
                           "|c" .. C.MINT .. "Export Chat Data:|r  |c" .. C.WHITE .. "/ft chatexport|r\n" ..
                           "|c" .. C.DIM .. "Export the full chat database to chat in a copy-paste ready format.|r"
                },
            }
        })
    end
    
    return options
end

function FancyTitles.InitializeUI()
    LAM = LibAddonMenu2
    
    if not LAM then 
        d("|c888888[FancyTitles]|r |cFF4444LibAddonMenu-2.0 not found - Settings UI disabled|r")
        return 
    end
    
    LAM:RegisterAddonPanel("FancyTitlesOptions", {
        type = "panel",
        name = "|cFF6B9DFancy|r|cC084FCTitles|r",
        author = "|c" .. C.CYAN .. FancyTitles.author .. "|r",
        version = "|c" .. C.DIM .. FancyTitles.version .. "|r",
        website = FancyTitles.discordUrl,
        registerForRefresh = true,
    })
    
    LAM:RegisterOptionControls("FancyTitlesOptions", BuildOptionsTable())
end
