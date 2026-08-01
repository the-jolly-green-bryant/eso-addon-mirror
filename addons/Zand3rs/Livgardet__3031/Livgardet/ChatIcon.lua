local res = LivgardetMediaRes
local LAM2 = LibAddonMenu2

function Livgardet:InitializeChatIcon()
    --local lg = WINDOW_MANAGER:CreateControl("Livgardet1", ZO_ChatWindow, CT_BUTTON) 
    local lg = WINDOW_MANAGER:CreateControl("Livgardet1", ZO_ActionBar1, CT_BUTTON)
    lg:SetDimensions(53, 53)
    --lg:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPRIGHT, -100, 11) 
    lg:SetAnchor(TOPRIGHT, ZO_ActionBar1, TOPRIGHT, 110, 0)
    lg:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control)
        SetTooltipText(InformationTooltip, "Livgardet", 1, 1, 1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    end)
    lg:SetHandler("OnMouseExit", function(_)
        ClearTooltip(InformationTooltip)
    end)

    lg:SetHandler("OnClicked", function(...)
        local entries = {
            {
                label = res.IconGMHouse .. GetString(LIVGARDET_PORT_GUILDHOUSE),
                callback = function()
                    self:PortToHouse("@Vrazh", 46, res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_CHAT_GUILDHOUSE))
                end,
            },
            {
                label = "-",
            },
            {
                label = res.IconGMHouse2 .. GetString(LIVGARDET_PORT_PARSINGGROUNDS),
                callback = function()
                    self:PortToHouse("@Zand3rs", 47, res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_CHAT_PARSINGGROUNDS))
                end,
            },
            {
                label = "-",
            },
            {
                label = res.IconGMHouse3 .. GetString(LIVGARDET_PORT_NONE),
                callback = function()
                    self:PortToHouse("@", 47, res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_CHAT_NOHOUSE))
                end,
            }
        }

        local entries2 = {
            {
                label = res.IconGrpShare .. GetString(LIVGARDET_SHARE_ALLDAILIES),
                callback = function()
                    self:ShareAllDailies()
                end,
            },
            {
                label = res.IconGrpShare .. GetString(LIVGARDET_SHARE_ZONEDAILIES),
                callback = function()
                    self:ShareZoneDailies()
                end,
            },
            {
                label = res.IconGrpLead .. GetString(LIVGARDET_PORT_GROUPLEADER),
                callback = function()
                    JumpToGroupLeader()
                end,
            },
            {
                label = "-",
            },
            {
                label = res.IconGrpLeave .. GetString(LIVGARDET_GROUPLEAVE),
                callback = function()
                    GroupLeave()
                end,
            }
        }

        local entries3 = self:CreateTeleportEntryList()

        local entries4 = self:CreateTeleportNodeEntryList()

        ClearMenu()
        AddCustomSubMenuItem("" .. res.IconGHouse .. GetString(LIVGARDET_GUILD_HOUSES), entries, normalColor)

        if (IsUnitGrouped("player")) then
            AddCustomMenuItem("-", function()
            end)
            AddCustomSubMenuItem("" .. res.IconGrpTool .. GetString(LIVGARDET_BUTTON_GROUPTOOL), entries2, normalColor)
        end

        AddCustomMenuItem("-", function() 
        end)
        AddCustomSubMenuItem("" .. res.IconWay .. GetString(LIVGARDET_PORT_BUTTON_TELEPORT), entries3, normalColor) 
        AddCustomSubMenuItem("" .. res.IconWay .. GetString(LIVGARDET_PORT_BUTTON_TELEPORTWAY) .. " " .. GetRecallCost(node) .. res.IconGold, entries4, normalColor) 
        AddCustomMenuItem("-", function() 
        end)
        AddCustomMenuItem("" .. res.IconPld .. GetString(LIVGARDET_PLEDGES_BUTTON), function() 
            self:ListPledges()
        end)
        AddCustomMenuItem("-", function()
        end) 
        AddCustomMenuItem("" .. res.IconEbon .. GetString(LIVGARDET_REQRUIT), function() 
            CHAT_SYSTEM:StartTextEntry("/zone Ett av dom största och mest aktiva svenska gillen i Elderscrolls online |H1:guild:664190|hLivgardet|h har öppna platser och vill fylla dom med nya trevliga, glada spelare. Häng på och upplev vad vi har att erbjuda. Vi kör veteran Trials, normal Trials, tävlingar, PVP, och annat kul. Vi har aktiva mentorer, crafters, och mer för att hjälpa nya.")
        end) 
        AddCustomMenuItem(res.IconDiscord .. GetString(LIVGARDET_OUR_DISCORD), function()
            RequestOpenUnsafeURL("https://discord.gg/livgardet")
        end)
        AddCustomMenuItem(res.IconWeb .. GetString(LIVGARDET_OUR_WEBSITE), function()
            RequestOpenUnsafeURL("https://www.livgardet.se")
        end)
        AddCustomMenuItem(res.IconOpt .. GetString(LIVGARDET_BUTTON_SETTINGS), function()
            LAM2:OpenToPanel(self.panel)
        end)
        AddCustomMenuItem("-", function()
        end)
        AddCustomMenuItem(res.IconRldUI .. "ReloadUI", function()
            ReloadUI()
        end)
        ShowMenu()
    end)
    self.chatIcon = lg
end


function Livgardet:ShowChatIcon(show)
    self.chatIcon:SetHidden(not show)
end

function Livgardet:SetChatIconTexture(monochrome)
    self.chatIcon:SetNormalTexture(monochrome and "Livgardet/imgs/normal.dds" or "Livgardet/imgs/normal.dds")
    self.chatIcon:SetPressedTexture(monochrome and "Livgardet/imgs/normal.dds" or "Livgardet/imgs/normal.dds")
    self.chatIcon:SetMouseOverTexture("Livgardet/imgs/hover.dds")
end
