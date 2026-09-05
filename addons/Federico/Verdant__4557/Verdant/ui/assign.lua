Verdant = Verdant or {}
Verdant.Assign = {}
local M = Verdant.Assign

local api = Verdant.zenimax.api
local zui = Verdant.zenimax.ui
local zc  = Verdant.zenimax.constants
local Scene = Verdant.zenimax.scene
local GetString               = api.GetString
local GetAbilityName          = api.GetAbilityName
local WINDOW_MANAGER          = zui.WINDOW_MANAGER
local CreateControlFromVirtual = zui.CreateControlFromVirtual
local math_floor              = math.floor
local math_ceil               = math.ceil
local string_format           = string.format
local table_concat            = table.concat

local log = Verdant.Log.for_module("assign")

-- anchor / type constants
local TOPLEFT     = zc.TOPLEFT
local TOPRIGHT    = zc.TOPRIGHT
local BOTTOMRIGHT = zc.BOTTOMRIGHT
local LEFT        = zc.LEFT
local RIGHT       = zc.RIGHT
local CENTER      = zc.CENTER
local GuiRoot     = zc.GuiRoot
local CT_TEXTURE  = zc.CT_TEXTURE
local CT_LABEL    = zc.CT_LABEL
local CT_CONTROL  = zc.CT_CONTROL
local TEXT_ALIGN_LEFT   = zc.TEXT_ALIGN_LEFT
local TEXT_ALIGN_CENTER = zc.TEXT_ALIGN_CENTER

local SkillColors = Verdant.SkillColors
local function hex(c)
  return string_format("%02X%02X%02X",
    math_floor(c.r * 255 + 0.5), math_floor(c.g * 255 + 0.5), math_floor(c.b * 255 + 0.5))
end

local function colored_label(key)
  local c = SkillColors.group_color(key)
  return "|c" .. hex(c) .. SkillColors.group_label(key) .. "|r"
end


local ROW_H            = 30
local FALLBACK_MAXROWS = 8
local FLYOUT_PAD       = 6
local FLYOUT_ENTRY_H   = 16
local FLYOUT_COL_W     = 158
local FLYOUT_COLS      = 2
local PALETTE = {
  { r = 0.95, g = 0.30, b = 0.25 }, { r = 0.98, g = 0.60, b = 0.20 }, { r = 0.98, g = 0.85, b = 0.30 },
  { r = 0.60, g = 0.90, b = 0.25 }, { r = 0.25, g = 0.80, b = 0.45 }, { r = 0.20, g = 0.85, b = 0.80 },
  { r = 0.30, g = 0.65, b = 0.98 }, { r = 0.45, g = 0.45, b = 0.95 }, { r = 0.70, g = 0.40, b = 0.95 },
  { r = 0.95, g = 0.40, b = 0.80 }, { r = 0.80, g = 0.65, b = 0.45 }, { r = 0.92, g = 0.92, b = 0.90 },
}
local PlaySound = zui.PlaySound
local FILL_TEXTURE = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"


local controls  = {}
local row_pool
local active_id
local pending   = {}
local open_flyout_for
local assign_active
local fly_entries = {}
local scroll_off = 0
local newcat_for
local newcat_color = 1
local swatches = {}

local function row_factory(row, counter)
  local nm = "VerdantAssignRow" .. counter
  local icon = WINDOW_MANAGER:CreateControl(nm .. "Icon", row, CT_TEXTURE)
  icon:SetDimensions(24, 24)
  icon:SetAnchor(LEFT, row, LEFT, 2, 0)
  row.vm_icon = icon

  local pick = CreateControlFromVirtual(nm .. "Pick", row, "ZO_DefaultButton")
  pick:SetDimensions(130, 24)
  pick:SetAnchor(RIGHT, row, RIGHT, 0, 0)
  pick:SetHandler("OnClicked", function() open_flyout_for(row) end)
  pick:SetHandler("OnMouseWheel", function(_, delta) M.on_scroll(delta) end)
  row:SetMouseEnabled(true)
  row:SetHandler("OnMouseWheel", function(_, delta) M.on_scroll(delta) end)
  row.vm_pick = pick

  local name = WINDOW_MANAGER:CreateControl(nm .. "Name", row, CT_LABEL)
  name:SetFont("ZoFontGame")
  name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  name:SetAnchor(LEFT,  icon, RIGHT, 8, 0)
  name:SetAnchor(RIGHT, pick, LEFT, -8, 0)
  name:SetMaxLineCount(1)
  name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  name:SetColor(0.92, 0.92, 0.92, 1)
  row.vm_name = name
