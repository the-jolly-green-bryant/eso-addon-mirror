SandE = {}

local SandE = SandE
local SandEmoteList = SandEmoteList
SandEmoteList:SetDeleteCallback(function (index)
    if index < 1 then
        return
    end

    local emoteIndex = SandE.currentEmoteIndex

    if SandE.currentEmoteType == SandE.CURRENT then
        emoteIndex = SandE.sv.EmoteCurrent
    end

    table.remove(SandE.sv.EmoteLists[emoteIndex], index)
    SandE.sv.EmoteListLengths[emoteIndex] = SandE.sv.EmoteListLengths[emoteIndex] - 1

    if emoteIndex == SandE.sv.EmoteCurrent then
        SandEmoteList:SetPlayingList(
            SandE.sv.EmoteLists[emoteIndex],
            SandE.sv.EmoteListLengths[emoteIndex],
            SandE.sv.EmoteRandom[emoteIndex]
        )
    end
end)

SandEmoteList:SetTextChangedCallback(function (index, action, time)
    local emoteIndex = SandE.currentEmoteIndex

    if SandE.currentEmoteType == SandE.CURRENT then
        emoteIndex = SandE.sv.EmoteCurrent
    end

    if action then
        SandE.sv.EmoteLists[emoteIndex][index].action = action
        SandE.sv.EmoteLists[emoteIndex][index].emoteIndex = SandEmoteList:GetEmoteIndex(action)
    elseif time then
        SandE.sv.EmoteLists[emoteIndex][index].time = time
    end

    if emoteIndex == SandE.sv.EmoteCurrent then
        SandEmoteList:SetPlayingList(
            SandE.sv.EmoteLists[emoteIndex],
            SandE.sv.EmoteListLengths[emoteIndex],
            SandE.sv.EmoteRandom[emoteIndex]
        )
    end
end)

SandE.name = "SandE"
SandE.version = 2.13
SandE.displayName = ""
SandE.displayName = SandE.displayName .. "|cffffff" .. "S" .. "|r"
SandE.displayName = SandE.displayName .. "|ccccccc" .. "t" .. "|r"
SandE.displayName = SandE.displayName .. "|caaaaaa" .. "y" .. "|r"
SandE.displayName = SandE.displayName .. "|c888888" .. "l" .. "|r"
SandE.displayName = SandE.displayName .. "|c666666" .. "e" .. "|r"
SandE.displayName = SandE.displayName .. "|cffffff" .. " " .. "|r"
SandE.displayName = SandE.displayName .. "|c333333" .. "a" .. "|r"
SandE.displayName = SandE.displayName .. "|c333333" .. "n" .. "|r"
SandE.displayName = SandE.displayName .. "|c333333" .. "d" .. "|r"
SandE.displayName = SandE.displayName .. "|cffffff" .. " " .. "|r"
SandE.displayName = SandE.displayName .. "|c666666" .. "E" .. "|r"
SandE.displayName = SandE.displayName .. "|c777777" .. "l" .. "|r"
SandE.displayName = SandE.displayName .. "|c888888" .. "e" .. "|r"
SandE.displayName = SandE.displayName .. "|c999999" .. "g" .. "|r"
SandE.displayName = SandE.displayName .. "|cbbbbbb" .. "a" .. "|r"
SandE.displayName = SandE.displayName .. "|cdddddd" .. "n" .. "|r"
SandE.displayName = SandE.displayName .. "|ceeeeee" .. "c" .. "|r"
SandE.displayName = SandE.displayName .. "|cffffff" .. "e" .. "|r"

SandE.NO_TITLE = "No Title"
SandE.CURRENT = "Current"
SandE.USER = "User"

SandE.configTypes = {
    SandE.CURRENT,
    SandE.USER,
}

SandE.currentCurrent = nil
SandE.currentSlot = nil
SandE.currentIndex = -1
SandE.currentType = SandE.CURRENT
SandE.currentEmoteType = SandE.CURRENT
SandE.disableUpdates = false

SandE.currentEmoteIndex = -1

SandE.bindingStartingIndex = -1

SandE.NEW = "+  - New - +"
SandE.NOCOPY = "x  - No Copy - x"
SandE.NOTHING = "x  - No Idle Anim - x"

SandE.COLLECTIBLES = {
    COLLECTIBLE_CATEGORY_TYPE_MOUNT             ,
    COLLECTIBLE_CATEGORY_TYPE_VANITY_PET        ,
    COLLECTIBLE_CATEGORY_TYPE_COSTUME           ,
    COLLECTIBLE_CATEGORY_TYPE_PERSONALITY       ,
    COLLECTIBLE_CATEGORY_TYPE_HAT               ,
    COLLECTIBLE_CATEGORY_TYPE_SKIN              ,
    COLLECTIBLE_CATEGORY_TYPE_POLYMORPH         ,
    COLLECTIBLE_CATEGORY_TYPE_HAIR              ,
    COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS ,
    COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY  ,
    COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY  ,
    COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING      ,
    COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING      ,
}

SandE.COLLECTIBLE_STRINGS = {
    [COLLECTIBLE_CATEGORY_TYPE_MOUNT            ] = "|cffffffMount|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_VANITY_PET       ] = "|cff0000Vanity Pet|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_COSTUME          ] = "|cffaa00Costume|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_PERSONALITY      ] = "|cffff00Personality|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_HAT              ] = "|caaff00Hat|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_SKIN             ] = "|c00ff00Skin|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_POLYMORPH        ] = "|c00ffaaPolymorph|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_HAIR             ] = "|c00ffffHair|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = "|c00aaffFacial Hair or Horns|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY ] = "|c0000ffFacial Accessory|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY ] = "|caa00ffJewelery|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING     ] = "|cff00ffHead Marking|r" ,
    [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING     ] = "|cff00aaBody Marking|r" ,
}

SandE.UIItems = {
    [COLLECTIBLE_CATEGORY_TYPE_MOUNT            ] = { SandEWindow_Item_2_Icon , SandEWindow_Item_2_Label , SandEWindow_Item_2 , },
    [COLLECTIBLE_CATEGORY_TYPE_VANITY_PET       ] = { SandEWindow_Item_3_Icon , SandEWindow_Item_3_Label , SandEWindow_Item_3 , },
    [COLLECTIBLE_CATEGORY_TYPE_COSTUME          ] = { SandEWindow_Item_4_Icon , SandEWindow_Item_4_Label , SandEWindow_Item_4 , },
    [COLLECTIBLE_CATEGORY_TYPE_PERSONALITY      ] = { SandEWindow_Item_9_Icon , SandEWindow_Item_9_Label , SandEWindow_Item_9 , },
    [COLLECTIBLE_CATEGORY_TYPE_HAT              ] = { SandEWindow_Item_10_Icon, SandEWindow_Item_10_Label, SandEWindow_Item_10, },
    [COLLECTIBLE_CATEGORY_TYPE_SKIN             ] = { SandEWindow_Item_11_Icon, SandEWindow_Item_11_Label, SandEWindow_Item_11, },
    [COLLECTIBLE_CATEGORY_TYPE_POLYMORPH        ] = { SandEWindow_Item_12_Icon, SandEWindow_Item_12_Label, SandEWindow_Item_12, },
    [COLLECTIBLE_CATEGORY_TYPE_HAIR             ] = { SandEWindow_Item_13_Icon, SandEWindow_Item_13_Label, SandEWindow_Item_13, },
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = { SandEWindow_Item_14_Icon, SandEWindow_Item_14_Label, SandEWindow_Item_14, },
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY ] = { SandEWindow_Item_15_Icon, SandEWindow_Item_15_Label, SandEWindow_Item_15, },
    [COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY ] = { SandEWindow_Item_16_Icon, SandEWindow_Item_16_Label, SandEWindow_Item_16, },
    [COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING     ] = { SandEWindow_Item_17_Icon, SandEWindow_Item_17_Label, SandEWindow_Item_17, },
    [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING     ] = { SandEWindow_Item_18_Icon, SandEWindow_Item_18_Label, SandEWindow_Item_18, },
}

SandE.Template = {
    [COLLECTIBLE_CATEGORY_TYPE_MOUNT            ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_VANITY_PET       ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_COSTUME          ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_PERSONALITY      ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_HAT              ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_SKIN             ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_POLYMORPH        ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_HAIR             ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING     ] = 0,
    [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING     ] = 0,
}

