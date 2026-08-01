RallyGroup = {}
RallyGroup.name = "RallyGroup"
RallyGroup.savedVarsName = "RallyGroupSavedVariables"
RallyGroup.enabled = false
RallyGroup.radius = 100
RallyGroup.updateMs = 1000
RallyGroup.requestedAnchorName = nil
RallyGroup.anchorOnCrown = false
RallyGroup.activeCrownKey = nil
RallyGroup.activeAnchorIsFallback = false
RallyGroup.saved = nil

local DEFAULT_SETTINGS = {
  left = nil,
  top = nil,
  defaultDistance = 50,
  backgroundAlpha = 0.50,
  defaultAnchorToCrown = false,
  showInRange = false,
  showOfflineMembers = true
}

RallyGroup.ignoredAccounts = {}
RallyGroup.ignoredCharacters = {}

RallyGroup.distanceHistory = {}
RallyGroup.anchorHistory = {}
RallyGroup.movementStableMeters = 10
RallyGroup.movementLookbackSeconds = 4
RallyGroup.historyKeepSeconds = 15
RallyGroup.lastHistoryFullCleanup = 0
RallyGroup.historyFullCleanupSeconds = 15
RallyGroup.anchorStableMeters = 10
RallyGroup.anchorStableSeconds = 3

local function Msg(text)
  CHAT_ROUTER:AddSystemMessage("|c66ccffRallyGroup:|r " .. text)
end

local function NormalizeAccountName(name)
  if not name or name == "" then return nil end
  name = zo_strtrim(name)
  if string.sub(name, 1, 1) ~= "@" then
    name = "@" .. name
  end
  return name
end

local function GetAccountKey(name)
  name = NormalizeAccountName(name)
  if not name then return nil end
  return string.lower(name)
end

local function GetCharacterKey(name)
  if not name or name == "" then return nil end
  return string.lower(zo_strtrim(name))
end

local function IsIgnoredMember(displayName, characterName)
  local accountKey = GetAccountKey(displayName)
  local characterKey = GetCharacterKey(characterName)

  if accountKey and RallyGroup.ignoredAccounts[accountKey] then
    return true
  end

  if characterKey and RallyGroup.ignoredCharacters[characterKey] then
    return true
  end

  return false
end


local function GetDefaultDistance()
  if RallyGroup.saved and tonumber(RallyGroup.saved.defaultDistance) then
    return tonumber(RallyGroup.saved.defaultDistance)
  end

  return DEFAULT_SETTINGS.defaultDistance
end

local function ShouldDefaultAnchorToCrown()
  if RallyGroup.saved and RallyGroup.saved.defaultAnchorToCrown ~= nil then
    return RallyGroup.saved.defaultAnchorToCrown == true
  end

  return DEFAULT_SETTINGS.defaultAnchorToCrown == true
end

local function GetDefaultAnchorName()
  if ShouldDefaultAnchorToCrown() then
    return "crown"
  end

  return nil
end

local function ShouldShowInRange()
  if RallyGroup.saved and RallyGroup.saved.showInRange ~= nil then
    return RallyGroup.saved.showInRange == true
  end

  return DEFAULT_SETTINGS.showInRange == true
end

local function ShouldShowOfflineMembers()
  if RallyGroup.saved and RallyGroup.saved.showOfflineMembers ~= nil then
    return RallyGroup.saved.showOfflineMembers == true
  end

  return DEFAULT_SETTINGS.showOfflineMembers == true
end

local function GetBackgroundAlpha()
  if RallyGroup.saved and tonumber(RallyGroup.saved.backgroundAlpha) then
    return tonumber(RallyGroup.saved.backgroundAlpha)
  end

  return DEFAULT_SETTINGS.backgroundAlpha
end

local function ApplyWindowBackgroundAlpha()
  if not RallyGroup.background then return end

  local alpha = GetBackgroundAlpha()
  if alpha < 0 then alpha = 0 end
  if alpha > 1 then alpha = 1 end

  RallyGroup.background:SetCenterColor(0, 0, 0, alpha)
end

local function CreateSettingsPanel()
  if RallyGroup.settingsPanel then return end

  local LAM = LibAddonMenu2
  if not LAM then return end

  local panelData = {
    type = "panel",
    name = "Rally Group",
    displayName = "Rally Group",
    author = "evaainefaye",
    version = "1.02",
    registerForRefresh = true,
    registerForDefaults = true
  }

  RallyGroup.settingsPanel = LAM:RegisterAddonPanel("RallyGroupOptions", panelData)

  local optionsData = {
    {
      type = "slider",
      name = "Default Radius",
      tooltip = "Radius in meters used when you type /rg or /rallygroup without a distance.",
      min = 30,
      max = 200,
      step = 1,
      getFunc = function() return GetDefaultDistance() end,
      setFunc = function(value)
        RallyGroup.saved.defaultDistance = tonumber(value) or DEFAULT_SETTINGS.defaultDistance
        if not RallyGroup.enabled then
          RallyGroup.radius = RallyGroup.saved.defaultDistance
        end
      end,
      default = DEFAULT_SETTINGS.defaultDistance
    },
    {
      type = "checkbox",
      name = "Default Anchor to Crown?",
      tooltip =
      "When enabled, /rg and /rallygroup without an explicit anchor will use the current crown/group leader as the anchor.",
      getFunc = function() return ShouldDefaultAnchorToCrown() end,
      setFunc = function(value)
        RallyGroup.saved.defaultAnchorToCrown = value == true
      end,
      default = DEFAULT_SETTINGS.defaultAnchorToCrown
    },
    {
      type = "checkbox",
      name = "Show Group Members In Range?",
      tooltip =
      "When enabled, group members inside the rally radius are shown in green with their distance to the anchor.",
      getFunc = function() return ShouldShowInRange() end,
      setFunc = function(value)
        RallyGroup.saved.showInRange = value == true
      end,
      default = DEFAULT_SETTINGS.showInRange
    },
    {
      type = "checkbox",
      name = "Show Offline Members?",
      tooltip =
      "When enabled, offline group members and members whose zone cannot be detected are shown in the Rally Group window.",
      getFunc = function() return ShouldShowOfflineMembers() end,
      setFunc = function(value)
        RallyGroup.saved.showOfflineMembers = value == true
      end,
      default = DEFAULT_SETTINGS.showOfflineMembers
    },
    {
      type = "slider",
      name = "Window Opacity",
      tooltip = "Adjust the Rally Group window background opacity from fully transparent to fully black.",
      min = 0,
      max = 100,
      step = 1,
      getFunc = function() return math.floor((GetBackgroundAlpha() * 100) + 0.5) end,
      setFunc = function(value)
        RallyGroup.saved.backgroundAlpha = (tonumber(value) or 50) / 100
        ApplyWindowBackgroundAlpha()
      end,
      default = math.floor(DEFAULT_SETTINGS.backgroundAlpha * 100)
    }
  }

  LAM:RegisterOptionControls("RallyGroupOptions", optionsData)
