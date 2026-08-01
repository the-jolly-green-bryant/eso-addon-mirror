local LKT = LibKeepTooltip

local Log = IMP_PVP_UI_Logger('IMP_KT_RESORCESLEVELS')

local function AddResourcesLevelsLine(self)
    local keepId = self.keepId
    local battlegroundContext = self.battlegroundContext

    local resourcesTable = {}
    for resourceType = 1, 3 do
        local keepResourceId = GetResourceKeepForKeep(keepId, resourceType)
        local resourceAlliance = GetKeepAlliance(keepResourceId, battlegroundContext)

        local recourceIcon = IMP_PVP_UI_SHARED.GetKeepIcon(keepResourceId, resourceAlliance, 24)
        local keepResourceLevel = GetKeepResourceLevel(keepId, battlegroundContext, resourceType)

        table.insert(resourcesTable, string.format('%s- %d', recourceIcon, keepResourceLevel))
    end

    LKT.AddLine(self, table.concat(resourcesTable, '   '), LKT.KEEP_TOOLTIP_NORMAL_LINE)
end

-- do
--     local RESOURCES = LKT:RegisterIngridient('RESOURCES', AddResourcesLine)
--     local USUAL_KEEP_TOOLTIP_RECIPE = LKT.GetRecipeByKeepType(KEEPTYPE_KEEP)
--     LKT.AddIngridientBefore(USUAL_KEEP_TOOLTIP_RECIPE, RESOURCES, LKT.INGRIDIENTS.FAST_TRAVEL)
-- end

local function AddResourcesLevelsToReceipe()
    local RESOURCES_LEVELS = LKT:RegisterIngridient('RESOURCESLEVELS', AddResourcesLevelsLine)
    local USUAL_KEEP_TOOLTIP_RECIPE = LKT.GetRecipeByKeepType(KEEPTYPE_KEEP)
    LKT.AddIngridientBefore(USUAL_KEEP_TOOLTIP_RECIPE, RESOURCES_LEVELS, LKT.INGRIDIENTS.FAST_TRAVEL)
end

function IMP_KT_ResourcesLevels_Initialize()
    Log('Initializing resources levels')
    AddResourcesLevelsToReceipe()
    Log('Resources levels initialized')
end