SandE.BINDING_NAMES = {
    "SI_BINDING_NAME_SANDE_BIND1",
    "SI_BINDING_NAME_SANDE_BIND2",
    "SI_BINDING_NAME_SANDE_BIND3",
    "SI_BINDING_NAME_SANDE_BIND4",
    "SI_BINDING_NAME_SANDE_BIND5",
    "SI_BINDING_NAME_SANDE_BIND6",
    "SI_BINDING_NAME_SANDE_BIND7",
    "SI_BINDING_NAME_SANDE_BIND8",
    "SI_BINDING_NAME_SANDE_BIND9",
    "SI_BINDING_NAME_SANDE_BIND10",
    "SI_BINDING_NAME_SANDE_BIND11",
    "SI_BINDING_NAME_SANDE_BIND12",
}

SandE.BINDING_IDS = { }

SandE.Defaults = {}
SandE.Defaults.User = {}
SandE.Defaults.UserEmoteIndex = {}
SandE.Defaults.UserOutfit = {}
SandE.Defaults.UserTitle = {} -- Deprecated
SandE.Defaults.UserTitleString = {}
SandE.Defaults.UserMountOptions = {}
SandE.Defaults.UserMap = {}
SandE.Defaults.EmoteCurrent = -1
SandE.Defaults.EmoteLists = {}
SandE.Defaults.EmoteListLengths = {}
SandE.Defaults.EmoteMap = {}
SandE.Defaults.EmoteRandom = {}
SandE.Defaults.userCount = 0
SandE.Defaults.emoteCount = 0
SandE.Defaults.ui = {}
SandE.Defaults.ui.point = 3
SandE.Defaults.ui.relPoint = 3
SandE.Defaults.ui.offsetX = 406.68145751953
SandE.Defaults.ui.offsetY = 194.69073486328
SandE.Defaults.ui.buttonX = 0
SandE.Defaults.ui.buttonY = 0
SandE.Defaults.ui.showIcon = true
SandE.Defaults.ui.autoShow = true

SandE.titleIndices = {}

local function createSettings() -- {{{
    local LAM = LibAddonMenu2

    local settingsWindowData = {
        type = "panel",
        name = SandE.displayName,
        author = "|caaffeFJodynn|r",
        version = tostring(SandE.version),
        slashCommand = "/outfitsettings"
    }

    local settingsOptionsData = {
        {
            type = "checkbox",
            name = "Auto show/hide",
            tooltip = "When you open the Collection book choose to auto show/hide when it leaves",
            default = SandE.Defaults.ui.autoShow,
            getFunc = function() return SandE.sv.ui.autoShow end,
            setFunc = function(newValue)
                SandE.sv.ui.autoShow = newValue
            end,
        },
        {
            type = "checkbox",
            name = "Show image button to open SandE's UI.",
            tooltip = "Toggles whether or not you want to show the icon that tells you the keybinding and a button to open the UI and move around.",
            default = SandE.sv.ui.showIcon,
            getFunc = function() return SandE.sv.ui.showIcon end,
            setFunc = function(newValue)
                SandE.sv.ui.showIcon = newValue
                Outfit_UI_ButtonBg:SetHidden(not newValue)
                Outfit_UI_Button:SetHidden(not newValue)
                Outfit_UI_ButtonLabel:SetHidden(not newValue)
            end,
        },
    }

    local settingsOptionPanel = LAM:RegisterAddonPanel(SandE.name.."_LAM", settingsWindowData)
    LAM:RegisterOptionControls(SandE.name.."_LAM", settingsOptionsData)
end -- }}}

function toggleSandEUI()
    SandEWindow:SetHidden(not SandEWindow:IsHidden())
end

function selectSandEKeyBinding(bind)
    if SandE.sv.userCount < bind then
        return
    end

    SandE.currentIndex = bind
    SandE.currentSlot = SandE.sv.User[SandE.currentIndex]
    SandE:Load()
    SandE.mainComboBox:SelectFirstItem()
end

function SandE:Open()
    SandEWindow:SetHidden(false)
end

function SandE:Close()
    SandEWindow:SetHidden(true)
end

function SandE:reloadComboBox2()
    SandE.comboBox2:ClearItems()
    SandE:reloadEmoteComboBoxSel()

    function OutfitSelectCallback(comboBox, itemName, item, selectionChanged)
        if itemName == SandE.NEW then
            SandE.sv.userCount = SandE.sv.userCount + 1

            SandE.sv.User[SandE.sv.userCount] = {
                [COLLECTIBLE_CATEGORY_TYPE_MOUNT            ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_VANITY_PET       ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_COSTUME          ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_PERSONALITY      ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_HAT              ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_SKIN             ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_POLYMORPH        ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_HAIR             ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING     ] = 0,
                [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING     ] = 0,
            }
            SandE.sv.UserOutfit[SandE.sv.userCount] = 0
            SandE.sv.UserTitleString[SandE.sv.userCount] = SandE.NO_TITLE
            SandE.sv.UserMountOptions[SandE.currentIndex] = {
                GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE),
                GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE),
                GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE)
            }
            SandE.sv.UserMap[SandE.sv.userCount] = "New"
            SandE.sv.UserEmoteIndex[SandE.sv.userCount] = -1

            local name = SandE:getEntryName(SandE.sv.userCount, "New")
            local itemEntry = SandE.comboBox2:CreateItemEntry(name, OutfitSelectCallback)
            SandE.comboBox2:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
            SandE.currentIndex = SandE.sv.userCount
            SandE:reloadComboBox2()
            SandE.comboBox2:SetSelectedItem(name)
        else
            SandE.currentIndex = tonumber(string.match(itemName, "%d+"))
        end

        SandE.currentSlot = SandE.sv.User[SandE.currentIndex]
        SandE:reloadEmoteComboBoxSel()

        SandE:UpdateUI()

        SandE.o_outfitComboBox:SetHidden(false)
        SandE.o_emoteSelCombo:SetHidden(false)
        SandE.o_titleComboBox:SetHidden(false)
        SandEWindowSaveButton:SetHidden(false)
        SandEWindowLoadButton:SetHidden(false)
        SandEWindowDeleteButton:SetHidden(false)
        SandEWindowRandomButton:SetHidden(false)
        SandEWindowRenameEditBoxBackdrop:SetHidden(false)
        SandE.o_stamCheck:SetHidden(false)
        SandE.o_speedCheck:SetHidden(false)
        SandE.o_inventoryCheck:SetHidden(false)
    end


    local itemEntry = SandE.comboBox2:CreateItemEntry(SandE.NEW, OutfitSelectCallback)
    SandE.comboBox2:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)

    for i, name in pairs(SandE.sv.User) do
        local entryName = SandE:getEntryName(i, SandE.sv.UserMap[i])
        itemEntry = SandE.comboBox2:CreateItemEntry(entryName, OutfitSelectCallback)
        SandE.comboBox2:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
        -- ZO_CreateStringId(SandE.BINDING_NAMES[i], entryName)
        EsoStrings[SandE.bindingStartingIndex + i - 1] = entryName
    end

    for i=SandE.sv.userCount + 1, #SandE.BINDING_NAMES do
        EsoStrings[SandE.bindingStartingIndex + i - 1] = "NO OUTFIT MADE YET : " .. tostring(i)
    end

    KEYBINDING_MANAGER:RefreshList()
end

