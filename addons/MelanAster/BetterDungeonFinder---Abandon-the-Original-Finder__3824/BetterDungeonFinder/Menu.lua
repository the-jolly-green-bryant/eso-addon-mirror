----------------------------
local BAF = BetterDungonFinder
--Regular LibAddonMenu work
local LAM = LibAddonMenu2
----------------------------
--Tool Function
local BDSelect = ""
local DDSelect = ""

local function DungeonName(IsDlC)
  local Tep = {}
  if not IsDlC then
    for i = 1, #BAF.BaseDungeonInfo do
      Tep[i] = GetActivityName(BAF.BaseDungeonInfo[i][1])
    end
  else
    for i = 1, #BAF.DLCDungeonInfo do
      Tep[i] = GetActivityName(BAF.DLCDungeonInfo[i][1])
    end
  end
  return Tep
end

local RawBD = {unpack(BAF.BaseDungeonInfo)}
local RawDD = {unpack(BAF.DLCDungeonInfo)}
local function DungeonList(IsDLC)
  local String = ""
  if not IsDLC then
    for i = 1, #RawBD do
      String = String..GetActivityName(RawBD[BAF.savedVariables.BDSort[i]][1]).."\r\n"
    end
  else
    for i = 1, #RawDD do
      String = String..GetActivityName(RawDD[BAF.savedVariables.DDSort[i]][1]).."\r\n"
    end
  end
  return String
end

local function DungeonSwitch(IsDLC, IsDown)
  local String, Raw, Target
  if not IsDLC then
    String = BDSelect
    if String == "" then return end
    Raw = RawBD
    Target = BAF.savedVariables.BDSort
  else
    String = DDSelect
    if String == "" then return end
    Raw = RawDD
    Target = BAF.savedVariables.DDSort
  end
  local Num = 0
  local index = 0
  for i = 1, #Raw do
    if String == GetActivityName(Raw[i][1]) then 
      Num = i
      break
    end
  end
  for i = 1, #Target do
    if Num == Target[i] then
      index = i
      break
    end
  end
  if IsDown then
    if Target[index + 1] then
      Target[index], Target[index + 1] = Target[index + 1], Target[index]
    end
  else
    if Target[index - 1] then
      Target[index], Target[index - 1] = Target[index - 1], Target[index]
    end
  end
  return
end

local function DungeonNameSort(IsDLC)
  local Raw, Tep, Re
  if IsDLC then
    Raw = RawDD
  else
    Raw = RawBD
  end
  Tep = {}
  for i = 1, #Raw do
    table.insert(Tep, {["String"] = GetActivityName(Raw[i][1]), ["Index"] = i})
  end
  table.sort(Tep, function(a, b)
      return a.String < b.String
    end)
  Re = {}
  for i = 1, #Raw do
    Re[i] = Tep[i]["Index"]
  end
  return Re
end

local iconList = {
  "/esoui/art/icons/quest_strosmkai_open_treasure_chest.dds",
  "/esoui/art/icons/housing_alt_fur_treasurechest001.dds",
  "/esoui/art/icons/housing_bre_con_treasurechest001.dds",
  "/esoui/art/icons/rewardbox_imperialcity.dds",
  "/esoui/art/icons/smalljewelrybox.dds",
  "/esoui/art/icons/u36_scarabhostbox.dds",
  "/esoui/art/icons/antiquities_dwarven_puzzle_box_icon.dds",
  "/esoui/art/icons/delivery_box_001.dds",
  "/esoui/art/icons/event_jestersfestival_2016_gift_box.dds",
  "/esoui/art/icons/event_midyear_giftbox.dds",
  "/esoui/art/icons/gift_box_001.dds",
  "/esoui/art/icons/gift_box_002.dds",
  "/esoui/art/icons/gift_box_003.dds",
  "/esoui/art/icons/gift-box-ouroboros.dds",
}

local function Icon2Text(Table)
  local Tep = {}
  for i = 1, #Table do
    Tep[i] = "|t32:32:"..Table[i].."|t"
  end
  return Tep
end

local function GetActionDataFormName(actionName, bindingIndex)
  local layerIndex, categoryIndex, actionIndex =  GetActionIndicesFromName(actionName)
  local name, isRebindable, isHidden = GetActionInfo(layerIndex, categoryIndex, actionIndex)
  local localizedActionName = GetString(_G["SI_BINDING_NAME_" .. actionName])
  return {
    actionName = actionName,
    localizedActionName = localizedActionName,
    localizedActionNameNarration = GetString(_G["SI_SCREEN_NARRATION_BINDING_NAME_" .. actionName]),
    isRebindable = isRebindable,
    layerIndex = layerIndex,
    categoryIndex = categoryIndex,
    actionIndex = actionIndex,
    bindingIndex = bindingIndex,
  }
end

