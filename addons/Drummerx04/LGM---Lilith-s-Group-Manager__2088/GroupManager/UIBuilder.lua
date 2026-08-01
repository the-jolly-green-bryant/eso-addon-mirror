local LGM = LGM or {}

local function parseInviteString(input)
   local wordTable = {}
   local count = 0
   for match in input:gmatch("([^\1-\42\44-\47\58-\64\91-\96]+)") do
      wordTable[LGM.HandlePlus(match)] = true
      count = count + 1
   end
   if count == 0 then return "" end
   return count == 1 and next(wordTable) or wordTable
end

--Generate invite string fields for guilds
local function CreateGuildInviteBox(ui, AnchorTo, index)
   local function SetChatFilters(val)
      p = parseInviteString(val)
      LGM.ChatFilter[_G["CHAT_CHANNEL_GUILD_" .. index]] = p
      LGM.ChatFilter[_G["CHAT_CHANNEL_OFFICER_" .. index]] = p
      return val
   end

   local Key = string.format("Guild%d",index)
   local guildId = GetGuildId(index)
   local guildName = GetGuildName(guildId)
   local guildSV = LGM.SV.inviteString.guild

   ui[Key] = LAMCreateControl.editbox(ui, {
        type = "editbox",
        name = guildName,
        tooltip = string.format("Set the invite string for \"%s\" messages.", guildName),
        getFunc = function()
           if not guildSV[guildId] then guildSV[guildId] = guildSV[index] or ""; guildSV[index] = nil end -- migrate from index to id
           local val = guildSV[guildId]
           SetChatFilters(string.lower(val))
           return val
        end,
        setFunc = function(val)
           val = SetChatFilters(string.lower(val))
           guildSV[guildId] = val
        end,
   })
--   ui[Key].container:SetWidth(140)
   ui[Key]:SetAnchor(TOPRIGHT, AnchorTo, BOTTOMRIGHT, 0, 5)
   ui[Key]:SetParent(ui.ChatAnchor)
   return ui[Key]
end

------------------------------------------------------------------------------------------------------------------------
-- Generate String Invite Boxes
------------------------------------------------------------------------------------------------------------------------
local function CreateInviteBoxes(ui, AnchorTo, chatChannel)
   local function SetChatFilters(val)
      p = parseInviteString(val)
      LGM.ChatFilter[CHAT_CHANNEL_ZONE] = p
      LGM.ChatFilter[CHAT_CHANNEL_YELL] = p
      LGM.ChatFilter[CHAT_CHANNEL_SAY] = p
      return val
   end
   ui.Zone = LAMCreateControl.editbox(ui, {
        type = "editbox",
        name = "Zone",
        tooltip = "Set the invite string for \"Zone\" messages.",
        getFunc = function()
           local val = LGM.SV.inviteString.Zone
           return SetChatFilters(val)
        end,
        setFunc = function(val)
           val = SetChatFilters(string.lower(val))
           LGM.SV.inviteString.Zone = val
        end,
   })
--   ui[Key].container:SetWidth(140)
   ui.Zone:SetAnchor(TOPRIGHT, AnchorTo, BOTTOMRIGHT, 0, 5)
   ui.Zone:SetParent(ui.ChatAnchor)

   ui.Whisper = LAMCreateControl.editbox(ui, {
        type = "editbox",
        name = "Whisper",
        tooltip = "Set the invite string for \"Whisper\" messages.",
        getFunc = function()
              local val = LGM.SV.inviteString.Whisper
              LGM.ChatFilter[CHAT_CHANNEL_WHISPER] = parseInviteString(val)
              return val
           end,
        setFunc = function(val)
              val = string.lower(val)
              LGM.ChatFilter [CHAT_CHANNEL_WHISPER] = parseInviteString(val)
              LGM.SV.inviteString.Whisper = val
           end,
   })
   ui.Whisper:SetAnchor(TOPRIGHT, ui.Zone, BOTTOMRIGHT, 0, 5)
   ui.Whisper:SetParent(ui.ChatAnchor)
   return ui.Whisper

end