function SandE:reloadEmoteComboBoxSel()
    SandE.emoteSelCombo:ClearItems()

    function EmoteSelectCallback2(comboBox, itemName, item, selectionChanged)
        local currentIndex = tonumber(string.match(itemName, "%d+"))

        if SandE.currentType == SandE.CURRENT then
            if itemName == SandE.NOTHING then
                if SandE.currentEmoteType == SandE.CURRENT then
                    SandEmoteList:ClearList()
                end
                SandE.sv.EmoteCurrent = -1
                SandEmoteList:Stop()
            else
                SandE.sv.EmoteCurrent = currentIndex

                SandEmoteList:SetPlayingList(
                    SandE.sv.EmoteLists[currentIndex],
                    SandE.sv.EmoteListLengths[currentIndex],
                    SandE.sv.EmoteRandom[currentIndex]
                )
                SandEmoteList:Start()

                if SandE.currentEmoteType == SandE.CURRENT then
                    SandEmoteList:ClearList()
                    SandEmoteList:NewTable(
                        SandE.sv.EmoteLists[SandE.sv.EmoteCurrent],
                        SandE.sv.EmoteListLengths[SandE.sv.EmoteCurrent]
                    )
                end
            end
        else
            if itemName == SandE.NOTHING then
                SandE.sv.UserEmoteIndex[SandE.currentIndex] = -1
            else
                SandE.sv.UserEmoteIndex[SandE.currentIndex] = currentIndex
            end
        end

        SandE:UpdateEmoteUI()
    end

    local itemEntry = SandE.emoteSelCombo:CreateItemEntry(SandE.NOTHING, EmoteSelectCallback2)
    SandE.emoteSelCombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)

    for i, name in ipairs(SandE.sv.EmoteLists) do
        local entryName = SandE:getEntryName(i, SandE.sv.EmoteMap[i])
        local itemEntry = SandE.emoteSelCombo:CreateItemEntry(entryName, EmoteSelectCallback2)
        SandE.emoteSelCombo:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    if SandE.currentType == SandE.CURRENT then
        if SandE.sv.EmoteCurrent == -1 then
            SandE.emoteSelCombo:SetSelectedItem(SandE.NOTHING)
        else
            local text = SandE.sv.EmoteMap[SandE.sv.EmoteCurrent]
            local entryName = SandE:getEntryName(SandE.sv.EmoteCurrent, text)
            SandE.emoteSelCombo:SetSelectedItem(entryName)
        end
    else
        local index = SandE.sv.UserEmoteIndex[SandE.currentIndex]
        if index == -1 then
            SandE.emoteSelCombo:SetSelectedItem(SandE.NOTHING)
        else
            local text = SandE.sv.EmoteMap[index]
            local entryName = SandE:getEntryName(index, text)
            SandE.emoteSelCombo:SetSelectedItem(entryName)
        end
    end
end

function SandE:reloadEmoteComboBox2()
    SandE.emoteComboBox2:ClearItems()

    function EmoteSelectCallback(comboBox, itemName, item, selectionChanged)
        SandEmoteList:ClearList()

        if itemName == SandE.NEW then
            SandE.sv.emoteCount = SandE.sv.emoteCount + 1

            SandE.sv.EmoteLists[SandE.sv.emoteCount] = { }
            SandE.sv.EmoteListLengths[SandE.sv.emoteCount] = 0
            SandE.sv.EmoteMap[SandE.sv.emoteCount] = "New"
            SandE.sv.EmoteRandom[SandE.sv.emoteCount] = false

            local name = SandE:getEntryName(SandE.sv.emoteCount, "New")
            local itemEntry = SandE.emoteComboBox2:CreateItemEntry(name, EmoteSelectCallback)
            SandE.emoteComboBox2:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
            SandE.currentEmoteIndex = SandE.sv.emoteCount
            SandE:reloadEmoteComboBox2()
            SandE.emoteComboBox2:SetSelectedItem(name)
        else
            SandE.currentEmoteIndex = tonumber(string.match(itemName, "%d+"))

            SandEmoteList:NewTable(
                SandE.sv.EmoteLists[SandE.currentEmoteIndex],
                SandE.sv.EmoteListLengths[SandE.currentEmoteIndex]
            )
        end

        SandE.reloadEmoteComboBoxSel()
        SandE:SetupCopyCombo()
        SandE:UpdateUI()

        SandEWindowEmotesContainerTimeBD:SetHidden(false)
        SandEWindowEmotesContainerSlashBD:SetHidden(false)
        SandEWindowEmotesContainerRenameBD:SetHidden(false)
        SandEWindowEmotesContainerAddButton:SetHidden(false)
        SandEWindowEmotesContainerDeleteButton:SetHidden(false)
        SandEWindowEmotesContainerActionDropdown:SetHidden(false)
        SandEWindowEmotesContainerCopyDropdown:SetHidden(false)
    end

    local itemEntry = SandE.emoteComboBox2:CreateItemEntry(SandE.NEW, EmoteSelectCallback)
    SandE.emoteComboBox2:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)

    for i, name in ipairs(SandE.sv.EmoteLists) do
        local entryName = SandE:getEntryName(i, SandE.sv.EmoteMap[i])
        itemEntry = SandE.emoteComboBox2:CreateItemEntry(entryName, EmoteSelectCallback)
        SandE.emoteComboBox2:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end
end

function SandE:GetRandom(catType)
    local list = {0}
    local count = 0
    for i=count + 1, GetTotalCollectiblesByCategoryType(catType) do
        local colId = GetCollectibleIdFromType(catType, i)
        if IsCollectibleUnlocked(colId) and IsCollectibleUsable(colId) and IsCollectibleValidForPlayer(colId) then
            count = count + 1
            list[count] = colId
        end
    end

    if count > 0 then
        local ran = math.random(count)
        local id = list[ran]

        if SandE.currentType == SandE.CURRENT then
            if id == 0 and i ~= COLLECTIBLE_CATEGORY_TYPE_MOUNT then
                id = SandE.currentCurrent[i]
                UseCollectible(id)
            else
                UseCollectible(id)
            end
        else
            SandE.currentSlot[catType] = id
        end
    end
end

function SandE:GetRandomAll()
    for i, x in ipairs(SandE.COLLECTIBLES) do
        SandE:GetRandom(x)
    end

    SandE:UpdateUI()
end

function SandE:GetOutfitName(i)
    if i == 0 then
        return "No Outfit"
    else
        return GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
    end
end

function SandE:GetTitleIndex(title)
    return SandE.titleIndices[title]
end

function SandE:GetTitle(i)
    if i == 0 then
        return SandE.NO_TITLE
    else
        return GetTitle(i)
    end
end

function SandE:RenameUser(text)
    if text == nil or text == '' then
        return
    end

    SandE.sv.UserMap[SandE.currentIndex] = text

    SandE:reloadComboBox2()

    local entryName = SandE:getEntryName(SandE.currentIndex, text)
    SandE.comboBox2:SetSelectedItem(entryName)

    SandEWindowRenameEditBoxBackdropEditBox:SetText("Rename")
    SandEWindowRenameEditBoxBackdropEditBox:SetColor(.7,.7,.5,.5)
end

function SandE:Delete()
    table.remove(SandE.sv.User, SandE.currentIndex)
    table.remove(SandE.sv.UserOutfit, SandE.currentIndex)
    table.remove(SandE.sv.UserTitleString, SandE.currentIndex)
    table.remove(SandE.sv.UserMap, SandE.currentIndex)
    table.remove(SandE.sv.UserMountOptions, SandE.currentIndex)
    table.remove(SandE.sv.UserEmoteIndex, SandE.currentIndex)

    SandE.sv.userCount = SandE.sv.userCount - 1

    SandE.mainComboBox:UpdateItems()
    SandE.mainComboBox:SelectFirstItem()

    SandE:reloadComboBox2()
end

function SandE:Save()
    for i, id in pairs(SandE.currentCurrent) do
        SandE.currentSlot[i] = id
    end

    SandE.sv.UserOutfit[SandE.currentIndex] = GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
    SandE.sv.UserTitleString[SandE.currentIndex] = SandE:GetTitle(GetCurrentTitleIndex() or 0)
    SandE.sv.UserMountOptions[SandE.currentIndex] = {
        GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE),
        GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE),
        GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE)
    }

    SandE:UpdateUI()
end

function SandE:Load()
    SandE.disableUpdates = true

    for i, id in pairs(SandE.currentSlot) do
        if id == 0 and i ~= COLLECTIBLE_CATEGORY_TYPE_MOUNT then
            id = SandE.currentCurrent[i]

            if IsCollectibleUsable(id) then
                UseCollectible(id)
            end
        elseif SandE.currentCurrent[i] ~= id then
            if IsCollectibleUsable(id) then
                UseCollectible(id)
            end
        end
    end

    local index = SandE.sv.UserOutfit[SandE.currentIndex]
    if index == 0 then
        UnequipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    else
        EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    end

    if SandE.sv.UserTitleString[SandE.currentIndex] ~= SandE.NO_TITLE then
        SelectTitle(SandE:GetTitleIndex(SandE.sv.UserTitleString[SandE.currentIndex]))
    end

    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE, SandE.sv.UserMountOptions[SandE.currentIndex][1])
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE, SandE.sv.UserMountOptions[SandE.currentIndex][2])
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE, SandE.sv.UserMountOptions[SandE.currentIndex][3])

    local emoteIndex = SandE.sv.UserEmoteIndex[SandE.currentIndex]
    if emoteIndex ~= -1 then
        SandEmoteList:SetPlayingList(
            SandE.sv.EmoteLists[emoteIndex],
            SandE.sv.EmoteListLengths[emoteIndex],
            SandE.sv.EmoteRandom[emoteIndex]
        )
        SandEmoteList:Start()
    else
        SandEmoteList:Stop()
    end

    SandE.sv.EmoteCurrent = emoteIndex

    SandE.disableUpdates = false
