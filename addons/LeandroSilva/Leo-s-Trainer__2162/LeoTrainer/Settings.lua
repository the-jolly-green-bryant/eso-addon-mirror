
LeoTrainer.craftNames = {"Blacksmith", "Clothing", "Woodworking", "Jewelry"}

LeoTrainer_SettingsMenu = ZO_Object:Subclass()
local LAM = LibAddonMenu2

function LeoTrainer_SettingsMenu:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function LeoTrainer_SettingsMenu:Initialize()
end

function LeoTrainer_SettingsMenu:SelectAll(craftSkill)
    for i, char in ipairs(LeoAltholic.GetCharacters()) do
        if craftSkill ~= nil then
            LeoTrainer.setTrackingSkill(char.bio.name, craftSkill, true)
            LeoTrainer.setFillSlotWithSkill(char.bio.name, craftSkill, true)
        else
            for _, craftSkill in ipairs({ CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING }) do
                LeoTrainer.setTrackingSkill(char.bio.name, craftSkill, true)
                LeoTrainer.setFillSlotWithSkill(char.bio.name, craftSkill, true)
            end
        end
    end
    ReloadUI()
end
function LeoTrainer_SettingsMenu:DeselectAll(craftSkill)
    for i, char in ipairs(LeoAltholic.GetCharacters()) do
        if craftSkill ~= nil then
            LeoTrainer.setTrackingSkill(char.bio.name, craftSkill, false)
            LeoTrainer.setFillSlotWithSkill(char.bio.name, craftSkill, false)
        else
            for _, craftSkill in ipairs({ CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING }) do
                LeoTrainer.setTrackingSkill(char.bio.name, craftSkill, false)
                LeoTrainer.setFillSlotWithSkill(char.bio.name, craftSkill, false)
            end
        end
    end
    ReloadUI()
end

local qualityChoices = {}
local qualityChoicesValues = {}
for quality = ITEM_FUNCTIONAL_QUALITY_MIN_VALUE, ITEM_FUNCTIONAL_QUALITY_MAX_VALUE do
    local qualityColor = GetItemQualityColor(quality)
    local qualityString = qualityColor:Colorize(GetString("SI_ITEMQUALITY", quality))
    table.insert(qualityChoicesValues, quality)
    table.insert(qualityChoices, qualityString)
end

