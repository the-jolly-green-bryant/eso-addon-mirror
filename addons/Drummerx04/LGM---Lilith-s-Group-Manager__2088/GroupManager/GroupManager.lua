local LGM = LGM or {}


function LGM.OnAddonLoaded(eventId, name)
   if name == LGM.name then
      -- ZO_CreateStringId("SI_BINDING_NAME_GroupManager_ToggleWindow", "Toggle Command History")
      EVENT_MANAGER:UnregisterForEvent(LGM.name, EVENT_ADD_ON_LOADED)

      local defaults = {
         Enabled = false,
         maxSize = 24,
         inviteString = {
            guild = {},
            Zone = "",
            Whisper = "",
         },
         Groups = {
            ["New Group"] = {}
         },
         inviteGroup = "New Group",
         recapLength = 10,
         kickTime = 0,
         autoAltKick = false,
         allowSuggestions = false,
         trackDeaths = true,
         panelSelection = "LGMMenuBarButton1",
         displayAbilityIds = false,
         autoSelectLGM = false,
         livePopupAnchorPoint = {25, 500},
         livePopupLength = 0,
         markTrialStart = true,
         muteInvites = true,
      }

      LGM.SV = ZO_SavedVars:NewAccountWide("GroupManager_Data", 1, nil, defaults, nil)

      -- List data population calls
      LGM.inviteList:RegisterHandlers()
      --LGM.inviteList:RefreshGroupList(true)
      LGM.deathList:RegisterEvents(LGM.SV.trackDeaths)

      LGM.raidList:LoadRaidInviteGroup(LGM.SV.Groups[LGM.SV.inviteGroup])
      LGM:CreateOptions()
      LGM:UpdateRaidChoices()

      LGM.SetChatScan(LGM.SV.Enabled)
      -- end


      -- Set Live Recap Popup Anchor Point
      LGM_LivePopupAnchor:ClearAnchors()
      LGM_LivePopupAnchor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT , unpack(LGM.SV.livePopupAnchorPoint))

      ----------------------------------------------------------------------------------------------------
      --Disable the Alert Text reply and sound in the upper right corner for all outgoing Invites
      --sent by this addon and others.

      if LGM.SV.muteInvites then
         EVENT_MANAGER:UnregisterForEvent("AlertTextManager", EVENT_GROUP_INVITE_RESPONSE)
      end
      -- Grab the function Handle for Inviting group members by name
      LGM.GroupInviteByName = GroupInviteByName
      function GroupInviteByName(name)
               return LGM.inviteList:InviteRaidMember(name)
      end
      ----------------------------------------------------------------------------------------------------
      local movable = true
      SLASH_COMMANDS["/lgm"] = function(extra)

         extra = extra:lower()
         if extra == "" then
            d("LGM help - /lgm arguments",
            "|u30:0::|us - Print the death recap to chat box",
            "|u30:0::|utrackdeaths - toggle LGM death tracking",
            "|u30:0::|uautoselect - toggle LGM as default group menu selection",
            "|u30:0::|urecap <integer> - changes the tracking length recaps",
            "|u30:0::|uliverecap <integer> - Rows for incombat death recap. 0 = off",
            "|u30:0::|udump - (developer) dump the damage queues into the death panel timeline for inspection",
            "|u30:0::|umarktrialstart - toggle the marking of the start of a trial in the death panel timeline",
            "|u30:0::|umuteinvites - toggle the muting of the in-game invite responses",
            "|u30:0::|utogglemove - toggles live recap window for custom placement")
         elseif extra == "s" then
            LGM_DeathPanel_ToggleButtonHandler(nil, 2)
         elseif extra == "dump" then
            LGM.deathList:DumpMapping()
         elseif extra == "altkick" then
            local setting = LGM.iSettings.altkick
            local Toggle = setting:GetHandler("OnMouseUp")
            Toggle(setting)

            -- LGM.SV.autoAltKick = not LGM.SV.autoAltKick
            -- df("LGM Auto Alt Kicker %s", LGM.SV.autoAltKick and "On" or "Off")
            -- LGM.inviteList:RefreshGroupList()
         elseif extra == 'togglemove' then
            LGM.recapPopup:SetMoveMode(movable)
            movable = not movable
         elseif extra == 'trackdeaths' then
            LGM.SV.trackDeaths = not LGM.SV.trackDeaths
            LGM.deathList:RegisterEvents(LGM.SV.trackDeaths)
         elseif extra == 'marktrialstart' then
            LGM.SV.markTrialStart = not LGM.SV.markTrialStart
            d("LGM Mark Trial Start: "..tostring(LGM.SV.markTrialStart))
         elseif extra == 'muteinvites' then
            LGM.SV.muteInvites = not LGM.SV.muteInvites
            d("LGM Mute Invite Responses: "..tostring(LGM.SV.muteInvites).." (will take effect after relog or reloadui)")
         elseif extra == 'autoselect' then
            LGM.SV.autoSelectLGM = not LGM.SV.autoSelectLGM
            d("LGM AutoSelect Group Menu: "..tostring(LGM.SV.autoSelectLGM))
         else
            local _, _, arg = extra:find("^%s*recap%s+(%d+)")
            arg = tonumber(arg)
            if arg then
               LGM.SV.recapLength = arg
               df("LGM Death Recap Rows: %d", arg)
               return
            end
            local _, _, arg = extra:find("^%s*liverecap%s+(%d+)")
            arg = tonumber(arg)
            if arg then
               LGM.SV.livePopupLength = arg
               df("LGM Live Recap Rows (0 = off): %d", arg)
               return
            end

            df("|CFF2255Invalid LGM arguments: %s|r", extra)
         end
      end

      ----------------------------------------------------------------------------------------------------
      --Disable raid invites upon completion of raid
      EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_RAID_TRIAL_COMPLETE, function() LGM:DisbleRaidInvites() end)
   end