end

function SandE:getEntryName(index, name)
    -- if either are nil, ignore..

    if ( index == nil or name == nil ) then
        return ""
    else
        return string.format("%d : %s", index, name)
    end
end

function SandE:setTooltip(control, text)
    control.data = { tooltipText = text }

    control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
end

function SandE:SetupOutfitCombo()
    SandE.outfitComboBox:ClearItems()

    function OutfitIndexCallback(comboBox, itemName, item, selectionChanged)
        local index = tonumber(string.match(itemName, "%d+"))
        if SandE.currentType == SandE.CURRENT then
            if index == 0 then
                UnequipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
            else
                EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
            end
        else
            SandE.sv.UserOutfit[SandE.currentIndex] = index
        end
    end

    local FIRST_INDEX = 0
    local LAST_INDEX  = GetNumUnlockedOutfits(GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    for i=FIRST_INDEX, LAST_INDEX do
        local name = SandE:GetOutfitName(i)
        name = SandE:getEntryName(i, name)
        local itemEntry = SandE.mainComboBox:CreateItemEntry(name, OutfitIndexCallback)
        SandE.outfitComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    SandE.outfitComboBox:UpdateItems()
    local index = GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
    SandE.outfitComboBox:SetSelectedItem(SandE:getEntryName(index, SandE:GetOutfitName(index)))
end

function SandE:SetupTitleCombo()
    if SandE.titleComboBox == nil then
        return
    end

    SandE.titleComboBox:ClearItems()

    function OutfitTitleIndexCallback(comboBox, itemName, item, selectionChanged)
        if SandE.currentType == SandE.CURRENT then
            SelectTitle(SandE:GetTitleIndex(itemName))
        else
            SandE.sv.UserTitleString[SandE.currentIndex] = itemName
        end
    end

    for i=0, GetNumTitles() do
        local name = SandE:GetTitle(i)
        SandE.titleIndices[name] = i
        local itemEntry = SandE.mainComboBox:CreateItemEntry(name, OutfitTitleIndexCallback)
        SandE.titleComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    SandE.titleComboBox:UpdateItems()
    local index = GetCurrentTitleIndex() or 0
    -- takes a bit of time for strings I guess?
    zo_callLater(function()
        SandE.titleComboBox:SetSelectedItem(SandE:GetTitle(index))
    end, 1000)
end

function SandE:SetupActionCombo()
    SandE.actionComboBox:ClearItems()

    function emoteCallback(comboBox, itemName, item, selectionChanged)
        PlayEmoteByIndex(SandEmoteList:GetEmoteIndex(itemName))
        SandEWindowEmotesContainerSlashBDEditBox:SetText(itemName)
        SandEWindowEmotesContainerTimeBDEditBox:TakeFocus()
    end

    for i=1, SandEmoteList.playableEmotesLength do
        local emote = SandEmoteList.playableEmotes[i]
        local name = SandE:getEntryName(i, emote.slash .. ' ' .. emote.displayName)
        name = emote.slash
        local itemEntry = SandE.mainComboBox:CreateItemEntry(name, emoteCallback)
        SandE.actionComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    SandE.actionComboBox:UpdateItems()
    SandE.actionComboBox:SetSelectedItem("/angry")
end

function SandE:SetupCopyCombo()
    SandE.copyComboBox:ClearItems()

    function copyCallback(comboBox, itemName, item, selectionChanged)
        local index = tonumber(string.match(itemName, "%d+"))

        for v in next, SandE.sv.EmoteLists[SandE.currentEmoteIndex] do
            rawset(SandE.sv.EmoteLists[SandE.currentEmoteIndex], v, nil)
        end

        SandEmoteList:ClearList()

        for i, p in ipairs(SandE.sv.EmoteLists[index]) do
            SandE.sv.EmoteLists[SandE.currentEmoteIndex][i] = {}
            for n, x in pairs(p) do
                SandE.sv.EmoteLists[SandE.currentEmoteIndex][i][n] = x
            end
        end

        SandE.sv.EmoteListLengths[SandE.currentEmoteIndex] = SandE.sv.EmoteListLengths[index]

        SandE.sv.EmoteRandom[SandE.currentEmoteIndex] = SandE.sv.EmoteRandom[index]

        SandEmoteList:NewTable(
            SandE.sv.EmoteLists[SandE.currentEmoteIndex],
            SandE.sv.EmoteListLengths[SandE.currentEmoteIndex]
        )

        SandE.copyComboBox:SetSelectedItem(SandE.NOCOPY)

        if SandE.sv.EmoteCurrent == SandE.currentEmoteIndex then
            SandEmoteList:SetPlayingList(
                SandE.sv.EmoteLists[SandE.currentEmoteIndex],
                SandE.sv.EmoteListLengths[SandE.currentEmoteIndex],
                SandE.sv.EmoteRandom[SandE.currentEmoteIndex]
            )
        end

        SandE:UpdateEmoteUI()
    end

    local itemEntry = SandE.copyComboBox:CreateItemEntry(SandE.NOCOPY, EmoteSelectCallback2)
    SandE.copyComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)

    for i, name in ipairs(SandE.sv.EmoteMap) do
        if i ~= SandE.currentEmoteIndex then
            local entryName = SandE:getEntryName(i, "Copy List: " ..SandE.sv.EmoteMap[i])
            local itemEntry = SandE.copyComboBox:CreateItemEntry(entryName, copyCallback)
            SandE.copyComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
        end
    end

    SandE.copyComboBox:UpdateItems()
    SandE.copyComboBox:SetSelectedItem(SandE.NOCOPY)
end

function SandE:DeleteList()
    table.remove(SandE.sv.EmoteLists, SandE.currentEmoteIndex)
    table.remove(SandE.sv.EmoteMap, SandE.currentEmoteIndex)
    table.remove(SandE.sv.EmoteListLengths, SandE.currentEmoteIndex)
    table.remove(SandE.sv.EmoteRandom, SandE.currentEmoteIndex)

    SandE.sv.emoteCount = SandE.sv.emoteCount - 1
    SandE.sv.EmoteCurrent = -1
    SandEmoteList:Stop()

    SandE.emoteComboBox:UpdateItems()
    SandE.emoteComboBox:SelectFirstItem()
    SandE.emoteSelCombo:SetSelectedItem(SandE.NOTHING)
    SandEmoteList:ClearList()

    SandE:reloadEmoteComboBox2()
    SandE:reloadEmoteComboBoxSel()
end

function SandE:RenameEmoteList(text)
    if text == nil or text == '' then
        return
    end

    SandE.sv.EmoteMap[SandE.currentEmoteIndex] = text

    SandE:reloadEmoteComboBox2()
    SandE:reloadEmoteComboBoxSel()

    local entryName = SandE:getEntryName(SandE.currentEmoteIndex, text)
    SandE.emoteComboBox2:SetSelectedItem(entryName)

    SandEWindowEmotesContainerRenameBDEditBox:SetText("Rename")
    SandEWindowEmotesContainerRenameBDEditBox:SetColor(.7,.7,.5,.5)
end

function SandE:AddToList()
    local action = SandEWindowEmotesContainerSlashBDEditBox:GetText()
    local time = SandEWindowEmotesContainerTimeBDEditBox:GetText()

    if not tonumber(time) then
        d ( "You need to enter a number" )
        return
    end

    local emoteIndex = SandEmoteList:GetEmoteIndex(action)

    if SandEmoteList:GetEmoteIndex(action) == nil and not SandEmoteList:IsSpecialAction(action) then
        d ( "You need to enter a valid slash command ( You may not own that emote )" )
        return
    end

    SandEWindowEmotesContainerSlashBDEditBox:Clear()
    SandEWindowEmotesContainerTimeBDEditBox:Clear()
    SandEWindowEmotesContainerSlashBDEditBox:TakeFocus()

    local rtn = SandEmoteList:NewAction(action, time, emoteIndex)
    table.insert(SandE.sv.EmoteLists[SandE.currentEmoteIndex], rtn)
    SandE.sv.EmoteListLengths[SandE.currentEmoteIndex] = SandE.sv.EmoteListLengths[SandE.currentEmoteIndex] + 1

    if SandE.currentEmoteIndex == SandE.sv.EmoteCurrent then
        SandEmoteList:SetPlayingList(
            SandE.sv.EmoteLists[SandE.currentEmoteIndex],
            SandE.sv.EmoteListLengths[SandE.currentEmoteIndex],
            SandE.sv.EmoteRandom[SandE.currentEmoteIndex]
        )
    end
