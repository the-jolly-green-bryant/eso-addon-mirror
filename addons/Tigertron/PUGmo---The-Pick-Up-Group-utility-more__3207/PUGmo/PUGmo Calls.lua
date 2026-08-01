if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM
-------------------------------------------------------------------------
--- HotKey routine -- PUGmo GO!
-------------------------------------------------------------------------
function PUGmoGO()
    PUG.data.hide = not PUG.data.hide
    if PUG.data.hide then
        --SetGameCameraUIMode(false)
        PUGmoWindowZone:SetHidden(true)
        PUGmoWindowGroup:SetHidden(true)
        EM:UnregisterForUpdate(PUG.data.grouplistCB)
        return
    else
        SetGameCameraUIMode(true)
        if IsUnitInDungeon("player") and GetGroupSize() > 0 then
            PUGmoWindowZone:SetHidden(true)
            PUGmoWindowGroup:SetHidden(false)
            EM:RegisterForUpdate(PUG.data.grouplistCB, 250, function(...)
                PUG:updateGroupBuffer()
            end)
        else
            PUGmoWindowZone:SetHidden(false)
            PUGmoWindowGroup:SetHidden(true)
            EM:UnregisterForUpdate(PUG.data.grouplistCB)
        end
    end
end
-------------------------------------------------------------------------

--[[
CHAT_CHANNEL_SAY = 0
CHAT_CHANNEL_YELL = 1
CHAT_CHANNEL_WHISPER = 2
CHAT_CHANNEL_PARTY = 3
CHAT_CHANNEL_WHISPER_SENT = 4
CHAT_CHANNEL_EMOTE = 6
CHAT_CHANNEL_GUILD_1 = 12
CHAT_CHANNEL_GUILD_2 = 13
CHAT_CHANNEL_GUILD_3 = 14
CHAT_CHANNEL_GUILD_4 = 15
CHAT_CHANNEL_GUILD_5 = 16
CHAT_CHANNEL_OFFICER_1 = 17
CHAT_CHANNEL_OFFICER_2 = 18
CHAT_CHANNEL_OFFICER_3 = 19
CHAT_CHANNEL_OFFICER_4 = 20
CHAT_CHANNEL_OFFICER_5 = 21
CHAT_CHANNEL_USER_CHANNEL_1 = 22
CHAT_CHANNEL_USER_CHANNEL_2 = 23
CHAT_CHANNEL_USER_CHANNEL_3 = 24
CHAT_CHANNEL_USER_CHANNEL_4 = 25
CHAT_CHANNEL_USER_CHANNEL_5 = 26
CHAT_CHANNEL_USER_CHANNEL_6 = 27
CHAT_CHANNEL_USER_CHANNEL_7 = 28
CHAT_CHANNEL_USER_CHANNEL_8 = 29
CHAT_CHANNEL_USER_CHANNEL_9 = 30
CHAT_CHANNEL_ZONE = 31
CHAT_CHANNEL_ZONE_LANGUAGE_1 = 32
CHAT_CHANNEL_ZONE_LANGUAGE_2 = 33
CHAT_CHANNEL_ZONE_LANGUAGE_3 = 34
CHAT_CHANNEL_ZONE_LANGUAGE_4 = 35
CHAT_CHANNEL_ZONE_LANGUAGE_5 = 36
--]]
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Main Trigger - EVENT_CHAT_MESSAGE_CHANNEL (number eventCode, MsgChannelType channelType, string fromName, string text, boolean isCustomerService, string fromDisplayName) ---
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PUG:onChat(channel, fromName, msg, isCustomerService, name)
    --PUG:debug("onChat channel " .. channel)
    --- check for echo of myLootList
    if msg == PUG.myLootList[1] then
        --- cancel the pause
        PUG.alertBox.pause = false
        PUG.alertBox.delay = 0
        table.remove(PUG.myLootList, 1)
        if #PUG.myLootList > 0 then
            if channel == CHAT_CHANNEL_WHISPER_SENT then
                --PUG:markPlayer(name)
                channel = CHAT_CHANNEL_WHISPER
            end
            PUG:msgToChat(PUG.myLootList[1], channel)
        end
    end

    --- Filter out own messages from here including above echo check
    if name == PUG.data.me then
        return
    end

    if channel == CHAT_CHANNEL_SAY then
        PUG:sayHandler(0, fromName, msg, isCustomerService, name)
        return
    elseif channel == CHAT_CHANNEL_WHISPER then
        PUG:whisperHandler(channel, fromName, msg, isCustomerService, name)
        return
    elseif channel == CHAT_CHANNEL_PARTY then
        PUG:groupHandler(0, fromName, msg, isCustomerService, name)
        return
    elseif channel == CHAT_CHANNEL_ZONE then
        PUG:zoneHandler(0, fromName, msg, isCustomerService, name)
        return
    elseif channel >= CHAT_CHANNEL_GUILD_1 and channel <= CHAT_CHANNEL_OFFICER_5 then
        PUG:guildHandler(channel, fromName, msg, isCustomerService, name)
        return
    end
