-- ============================================
-- CORE UI MODULE (Net Worth Dashboard, Gold Ledger & Donate)
-- ============================================

NWT.NetWorthDashboard = { isOpen = false, sceneInitialized = false }
NWT.GoldLedgerDashboard = { isOpen = false, sceneInitialized = false, selectedIndex = 1, scrollOffset = 0 }

-- =============================
-- Net Worth Settings Dialog (Gamepad) - must be defined before InitNetWorthDashboardScene
-- =============================

local ATK_NetWorthSettingsListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_NetWorthSettingsListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_NetWorthSettingsListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, NET_WORTH_DASHBOARD_SCENE) end
function ATK_NetWorthSettingsListScreen:PerformUpdate() end
function ATK_NetWorthSettingsListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { alignment = KEYBIND_STRIP_ALIGN_LEFT, 
          name = function() 
              if NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen then return "Toggle" end
              return "Select"
          end, 
          keybind = "UI_SHORTCUT_PRIMARY", 
          callback = function() 
              if NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen then
                  NWT.NetWorthSettingsChangeSelected()
                  PlaySound(SOUNDS.POSITIVE_CLICK)
              end
          end,
          enabled = function() return NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen end
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT,
          name = "Refresh",
          keybind = "UI_SHORTCUT_SECONDARY",
          callback = function() NWT.RefreshNetWorthCurrentTab() PlaySound(SOUNDS.POSITIVE_CLICK) end,
          visible = function() return not (NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen) end
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT,
          name = "Settings",
          keybind = "UI_SHORTCUT_TERTIARY",
          callback = function() NWT.OpenNetWorthSettingsDialog() PlaySound(SOUNDS.POSITIVE_CLICK) end,
          visible = function() return not (NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen) end
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT,
          name = "Gold Ledger",
          keybind = "UI_SHORTCUT_LEFT_SHOULDER",
          callback = function() NWT.OpenGoldLedgerDashboard() end,
          visible = function() return not (NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen) end
        },
        { alignment = KEYBIND_STRIP_ALIGN_LEFT,
          name = "Gold Ledger",
          keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
          callback = function() NWT.OpenGoldLedgerDashboard() end,
          visible = function() return not (NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen) end
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() 
        if NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen then
            NWT.CloseNetWorthSettingsDialog()
        else
            NWT.CloseNetWorthDashboard()
        end
    end)
end

function NWT.InitNetWorthDashboardScene()
    if NWT.NetWorthDashboard.sceneInitialized then return end
    local ui = ATK_NetWorth_UI
    if not ui then return end
    
    local hiddenControl = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenNetWorthList", GuiRoot, "ATK_HouseList_Screen")
    hiddenControl:SetHidden(true)
    hiddenControl:SetAlpha(0)
    
    local fragment = ZO_SimpleSceneFragment:New(ui)
    local hiddenFragment = ZO_SimpleSceneFragment:New(hiddenControl)
    
    NET_WORTH_DASHBOARD_SCENE = ZO_Scene:New("netWorthDashboardScene", SCENE_MANAGER)
    NET_WORTH_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    NET_WORTH_DASHBOARD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    NET_WORTH_DASHBOARD_SCENE:AddFragment(fragment)
    NET_WORTH_DASHBOARD_SCENE:AddFragment(hiddenFragment)
    
    NWT.HiddenNetWorthListScreen = ATK_NetWorthSettingsListScreen:New(hiddenControl)
    NWT.HiddenNetWorthList = NWT.HiddenNetWorthListScreen:GetMainList()
    NWT.HiddenNetWorthList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    -- Override MovePrevious/MoveNext to handle settings dialog navigation
    NWT.HiddenNetWorthList.MovePrevious = function(self, ...)
        if NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen then
            NWT.NetWorthSettingsMoveSelection(-1)
            return
        end
        return ZO_ParametricList.MovePrevious(self, ...)
    end
    NWT.HiddenNetWorthList.MoveNext = function(self, ...)
        if NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen then
            NWT.NetWorthSettingsMoveSelection(1)
            return
        end
        return ZO_ParametricList.MoveNext(self, ...)
    end
    
    NET_WORTH_DASHBOARD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            NWT.NetWorthDashboard.isOpen = true
            if NWT.HiddenNetWorthListScreen then 
                KEYBIND_STRIP:AddKeybindButtonGroup(NWT.HiddenNetWorthListScreen.keybindStripDescriptor) 
            end
        elseif newState == SCENE_SHOWN then
            if NWT.HiddenNetWorthList then NWT.HiddenNetWorthList:Activate() end
        elseif newState == SCENE_HIDING then
            -- Close settings dialog when scene is hiding (e.g., Start button pressed)
            if NWT.NetWorthSettings and NWT.NetWorthSettings.isOpen then
                NWT.CloseNetWorthSettingsDialog()
            end
        elseif newState == SCENE_HIDDEN then
            if NWT.HiddenNetWorthListScreen then 
                KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.HiddenNetWorthListScreen.keybindStripDescriptor) 
            end
            if NWT.HiddenNetWorthList then NWT.HiddenNetWorthList:Deactivate() end
            NWT.NetWorthDashboard.isOpen = false
        end
    end)
    NWT.NetWorthDashboard.sceneInitialized = true