end

local function row_reset(row)
  row:SetHidden(true)
  row:ClearAnchors()
end

local function open_newcat()
  newcat_for = active_id
  active_id = nil
  controls.flyout:SetHidden(true)
  newcat_color = 1
  controls.newcat_edit:SetText("")
  for i = 1, #swatches do swatches[i].rim:SetHidden(i ~= newcat_color) end
  controls.newcat:SetHidden(false)
end

local function build_flyout()
  local fly    = controls.flyout
  local groups = SkillColors.groups_ordered()
  local n      = #groups + 1
  local rows_per_col = math_ceil(n / FLYOUT_COLS)

  for i = 1, n do
    local col = math_floor((i - 1) / rows_per_col)
    local r   = (i - 1) % rows_per_col
    local e = fly_entries[i]
    if not e then
      e = WINDOW_MANAGER:CreateControl("VerdantAssignFlyoutE" .. i, fly, CT_LABEL)
      e:SetDrawLayer(DL_OVERLAY)
      e:SetDrawLevel(103)
      e:SetFont("ZoFontGameSmall")
      e:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
      e:SetVerticalAlignment(TEXT_ALIGN_CENTER)
      e:SetDimensions(FLYOUT_COL_W, FLYOUT_ENTRY_H)
      e:SetMouseEnabled(true)
      fly_entries[i] = e
    end
    e:ClearAnchors()
    e:SetAnchor(TOPLEFT, fly, TOPLEFT, FLYOUT_PAD + col * FLYOUT_COL_W, FLYOUT_PAD + r * FLYOUT_ENTRY_H)
    e:SetHidden(false)
    if i <= #groups then
      local g = groups[i]
      local key = g.key
      local cr, cg, cb = g.r, g.g, g.b
      e:SetText(g.label)
      e:SetColor(cr, cg, cb, 1)
      e:SetHandler("OnMouseUp",    function() assign_active(key) end)
      e:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
      e:SetHandler("OnMouseExit",  function(self) self:SetColor(cr, cg, cb, 1) end)
    else
      e:SetText(GetString(VERDANT_ASSIGN_NEW))
      e:SetColor(0.85, 0.70, 0.36, 1)
      e:SetHandler("OnMouseUp",    function() PlaySound(SOUNDS.DIALOG_ACCEPT); open_newcat() end)
      e:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
      e:SetHandler("OnMouseExit",  function(self) self:SetColor(0.85, 0.70, 0.36, 1) end)
    end
  end
  for i = n + 1, #fly_entries do fly_entries[i]:SetHidden(true) end

  fly:SetDimensions(FLYOUT_PAD * 2 + FLYOUT_COLS * FLYOUT_COL_W,
                    FLYOUT_PAD * 2 + rows_per_col * FLYOUT_ENTRY_H)
end

local function build_swatches()
  local panel = controls.newcat
  for i = 1, #PALETTE do
    local c = PALETTE[i]
    local x = 10 + (i - 1) * 24
    local rim = WINDOW_MANAGER:CreateControl("VerdantAssignSwatchRim" .. i, panel, CT_TEXTURE)
    rim:SetTexture(FILL_TEXTURE)
    rim:SetTextureCoords(0, 1, 0, 0.05)
    rim:SetDimensions(22, 22)
    rim:SetAnchor(TOPLEFT, panel, TOPLEFT, x - 2, 38)
    rim:SetColor(1, 1, 1, 0.9)
    rim:SetHidden(i ~= 1)
    local sw = WINDOW_MANAGER:CreateControl("VerdantAssignSwatch" .. i, panel, CT_TEXTURE)
    sw:SetTexture(FILL_TEXTURE)
    sw:SetTextureCoords(0, 1, 0, 0.05)
    sw:SetDimensions(18, 18)
    sw:SetAnchor(TOPLEFT, panel, TOPLEFT, x, 40)
    sw:SetColor(c.r, c.g, c.b, 1)
    local hit = WINDOW_MANAGER:CreateControl("VerdantAssignSwatchHit" .. i, panel, CT_CONTROL)
    hit:SetDimensions(22, 22)
    hit:SetAnchor(TOPLEFT, panel, TOPLEFT, x - 2, 38)
    hit:SetMouseEnabled(true)
    local idx = i
    hit:SetHandler("OnMouseUp", function() M.on_newcat_swatch(idx) end)
    swatches[i] = { rim = rim, sw = sw, hit = hit }
  end
