local ArcanumGuildHall = _G["ArcanumGuildHall"]

local res = ArcanumGuildHallMediaRes
local LAM2 = LibAddonMenu2

function ArcanumGuildHall:CreateMenuEntries()
    local groupEntries = {
        {
            label = res.IconGrpShare .. ArcanumGuildHall.GetDefaultLocaleString("SHARE_ALLDAILIES"),
            callback = function()
                self:ShareAllDailies()
            end,
        },
        {
            label = res.IconGrpShare .. ArcanumGuildHall.GetDefaultLocaleString("SHARE_ZONEDAILIES"),
            callback = function()
                self:ShareZoneDailies()
            end,
        },
        {
            label = res.IconGrpLead .. ArcanumGuildHall.GetDefaultLocaleString("PORT_GROUPLEADER"),
            callback = function()
                JumpToGroupLeader()
            end,
        },
        {
            label = "-"
        },
        {
            label = res.IconGrpLeave .. GetString(SI_GROUP_LEAVE),
            callback = function()
                GroupLeave()
            end,
        }
    }

    local houseEntries = {
        {
            label = ArcanumGuildHall.GetDefaultLocaleString("PORT_IN_HOUSE"),
            callback = function()
                RequestJumpToHouse(GetHousingPrimaryHouse(), false)
            end,
        },
        {
            label = ArcanumGuildHall.GetDefaultLocaleString("PORT_FRONT_HOUSE"),
            callback = function()
                RequestJumpToHouse(GetHousingPrimaryHouse(), true)
            end,
        },
    }

    local pledgeEntries = {
        {
            label = ArcanumGuildHall.GetDefaultLocaleString("PLEDGES_BUTTON_SHOW"),
            callback = function()
                self:ListPledges()
            end,
        },
        {
            label = ArcanumGuildHall.GetDefaultLocaleString("PLEDGES_BUTTON_SEND"),
            callback = function()
                self:SendPledgesToChat()
            end,
        },
    }

    return groupEntries, houseEntries, pledgeEntries
end

function ArcanumGuildHall:ShowMenuLeft()
    local groupEntries, houseEntries, pledgeEntries = self:CreateMenuEntries()

    ClearMenu()

    AddCustomMenuItem(res.IconWay .. ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_WINDOW_TITLE"), function()
        self:ToggleTeleportWindow()
    end)

    AddCustomSubMenuItem(
            res.IconGMHouse .. GetString(SI_SOCIAL_MENU_VISIT_HOUSE),
            houseEntries
    )

    if IsUnitGrouped("player") then
        AddCustomMenuItem("-")
        AddCustomSubMenuItem(
                res.IconGrpTool .. ArcanumGuildHall.GetDefaultLocaleString("BUTTON_GROUPTOOL"),
                groupEntries
        )
    end

    AddCustomMenuItem("-")

    if self.db.challengeDisplayMode == "window" then
        AddCustomMenuItem(
                res.IconPld .. ArcanumGuildHall.GetDefaultLocaleString("CHALLENGES_WINDOW_TITLE"),
                function()
                    self:ToggleChallengesWindow()
                end
        )
    else
        AddCustomSubMenuItem(
                res.IconPld .. ArcanumGuildHall.GetDefaultLocaleString("PLEDGES_BUTTON"),
                pledgeEntries
        )

        AddCustomMenuItem(
                res.IconPld .. ArcanumGuildHall.GetDefaultLocaleString("WEEKLY_CHALLENGES_TITLE"),
                function()
                    self:ListTrialAndChallengeWeeklies()
                end
        )
    end

    AddCustomMenuItem(
            res.IconTomes .. ArcanumGuildHall.GetDefaultLocaleString("TOME_WINDOW_TITLE"),
            function()
                self:ToggleTomeWindow()
            end
    )

    AddCustomMenuItem("-")

    AddCustomMenuItem(
            res.IconDiscord .. ArcanumGuildHall.GetDefaultLocaleString("OUR_DISCORD"),
            function()
                RequestOpenUnsafeURL("https://discord.gg/3FngWCQ")
            end
    )

    AddCustomMenuItem(
            res.IconOpt .. GetString(SI_GAME_MENU_SETTINGS),
            function()
                LAM2:OpenToPanel(self.panel)
            end
    )

    AddCustomMenuItem("-")

    AddCustomMenuItem(
            res.IconRldUI .. "ReloadUI",
            function()
                ReloadUI()
            end
    )

    ShowMenu()
end

