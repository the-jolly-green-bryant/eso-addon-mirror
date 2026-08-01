local WG = SDC_WareGuild
local LAM = LibAddonMenu2

---------------------
----Tool Function----
---------------------
local GuildD1A, GuildD1B, GuildD2A, GuildD2B, GuildD3A, GuildD3B, GuildD4A, GuildD4B, GuildD5A, GuildD5B
local GuildFuzzy1, GuildFuzzy2, GuildFuzzy3, GuildFuzzy4, GuildFuzzy5 = false, false, false, false, false
local GuildS1A, GuildS1B, GuildS2A, GuildS2B, GuildS3A, GuildS3B, GuildS4A, GuildS4B, GuildS5A, GuildS5B = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
local GuildS1C, GuildS2C, GuildS3C, GuildS4C, GuildS5C = 1, 1, 1, 1, 1
local ClipGuild, ClipSteps = false, {}
local MaterialChoices = {
  "/", 
  WG.Lang.BLACKSMITH, 
  WG.Lang.CLOTH, 
  WG.Lang.WOOD, 
  WG.Lang.JEWELRY, 
  WG.Lang.COOK, 
  WG.Lang.ENCHANT, 
  WG.Lang.ALCHEMY, 
  WG.Lang.STYLE, 
  WG.Lang.TRAIT,
}
local MaterialChoicesValue = {
  "/", 
  WAREGUILD_STORE_B,
  WAREGUILD_STORE_C,
  WAREGUILD_STORE_W,
  WAREGUILD_STORE_J,
  WAREGUILD_STORE_P,
  WAREGUILD_STORE_E,
  WAREGUILD_STORE_A,
  WAREGUILD_STORE_S,
  WAREGUILD_STORE_T,
}

--List of Guilds
local function GuildList()
  local Name = {"/", }
  local Id = {false, }
  for i = 1, 5 do
    local Tep = GetGuildId(i)
    if Tep ~= 0 then
      table.insert(Id, Tep)
      table.insert(Name, GetGuildName(Tep))
    end
  end
  return Name, Id
end

--List of Items
local function ItemList()
  local Link = {"/", }
  local Repeat = {}
  local Sort = {}
  for i = 0, GetBagSize(1) do
    local Tep = GetItemLink(1, i)
    if Tep ~= "" then
      if not Repeat[Tep] then
        table.insert(Sort, {Tep, GetItemLinkItemId(Tep)})
        Repeat[Tep] = true
      end
    end
  end
  table.sort(Sort, 
    function(a, b)
      return a[2] < b[2]
    end
  )
  for i = 1, #Sort do
    table.insert(Link, Sort[i][1])
  end
  return Link
end

--Display of Rules
local function Desc(RuleTable)
  local String = ""
  for i = 1, #RuleTable do
    String = String..string.format("%03d", i).." "..WG.StepToString(RuleTable[i]).."\r\n"
  end
  return String
end

--Copy Steps
local function CopySteps(GuildId, StepsTable)
  local Tep = {}
  for i = 1, #StepsTable do
    local Step = {
        ["GuildId"] = GuildId,
        ["Type"] = StepsTable[i]["Type"],
        ["ItemId"] = StepsTable[i]["ItemId"],
        ["ItemLink"] = StepsTable[i]["ItemLink"],
        ["Count"] = StepsTable[i]["Count"],
      }
    table.insert(Tep, Step)
  end
  return Tep
end

------------
----Menu----
------------