end

function M.on_newcat_swatch(i)
  if not PALETTE[i] then return end
  newcat_color = i
  for k = 1, #swatches do swatches[k].rim:SetHidden(k ~= i) end
  PlaySound(SOUNDS.DEFAULT_CLICK)
end

function M.on_newcat_create()
  local name = tostring(controls.newcat_edit:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  end
  local c   = PALETTE[newcat_color] or PALETTE[1]
  local key = SkillColors.custom_key(name)
  if not SkillColors.add_group(key, name, c.r, c.g, c.b) then
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    return
  end
  local sv = Verdant.SavedVars
  if sv then
    sv.custom_groups = sv.custom_groups or {}
    sv.custom_groups[key] = { label = name, r = c.r, g = c.g, b = c.b }
  end
  log:info("custom group", key, name)
  PlaySound(SOUNDS.DIALOG_ACCEPT)
  controls.newcat:SetHidden(true)
  build_flyout()
  if newcat_for then
    pending[newcat_for] = key
    newcat_for = nil
    M.refresh()
  end
end

function M.on_newcat_cancel()
  newcat_for = nil
  controls.newcat:SetHidden(true)
  PlaySound(SOUNDS.DIALOG_DECLINE)
end

function M.open_newcat_for_test(id)
  active_id = id
  open_newcat()
end

open_flyout_for = function(row)
  active_id = row.vm_id
  local fly = controls.flyout
  local btn = row.vm_pick
  fly:ClearAnchors()
  local _, screen_h = GuiRoot:GetDimensions()
  if btn:GetBottom() + fly:GetHeight() > screen_h then
    fly:SetAnchor(BOTTOMRIGHT, btn, TOPRIGHT, 0, -2)
  else
    fly:SetAnchor(TOPRIGHT, btn, BOTTOMRIGHT, 0, 2)
  end
  fly:SetHidden(false)
end

assign_active = function(key)
  local id = active_id
  controls.flyout:SetHidden(true)
  active_id = nil
  if not id then return end
  pending[id] = key
  M.refresh()
end

function M.refresh()
  row_pool:ReleaseAllObjects()
  controls.flyout:SetHidden(true)

  local unknowns = SkillColors.get_unknowns()
  controls.help:SetText("")
  if #unknowns == 0 then
    controls.empty:SetHidden(false)
    return
  end
  controls.empty:SetHidden(true)

  local list   = controls.list
  local lh      = list:GetHeight()
  local max_rows = (lh > 0) and math_floor(lh / ROW_H) or FALLBACK_MAXROWS

  local max_off = (#unknowns > max_rows) and (#unknowns - max_rows) or 0
  if scroll_off > max_off then scroll_off = max_off end
  if scroll_off < 0 then scroll_off = 0 end
  local shown = 0
  for i = 1, #unknowns do
    local slot = i - scroll_off
    if slot > max_rows then break end
    if slot >= 1 then
    local u   = unknowns[i]
    local row = row_pool:AcquireObject()
    row.vm_id = u.id
    if u.icon ~= "" then row.vm_icon:SetTexture(u.icon) end
    row.vm_icon:SetHidden(u.icon == "")
    row.vm_name:SetText(u.name)
    local chosen = pending[u.id]
    if chosen then
      row.vm_pick:SetText(colored_label(chosen))
    else
      row.vm_pick:SetText(GetString(VERDANT_ASSIGN_PICK))
    end
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT,  list, TOPLEFT,  0, (slot - 1) * ROW_H)
    row:SetAnchor(TOPRIGHT, list, TOPRIGHT, 0, (slot - 1) * ROW_H)
    row:SetHeight(ROW_H - 2)
    row:SetHidden(false)
    shown = shown + 1
    end
  end

  local rest = #unknowns - scroll_off - shown
  if rest > 0 or scroll_off > 0 then
    controls.help:SetText(string_format(GetString(VERDANT_ASSIGN_MORE), rest, scroll_off))
  end
end

function M.on_scroll(delta)
  local dir = (delta and delta < 0) and 1 or -1
  local before = scroll_off
  scroll_off = scroll_off + dir
  M.refresh()
  if scroll_off ~= before then PlaySound(SOUNDS.DEFAULT_CLICK) end
end

local CONFIRM_W       = 420
local CONFIRM_LINE_H  = 26
local CONFIRM_TOP_H   = 44
local CONFIRM_BTM_H   = 44
local CONFIRM_EXTRA   = 3

local function clear_pending()
  for id in pairs(pending) do pending[id] = nil end
end

local function pending_count()
  local n = 0
  for _ in pairs(pending) do n = n + 1 end
  return n
end

local function show_confirm()
  controls.flyout:SetHidden(true)

  local lines = {}
  for id, key in pairs(pending) do
    local name = GetAbilityName(id)
    if not name or name == "" then name = "#" .. id end
    lines[#lines + 1] = name .. "  \226\134\146  " .. colored_label(key)
  end
  table.sort(lines)

  controls.confirm_msg:SetText(table_concat(lines, "\n") .. "\n\n" .. GetString(VERDANT_ASSIGN_CONFIRM_NOTE))


  local h = CONFIRM_TOP_H + (#lines + CONFIRM_EXTRA) * CONFIRM_LINE_H + CONFIRM_BTM_H
  controls.confirm:SetDimensions(CONFIRM_W, h)

  controls.window:SetHidden(true)
  controls.confirm:SetHidden(false)
end

function M.show_reset_scroll()
  scroll_off = 0
end

function M.show()
  controls.confirm:SetHidden(true)
  clear_pending()
  Scene.show_top_level(controls.window)
  M.refresh()
end

function M.hide()
  controls.flyout:SetHidden(true)
  controls.confirm:SetHidden(true)
  clear_pending()
  Scene.hide_top_level(controls.window)
  row_pool:ReleaseAllObjects()
end

function M.toggle()
  if controls.window:IsHidden() then M.show() else M.hide() end
end

function M.on_close_click() M.hide() end

function M.on_assign_click()
  if pending_count() == 0 then
    M.hide()
  else
    show_confirm()
  end
end

function M.on_confirm_no()
  controls.confirm:SetHidden(true)
  controls.window:SetHidden(false)
  M.refresh()
end

function M.on_confirm_yes()
  local sv = Verdant.SavedVars
  for id, key in pairs(pending) do
    SkillColors.set_override(id, key)
    if sv then
      sv.skill_overrides = sv.skill_overrides or {}
      sv.skill_overrides[id] = key
    end
    log:info("committed", id, "->", key)
  end
  controls.confirm:SetHidden(true)
  M.hide()
end

function M.on_move_stop()
  controls.flyout:SetHidden(true)
  local sv = Verdant.SavedVars
  if not sv or not controls.window then return end
  sv.assign = sv.assign or {}
  sv.assign.x = controls.window:GetLeft()
  sv.assign.y = controls.window:GetTop()
end

-- ── init ────────────────────────────────────────────────────────────────────
function M.init()
  controls.window     = VerdantAssignPanel
  Scene.register_top_level(controls.window)
  controls.title      = VerdantAssignPanelWindowTitle
  controls.help       = VerdantAssignPanelHelpLabel
  controls.list       = VerdantAssignPanelList
  controls.empty      = VerdantAssignPanelListEmpty
  controls.assign_btn = VerdantAssignPanelAssignBtn
  controls.flyout     = VerdantAssignPanelFlyout
  controls.confirm       = VerdantAssignConfirm
  controls.confirm_title = VerdantAssignConfirmTitle
  controls.confirm_msg   = VerdantAssignConfirmMsg
  controls.confirm_yes   = VerdantAssignConfirmYesBtn
  controls.confirm_no    = VerdantAssignConfirmNoBtn
  controls.newcat        = VerdantAssignPanelNewCat
  controls.newcat_edit   = VerdantAssignPanelNewCatNameBoxEdit
  controls.newcat_create = VerdantAssignPanelNewCatCreateBtn
  controls.newcat_cancel = VerdantAssignPanelNewCatCancelBtn


  VerdantAssignPanelBg:SetCenterColor(0.62, 1.00, 0.74, 1.0)
  VerdantAssignPanelBg:SetEdgeColor(0.42, 1.00, 0.60, 1.0)

  VerdantAssignPanelFlyoutFill:SetTexture("EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds")
  VerdantAssignPanelFlyoutFill:SetTextureCoords(0, 1, 0, 0.05)
  VerdantAssignPanelFlyoutFill:SetColor(0.062, 0.058, 0.050, 0.985)
  VerdantAssignPanelFlyoutFill:SetDrawLayer(DL_OVERLAY)
  VerdantAssignPanelFlyoutFill:SetDrawLevel(101)
  VerdantAssignPanelFlyoutBg:SetCenterColor(0.075, 0.070, 0.062, 0.98)
  VerdantAssignPanelFlyoutBg:SetEdgeColor(0.42, 1.00, 0.60, 0.85)
  VerdantAssignPanelFlyoutBg:SetDrawLayer(DL_OVERLAY)
  VerdantAssignPanelFlyoutBg:SetDrawLevel(102)
  controls.flyout:SetDrawLevel(100)
  controls.confirm:SetDrawTier(DT_HIGH)
  VerdantAssignConfirmBg:SetCenterColor(0.62, 1.00, 0.74, 1.0)
  VerdantAssignConfirmBg:SetEdgeColor(0.42, 1.00, 0.60, 1.0)

  controls.title:SetText(GetString(VERDANT_ASSIGN_TITLE))
  controls.title:SetColor(0.75, 0.75, 0.75, 1)
  controls.help:SetColor(0.85, 0.70, 0.30, 1)
  controls.empty:SetText(GetString(VERDANT_ASSIGN_EMPTY))
  controls.empty:SetColor(0.45, 0.45, 0.45, 1)
  controls.empty:SetHidden(true)
  controls.assign_btn:SetText(GetString(VERDANT_ASSIGN_DONE))

  controls.confirm_title:SetText(GetString(VERDANT_ASSIGN_CONFIRM_TITLE))
  controls.confirm_title:SetColor(0.55, 0.85, 0.55, 1)
  controls.confirm_msg:SetColor(0.90, 0.90, 0.90, 1)
  controls.confirm_yes:SetText(GetString(VERDANT_ASSIGN_CONFIRM_YES))
  controls.confirm_no:SetText(GetString(VERDANT_ASSIGN_CONFIRM_NO))
  controls.confirm:SetHidden(true)

  row_pool = Verdant.lib.plot.Pool.new("VerdantAssignRowC", controls.list, CT_CONTROL, row_factory, row_reset)
  VerdantAssignPanelNewCatBg:SetCenterColor(0.075, 0.070, 0.062, 0.98)
  VerdantAssignPanelNewCatBg:SetEdgeColor(0.86, 0.70, 0.36, 0.85)
  VerdantAssignPanelNewCatTitle:SetText(GetString(VERDANT_ASSIGN_NEW_TITLE))
  VerdantAssignPanelNewCatTitle:SetColor(0.85, 0.70, 0.36, 1)
  controls.newcat_edit:SetDefaultText(GetString(VERDANT_ASSIGN_NEW_NAME))
  controls.newcat_create:SetText(GetString(VERDANT_ASSIGN_CREATE))
  controls.newcat_cancel:SetText(GetString(VERDANT_ASSIGN_CANCEL))
  controls.newcat:SetHidden(true)
  build_swatches()
  controls.list:SetMouseEnabled(true)
  controls.list:SetHandler("OnMouseWheel", function(_, delta) M.on_scroll(delta) end)
  zui.tooltip(controls.newcat_create, VERDANT_TIP_ASSIGN_CREATE)
  zui.tooltip(controls.newcat_cancel, VERDANT_TIP_ASSIGN_CANCEL)
  zui.tooltip(controls.assign_btn,    VERDANT_TIP_ASSIGN_DONE)
  zui.tooltip(controls.confirm_yes,   VERDANT_TIP_CONFIRM_YES)
  zui.tooltip(controls.confirm_no,    VERDANT_TIP_CONFIRM_NO)
  zui.tooltip(VerdantAssignPanelCloseBtn, VERDANT_TIP_CLOSE)
  build_flyout()

  local sv = Verdant.SavedVars
  sv.assign = sv.assign or {}
  controls.window:ClearAnchors()
  if sv.assign.x and sv.assign.y then
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.assign.x, sv.assign.y)
  else
    controls.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  end

  log:info("init: categories=", #SkillColors.groups_ordered())
end
