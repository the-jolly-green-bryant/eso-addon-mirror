local BAF = BetterDungonFinder

--Tool Function
local function Distance(p1, p2)
  return math.sqrt(math.pow(p1[1] - p2[1], 2) + math.pow(p1[2] - p2[2], 2) + math.pow(p1[3] - p2[3], 2))
end

local zoneIdList
local function IsPlayerInDungeon(zondId)
  if not zoneIdList then
    zoneIdList = {}
    for i = 1, #BAF.BaseDungeonInfo do
      zoneIdList[BAF.BaseDungeonInfo[i][3]] = true
    end
    for i = 1, #BAF.DLCDungeonInfo do
      zoneIdList[BAF.DLCDungeonInfo[i][3]] = true
    end
  end
  return zoneIdList[zondId]
end

local function Merge(displayName, zondId, xyzTable)
  local Count = 0
  --Check Any New Position
  for key, xyz in pairs(xyzTable) do
    if xyz[1] and xyz[2] and xyz[3] then
      local IsNew = true
      BAF.savedVariables.ChestList[zondId] = BAF.savedVariables.ChestList[zondId] or {}
      --Check by Distance
      for i = 1, #BAF.savedVariables.ChestList[zondId] do
        if Distance(xyz, BAF.savedVariables.ChestList[zondId][i]) < 1000 then
          IsNew = false
        end
      end
      --Add New Position
      if IsNew then
        table.insert(BAF.savedVariables.ChestList[zondId], xyz)
        Count = Count + 1
      end
    end
  end
  --Something New
  if Count > 0 then
    BAF.MarkChests()
    d(zo_strformat(BAFLang_SI.MESSAGE_ReceivedChest, Count, displayName))
  end
  return
end

--Var
local CurrentMarks = {}
--local ReceivedData = {}
local ZoneLock

function BAF.ZoneChanged()
  --Reset ZoneLock and ReceivedData
  ZoneLock = nil
  --ReceivedData = {}
  BAF.MarkChests()
end

--Mark Possible Chests
function BAF.MarkChests()
  --Check OdySupportIcons
  if not OSI then return end
  --Initialize
  local ZoneId = GetUnitWorldPosition("player")
  for i = 1, #CurrentMarks do
    OSI.DiscardPositionIcon(CurrentMarks[i])
  end
  CurrentMarks = {}
  --Check Setting
  if (BAF.savedVariables.Mark_Chest == false) or (not IsPlayerInDungeon(ZoneId)) then return end
  --Mark
  local List = BAF.savedVariables.ChestList[ZoneId] or {}
  for key, xyz in pairs(List) do
    table.insert(CurrentMarks, OSI.CreatePositionIcon(xyz[1], xyz[2], xyz[3], BAF.savedVariables.Icon_Chest, BAF.savedVariables.Size_Cheset))
  end
end

local ChestName = {
  ["箱子"]     = true,  -- zh
  ["Chest"]    = true,  -- en
  ["Сундук"]   = true,  -- ru
  ["Truhe"]    = true,  -- de
  ["Truhe^f"]  = true,  -- de
  ["cofre"]    = true,  -- es
  ["cofre^m"]  = true,  -- es
  ["coffre"]   = true,  -- fr
  ["coffre^m"] = true,  -- fr
  ["宝箱"]     = true,  -- jp
}

--Add location of unmarked chest
function BAF.AddMarkChest(eventCode, result, targetName)
  --Initialize
  if not ChestName[targetName] then return end
  local ZoneId, cX, cY, cZ = GetUnitWorldPosition("player")
  if not IsPlayerInDungeon(ZoneId) then return end
  --Add
  BAF.savedVariables.ChestList[ZoneId] = BAF.savedVariables.ChestList[ZoneId] or {}
  for i = 1, #BAF.savedVariables.ChestList[ZoneId] do
    if Distance({cX, cY, cZ}, BAF.savedVariables.ChestList[ZoneId][i]) < 1000 then
      return
    end
  end
  d(BAFLang_SI.MESSAGE_AddChestMark)
  table.insert(BAF.savedVariables.ChestList[ZoneId], {cX, cY, cZ})
  BAF.MarkChests()
end

--Data Share--
function BAF.HandleDataShareReceived(tag, data)
  --Check Setting
  if BAF.savedVariables.Share_Chest == false then return end
  --Initialize
  local ZoneId = GetUnitWorldPosition(tag)
  local Name = GetUnitDisplayName(tag)
  --[[
  local Fliter = data % 10
  --Start Point
  if Fliter == 0 then 
    ReceivedData[Name] = {}
    ReceivedData[Name][data / 1000] = {}
    return
  end
  --Position
  if Fliter > 0 and Fliter < 4 then
    if ReceivedData[Name] and ReceivedData[Name][ZoneId] then
      local Index = (data - Fliter) / 10 % 100
      ReceivedData[Name][ZoneId][Index] = ReceivedData[Name][ZoneId][Index] or {}
      ReceivedData[Name][ZoneId][Index][Fliter] = math.floor(data / 1000)
    end
    return
  end
  --End Point
  if Fliter == 9 then
    if ReceivedData[Name] and ReceivedData[Name][(data - 9) / 1000] then
      Merge(Name, (data - 9) / 1000, ReceivedData[Name][(data - 9) / 1000])
    end
    return
  end
  ]]
  if ZoneId == data.zoneId and data.xyz then
    local xyzLists = {}
    if (#data.xyz)%3 ~= 0 then return end
    for i = 1, (#data.xyz)/3 do
      table.insert(xyzLists, {data.xyz[3*i-2], data.xyz[3*i-1], data.xyz[3*i]})
    end
    Merge(Name, ZoneId, xyzLists)
  end
end

function BAF.SendChestMarkerData(Code, IsCombat)
  --Check Setting
  if BAF.savedVariables.Share_Chest == false then return end
  --Check Dungeons and Out of Combat
  if IsCombat then return end
  local ZoneId = GetUnitWorldPosition("player")
  if not IsPlayerInDungeon(ZoneId) then return end
  --Avoid Repeated Messages
  if ZoneLock then return else ZoneLock = ZoneId end
  --[[
  --Prepare Raw Data
  local RawTable = {}
  if not BAF.savedVariables.ChestList[ZoneId] then return end
  for i = 1, #BAF.savedVariables.ChestList[ZoneId] do
    table.insert(RawTable, BAF.savedVariables.ChestList[ZoneId][i][1]*1000 + i*10 + 1) --i, X
    table.insert(RawTable, BAF.savedVariables.ChestList[ZoneId][i][2]*1000 + i*10 + 2) --i, Y
    table.insert(RawTable, BAF.savedVariables.ChestList[ZoneId][i][3]*1000 + i*10 + 3) --i, Z
  end
  --Nothing to Share
  if not RawTable[1] then return end
  --Send Messages
  BAF.ShareData:QueueData(ZoneId*1000 + 0)
  for i = 1, #RawTable do
    BAF.ShareData:QueueData(RawTable[i])
  end
  BAF.ShareData:QueueData(ZoneId*1000 + 9)
  ]]
  local xyzList = {}
  if not BAF.savedVariables.ChestList[ZoneId] then return end
  for i = 1, #BAF.savedVariables.ChestList[ZoneId] do
    table.insert(xyzList, BAF.savedVariables.ChestList[ZoneId][i][1])
    table.insert(xyzList, BAF.savedVariables.ChestList[ZoneId][i][2])
    table.insert(xyzList, BAF.savedVariables.ChestList[ZoneId][i][3])
  end
  BAF.ShareProtocol:Send({
    zoneId = ZoneId,
    xyz = xyzList
  })
end