end

local function SaveWindowPosition()
  if not RallyGroup.window or not RallyGroup.saved then return end
  RallyGroup.saved.left = RallyGroup.window:GetLeft()
  RallyGroup.saved.top = RallyGroup.window:GetTop()
end

local function CreateUI()
  if RallyGroup.window then return end

  local wm = WINDOW_MANAGER
  local win = wm:CreateTopLevelWindow("RallyGroupWindow")
  win:SetDimensions(820, 340)
  win:SetHidden(true)
  -- Click-through window body: users control visibility with /rg off or /rallygroup off.
  -- The title bar remains mouse-enabled so the window can still be moved.
  win:SetMouseEnabled(false)
  win:SetMovable(true)
  win:SetClampedToScreen(true)

  local background = wm:CreateControl(nil, win, CT_BACKDROP)
  background:SetAnchorFill(win)
  background:SetCenterColor(0, 0, 0, GetBackgroundAlpha())
  background:SetEdgeColor(0.4, 0.4, 0.4, 0.85)
  background:SetDrawLayer(DL_BACKGROUND)

  if RallyGroup.saved and RallyGroup.saved.left and RallyGroup.saved.top then
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RallyGroup.saved.left, RallyGroup.saved.top)
  else
    win:SetAnchor(TOP, GuiRoot, TOP, 0, 120)
  end

  win:SetHandler("OnMoveStop", SaveWindowPosition)

  local titleBackground = wm:CreateControl(nil, win, CT_BACKDROP)
  titleBackground:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
  titleBackground:SetAnchor(TOPRIGHT, win, TOPRIGHT, 0, 0)
  titleBackground:SetHeight(32)
  titleBackground:SetCenterColor(0.08, 0.18, 0.28, 0.85)
  titleBackground:SetEdgeColor(0.25, 0.55, 0.80, 0.95)
  titleBackground:SetDrawLayer(DL_CONTROLS)
  titleBackground:SetMouseEnabled(true)
  titleBackground:SetHandler("OnMouseDown", function()
    win:StartMoving()
  end)
  titleBackground:SetHandler("OnMouseUp", function()
    win:StopMovingOrResizing()
    SaveWindowPosition()
  end)

  local title = wm:CreateControl(nil, win, CT_LABEL)
  title:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 2)
  title:SetAnchor(TOPRIGHT, win, TOPRIGHT, -34, 2)
  title:SetHeight(28)
  title:SetFont("ZoFontWinH3")
  title:SetColor(1, 0.85, 0.2, 1)
  title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  title:SetText("Rally Group")
  title:SetDrawLayer(DL_OVERLAY)
  title:SetMouseEnabled(true)
  title:SetHandler("OnMouseDown", function()
    win:StartMoving()
  end)
  title:SetHandler("OnMouseUp", function()
    win:StopMovingOrResizing()
    SaveWindowPosition()
  end)

  local close = wm:CreateControl(nil, win, CT_BUTTON)
  close:SetAnchor(TOPRIGHT, win, TOPRIGHT, -4, 3)
  close:SetDimensions(26, 26)
  close:SetFont("ZoFontGameBold")
  close:SetText("X")
  close:SetNormalFontColor(1, 0.35, 0.35, 1)
  close:SetMouseOverFontColor(1, 0.7, 0.7, 1)
  close:SetDrawLayer(DL_OVERLAY)
  close:SetMouseEnabled(true)
  close:SetHandler("OnClicked", function()
    RallyGroup.Stop()
  end)

  local body = wm:CreateControl(nil, win, CT_CONTROL)
  body:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 40)
  body:SetDimensions(800, 292)

  RallyGroup.window = win
  RallyGroup.body = body
  RallyGroup.title = title
  RallyGroup.titleBackground = titleBackground
  RallyGroup.close = close
  RallyGroup.background = background
  ApplyWindowBackgroundAlpha()
  RallyGroup.rowControls = RallyGroup.rowControls or {}
  RallyGroup.rowBackgrounds = RallyGroup.rowBackgrounds or {}
end

local function ResizeWindowForLineCount(lineCount)
  if not RallyGroup.window or not RallyGroup.body then return end

  local windowWidth = 820
  local lineHeight = ROW_HEIGHT or 24
  local chromeHeight = 52
  local verticalPadding = 8

  -- lineCount includes the header row plus all visible data rows.
  -- Keep the window just tall enough for the visible rows, then shrink/grow
  -- as the row count changes.
  local visibleRows = math.max(1, lineCount or 1)
  local desiredBodyHeight = (visibleRows * lineHeight) + verticalPadding
  local desiredHeight = chromeHeight + desiredBodyHeight

  local minimumHeight = chromeHeight + lineHeight + verticalPadding
  local maxHeight = desiredHeight

  if GuiRoot and GuiRoot.GetHeight then
    maxHeight = GuiRoot:GetHeight() - 80
  end

  if maxHeight < minimumHeight then
    maxHeight = minimumHeight
  end

  local windowHeight = math.min(math.max(minimumHeight, desiredHeight), maxHeight)
  local bodyHeight = math.max(lineHeight, windowHeight - chromeHeight)

  RallyGroup.window:SetDimensions(windowWidth, windowHeight)
  RallyGroup.body:SetDimensions(windowWidth - 20, bodyHeight)
end

local function FormatDistance(meters)
  if meters >= 1000 then
    return string.format("%.1f km", meters / 1000)
  end

  return string.format("%d m", meters)
end

local function ColorCell(text, color)
  if not color or color == "" then return tostring(text or "") end
  return color .. tostring(text or "") .. "|r"
end

local COLUMN_DISTANCE_X = 10
local COLUMN_DISTANCE_W = 70
local COLUMN_NAME_X = 92
local COLUMN_NAME_W = 340
local COLUMN_ZONE_X = 444
local COLUMN_ZONE_W = 220
local COLUMN_STATUS_X = 676
local COLUMN_STATUS_W = 110
local COLUMN_BODY_RIGHT = 800
local ROW_HEIGHT = 24

local function AddDisplayRow(rows, distanceText, name, zone, status, rowColor, zoneColor)
  table.insert(rows, {
    distance = distanceText or "",
    name = name or "",
    zone = zone or "",
    status = status or "",
    rowColor = rowColor or "|cffffff",
    zoneColor = zoneColor or rowColor or "|cffffff"
  })
end