end

function SandE:CreateWindow()
    SandE:MakeEmoteList()

    local o_comboBox = WINDOW_MANAGER:GetControlByName("SandEWindow", "Dropdown")
    local o_comboBox2 = WINDOW_MANAGER:GetControlByName("SandEWindow", "Dropdown2")
    local o_emoteComboBox = WINDOW_MANAGER:GetControlByName("SandEWindowEmotesContainer", "Dropdown")
    local o_emoteComboBox2 = WINDOW_MANAGER:GetControlByName("SandEWindowEmotesContainer", "Dropdown2")
    local o_actionComboBox = WINDOW_MANAGER:GetControlByName("SandEWindowEmotesContainer", "ActionDropdown")
    local o_copyComboBox = WINDOW_MANAGER:GetControlByName("SandEWindowEmotesContainer", "CopyDropdown")
    SandE.o_outfitComboBox = WINDOW_MANAGER:GetControlByName("SandEWindow", "Dropdown3")
    SandE.o_titleComboBox = WINDOW_MANAGER:GetControlByName("SandEWindow", "Dropdown4")
    SandE.o_emoteSelCombo = WINDOW_MANAGER:GetControlByName("SandEWindow", "DropdownEmote")
    SandE.o_stamCheck  = WINDOW_MANAGER:GetControlByName("SandEWindow", "Stam_Check")
    SandE.o_speedCheck  = WINDOW_MANAGER:GetControlByName("SandEWindow", "Speed_Check")
    SandE.o_inventoryCheck  = WINDOW_MANAGER:GetControlByName("SandEWindow", "Inventory_Check")
    SandE.o_emoteRandomCheck  = WINDOW_MANAGER:GetControlByName("SandEWindowEmotesContainer", "RandomCheck")

    SandE:setTooltip(SandE.o_stamCheck, "Show stamina mount upgrades.")
    SandE:setTooltip(SandE.o_speedCheck, "Show speed mount upgrades.")
    SandE:setTooltip(SandE.o_inventoryCheck, "Show inventory mount upgrades.")
    SandE:setTooltip(SandE.o_emoteRandomCheck, "Play in random order instead of in sequential order as they are listed.")

    SandE:setTooltip(SandE.o_outfitComboBox, "If you are currently looking at your current outfit, set it to that outfit, if you are looking at a custom user outfit, then set it for that loadout.")

    SandE.mainComboBox   = o_comboBox.m_comboBox
    SandE.comboBox2  = o_comboBox2.m_comboBox
    SandE.outfitComboBox  = SandE.o_outfitComboBox.m_comboBox
    SandE.titleComboBox  = SandE.o_titleComboBox.m_comboBox
    SandE.emoteSelCombo  = SandE.o_emoteSelCombo.m_comboBox
    SandE.emoteComboBox  = o_emoteComboBox.m_comboBox
    SandE.emoteComboBox2  = o_emoteComboBox2.m_comboBox
    SandE.actionComboBox  = o_actionComboBox.m_comboBox
    SandE.copyComboBox  = o_copyComboBox.m_comboBox

    SandE.mainComboBox:SetSortsItems(true)
    SandE.comboBox2:SetSortsItems(true)
    SandE.outfitComboBox:SetSortsItems(true)
    SandE.titleComboBox:SetSortsItems(true)
    SandE.actionComboBox:SetSortsItems(true)

    SandE.mainComboBox:ClearItems()
    SandE.comboBox2:ClearItems()

    SandE.comboBox2.m_dropdown:SetHandler("OnShow", function(self)
        o_comboBox2:SetDimensions(400,30)
    end)

    SandE.comboBox2.m_dropdown:SetHandler("OnHide", function(self)
        o_comboBox2:SetDimensions(150,30)
    end)

    SandE.outfitComboBox.m_dropdown:SetHandler("OnShow", function(self)
        SandE.o_outfitComboBox:SetDimensions(400,30)
    end)

    SandE.outfitComboBox.m_dropdown:SetHandler("OnHide", function(self)
        SandE.o_outfitComboBox:SetDimensions(250,30)
    end)

    SandE.titleComboBox.m_dropdown:SetHandler("OnShow", function(self)
        SandE.o_titleComboBox:SetDimensions(400,30)
    end)

    SandE.titleComboBox.m_dropdown:SetHandler("OnHide", function(self)
        SandE.o_titleComboBox:SetDimensions(250,30)
    end)

    SandE.emoteSelCombo.m_dropdown:SetHandler("OnShow", function(self)
        SandE.o_emoteSelCombo:SetDimensions(400,30)
    end)

    SandE.emoteSelCombo.m_dropdown:SetHandler("OnHide", function(self)
        SandE.o_emoteSelCombo:SetDimensions(250,30)
    end)

    SandE.emoteComboBox2.m_dropdown:SetHandler("OnShow", function(self)
        o_emoteComboBox2:SetDimensions(400,30)
    end)

    SandE.emoteComboBox2.m_dropdown:SetHandler("OnHide", function(self)
        o_emoteComboBox2:SetDimensions(150,30)
    end)

    SandE.copyComboBox.m_dropdown:SetHandler("OnShow", function(self)
        o_copyComboBox:SetDimensions(400,30)
    end)

    SandE.copyComboBox.m_dropdown:SetHandler("OnHide", function(self)
        o_copyComboBox:SetDimensions(200,30)
    end)

    function OutfitConfigCallback(comboBox, itemName, item, selectionChanged)
        SandEWindowSaveButton:SetHidden(true)
        SandEWindowLoadButton:SetHidden(true)
        SandEWindowDeleteButton:SetHidden(true)
        SandEWindowRenameEditBoxBackdrop:SetHidden(true)

        SandE.comboBox2:ClearItems()
        SandE.currentIndex = -1
        SandE.currentSlot = nil

        if itemName == SandE.CURRENT then
            o_comboBox2:SetHidden(true)
            SandE.currentType = SandE.CURRENT
            SandE.currentSlot = SandE.currentCurrent
            SandE:UpdateUI()
            SandEWindowRandomButton:SetHidden(false)
            SandE:reloadEmoteComboBoxSel()
            SandE.o_outfitComboBox:SetHidden(false)
            SandE.o_emoteSelCombo:SetHidden(false)
            SandE.o_titleComboBox:SetHidden(false)
            SandE.o_stamCheck:SetHidden(false)
            SandE.o_speedCheck:SetHidden(false)
            SandE.o_inventoryCheck:SetHidden(false)
        else
            o_comboBox2:SetHidden(false)
            SandE.o_outfitComboBox:SetHidden(true)
            SandE.o_emoteSelCombo:SetHidden(true)
            SandE.o_titleComboBox:SetHidden(true)
            SandE.o_stamCheck:SetHidden(true)
            SandE.o_speedCheck:SetHidden(true)
            SandE.o_inventoryCheck:SetHidden(true)
            SandE.currentType = SandE.USER
            SandE.reloadComboBox2()
            SandEWindowRandomButton:SetHidden(true)
        end
    end

    function EmoteConfigCallback(comboBox, itemName, item, selectionChanged)
        SandEWindowEmotesContainerTimeBD:SetHidden(true)
        SandEWindowEmotesContainerSlashBD:SetHidden(true)
        SandEWindowEmotesContainerAddButton:SetHidden(true)
        SandEWindowEmotesContainerDeleteButton:SetHidden(true)
        SandEWindowEmotesContainerRenameBD:SetHidden(true)
        SandEWindowEmotesContainerActionDropdown:SetHidden(true)
        SandEWindowEmotesContainerCopyDropdown:SetHidden(true)

        SandEmoteList:ClearList()
        SandE.emoteComboBox2:ClearItems()
        SandE.currentEmoteIndex = -1

        if itemName == SandE.CURRENT then
            o_emoteComboBox2:SetHidden(true)
            SandE.currentEmoteType = SandE.CURRENT

            if SandE.sv.EmoteCurrent ~= -1 then
                SandEmoteList:NewTable(
                    SandE.sv.EmoteLists[SandE.sv.EmoteCurrent],
                    SandE.sv.EmoteListLengths[SandE.sv.EmoteCurrent]
                )
            end
            SandE:UpdateUI()
        else
            SandE.o_emoteRandomCheck:SetHidden(true)
            o_emoteComboBox2:SetHidden(false)
            SandE.currentEmoteType = SandE.USER
            SandE.reloadEmoteComboBox2()
        end
    end

    SandE:SetupActionCombo()
    SandE:SetupOutfitCombo()
    SandE:SetupTitleCombo()
    SandE:reloadComboBox2()
    SandE:reloadEmoteComboBox2()
    SandE:reloadEmoteComboBoxSel()

    SandE:CD()

    for _, name in ipairs(SandE.configTypes) do
        local itemEntry = SandE.mainComboBox:CreateItemEntry(name, OutfitConfigCallback)
        SandE.mainComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    for _, name in ipairs(SandE.configTypes) do
        local itemEntry = SandE.emoteComboBox:CreateItemEntry(name, EmoteConfigCallback)
        SandE.emoteComboBox:AddItem(itemEntry, ZO_COMBOBOX_SURPRESS_UPDATE)
    end

    SandE.mainComboBox:UpdateItems()
    SandE.mainComboBox:SelectFirstItem()

    SandE.emoteComboBox:UpdateItems()
    SandE.emoteComboBox:SelectFirstItem()

    -- Edit
    SandEWindowRenameEditBoxBackdropEditBox:SetHandler("OnEnter", function()
        SandE:RenameUser(SandEWindowRenameEditBoxBackdropEditBox:GetText())
        SandEWindowRenameEditBoxBackdropEditBox:Clear()
        SandEWindowRenameEditBoxBackdropEditBox:LoseFocus()
    end)

    SandEWindowRenameEditBoxBackdropEditBox:SetHandler("OnFocusGained", function()
        SandEWindowRenameEditBoxBackdropEditBox:Clear()
        SandEWindowRenameEditBoxBackdropEditBox:SetColor(1,1,1,1)
        SandEWindowRenameEditBoxBackdrop:SetEdgeColor(1,1,1,1)
        SandEWindowRenameEditBoxBackdrop:SetDimensions(300, 30)
    end)

    SandEWindowRenameEditBoxBackdropEditBox:SetHandler("OnFocusLost", function()
        SandEWindowRenameEditBoxBackdrop:SetEdgeColor(0,0,0,0)
        SandEWindowRenameEditBoxBackdropEditBox:SetText("Rename")
        SandEWindowRenameEditBoxBackdropEditBox:SetColor(.7,.7,.5,.5)
        SandEWindowRenameEditBoxBackdrop:SetDimensions(90, 30)
    end)

    SandEWindowRenameEditBoxBackdropEditBox:SetText("Rename")
    SandEWindowRenameEditBoxBackdropEditBox:SetColor(.7,.7,.5,.5)

    SandE:setTooltip(SandEWindowRenameEditBoxBackdropEditBox, "Press |c55ff55ENTER|r when done to save new name.")

    SandEWindowEmotesContainerRenameBDEditBox:SetHandler("OnEnter", function()
        SandE:RenameEmoteList(SandEWindowEmotesContainerRenameBDEditBox:GetText())
        SandEWindowEmotesContainerRenameBDEditBox:Clear()
        SandEWindowEmotesContainerRenameBDEditBox:LoseFocus()
    end)

    SandEWindowEmotesContainerRenameBDEditBox:SetHandler("OnFocusGained", function()
        SandEWindowEmotesContainerRenameBDEditBox:Clear()
        SandEWindowEmotesContainerRenameBDEditBox:SetColor(1,1,1,1)
        SandEWindowEmotesContainerRenameBD:SetEdgeColor(1,1,1,1)
        SandEWindowEmotesContainerRenameBD:SetDimensions(200, 30)
    end)

    SandEWindowEmotesContainerRenameBDEditBox:SetHandler("OnFocusLost", function()
        SandEWindowEmotesContainerRenameBD:SetEdgeColor(0,0,0,0)
        SandEWindowEmotesContainerRenameBDEditBox:SetText("Rename")
        SandEWindowEmotesContainerRenameBDEditBox:SetColor(.7,.7,.5,.5)
        SandEWindowEmotesContainerRenameBD:SetDimensions(90, 30)
    end)

    SandEWindowEmotesContainerRenameBDEditBox:SetText("Rename")
    SandEWindowEmotesContainerRenameBDEditBox:SetColor(.7,.7,.5,.5)

    SandE:setTooltip(SandEWindowEmotesContainerRenameBDEditBox, "Press |c55ff55ENTER|r when done to save new name.")


    -- Emote Edits
    SandEWindowEmotesContainerSlashBDEditBox:SetHandler("OnFocusGained", function()
        SandEWindowEmotesContainerSlashBD:SetEdgeColor(1,1,1,1)
        HideMouse(false)
    end)

    SandEWindowEmotesContainerSlashBDEditBox:SetHandler("OnFocusLost", function()
        SandEWindowEmotesContainerSlashBD:SetEdgeColor(0,0,0,0)
        ShowMouse(false)
    end)

    SandEWindowEmotesContainerSlashBDEditBox:SetHandler("OnTextChanged", function()
        local orig = SandEWindowEmotesContainerSlashBDEditBox:GetText()
        action = string.gsub(orig, "%s+", "")
        if orig ~= action then
            SandEWindowEmotesContainerSlashBDEditBox:SetText(action)
            return
        end

        if string.len(SandEWindowEmotesContainerSlashBDEditBox:GetText()) < 1 then
            SandEWindowEmotesContainerSlashBDLabel:SetHidden(false)
        else
            SandEWindowEmotesContainerSlashBDLabel:SetHidden(true)
        end
    end)

    SandEWindowEmotesContainerSlashBDEditBox:SetHandler("OnSpace", function()
        SandEWindowEmotesContainerTimeBDEditBox:TakeFocus()
    end)

    SandEmoteList.AutoComplete:New(SandEWindowEmotesContainerSlashBDEditBox, nil, nil, nil, 8, AUTO_COMPLETION_AUTOMATIC_MODE, AUTO_COMPLETION_DONT_USE_ARROWS)

    SandEWindowEmotesContainerTimeBDEditBox:SetHandler("OnEnter", function()
        SandE:AddToList()
    end)

    SandEWindowEmotesContainerTimeBDEditBox:SetHandler("OnFocusGained", function()
        SandEWindowEmotesContainerTimeBD:SetEdgeColor(1,1,1,1)
    end)

    SandEWindowEmotesContainerTimeBDEditBox:SetHandler("OnFocusLost", function()
        SandEWindowEmotesContainerTimeBD:SetEdgeColor(0,0,0,0)
    end)

    SandEWindowEmotesContainerTimeBDEditBox:SetHandler("OnTab", function()
        SandEWindowEmotesContainerSlashBDEditBox:TakeFocus()
    end)

    SandEWindowEmotesContainerTimeBDEditBox:SetHandler("OnSpace", function()
        SandEWindowEmotesContainerSlashBDEditBox:TakeFocus()
    end)

    SandEWindowEmotesContainerTimeBDEditBox:SetHandler("OnTextChanged", function()
        local orig = SandEWindowEmotesContainerTimeBDEditBox:GetText()
        time = string.gsub(orig, "%s+", "")
        if orig ~= time then
            SandEWindowEmotesContainerTimeBDEditBox:SetText(time)
            return
        end

        if string.len(SandEWindowEmotesContainerTimeBDEditBox:GetText()) < 1 then
            SandEWindowEmotesContainerTimeBDLabel:SetHidden(false)
        else
            SandEWindowEmotesContainerTimeBDLabel:SetHidden(true)
        end
    end)

    -- SandEWindowEmotesContainerSlashBDEditBox:SetDefaultText("/emote")
    -- SandEWindowEmotesContainerTimeBDEditBox:SetDefaultText("1000")

    SandE:setTooltip(SandEWindowEmotesContainerSlashBDEditBox, "TAB to complete a slash command you begin typing\nSpace to focus Time")
    SandE:setTooltip(SandEWindowEmotesContainerTimeBDEditBox, "Press |caaffaaENTER|r when done to add to list ( You also need /slashEmote filled in )\nTab or Space to focus Action")

    SandEWindowSaveButton:SetHandler("OnClicked", function() SandE:Save() end)
    SandE:setTooltip(SandEWindowSaveButton, "|c99ff99Save|r the current slot.")
    SandEWindowSaveButton:SetText("|c99ff99Save ")

    SandEWindowLoadButton:SetHandler("OnClicked", function() SandE:Load() end)
    SandE:setTooltip(SandEWindowLoadButton, "|c99ffffLoad|r the current slot.")
    SandEWindowLoadButton:SetText("|c99ffffLoad ")

    SandEWindowDeleteButton:SetHandler("OnClicked", function() SandE:Delete() end)
    SandE:setTooltip(SandEWindowDeleteButton, "|cff0033Delete|r the current slot.")
    SandEWindowDeleteButton:SetText("|cff0033Delete ")

    SandEWindowRandomButton:SetHandler("OnClicked", function() SandE:GetRandomAll() end)
    SandE:setTooltip(SandEWindowRandomButton, "|cff00ffRandom|r, if current Randomize what you are currently wearing, if slot set it to random.")
    SandEWindowRandomButton:SetText("|cff00ffRandom|r")

    SandEWindowEmotesContainerAddButton:SetHandler("OnClicked", function() SandE:AddToList() end)
    SandE:setTooltip(SandEWindowEmotesContainerAddButton, "|caaffaaAdd|r the emote with time entered.")
    SandEWindowEmotesContainerAddButton:SetText("|caaffaaAdd|r")

    SandEWindowEmotesContainerDeleteButton:SetHandler("OnClicked", function() SandE:DeleteList() end)
    SandE:setTooltip(SandEWindowEmotesContainerDeleteButton, "|cffaaaaDelete|r ALL of this emote list")
    SandEWindowEmotesContainerDeleteButton:SetText("|cffaaaaDelete|r")

    SandEWindowCloseButton:SetHandler("OnClicked", function() SandE:Close() end)
    SandE:setTooltip(SandEWindowCloseButton, "Close Window")

    for i, x in ipairs(SandE.COLLECTIBLES) do
        SandE.UIItems[x][3]:SetHandler("OnMouseDown", function(self, button, ctrl, alt, shift)
            if SandE.currentSlot == nil then
                d ( "You need to select a slot or current first." )
                return
            end

            if ( ctrl ) then
                SandE:GetRandom(x)
                if SandE.currentType ~= SandE.CURRENT then
                    SandE:UpdateUI()
                end
            elseif ( shift ) then
                id = SandE.currentCurrent[x]

                if SandE.currentType == SandE.CURRENT then
                    if i ~= COLLECTIBLE_CATEGORY_TYPE_MOUNT then
                        UseCollectible(id)
                    end
                else
                    SandE.currentSlot[x] = 0
                    SandE:UpdateUI()
                end
            else
                -- d("reg or alt")
            end
        end)

    end

    local function mountToggle(check, setting, ind)
        local val = 1
        if ZO_CheckButton_IsChecked(check) then val = 0 end

        if SandE.currentType == SandE.CURRENT then
            SetSetting(SETTING_TYPE_IN_WORLD, setting, val)
        else
            if SandE.currentIndex ~= -1 then
                SandE.sv.UserMountOptions[SandE.currentIndex][ind] = val
            end
        end
    end

    ZO_CheckButton_SetToggleFunction(SandE.o_stamCheck, function()
        mountToggle(SandE.o_stamCheck, IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE, 1)
    end)

    ZO_CheckButton_SetToggleFunction(SandE.o_speedCheck, function()
        mountToggle(SandE.o_speedCheck, IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE, 2)
    end)

    ZO_CheckButton_SetToggleFunction(SandE.o_inventoryCheck, function()
        mountToggle(SandE.o_inventoryCheck, IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE, 3)
    end)

    ZO_CheckButton_SetToggleFunction(SandE.o_emoteRandomCheck, function()
        local checked = ZO_CheckButton_IsChecked(SandE.o_emoteRandomCheck)

        if SandE.currentEmoteType == SandE.CURRENT then
            if SandE.sv.EmoteCurrent ~= -1 then
                SandE.sv.EmoteRandom[SandE.sv.EmoteCurrent] = checked
                SandEmoteList:SetPlayingList(
                    SandE.sv.EmoteLists[SandE.sv.EmoteCurrent],
                    SandE.sv.EmoteListLengths[SandE.sv.EmoteCurrent],
                    SandE.sv.EmoteRandom[SandE.sv.EmoteCurrent]
                )
            end
        else
            SandE.sv.EmoteRandom[SandE.currentEmoteIndex] = checked
            if SandE.sv.EmoteCurrent == SandE.currentEmoteIndex then
                SandEmoteList:SetPlayingList(
                    SandE.sv.EmoteLists[SandE.sv.EmoteCurrent],
                    SandE.sv.EmoteListLengths[SandE.sv.EmoteCurrent],
                    SandE.sv.EmoteRandom[SandE.sv.EmoteCurrent]
                )
            end
        end
    end)