end


local function OnCharacterLoad(eventCode, initialLoad)
   local function AddName(name)
      return LGM.raidList:AddRaidMember(name, LGM.SV.inviteGroup)
   end

   local function AddCharacter(self, control, button, upInside)
      local data = ZO_ScrollList_GetData(control)
      if(button == MOUSE_BUTTON_INDEX_RIGHT and upInside) then

         if not data.isLocalPlayer then
            (AddCustomMenuItem or AddMenuItem)("Add to Raid Group", function()
               return AddName(data.displayName)
            end)

            self:ShowMenu(control)
         end
      elseif button == 3 or button == 4 or button == 5 then
         return AddName(data.displayName)
      end
   end

   local function HookMenu(list, fnName)
      SecurePostHook(list, fnName, function(...)
         AddCharacter(...)
      end)
   end
   HookMenu(GROUP_LIST, "GroupListRow_OnMouseUp")
   HookMenu(GUILD_ROSTER_KEYBOARD, "GuildRosterRow_OnMouseUp")
   HookMenu(FRIENDS_LIST, "FriendsListRow_OnMouseUp")

   EVENT_MANAGER:UnregisterForEvent(LGM.name, EVENT_PLAYER_ACTIVATED)
end


function LGM:DisbleRaidInvites()
   local inviteButton = GetControl(self.raidList.control, "InviteGroup")
   if inviteButton then
      self.raidList:InviteButtonHandler(inviteButton, 2)
   end
end

function LGM:DisableInvites()
   local chatButton = self.iSettings.enable
   chatButton.value = true
   local Toggle = chatButton:GetHandler("OnMouseUp")
   Toggle(chatButton)

   LGM:DisbleRaidInvites()
end


function LGM:OnInitialized()
   EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, self.OnAddonLoaded)
   EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, OnCharacterLoad)

end

-- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED, function(...) d(...) end)
-- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GROUP_MEMBER_LEFT, function(...) d(...) end)


