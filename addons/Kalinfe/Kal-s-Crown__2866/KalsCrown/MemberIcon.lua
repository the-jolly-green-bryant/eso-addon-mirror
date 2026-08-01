local KC = KalsCrown

local MemberData = KC.members

-- Big shout out to @Lamierina7, I do not have the experience required to do this type of math on my own. Their work really helped
function KalsCrown.UpdateMemberIcon(matrix, dims, window, tag)
  local data = MemberData[tag]
  local info = data.info
  local unit = data.unit
  local control = data.control
  local highlight = data.highlight

  if(unit) then
    control:SetHidden(true)
    highlight:SetHidden(true)
    -- Get the position of the player
    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(unit)
    worldY = worldY + info.displayOffset
    -- Calculate (with our camera matrix)
    local playerX = worldX * matrix.i11 + worldY * matrix.i21 + worldZ * matrix.i31 + matrix.i41
    local playerY = worldX * matrix.i12 + worldY * matrix.i22 + worldZ * matrix.i32 + matrix.i42
    local playerZ = worldX * matrix.i13 + worldY * matrix.i23 + worldZ * matrix.i33 + matrix.i43
    -- Check if player is in front
    if(playerZ > 0 and info.shouldDisplay) then
      -- Find the player's screen position
      local w, h = GetWorldDimensionsOfViewFrustumAtDepth(playerZ)
      local x, y = playerX * dims.uiW / w, -playerY * dims.uiH / h
      control:ClearAnchors()
      control:SetAnchor(CENTER, window, CENTER, x, y)
      local scale = info.displaySize * 1000 / playerZ
      control:SetDimensions(scale, scale)
      control:SetHidden(false)

      if(info.shouldHighlight) then
        highlight:ClearAnchors()
        highlight:SetAnchor(CENTER, window, CENTER, x, y)
        scale = (info.displaySize * 1.14) * 1000 / playerZ
        highlight:SetDimensions(scale, scale)
        highlight:SetHidden(false)
      end
      return playerZ, control
    end
  end
  return -1, control
end

function KalsCrown.ShouldDisplay(data)
  local info = data.info
  local displayInfo = KalsCrown.vars
  if(info.isSelf) then
    return displayInfo.showSelf
  end
  if(displayInfo.showEveryone) then
    return true
  else
    if(info.isLeader) then
      return displayInfo.showLeader
    elseif(info.role == LFG_ROLE_HEAL) then
      return displayInfo.showHealers
    elseif(info.role == LFG_ROLE_TANK) then
      return displayInfo.showTanks
    end
  end
  return false
end

function KalsCrown.ShouldHighlight(data)
  local info = data.info
  local displayInfo = KalsCrown.vars
  if(info.isSelf) then
    return displayInfo.highlightSelf
  end
  if(displayInfo.highlightEveryone) then
    return true
  else
    if(info.isLeader) then
      return displayInfo.highlightLeader
    elseif(info.role == LFG_ROLE_HEAL) then
      return displayInfo.highlightHealers
    elseif(info.role == LFG_ROLE_TANK) then
      return displayInfo.highlightTanks
    end
  end
  return false
end

function KalsCrown.GetRoleOffset(data)
  local info = data.info
  local displayInfo = KalsCrown.vars
  if(info.isSelf) then
    return displayInfo.selfOffset
  elseif(info.isLeader) then
    return displayInfo.leaderOffset
  elseif(info.role == LFG_ROLE_HEAL) then
    return displayInfo.healerOffset
  elseif(info.role == LFG_ROLE_TANK) then
    return displayInfo.tankOffset
  end
  return displayInfo.generalOffset
end

function KalsCrown.GetRoleSize(data)
  local info = data.info
  local displayInfo = KalsCrown.vars
  if(info.isSelf) then
    return displayInfo.selfSize
  elseif(info.isLeader) then
    return displayInfo.leaderSize
  elseif(info.role == LFG_ROLE_HEAL) then
    return displayInfo.healerSize
  elseif(info.role == LFG_ROLE_TANK) then
    return displayInfo.tankSize
  end
  return displayInfo.generalSize