function LGM:InitKeybindStrip()
    self.keybindStripDescriptor =
    {
        -- Ready Check
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            name = GetString(SI_GROUP_LIST_READY_CHECK_BIND),
            keybind = "UI_SHORTCUT_TERTIARY",

            callback = ZO_SendReadyCheck,

            visible = function()
               return IsUnitGrouped('player')
            end
        },

        -- Leave Group
        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,

            name = GetString(SI_GROUP_LEAVE),
            keybind = "UI_SHORTCUT_NEGATIVE",

            callback = function()
                ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
            end,

            visible = function()
               return IsUnitGrouped('player')
            end
        },
    }
end

function LGM:CreateOptions()
   local fragment = ZO_SimpleSceneFragment:New(GroupManagerPanel)

   self:InitKeybindStrip()
   fragment:RegisterCallback("StateChange",  function(oldState, newState)
                                           if(newState == SCENE_SHOWING) then
                                              KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
                                           elseif(newState == SCENE_HIDDEN) then
                                              KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
                                           end
   end)

   GROUP_MENU_KEYBOARD:AddCategory({
         name = "L.G.M.",--"Lilith's Group Manager",
         categoryFragment = fragment,
         normalIcon = "esoui/art/journal/journal_tabicon_achievements_up.dds",
         --normalIcon = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",
         pressedIcon = "esoui/art/journal/journal_tabicon_achievements_down.dds",
         mouseoverIcon = "esoui/art/journal/journal_tabicon_achievements_over.dds",
         priority = 1000,
   })
   if LGM.SV.autoSelectLGM then
      GROUP_MENU_KEYBOARD.navigationTree:SelectNode(GROUP_MENU_KEYBOARD.categoryFragmentToNodeLookup[fragment])
   end
   ------------------------------------------------------------------------------------------------------------------------
   -- Invite Panel Options
   ------------------------------------------------------------------------------------------------------------------------
   local ui = {}

   LGM.iSettings = ui

   ui.main = GroupManagerPanelInviteWindow
   ui.scroll = ui.main -- For using LAM controls
   ui.main:SetAnchor(TOPRIGHT, GroupManagerPanel, TOPRIGHT, -30, 0)

   ui.main:SetWidth(340)
   ui.panel = ui.main
   ui.panel.data = {}

   ui.enable = LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = "Chat Scanning",
        tooltip = "Choose whether or not the addon will scan for the invite strings.",
        getFunc = function()
           return LGM.SV.Enabled
        end,
        setFunc = function(val)
           LGM.SetChatScan(val)
           LGM.SV.Enabled = val
        end,
    })

    ui.enable:SetAnchor(TOPRIGHT, ui.main, TOPRIGHT, 0, 100)
    ui.ChatAnchor = ui.enable

    local AnchorTo = ui.enable

    -- for _,v in ipairs({"Zone", "Whisper"}) do
    AnchorTo = CreateInviteBoxes(ui, AnchorTo)
    --end

    for i = 1,5 do
       AnchorTo = CreateGuildInviteBox(ui, AnchorTo, i)
    end

    ui.suggestions =  LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = "Allow Suggestions",
        tooltip = "Allow group members and whispers to suggest people to invite",
        getFunc = function()
           local val = LGM.SV.allowSuggestions
              LGM.inviteList:SuggestionRegistrationHandler(val)
              return val
           end,
        setFunc = function(val)
           LGM.inviteList:SuggestionRegistrationHandler(val)
              LGM.SV.allowSuggestions = val
           end,
   })
    ui.suggestions:SetAnchor(TOPRIGHT, AnchorTo, BOTTOMRIGHT, 0, 20)

    ui.offlines = LAMCreateControl.slider(ui, {
        type = "slider",
        name = "Offline Kick Timer",
        tooltip = "Kick offlines after X seconds. Choose 0 to disable this feature.",
        min = 0,
        max = 120,
        step = 5,
        getFunc = LGM.inviteList:KickTimeGetFunc(),
        setFunc = LGM.inviteList:KickTimeSetFunc(),
        default = 0,
    })
    ui.offlines:SetAnchor(TOPRIGHT, ui.suggestions, BOTTOMRIGHT, 0, 20)


    ui.max = LAMCreateControl.slider(ui, {
        type = "slider",
        name = "Max Group Size",
        tooltip = "Set the maximum group size. Once the group reaches the set value, ALL new attempted invites will be dropped, but pending invites can still run over the max. You can force an additional invite from the context menu in the Invite List",
        min = 2,
        max = 24,
        getFunc = function() return LGM.SV.maxSize end,
        setFunc = function(val) LGM.SV.maxSize = val end,
        default = 24,
    })
    ui.max:SetAnchor(TOPRIGHT, ui.offlines, BOTTOMRIGHT, 0, 20)

    ui.altkick =  LAMCreateControl.checkbox(ui, {
        type = "checkbox",
        name = "Auto Alt Kick",
        tooltip = "Automatically kick offline alt characters",
        getFunc = function()
              return LGM.SV.autoAltKick
           end,
        setFunc = function(val)
           LGM.SV.autoAltKick = val
           LGM.inviteList:RefreshGroupList()
           end,
   })
    ui.altkick:SetAnchor(TOPRIGHT, ui.max, BOTTOMRIGHT, 0, 20)



    ------------------------------------------------------------------------------------------------------------------------
    -- Raid Panel Options
    ------------------------------------------------------------------------------------------------------------------------



    local rp = {}
    testrp = rp
    rp.main = GroupManagerPanelRaidGroupWindow
    rp.scroll = rp.main -- For using LAM controls
    rp.main:SetAnchor(TOPLEFT, GroupManagerPanelRaidGroupWindowList, TOPRIGHT, 0, 0)

    rp.main:SetWidth(340)
    rp.panel = rp.main
    rp.panel.data = {}

    local addMemberBox
    rp.addMembers = LAMCreateControl.editbox(rp, {
                                                   type = "editbox",
                                                   name = "Add Members",
                                                   tooltip = "Add listed @names to the current Raid Group",
                                                   getFunc = function()
                                                      return ""
                                                   end,
                                                   setFunc = function(val)
                                                      -- May contain a single [.-'_]
                                                      for atName in val:gmatch('(@[^\1-\38\40-\44\47\58-\64\91-\94\96\123-\127]+)') do
                                                         LGM.raidList:AddRaidMember(atName, LGM.SV.inviteGroup)
                                                      end
                                                      addMemberBox:SetText("")
                                                   end,
    })
    addMemberBox = rp.addMembers.editbox
    rp.addMembers:SetAnchor(TOPRIGHT, rp.main, TOPRIGHT, -20, 5)
    rp.addMembers:SetParent(rp.main)
    rp.addMembers.editbox:SetWidth(150)
    rp.addMembers.bg:ClearAnchors()
    rp.addMembers.bg:SetAnchor(TOPRIGHT, rp.addMembers.editbox, TOPRIGHT, 0, 0)
    rp.addMembers.bg:SetAnchor(BOTTOMLEFT, rp.addMembers.editbox, BOTTOMLEFT, 0, 0)

    rp.addMembers.editbox:ClearAnchors()
    rp.addMembers.editbox:SetAnchor(TOPRIGHT, rp.addMembers, TOPRIGHT, 0, 0)


    rp.groupname = LAMCreateControl.editbox(rp, {
        type = "editbox",
        name = "Group Name",
        tooltip = "Set name for the current Raid Group.",
        getFunc = function()
              return LGM.SV.inviteGroup
           end,
        setFunc = function(val)
           if val ~= LGM.SV.inviteGroup and LGM.SV.Groups[val] == nil then
              LGM.SV.Groups[val] = LGM.SV.Groups[LGM.SV.inviteGroup]
              LGM.SV.Groups[LGM.SV.inviteGroup] = nil
              LGM.SV.inviteGroup = val
              LGM.raidList.label:SetText(val)
              LGM:UpdateRaidChoices()
           end
           end,
    })
    rp.groupname:SetAnchor(TOPRIGHT, rp.addMembers, BOTTOMRIGHT, 0, 20)
    rp.groupname:SetParent(rp.main)
    rp.groupname.editbox:SetWidth(150)
    rp.groupname.bg:ClearAnchors()
    rp.groupname.bg:SetAnchor(TOPRIGHT, rp.groupname.editbox, TOPRIGHT, 0, 0)
    rp.groupname.bg:SetAnchor(BOTTOMLEFT, rp.groupname.editbox, BOTTOMLEFT, 0, 0)

    rp.groupname.editbox:ClearAnchors()
    rp.groupname.editbox:SetAnchor(TOPRIGHT, rp.groupname, TOPRIGHT, 0, 0)


    rp.selector = LAMCreateControl.dropdown(rp.main, {
                                               type = "dropdown",
                                               name = "Raid Selector", -- or string id or function returning a string
                                               choices = {},
                                               getFunc = function() return LGM.SV.inviteGroup end,
                                               setFunc = function(val)
                                                  if val ~= LGM.SV.inviteGroup then
                                                     LGM.SV.inviteGroup = val
                                                     LGM.raidList:LoadRaidInviteGroup(LGM.SV.Groups[val])
                                                     rp.groupname.editbox:SetText(val)
                                                  end
                                               end,
                                               tooltip = "Select the active Raid Group", -- or string id or function returning a string (optional)
                                               sort = "name-up", --or "name-down", "numeric-up", "numeric-down" (optional) - if not provided, list will not be sorted
                                               width = "full", --or "half" (optional)
    })


    LGM.selector = rp.selector
    rp.selector:SetAnchor(TOPRIGHT, rp.groupname, BOTTOMRIGHT, 0, 20)
    rp.selector:SetParent(rp.main)
    rp.selector.combobox:SetWidth(150)
    rp.selector.combobox:ClearAnchors()
    rp.selector.combobox:SetAnchor(TOPRIGHT, rp.selector, TOPRIGHT, 0, 0)

    function LGM:UpdateRaidChoices()
       local selector = self.selector
       local choices = {}

       for k in pairs(LGM.SV.Groups) do
          table.insert(choices, k)
       end

       selector:UpdateChoices(choices)
       -- selector:UpdateValue(false, LGM.SV.inviteGroup)
    end

    function LGM:UpdateRaidModifiers(val)
       self:UpdateRaidChoices()
       rp.groupname.editbox:SetText(val)
       LGM.raidList:LoadRaidInviteGroup(LGM.SV.Groups[val])
    end
    -- rp.groupname.editbox:SetWidth(150)
    -- rp.groupname.editbox:ClearAnchors()
    -- rp.groupname.editbox:SetAnchor(TOPRIGHT, rp.groupname, TOPRIGHT, 0, 0)

    ------------------------------------------------------------------------------------------------------------------------
    -- Menu Bar Setup
    ------------------------------------------------------------------------------------------------------------------------
    local function MenuSelector(data)
       GroupManagerPanelInviteWindow:SetHidden(data.descriptor ~= "LGMMenuBarButton1")
       GroupManagerPanelRaidGroupWindow:SetHidden(data.descriptor ~= "LGMMenuBarButton2")
       GroupManagerPanelDeathWindow:SetHidden(data.descriptor ~= "LGMMenuBarButton3")
       LGMMenuBarLabel:SetText( data.label )
       LGM.SV.panelSelection = data.descriptor
    end
    ZO_MenuBar_AddButton(LGMMenuBar, {
                            descriptor = "LGMMenuBarButton1",
                            normal = "esoui/art/campaign/overview_indexicon_emperor_up.dds",
                            pressed = "esoui/art/campaign/overview_indexicon_emperor_down.dds",
                            --disabled = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",
                            highlight = "esoui/art/campaign/overview_indexicon_emperor_over.dds",
                            label = "Invite Panel",
                            callback = MenuSelector,
                            --         statusIcon = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",

    })
    ZO_MenuBar_AddButton(LGMMenuBar, {
                            descriptor = "LGMMenuBarButton2",
                            normal = "esoui/art/contacts/tabicon_friends_up.dds",
                            pressed = "esoui/art/contacts/tabicon_friends_down.dds",
                            --disabled = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",
                            highlight = "esoui/art/contacts/tabicon_friends_over.dds",
                            label = "Raid Panel",
                            callback = MenuSelector,
                            --         statusIcon = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",
    })
    ZO_MenuBar_AddButton(LGMMenuBar, {
                            descriptor = "LGMMenuBarButton3",
                            normal = "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
                            pressed = "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_down.dds",
                            --disabled = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",
                            highlight = "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_over.dds",
                            label = "Death Panel",
                            callback = MenuSelector,
                            --         statusIcon = "EsoUI/Art/Icons/guildranks/guild_indexicon_leader_up.dds",
    })

    ZO_MenuBar_SelectDescriptor(LGMMenuBar, LGM.SV.panelSelection)
end


--]]--