local function GetRowControl(rowIndex, columnName)
  RallyGroup.rowControls = RallyGroup.rowControls or {}
  RallyGroup.rowControls[rowIndex] = RallyGroup.rowControls[rowIndex] or {}

  local existing = RallyGroup.rowControls[rowIndex][columnName]
  if existing then return existing end

  local label = WINDOW_MANAGER:CreateControl(nil, RallyGroup.body, CT_LABEL)
  label:SetFont("ZoFontGameSmall")
  label:SetVerticalAlignment(TEXT_ALIGN_TOP)
  label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

  RallyGroup.rowControls[rowIndex][columnName] = label
  return label
end

local function PositionColumnLabel(label, rowIndex, x, width, alignment)
  local y = (rowIndex - 1) * ROW_HEIGHT
  label:ClearAnchors()
  label:SetAnchor(TOPLEFT, RallyGroup.body, TOPLEFT, x, y)
  label:SetDimensions(width, ROW_HEIGHT)
  label:SetHorizontalAlignment(alignment or TEXT_ALIGN_LEFT)
  label:SetHidden(false)
end

local function GetRowBackground(rowIndex)
  RallyGroup.rowBackgrounds = RallyGroup.rowBackgrounds or {}

  local existing = RallyGroup.rowBackgrounds[rowIndex]
  if existing then return existing end

  local backdrop = WINDOW_MANAGER:CreateControl(nil, RallyGroup.body, CT_BACKDROP)
  backdrop:SetDrawLayer(DL_BACKGROUND)
  backdrop:SetEdgeColor(0, 0, 0, 0)

  RallyGroup.rowBackgrounds[rowIndex] = backdrop
  return backdrop
end

local function PositionRowBackground(backdrop, rowIndex)
  local y = (rowIndex - 1) * ROW_HEIGHT
  backdrop:ClearAnchors()
  backdrop:SetAnchor(TOPLEFT, RallyGroup.body, TOPLEFT, 0, y)
  backdrop:SetDimensions(800, ROW_HEIGHT)

  if rowIndex == 1 then
    -- Header row: slightly stronger shade.
    backdrop:SetCenterColor(0, 0, 0, 0.20)
    backdrop:SetHidden(false)
  elseif rowIndex % 2 == 0 then
    -- Alternate data rows: subtle light stripe.
    backdrop:SetCenterColor(1, 1, 1, 0.075)
    backdrop:SetHidden(false)
  else
    backdrop:SetHidden(true)
  end
end

local function HideUnusedRows(startIndex)
  if RallyGroup.rowControls then
    for rowIndex = startIndex, #RallyGroup.rowControls do
      local row = RallyGroup.rowControls[rowIndex]
      if row then
        for _, label in pairs(row) do
          label:SetHidden(true)
          label:SetText("")
        end
      end
    end
  end

  if RallyGroup.rowBackgrounds then
    for rowIndex = startIndex, #RallyGroup.rowBackgrounds do
      local backdrop = RallyGroup.rowBackgrounds[rowIndex]
      if backdrop then
        backdrop:SetHidden(true)
      end
    end
  end
end

local function HasColumnData(rows, columnName)
  for rowIndex, row in ipairs(rows) do
    -- Row 1 is the header. Only real data rows decide whether an optional column is visible.
    if rowIndex > 1 and row[columnName] and row[columnName] ~= "" then
      return true
    end
  end

  return false
end