end

local function EnsureNetWorthSettingsVars()
    local sv = NWT.savedVars
    if not sv.features then sv.features = {} end
    if not sv.enabledGuildBanks then sv.enabledGuildBanks = {} end
    if sv.includeBank == nil then sv.includeBank = true end
    if sv.includeCraftBag == nil then sv.includeCraftBag = true end
    if sv.includeFurnitureVault == nil then sv.includeFurnitureVault = true end
    if sv.includeMyHousing == nil then sv.includeMyHousing = true end
    if sv.includeCrownsAsGold == nil then sv.includeCrownsAsGold = true end
    if not sv.crownToGoldRate then sv.crownToGoldRate = 100 end
    if not sv.writVoucherToGoldRate then sv.writVoucherToGoldRate = 1000 end
end

local function GetSettingValueText(entry)
    if not entry then return "" end
    local sv = NWT.savedVars
    if entry.kind == "toggle" then
        local enabled = sv[entry.settingId]
        if enabled == nil then enabled = true end
        return enabled and "|c00FF00ON|r" or "|cFF4444OFF|r"
    elseif entry.kind == "cycle" then
        local cur = sv[entry.settingId] or entry.min or 0
        return tostring(cur)
    elseif entry.kind == "guildToggle" and entry.guildId then
        local enabled = sv.enabledGuildBanks[entry.guildId]
        if enabled == nil then enabled = false end
        return enabled and "|c00FF00ON|r" or "|cFF4444OFF|r"
    end
    return ""
end

local function BuildNetWorthSettingsEntries()
    EnsureNetWorthSettingsVars()
    local entries = {}
    local function addToggle(label, settingId)
        table.insert(entries, { label = label, kind = "toggle", settingId = settingId })
    end
    local function addCycle(label, settingId, min, max, step)
        table.insert(entries, { label = label, kind = "cycle", settingId = settingId, min = min, max = max, step = step })
    end
    addToggle("Include Bank", "includeBank")
    addToggle("Include Craft Bag", "includeCraftBag")
    addToggle("Include Furniture Vault", "includeFurnitureVault")
    addToggle("Include My Housing", "includeMyHousing")
    addToggle("Include Crowns as Gold", "includeCrownsAsGold")
    addCycle("Crown → Gold Rate", "crownToGoldRate", 0, 2000, 100)
    addCycle("Writ Voucher → Gold", "writVoucherToGoldRate", 0, 2000, 100)
    
    -- Per-guild bank toggles
    for i = 1, GetNumGuilds() do
        local gid = GetGuildId(i)
        local gname = GetGuildName(gid) or ("Guild " .. i)
        table.insert(entries, { label = "Bank: " .. gname, kind = "guildToggle", guildId = gid })
    end
    return entries
