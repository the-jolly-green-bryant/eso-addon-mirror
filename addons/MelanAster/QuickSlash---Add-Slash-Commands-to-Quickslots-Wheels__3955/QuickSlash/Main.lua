--Name Space
QuickSlash = {}
local QS = QuickSlash

--Basic Info
QS.Name = "QuickSlash"
QS.Author = "@MelanAster"
QS.Version = "0.10"

--Setting
QS.Default = {
  CV = false,
  Command = {
    [HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {},
    [HOTBAR_CATEGORY_ALLY_WHEEL] = {},
    [HOTBAR_CATEGORY_MEMENTO_WHEEL] = {},
    [HOTBAR_CATEGORY_TOOL_WHEEL] = {},
    [HOTBAR_CATEGORY_EMOTE_WHEEL] = {},
  },
}

--[[ Structure

  [HOTBAR_CATEGORY_XX] = {
    [EntryIndex] = {
      name = "",
      icon = "",
      slash = "",
    },
    ...
  }
  
--]]

--When Loaded
local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= QS.Name then return end
	EVENT_MANAGER:UnregisterForEvent(QS.Name, EVENT_ADD_ON_LOADED)
  
  --Get Account/Character Setting
  QS.AV = ZO_SavedVars:NewAccountWide("QuickSlash_Vars", 1, nil, QS.Default, GetWorldName())
  QS.CV = ZO_SavedVars:NewCharacterIdSettings("QuickSlash_Vars", 1, nil, QS.Default, GetWorldName())
  QS.SwitchSV()
  
  --Hook Wheels
  QS.HookWheel()
  
  --Menu
  QS.BuildMenu()
end

--Account/Character Setting
function QS.SwitchSV()
  if QS.CV.CV then
    QS.SV = QS.CV
  else
    QS.SV = QS.AV
  end
end

function QS.HookWheel()
  --PC Part
  local Old = UTILITY_WHEEL_KEYBOARD.menu.AddEntry
  UTILITY_WHEEL_KEYBOARD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
    local Category = UTILITY_WHEEL_KEYBOARD:GetHotbarCategory()
    local Index = data.slotNum
    local New = QS.SV.Command[Category][Index]
    if New then
      Old(Self, New.name, New.icon, New.icon, function() QS.Execute(New.slash) end, {name = New.name, slotNum = Index})
    else
      Old(Self, name, inactiveIcon, activeIcon, callback, data)
    end
  end
  --GamePad Part
  UTILITY_WHEEL_GAMEPAD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
    local Category = UTILITY_WHEEL_GAMEPAD:GetHotbarCategory()
    local Index = data.slotNum
    local New = QS.SV.Command[Category][Index]
    if New then
      Old(Self, New.name, New.icon, New.icon, function() QS.Execute(New.slash) end, {name = New.name, slotNum = Index})
    else
      Old(Self, name, inactiveIcon, activeIcon, callback, data)
    end
  end
end

-- /script QuickSlash.Execute()
function QS.Execute(Text)
  --Pretreatment
  Text = tostring(Text)
  local Args = {}
  string.gsub(Text, "[^%s]+", function(tep) table.insert(Args, tep) end)
  local Command = Args[1]
  table.remove(Args, 1)

  --Not Slash Command
  if not Command then 
    d(QS.Lang.INVALID_SLASH)
    return false 
  end
  
  --Patch for script
  if Command:lower() == "/script" then
    code = string.gsub(Text, Command, "", 1)
    Args = {[1] = code}
  end

  --DoCommand
  local fn = SLASH_COMMANDS[Command]
  if fn then
    if Args[1] then fn(unpack(Args)) else fn("") end
    return true
  else
    d(QS.Lang.INVALID_SLASH)
    return false
  end
end

--Icon
QS.IconList = {
  "/esoui/art/crafting/alchemy_tabicon_reagent_up.dds",
  "/esoui/art/crafting/alchemy_tabicon_solvent_up.dds",
  "/esoui/art/crafting/blueprints_tabicon_up.dds",
  "/esoui/art/crafting/designs_tabicon_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_aspect_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_essence_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_potency_up.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_designs.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_fillet.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_improve.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_refine.dds",
  "/esoui/art/crafting/gamepad/gp_jewelry_tabicon_icon.dds",
  "/esoui/art/crafting/gamepad/gp_reconstruct_tabicon.dds",
  "/esoui/art/crafting/jewelryset_tabicon_icon_up.dds",
  "/esoui/art/crafting/patterns_tabicon_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_fish_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_furnishings_up.dds",
  "/esoui/art/crafting/retrait_tabicon_up.dds",
  "/esoui/art/crafting/smithing_tabicon_armorset_up.dds",
  "/esoui/art/crafting/smithing_tabicon_weaponset_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_equip_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_quests_up.dds",
  "/esoui/art/companion/keyboard/category_u30_companions_up.dds",
  "/esoui/art/collections/collections_categoryicon_unlocked_up.dds",
  "/esoui/art/collections/collections_tabicon_housing_up.dds",
  "/esoui/art/companion/keyboard/companion_character_up.dds",
  "/esoui/art/companion/keyboard/companion_skills_up.dds",
  "/esoui/art/companion/keyboard/companion_overview_up.dds",
  "/esoui/art/guildfinder/keyboard/guildbrowser_guildlist_additionalfilters_up.dds",
  "/esoui/art/help/help_tabicon_cs_up.dds",
  "/esoui/art/help/help_tabicon_tutorial_up.dds",
  "/esoui/art/lfg/lfg_any_up_64.dds",
  "/esoui/art/lfg/lfg_tank_up_64.dds",
  "/esoui/art/lfg/lfg_dps_up_64.dds",
  "/esoui/art/lfg/lfg_healer_up_64.dds",
  "/esoui/art/lfg/lfg_indexicon_alliancewar_up.dds",
  "/esoui/art/lfg/lfg_indexicon_trial_up.dds",
  "/esoui/art/lfg/lfg_indexicon_zonestories_up.dds",
  "/esoui/art/lfg/lfg_tabicon_grouptools_up.dds",
  "/esoui/art/mail/mail_tabicon_inbox_up.dds",
  "/esoui/art/market/keyboard/tabicon_crownstore_up.dds",
  "/esoui/art/market/keyboard/tabicon_daily_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_rawplating_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds",
  "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
}

function QS.Icon2Text(Table)
  local Tep = {}
  for i = 1, #Table do
    Tep[i] = "|t32:32:"..Table[i].."|t"
  end
  return Tep
end

--Menu Part
local LAM = LibAddonMenu2
function QS.BuildMenu()
  --Panel Part
  local panelData = {
    type = "panel",
    name = QS.Name,
    displayName = QS.Name,
    author = QS.Author,
    version = QS.Version,
    registerForRefresh = true,
	}
	LAM:RegisterAddonPanel(QS.Name.."_Options", panelData)
  
  --Option Part
  local Category, EntryIndex, Icon, IconCustom, Name, Slash, Status
  local Category2, EntryIndex2
  local options = {
    {
    type = "checkbox",
    name = QS.Lang.CHARACTER_SETTING,
    getFunc = function() return QS.CV.CV end,
    setFunc = function(var)
      QS.CV.CV = var
      QS.SwitchSV()
    end,
    width = "full",
    },
    --Create QuickSlot
    {
    type = "header",
    name = QS.Lang.CREATE_QUICKSLOT,
    },
    --Category
    {
    type = "dropdown",
    name = QS.Lang.WHEEL_CATEGORY,
    choices = {
      GetString(SI_HOTBARCATEGORY10),
      GetString(SI_HOTBARCATEGORY13),
      GetString(SI_HOTBARCATEGORY12),
      GetString(SI_HOTBARCATEGORY14),
      GetString(SI_HOTBARCATEGORY11),
    },
    choicesValues = {
      HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
      HOTBAR_CATEGORY_ALLY_WHEEL,
      HOTBAR_CATEGORY_MEMENTO_WHEEL,
      HOTBAR_CATEGORY_TOOL_WHEEL,
      HOTBAR_CATEGORY_EMOTE_WHEEL,
    },
    getFunc = function() return Category or HOTBAR_CATEGORY_QUICKSLOT_WHEEL end,
    setFunc = function(var) Category = var end,
    width = "half",
    },
    --Index
    {
    type = "dropdown",
    name = QS.Lang.WHEEL_SLOT,
    choices = {"1 - N", "2 - NW", "3 - W", "4 - SW", "5 - S", "6 - SE", "7 - E", "8 - NE"},
    choicesValues = {4, 3, 2, 1, 8, 7, 6, 5},
    getFunc = function() return EntryIndex or 4 end,
    setFunc = function(var) EntryIndex = var end,
    width = "half",
    },
    --Icon Select
    {
    type = "dropdown",
    name = QS.Lang.WHEEL_ICON,
    choices = QS.Icon2Text(QS.IconList),
    choicesValues = QS.IconList,
    getFunc = function() return Icon or QS.IconList[1] end,
    setFunc = function(var) Icon = var end,
    scrollable = true,
    width = "half",
    },
    --Icon Custom
    {
    type = "editbox",
    name = QS.Lang.WHEEL_ICON_CUSTOM,
    tooltip = QS.Lang.WHEEL_ICON_CUSTOM_TOOLTIP,
    getFunc = function() return IconCustom or "" end,
    setFunc = function(text) IconCustom = text end,
    isMultiline = false,
    width = "half",
    },
    --Name
    {
    type = "editbox",
    name = QS.Lang.WHEEL_NAME,
    getFunc = function() return Name or "" end,
    setFunc = function(text) Name = text end,
    isMultiline = false,
    width = "full",
    },
    --Slash
    {
    type = "editbox",
    name = QS.Lang.WHEEL_SLASH,
    tooltip = QS.Lang.WHEEL_SLASH_TOOLTIP,
    getFunc = function() return Slash or "" end,
    setFunc = function(text) Slash = text end,
    isMultiline = false,
    width = "full",
    },
    --Check
    {
    type = "button",
    name = QS.Lang.WHEEL_CHECK,
    tooltip = QS.Lang.WHEEL_CHECK_TOOLTIP,
    func = function()
      local Tep = zo_strmatch(Slash or "", "^(/%S+)%s?(.*)")
      if SLASH_COMMANDS[Tep] then
        Status = QS.Lang.STATUS_GOOD_COMMAND
      else
        Status = QS.Lang.STATUS_BAD_COMMAND
      end
    end,
    width = "half",
    },
    --Apply
    {
    type = "button",
    name = QS.Lang.WHEEL_APPLY,
    func = function()
      if not Name or Name == "" then
        Status = QS.Lang.STATUS_NO_NAME
      else
        local Tex
        if IconCustom and IconCustom ~= "" then
          Tex = IconCustom
        else
          if Icon and Icon ~= "" then
            Tex = Icon
          else
            Tex = QS.IconList[1]
          end
        end
        QS.SV.Command[Category or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex or 4] = {
          ["name"] = Name or "",
          ["icon"] = Tex,
          ["slash"] = Slash or "",
        }
        Icon, IconCustom, Name, Slash = nil, nil, nil, nil
        Status = QS.Lang.STATUS_ADDED
      end
    end,
    width = "half",
    },
    --Status
    {
		type = "description",
		title = function() return Status or " " end,
    text = QS.Lang.WHEEL_INFO
    },
    {
    type = "header",
    name = QS.Lang.WHEEL_DESC,
    },
    {
    --Description
		type = "description",
    text = function()
      local Positons = {"1 - N    ", "2 - NW", "3 - W   ", "4 - SW", "5 - S    ", "6 - SE  ", "7 - E    ", "8 - NE "}
      local Order = {4, 3, 2, 1, 8, 7, 6, 5}
      local Part = function(Index)
        local StringList = {SI_HOTBARCATEGORY10, SI_HOTBARCATEGORY11, SI_HOTBARCATEGORY12, SI_HOTBARCATEGORY13, SI_HOTBARCATEGORY14}
        local Tep = GetString(StringList[Index - 9]).."\r\n  "
        if QS.SV.Command[Index] then
          for k, v in ipairs(Order) do
            local Content = QS.SV.Command[Index][v]
            if Content then
              Tep = Tep..Positons[k].."  |t16:16:"..Content.icon.."|t  "..Content.name.." |c778899( "..Content.slash.." )|r\r\n  "
            end
          end
        end
        return Tep.."\r\n"
      end
      return table.concat({
        Part(HOTBAR_CATEGORY_QUICKSLOT_WHEEL), 
        Part(HOTBAR_CATEGORY_ALLY_WHEEL), 
        Part(HOTBAR_CATEGORY_MEMENTO_WHEEL), 
        Part(HOTBAR_CATEGORY_TOOL_WHEEL), 
        Part(HOTBAR_CATEGORY_EMOTE_WHEEL)
      })
    end,
    },
    {
    type = "header",
    name = QS.Lang.WHEEL_EDIT,
    },
    --Category
    {
    type = "dropdown",
    name = QS.Lang.WHEEL_CATEGORY,
    choices = {
      GetString(SI_HOTBARCATEGORY10),
      GetString(SI_HOTBARCATEGORY13),
      GetString(SI_HOTBARCATEGORY12),
      GetString(SI_HOTBARCATEGORY14),
      GetString(SI_HOTBARCATEGORY11),
    },
    choicesValues = {
      HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
      HOTBAR_CATEGORY_ALLY_WHEEL,
      HOTBAR_CATEGORY_MEMENTO_WHEEL,
      HOTBAR_CATEGORY_TOOL_WHEEL,
      HOTBAR_CATEGORY_EMOTE_WHEEL,
    },
    getFunc = function() return Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL end,
    setFunc = function(var) Category2 = var end,
    width = "half",
    },
    --Index
    {
    type = "dropdown",
    name = QS.Lang.WHEEL_SLOT,
    choices = {"1 - N", "2 - NW", "3 - W", "4 - SW", "5 - S", "6 - SE", "7 - E", "8 - NE"},
    choicesValues = {4, 3, 2, 1, 8, 7, 6, 5},
    getFunc = function() return EntryIndex2 or 4 end,
    setFunc = function(var) EntryIndex2 = var end,
    width = "half",
    },
    --Empty
    {
    type = "button",
    name = QS.Lang.WHEEL_EMPTY,
    func = function()
      QS.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {}
    end,
    width = "half",
    },
    --Delete
    {
    type = "button",
    name = QS.Lang.WHEEL_DELETE,
    func = function()
      QS.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex2 or 4] = nil
    end,
    width = "half",
    },
  }
  LAM:RegisterOptionControls(QS.Name.."_Options", options)
end

-- Start Here
EVENT_MANAGER:RegisterForEvent(QS.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)