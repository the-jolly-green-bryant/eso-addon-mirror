SlashVivec = {}
SlashVivec.name = "SlashVivec"

function SlashVivec.OnAddOnLoaded(event, addonName)
  if addonName == SlashVivec.name then
    SlashVivec:Initialize()
  end
end

function SlashVivec:Initialize()
  SLASH_COMMANDS["/vivec"] = SlashVivec.vivec
  SLASH_COMMANDS["/vv"] = SlashVivec.vivec
  SLASH_COMMANDS["/twotools"] = SlashVivec.twotools
  SLASH_COMMANDS["/tt"] = SlashVivec.twotools
  d("SlashVivec 0.6.9 By damage_1 Has Loaded.")
end

function SlashVivec.vivec()

  vivecerNotFound = true

  if vivecerNotFound and IsPlayerInGroup(GetDisplayName()) then
		local groupUnitTag = ""
		for i = 1, GetGroupSize() do
			groupUnitTag = GetGroupUnitTagByIndex(i)
			local gr = {}
			if groupUnitTag ~= nil and GetUnitZoneIndex(groupUnitTag) ~= nil then
				gr.displayName = GetUnitDisplayName(groupUnitTag)
				gr.online = IsUnitOnline(groupUnitTag)
				gr.zoneId = GetZoneId(GetUnitZoneIndex(groupUnitTag))
			end
      if gr.displayName ~= GetDisplayName() and gr.online and gr.zoneId == 849 then
        JumpToGroupMember(gr.displayName)
        vivecerNotFound = false
        break
      end
    end  
  end

  if vivecerNotFound then
    for i = 1, GetNumFriends() do
          local fr = {}
          fr.displayName, fr.note, fr.status, fr.secsSinceLogoff = GetFriendInfo(i)
          fr.hasCharacter, fr.characterName, fr.zoneName, fr.classType, fr.alliance, fr.level, fr.championRank, fr.zoneId = GetFriendCharacterInfo(i)
          if fr.displayName ~= GetDisplayName() and fr.displayName ~= "" and fr.status ~= 4 and fr.zoneId == 849 then
            JumpToFriend(fr.displayName)
            vivecerNotFound = false
            break
          end
    end
  end
  
  if vivecerNotFound then
    for i = 1, GetNumGuilds() do
      local totalGuildMembers = GetNumGuildMembers(GetGuildId(i))
      if not vivecerNotFound then
        break
      else
        for j = 1, totalGuildMembers do
            local gm = {}
            gm.displayName, gm.note, gm.rankIndex, gm.status, gm.secsSinceLogoff = GetGuildMemberInfo(GetGuildId(i), j)
            gm.hasCharacter, gm.characterName, gm.zoneName, gm.classType, gm.alliance, gm.level, gm.championRank, gm.zoneId = GetGuildMemberCharacterInfo(GetGuildId(i), j)
            
            if gm.displayName ~= GetDisplayName() and gm.displayName ~= "" and gm.status ~= 4 and gm.zoneId == 849 then
              JumpToGuildMember(gm.displayName)
              vivecerNotFound = false
              break
            end
        end
      end	
    end
  end
  if vivecerNotFound then
    if HasCompletedFastTravelNodePOI(284) then 
      d("No one is in Vivec City. Fast travelling with gold...")
      FastTravelToNode(284)
      vivecerNotFound = false
    else
      d("No one is in Vivec City, and you have never been there before. Fast travelling to Seyda Neen with gold instead...")
      FastTravelToNode(272)
      vivecerNotFound = false
    end
  end
end

function SlashVivec.twotools()
    d("Teleporting to @twotools' house...")
    JumpToHouse("@twotools")
end




EVENT_MANAGER:RegisterForEvent(SlashVivec.name, EVENT_ADD_ON_LOADED, SlashVivec.OnAddOnLoaded)