end

local function EnsureNetWorthSettingsDialog()
    if NWT.NetWorthSettings and NWT.NetWorthSettings.control then return end
    local ctrl = ATK_NetWorthSettingsDialog
    if not ctrl then return end
    
    local optionLabels = {}
    for i = 1, 20 do
        local label = ctrl:GetNamedChild("Option" .. i)
        if label then
            label:SetHidden(true)
            optionLabels[i] = label
        end
    end
    
    NWT.NetWorthSettings = {
        control = ctrl,
        optionLabels = optionLabels,
        selectedIndex = 1,
        isOpen = false,
        entries = {},
    }
end

function NWT.RefreshNetWorthSettingsList()
    EnsureNetWorthSettingsDialog()
    local dlg = NWT.NetWorthSettings
    if not dlg or not dlg.control then return end
    
    local entries = BuildNetWorthSettingsEntries()
    dlg.entries = entries
    
    if not dlg.selectedIndex or dlg.selectedIndex < 1 then dlg.selectedIndex = 1 end
    if dlg.selectedIndex > #entries then dlg.selectedIndex = #entries end
    
    -- Use Dues Settings style: text formatting + SelectionFrame positioning
    for i = 1, 20 do
        local label = dlg.optionLabels[i]
        if label then
            local entry = entries[i]
            if entry then
                if i == dlg.selectedIndex then
                    -- Selected: yellow arrow prefix, highlighted text
                    label:SetText("|cFFFF00► " .. entry.label .. ": |cFFD700" .. GetSettingValueText(entry) .. "|r")
                else
                    -- Unselected: plain white text with gray value
                    label:SetText("|cFFFFFF  " .. entry.label .. ": |c888888" .. GetSettingValueText(entry) .. "|r")
                end
                label:SetHidden(false)
            else
                label:SetHidden(true)
            end
        end
    end
    
    -- Position SelectionFrame backdrop like Dues Settings does
    local selFrame = dlg.control:GetNamedChild("SelectionFrame")
    if selFrame and dlg.selectedIndex <= #entries then
        -- Row height is 35, starting offset is 110 (from XML)
        local rowY = 110 + (dlg.selectedIndex - 1) * 35
        selFrame:ClearAnchors()
        selFrame:SetAnchor(TOPLEFT, dlg.control, TOPLEFT, 30, rowY - 2)
        selFrame:SetHidden(false)
    elseif selFrame then
        selFrame:SetHidden(true)
    end
end

function NWT.NetWorthSettingsChangeSelected()
    if not NWT.NetWorthSettings then return end
    local data = NWT.NetWorthSettings.entries and NWT.NetWorthSettings.entries[NWT.NetWorthSettings.selectedIndex or 1]
    if not data then return end
    local sv = NWT.savedVars
    
    if data.kind == "toggle" then
        sv[data.settingId] = not sv[data.settingId]
    elseif data.kind == "cycle" then
        local cur = sv[data.settingId] or data.min or 0
        local step = data.step or 100
        local max = data.max or cur
        local min = data.min or 0
        cur = cur + step
        if cur > max then cur = min end
        sv[data.settingId] = cur
    elseif data.kind == "guildToggle" and data.guildId then
        sv.enabledGuildBanks[data.guildId] = not sv.enabledGuildBanks[data.guildId]
    end
    
    NWT.RefreshNetWorthSettingsList()
    NWT.CalculateNetWorth()
    NWT.UpdateNetWorthDashboard()
end

function NWT.NetWorthSettingsMoveSelection(dir)
    if not NWT.NetWorthSettings or not NWT.NetWorthSettings.entries then return end
    local count = #NWT.NetWorthSettings.entries
    if count == 0 then return end
    
    local idx = NWT.NetWorthSettings.selectedIndex or 1
    idx = idx + dir
    if idx < 1 then idx = count
    elseif idx > count then idx = 1 end
    
    NWT.NetWorthSettings.selectedIndex = idx
    NWT.RefreshNetWorthSettingsList()
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
end