local function RenderColumnRows(rows)
  if not RallyGroup.body then return end

  local showZoneColumn = HasColumnData(rows, "zone")
  local showStatusColumn = HasColumnData(rows, "status")

  local nameX = COLUMN_NAME_X
  local nameW = COLUMN_NAME_W
  local zoneX = COLUMN_ZONE_X
  local zoneW = COLUMN_ZONE_W
  local statusX = COLUMN_STATUS_X
  local statusW = COLUMN_STATUS_W

  if showZoneColumn and showStatusColumn then
    nameW = COLUMN_NAME_W
    zoneX = COLUMN_ZONE_X
    zoneW = COLUMN_ZONE_W
    statusX = COLUMN_STATUS_X
    statusW = COLUMN_STATUS_W
  elseif showZoneColumn and not showStatusColumn then
    nameW = COLUMN_NAME_W
    zoneX = COLUMN_ZONE_X
    zoneW = COLUMN_BODY_RIGHT - COLUMN_ZONE_X
  elseif not showZoneColumn and showStatusColumn then
    nameW = COLUMN_NAME_W
    statusX = COLUMN_ZONE_X
    statusW = COLUMN_BODY_RIGHT - COLUMN_ZONE_X
  else
    nameW = COLUMN_BODY_RIGHT - COLUMN_NAME_X
  end

  for rowIndex, row in ipairs(rows) do
    local rowBackground = GetRowBackground(rowIndex)
    local distanceLabel = GetRowControl(rowIndex, "distance")
    local nameLabel = GetRowControl(rowIndex, "name")
    local zoneLabel = GetRowControl(rowIndex, "zone")
    local statusLabel = GetRowControl(rowIndex, "status")

    PositionRowBackground(rowBackground, rowIndex)
    PositionColumnLabel(distanceLabel, rowIndex, COLUMN_DISTANCE_X, COLUMN_DISTANCE_W, TEXT_ALIGN_RIGHT)
    PositionColumnLabel(nameLabel, rowIndex, nameX, nameW, TEXT_ALIGN_LEFT)

    distanceLabel:SetText(ColorCell(row.distance, row.rowColor))
    nameLabel:SetText(ColorCell(row.name, row.rowColor))

    if showZoneColumn then
      PositionColumnLabel(zoneLabel, rowIndex, zoneX, zoneW, TEXT_ALIGN_LEFT)
      zoneLabel:SetText(ColorCell(row.zone, row.zoneColor or row.rowColor))
    else
      zoneLabel:SetHidden(true)
      zoneLabel:SetText("")
    end

    if showStatusColumn then
      PositionColumnLabel(statusLabel, rowIndex, statusX, statusW, TEXT_ALIGN_LEFT)
      statusLabel:SetText(ColorCell(row.status, row.rowColor))
    else
      statusLabel:SetHidden(true)
      statusLabel:SetText("")
    end
  end

  HideUnusedRows(#rows + 1)
end

local function GetDisplayNameWithCharacter(unitTag)
  local accountName = GetUnitDisplayName(unitTag) or ""
  local characterName = GetUnitName(unitTag) or ""

  if accountName == "" then
    accountName = "Unknown"
  end

  if characterName ~= "" and characterName ~= accountName then
    return accountName .. " (" .. characterName .. ")"
  end

  return accountName
end

local function GetDistanceMetersBetween(unitTagA, unitTagB)
  local zoneA, ax, ay, az = GetUnitWorldPosition(unitTagA)
  local zoneB, bx, by, bz = GetUnitWorldPosition(unitTagB)

  if not zoneA or not zoneB then return nil, zoneA, zoneB end
  if zoneA == 0 or zoneB == 0 then return nil, zoneA, zoneB end
  if zoneA ~= zoneB then return nil, zoneA, zoneB end

  if ax == 0 and ay == 0 and az == 0 then return nil, zoneA, zoneB end
  if bx == 0 and by == 0 and bz == 0 then return nil, zoneA, zoneB end

  local dx = ax - bx
  local dy = ay - by
  local dz = az - bz

  return math.sqrt(dx * dx + dy * dy + dz * dz) / 100, zoneA, zoneB
end

local function FindGroupUnitByDisplayName(name)
  if not name or name == "" then return nil end

  local wanted = string.lower(NormalizeAccountName(name) or name)
  local groupSize = GetGroupSize()
  local fallbackTag = nil

  for i = 1, groupSize do
    local unitTag = GetGroupUnitTagByIndex(i)

    if unitTag then
      local displayName = string.lower(GetUnitDisplayName(unitTag) or "")
      local characterName = string.lower(GetUnitName(unitTag) or "")

      if displayName == wanted or characterName == wanted then
        if IsUnitOnline(unitTag) and DoesUnitExist(unitTag) then
          return unitTag
        end

        fallbackTag = fallbackTag or unitTag
      end
    end
  end

  return fallbackTag
end

local function FindGroupUnitByAccountName(name)
  local accountName = NormalizeAccountName(name)
  if not accountName then return nil end

  local wanted = string.lower(accountName)
  local groupSize = GetGroupSize()

  for i = 1, groupSize do
    local unitTag = GetGroupUnitTagByIndex(i)

    if unitTag then
      local displayName = string.lower(GetUnitDisplayName(unitTag) or "")

      if displayName == wanted then
        return unitTag
      end
    end
  end

  return nil
end

local function FindGroupUnitByCharacterName(name)
  if not name or name == "" then return nil end

  local wanted = string.lower(zo_strtrim(name))
  local groupSize = GetGroupSize()

  for i = 1, groupSize do
    local unitTag = GetGroupUnitTagByIndex(i)

    if unitTag then
      local characterName = string.lower(GetUnitName(unitTag) or "")

      if characterName == wanted then
        return unitTag
      end
    end
  end

  return nil
end

local function FindGroupLeaderUnitTag()
  local groupSize = GetGroupSize()

  for i = 1, groupSize do
    local unitTag = GetGroupUnitTagByIndex(i)

    if unitTag and IsUnitGroupLeader and IsUnitGroupLeader(unitTag) then
      return unitTag
    end
  end

  return nil
end


local function GetAnchorUnitTag()
  if RallyGroup.anchorOnCrown then
    local crownTag = FindGroupLeaderUnitTag()

    if crownTag and IsUnitOnline(crownTag) and DoesUnitExist(crownTag) then
      local crownDisplayName = GetUnitDisplayName(crownTag) or ""
      local crownCharacterName = GetUnitName(crownTag) or ""
      local crownKey = GetAccountKey(crownDisplayName) or GetCharacterKey(crownCharacterName) or crownTag
      local crownLabel = "Crown: " .. GetDisplayNameWithCharacter(crownTag)

      if RallyGroup.activeAnchorIsFallback then
        Msg("Crown is available. Switching anchor back to " .. crownLabel .. ".")
        RallyGroup.anchorHistory = {}
        RallyGroup.distanceHistory = {}
        RallyGroup.lastHistoryFullCleanup = 0
      elseif RallyGroup.activeCrownKey and RallyGroup.activeCrownKey ~= crownKey then
        Msg("Crown changed. Switching anchor to " .. crownLabel .. ".")
        RallyGroup.anchorHistory = {}
        RallyGroup.distanceHistory = {}
        RallyGroup.lastHistoryFullCleanup = 0
      end

      RallyGroup.activeCrownKey = crownKey
      RallyGroup.activeAnchorIsFallback = false
      return crownTag, crownLabel
    end

    if not RallyGroup.activeAnchorIsFallback then
      Msg("Could not find an available crown/group leader. Switching anchor to you until crown is available.")
      RallyGroup.anchorHistory = {}
      RallyGroup.distanceHistory = {}
      RallyGroup.lastHistoryFullCleanup = 0
    end

    RallyGroup.activeCrownKey = nil
    RallyGroup.activeAnchorIsFallback = true
    return "player", "You"
  end

  if RallyGroup.requestedAnchorName and RallyGroup.requestedAnchorName ~= "" then
    local anchorTag = FindGroupUnitByDisplayName(RallyGroup.requestedAnchorName)

    if anchorTag and IsUnitOnline(anchorTag) and DoesUnitExist(anchorTag) then
      local requestedAnchorLabel = GetDisplayNameWithCharacter(anchorTag)

      if RallyGroup.activeAnchorIsFallback then
        Msg(RallyGroup.requestedAnchorName ..
          " rejoined the group. Switching anchor back to " .. requestedAnchorLabel .. ".")
        RallyGroup.anchorHistory = {}
        RallyGroup.distanceHistory = {}
        RallyGroup.lastHistoryFullCleanup = 0
      end

      RallyGroup.activeAnchorIsFallback = false
      return anchorTag, requestedAnchorLabel
    end

    if not RallyGroup.activeAnchorIsFallback then
      Msg(RallyGroup.requestedAnchorName .. " is no longer available. Switching anchor to you until they return.")
      RallyGroup.anchorHistory = {}
      RallyGroup.distanceHistory = {}
      RallyGroup.lastHistoryFullCleanup = 0
    end

    RallyGroup.activeAnchorIsFallback = true
    return "player", "You"
  end

  RallyGroup.activeAnchorIsFallback = false
  return "player", "You"
end

local function BuildTitle(anchorLabel)
  return string.format(
    "Rally Group On %s Radius %s",
    string.upper(tostring(anchorLabel or "You")),
    FormatDistance(RallyGroup.radius or 0)
  )
end

local function GetMemberKey(name)
  return string.lower(name or "")
end

local function UpdateMovementHistory(name, distance)
  local key = GetMemberKey(name)
  local now = GetFrameTimeSeconds()

  RallyGroup.distanceHistory[key] = RallyGroup.distanceHistory[key] or {}
  local history = RallyGroup.distanceHistory[key]

  table.insert(history, { time = now, distance = distance })

  while #history > 0 and now - history[1].time > RallyGroup.historyKeepSeconds do
    table.remove(history, 1)
  end
end

local function GetMovementText(name, currentDistance, stableMetersOverride)
  local key = GetMemberKey(name)
  local history = RallyGroup.distanceHistory[key]

  if not history or #history < 2 then return "" end

  local now = GetFrameTimeSeconds()
  local compareSample = nil

  for i = #history, 1, -1 do
    if now - history[i].time >= RallyGroup.movementLookbackSeconds then
      compareSample = history[i]
      break
    end
  end

  if not compareSample then compareSample = history[1] end

  local change = currentDistance - compareSample.distance
  local stableMeters = stableMetersOverride or RallyGroup.movementStableMeters

  if math.abs(change) <= stableMeters then return "" end
  if change < 0 then return " (Approaching)" end

  return " (Departing)"
end

local function PruneMovementHistory(activeKeys)
  for key in pairs(RallyGroup.distanceHistory) do
    if not activeKeys[key] then
      RallyGroup.distanceHistory[key] = nil
    end
  end
end

local function UpdateAnchorHistory(anchorTag)
  local zone, x, y, z = GetUnitWorldPosition(anchorTag)
  if not zone then return end
  if x == 0 and y == 0 and z == 0 then return end

  local now = GetFrameTimeSeconds()

  table.insert(RallyGroup.anchorHistory, {
    time = now,
    zone = zone,
    x = x,
    y = y,
    z = z
  })

  while #RallyGroup.anchorHistory > 0 and now - RallyGroup.anchorHistory[1].time > RallyGroup.historyKeepSeconds do
    table.remove(RallyGroup.anchorHistory, 1)
  end
end

local function IsAnchorStable()
  local history = RallyGroup.anchorHistory
  if not history or #history < 2 then return false end

  local newest = history[#history]
  local oldest = history[1]

  if newest.zone ~= oldest.zone then return false end
  if newest.time - oldest.time < RallyGroup.anchorStableSeconds then return false end

  local dx = newest.x - oldest.x
  local dy = newest.y - oldest.y
  local dz = newest.z - oldest.z
  local movedMeters = math.sqrt(dx * dx + dy * dy + dz * dz) / 100

  return movedMeters <= RallyGroup.anchorStableMeters
end

local function CleanupAllHistory()
  local now = GetFrameTimeSeconds()

  if now - (RallyGroup.lastHistoryFullCleanup or 0) < RallyGroup.historyFullCleanupSeconds then
    return
  end

  RallyGroup.lastHistoryFullCleanup = now

  for key, history in pairs(RallyGroup.distanceHistory) do
    while #history > 0 and now - history[1].time > RallyGroup.historyKeepSeconds do
      table.remove(history, 1)
    end

    if #history == 0 then
      RallyGroup.distanceHistory[key] = nil
    end
  end

  while #RallyGroup.anchorHistory > 0 and now - RallyGroup.anchorHistory[1].time > RallyGroup.historyKeepSeconds do
    table.remove(RallyGroup.anchorHistory, 1)
  end
end

local function GetStatusSuffix(unitTag)
  local suffix = ""

  if not IsUnitOnline(unitTag) then
    suffix = suffix .. " (Offline)"
  end

  if IsUnitDead(unitTag) then
    suffix = suffix .. " (Dead)"
  end

  return suffix
end

local function GetZoneNameFromWorldZoneId(zoneId)
  if not zoneId or zoneId == 0 then return "Unknown Zone" end

  if GetZoneNameById then
    local zoneName = GetZoneNameById(zoneId)
    if zoneName and zoneName ~= "" and zoneName ~= "Different Zone" then
      return zoneName
    end
  end

  return "Zone ID " .. tostring(zoneId)
end

local function GetUnitZoneName(unitTag)
  if GetUnitZone then
    local unitZoneName = GetUnitZone(unitTag)
    if unitZoneName and unitZoneName ~= "" and unitZoneName ~= "Different Zone" then
      return unitZoneName
    end
  end

  return nil
end

local function GetWorldPositionInfo(unitTag)
  local zoneId, x, y, z = GetUnitWorldPosition(unitTag)
  local hasZoneId = zoneId ~= nil and zoneId ~= 0
  local hasValidPosition = hasZoneId and not (x == 0 and y == 0 and z == 0)
  local worldZoneName = GetZoneNameFromWorldZoneId(zoneId)
  local unitZoneName = GetUnitZoneName(unitTag)
  local zoneName = unitZoneName or worldZoneName

  return {
    zoneId = zoneId,
    x = x,
    y = y,
    z = z,
    hasZoneId = hasZoneId,
    hasValidPosition = hasValidPosition,
    zoneName = zoneName,
    worldZoneName = worldZoneName,
    unitZoneName = unitZoneName
  }
end

local function AreInSameDetectedZone(infoA, infoB)
  if not infoA or not infoB then return false end
  if not infoA.hasZoneId or not infoB.hasZoneId then return false end
  if infoA.zoneId ~= infoB.zoneId then return false end

  -- Public dungeons, trials, and other instances can sometimes share the
  -- parent world zone id. When ESO gives a more specific unit zone name,
  -- use that to tell whether two members are actually in the same place.
  if infoA.unitZoneName and infoB.unitZoneName and infoA.unitZoneName ~= infoB.unitZoneName then
    return false
  end

  return true
end

local function GetDistanceMetersFromInfo(infoA, infoB)
  if not AreInSameDetectedZone(infoA, infoB) then return nil end
  if not infoA.hasValidPosition or not infoB.hasValidPosition then return nil end

  local dx = infoA.x - infoB.x
  local dy = infoA.y - infoB.y
  local dz = infoA.z - infoB.z

  return math.sqrt(dx * dx + dy * dy + dz * dz) / 100
end

local function BuildAnchorDisplayLabel(anchorLabel, anchorTag)
  -- Keep the title focused on the anchor name only.
  -- If the anchor is in a different zone, that zone is shown in the detail rows below.
  return anchorLabel
end

local function AddMemberStatus(unitTag, inZoneMembers, otherZoneMembers, statusMembers,
                               activeMovementKeys, anchorTag, anchorStable, showAnchorZoneForDistances,
                               playerDisplayName, playerCharacterName)
  if not unitTag or unitTag == anchorTag then return end

  local displayName = GetUnitDisplayName(unitTag) or ""
  local characterName = GetUnitName(unitTag) or ""
  local name = GetDisplayNameWithCharacter(unitTag)

  -- When the player is the anchor, ESO may still expose the player through a
  -- group unit tag. Do not list yourself when you are the anchor.
  if anchorTag == "player" and displayName == playerDisplayName and characterName == playerCharacterName then
    return
  end

  if IsIgnoredMember(displayName, characterName) then return end

  local showOfflineMembers = ShouldShowOfflineMembers()
  local isOnline = IsUnitOnline(unitTag)

  if not isOnline then
    if showOfflineMembers then
      table.insert(statusMembers, {
        name = name,
        accountKey = GetAccountKey(displayName) or string.lower(displayName or ""),
        characterKey = GetCharacterKey(characterName) or string.lower(characterName or ""),
        zone = "",
        status = " (Offline)"
      })
    end
    return
  end

  local isDead = IsUnitDead(unitTag)
  local statusSuffix = GetStatusSuffix(unitTag)
  local anchorInfo = GetWorldPositionInfo(anchorTag)
  local memberInfo = GetWorldPositionInfo(unitTag)

  if isDead then
    if showOfflineMembers then
      table.insert(statusMembers, {
        name = name,
        accountKey = GetAccountKey(displayName) or string.lower(displayName or ""),
        characterKey = GetCharacterKey(characterName) or string.lower(characterName or ""),
        zone = memberInfo.zoneName or "",
        status = " (Dead)"
      })
    end
    return
  end

  local function AddOtherZoneMember(zoneName)
    zoneName = zoneName or memberInfo.zoneName or "Unknown Zone"

    table.insert(otherZoneMembers, {
      name = name,
      accountKey = GetAccountKey(displayName) or string.lower(displayName or ""),
      characterKey = GetCharacterKey(characterName) or string.lower(characterName or ""),
      zone = zoneName,
      status = statusSuffix
    })
  end

  -- Zone membership is decided by the detected anchor zone/instance. If the
  -- member's zone cannot be detected, treat that like an offline/unknown entry
  -- controlled by the Show Offline Members setting.
  if not memberInfo.hasZoneId then
    if showOfflineMembers then
      table.insert(statusMembers, {
        name = name,
        zone = "",
        status = " (Zone Unknown)"
      })
    end
    return
  end

  if not anchorInfo.hasZoneId then
    if showOfflineMembers then
      table.insert(statusMembers, {
        name = name,
        accountKey = GetAccountKey(displayName) or string.lower(displayName or ""),
        characterKey = GetCharacterKey(characterName) or string.lower(characterName or ""),
        zone = memberInfo.zoneName or "",
        status = " (Anchor Zone Unknown)"
      })
    end
    return
  end

  if not AreInSameDetectedZone(anchorInfo, memberInfo) then
    AddOtherZoneMember(memberInfo.zoneName)
    return
  end

  -- Same detected anchor zone/instance: report distance when both positions are usable.
  -- If ESO gives a same-zone id but zero coordinates, keep the member visible as unknown distance.
  if not anchorInfo.hasValidPosition or not memberInfo.hasValidPosition then
    table.insert(inZoneMembers, {
      name = name,
      distance = 999999999,
      distanceText = "Unknown",
      zone = showAnchorZoneForDistances and memberInfo.zoneName or nil,
      movement = "",
      status = statusSuffix,
      inRange = false
    })
    return
  end

  local distance = GetDistanceMetersFromInfo(anchorInfo, memberInfo)
  if not distance then
    AddOtherZoneMember(memberInfo.zoneName)
    return
  end

  local isInRange = distance <= RallyGroup.radius
  local showInRange = ShouldShowInRange()

  -- Keep movement history even while the member is in range. This lets movement
  -- status appear immediately when they leave the radius instead of waiting for
  -- a new out-of-range history window to build.
  UpdateMovementHistory(name, distance)
  activeMovementKeys[GetMemberKey(name)] = true

  if not isInRange or showInRange then
    local movementThreshold = RallyGroup.movementStableMeters

    if isInRange then
      -- In-range rows are mostly informational. Suppress minor movement text
      -- unless the change is larger than the normal out-of-range threshold.
      movementThreshold = RallyGroup.movementStableMeters * 2
    end

    table.insert(inZoneMembers, {
      name = name,
      distance = distance,
      distanceText = FormatDistance(distance),
      zone = showAnchorZoneForDistances and memberInfo.zoneName or nil,
      movement = anchorStable and GetMovementText(name, distance, movementThreshold) or "",
      status = statusSuffix,
      inRange = isInRange
    })
  end
end

local function CompareMemberByAccountThenCharacter(a, b)
  local aAccount = a.accountKey or string.lower(a.name or "")
  local bAccount = b.accountKey or string.lower(b.name or "")

  if aAccount ~= bAccount then
    return aAccount < bAccount
  end

  local aCharacter = a.characterKey or ""
  local bCharacter = b.characterKey or ""

  if aCharacter ~= bCharacter then
    return aCharacter < bCharacter
  end

  return (a.name or "") < (b.name or "")
end

function RallyGroup.Update()
  if not RallyGroup.enabled then return end

  CleanupAllHistory()
  CreateUI()

  if not IsUnitGrouped("player") then
    RallyGroup.window:SetHidden(true)
    return
  end

  local anchorTag, anchorLabel = GetAnchorUnitTag()
  RallyGroup.title:SetText(BuildTitle(BuildAnchorDisplayLabel(anchorLabel, anchorTag)))

  local playerInfo = GetWorldPositionInfo("player")
  local anchorInfo = GetWorldPositionInfo(anchorTag)
  local playerIsAnchor = anchorTag == "player"
  local playerSeparatedFromAnchor = not playerIsAnchor and not AreInSameDetectedZone(playerInfo, anchorInfo)
  local showAnchorZoneForDistances = playerSeparatedFromAnchor
      and playerInfo.hasZoneId
      and anchorInfo.hasZoneId

  local pinnedMembers = {}
  local inZoneMembers = {}
  local otherZoneMembers = {}
  local statusMembers = {}
  local activeMovementKeys = {}
  local playerDisplayName = GetUnitDisplayName("player") or ""
  local playerCharacterName = GetUnitName("player") or ""
  local playerName = GetDisplayNameWithCharacter("player")

  if playerSeparatedFromAnchor then
    -- Anchor is always first when you are separated from it. Its distance is
    -- 0 m because the anchor is always 0 m from itself. Its zone belongs in
    -- the Zone column, not in the title bar.
    table.insert(pinnedMembers, {
      name = "ANCHOR: " .. GetDisplayNameWithCharacter(anchorTag),
      distance = 0,
      distanceText = "0 m",
      zone = anchorInfo.zoneName or "Unknown Zone",
      movement = "",
      status = "",
      pinnedType = "anchor"
    })

    -- Since the player is not the anchor and is not in the anchor's zone,
    -- include the player among the other-zone members. Distance is blank
    -- because cross-zone distance is not meaningful.
    if playerInfo.hasZoneId then
      table.insert(otherZoneMembers, {
        name = playerName,
        accountKey = GetAccountKey(playerDisplayName) or string.lower(playerDisplayName or ""),
        characterKey = GetCharacterKey(playerCharacterName) or string.lower(playerCharacterName or ""),
        zone = playerInfo.zoneName or "Unknown Zone",
        status = ""
      })
    elseif ShouldShowOfflineMembers() then
      table.insert(statusMembers, {
        name = playerName,
        accountKey = GetAccountKey(playerDisplayName) or string.lower(playerDisplayName or ""),
        characterKey = GetCharacterKey(playerCharacterName) or string.lower(playerCharacterName or ""),
        zone = "",
        status = " (Zone Unknown)"
      })
    end
  end

  UpdateAnchorHistory(anchorTag)
  local anchorStable = IsAnchorStable()

  local groupSize = GetGroupSize()

  for i = 1, groupSize do
    local unitTag = GetGroupUnitTagByIndex(i)
    local unitDisplayName = GetUnitDisplayName(unitTag) or ""
    local unitCharacterName = GetUnitName(unitTag) or ""

    local isPlayerRow = unitDisplayName == playerDisplayName and unitCharacterName == playerCharacterName

    -- If you are the anchor, never show yourself. If you are separated from
    -- the anchor, the player row was already added explicitly above so it can
    -- be sorted with other non-anchor-zone members.
    if not (playerIsAnchor and isPlayerRow) and not (playerSeparatedFromAnchor and isPlayerRow) then
      AddMemberStatus(
        unitTag,
        inZoneMembers,
        otherZoneMembers,
        statusMembers,
        activeMovementKeys,
        anchorTag,
        anchorStable,
        showAnchorZoneForDistances,
        playerDisplayName,
        playerCharacterName
      )
    end
  end

  PruneMovementHistory(activeMovementKeys)

  table.sort(inZoneMembers, function(a, b)
    return a.distance < b.distance
  end)

  table.sort(otherZoneMembers, function(a, b)
    local aZone = a.zone or ""
    local bZone = b.zone or ""

    if aZone ~= bZone then
      return aZone < bZone
    end

    return CompareMemberByAccountThenCharacter(a, b)
  end)

  table.sort(statusMembers, CompareMemberByAccountThenCharacter)

  if #pinnedMembers == 0 and #inZoneMembers == 0 and #otherZoneMembers == 0 and #statusMembers == 0 then
    ResizeWindowForLineCount(1)
    HideUnusedRows(1)
    RallyGroup.window:SetHidden(true)
    return
  end

  local rows = {}
  AddDisplayRow(rows, "Distance", "Account / Character", "Zone", "Status", "|caaaaaa", "|caaaaaa")

  -- 0. Anchor row when you are separated from the anchor.
  for _, member in ipairs(pinnedMembers) do
    AddDisplayRow(
      rows,
      member.distanceText,
      member.name,
      member.zone or "",
      (member.status or "") .. (member.movement or ""),
      "|c66ff66",
      member.zone and "|c66ccff" or "|c66ff66"
    )
  end

  -- 1. Members in the anchor's zone, sorted closest to farthest from anchor.
  for _, member in ipairs(inZoneMembers) do
    local color = "|cffff66"

    if member.inRange then
      color = "|c66ff66"
    elseif member.distance >= RallyGroup.radius * 2 then
      color = "|cff4444"
    end

    AddDisplayRow(
      rows,
      member.distanceText,
      member.name,
      member.zone or "",
      (member.status or "") .. (member.movement or ""),
      color,
      member.zone and "|c66ccff" or color
    )
  end

  -- 2. Members not in the anchor's zone, sorted by zone then account/character.
  for _, member in ipairs(otherZoneMembers) do
    AddDisplayRow(
      rows,
      "",
      member.name,
      member.zone,
      member.status or "",
      "|cffa500",
      "|c66ccff"
    )
  end

  -- 3. Offline, dead, or unknown-zone members, sorted alphabetically.
  for _, member in ipairs(statusMembers) do
    AddDisplayRow(
      rows,
      "",
      member.name,
      member.zone or "",
      member.status or "",
      "|cff66ff",
      member.zone and "|c66ccff" or "|cff66ff"
    )
  end

  ResizeWindowForLineCount(#rows)
  RenderColumnRows(rows)
  RallyGroup.window:SetHidden(false)
end

function RallyGroup.Start(radius, anchorName)
  radius = tonumber(radius)

  if not radius or radius <= 0 then
    Msg(
      "Use /rg, /rg @name, /rg charactername, /rg <number>, /rg crown <number>, /rg <number> crown, /rg <number> @name, /rg @name <number>, /rg ignore @name, /rg ignore charactername, /rg ignore clear, or /rg off")
    return
  end

  RallyGroup.radius = radius
  RallyGroup.enabled = true
  RallyGroup.distanceHistory = {}
  RallyGroup.anchorHistory = {}
  RallyGroup.lastHistoryFullCleanup = 0
  RallyGroup.activeCrownKey = nil

  local fallbackMessage = nil

  if anchorName and anchorName ~= "" then
    if string.lower(anchorName) == "crown" then
      RallyGroup.anchorOnCrown = true
      RallyGroup.requestedAnchorName = nil

      if not FindGroupLeaderUnitTag() then
        RallyGroup.activeAnchorIsFallback = true
        fallbackMessage =
        "Crown/group leader was not found. Starting with YOU as the anchor, and will switch to crown when available."
      else
        RallyGroup.activeAnchorIsFallback = false
      end
    else
      RallyGroup.anchorOnCrown = false
      anchorName = NormalizeAccountName(anchorName)
      RallyGroup.requestedAnchorName = anchorName

      if not FindGroupUnitByDisplayName(anchorName) then
        RallyGroup.activeAnchorIsFallback = true
        fallbackMessage = anchorName ..
            " is not currently in your group. Starting with YOU as the anchor, and will switch if they join."
      else
        RallyGroup.activeAnchorIsFallback = false
      end
    end
  else
    RallyGroup.anchorOnCrown = false
    RallyGroup.requestedAnchorName = nil
    RallyGroup.activeAnchorIsFallback = false
  end

  CreateUI()
  RallyGroup.window:SetHidden(false)

  EVENT_MANAGER:UnregisterForUpdate(RallyGroup.name .. "Update")
  EVENT_MANAGER:RegisterForUpdate(
    RallyGroup.name .. "Update",
    RallyGroup.updateMs,
    RallyGroup.Update
  )

  if RallyGroup.anchorOnCrown then
    Msg("Enabled. Radius: " .. radius .. " meters. Anchor: CROWN.")
  elseif RallyGroup.requestedAnchorName then
    Msg("Enabled. Radius: " .. radius .. " meters. Requested anchor: " .. RallyGroup.requestedAnchorName .. ".")
  else
    Msg("Enabled. Radius: " .. radius .. " meters. Anchor: YOU.")
  end

  if fallbackMessage then
    Msg(fallbackMessage)
  end

  RallyGroup.Update()
end

function RallyGroup.Stop()
  RallyGroup.enabled = false

  EVENT_MANAGER:UnregisterForUpdate(RallyGroup.name .. "Update")

  SaveWindowPosition()

  if RallyGroup.window then
    RallyGroup.window:SetHidden(true)
  end

  RallyGroup.distanceHistory = {}
  RallyGroup.anchorHistory = {}
  RallyGroup.lastHistoryFullCleanup = 0
  RallyGroup.activeCrownKey = nil

  Msg("Disabled.")
end

function RallyGroup.OpenSettings()
  local LAM = LibAddonMenu2

  if not LAM then
    Msg("Settings require LibAddonMenu-2.0 to be installed/enabled.")
    return
  end

  CreateSettingsPanel()

  if LAM.OpenToPanel and RallyGroup.settingsPanel then
    LAM:OpenToPanel(RallyGroup.settingsPanel)
  else
    Msg("Settings panel is not available yet. Try again after the UI finishes loading.")
  end
end

function RallyGroup.SlashCommand(args)
  args = zo_strtrim(args or "")

  if args == "" then
    RallyGroup.Start(GetDefaultDistance(), GetDefaultAnchorName())
    return
  end

  local lower = string.lower(args)

  -- Evaluate settings before any command parsing that could treat it as an anchor name.
  if lower == "settings" then
    RallyGroup.OpenSettings()
    return
  end

  if lower == "off" then
    RallyGroup.Stop()
    return
  end

  if lower == "crown" then
    RallyGroup.Start(GetDefaultDistance(), "crown")
    return
  end

  local ignoreCommand = string.match(args, "^[Ii][Gg][Nn][Oo][Rr][Ee]%s+(.+)$")
  if ignoreCommand then
    ignoreCommand = zo_strtrim(ignoreCommand or "")
    local lowerIgnore = string.lower(ignoreCommand)

    if lowerIgnore == "clear" then
      RallyGroup.ignoredAccounts = {}
      RallyGroup.ignoredCharacters = {}
      RallyGroup.distanceHistory = {}

      Msg("Cleared all ignored accounts and characters for this session.")
      RallyGroup.Update()
      return
    end

    if lowerIgnore == "list" then
      local lines = {}

      for accountKey in pairs(RallyGroup.ignoredAccounts) do
        table.insert(lines, accountKey)
      end

      for characterKey in pairs(RallyGroup.ignoredCharacters) do
        table.insert(lines, characterKey)
      end

      table.sort(lines)

      if #lines == 0 then
        Msg("No ignored accounts or characters.")
      else
        Msg("Ignored this session: " .. table.concat(lines, ", "))
      end

      return
    end

    if string.sub(ignoreCommand, 1, 1) == "@" then
      local normalized = NormalizeAccountName(ignoreCommand)
      local key = GetAccountKey(normalized)

      if normalized and key then
        RallyGroup.ignoredAccounts[key] = true
        RallyGroup.distanceHistory[key] = nil

        Msg("Ignoring account " .. normalized .. " for this session.")
        RallyGroup.Update()
      else
        Msg("Use /rg ignore @accountname, /rg ignore charactername, /rg ignore list, or /rg ignore clear")
      end

      return
    end

    local matchingCharacterUnit = FindGroupUnitByCharacterName(ignoreCommand)

    if matchingCharacterUnit then
      local characterName = GetUnitName(matchingCharacterUnit) or ignoreCommand
      local characterKey = GetCharacterKey(characterName)

      RallyGroup.ignoredCharacters[characterKey] = true
      RallyGroup.distanceHistory[characterKey] = nil

      Msg("Ignoring character " .. characterName .. " for this session.")
      RallyGroup.Update()
      return
    end

    local matchingAccountUnit = FindGroupUnitByAccountName(ignoreCommand)

    if matchingAccountUnit then
      local normalized = NormalizeAccountName(ignoreCommand)
      local key = GetAccountKey(normalized)

      RallyGroup.ignoredAccounts[key] = true
      RallyGroup.distanceHistory[key] = nil

      Msg("Ignoring account " .. normalized .. " for this session.")
      RallyGroup.Update()
      return
    end

    local characterKey = GetCharacterKey(ignoreCommand)

    if characterKey then
      RallyGroup.ignoredCharacters[characterKey] = true
      RallyGroup.distanceHistory[characterKey] = nil

      Msg("Ignoring character " .. ignoreCommand .. " for this session.")
      RallyGroup.Update()
    else
      Msg("Use /rg ignore @accountname, /rg ignore charactername, /rg ignore list, or /rg ignore clear")
    end

    return
  end

  local first, second = string.match(args, "^(%S+)%s+(%S+)$")

  if first and second then
    local firstNumber = tonumber(first)
    local secondNumber = tonumber(second)

    if firstNumber and not secondNumber then
      RallyGroup.Start(firstNumber, second)
      return
    elseif secondNumber and not firstNumber then
      RallyGroup.Start(secondNumber, first)
      return
    else
      Msg(
        "Invalid command. Use /rg, /rg @name, /rg charactername, /rg 50, /rg crown 50, /rg 50 crown, /rg 50 @name, /rg @name 50, /rg ignore @name, /rg ignore charactername, /rg ignore list, /rg ignore clear, or /rg off")
      return
    end
  end

  local plainRadius = tonumber(args)

  if plainRadius then
    RallyGroup.Start(plainRadius, GetDefaultAnchorName())
    return
  end

  -- Single non-command argument is treated as an anchor name using the default radius.
  -- This allows /rg @accountname, /rg accountname, or /rg charactername.
  RallyGroup.Start(GetDefaultDistance(), args)
end

local function OnAddOnLoaded(event, addonName)
  if addonName ~= RallyGroup.name then return end

  EVENT_MANAGER:UnregisterForEvent(RallyGroup.name, EVENT_ADD_ON_LOADED)

  RallyGroup.saved = ZO_SavedVars:NewAccountWide(
    RallyGroup.savedVarsName,
    1,
    nil,
    DEFAULT_SETTINGS,
    GetWorldName()
  )

  RallyGroup.radius = GetDefaultDistance()

  CreateSettingsPanel()

  SLASH_COMMANDS["/rallygroup"] = RallyGroup.SlashCommand
  SLASH_COMMANDS["/rg"] = RallyGroup.SlashCommand

  CreateUI()

  Msg("Loaded. Use /rallygroup or /rg.")
end

EVENT_MANAGER:RegisterForEvent(
  RallyGroup.name,
  EVENT_ADD_ON_LOADED,
  OnAddOnLoaded
)