function LeoTrainer_SettingsMenu:CreatePanel()
    local OptionsName = "LeoTrainerOptions"
    local panelData = {
        type = "panel",
        name = LeoTrainer.name,
        displayName = "|c39B027"..LeoTrainer.displayName.."|r",
        author = "@LeandroSilva",
        version = LeoTrainer.version,
        registerForRefresh = true,
        registerForDefaults = false,
        slashCommand = "/lto",
        website = "http://www.esoui.com/downloads/info2162-LeosTrainer.html",
    }
    LAM:RegisterAddonPanel(OptionsName, panelData)

    local charNames = {
        "Anyone"
    }
    for _, char in pairs(LeoAltholic.GetCharacters()) do
        table.insert(charNames, char.bio.name)
    end

    local researchMaxQualities = {
        {
            type = "description",
            text = GetString(SI_KEEP_UPGRADE_AT_MAX)
        }
    }
    local deconstructMaxQualities = {
        {
            type = "description",
            text = GetString(SI_KEEP_UPGRADE_AT_MAX)
        }
    }
    for _, craftSkill in ipairs({ CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_JEWELRYCRAFTING, CRAFTING_TYPE_ENCHANTING }) do
        if craftSkill ~= CRAFTING_TYPE_ENCHANTING then
            table.insert(researchMaxQualities, {
                type = "dropdown",
                width = "half",
                choices = qualityChoices,
                choicesValues = qualityChoicesValues,
                name = zo_strformat(SI_ABILITY_NAME, ZO_GetCraftingSkillName(craftSkill)),
                getFunc = function() return LeoTrainer.settings.research.maxQuality[craftSkill] end,
                setFunc = function(value) LeoTrainer.settings.research.maxQuality[craftSkill] = value end,
                default = LeoTrainer.settingsDefaults.research.maxQuality[craftSkill],
                disabled = function() return not LeoTrainer.settings.research.auto end,
            });
        end
        table.insert(deconstructMaxQualities, {
            type = "dropdown",
            width = "half",
            choices = qualityChoices,
            choicesValues = qualityChoicesValues,
            name = zo_strformat(SI_ABILITY_NAME, ZO_GetCraftingSkillName(craftSkill)),
            getFunc = function() return LeoTrainer.settings.deconstruct.maxQuality[craftSkill] end,
            setFunc = function(value) LeoTrainer.settings.deconstruct.maxQuality[craftSkill] = value end,
            default = LeoTrainer.settingsDefaults.deconstruct.maxQuality[craftSkill],
            disabled = function() return not LeoTrainer.settings.deconstruct.auto end,
        });
    end


    local optionsData = {
        {
            type = "header",
            name = "|c3f7fff"..GetString(SI_GAMEPAD_OPTIONS_MENU).."|r"
        },
        {
            type = "checkbox",
            name = zo_strformat(GetString(SI_GAMEPAD_ALCHEMY_USE_REAGENT), GetString(SI_ITEMTRAITTYPE25)),
            default = false,
            getFunc = function() return LeoTrainer.data.trainNirnhoned end,
            setFunc = function(value) LeoTrainer.data.trainNirnhoned = value end,
        },
        {
            type = "checkbox",
            name = "Silent mode. No message displayed on chat.",
            default = false,
            getFunc = function() return LeoTrainer.data.silent end,
            setFunc = function(value) LeoTrainer.data.silent = value end,
        },
        LeoTrainer.settings:GetLibAddonMenuAccountCheckbox(),
        {
            type = "submenu",
            name = GetString(SI_SMITHING_TAB_RESEARCH),
            controls = {
                {
                    type = "description",
                    text = "To avoid problems, auto research will ony work with marked items for research by FCOItemSaver. Also, only until max skill level. This addon will automatically mark items after crafts them."
                },{
                    type = "checkbox",
                    name = "Research automatically when in station",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.research.auto end,
                    setFunc = function(value) LeoTrainer.settings.research.auto = value end,
                    disabled = function() return not FCOIS end,
                },{
                    type = "checkbox",
                    name = "List items in the chat",
                    default = true,
                    getFunc = function() return LeoTrainer.settings.research.listInChat end,
                    setFunc = function(value) LeoTrainer.settings.research.listInChat = value end,
                },{
                    type = "checkbox",
                    name = "Allow crafted items",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.research.allowCrafted end,
                    setFunc = function(value) LeoTrainer.settings.research.allowCrafted = value end,
                    disabled = function() return not LeoTrainer.settings.research.auto end,
                },{
                    type = "checkbox",
                    name = "Allow set items",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.research.allowSets end,
                    setFunc = function(value) LeoTrainer.settings.research.allowSets = value end,
                    disabled = function() return not LeoTrainer.settings.research.auto end,
                },
                unpack(researchMaxQualities)
            }
        },{
            type = "submenu",
            name = GetString(SI_CRAFTING_PERFORM_FREE_CRAFT),
            controls = {
                {
                    type = "checkbox",
                    name = "Craft automatically when in station",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.craft.auto end,
                    setFunc = function(value) LeoTrainer.settings.craft.auto = value end,
                }
            }
        },{
            type = "submenu",
            name = GetString(SI_SMITHING_TAB_DECONSTRUCTION),
            controls = {
                {
                    type = "description",
                    text = "To avoid problems, auto deconstruct will ony work with marked items by FCOItemSaver and marked with deconstruction or inticate icons. Also, only until max skill level."
                },{
                    type = "checkbox",
                    name = "Deconstruct automatically when in station",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.deconstruct.auto end,
                    setFunc = function(value) LeoTrainer.settings.deconstruct.auto = value end,
                    disabled = function() return not FCOIS end,
                },{
                    type = "checkbox",
                    name = "List items in the chat",
                    default = true,
                    getFunc = function() return LeoTrainer.settings.deconstruct.listInChat end,
                    setFunc = function(value) LeoTrainer.settings.deconstruct.listInChat = value end,
                },{
                    type = "checkbox",
                    name = "Allow items in Bank",
                    tooltip = "On: will scan backpack and bank. Off: Only backpack",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.deconstruct.allowBank end,
                    setFunc = function(value) LeoTrainer.settings.deconstruct.allowBank = value end,
                },{
                    type = "checkbox",
                    name = "Allow set items",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.deconstruct.allowSets end,
                    setFunc = function(value) LeoTrainer.settings.deconstruct.allowSets = value end,
                },
                unpack(deconstructMaxQualities)
            }
        },{
            type = "submenu",
            name = GetString(SI_INTERACT_OPTION_BANK),
            controls = {
                {
                    type = "checkbox",
                    name = "Deposit crafted items automatically",
                    default = false,
                    getFunc = function() return LeoTrainer.settings.bank.autoDeposit end,
                    setFunc = function(value) LeoTrainer.settings.bank.autoDeposit = value end,
                }
            }
        },{
            type = "header",
            name = "|c3f7fffCharacters|r"
        },{
            type = "dropdown",
            name = "Prefered Trainer",
            tooltip = "This character will be selected as the default trainer if knows the trait.",
            choices = charNames,
            default = "Anyone",
            getFunc = function() return LeoTrainer.settings.defaultTrainer end,
            setFunc = function(value) LeoTrainer.settings.defaultTrainer = value end
        },{
            type = "description",
            text = "Select which crafting skills will be available for each char and which ones will be used when filling empty research slots"
        },{
            type = "button",
            name = "Select all",
            func = function() LeoTrainer_SettingsMenu:SelectAll() end,
            warning = "Will need to reload the UI.",
            width = "half",
        },{
            type = "button",
            name = "Deselect all",
            func = function() LeoTrainer_SettingsMenu:DeselectAll() end,
            warning = "Will need to reload the UI.",
            width = "half",
        },{
            type = "custom",
            reference = OptionsName .. "Characters"
        }
    }
    LAM:RegisterOptionControls(OptionsName, optionsData)