----------------------------
--Menu
function BAF.buildMenu()
  local panelData = {
    type = "panel",
    name = BAF.name,
    displayName = BAF.title,
    author = BAF.author,
    version = BAF.version,
	}
	LAM:RegisterAddonPanel(BAF.name.."_Options", panelData)

	local options = {
    --Button
    {
			type = "submenu",
			name = BAFLang_SI.SETTING_Trigger_Header,
      controls = {
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Trigger_Lock,
          tooltip = BAFLang_SI.SETTING_Trigger_Lock_Info,
          getFunc = function() return BAF.savedVariables.Button_Lock end,
          setFunc = function(value) 
            BAF.savedVariables.Button_Lock = value
            BAF.SettingUpdate()
          end,
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Trigger_Hide,
          tooltip = BAFLang_SI.SETTING_Trigger_Hide_Info,
          getFunc = function() return BAF.savedVariables.Button_Hide end,
          setFunc = function(value) 
            BAF.savedVariables.Button_Hide = value
            BAF.SettingUpdate()
          end,
        },
        {
          type = "header",
          name = GetString(SI_GAME_MENU_KEYBINDINGS),
        },
        {
          type = "button",
          name = GetString(SI_KEYBINDINGS_PRIMARY_HEADER),
          func = function() 
            ZO_Dialogs_ShowDialog("BINDINGS", GetActionDataFormName("BDF_OPEN", 1))
          end,
          width = "half",	
        },
        {
          type = "button",
          name = GetString(SI_KEYBINDINGS_SECONDARY_HEADER),
          func = function() 
            ZO_Dialogs_ShowDialog("BINDINGS", GetActionDataFormName("BDF_OPEN", 2))
          end,
          width = "half",	
        },
        {
          type = "button",
          name = GetString(SI_KEYBINDINGS_TERTIARY_HEADER),
          func = function() 
            ZO_Dialogs_ShowDialog("BINDINGS", GetActionDataFormName("BDF_OPEN", 3))
          end,
          width = "half",	
        },
        {
          type = "button",
          name = GetString(SI_KEYBINDINGS_QUATERNARY_HEADER),
          func = function() 
            ZO_Dialogs_ShowDialog("BINDINGS", GetActionDataFormName("BDF_OPEN", 4))
          end,
          width = "half",	
        },
      },
		},
    --UI
    {
      type = "submenu",
      name = GetString(SI_KEYBINDINGS_CATEGORY_USER_INTERFACE),
      controls = {
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Finder_Lock,
          tooltip = BAFLang_SI.SETTING_Finder_Lock_Info,
          getFunc = function() return BAF.savedVariables.Window_Lock end,
          setFunc = function(value) 
            BAF.savedVariables.Window_Lock = value
            BAF.SettingUpdate()
          end,
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Finder_Pure,
          tooltip = BAFLang_SI.SETTING_Finder_Pure_Info,
          getFunc = function() return BAF.savedVariables.Pure_Black end,
          setFunc = function(value) 
            BAF.savedVariables.Pure_Black = value
            BAF.SettingUpdate()
          end,
        },
        { 
          type = "divider",
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Finder_Title,
          tooltip = BAFLang_SI.SETTING_Finder_Title_Info,
          getFunc = function() return BAF.savedVariables.Window_Left end,
          setFunc = function(value) 
            BAF.savedVariables.Window_Left = value
          end,
        },
        {
          type = "slider",
          name = BAFLang_SI.SETTING_Finder_TitleV,
          getFunc = function() return BAF.savedVariables.Window_LeftV end,
          setFunc = function(var) BAF.savedVariables.Window_LeftV = var end,
          min = -50,
          max = 50,
          step = 0.5,
        },
        {
          type = "slider",
          name = BAFLang_SI.SETTING_Finder_Alpha_Low,
          getFunc = function() return BAF.savedVariables.AlphaLow end,
          setFunc = function(var) BAF.savedVariables.AlphaLow = var end,
          min = 0,
          max = 1,
          step = 0.05,
          width = "half",
          tooltip = SETTING_Finder_Alpha_Tooltip,
        },
        {
          type = "slider",
          name = BAFLang_SI.SETTING_Finder_Alpha_High,
          getFunc = function() return BAF.savedVariables.AlphaHigh end,
          setFunc = function(var) BAF.savedVariables.AlphaHigh = var end,
          min = 0,
          max = 1,
          step = 0.05,
          width = "half",
          tooltip = SETTING_Finder_Alpha_Tooltip,
        },
      },
    },
    {
      type = "divider",
    },
    --UDQ
    {
      type = "submenu",
      name = GetString(SI_QUESTTYPE15),
      controls = {
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Other_AutoUDQ,
          tooltip = BAFLang_SI.SETTING_Other_AutoUDQ_Info,
          getFunc = function() return BAF.savedVariables.AutoUDQ end,
          setFunc = function(value)
            BAF.savedVariables.AutoUDQ = value
          end,
        },
        {
          type = "slider",
          name = BAFLang_SI.SETTING_Other_AutoUDQ_Delay,
          getFunc = function() return BAF.savedVariables.UDQDelay end,
          setFunc = function(var) BAF.savedVariables.UDQDelay = var end,
          min = 50,
          max = 500,
          step = 10,
          width = "full",
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Other_AutoSwitchQuest,
          tooltip = BAFLang_SI.SETTING_Other_AutoSwitchQuest_Info,
          getFunc = function() return BAF.savedVariables.Auto_Switch end,
          setFunc = function(value)
            BAF.savedVariables.Auto_Switch = value
          end,
        },
        {
          type = "divider",
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Coffer_Helper,
          tooltip = BAFLang_SI.SETTING_Coffer_Helper_Tooltip,
          getFunc = function() return BAF.savedVariables.CofferHelper end,
          setFunc = function(value) 
            BAF.savedVariables.CofferHelper = value
          end,
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Hide_Shoudler_Count,
          tooltip = BAFLang_SI.SETTING_Hide_Shoudler_Count_Tooltip,
          getFunc = function() return BAF.savedVariables.Hide_Shoulder end,
          setFunc = function(value) 
            BAF.savedVariables.Hide_Shoulder = value
          end,
        },
      },
    },
    --Chest
    {
      type = "submenu",
			name = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES406),
      controls = {
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Other_MarkChests,
          tooltip = BAFLang_SI.SETTING_Other_MarkChests_Info,
          getFunc = function() return BAF.savedVariables.Mark_Chest end,
          setFunc = function(value)
            BAF.savedVariables.Mark_Chest = value
            BAF.MarkChests()
          end,
        },
        {
          type = "dropdown",
          name = GetString(SI_GUILD_RANK_ICONS_DIALOG_HEADER),
          choices = Icon2Text(iconList),
          choicesValues = iconList,
          getFunc = function() return BAF.savedVariables.Icon_Chest end,
          setFunc = function(value)
            BAF.savedVariables.Icon_Chest = value
            BAF.MarkChests()
          end,
        },
        {
          type = "slider",
          name = GetString(SI_INTERFACE_OPTIONS_TARGET_MARKER_SIZE),
          getFunc = function() return BAF.savedVariables.Size_Cheset end,
          setFunc = function(value)
            BAF.savedVariables.Size_Cheset = value
            BAF.MarkChests()
          end,
          min = 0,
          max = 1280,
          step = 16,
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Other_ShareChests,
          tooltip = BAFLang_SI.SETTING_Other_ShareChests_Info,
          getFunc = function() return BAF.savedVariables.Share_Chest end,
          setFunc = function(value)
            BAF.savedVariables.Share_Chest = value
          end,
        },
      },
    },
    --Others
    {
			type = "submenu",
			name = BAFLang_SI.SETTING_Other_Header,
      controls = {
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Other_DoubleCQTE,
          tooltip = BAFLang_SI.SETTING_Other_DoubleCQTE_Info,
          getFunc = function() return BAF.savedVariables.DoubleCQTE end,
          setFunc = function(value)
            BAF.savedVariables.DoubleCQTE = value
            BAF.DoubleCheckPTE()
          end,
        },
        {
          type = "divider",
        },
        {
          type = "slider",
          name = BAFLang_SI.SETTING_Other_AutoConfirm,
          getFunc = function() return BAF.savedVariables.AutoConfirm end,
          setFunc = function(var) BAF.savedVariables.AutoConfirm = var end,
          min = 0,
          max = 45,
          step = 3,
          warning = "0 = "..GetString(SI_DIALOG_CLOSE).."; 45 = "..GetString(SI_GAMEPAD_MARKET_FREE_TRIAL_TILE_TEXT),
        },
        {
          type = "checkbox",
          name = BAFLang_SI.SETTING_Other_BGSound,
          tooltip = BAFLang_SI.SETTING_Other_BGSound_Info,
          getFunc = function() return BAF.savedVariables.BGSound end,
          setFunc = function(value)
            BAF.savedVariables.BGSound = value
          end,
        },
        {
          type = "slider",
          name = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES103),
          getFunc = function() return BAF.savedVariables.AlertSound end,
          setFunc = function(var) BAF.savedVariables.AlertSound = var end,
          min = 0,
          max = 20,
          step = 1,
          width = "half",
          warning = "0 = "..GetString(SI_DIALOG_CLOSE)
        },
        {
          type = "button",
          name = "|t30:30:esoui/art/voip/gamepad/gp_voip_listening.dds|t",
          func = function()
            PlaySound(BAF.AlertSound[BAF.savedVariables.AlertSound])
          end,
          width = "half",	
        },
      },
		},
    --Sort
    {
      type = "divider",
    },
    {
			type = "description",
			title = BAFLang_SI.SETTING_Sort_Header,
      text = BAFLang_SI.SETTING_Sort_Header_Des,
    },
    {
		type = "submenu",
		name = BAFLang_SI.TITLE_BaseDungeon,
		controls = {
        {
          type = "dropdown",
          name = GetString(SI_CONSOLEACTIVITYTYPE1),
          choices = DungeonName(false),
          getFunc = function() return "" end,
          setFunc = function(var) BDSelect = var end,
          width = "full",
          warning = BAFLang_SI.WARNING_ReloadUI,
        },
        {
          type = "button",
          name = "↑",
          func = function() 
            DungeonSwitch(false, false)
            BAF_BDList.data.text = DungeonList(false)
            BAF_BDList:UpdateValue()
          end,
          width = "half",	
        },
        {
          type = "button",
          name = "↓",
          func = function() 
            DungeonSwitch(false, true)
            BAF_BDList.data.text = DungeonList(false)
            BAF_BDList:UpdateValue()
          end,
          width = "half",	
        },
        {
          type = "button",
          name = GetString(SI_GAMEPAD_BANK_SORT_ORDER_UP_TEXT),
          tooltip = BAFLang_SI.SETTING_Sort_AZ_Info,
          func = function() 
            BAF.savedVariables.BDSort = DungeonNameSort(false)
            BAF_BDList.data.text = DungeonList(false)
            BAF_BDList:UpdateValue()
          end,
          width = "half",	
        },
        {
          type = "button",
          name = GetString(SI_CHAT_CONFIG_RESET),
          func = function() 
            BAF.savedVariables.BDSort = {}
            for i = 1, #BAF.BaseDungeonInfo do
              if not BAF.savedVariables.BDSort[i] then
                BAF.savedVariables.BDSort[i] = i
              end
            end
            BAF_BDList.data.text = DungeonList(false)
            BAF_BDList:UpdateValue()
          end,
          width = "half",
          warning = BAFLang_SI.WARNING_ReloadUI,
        },
        {
          type = "description",
          text = DungeonList(false),
          reference = "BAF_BDList",
        },
      },
    },
  	{
		type = "submenu",
		name = BAFLang_SI.TITLE_DLCDungeon,
		controls = {
        {
          type = "dropdown",
          name = GetString(SI_CONSOLEACTIVITYTYPE1),
          choices = DungeonName(true),
          getFunc = function() return "" end,
          setFunc = function(var) DDSelect = var end,
          width = "full",
          warning = BAFLang_SI.WARNING_ReloadUI,
        },
        {
          type = "button",
          name = "↑",
          func = function() 
            DungeonSwitch(true, false)
            BAF_DDList.data.text = DungeonList(true)
            BAF_DDList:UpdateValue()
          end,
          width = "half",	
        },
        {
          type = "button",
          name = "↓",
          func = function() 
            DungeonSwitch(true, true)
            BAF_DDList.data.text = DungeonList(true)
            BAF_DDList:UpdateValue()
          end,
          width = "half",	
        },
        {
          type = "button",
          name = GetString(SI_GAMEPAD_BANK_SORT_ORDER_UP_TEXT),
          tooltip = BAFLang_SI.SETTING_Sort_AZ_Info,
          func = function() 
            BAF.savedVariables.DDSort = DungeonNameSort(true)
            BAF_DDList.data.text = DungeonList(true)
            BAF_DDList:UpdateValue()
          end,
          width = "half",	
        },
        {
          type = "button",
          name = GetString(SI_CHAT_CONFIG_RESET),
          func = function() 
            BAF.savedVariables.DDSort = {}
            for i = 1, #BAF.DLCDungeonInfo do
              if not BAF.savedVariables.DDSort[i] then
                BAF.savedVariables.DDSort[i] = i
              end
            end
            BAF_DDList.data.text = DungeonList(true)
            BAF_DDList:UpdateValue()
          end,
          width = "half",
          warning = BAFLang_SI.WARNING_ReloadUI,
        },
        {
          type = "description",
          text = DungeonList(true),
          reference = "BAF_DDList",
        },
      },
    },
	}
  BAF.SettingUpdate()
	LAM:RegisterOptionControls(BAF.name.."_Options", options)
end
----------------------------
--Restore saved setting
function BAF.SettingUpdate()
  BAFTopLevel:SetMovable(not BAF.savedVariables.Window_Lock)
  BAFTriggle_Button:SetMovable(not BAF.savedVariables.Button_Lock)
  BAFTriggle_Button:SetHidden(BAF.savedVariables.Button_Hide)
  BAFPureBlack:SetHidden(not BAF.savedVariables.Pure_Black)
end