function WG.BuildMenu()
  local panelData = {
    type = "panel",
    name = WG.name,
    displayName = WG.title,
    author = WG.author,
    version = WG.version,
    registerForRefresh = true,
	}
	LAM:RegisterAddonPanel(WG.name.."_Options", panelData)
  local options = {
    { --Account/Character setting
		type = "checkbox",
		name = WG.Lang.SETTING_CHARACTER_CONFIG,
    tooltip = WG.Lang.SETTING_CHARACTER_CONFIG_TOOLTIP,
		getFunc = function() return WG.CV.CV end,
		setFunc = function(var)
      WG.CV.CV = var
      WG.SwitchSV()
    end,
    width = "full",
    },
  --Setting
    {
    type = "header",
    name = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1305),
		},
    { --Auto Open When Need Store
		type = "checkbox",
		name = WG.Lang.SETTING_AUTO_OPEN_STORE,
    tooltip = WG.Lang.SETTING_AUTO_OPEN_STORE_TOOLTIP,
		getFunc = function() return WG.SV.AutoOpen end,
		setFunc = function(var) WG.SV.AutoOpen = var end,
    width = "full",
    },
    { --Auto Open When Daily Writs
		type = "checkbox",
		name = WG.Lang.SETTING_AUTO_OPEN_WRITS,
    tooltip = WG.Lang.SETTING_AUTO_OPEN_WRITS_TOOLTIP,
		getFunc = function() return WG.SV.ForceOpen end,
		setFunc = function(var) WG.SV.ForceOpen = var end,
    width = "full",
    },
    { --Auto Close
		type = "checkbox",
		name = WG.Lang.SETTING_AUTO_CLOSE,
    tooltip = WG.Lang.SETTING_AUTO_CLOSE_TOOLTIP,
		getFunc = function() return WG.SV.AutoClose end,
		setFunc = function(var) WG.SV.AutoClose = var end,
    width = "full",
    },
    { --Display Log
		type = "checkbox",
		name = WG.Lang.SETTING_STEPS_LOG,
    tooltip = WG.Lang.SETTING_STEPS_LOG_TOOLTIP,
		getFunc = function() return WG.SV.Log end,
		setFunc = function(var) WG.SV.Log = var end,
    width = "full",
    },
    {
    type = "divider",
    alpha = 0.2,
    },
    { --KeepCraft
		type = "checkbox",
		name = WG.Lang.SETTING_BAN_STORE_WRITS,
    tooltip = WG.Lang.SETTING_BAN_STORE_WRITS_TOOLTIP,
		getFunc = function() return WG.SV.KeepCraft end,
		setFunc = function(var) WG.SV.KeepCraft = var end,
    width = "full",
    },
    { --Ignore Inventory
		type = "checkbox",
		name = WG.Lang.SETTING_IGNORE_INVENTORY,
    tooltip = WG.Lang.SETTING_IGNORE_INVENTORY_TOOLTIP,
		getFunc = function() return WG.SV.IgnoreInventory end,
		setFunc = function(var) WG.SV.IgnoreInventory = var end,
    width = "full",
    },
    {
    type = "divider",
    alpha = 0.2,
    },
    { --Not enough to take
		type = "checkbox",
		name = WG.Lang.SETTING_NE_TAKE,
    tooltip = WG.Lang.SETTING_NE_TAKE_TOOLTIP,
		getFunc = function() return WG.SV.NE_Take end,
		setFunc = function(var) WG.SV.NE_Take = var end,
    width = "full",
    },
    { --Not enough to store
		type = "checkbox",
		name = WG.Lang.SETTING_NE_STORE,
    tooltip = WG.Lang.SETTING_NE_STORE_TOOLTIP,
		getFunc = function() return WG.SV.NE_Store end,
		setFunc = function(var) WG.SV.NE_Store = var end,
    width = "full",
    },
    {
    type = "divider",
    alpha = 0.2,
    },
    {
    type = "checkbox",
		name = WG.Lang.SETTING_IGNORE_FCOIS,
    tooltip = WG.Lang.SETTING_IGNORE_FCOIS_TOOLTIP,
		getFunc = function() return WG.SV.IgnoreFCOIS end,
		setFunc = function(var) WG.SV.IgnoreFCOIS = var end,
    width = "full",
    },
  --Guild Bank
    {
    type = "header",
    name = WG.Lang.SETTING_HEADER_SELECT_GUILD,
		},
    {
		type = "description",
		title = WG.Lang.SETTING_GUILD_TIPS,
    },
    { --Guild 1
    type = "dropdown",
    name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 1",
    choices = GuildList(),
    choicesValues = select(2, GuildList()),
    scrollable = true,
    getFunc = function() if WG.SV.Guild[1] then return WG.SV.Guild[1] else return false end end,
    setFunc = function(var)
      if WG.SV.Guild[1] ~= var then
        WG.SV.Guild[1] = var
        WG.SV.Guild1 = {}
      end
    end,
    width = "full",
    },
    { --Guild 2
    type = "dropdown",
    name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 2", 
    choices = GuildList(),
    choicesValues = select(2, GuildList()),
    scrollable = true,
    getFunc = function() if WG.SV.Guild[2] then return WG.SV.Guild[2] else return false end end,
    setFunc = function(var)
      if WG.SV.Guild[2] ~= var then
        WG.SV.Guild[2] = var
        WG.SV.Guild2 = {}
      end
    end,
    width = "full",
    },
    { --Guild 3
    type = "dropdown",
    name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 3", 
    choices = GuildList(),
    choicesValues = select(2, GuildList()),
    scrollable = true,
    getFunc = function() if WG.SV.Guild[3] then return WG.SV.Guild[3] else return false end end,
    setFunc = function(var)
      if WG.SV.Guild[3] ~= var then
        WG.SV.Guild[3] = var
        WG.SV.Guild3 = {}
      end
    end,
    width = "full",
    },
    { --Guild 4
    type = "dropdown",
    name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 4", 
    choices = GuildList(),
    choicesValues = select(2, GuildList()),
    scrollable = true,
    getFunc = function() if WG.SV.Guild[4] then return WG.SV.Guild[4] else return false end end,
    setFunc = function(var)
      if WG.SV.Guild[4] ~= var then
        WG.SV.Guild[4] = var
        WG.SV.Guild4 = {}
      end
    end,
    width = "full",
    },
    { --Guild 5
    type = "dropdown",
    name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 5", 
    choices = GuildList(),
    choicesValues = select(2, GuildList()),
    scrollable = true,
    getFunc = function() if WG.SV.Guild[5] then return WG.SV.Guild[5] else return false end end,
    setFunc = function(var)
      if WG.SV.Guild[5] ~= var then
        WG.SV.Guild[5] = var
        WG.SV.Guild5 = {}
      end
    end,
    width = "full",
    },
    
    { --Guild Rule 1
    type = "submenu",
		name = function() return GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 1 > "..GetGuildName(WG.SV.Guild[1] or 0) end,
    disabled = function() if WG.SV.Guild[1] then return false else return true end end,
		controls = {
        { --Item Scroll
        type = "dropdown",
        name = WG.Lang.GUILD_ITEM_SCROLL, 
        choices = ItemList(),
        scrollable = true,
        getFunc = function() if GuildD1A then return GuildD1A else return "/" end end,
        setFunc = function(var) 
          if var ~= "/" then 
            GuildD1A = var
          else 
            GuildD1A = nil
          end
        end,
        reference = "WG_Guild_1_Item",
        width = "full",
        },
        { --Fuzzy
        type = "checkbox",
        name = WG.Lang.GUILD_FUZZY,
        tooltip = WG.Lang.GUILD_FUZZY_TOOLTIP,
        getFunc = function() return GuildFuzzy1 end,
        setFunc = function(var) GuildFuzzy1 = var end,
        width = "half",
        },
        { --UpdateList
        type = "button",
        name = WG.Lang.GUILD_UPDATE_ITEM_LIST,
        func = function()
          GuildD1A = nil
          WG_Guild_1_Item.data.choices = ItemList()
          WG_Guild_1_Item:UpdateChoices()
        end,
        width = "half",	
        },
        { --Withdraw all
        type = "button",
        name = WG.Lang.GUILD_TAKE_ALL,
        func = function()
          if not GuildD1A then return end
          if GuildFuzzy1 then
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD1A)})
          else
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemLink"] = GuildD1A})
          end
        end,
        width = "half",	
        },
        { --Store All
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL,
        func = function()
          if not GuildD1A then return end
          if GuildFuzzy1 then
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_STORE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD1A)})
          else
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_STORE_ALL, ["ItemLink"] = GuildD1A})
          end
        end,
        width = "half",	
        },
        { --TakeTo
        type = "slider",
        name = WG.Lang.GUILD_TAKE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS1A = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_TAKE_TO,
        func = function()
          if not GuildD1A then return end
          if GuildFuzzy1 then
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS1A, ["ItemId"] = GetItemLinkItemId(GuildD1A)})
          else
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS1A, ["ItemLink"] = GuildD1A})
          end
        end,
        width = "half",	
        },
        { --StoreTo
        type = "slider",
        name = WG.Lang.GUILD_STORE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS1B = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_TO,
        func = function()
          if not GuildD1A then return end
          if GuildFuzzy1 then
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS1B, ["ItemId"] = GetItemLinkItemId(GuildD1A)})
          else
            table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS1B, ["ItemLink"] = GuildD1A})
          end
        end,
        width = "half",	
        },
        {
        type = "header",
        name = GetString(SI_FURNITURETHEMETYPE1),
        },
        { --Store Craft Materials
        type = "dropdown",
        name = WG.Lang.GUILD_STORE_ALL_TYPE_DROP,
        choices = MaterialChoices,
        choicesValues = MaterialChoicesValue,
        scrollable = true,
        getFunc = function() return "/" end,
        setFunc = function(var) 
          if var ~= "/" then
            GuildD1B = var
          else
            GuildD1B = nil
          end
        end,
        width = "full",
        },
        { --Withdraw for Daily Writs
        type = "button",
        name = WG.Lang.GUILD_TAKE_WRITS,
        tooltip = WG.Lang.GUILD_TAKE_WRITS_TOOLTIP,
        func = function()
          table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = WAREGUILD_DAILY})
        end,
        width = "half",	
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL_TYPE,
        func = function()
          if not GuildD1B then return end
          table.insert(WG.SV.Guild1, {["GuildId"] = WG.SV.Guild[1], ["Type"] = GuildD1B})
        end,
        width = "half",	
        },
        {
        type = "header",
        name = WG.Lang.GUILD_HEADER_STEPS,
        },
        { --Rules Display
        type = "description",
        title = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 1 > ",
        text = function() return Desc(WG.SV.Guild1) end,
        width = "full",
        enableLinks = true,
        },
        { --Which Line
        type = "slider",
        name = WG.Lang.GUILD_STEPS_SLIDER,
        getFunc = function() return 1 end,
        setFunc = function(var) GuildS1C = var end,
        min = 1,
        max = 1000,
        step = 1,
        width = "full",
        },
        { --Empty Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_EMPTY,
        func = function()
          WG.SV.Guild1 = {}
        end,
        width = "half",	
        },
        { --Delete Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_DELETE,
        func = function()
          table.remove(WG.SV.Guild1, GuildS1C)
        end,
        width = "half",	
        },
      },
    },
    { --Guild Rule 2
    type = "submenu",
		name = function() return GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 2 > "..GetGuildName(WG.SV.Guild[2] or 0) end,
    disabled = function() if WG.SV.Guild[2] then return false else return true end end,
		controls = {
        { --Item Scroll
        type = "dropdown",
        name = WG.Lang.GUILD_ITEM_SCROLL, 
        choices = ItemList(),
        scrollable = true,
        getFunc = function() if GuildD2A then return GuildD2A else return "/" end end,
        setFunc = function(var) 
          if var ~= "/" then 
            GuildD2A = var
          else 
            GuildD2A = nil
          end
        end,
        reference = "WG_Guild_2_Item",
        width = "full",
        },
        { --Fuzzy
        type = "checkbox",
        name = WG.Lang.GUILD_FUZZY,
        tooltip = WG.Lang.GUILD_FUZZY_TOOLTIP,
        getFunc = function() return GuildFuzzy2 end,
        setFunc = function(var) GuildFuzzy2 = var end,
        width = "half",
        },
        { --UpdateList
        type = "button",
        name = WG.Lang.GUILD_UPDATE_ITEM_LIST,
        func = function()
          GuildD2A = nil
          WG_Guild_2_Item.data.choices = ItemList()
          WG_Guild_2_Item:UpdateChoices()
        end,
        width = "half",	
        },
        { --Withdraw all
        type = "button",
        name = WG.Lang.GUILD_TAKE_ALL,
        func = function()
          if not GuildD2A then return end
          if GuildFuzzy2 then
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD2A)})
          else
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemLink"] = GuildD2A})
          end
        end,
        width = "half",
        },
        { --Store All
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL,
        func = function()
          if not GuildD2A then return end
          if GuildFuzzy2 then
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_STORE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD2A)})
          else
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_STORE_ALL, ["ItemLink"] = GuildD2A})
          end
        end,
        width = "half",	
        },
        { --TakeTo
        type = "slider",
        name = WG.Lang.GUILD_TAKE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS2A = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_TAKE_TO,
        func = function()
          if not GuildD2A then return end
          if GuildFuzzy2 then
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS2A, ["ItemId"] = GetItemLinkItemId(GuildD2A)})
          else
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS2A, ["ItemLink"] = GuildD2A})
          end
        end,
        width = "half",	
        },
        { --StoreTo
        type = "slider",
        name = WG.Lang.GUILD_STORE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS2B = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_TO,
        func = function()
          if not GuildD2A then return end
          if GuildFuzzy2 then
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS2B, ["ItemId"] = GetItemLinkItemId(GuildD2A)})
          else
            table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS2B, ["ItemLink"] = GuildD2A})
          end
        end,
        width = "half",	
        },
        {
        type = "header",
        name = GetString(SI_FURNITURETHEMETYPE1),
        },
        { --Store Craft Materials
        type = "dropdown",
        name = WG.Lang.GUILD_STORE_ALL_TYPE_DROP, 
        choices = MaterialChoices,
        choicesValues = MaterialChoicesValue,
        scrollable = true,
        getFunc = function() return "/" end,
        setFunc = function(var) 
          if var ~= "/" then
            GuildD2B = var
          else
            GuildD2B = nil
          end
        end,
        width = "full",
        },
        { --Withdraw for Daily Writs
        type = "button",
        name = WG.Lang.GUILD_TAKE_WRITS,
        tooltip = WG.Lang.GUILD_TAKE_WRITS_TOOLTIP,
        func = function()
          table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = WAREGUILD_DAILY})
        end,
        width = "half",	
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL_TYPE,
        func = function()
          if not GuildD2B then return end
          table.insert(WG.SV.Guild2, {["GuildId"] = WG.SV.Guild[2], ["Type"] = GuildD2B})
        end,
        width = "half",	
        },
        {
        type = "header",
        name = WG.Lang.GUILD_HEADER_STEPS,
        },
        { --Rules Display
        type = "description",
        title = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 2 > ",
        text = function() return Desc(WG.SV.Guild2) end,
        width = "full",
        enableLinks = true,
        },
        { --Which Line
        type = "slider",
        name = WG.Lang.GUILD_STEPS_SLIDER,
        getFunc = function() return 1 end,
        setFunc = function(var) GuildS2C = var end,
        min = 1,
        max = 1000,
        step = 1,
        width = "full",
        },
        { --Empty Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_EMPTY,
        func = function()
          WG.SV.Guild2 = {}
        end,
        width = "half",	
        },
        { --Delete Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_DELETE,
        func = function()
          table.remove(WG.SV.Guild2, GuildS2C)
        end,
        width = "half",	
        },
      },
    },
    { --Guild Rule 3
    type = "submenu",
		name = function() return GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 3 > "..GetGuildName(WG.SV.Guild[3] or 0) end,
    disabled = function() if WG.SV.Guild[3] then return false else return true end end,
		controls = {
        { --Item Scroll
        type = "dropdown",
        name = WG.Lang.GUILD_ITEM_SCROLL,
        choices = ItemList(),
        scrollable = true,
        getFunc = function() if GuildD3A then return GuildD3A else return "/" end end,
        setFunc = function(var) 
          if var ~= "/" then 
            GuildD3A = var
          else 
            GuildD3A = nil
          end
        end,
        reference = "WG_Guild_3_Item",
        width = "full",
        },
        { --Fuzzy
        type = "checkbox",
        name = WG.Lang.GUILD_FUZZY,
        tooltip = WG.Lang.GUILD_FUZZY_TOOLTIP,
        getFunc = function() return GuildFuzzy3 end,
        setFunc = function(var) GuildFuzzy3 = var end,
        width = "half",
        },
        { --UpdateList
        type = "button",
        name = WG.Lang.GUILD_UPDATE_ITEM_LIST,
        func = function()
          GuildD3A = nil
          WG_Guild_3_Item.data.choices = ItemList()
          WG_Guild_3_Item:UpdateChoices()
        end,
        width = "half",	
        },
        { --Withdraw all
        type = "button",
        name = WG.Lang.GUILD_TAKE_ALL,
        func = function()
          if not GuildD3A then return end
          if GuildFuzzy3 then
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD3A)})
          else
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemLink"] = GuildD3A})
          end
        end,
        width = "half",	
        },
        { --Store All
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL,
        func = function()
          if not GuildD3A then return end
          if GuildFuzzy3 then
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_STORE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD3A)})
          else
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_STORE_ALL, ["ItemLink"] = GuildD3A})
          end
        end,
        width = "half",	
        },
        { --TakeTo
        type = "slider",
        name = WG.Lang.GUILD_TAKE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS3A = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_TAKE_TO,
        func = function()
          if not GuildD3A then return end
          if GuildFuzzy3 then
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS3A, ["ItemId"] = GetItemLinkItemId(GuildD3A)})
          else
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS3A, ["ItemLink"] = GuildD3A})
          end
        end,
        width = "half",	
        },
        { --StoreTo
        type = "slider",
        name = WG.Lang.GUILD_STORE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS3B = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_TO,
        func = function()
          if not GuildD3A then return end
          if GuildFuzzy3 then
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS3B, ["ItemId"] = GetItemLinkItemId(GuildD3A)})
          else
            table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS3B, ["ItemLink"] = GuildD3A})
          end
        end,
        width = "half",	
        },
        {
        type = "header",
        name = GetString(SI_FURNITURETHEMETYPE1),
        },
        { --Store Craft Materials
        type = "dropdown",
        name = WG.Lang.GUILD_STORE_ALL_TYPE_DROP, 
        choices = MaterialChoices,
        choicesValues = MaterialChoicesValue,
        scrollable = true,
        getFunc = function() return "/" end,
        setFunc = function(var) 
          if var ~= "/" then
            GuildD3B = var
          else
            GuildD3B = nil
          end
        end,
        width = "full",
        },
        { --Withdraw for Daily Writs
        type = "button",
        name = WG.Lang.GUILD_TAKE_WRITS,
        tooltip = WG.Lang.GUILD_TAKE_WRITS_TOOLTIP,
        func = function()
          table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = WAREGUILD_DAILY})
        end,
        width = "half",	
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL_TYPE,
        func = function()
          if not GuildD3B then return end
          table.insert(WG.SV.Guild3, {["GuildId"] = WG.SV.Guild[3], ["Type"] = GuildD3B})
        end,
        width = "half",	
        },
        {
        type = "header",
        name = WG.Lang.GUILD_HEADER_STEPS,
        },
        { --Rules Display
        type = "description",
        title = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 3 > ",
        text = function() return Desc(WG.SV.Guild3) end,
        width = "full",
        enableLinks = true,
        },
        { --Which Line
        type = "slider",
        name = WG.Lang.GUILD_STEPS_SLIDER,
        getFunc = function() return 1 end,
        setFunc = function(var) GuildS3C = var end,
        min = 1,
        max = 1000,
        step = 1,
        width = "full",
        },
        { --Empty Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_EMPTY,
        func = function()
          WG.SV.Guild3 = {}
        end,
        width = "half", 
        },
        { --Delete Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_DELETE,
        func = function()
          table.remove(WG.SV.Guild3, GuildS3C)
        end,
        width = "half",	
        },
      },
    },
    { --Guild Rule 4
    type = "submenu",
		name = function() return GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 4 > "..GetGuildName(WG.SV.Guild[4] or 0) end,
    disabled = function() if WG.SV.Guild[4] then return false else return true end end,
		controls = {
        { --Item Scroll
        type = "dropdown",
        name = WG.Lang.GUILD_ITEM_SCROLL, 
        choices = ItemList(),
        scrollable = true,
        getFunc = function() if GuildD4A then return GuildD4A else return "/" end end,
        setFunc = function(var) 
          if var ~= "/" then 
            GuildD4A = var
          else 
            GuildD4A = nil
          end
        end,
        reference = "WG_Guild_4_Item",
        width = "full",
        },
        { --Fuzzy
        type = "checkbox",
        name = WG.Lang.GUILD_FUZZY,
        tooltip = WG.Lang.GUILD_FUZZY_TOOLTIP,
        getFunc = function() return GuildFuzzy4 end,
        setFunc = function(var) GuildFuzzy4 = var end,
        width = "half",
        },
        { --UpdateList
        type = "button",
        name = WG.Lang.GUILD_UPDATE_ITEM_LIST,
        func = function()
          GuildD4A = nil
          WG_Guild_4_Item.data.choices = ItemList()
          WG_Guild_4_Item:UpdateChoices()
        end,
        width = "half",	
        },
        { --Withdraw all
        type = "button",
        name = WG.Lang.GUILD_TAKE_ALL,
        func = function()
          if not GuildD4A then return end
          if GuildFuzzy4 then
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD4A)})
          else
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemLink"] = GuildD4A})
          end
        end,
        width = "half",	
        },
        { --Store All
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL,
        func = function()
          if not GuildD4A then return end
          if GuildFuzzy4 then
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_STORE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD4A)})
          else
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_STORE_ALL, ["ItemLink"] = GuildD4A})
          end
        end,
        width = "half",	
        },
        { --TakeTo
        type = "slider",
        name = WG.Lang.GUILD_TAKE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS4A = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_TAKE_TO,
        func = function()
          if not GuildD4A then return end
          if GuildFuzzy4 then
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS4A, ["ItemId"] = GetItemLinkItemId(GuildD4A)})
          else
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS4A, ["ItemLink"] = GuildD4A})
          end
        end,
        width = "half",	
        },
        { --StoreTo
        type = "slider",
        name = WG.Lang.GUILD_STORE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS4B = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_TO,
        func = function()
          if not GuildD4A then return end
          if GuildFuzzy4 then
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS4B, ["ItemId"] = GetItemLinkItemId(GuildD4A)})
          else
            table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS4B, ["ItemLink"] = GuildD4A})
          end
        end,
        width = "half",	
        },
        {
        type = "header",
        name = GetString(SI_FURNITURETHEMETYPE1),
        },
        { --Store Craft Materials
        type = "dropdown",
        name = WG.Lang.GUILD_STORE_ALL_TYPE_DROP, 
        choices = MaterialChoices,
        choicesValues = MaterialChoicesValue,
        scrollable = true,
        getFunc = function() return "/" end,
        setFunc = function(var) 
          if var ~= "/" then
            GuildD4B = var
          else
            GuildD4B = nil
          end
        end,
        width = "full",
        },
        { --Withdraw for Daily Writs
        type = "button",
        name = WG.Lang.GUILD_TAKE_WRITS,
        tooltip = WG.Lang.GUILD_TAKE_WRITS_TOOLTIP,
        func = function()
          table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = WAREGUILD_DAILY})
        end,
        width = "half",	
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL_TYPE,
        func = function()
          if not GuildD4B then return end
          table.insert(WG.SV.Guild4, {["GuildId"] = WG.SV.Guild[4], ["Type"] = GuildD4B})
        end,
        width = "half",	
        },
        {
        type = "header",
        name = WG.Lang.GUILD_HEADER_STEPS,
        },
        { --Rules Display
        type = "description",
        title = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 4 > ",
        text = function() return Desc(WG.SV.Guild4) end,
        width = "full",
        enableLinks = true,
        },
        { --Which Line
        type = "slider",
        name = WG.Lang.GUILD_STEPS_SLIDER,
        getFunc = function() return 1 end,
        setFunc = function(var) GuildS4C = var end,
        min = 1,
        max = 1000,
        step = 1,
        width = "full",
        },
        { --Empty Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_EMPTY,
        func = function()
          WG.SV.Guild4 = {}
        end,
        width = "half",	
        },
        { --Delete Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_DELETE,
        func = function()
          table.remove(WG.SV.Guild4, GuildS4C)
        end,
        width = "half",	
        },
      },
    },
    { --Guild Rule 5
    type = "submenu",
		name = function() return GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 5 > "..GetGuildName(WG.SV.Guild[5] or 0) end,
    disabled = function() if WG.SV.Guild[5] then return false else return true end end,
		controls = {
        { --Item Scroll
        type = "dropdown",
        name = WG.Lang.GUILD_ITEM_SCROLL, 
        choices = ItemList(),
        scrollable = true,
        getFunc = function() if GuildD5A then return GuildD5A else return "/" end end,
        setFunc = function(var) 
          if var ~= "/" then 
            GuildD5A = var
          else 
            GuildD5A = nil
          end
        end,
        reference = "WG_Guild_5_Item",
        width = "full",
        },
        { --Fuzzy
        type = "checkbox",
        name = WG.Lang.GUILD_FUZZY,
        tooltip = WG.Lang.GUILD_FUZZY_TOOLTIP,
        getFunc = function() return GuildFuzzy5 end,
        setFunc = function(var) GuildFuzzy5 = var end,
        width = "half",
        },
        { --UpdateList
        type = "button",
        name = WG.Lang.GUILD_UPDATE_ITEM_LIST,
        func = function()
          GuildD5A = nil
          WG_Guild_5_Item.data.choices = ItemList()
          WG_Guild_5_Item:UpdateChoices()
        end,
        width = "half",	
        },
        { --Withdraw all
        type = "button",
        name = WG.Lang.GUILD_TAKE_ALL,
        func = function()
          if not GuildD5A then return end
          if GuildFuzzy5 then
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD5A)})
          else
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_TAKE_ALL, ["ItemLink"] = GuildD5A})
          end
        end,
        width = "half",	
        },
        { --Store All
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL,
        func = function()
          if not GuildD5A then return end
          if GuildFuzzy5 then
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_STORE_ALL, ["ItemId"] = GetItemLinkItemId(GuildD5A)})
          else
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_STORE_ALL, ["ItemLink"] = GuildD5A})
          end
        end,
        width = "half",	
        },
        { --TakeTo
        type = "slider",
        name = WG.Lang.GUILD_TAKE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS5A = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_TAKE_TO,
        func = function()
          if not GuildD5A then return end
          if GuildFuzzy5 then
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS5A, ["ItemId"] = GetItemLinkItemId(GuildD5A)})
          else
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_TAKE_TO, ["Count"] = GuildS5A, ["ItemLink"] = GuildD5A})
          end
        end,
        width = "half",	
        },
        { --StoreTo
        type = "slider",
        name = WG.Lang.GUILD_STORE_TO_SLIDER,
        getFunc = function() return 0 end,
        setFunc = function(var) GuildS5B = var end,
        min = 0,
        max = 10000,
        step = 1,
        width = "half",
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_TO,
        func = function()
          if not GuildD5A then return end
          if GuildFuzzy5 then
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS5B, ["ItemId"] = GetItemLinkItemId(GuildD5A)})
          else
            table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_STORE_TO, ["Count"] = GuildS5B, ["ItemLink"] = GuildD5A})
          end
        end,
        width = "half",	
        },
        {
        type = "header",
        name = GetString(SI_FURNITURETHEMETYPE1),
        },
        { --Store Craft Materials
        type = "dropdown",
        name = WG.Lang.GUILD_STORE_ALL_TYPE_DROP, 
        choices = MaterialChoices,
        choicesValues = MaterialChoicesValue,
        scrollable = true,
        getFunc = function() return "/" end,
        setFunc = function(var) 
          if var ~= "/" then
            GuildD5B = var
          else
            GuildD5B = nil
          end
        end,
        width = "full",
        },
        { --Withdraw for Daily Writs
        type = "button",
        name = WG.Lang.GUILD_TAKE_WRITS,
        tooltip = WG.Lang.GUILD_TAKE_WRITS_TOOLTIP,
        func = function()
          table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = WAREGUILD_DAILY})
        end,
        width = "half",	
        },
        { 
        type = "button",
        name = WG.Lang.GUILD_STORE_ALL_TYPE,
        func = function()
          if not GuildD5B then return end
          table.insert(WG.SV.Guild5, {["GuildId"] = WG.SV.Guild[5], ["Type"] = GuildD5B})
        end,
        width = "half",	
        },
        {
        type = "header",
        name = WG.Lang.GUILD_HEADER_STEPS,
        },
        { --Rules Display
        type = "description",
        title = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER).." 5 > ",
        text = function() return Desc(WG.SV.Guild5) end,
        width = "full",
        enableLinks = true,
        },
        { --Which Line
        type = "slider",
        name = WG.Lang.GUILD_STEPS_SLIDER,
        getFunc = function() return 1 end,
        setFunc = function(var) GuildS5C = var end,
        min = 1,
        max = 1000,
        step = 1,
        width = "full",
        },
        { --Empty Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_EMPTY,
        func = function()
          WG.SV.Guild5 = {}
        end,
        width = "half",	
        },
        { --Delete Rule
        type = "button",
        name = WG.Lang.GUILD_STEPS_DELETE,
        func = function()
          table.remove(WG.SV.Guild5, GuildS5C)
        end,
        width = "half",	
        },
      },
    },
    { --Clipboard
    type = "submenu",
		name = WG.Lang.CLIP,
    disabled = false,
		controls = {
        { --Select Bank
        type = "dropdown",
        name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER), 
        choices = {"/", "1", "2", "3", "4", "5"},
        choicesValues = {false, 1, 2, 3, 4, 5},
        scrollable = true,
        getFunc = function() if ClipGuild then return ClipGuild else return false end end,
        setFunc = function(var)
          if var and WG.SV.Guild[var] then
            ClipGuild = var
          end
        end,
        width = "full",
        },
        { --Copy
        type = "button",
        name = GetString(SI_UI_ERROR_COPY),
        func = function()
          if not ClipGuild then return end
          if ClipGuild == 1 then ClipSteps = WG.SV.Guild1 end
          if ClipGuild == 2 then ClipSteps = WG.SV.Guild2 end
          if ClipGuild == 3 then ClipSteps = WG.SV.Guild3 end
          if ClipGuild == 4 then ClipSteps = WG.SV.Guild4 end
          if ClipGuild == 5 then ClipSteps = WG.SV.Guild5 end
        end,
        width = "half",	
        },
        { --Paste
        type = "button",
        name = WG.Lang.CLIP_PASTE,
        func = function()
          if not ClipGuild then return end
          if ClipGuild == 1 then WG.SV.Guild1 = CopySteps(WG.SV.Guild[1], ClipSteps) end
          if ClipGuild == 2 then WG.SV.Guild2 = CopySteps(WG.SV.Guild[2], ClipSteps) end
          if ClipGuild == 3 then WG.SV.Guild3 = CopySteps(WG.SV.Guild[3], ClipSteps) end
          if ClipGuild == 4 then WG.SV.Guild4 = CopySteps(WG.SV.Guild[4], ClipSteps) end
          if ClipGuild == 5 then WG.SV.Guild5 = CopySteps(WG.SV.Guild[5], ClipSteps) end
        end,
        width = "half",	
        },
        { --Rules Display
        type = "description",
        title = WG.Lang.GUILD_HEADER_STEPS,
        text = function() return Desc(ClipSteps) end,
        width = "full",
        enableLinks = true,
        },
      },
    },
    { --Help
      type = "description",
      title = WG.Lang.SETTING_BOTTOM_TIPS,
      width = "full",
      enableLinks = true,
    },
  --End of options
  }
	LAM:RegisterOptionControls(WG.name.."_Options", options)
end