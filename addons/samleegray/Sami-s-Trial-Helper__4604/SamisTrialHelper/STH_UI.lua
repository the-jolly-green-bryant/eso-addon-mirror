local STH = SamisTrialHelperAddon

STH.ui = STH.ui or {}

local ui = STH.ui
local util = STH.util
local SAMID = SamisTrialAddonsDebugHelpers

ui.playerButtons = {}
ui.activePlayerButtons = {}
ui.playerButtonCount = 0

function ui.init()
  SamisTrialHelperTLC:ClearAnchors()
  SamisTrialHelperTLC:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, STH.settings.offsetX,
    STH.settings.offsetY)

  -- Create background if it doesn't exist
  if not ui.background then
    local bg = WINDOW_MANAGER:CreateControl("SamisTrialHelperTLCBackground", SamisTrialHelperTLC, CT_TEXTURE)
    bg:SetDimensions(400, 100)
    bg:SetAnchor(TOPLEFT, SamisTrialHelperTLC, TOPLEFT, 0, 0)
    bg:SetDrawLevel(-1)
    ui.background = bg
  end

  -- Create title if it doesn't exist
  if not ui.title then
    local title = WINDOW_MANAGER:CreateControl("SamisTrialHelperTLCTitle", SamisTrialHelperTLC, CT_LABEL)
    title:SetFont("ZoFontWinH5")
    title:SetColor(1, 1, 1)
    title:SetText("Get yo Loot!")
    title:SetAnchor(TOP, SamisTrialHelperTLC, TOP, 0, 2)
    ui.title = title
  end

  -- Adjust label to position below title
  SamisTrialHelperTLCLabel:ClearAnchors()
  SamisTrialHelperTLCLabel:SetAnchor(TOPLEFT, SamisTrialHelperTLC, TOPLEFT, 8, 20)

  -- Set default text color
  local r, g, b = util.hexToRgb("#FFFFFF")
  SamisTrialHelperTLCLabel:SetColor(r, g, b)

  -- Set up the background
  local bg = ui.background
  local r, g, b = util.hexToRgb("#000000")
  bg:SetColor(r, g, b, 255)
  bg:SetHidden(false)

  ui.hide()
end

function ui.hide()
  SamisTrialHelperTLC:SetHidden(true)
end

function ui.show()
  SamisTrialHelperTLC:SetHidden(false)
end

function ui.createPlayerButtons(allDetails)
  ui.clearPlayerButtons()

  SAMID:Print("Creating player buttons for player(s).")

  local index = nil
  for _, details in pairs(allDetails) do
    index = index or 1
    ui.createPlayerButton(details, index)
    index = index + 1
  end

  if index then
    SAMID:Print("Created player button(s). %d", index)
    ui.show()
  end
end