end

-------------------------------------------------------------------------
function PUG:onCapsLock()
    ---SetEdgeTexture(string filename, number edgeFileWidth, number edgeFileHeight, number edgeSize, number edgeFilePadding)
    ---SetEdgeColor(number r, number g, number b, number a)
    if IsCapsLockOn() then
        CHAT_SYSTEM.textEntry.editBg:SetEdgeColor(1, 0, 0, 1)
        CHAT_SYSTEM.textEntry.editBg:SetCenterColor(1, 0, 0, 1)
    else
        CHAT_SYSTEM.textEntry.editBg:SetEdgeColor(1, 1, 1, 1)
        CHAT_SYSTEM.textEntry.editBg:SetCenterColor(1, 1, 1, 1)
    end
end

--- EVENT_GROUP_MEMBER_LEFT(characterName, reason, isLocalPlayer, isLeader, displayName)
-------------------------------------------------------------------------
function PUG:onUnitLeft(characterName, reason, isLocalPlayer, isLeader, displayName)
    --PUG:debug("*** Unit Left", characterName, reason, isLocalPlayer, isLeader, displayName, "Unit Left ***")
    --PUG:debug("* onLeft groupBuffer size: " .. #PUG.groupBuffer)

    --- we left the group so reset everything
    if isLocalPlayer then
        PUG.data.initGroupList = false
        PUG.groupBuffer = {}
        PUG:updateGroupList()
        return false
    end

    local tmp = {}
    for i = 1, #PUG.groupBuffer do
        if PUG.groupBuffer[i].name ~= displayName then
            table.insert(tmp, PUG.groupBuffer[i])
            --PUG:debug("* onleft adding back *: " .. PUG.groupBuffer[i].name)
        end
    end
    PUG.groupBuffer = tmp
    PUG:updateGroupList()
end

---EVENT_GROUP_MEMBER_CONNECTED_STATUS()
-------------------------------------------------------------------------
-- todo change Bg color of unit button to show off line
function PUG:onUnitDisconnected(unitTag, isOnline)
    --PUG:debug("*** Unit Dis/Connected")
    local name = GetUnitDisplayName(unitTag)
    local index = PUG:getIndex(name)
    if not index or index > 11 or index == 0 then
        --PUG:debug("disconnect index error: " .. (index or "NIL"))
        index = 13
    end
    --PUG:debug("Name: " .. name .. " unitTag: " .. unitTag .. " Index: " .. index .. " is online?", isOnline, "Unit Dis/Connected ***")
end

--- this fires a lot. I think its whenever a group member joins or leaves
--- and it fires for everyone again.
--- initial call on log in the unit tag is invalid
---EVENT_GROUP_MEMBER_ROLE_CHANGED(eventId, unitTag, newRole)
-------------------------------------------------------------------------
function PUG:onRoleChanged(unitTag, newRole)

    --PUG:debug("*** New Role: " .. PUG.role[newRole])

    if not unitTag or unitTag == "" then
        --PUG:debug("* new role unitTag error: " .. type(unitTag) .. " the tag:")
        --PUG:debug(unitTag)
        unitTag = "not set"
    end
    --PUG:debug("* new role unitTag: " .. unitTag)
    local name = GetUnitDisplayName(unitTag)
    --- the main call to keep the list up to date
    local index = PUG:getIndex(name)
    if not index or index > 11 or index == 0 then
        index = 13
        --PUG:debug("* role changed index error: " .. index)
        return
    end
    local role = PUG.role[newRole]
    PUG.groupBuffer[index].role = role
    --PUG:debug("New Role * Name: " .. name .. " unitTag: " .. unitTag .. " Index: " .. index .. " is a " .. role)
    --PUG:debug("New Role ***")
end
-------------------------------------------------------------------------
function PUG:updateTestButton(r, g, b, a)
    --PUG:debug(r, g, b, a)
    local l = PUGmoLAMTestButton.texture
    l:SetColor(r, g, b)
    l:SetAlpha(a)
end

-------------------------------------------------------------------------
function PUG:alertBoxConfirm()
    PUG.alertBox.pause = true
    PUG.alertBox.confirm = false
    PUGmoAlertBoxWindow:SetHidden(true)
end

-------------------------------------------------------------------------
function PUG:resetAll()
    PUG.alertBox.delay = 0
    PUG.alertBox.pause = true
    PUG.alertBox.confirm = false

    PUG:removeMarker()
    PUG.data.marked = {
        icon = nil,
        delay = 0,
        tag = "",
        name = "",
    }

    PUG.data.groupSets = {}

    PUG.myLootList = {}
    PUG.data.initGroupList = false
    PUG.groupBuffer = {}
    PUG.selected = {}
    PUG:initGroupList()

end

-------------------------------------------------------------------------
--EVENT_PLAYER_ACTIVATED()
function PUG:onPlayerActivated(f)
    --PUG:debug("*** onPlayer")
    --PUG:debug("* onPlayer groupBuffer: " .. #PUG.groupBuffer)

    --PUG:debug("Map Name: " .. GetMapInfoById(GetMapIdByZoneId(GetZoneId(GetCurrentMapZoneIndex()))))
    --PUG:debug("zoneIndex: " .. GetCurrentMapZoneIndex())

    if not IsUnitInDungeon("player") then
        --PUG:debug("left dungeon")
        if PUG.SV.setEncounterLog then
            SetEncounterLogEnabled(false)
            d("PUGmo turned OFF encounter log.")
        end
        PUG.data.dungeon = {
            last = PUG.data.dungeon.index,
            index = GetCurrentMapZoneIndex(),
            left = true,
            --time = os.time() + ((60 * 60) * 2)
        }
        -- todo if you go from one dungeon to another then this will be false
    elseif PUG.data.dungeon.left then
        --- we are in a new dungeon or it's a /reloadui
        if PUG.SV.setEncounterLog then
            SetEncounterLogEnabled(true)
            d("PUGmo turned ON encounter log")
        end
        PUG.data.groupSets = {}
        PUG.data.dungeon = {
            last = PUG.data.dungeon.index,
            index = GetCurrentMapZoneIndex(),
            left = false,
        }
        PUG.data.oldLoot = {}
        for slot = 1, GetBagSize(BAG_BACKPACK) do
            if GetItemBoPTimeRemainingSeconds(BAG_BACKPACK, slot) > 0 then
                table.insert(PUG.data.oldLoot, GetItemLink(BAG_BACKPACK, slot))
            end
        end
        if PUG.SV.groupChat then
            if GetGroupSize() > 0 then
                --- uses pChat to switch chat box to first group tab
                if PUG.data.isPChat then
                    local tabs = GetNumChatContainerTabs(1)
                    for i = 1, tabs do
                        if IsChatContainerTabCategoryEnabled(1, i, CHAT_CATEGORY_PARTY) then
                            --PUG:debug("pChat change tab: " .. i)
                            pChat_ChangeTab(i)
                            break
                        end
                    end
                end
                --- sets group channel active
                PUG:msgToChat("", CHAT_CHANNEL_PARTY)
            end
        end
        if PUG.SV.preCheck and GetGroupSize() > 0 then
            PUG:preCheck()
        end
    end
    --PUG:debug("*** onPlayer groupBuffer: " .. #PUG.groupBuffer)
    --PUG:debug("onPlayer ***")
end
-------------------------------------------------------------------------
--- The (self, data, and scrollListControl) are all supplied by the
--- internal callback trigger. What is contained in data is determined by
--- the structure of the table of data items you used to create it.
--- Called when a new row is added.
-------------------------------------------------------------------------
function PUG:layoutRowZone(data)
    local channel = data.channel

    self:GetNamedChild("UnitName"):SetText(data.name)
    self:GetNamedChild("UnitName"):SetHandler("OnMouseUp", function()
        PUG:msgToChat("", CHAT_CHANNEL_WHISPER, data.name)
    end)
    self:GetNamedChild("UnitName"):SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    -- todo shift click to send to guild chat
    if data.guild > 0 then
        local name = PUG.guildName[data.guild]
        name = PUG.guildColor[data.guild] .. name .. "|r"
        if isPChat then
            name = pChat.GetChannelColors(data.guild + 10) .. name .. "|r"
        end
        -- todo check
        self:GetNamedChild("UnitName"):SetHandler("OnMouseUp", function()
            PUG:msgToChat("", data.guild + 11)
        end)
        self:GetNamedChild("UnitName"):SetText(name)
        self:GetNamedChild("UnitName"):SetHandler("OnMouseEnter", function()
            ZO_Tooltips_ShowTextTooltip(self, LEFT, data.name)
        end)

    else
        self:GetNamedChild("UnitName"):SetHandler("OnMouseEnter", function()
            ZO_Tooltips_ShowTextTooltip(self, LEFT, "Click to start whisper")
        end)
    end

    self:GetNamedChild("KeyWords"):SetText(data.keywords)

    --- be sure to set dimensions in XML to get a box to mouse over
    local tooltip = table.concat(data.msgs, "\n|t1150%:100%:EsoUI/Art/Miscellaneous/horizontalDivider.dds|t\n")
    self:GetNamedChild("UnitMsg"):SetText(data.msg)
    self:GetNamedChild("UnitMsg"):SetHandler("OnMouseEnter", function()
        ZO_Tooltips_ShowTextTooltip(self, LEFT, tooltip)
    end)

    self:GetNamedChild("UnitMsg"):SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

    self:GetNamedChild("BtnDel"):SetHandler("OnMouseUp", function()
        PUG:delListUnitRow(data.index)
    end)

    self:GetNamedChild("BtnDel"):SetHandler("OnMouseEnter", function()
        ZO_Tooltips_ShowTextTooltip(self, LEFT, "Delete this Log. Shift+Click to blacklist\nthe player until next reload\nType \"\\pugmo clear bl\" to clear the blacklist")
    end)

    self:GetNamedChild("BtnDel"):SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)

end

-------------------------------------------------------------------------
--TODO this needs to be incorporated above
-------------------------------------------------------------------------
function PUG:ToolTipHandler(type, target, msg)
    if type == 1 then
        if msg ~= "" and msg ~= nil then
            ZO_Tooltips_ShowTextTooltip(target, TOP, msg)
        end
    end
    if type == 0 then
        ZO_Tooltips_HideTextTooltip()
    end
end

-------------------------------------------------------------------------
--- called when row is shown
-------------------------------------------------------------------------
function PUG:layoutRowGroup(data, scrollList)
    self:GetNamedChild("UnitName"):SetText(data.name)
    self:GetNamedChild("Role"):SetText(data.role)

    self:GetNamedChild("UnitName"):SetHandler("OnMouseUp", function()

        --PUG:debug("clicked", data.name, PUG.data.marked.name, PUG.data.button)

        if data.name == PUG.data.marked.name and PUG.data.button then
            PUG.data.button:SetEdgeColor(0, 0, 0)
            --PUG:debug("clicked same name that was on already - edge off")
            PUG:markPlayer(data.name)
            PUG.data.button = nil
            return
        elseif PUG.data.button then
            PUG.data.button:SetEdgeColor(0, 0, 0)
            --PUG:debug("clicked different name and one was on already - edge off")
            PUG.data.button = nil
        end

        PUG.data.button = data.dataEntry.control

        PUG.data.button:SetEdgeColor(1, 0, 0)
        --PUG:debug("edge ON", PUG.data.button)

        if #PUG.msg > 1 then
            PUG.myLootList[1] = table.concat(PUG.msg, ", ")
            PUG.myLootList[1] = PUG.myLootList[1] .. " " .. PUG.SV.lootWhisperSuffix
            for i = 2, #PUG.selected do
                --PUG.seleccted[i]:SetAlpha(1)
                --- set index to 99 to indicate the item is selected
                PUG.selected[i].index = 99
            end
            PUG:msgToChat(PUG.myLootList[1], CHAT_CHANNEL_WHISPER, data.name)
            PUG.msg = {}
            PUG.selected = {}
        end
        PUG:markPlayer(data.name)

    end)
    --- this seeds the item count
    PUG.data.item = 1
end
-------------------------------------------------------------------------
--- called when row is shown
-------------------------------------------------------------------------
function PUG:layoutRowGroupItem(data, scrollList)
    if not data[PUG.data.item] then
        return
    end
    local button = self:GetNamedChild("ItemLink")
    local itemlink = string.gsub(data[PUG.data.item], "|H1:", "|H0:", 1)

    PUG.data.item = PUG.data.item + 1
    button:SetText(" " .. itemlink)
    button:SetHandler("OnMouseEnter", function()
        -- TODO handle left and right depending on where the list is on the screen
        InitializeTooltip(PUGmoTooltip, PUGmoWindowGroup, TOPRIGHT, -20, 0, TOPLEFT)
        PUGmoTooltip:SetLink(itemlink)
    end)

    button:SetHandler("OnMouseExit", function()
        PUGmoTooltip:ToggleHidden()
    end)

    button:SetHandler("OnMouseUp", function()

        if #PUG.selected == 0 then
            PUG.msg[1] = PUG.SV.lootWhisperPrefix .. " "
            PUG.selected[1] = "Place Holder"
        end

        local b = self:GetNamedChild("ItemLink")

        local a = b:GetAlpha()
        if a < 0.5 and b.index ~= 99 then
            b:SetAlpha(1)
            table.remove(PUG.selected, b.index)
            table.remove(PUG.msg, b.index)
            for i = 2, #PUG.selected do
                PUG.selected[i].index = i

            end
            if #PUG.msg == 1 then
                PUG.msg = {}
                PUG.selected = {}
            end
        else
            if b.index ~= 99 then
                if #PUG.selected == 4 then
                    PUG:addAlert("Message  Buffer limit reached\nPlease send and start another.")
                    return
                end
                b:SetAlpha(0.4)
                b.index = #PUG.selected + 1
                table.insert(PUG.selected, b)
                table.insert(PUG.msg, itemlink)

            end

        end
    end)

    button = self

    --- change the color by set name
    local next = #PUG.data.groupSets + 1
    if next > 5 then
        next = 5
    end
    local color = PUG.SV.itemColor[next]
    local _, set = GetItemLinkSetInfo(itemlink)
    --PUG:debug("set  " .. set)
    for i = 1, #PUG.data.groupSets do
        if PUG.data.groupSets[i] == set then
            next = i
            break
        end
    end
    color = PUG.SV.itemColor[next]
    PUG.data.groupSets[next] = set
    set = "|u5:5::" .. set .. " |u"
    button:SetEdgeColor(color.r, color.g, color.b, color.a)
    button = button:GetNamedChild("SetName")
    button:SetText(set)
    button = button:GetNamedChild("Bg")
    button:SetEdgeColor(color.r, color.g, color.b, color.a)
end

-------------------------------------------------------------------------
function PUG:onMoveStop(self, panel)

    PUG.SV[panel] = { left = self:GetLeft(), top = self:GetTop() }
end

-------------------------------------------------------------------------
function PUG:minimizeWTS()
    local width, height = PUGmoWindowZone:GetDimensions()
    if PUG.SV.minimized then
        PUG.SV.minimized = false
        PUGmoWindowZoneListLFG:SetDimensions(width, height / 2)
        PUGmoWindowZoneListWTS:SetDimensions(width, (height / 2) - 70)
        PUGmoWindowZoneMinimize:SetNormalTexture("/esoui/art/buttons/pointsminus_up.dds")
        PUGmoWindowZoneMinimize:SetMouseOverTexture("/esoui/art/buttons/pointsminus_over.dds")
        PUGmoWindowZoneMinimize:SetPressedTexture("/esoui/art/buttons/pointsminus_down.dds")

    else
        PUG.SV.minimized = true
        PUGmoWindowZoneListLFG:SetDimensions(width, height - 250)
        PUGmoWindowZoneListWTS:SetDimensions(width, 140)
        PUGmoWindowZoneMinimize:SetNormalTexture("/esoui/art/buttons/pointsplus_up.dds")
        PUGmoWindowZoneMinimize:SetMouseOverTexture("/esoui/art/buttons/pointsplus_over.dds")
        PUGmoWindowZoneMinimize:SetPressedTexture("/esoui/art/buttons/pointsplus_down.dds")

    end
end
