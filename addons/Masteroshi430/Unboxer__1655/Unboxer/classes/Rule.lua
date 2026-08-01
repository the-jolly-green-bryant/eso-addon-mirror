--[[ 
     Base class for an Unboxer configurable category matching rule.  
     Child classes implement matching logic for whether an itemLink matches the rule.
]]--

local addon = Unboxer
local class = addon.classes
local debug = false
local itemlinkFormat = GetString(SI_UNBOXER_ITEMLINK_FORMAT)
class.Rule = ZO_Object:Subclass()

function class.Rule:New(...)
    local instance = ZO_Object.New(self)
    instance:Initialize(...)
    return instance
end

function class.Rule:Initialize(options)
    if not options then
        addon.Debug("Parameter #1 to Rule:New() constructor missing.  Expected options table containing, at the least, an entry for 'name', specifying the rule id / setting name.", debug)
        return
    elseif not options.name then
        addon.Debug("options parameter to Rule:New() missing required table entry 'name', specifying the rule id / setting name.")
    end
    self.name = options.name
    self.exampleItemIds = options.exampleItemIds or {}
    if options.exampleItemId then
        table.insert(self.exampleItemIds, options.exampleItemId)
    end
    self.autolootSettingName = self.name .. "Autoloot"
    self.summarySettingName = self.name .. "Summary"
    self.title = options.title or options.name
    self.tooltip = options.tooltip or ""
    self.submenu = options.submenu or GetString(SI_GAMEPLAY_OPTIONS_GENERAL)
    self.knownIds = options.knownIds or {}
    if type(options.dependencies) ~= "table" then
        options.dependencies = { options.dependencies }
    end
    self.dependencies = {}
    for _, dependencyName in ipairs(options.dependencies) do
        self.dependencies[dependencyName] = true
    end
    self.hidden = options.hidden or false
end

--[[ Generates LibAddonMenu2 configuration options for enabling/disabling this rule ]]--
function class.Rule:CreateLAM2Options()
    if self.optionsTable then
        return self.optionsTable
    end
    if not self.name or self.hidden then return end
    local title = self.title
    local tooltip = self.tooltip
    local optionsTable = {}
    table.insert(optionsTable, { type = "divider" })
    table.insert(optionsTable,
        {
            type     = "checkbox",
            name     = title,
            tooltip  = tooltip,
            getFunc  = function() return self:IsEnabled() end,
            setFunc  = function(value) self:SetEnabled(value) end,
            default  = false,
        })
    if #self.exampleItemIds > 0 then
        local exampleItemLinks = {}
        for _, itemId in ipairs(self.exampleItemIds) do
            local itemLink = string.format(itemlinkFormat, itemId)
            table.insert(exampleItemLinks, itemLink)
        end
        table.insert(optionsTable,
            {
                type        = "description",
                text        = ZO_GenerateCommaSeparatedListWithoutAnd(exampleItemLinks) .. GetString(SI_UNBOXER_ETC),
                enableLinks = true,
            })
    end
    table.insert(optionsTable,
        {
            type     = "checkbox",
            name     = GetString(SI_UNBOXER_AUTOLOOT),
            tooltip  = GetString(SI_UNBOXER_AUTOLOOT_TOOLTIP),
            width    = "half",
            getFunc  = function() return self:IsAutolootEnabled() end,
            setFunc  = function(value) self:SetAutolootEnabled(value) end,
            default  = self:IsAutolootDefault(),
            disabled = function()
                           return not addon.settings.autoloot
                                  or not self:IsEnabled()
                       end,
        })
    table.insert(optionsTable,
        {
            type     = "checkbox",
            name     = GetString(SI_UNBOXER_SUMMARY),
            tooltip  = GetString(SI_UNBOXER_SUMMARY_TOOLTIP),
            width    = "half",
            getFunc  = function() return self:IsSummaryEnabled() end,
            setFunc  = function(value) self:SetSummaryEnabled(value) end,
            default  = self:IsSummaryDefault(),
            disabled = function() return not self:IsEnabled() or not addon.settings.chatContentsSummary.enabled end,
        })
    
    self:OnAutolootSet(self:IsAutolootEnabled())
    
    self.optionsTable = optionsTable
    
    return optionsTable
end

--[[ Abstract: determines if this rule applies to a given item link. 
     data: table containing infomation about the item to match, like itemType, quality, lowercase name and lowercase flavorText.
     Returns: 
     * isMatch:  true if the data matches this rule; otherwise nil
     * canUnbox: true if the given item is able to be unboxed by the current character; otherwise nil
]]--
function class.Rule:Match(data)
    error("Unboxer.Rule:Match() must be overriden in child class for rule '" .. self.name .. "'")
end

function class.Rule:MatchKnownIds(data)
    if self.knownIds[data.itemId] then
        return true
    end
end

function class.Rule:GetKnownIds()
    return self.knownIds
end

function class.Rule:IsAutolootDefault()
    return addon.defaults[self.autolootSettingName]
end

function class.Rule:IsAutolootEnabled()
    return addon.settings[self.autolootSettingName]
end

function class.Rule:IsDependentUpon(rule)
    return self.dependencies[rule.name]
end

function class.Rule:IsEnabled()
    return addon.settings[self.name]
end

function class.Rule:IsSummaryDefault()
    return true
end

function class.Rule:IsSummaryEnabled()
    return addon.settings[self.summarySettingName]
end

function class.Rule:OnAutolootSet(value)
    -- Optional: Override this in your child class
end

function class.Rule:SetAutolootEnabled(value) 
    addon.settings[self.autolootSettingName] = value
    addon.Debug("auto loot set for " .. self.name, debug)
    self:OnAutolootSet(value)
end

function class.Rule:SetEnabled(enabled)
    addon.settings[self.name] = enabled
end

function class.Rule:SetSummaryEnabled(enabled)
    addon.settings[self.summarySettingName] = enabled
end