function ArcanumGuildHall:ShowMenuRight()
    ClearMenu()

    AddCustomMenuItem(res.IconRnR .. ArcanumGuildHall.GetDefaultLocaleString("BINDING_REPAIR_RECHARGE"), function()
        if not ArcanumGuildHall.HasItemsToRepair() and not ArcanumGuildHall.HasItemsToRecharge() then
            CHAT_ROUTER:AddSystemMessage(res.IconAA .. " " .. res.Ccolor2 .. ArcanumGuildHall.GetDefaultLocaleString("CHAT_NOTHING_TO_REPAIR_RECHARGE") .. "|r")
            return
        end
        ArcanumGuildHall.RepairRecharge()
    end)

    AddCustomMenuItem(res.IconRepair .. ArcanumGuildHall.GetDefaultLocaleString("BINDING_REPAIR_WITH_KITS"), function()
        if not ArcanumGuildHall.HasItemsToRepair() then
            CHAT_ROUTER:AddSystemMessage(res.IconAA .. " " .. res.Ccolor2 .. zo_strformat(ArcanumGuildHall.GetDefaultLocaleString("CHAT_NOTHING_TO_REPAIR"), ArcanumGuildHall.db.repairThreshold) .. "|r")
            return
        end
        ArcanumGuildHall.RepairItemsWithKits()
    end)

    AddCustomMenuItem(res.IconRecharge .. ArcanumGuildHall.GetDefaultLocaleString("BINDING_RECHARGE_WITH_GEMS"), function()
        if not ArcanumGuildHall.HasItemsToRecharge() then
            CHAT_ROUTER:AddSystemMessage(res.IconAA .. " " .. res.Ccolor2 .. zo_strformat(ArcanumGuildHall.GetDefaultLocaleString("CHAT_NOTHING_TO_RECHARGE"), ArcanumGuildHall.db.rechargeThreshold) .. "|r")
            return
        end
        ArcanumGuildHall.RechargeItemsWithGems()
    end)

    ShowMenu()
end

function ArcanumGuildHall:AnchorChatIconToNormalChat()
    if not self.chatIcon then
        return
    end

    self.chatIcon:SetParent(ZO_ChatWindow)
    self.chatIcon:ClearAnchors()
    self.chatIcon:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 20, 5)
end

function ArcanumGuildHall:AnchorChatIconToMinBar()
    if not self.chatIcon then
        return
    end

    self.chatIcon:SetParent(ZO_ChatWindowMinBar)
    self.chatIcon:ClearAnchors()
    self.chatIcon:SetAnchor(LEFT, ZO_ChatWindowMinBar, LEFT, 2, -5)
end

function ArcanumGuildHall:UpdateChatIconForChatState()
    if not self.chatIcon then
        return
    end

    if self.db.showChatIcon == false then
        self.chatIcon:SetHidden(true)
        return
    end

    local isMinimized = ZO_ChatWindowMinBar and not ZO_ChatWindowMinBar:IsHidden()

    if isMinimized then
        self:AnchorChatIconToMinBar()
    else
        self:AnchorChatIconToNormalChat()
    end

    self.chatIcon:SetHidden(false)
end

function ArcanumGuildHall:RegisterChatIconStateHooks()
    if self.chatIconStateHooksRegistered then
        return
    end

    if ZO_ChatWindowMinBar then
        ZO_PreHookHandler(ZO_ChatWindowMinBar, "OnEffectivelyShown", function()
            self:AnchorChatIconToMinBar()
        end)

        ZO_PreHookHandler(ZO_ChatWindowMinBar, "OnEffectivelyHidden", function()
            self:AnchorChatIconToNormalChat()
        end)
    end

    if ZO_ChatWindow then
        ZO_PreHookHandler(ZO_ChatWindow, "OnEffectivelyShown", function()
            if not ZO_ChatWindowMinBar or ZO_ChatWindowMinBar:IsHidden() then
                self:AnchorChatIconToNormalChat()
            end
        end)
    end

    self.chatIconStateHooksRegistered = true
end

function ArcanumGuildHall:InitializeChatIcon()
    local ptoGHall = WINDOW_MANAGER:CreateControl("ArcanumGuildHall1", ZO_ChatWindow, CT_BUTTON)
    ptoGHall:SetDimensions(20, 20)

    ptoGHall:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control)
        InformationTooltip:AddLine(res.IconAA .. " |cffffffArcanum Artis|r " .. res.IconAA)
        InformationTooltip:AddVerticalPadding(-15)
        InformationTooltip:AddLine(res.IconDivider)
        InformationTooltip:AddVerticalPadding(-10)
        InformationTooltip:AddLine(
                res.IconLeftClk .. ArcanumGuildHall.GetDefaultLocaleString("MENU_LEFT")
                        .. res.IconRightClk .. ArcanumGuildHall.GetDefaultLocaleString("MENU_RIGHT")
        )
    end)

    ptoGHall:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    ptoGHall:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:ShowMenuLeft()
        elseif button == MOUSE_BUTTON_INDEX_RIGHT then
            self:ShowMenuRight()
        end
    end)

    self.chatIcon = ptoGHall
    self:RegisterChatIconStateHooks()
    self:UpdateChatIconForChatState()
end

function ArcanumGuildHall:ShowChatIcon(show)
    self.db.showChatIcon = show
    self:UpdateChatIconForChatState()
end

function ArcanumGuildHall:SetChatIconTexture(monochrome)
    self.chatIcon:SetNormalTexture(monochrome and "ArcanumGuildHall/imgs/aaguild_mono.dds" or "ArcanumGuildHall/imgs/aaguild.dds")
    self.chatIcon:SetPressedTexture(monochrome and "ArcanumGuildHall/imgs/aaguild_mono_pressed.dds" or "ArcanumGuildHall/imgs/aaguild_pressed.dds")
    self.chatIcon:SetMouseOverTexture("ArcanumGuildHall/imgs/aaguild_over.dds")
end