DoItAll = DoItAll or {}
DoItAll.Settings = {}
DoItAll.Settings.Options = {}

--The SavedVariables entries
DoItAll.Settings.DefaultOptions = {
  BatchSize = 20,
  BatchDelay = 200,
  ExtractDelay = 200,
  RespectItemSaver = true,
  --UseISFilterSetChecks = false,
  UseFCOISFilterPanelChecks = true,
  KeepResearchableItems = true,
  SendMailFull = false,
  SendMailEnd = false,
  UseZOsMulticraft = true,
  SuppressAskBeforeExtractDialog = false,
}

--Create the LAM controls dynamically
local function CreateLAMControl(setting, name, tooltip, data, disabledChecks, warning)
  data.name = name
  data.tooltip = tooltip
  data.getFunc = function() return DoItAll.Settings["Get" .. setting]() end
  data.setFunc = function(value) DoItAll.Settings["Set" .. setting](value) end
  data.default = DoItAll.Settings.DefaultOptions[setting]
  data.reference = "DoItAll_" .. setting
  if disabledChecks ~= nil then
    data.disabled = disabledChecks
  end
  if warning then
    data.warning = warning
  end
  return data
end

local function CreateLAMCheckbox(setting, name, tooltip, disabledChecks, warning)
  return CreateLAMControl(setting, name, tooltip, { type = "checkbox" }, disabledChecks, warning)
end

local function CreateLAMSlider(setting, name, tooltip, min, max, step, disabledChecks)
  return CreateLAMControl(setting, name, tooltip, { type = "slider", min = min, max = max, step = step }, disabledChecks, nil)
end

local function CreateLAMHeader(name)
  return { type = "header", name = name }
end

local function SetupOptionsMenu()
  local addonName = DoItAll.AddOnName

  local panelData = {
    type = "panel",
    name = addonName,
    author = "Thenedus, Baertram",
    version = tostring(DoItAll.AddOnVersion),
    registerForDefaults = true,
    registerForRefresh = true, --important to call the "disabled" functions and update the controls!
    slashCommand = "/doitalls",
    website = "http://www.esoui.com/downloads/info690-DoItAll.html",
    feedback = "https://www.esoui.com/portal.php?id=136&a=faq",
    donation = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
  }

  local optionsData = {
    CreateLAMHeader("General"),
    CreateLAMCheckbox("RespectItemSaver", "Protect/Keep saved items", "Skip items that are saved with the addons: FCO ItemSaver, Item Saver."),
    CreateLAMCheckbox("UseFCOISFilterPanelChecks", "Use FCO ItemSaver panel checks", "Check if the FCO ItemSaver marker icons at an item really protect the item at the current filter panel (deconstruct, extract, sell, mail, trade, bank, etc.), instead of only checking if the item got any of the FCOIS marker icons active.\n\nThis will alow you to e.g. deconstruct items even if they are marked with a marker icon, but the marker icon settings allows deconstruction (or you have disabled deconstruction checks temporarily with the additional inventory \'flag\' icon)"),
    --CreateCheckbox("UseISFilterSetChecks", "Use ItemSaver set checks", "Check items marked with ItemSaver for the actual filter set settings (mail, trade, extract, sell, etc.), instead of only checking if the item got any of the Itemsaver marker icons active.\n\nThis will alow you to e.g. deconstruct items even if they are marked with a marker icon, but the marker icon settings allows deconstruction in this filter set."),
    CreateLAMHeader("Transfer All"),
    CreateLAMSlider("BatchSize", "Batch Size", "The number of items to transfer in one batch.", 1, 200, 5),
    CreateLAMSlider("BatchDelay", "Batch Delay [ms]", "The number of milliseconds to wait between two batches.", 100, 1000, 10),
    CreateLAMHeader("Extract/Deconstruct/Refine All"),
    CreateLAMCheckbox("UseZOsMulticraft", "Use vanilla UI multicraft", "Use the vanilla UI multicraft if you press the keybind to extract all.\nThis will add all refinable/deconstructable/extractable items to the extraction slot at once and process them all with 1 keybind press/mouse click.\nInformation: ZOs prevents multi refine/deconstruct/extract of batches > 100 items. If there are more than 100 items you might need to repeat the keybind press/mouse click!\n\nIf disabled the items will be extracted, with the setup extract delay, one slot after another."),
    CreateLAMCheckbox("SuppressAskBeforeExtractDialog", "Suppress \'Ask before multi-extract\' dialog", "Suppress the dialog which will ask if you really want to extract all the items at once.", function() return DoItAll.Settings.GetUseZOsMulticraft() end, "Enabling this will refine/deconstruct/extract all your slotted items at once, without any warning or way to get them back!"),
    CreateLAMSlider("ExtractDelay", "Extract Delay [ms]", "The number of milliseconds to wait between each extraction.\nThis does not apply to the ZOs vanilla UI multicraft extraction!", 0, 1000, 10, function() return DoItAll.Settings.GetUseZOsMulticraft() end),
    CreateLAMCheckbox("KeepResearchableItems", "Keep researchable items", "Do not deconstruct items that have a researchable trait (requires addon \'Research Assistant\'!)."),
    CreateLAMHeader("Attach All"),
    CreateLAMCheckbox("SendMailFull", "Auto-send full mails", "Send mail when all attachment slots are full."),
    CreateLAMCheckbox("SendMailEnd", "Auto-send mail when done", "Send mail when all possible (non protected) items have been attached, even though not all attachment slots may have been used.")
  }

  local LAM2 = DoItAll.LAM
  local addonSettingsPanelName = addonName .. "_LAM_Settings_Panel"
  DoItAll.LAMPanel = LAM2:RegisterAddonPanel(addonSettingsPanelName, panelData)
  LAM2:RegisterOptionControls(addonSettingsPanelName, optionsData)
end

--Create Get and Set functions dynamically from the SV default entries
local function CreateGettersAndSetters()
  for option, _ in pairs(DoItAll.Settings.DefaultOptions) do
    DoItAll.Settings["Get" .. option] = function() return DoItAll.Settings.Options[option] end
    DoItAll.Settings["Set" .. option] = function(value) DoItAll.Settings.Options[option] = value end
  end
end

--Init the settings, load the server dependent SV with character ID
function DoItAll.Settings.Initialize()
  DoItAll.Settings.Options = ZO_SavedVars:NewCharacterIdSettings("DoItAllSV", 2, nil, DoItAll.Settings.DefaultOptions, GetWorldName())
  CreateGettersAndSetters()
  SetupOptionsMenu()
end

function DoItAll.IsZOsVanillaUIMultiCraftEnabled()
  return DoItAll.Settings.GetUseZOsMulticraft() or false
end