end

function SandE:Initialize()
    ZO_CreateStringId("SI_CATEGORY_NAME_STYLE_AND_ELEGANCE", SandE.name)
    ZO_CreateStringId("SI_BINDING_NAME_SANDE_TOGGLE_UI", "Toggle UI")
    for i, x in ipairs(SandE.BINDING_NAMES) do
        ZO_CreateStringId(x, "NO OUTFIT MADE YET : " .. tostring(i))
    end

    for i=7756, #EsoStrings do
        if EsoStrings[i] == "NO OUTFIT MADE YET : 1" then
            SandE.bindingStartingIndex = i
        end
    end

    SandE.sv = ZO_SavedVars:New("SandE_sv", 1, nil, SandE.Defaults)

    SandEWindow:ClearAnchors()
    SandEWindow:SetAnchor(SandE.sv.ui.point, GuiRoot, SandE.sv.ui.relPoint, SandE.sv.ui.offsetX, SandE.sv.ui.offsetY)

    SandEWindow:SetHandler("OnMoveStop", function (self)
        local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
        if valid then
            SandE.sv.ui.point = point
            SandE.sv.ui.relPoint = relPoint
            SandE.sv.ui.offsetX = offsetX
            SandE.sv.ui.offsetY = offsetY
        end

        SandE:UpdateUI()
    end)

    SandE:CreateWindow()
    SandEWindowTitle:SetText(SandE.displayName)

    SandE:setTooltip(Outfit_UI_Button, "Open/Close " .. SandE.displayName .. " UI.")

    Outfit_UI_ButtonBg:ClearAnchors()
    Outfit_UI_ButtonBg:SetAnchor(SandE.sv.ui.buttonPoint, GuiRoot, SandE.sv.ui.buttonRelPoint, SandE.sv.ui.buttonX, SandE.sv.ui.buttonY)
    Outfit_UI_ButtonBg:SetHidden(not SandE.sv.ui.showIcon)
    Outfit_UI_ButtonBg:SetHandler("OnMoveStop", function (self)
        local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
        if valid then
            SandE.sv.ui.buttonX = offsetX
            SandE.sv.ui.buttonY = offsetY
            SandE.sv.ui.buttonRelPoint = relPoint
            SandE.sv.ui.buttonPoint = point
        end
    end)

    Outfit_UI_Button:SetHandler("OnClicked", function (self)
        toggleSandEUI()
    end)

    SandE.layerIndex, SandE.categoryIndex, SandE.actionIndex = GetActionIndicesFromName("SANDE_TOGGLE_UI")

    if SandE.layerIndex == nil or SandE.categoryIndex == nil or SandE.actionIndex == nil then
        Outfit_UI_ButtonLabel:SetText("")
    else
        keycode, _, _, _, _ = GetActionBindingInfo(SandE.layerIndex, SandE.categoryIndex, SandE.actionIndex)
        Outfit_UI_ButtonLabel:SetText(GetKeyName(keycode))
    end

    local hud_scenes = {
        "hud",
        "hudui"
    }

    local scenes = {
        COLLECTIONS_BOOK_SCENE,
        GAMEPAD_COLLECTIONS_BOOK_SCENE,
        ZO_OUTFIT_STYLES_BOOK_SCENE,
        GAMEPAD_OUTFITS_SELECTION_SCENE,
    }

    for i, scene in ipairs(scenes) do
        scene:RegisterCallback("StateChange", function(oldstate, newState)
            if SandE.sv.ui.autoShow then
                if(scene:IsShowing()) then
                    SandEWindow:SetHidden(false)
                else
                    SandEWindow:SetHidden(true)
                end
            end
        end)
    end

    for _, scene in ipairs(hud_scenes) do
        local sceneObj = SCENE_MANAGER:GetScene(scene)
        sceneObj:RegisterCallback("StateChange", function(oldState, newState)
            -- d ( scene .. " :: " .. tostring(oldState) .. " -> " .. tostring(newState) )
            SandEmoteList:SetBusy( not ( newState and ( newState == "showing" or newState == "shown" ) ) )
        end)
    end

    createSettings()