end

function KalsCrown.FindMemberInfo(tag)
  if(not MemberData[tag].info) then
    MemberData[tag].info = {}
  end
  local info = MemberData[tag].info
  info.role = GetGroupMemberSelectedRole(tag)
  info.isLeader = tag == GetGroupLeaderUnitTag()
  info.isOnline = IsUnitOnline(tag)
  info.isSelf = tag == "player"
  info.shouldDisplay = KalsCrown.ShouldDisplay(MemberData[tag])
  info.shouldHighlight = KalsCrown.ShouldHighlight(MemberData[tag])
  if(not info.isSelf and AreUnitsEqual("player", tag)) then
    info.shouldDisplay = false
  end
  info.displaySize = KalsCrown.GetRoleSize(MemberData[tag])
  info.displayOffset = KalsCrown.GetRoleOffset(MemberData[tag])
end

function KalsCrown.RebuildMemberData(window, tag)
  local data = MemberData[tag]
  data.displayName = GetUnitDisplayName(tag)
  if(not data.control) then
    data.control = KalsCrown.BuildControl(tag, window)
  end
  if(not data.highlight) then
    data.highlight = KalsCrown.BuildHighlight(tag, window)
  end
  KalsCrown.FindMemberInfo(tag)
  -- animInfo stored as icon, cols, rows, fr
  data.isAnim, data.animInfo = KalsCrown.GetIcon(data.displayName, data.info.role)
  --data.isAnim, data.animInfo = KalsCrown.GetIcon("@ValyrianEmpress", data.info.role)
  data.icon = data.animInfo
  if(data.isAnim) then
    data.icon = data.animInfo[1]
  end
  data.control:SetTexture(data.icon)
  KalsCrown.createAnimation(tag)
end

function KalsCrown.BuildControl(tag, window)
  local control = WINDOW_MANAGER:CreateControl("KalsCrown"..tag, window, CT_TEXTURE)
  control:ClearAnchors()
  control:SetAnchor(CENTER, window, CENTER, 0, 0)
  control:SetDimensions(75,75)
  control:SetHidden(true)
  return control
end

function KalsCrown.BuildHighlight(tag, window)
  local control = WINDOW_MANAGER:CreateControl("KalsCrownHighlight"..tag, window, CT_TEXTURE)
  control:ClearAnchors()
  control:SetAnchor(CENTER, window, CENTER, 0, 0)
  control:SetDimensions(85,85)
  control:SetHidden(true)
  control:SetTexture("KalsCrown/Icons/highlight.dds")
  return control
end

function KalsCrown.destroyTimeline(tag)
  local mData = MemberData[tag]
  local data = MemberData[tag].anim
  if(data.timeline) then
    data.anim:SetImageData(1,1)
    data.anim:SetFramerate(1)
    data.timeline:SetEnabled(false)
    data.timeline = ANIMATION_MANAGER:CreateTimeline()
  end
end

function KalsCrown.createAnimation(tag)
  local mData = MemberData[tag]
  if(not mData.anim) then
    mData.anim = {}
  end
  local data = mData.anim
  local control = mData.control
  if(mData.isAnim) then
    KalsCrown.destroyTimeline(tag)
    data.timeline = ANIMATION_MANAGER:CreateTimeline()
    data.anim = data.timeline:InsertAnimation(ANIMATION_TEXTURE, control)
    --CHAT_SYSTEM:AddMessage("[Kals Crown] " .. mData)
    data.anim:SetImageData(mData.animInfo[2],mData.animInfo[3])
    data.anim:SetFramerate(mData.animInfo[4])
    control:SetTexture(mData.icon)
    data.timeline:SetEnabled(true)
    data.timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    data.timeline:PlayFromStart()
  else
    KalsCrown.destroyTimeline(tag)
  end
end