function ui.createPlayerButton(playerDetails, rowIndex)
  local row = ui.activePlayerButtons[playerDetails.playerName]

  if not rowIndex then
    if row then
      rowIndex = row.rowIndex
    else
      local count = 0
      for _ in pairs(ui.activePlayerButtons) do count = count + 1 end
      rowIndex = count + 1
    end
  end

  if not row then
    row = table.remove(ui.playerButtons)
  end

  if not row then
    ui.playerButtonCount = ui.playerButtonCount + 1
    local controlName = "SamisTrialHelperTLCRow" .. tostring(ui.playerButtonCount)
    row = WINDOW_MANAGER:CreateControl(controlName, SamisTrialHelperTLC, CT_CONTROL)
    row:SetHeight(30)
    row:SetMouseEnabled(true)

    row.label = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.label:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.label:SetFont("ZoFontWinH5")

    row.closeButton = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.closeButton:SetAnchor(LEFT, row.label, RIGHT, 8, 0)
    row.closeButton:SetFont("ZoFontWinH5")
    row.closeButton:SetColor(1, 0.5, 0)
    row.closeButton:SetText("X")
    row.closeButton:SetMouseEnabled(true)
    row.closeButton:SetHandler("OnMouseUp", function(self, button)
      if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
      local parent = self:GetParent()
      if not parent.playerDetails then return end
      local details = parent.playerDetails
      STH:RemoveUncollectedItemRecord(details)
      ui.removePlayerButton(details.playerName)
    end)
    row.closeButton:SetHandler("OnMouseEnter", function(self)
      self:SetColor(1, 0, 0)
    end)
    row.closeButton:SetHandler("OnMouseExit", function(self)
      self:SetColor(1, 0.5, 0)
    end)

    row:SetHandler("OnMouseUp", function(self, button)
      if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
      if not self.playerDetails then return end

      local details = self.playerDetails

      STH:SendGroupMessage(details)
      ui.removePlayerButton(details.playerName)
      STH:RemoveUncollectedItemRecord(details)
    end)

    row:SetHandler("OnMouseEnter", function(self)
      self.label:SetColor(1, 0.85, 0)
    end)

    row:SetHandler("OnMouseExit", function(self)
      self.label:SetColor(1, 1, 1)
    end)
  end

  row.playerDetails = playerDetails
  row.label:SetText(playerDetails.playerName .. " has #" .. #playerDetails.itemLinks .. " items you need")
  row:SetWidth(row.label:GetTextWidth() + 50)
  row:ClearAnchors()
  row:SetAnchor(TOPLEFT, SamisTrialHelperTLC, TOPLEFT, 8, 20 + 30 * (rowIndex - 1))
  row:SetHidden(false)
  row.rowIndex = rowIndex

  ui.activePlayerButtons[playerDetails.playerName] = row
  ui.resizeBackground()
end

function ui.resizeBackground()
  local maxWidth = 0
  local count = 0
  for _, row in pairs(ui.activePlayerButtons) do
    local w = row:GetWidth()
    if w > maxWidth then maxWidth = w end
    count = count + 1
  end

  local bg = ui.background
  bg:SetWidth(maxWidth)
  bg:SetHeight(20 + 30 * count + 8)

  if ui.title then
    ui.title:ClearAnchors()
    ui.title:SetAnchor(TOP, bg, TOP, 0, 2)
  end
end

function ui.removePlayerButton(playerName)
  local row = ui.activePlayerButtons[playerName]
  if row then
    row:SetHidden(true)
    row:ClearAnchors()
    row.playerDetails = nil
    row.rowIndex = nil
    ui.activePlayerButtons[playerName] = nil
    table.insert(ui.playerButtons, row)

    if next(ui.activePlayerButtons) == nil then
      ui.hide()
    else
      ui.resizeBackground()
    end
  end
end

function ui.clearPlayerButtons()
  local hadActiveRows = next(ui.activePlayerButtons) ~= nil

  for playerName, row in pairs(ui.activePlayerButtons) do
    row:SetHidden(true)
    row:ClearAnchors()
    row.playerDetails = nil
    table.insert(ui.playerButtons, row)
  end

  ui.activePlayerButtons = {}

  if hadActiveRows then
    ui.hide()
  end
end

function ui.setText(text)
  SamisTrialHelperTLCLabel:SetText(text or "")

  -- Resize background to match label with padding
  local label = SamisTrialHelperTLCLabel
  local width = label:GetWidth()
  local height = label:GetHeight()

  if width == 0 or height == 0 then
    -- If dimensions are 0, use the control's set dimensions
    width = 200
    height = 100
  end

  -- Add padding: 8px left/right, 4px top/bottom
  width = width + 16
  height = height + 8

  local bg = ui.background
  bg:SetDimensions(width, height)

  -- Recenter title after resizing
  local title = ui.title
  if title then
    title:ClearAnchors()
    title:SetAnchor(TOP, ui.background, TOP, 0, 2)
  end
end

function STH.savePosition()
  STH.settings.offsetX = SamisTrialHelperTLC:GetLeft()
  STH.settings.offsetY = SamisTrialHelperTLC:GetTop()
end

-- function ui.updateBackgroundColor()
--   local bg = ui.background
--   if bg then
--     local r, g, b = util.hexToRgb(STH.settings.backgroundColor)
--     bg:SetColor(r, g, b, STH.settings.backgroundOpacity)
--   end
-- end

-- function ui.updateBackgroundOpacity()
--   local bg = ui.background
--   if bg then
--     local r, g, b = util.hexToRgb(STH.settings.backgroundColor)
--     bg:SetColor(r, g, b, STH.settings.backgroundOpacity)
--   end
-- end

-- function ui.updateTextColors()
--   -- Refresh the timers to apply any color changes
--   local r, g, b = util.hexToRgb(STH.settings.defaultTextColour)
--   SamisTrialHelperTLCLabel:SetColor(r, g, b)
--   STH.updateTimer()
-- end

-- function ui.updateTitleVisibility()
--   local title = ui.title
--   if title then
--     title:SetHidden(not STH.settings.showTitle)
--   end
-- end