function NWT.OpenNetWorthSettingsDialog()
    EnsureNetWorthSettingsDialog()
    NWT.RefreshNetWorthSettingsList()
    if NWT.NetWorthSettings and NWT.NetWorthSettings.control then
        NWT.NetWorthSettings.control:SetHidden(false)
        NWT.NetWorthSettings.isOpen = true
        if KEYBIND_STRIP and NWT.HiddenNetWorthListScreen then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenNetWorthListScreen.keybindStripDescriptor)
        end
    end
end

function NWT.CloseNetWorthSettingsDialog()
    if not NWT.NetWorthSettings or not NWT.NetWorthSettings.control then return end
    NWT.NetWorthSettings.control:SetHidden(true)
    NWT.NetWorthSettings.isOpen = false
    PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
    if KEYBIND_STRIP and NWT.HiddenNetWorthListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(NWT.HiddenNetWorthListScreen.keybindStripDescriptor)
    end
end

function NWT.UpdateNetWorthDashboard()
    local ui = ATK_NetWorth_UI
    if ui then
        NWT.UpdateNetWorthDashboard_New(ui)
        return
    end
    -- Fallback to old UI
    ui = ATK_NetWorth_UI
    if not ui then return end
    NWT.CalculateNetWorth()
    
    local left, right = ui:GetNamedChild("LeftPanel"), ui:GetNamedChild("RightPanel")
    ui:GetNamedChild("Title"):SetText("|cFFFFFF" .. (GetUnitName("player") or "Unknown") .. "|r  |cFFD700NET WORTH|r")
    left:GetNamedChild("Header"):SetText("|cFFFFAAWealth Summary|r")
    right:GetNamedChild("Header"):SetText("|cFFD700Top 10 Most Valuable Items|r")
    left:GetNamedChild("Total"):SetText("|cFFFFFF" .. NWT.FormatGold(NWT.netWorth.total) .. " gold|r")
    
    left:GetNamedChild("Gold"):SetText("|cFFFFAAGold:|r " .. NWT.FormatGold(NWT.netWorth.gold) .. "g")
    left:GetNamedChild("Inventory"):SetText("|cFFFFAAInventory:|r " .. NWT.FormatGold(NWT.netWorth.inventory) .. "g")
    left:GetNamedChild("Bank"):SetText(NWT.savedVars.includeBank and ("|cFFFFAABank:|r " .. NWT.FormatGold(NWT.netWorth.bank) .. "g") or "|c666666Bank:|r (disabled)")
    left:GetNamedChild("CraftBag"):SetText(NWT.savedVars.includeCraftBag and ("|cFFFFAACraft Bag:|r " .. NWT.FormatGold(NWT.netWorth.craftBag) .. "g") or "|c666666Craft Bag:|r (disabled)")
    
    local vaultSlot = GetNextFurnitureVaultSlotId(nil)
    local vSuffix = (NWT.netWorth.furnitureVault > 0 and not vaultSlot) and " (saved)" or ""
    left:GetNamedChild("FurnitureVault"):SetText(NWT.savedVars.includeFurnitureVault and ("|cFFFFAAFurniture Vault:|r " .. NWT.FormatGold(NWT.netWorth.furnitureVault) .. "g" .. vSuffix) or "|c666666Furniture Vault:|r (disabled)")
    
    local hId = GetCurrentZoneHouseId()
    local hSuffix = (hId == 0 or not IsOwnerOfCurrentHouse()) and " (saved)" or ""
    left:GetNamedChild("Housing"):SetText(NWT.savedVars.includeMyHousing and ("|cFFFFAAMy Housing:|r " .. NWT.FormatGold(NWT.netWorth.myHousing) .. "g" .. hSuffix) or "|c666666Housing:|r (disabled)")
    left:GetNamedChild("GuildBanks"):SetText(NWT.netWorth.guildBanks > 0 and ("|cFFFFAAGuild Banks:|r " .. NWT.FormatGold(NWT.netWorth.guildBanks) .. "g (saved)") or "|c666666Guild Banks:|r 0g")
    
    local cText = "|c33CCFFCrowns:|r " .. NWT.FormatGold(NWT.netWorth.crowns)
    if NWT.netWorth.crownsAsGold > 0 then cText = cText .. " (=" .. NWT.FormatGold(NWT.netWorth.crownsAsGold) .. "g)" end
    left:GetNamedChild("Crowns"):SetText(cText)
    left:GetNamedChild("CrownGems"):SetText("|cFF66CCCrown Gems:|r " .. NWT.FormatGold(NWT.netWorth.crownGems))
    left:GetNamedChild("CrownItems"):SetText("|c99CCFFCrown Items:|r " .. (NWT.netWorth.crownStoreItems or 0) .. " store, " .. (NWT.netWorth.crownCrateItems or 0) .. " crate")
    
    -- Total crown value (vault + housing + storage) - converted to gold
    local fcLabel = left:GetNamedChild("FurnitureCrowns")
    if fcLabel then
        if NWT.netWorth.totalCrownValue and NWT.netWorth.totalCrownValue > 0 then
            local crownText = "|cFFAA00Crown Furniture:|r " .. NWT.FormatGold(NWT.netWorth.totalCrownValue) .. " crowns"
            if NWT.netWorth.crownFurnitureAsGold and NWT.netWorth.crownFurnitureAsGold > 0 then
                crownText = crownText .. " (=" .. NWT.FormatGold(NWT.netWorth.crownFurnitureAsGold) .. "g)"
            end
            fcLabel:SetText(crownText)
        else
            fcLabel:SetText("|c666666Crown Furniture:|r 0")
        end
    end
    
    -- Total writ vouchers (vault + housing + storage)
    local wvLabel = left:GetNamedChild("WritVouchers")
    if wvLabel then
        if NWT.netWorth.totalWritVouchers and NWT.netWorth.totalWritVouchers > 0 then
            local wvText = "|c88FF88Writ Vouchers:|r " .. NWT.FormatGold(NWT.netWorth.totalWritVouchers) .. " WV"
            if NWT.netWorth.writVouchersAsGold > 0 then
                wvText = wvText .. " (=" .. NWT.FormatGold(NWT.netWorth.writVouchersAsGold) .. "g)"
            end
            wvLabel:SetText(wvText)
        else
            wvLabel:SetText("|c666666Writ Vouchers:|r 0 WV")
        end
    end
    
    -- Visiting House section
    local vhHeader = left:GetNamedChild("VisitingHouseHeader")
    local vhValue = left:GetNamedChild("VisitingHouseValue")
    local houseId = GetCurrentZoneHouseId()
    local inHouse = houseId and houseId > 0
    
    if vhHeader and vhValue then
        if inHouse and NWT.netWorth.visitingHouse then
            local houseName = NWT.netWorth.visitingHouseName or "Current House"
            if houseName == "" then houseName = "Current House" end
            vhHeader:SetText("|cAAFFAA" .. houseName .. "|r")
            
            local goldVal = NWT.netWorth.visitingHouse or 0
            local crownVal = NWT.netWorth.visitingHouseCrowns or 0
            local wvVal = NWT.netWorth.visitingHouseWV or 0
            local crownToGold = NWT.savedVars.crownToGoldRate or 100
            local wvToGold = NWT.savedVars.writVoucherToGoldRate or 1000
            local totalGold = goldVal + (crownVal * crownToGold) + (wvVal * wvToGold)
            
            local valueText = NWT.FormatGold(goldVal) .. "g"
            if crownVal > 0 then valueText = valueText .. " + " .. NWT.FormatGold(crownVal) .. " crowns" end
            if wvVal > 0 then valueText = valueText .. " + " .. NWT.FormatGold(wvVal) .. " WV" end
            valueText = valueText .. " = |cFFD700" .. NWT.FormatGold(totalGold) .. "g|r"
            vhValue:SetText(valueText)
        else
            vhHeader:SetText("|c666666Visiting House|r")
            vhValue:SetText("|c666666Not in a house|r")
        end
    end
    
    for i = 1, 10 do
        local label = right:GetNamedChild("Item" .. i)
        if label then
            if NWT.topItems[i] then
                label:SetText("|cFFD700" .. i .. ".|r " .. (NWT.topItems[i].name or "Unknown") .. "\n   |c888888x" .. NWT.topItems[i].count .. " = " .. NWT.FormatGold(NWT.topItems[i].value) .. "g|r")
            else label:SetText("") end
        end
    end
    ui:GetNamedChild("Updated"):SetText("|c888888Last updated: " .. GetTimeString() .. "|r")