end

function LeoTrainer_SettingsMenu:AddCharacters()
    if LeoTrainerOptionsCharactersSection then return end
    local control = CreateControlFromVirtual("$(parent)", LeoTrainerOptionsCharacters, "LeoTrainer_SettingsCharacters", "Section")
    self.container = control:GetNamedChild("Container")
    local last
    for i, char in ipairs(LeoAltholic.GetCharacters()) do
        last = self:AddCharacter(i, char, last)
    end
end

function LeoTrainer_SettingsMenu_OnMouseEnter(control, tooltip)
    InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
    SetTooltipText(InformationTooltip, tooltip)
end

local function Toggle(checkbox, checked)
    local control = checkbox:GetParent()
    LeoTrainer.setTrackingSkill(control.data.charName, checkbox.data.craftId, checked)
end

local function ToggleFill(checkbox, checked)
    local control = checkbox:GetParent()
    LeoTrainer.setFillSlotWithSkill(control.data.charName, checkbox.data.craftId, checked)
end

function LeoTrainer_SettingsMenu:AddCharacter(id, char, last)
    local control = CreateControlFromVirtual("$(parent)", self.container, "LeoTrainer_SettingsCharacter", id)
    if last then
        control:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 0)
        control:SetAnchor(BOTTOMRIGHT, last, BOTTOMRIGHT, 0, 30)
    else
        control:SetAnchor(TOPLEFT, LeoTrainer_SettingsCharactersIconsST_Label, TOPLEFT, 0, 30)
        control:SetAnchor(BOTTOMRIGHT, LeoTrainer_SettingsCharactersIconsST_Label, TOPRIGHT, 0, 60)
    end
    control.data = control.data or {}
    control.data.charName = char.bio.name
    control.label = control:GetNamedChild("Name")
    control.label:SetText(char.bio.name)
    control.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
    for k,craftId in pairs(LeoAltholic.craftResearch) do
        local checkbox = control:GetNamedChild("ST_" .. craftId)
        checkbox.data = checkbox.data or {}
        checkbox.data.craftId = craftId
        checkbox.data.tooltipText = nil
        ZO_CheckButton_SetCheckState(checkbox, LeoTrainer.isTrackingSkill(char.bio.name, craftId))
        ZO_CheckButton_SetToggleFunction(checkbox, Toggle)

        checkbox = control:GetNamedChild("FS_" .. craftId)
        checkbox.data = checkbox.data or {}
        checkbox.data.craftId = craftId
        checkbox.data.tooltipText = nil
        ZO_CheckButton_SetCheckState(checkbox, LeoTrainer.canFillSlotWithSkill(char.bio.name, craftId))
        ZO_CheckButton_SetToggleFunction(checkbox, ToggleFill)
    end
    return control
end

function LeoTrainer_SettingsMenu:ClearCharacter(id)
    if self.container then
        local control = self.container:GetNamedChild(id)
        if control then
            control:SetHidden(true)
        end
    end
end

function LeoTrainer_SettingsMenu:OnSettingsControlsCreated(panel)
    --Each time an options panel is created, once for each addon viewed
    if panel:GetName() == "LeoTrainerOptions" then
        self:AddCharacters()
    end
end

function LeoTrainer_SettingsMenu:IsCreated()
    if self.container then
        return true
    else
        return false
    end
end