end

function SandE:UpdateEmoteUI()
    local emoteChecked = false

    if SandE.currentEmoteType == SandE.CURRENT then
        if SandE.sv.EmoteCurrent ~= -1 then
            emoteChecked = SandE.sv.EmoteRandom[SandE.sv.EmoteCurrent] or false
            SandE.o_emoteRandomCheck:SetHidden(false)
        else
            SandE.o_emoteRandomCheck:SetHidden(true)
        end
    else
        emoteChecked = SandE.sv.EmoteRandom[SandE.currentEmoteIndex] or false
        SandE.o_emoteRandomCheck:SetHidden(false)
    end

    ZO_CheckButton_SetCheckState(SandE.o_emoteRandomCheck, emoteChecked)
end

function SandE:UpdateUI()
    if SandE.currentSlot then
        for i, id in pairs(SandE.currentSlot) do
            if id ~= 0 then
                local name, desc, icon, _, unlocked, _, isActive, catType, hint, isPlaceholder = GetCollectibleInfo(id)
                local link = GetCollectibleLink(id, LINK_STYLE_BRACKETS)

                SandE.UIItems[i][1]:SetTexture(icon)
                if link then
                    SandE.UIItems[i][3]:SetHandler("OnMouseEnter", function (self)
                        self.itemtool = ItemTooltip
                        InitializeTooltip(self.itemtool, SandE.UIItems[i][3], TOPLEFT, 0, 0, BOTTOMRIGHT)
                        self.itemtool:SetLink(link)
                    end)

                    SandE.UIItems[i][3]:SetHandler("OnMouseExit", function (self)
                        if self.itemtool then
                            ClearTooltip(self.itemtool)
                        end
                    end)
                end
            else
                SandE.UIItems[i][1]:SetTexture("EsoUI/Art/ActionBar/abilityInset.dds")
                SandE.UIItems[i][3]:SetHandler("OnMouseEnter", function (self)
                    self.itemtool = InformationTooltip
                    InitializeTooltip(self.itemtool, SandE.UIItems[i][3], TOPLEFT, 0, 0, BOTTOMRIGHT)
                    SetTooltipText(self.itemtool, SandE.COLLECTIBLE_STRINGS[i])
                end)

                SandE.UIItems[i][3]:SetHandler("OnMouseExit", function (self)
                    if self.itemtool then
                        ClearTooltip(self.itemtool)
                    end
                end)
            end
        end
    end

    local index = 0
    local titleString = SandE.NO_TITLE
    local mount = {}

    if SandE.currentType == SandE.CURRENT then
        index = GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
        titleString = SandE:GetTitle(GetCurrentTitleIndex() or 0)
        mount[1] = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE)
        mount[2] = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE)
        mount[3] = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE)
    else
        index = SandE.sv.UserOutfit[SandE.currentIndex]

        -- backwards compat
        if SandE.sv.UserTitleString[SandE.currentIndex] == nil then
            if SandE.sv.UserTitle[SandE.currentIndex] ~= nil then
                SandE.sv.UserTitleString[SandE.currentIndex] = SandE:GetTitle(SandE.sv.UserTitle[SandE.currentIndex])
            else
                SandE.sv.UserTitleString[SandE.currentIndex] = SandE.NO_TITLE
            end
        end

        if SandE.sv.UserEmoteIndex[SandE.currentIndex] == nil then
            SandE.sv.UserEmoteIndex[SandE.currentIndex] = -1
        end

        local emoteIndex = SandE.sv.UserEmoteIndex[SandE.currentIndex]
        if emoteIndex ~= -1 then
            SandE.emoteSelCombo:SetSelectedItem(SandE:getEntryName(emoteIndex, SandE.sv.EmoteMap[emoteIndex]))
        end

        titleString = SandE.sv.UserTitleString[SandE.currentIndex]

        if SandE.sv.UserMountOptions[SandE.currentIndex] == nil then
            SandE.sv.UserMountOptions[SandE.currentIndex] = {
                GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE),
                GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE),
                GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE)
            }
        end

        mount[1] = SandE.sv.UserMountOptions[SandE.currentIndex][1]
        mount[2] = SandE.sv.UserMountOptions[SandE.currentIndex][2]
        mount[3] = SandE.sv.UserMountOptions[SandE.currentIndex][3]
    end

    SandE.outfitComboBox:SetSelectedItem(SandE:getEntryName(index, SandE:GetOutfitName(index)))
    SandE.titleComboBox:SetSelectedItem(titleString)

    if mount[1] == "0" then mount[1] = true else mount[1] = false end
    if mount[2] == "0" then mount[2] = true else mount[2] = false end
    if mount[3] == "0" then mount[3] = true else mount[3] = false end

    ZO_CheckButton_SetCheckState(SandE.o_stamCheck, mount[1])
    ZO_CheckButton_SetCheckState(SandE.o_speedCheck, mount[2])
    ZO_CheckButton_SetCheckState(SandE.o_inventoryCheck, mount[3])

    Outfit_UI_Button:SetHidden(not SandE.sv.ui.showIcon)
    Outfit_UI_ButtonLabel:SetHidden(not SandE.sv.ui.showIcon)

    SandE:UpdateEmoteUI()