end

-- New redesigned NetWorth UI update function
function NWT.UpdateNetWorthDashboard_New(ui)
    NWT.CalculateNetWorth()
    
    -- Header - Reset title when switching back from Gold Ledger
    local header = ui:GetNamedChild("Header")
    if header then
        local title = header:GetNamedChild("Title")
        if title then title:SetText("|c00FF00NET WORTH DASHBOARD|r |c888888v" .. (NWT.goldLedgerVersion or "?") .. "|r") end
        local subtitle = header:GetNamedChild("Subtitle")
        if subtitle then subtitle:SetText("|cFFFFFF" .. (GetUnitName("player") or "Unknown") .. "|r  •  Updated " .. GetTimeString()) end
    end
    
    -- Left Column
    local leftCol = ui:GetNamedChild("LeftCol")
    if leftCol then
        -- Total Card
        local totalCard = leftCol:GetNamedChild("TotalCard")
        if totalCard then
            local value = totalCard:GetNamedChild("Value")
            local change = totalCard:GetNamedChild("Change")
            if value then value:SetText("|c00FF00" .. NWT.FormatGold(NWT.netWorth.total) .. "g|r") end
            if change then 
                local diff = NWT.netWorth.total - (NWT.savedVars.lastNetWorth or NWT.netWorth.total)
                local changeColor = diff >= 0 and "|c00FF00+" or "|cFF4444"
                change:SetText(changeColor .. NWT.FormatGold(math.abs(diff)) .. "g|r since last check")
            end
        end
        
        -- Gold Card - Reset header when switching back from Gold Ledger
        local goldCard = leftCol:GetNamedChild("GoldCard")
        if goldCard then
            local gcHeader = goldCard:GetNamedChild("Header")
            if gcHeader then gcHeader:SetText("|cFFFFAAWEALTH BREAKDOWN|r") end
            local gcCrownHeader = goldCard:GetNamedChild("CrownHeader")
            if gcCrownHeader then gcCrownHeader:SetText("|c33CCFFCROWN CURRENCIES|r") end
            local gold = goldCard:GetNamedChild("Gold")
            local inv = goldCard:GetNamedChild("Inventory")
            local bank = goldCard:GetNamedChild("Bank")
            local craft = goldCard:GetNamedChild("CraftBag")
            local vault = goldCard:GetNamedChild("FurnitureVault")
            local housing = goldCard:GetNamedChild("Housing")
            local guildBanks = goldCard:GetNamedChild("GuildBanks")
            local crowns = goldCard:GetNamedChild("Crowns")
            local gems = goldCard:GetNamedChild("CrownGems")
            local crownItems = goldCard:GetNamedChild("CrownItems")
            local wv = goldCard:GetNamedChild("WritVouchers")
            
            if gold then gold:SetText("|cFFD700Gold:|r  |c00FF00" .. NWT.FormatGold(NWT.netWorth.gold) .. "g|r") end
            if inv then inv:SetText("|cFFFFAAInventory:|r  " .. NWT.FormatGold(NWT.netWorth.inventory) .. "g") end
            if bank then bank:SetText(NWT.savedVars.includeBank and ("|cFFFFAABank:|r  " .. NWT.FormatGold(NWT.netWorth.bank) .. "g") or "|c666666Bank:|r (off)") end
            if craft then craft:SetText(NWT.savedVars.includeCraftBag and ("|cFFFFAACraft Bag:|r  " .. NWT.FormatGold(NWT.netWorth.craftBag) .. "g") or "|c666666Craft Bag:|r (off)") end
            if vault then vault:SetText(NWT.savedVars.includeFurnitureVault and ("|cFFFFAAVault:|r  " .. NWT.FormatGold(NWT.netWorth.furnitureVaultWithCrowns or NWT.netWorth.furnitureVault) .. "g") or "|c666666Vault:|r (off)") end
            if housing then housing:SetText(NWT.savedVars.includeMyHousing and ("|cFFFFAAHousing:|r  " .. NWT.FormatGold(NWT.netWorth.myHousingWithCrowns or NWT.netWorth.myHousing) .. "g") or "|c666666Housing:|r (off)") end
            if guildBanks then guildBanks:SetText("|cFFFFAAGuild Banks:|r  " .. NWT.FormatGold(NWT.netWorth.guildBanks or 0) .. "g") end
            if crowns then crowns:SetText("|c33CCFFCrowns:|r  " .. NWT.FormatGold(NWT.netWorth.crowns)) end
            if gems then gems:SetText("|cFF66CCGems:|r  " .. NWT.FormatGold(NWT.netWorth.crownGems)) end
            if crownItems then 
                -- Show TOTAL crown value across all locations (informational - already in breakdowns)
                local totalCrowns = NWT.netWorth.totalCrownValue or 0
                local crownText = "|c99CCFFCrown Items:|r  " .. NWT.FormatGold(totalCrowns)
                if NWT.netWorth.crownFurnitureAsGold and NWT.netWorth.crownFurnitureAsGold > 0 then
                    crownText = crownText .. " |c888888(included above)|r"
                end
                crownItems:SetText(crownText)
            end
            if wv then 
                -- Show TOTAL writ vouchers across all locations (informational - already in breakdowns)
                local totalWV = NWT.netWorth.totalWritVouchers or 0
                local wvText = "|c88FF88Writ Vouchers:|r  " .. NWT.FormatGold(totalWV) .. " WV"
                if NWT.netWorth.writVouchersAsGold and NWT.netWorth.writVouchersAsGold > 0 then
                    wvText = wvText .. " |c888888(included above)|r"
                end
                wv:SetText(wvText)
            end
        end
    end
    
    -- Center Column - Top Items
    local centerCol = ui:GetNamedChild("CenterCol")
    if centerCol then
        local list = centerCol:GetNamedChild("List")
        if list then
            for i = 1, 15 do
                local label = list:GetNamedChild("Item" .. i)
                if label then
                    local item = NWT.topItems[i]
                    if item then
                        local locText = item.location or ""
                        if #locText > 12 then locText = locText:sub(1,10) .. ".." end
                        local nameText = item.name or "Unknown"
                        if #nameText > 35 then nameText = nameText:sub(1,33) .. ".." end
                        label:SetText(string.format("|c888888%2d|r  |cFFFFFF%s|r  |c00FF00%sg|r  |c888888%s|r", i, nameText, NWT.FormatGold(item.value), locText))
                    else
                        label:SetText("")
                    end
                end
            end
        end
        local summary = centerCol:GetNamedChild("Summary")
        if summary then summary:SetText(string.format("|c888888Total items tracked: %d|r", #(NWT.topItems or {}))) end
    end
    
    -- Right Column
    local rightCol = ui:GetNamedChild("RightCol")
    if rightCol then
        -- Character Card
        local charCard = rightCol:GetNamedChild("CharCard")
        if charCard then
            local name = charCard:GetNamedChild("Name")
            local level = charCard:GetNamedChild("Level")
            local alliance = charCard:GetNamedChild("Alliance")
            local updated = charCard:GetNamedChild("Updated")
            if name then name:SetText("|c00FFFF" .. (GetUnitName("player") or "Unknown") .. "|r") end
            if level then level:SetText("Level " .. GetUnitLevel("player") .. " " .. GetUnitClass("player")) end
            if alliance then alliance:SetText(GetAllianceName(GetUnitAlliance("player"))) end
            if updated then updated:SetText("Updated: " .. GetTimeString()) end
        end
        
        -- Visiting House Card
        local visitCard = rightCol:GetNamedChild("VisitingCard")
        if visitCard then
            local houseName = visitCard:GetNamedChild("HouseName")
            local owner = visitCard:GetNamedChild("Owner")
            local value = visitCard:GetNamedChild("Value")
            local crownLabel = visitCard:GetNamedChild("CrownValue")
            local writLabel = visitCard:GetNamedChild("WritValue")
            local itemCount = visitCard:GetNamedChild("ItemCount")
            local hint = visitCard:GetNamedChild("Hint")
            
            local houseId = GetCurrentZoneHouseId()
            local inHouse = houseId and houseId > 0
            
            if inHouse and (NWT.netWorth.visitingHouseWithCrowns or 0) > 0 then
                local hName = NWT.netWorth.visitingHouseName or "Current House"
                if houseName then houseName:SetText("|cFF00FF" .. hName .. "|r") end
                if owner then owner:SetText("|c888888" .. (GetCurrentHouseOwner() or "") .. "|r") end
                -- Show gold value
                local totalVal = NWT.netWorth.visitingHouseWithCrowns or 0
                if value then value:SetText("|c00FF00" .. NWT.FormatGold(totalVal) .. "g|r") end
                -- Show crown value on separate line
                local crownVal = NWT.netWorth.visitingHouseCrowns or 0
                if crownLabel then 
                    if crownVal > 0 then
                        crownLabel:SetText("|cFFD700" .. NWT.FormatGold(crownVal) .. " crowns|r")
                    else
                        crownLabel:SetText("")
                    end
                end
                -- Show writ voucher value on separate line
                local wvVal = NWT.netWorth.visitingHouseWV or 0
                if writLabel then 
                    if wvVal > 0 then
                        writLabel:SetText("|c00FFFF" .. NWT.FormatGold(wvVal) .. " writ vouchers|r")
                    else
                        writLabel:SetText("")
                    end
                end
                if itemCount then itemCount:SetText((NWT.netWorth.visitingHouseItemCount or 0) .. " items") end
                if hint then hint:SetHidden(true) end
            else
                if houseName then houseName:SetText("|c666666Not in a house|r") end
                if owner then owner:SetText("") end
                if value then value:SetText("") end
                if crownLabel then crownLabel:SetText("") end
                if writLabel then writLabel:SetText("") end
                if itemCount then itemCount:SetText("") end
                if hint then hint:SetHidden(false) end
            end
        end
    end
end

-- Old UpdateGoldLedgerView removed - Gold Ledger now uses its own scene (ATK_GoldLedger_UI)

function NWT.RefreshNetWorthCurrentTab()
    -- Simple refresh - just update the current dashboard
    NWT.UpdateNetWorthDashboard()
end

function NWT.OpenNetWorthDashboard()
    if NWT.NetWorthDashboard.isOpen then return end
    -- If another dashboard is open, close it first to maintain proper scene stack
    if NWT.GoldLedgerDashboard.isOpen then SCENE_MANAGER:Hide("goldLedgerDashboardScene") end
    NWT.InitNetWorthDashboardScene()
    if not NET_WORTH_DASHBOARD_SCENE then return end
    NWT.UpdateNetWorthDashboard()
    SCENE_MANAGER:Push("netWorthDashboardScene")
end

function NWT.CloseNetWorthDashboard() if NET_WORTH_DASHBOARD_SCENE then SCENE_MANAGER:Hide("netWorthDashboardScene") end end