end

function SandE:CD()
    SandE.currentCurrent = {}

    for _, i in ipairs(SandE.COLLECTIBLES) do
        SandE.currentCurrent[i] = GetActiveCollectibleByType(i)
    end
end

function SandE:MakeEmoteList()
    SandEmoteList:New(SandEmoteScrollList)
    SandEmoteList:GetAllPlayableEmotes()
end

EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_COLLECTIBLE_UPDATED, function(eventCode, id, justUnlocked) -- {{{
    if SandE.disableUpdates then return end

    local catType = GetCollectibleCategoryType(id)
    for _, x in ipairs(SandE.COLLECTIBLES) do
        if x == catType then
            SandE:CD()

            if SandE.currentType == SandE.CURRENT then
                SandE.currentSlot = SandE.currentCurrent
                SandE:UpdateUI()
            end

            return
        end
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_ADD_ON_LOADED, function (event, addonName) -- {{{
    if addonName ~= SandE.name then return end
    SandE:Initialize()
end) -- }}}

EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_PLAYER_ACTIVATED, function(eventCode, initial) -- {{{
    SandE:CD()

    math.randomseed(os.time())

    if SandE.sv.EmoteCurrent ~= -1 then
        zo_callLater(function()
            SandEmoteList:SetPlayingList(
                SandE.sv.EmoteLists[SandE.sv.EmoteCurrent],
                SandE.sv.EmoteListLengths[SandE.sv.EmoteCurrent],
                SandE.sv.EmoteRandom[SandE.sv.EmoteCurrent]
            )
            SandEmoteList:Start()
        end, 1500)
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_OUTFIT_RENAME_RESPONSE, function(eventCode, response, outfitIndex) -- {{{
    if response == SET_OUTFIT_NAME_RESULT_SUCCESS then
        SandE:SetupOutfitCombo()
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_OUTFIT_EQUIP_RESPONSE, function(eventCode, response) -- {{{
    if response == EQUIP_OUTFIT_RESULT_SUCCESS then
        if ( SandE.currentType == SandE.CURRENT ) then
            SandE:SetupOutfitCombo()
        end
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_KEYBINDING_SET, function(eventCode, layerIndex, categoryIndex, actionIndex, bindingIndex, keyCode) -- {{{
    if layerIndex == nil or categoryIndex == nil or actionIndex == nil then
        Outfit_UI_ButtonLabel:SetText("")
    elseif layerIndex == SandE.layerIndex and categoryIndex == SandE.categoryIndex and actionIndex == SandE.actionIndex then
        Outfit_UI_ButtonLabel:SetText(GetKeyName(keyCode))
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_PLAYER_TITLES_UPDATE, function(eventCode) -- {{{
    SandE:SetupTitleCombo()
end) -- }}}

-- EVENT_MANAGER:RegisterForEvent(SandE.name, EVENT_PLAYER_EMOTE_FAILED_PLAY, function(eventCode, failure) -- {{{
    -- SandEmoteList:EmoteFailed(eventCode, failure)
-- end) -- }}}
