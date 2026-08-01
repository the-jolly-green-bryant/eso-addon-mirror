-- StickerbookPlus – Settings (LibAddonMenu options panel)

local Addon = StickerbookPlus
local Settings = {}
Addon.Settings = Settings

-- ── Live preview controls ─────────────────────────────────────────────────────

local g_previewNew = nil

local TILE_SIZE     = 67
local PREVIEW_PAD   = 4

local function CreatePreviewControl(parent, ctrlName)
    local ctrl = WINDOW_MANAGER:CreateControl(ctrlName, parent, CT_TEXTURE)
    ctrl:SetDimensions(TILE_SIZE, TILE_SIZE)
    ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, PREVIEW_PAD, PREVIEW_PAD)
    ctrl:SetColor(0, 0, 0, 0)

    local border = {}
    local sides = { "Top", "Bottom", "Left", "Right" }
    for _, side in ipairs(sides) do
        local line = WINDOW_MANAGER:CreateControl(ctrlName .. "Border" .. side, ctrl, CT_TEXTURE)
        line:SetHidden(true)
        border[side] = line
    end
    ctrl._border = border
    return ctrl
end

local function PositionPreviewBorder(ctrl, thickness)
    local b = ctrl._border
    b.Top:ClearAnchors()
    b.Top:SetAnchor(TOPLEFT,  ctrl, TOPLEFT,  0, 0)
    b.Top:SetAnchor(TOPRIGHT, ctrl, TOPRIGHT, 0, 0)
    b.Top:SetHeight(thickness)

    b.Bottom:ClearAnchors()
    b.Bottom:SetAnchor(BOTTOMLEFT,  ctrl, BOTTOMLEFT,  0, 0)
    b.Bottom:SetAnchor(BOTTOMRIGHT, ctrl, BOTTOMRIGHT, 0, 0)
    b.Bottom:SetHeight(thickness)

    b.Left:ClearAnchors()
    b.Left:SetAnchor(TOPLEFT,    ctrl, TOPLEFT,    0, thickness)
    b.Left:SetAnchor(BOTTOMLEFT, ctrl, BOTTOMLEFT, 0, -thickness)
    b.Left:SetWidth(thickness)

    b.Right:ClearAnchors()
    b.Right:SetAnchor(TOPRIGHT,    ctrl, TOPRIGHT,    0, thickness)
    b.Right:SetAnchor(BOTTOMRIGHT, ctrl, BOTTOMRIGHT, 0, -thickness)
    b.Right:SetWidth(thickness)
end

local function RefreshNewPreview()
    if not g_previewNew then return end
    local db = Addon.db
    if not db then return end

    if db.showNewBackground then
        local c = db.newBackgroundColor
        g_previewNew:SetColor(c.r, c.g, c.b, c.a or 1)
    else
        g_previewNew:SetColor(0, 0, 0, 0)
    end

    local thickness = db.newBorderThickness
    local showBorder = db.showNewBorder and thickness > 0
    for _, line in pairs(g_previewNew._border) do
        line:SetHidden(not showBorder)
        if showBorder then
            local c = db.newBorderColor
            line:SetColor(c.r, c.g, c.b, c.a or 1)
        end
    end
    if showBorder then
        PositionPreviewBorder(g_previewNew, thickness)
    end
end


-- ── Build options menu ────────────────────────────────────────────────────────

local function IndexOfChoice(choices, val)
    for i, v in ipairs(choices) do
        if v == val then return i end
    end
    return 1
end

local function MakeColorPicker(name, tooltip, dbKey, default, disabledKey, db, addon)
    return {
        type     = "colorpicker",
        name     = name,
        tooltip  = tooltip,
        getFunc  = function()
            local c = db[dbKey] or default
            return c.r, c.g, c.b, c.a
        end,
        setFunc  = function(r, g, b, a)
            db[dbKey] = { r = r, g = g, b = b, a = a or 1 }
            addon.Overlay.RefreshAll()
        end,
        disabled = disabledKey and function() return not db[disabledKey] end or nil,
        width    = "half",
        default  = default,
    }
end

local function BuildAreasSubmenu(db, addon, SOURCE)
    return {
        type     = "submenu",
        name     = GetString(SBP_AREAS_SUBMENU),
        controls = {
            {
                type    = "checkbox",
                name    = GetString(SBP_AREAS_SETS_NAME),
                tooltip = GetString(SBP_AREAS_SETS_TOOLTIP),
                getFunc = function() return db.enableSets end,
                setFunc = function(val)
                    db.enableSets = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.SETS)
                    if val then
                        addon.TreeProgress.Refresh()
                    else
                        addon.TreeProgress.Reset()
                    end
                end,
                width   = "half",
                default = true,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_AREAS_COLLECTIONS_NAME),
                tooltip = GetString(SBP_AREAS_COLLECTIONS_TOOLTIP),
                getFunc = function() return db.enableCollections end,
                setFunc = function(val)
                    db.enableCollections = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.COLLECTIONS)
                    if val then
                        addon.TreeProgress.Refresh()
                    else
                        addon.TreeProgress.Reset()
                    end
                end,
                width   = "half",
                default = true,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_AREAS_OUTFITS_NAME),
                tooltip = GetString(SBP_AREAS_OUTFITS_TOOLTIP),
                getFunc = function() return db.enableOutfits end,
                setFunc = function(val)
                    db.enableOutfits = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.OUTFITS)
                    if val then
                        addon.TreeProgress.Refresh()
                    else
                        addon.TreeProgress.Reset()
                    end
                end,
                width   = "half",
                default = true,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_AREAS_LORE_NAME),
                tooltip = GetString(SBP_AREAS_LORE_TOOLTIP),
                getFunc = function() return db.enableLore end,
                setFunc = function(val)
                    db.enableLore = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.LORE)
                    if val then
                        addon.TreeProgress.Refresh()
                    else
                        addon.TreeProgress.Reset()
                    end
                end,
                width   = "half",
                default = true,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_AREAS_ACHIEVEMENTS_NAME),
                tooltip = GetString(SBP_AREAS_ACHIEVEMENTS_TOOLTIP),
                getFunc = function() return db.enableAchievements end,
                setFunc = function(val)
                    db.enableAchievements = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.ACHIEVEMENTS)
                    if val then
                        addon.TreeProgress.Refresh()
                    else
                        addon.TreeProgress.Reset()
                    end
                end,
                width   = "half",
                default = true,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_AREAS_ANTIQUITIES_NAME),
                tooltip = GetString(SBP_AREAS_ANTIQUITIES_TOOLTIP),
                getFunc = function() return db.enableAntiquities end,
                setFunc = function(val)
                    db.enableAntiquities = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.ANTIQUITIES)
                    if val then
                        addon.TreeProgress.Refresh()
                    else
                        addon.TreeProgress.Reset()
                    end
                end,
                width   = "half",
                default = true,
            },
        },
    }
end

local function BuildNewOverlaySubmenu(db, addon)
    return {
        type     = "submenu",
        name     = GetString(SBP_NEW_SUBMENU),
        controls = {
            -- Row 1: checkboxes
            {
                type    = "checkbox",
                name    = GetString(SBP_NEW_BORDER_NAME),
                tooltip = GetString(SBP_NEW_BORDER_TOOLTIP),
                getFunc = function() return db.showNewBorder end,
                setFunc = function(val)
                    db.showNewBorder = val
                    addon.Overlay.RefreshAll()
                    RefreshNewPreview()
                end,
                width   = "half",
                default = true,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_NEW_BACKGROUND_NAME),
                tooltip = GetString(SBP_NEW_BACKGROUND_TOOLTIP),
                getFunc = function() return db.showNewBackground end,
                setFunc = function(val)
                    db.showNewBackground = val
                    addon.Overlay.RefreshAll()
                    RefreshNewPreview()
                end,
                width   = "half",
                default = true,
            },
            -- Row 2: color pickers
            {
                type     = "colorpicker",
                name     = GetString(SBP_NEW_BORDER_COLOR_NAME),
                tooltip  = GetString(SBP_NEW_BORDER_COLOR_TOOLTIP),
                getFunc  = function()
                    local c = db.newBorderColor
                    return c.r, c.g, c.b, c.a
                end,
                setFunc  = function(r, g, b, a)
                    db.newBorderColor = { r = r, g = g, b = b, a = a or 1 }
                    addon.Overlay.RefreshAll()
                    RefreshNewPreview()
                end,
                disabled = function() return not db.showNewBorder end,
                width    = "half",
                default  = { r = 0.9804, g = 1.0, b = 0.0, a = 1.0 },
            },
            {
                type     = "colorpicker",
                name     = GetString(SBP_NEW_BACKGROUND_COLOR_NAME),
                tooltip  = GetString(SBP_NEW_BACKGROUND_COLOR_TOOLTIP),
                getFunc  = function()
                    local c = db.newBackgroundColor
                    return c.r, c.g, c.b, c.a
                end,
                setFunc  = function(r, g, b, a)
                    db.newBackgroundColor = { r = r, g = g, b = b, a = a or 1 }
                    addon.Overlay.RefreshAll()
                    RefreshNewPreview()
                end,
                disabled = function() return not db.showNewBackground end,
                width    = "half",
                default  = { r = 0.0431, g = 1.0, b = 0.0, a = 0.7459 },
            },
            -- Row 3: slider + preview
            {
                type     = "slider",
                name     = GetString(SBP_NEW_BORDER_THICKNESS_NAME),
                tooltip  = GetString(SBP_NEW_BORDER_THICKNESS_TOOLTIP),
                min      = 1,
                max      = 12,
                step     = 1,
                getFunc  = function() return db.newBorderThickness end,
                setFunc  = function(val)
                    db.newBorderThickness = val
                    addon.Overlay.RefreshAll()
                    RefreshNewPreview()
                end,
                disabled = function() return not db.showNewBorder end,
                width    = "half",
                default  = 2,
            },
            {
                type        = "custom",
                reference   = "SBPPreviewNewControl",
                createFunc  = function(ctrl)
                    local lbl = WINDOW_MANAGER:CreateControl("SBPPreviewNewLabel", ctrl, CT_LABEL)
                    lbl:SetFont("ZoFontGameSmall")
                    lbl:SetText(GetString(SBP_NEW_PREVIEW_LABEL))
                    lbl:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 16, 0)
                    g_previewNew = CreatePreviewControl(ctrl, "SBPPreviewNewBg")
                    g_previewNew:ClearAnchors()
                    g_previewNew:SetAnchor(TOPLEFT, lbl, BOTTOMLEFT, 0, 2)
                    RefreshNewPreview()
                end,
                refreshFunc = function(_)
                    RefreshNewPreview()
                end,
                width     = "half",
                minHeight = TILE_SIZE + PREVIEW_PAD * 2 + 22,
            },

            -- Divider
            { type = "divider", width = "full" },

            -- ESO icon
            {
                type    = "checkbox",
                name    = GetString(SBP_NEW_HIDE_ICON_NAME),
                tooltip = GetString(SBP_NEW_HIDE_ICON_TOOLTIP),
                getFunc = function() return db.hideNewIcon end,
                setFunc = function(val)
                    db.hideNewIcon = val
                    addon.Overlay.RefreshAll()
                end,
                width   = "full",
                default = true,
            },
        },
    }
end

local function BuildMissingOverlaySubmenu(db, addon, SOURCE)
    return {
        type     = "submenu",
        name     = GetString(SBP_MISSING_SUBMENU),
        controls = {
            {
                type     = "colorpicker",
                name     = GetString(SBP_MISSING_BACKGROUND_COLOR_NAME),
                tooltip  = GetString(SBP_MISSING_BACKGROUND_COLOR_TOOLTIP),
                getFunc  = function()
                    local c = db.missingBackgroundColor
                    return c.r, c.g, c.b, c.a
                end,
                setFunc  = function(r, g, b, a)
                    db.missingBackgroundColor = { r = r, g = g, b = b, a = a or 1 }
                    addon.Overlay.RefreshAll()
                end,
                disabled = function() return not db.enableSets and not db.enableOutfits and not db.enableCollections and not db.enableLore and not db.enableAchievements and not db.enableAntiquities end,
                width    = "half",
                default  = { r = 1.0, g = 0.2118, b = 0.2118, a = 0.4016 },
            },
            -- Divider
            { type = "divider", width = "full" },
            -- Areas
            {
                type     = "checkbox",
                name     = GetString(SBP_MISSING_SETS_NAME),
                tooltip  = GetString(SBP_MISSING_SETS_TOOLTIP),
                getFunc  = function() return db.showMissingForSets end,
                setFunc  = function(val)
                    db.showMissingForSets = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.SETS)
                end,
                disabled = function() return not db.enableSets end,
                width    = "half",
                default  = true,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_MISSING_OUTFITS_NAME),
                tooltip  = GetString(SBP_MISSING_OUTFITS_TOOLTIP),
                getFunc  = function() return db.showMissingForOutfits end,
                setFunc  = function(val)
                    db.showMissingForOutfits = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.OUTFITS)
                end,
                disabled = function() return not db.enableOutfits end,
                width    = "half",
                default  = true,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_MISSING_COLLECTIONS_NAME),
                tooltip  = GetString(SBP_MISSING_COLLECTIONS_TOOLTIP),
                getFunc  = function() return db.showMissingForCollections end,
                setFunc  = function(val)
                    db.showMissingForCollections = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.COLLECTIONS)
                end,
                disabled = function() return not db.enableCollections end,
                width    = "half",
                default  = true,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_MISSING_LORE_NAME),
                tooltip  = GetString(SBP_MISSING_LORE_TOOLTIP),
                getFunc  = function() return db.showMissingForLore end,
                setFunc  = function(val)
                    db.showMissingForLore = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.LORE)
                end,
                disabled = function() return not db.enableLore end,
                width    = "half",
                default  = true,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_MISSING_ACHIEVEMENTS_NAME),
                tooltip  = GetString(SBP_MISSING_ACHIEVEMENTS_TOOLTIP),
                getFunc  = function() return db.showMissingForAchievements end,
                setFunc  = function(val)
                    db.showMissingForAchievements = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.ACHIEVEMENTS)
                end,
                disabled = function() return not db.enableAchievements end,
                width    = "half",
                default  = true,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_MISSING_ANTIQUITIES_NAME),
                tooltip  = GetString(SBP_MISSING_ANTIQUITIES_TOOLTIP),
                getFunc  = function() return db.showMissingForAntiquities end,
                setFunc  = function(val)
                    db.showMissingForAntiquities = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.ANTIQUITIES)
                end,
                disabled = function() return not db.enableAntiquities end,
                width    = "half",
                default  = true,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_MISSING_FRAGMENTS_NAME),
                tooltip  = GetString(SBP_MISSING_FRAGMENTS_TOOLTIP),
                getFunc  = function() return db.showMissingForAntiquityFragments end,
                setFunc  = function(val)
                    db.showMissingForAntiquityFragments = val
                    addon.Overlay.RefreshTrackedTiles(SOURCE.ANTIQUITY_FRAGMENTS)
                end,
                disabled = function() return not db.enableAntiquities end,
                width    = "half",
                default  = true,
            },
        },
    }
end

-- Per area: "Color" (uses the 4 global color levels from the "Tree Color Levels"
-- submenu) sits directly next to "Show missing piece count" (a text suffix on the
-- category name, independent of coloring).
local function BuildTreeColorSubmenu(db, addon, antiquityColorBasisChoices)
    return {
        type     = "submenu",
        name     = GetString(SBP_TREECOLOR_SUBMENU),
        controls = {
                {
                    type  = "description",
                    text  = GetString(SBP_TREECOLOR_DESC),
                    width = "full",
                },

                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_SETS_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_SETS_CATEGORIES_TOOLTIP),
                    getFunc  = function() return db.colorCategories end,
                    setFunc  = function(val) db.colorCategories = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_COUNT_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_SETS_CATEGORIES_COUNT_TOOLTIP),
                    getFunc  = function() return db.textCategories end,
                    setFunc  = function(val) db.textCategories = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_SUBCATS_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_SUBCATS_TOOLTIP),
                    getFunc  = function() return db.colorSubcats end,
                    setFunc  = function(val) db.colorSubcats = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_SUBCATS_COUNT_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_SUBCATS_COUNT_TOOLTIP),
                    getFunc  = function() return db.textSubcats end,
                    setFunc  = function(val) db.textSubcats = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_SETHEADER_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_SETHEADER_TOOLTIP),
                    getFunc  = function() return db.colorSets end,
                    setFunc  = function(val) db.colorSets = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_SETHEADER_COUNT_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_SETHEADER_COUNT_TOOLTIP),
                    getFunc  = function() return db.textSets end,
                    setFunc  = function(val) db.textSets = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets end,
                    width    = "half",
                    default  = true,
                },

                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_OUTFITS_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_OUTFITS_CATEGORIES_TOOLTIP),
                    getFunc  = function() return db.colorOutfits end,
                    setFunc  = function(val) db.colorOutfits = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableOutfits end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_COUNT_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_OUTFITS_CATEGORIES_COUNT_TOOLTIP),
                    getFunc  = function() return db.textOutfits end,
                    setFunc  = function(val) db.textOutfits = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableOutfits end,
                    width    = "half",
                    default  = true,
                },

                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_COLLECTIONS_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_COLLECTIONS_CATEGORIES_TOOLTIP),
                    getFunc  = function() return db.colorCollections end,
                    setFunc  = function(val) db.colorCollections = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableCollections end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_COUNT_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_COLLECTIONS_CATEGORIES_COUNT_TOOLTIP),
                    getFunc  = function() return db.textCollections end,
                    setFunc  = function(val) db.textCollections = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableCollections end,
                    width    = "half",
                    default  = true,
                },

                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_LORE_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_LORE_CATEGORIES_TOOLTIP),
                    getFunc  = function() return db.colorLore end,
                    setFunc  = function(val) db.colorLore = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableLore end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_COUNT_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_LORE_CATEGORIES_COUNT_TOOLTIP),
                    getFunc  = function() return db.textLore end,
                    setFunc  = function(val) db.textLore = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableLore end,
                    width    = "half",
                    default  = true,
                },
                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_ACHIEVEMENTS_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ACHIEVEMENTS_CATEGORIES_TOOLTIP),
                    getFunc  = function() return db.colorAchievements end,
                    setFunc  = function(val) db.colorAchievements = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAchievements end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_ACHIEVEMENTS_COUNT_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ACHIEVEMENTS_COUNT_TOOLTIP),
                    getFunc  = function() return db.textAchievementsCount end,
                    setFunc  = function(val) db.textAchievementsCount = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAchievements or not db.textAchievements end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_ACHIEVEMENTS_POINTS_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ACHIEVEMENTS_POINTS_TOOLTIP),
                    getFunc  = function() return db.textAchievementsPoints end,
                    setFunc  = function(val) db.textAchievementsPoints = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAchievements or not db.textAchievements end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_ACHIEVEMENTS_MAIN_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ACHIEVEMENTS_MAIN_TOOLTIP),
                    getFunc  = function() return db.textAchievements end,
                    setFunc  = function(val) db.textAchievements = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAchievements end,
                    width    = "half",
                    default  = true,
                },

                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_ACHIEVEMENTS_LINETHUMBS_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_LINETHUMBS_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_LINETHUMBS_TOOLTIP),
                    getFunc  = function() return db.colorAchievementLineThumbs end,
                    setFunc  = function(val) db.colorAchievementLineThumbs = val; addon.TreeProgress.RefreshAchievementLineThumbs() end,
                    disabled = function() return not db.enableAchievements end,
                    width    = "half",
                    default  = true,
                },

                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_ANTIQUITIES_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_CATEGORIES_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ANTIQUITIES_CATEGORIES_TOOLTIP),
                    getFunc  = function() return db.colorAntiquities end,
                    setFunc  = function(val) db.colorAntiquities = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAntiquities end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "dropdown",
                    name     = GetString(SBP_TREECOLOR_ANTIQUITIES_BASIS_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ANTIQUITIES_BASIS_TOOLTIP),
                    choices  = antiquityColorBasisChoices,
                    getFunc  = function() return antiquityColorBasisChoices[db.colorAntiquitiesBasis] end,
                    setFunc  = function(val)
                        db.colorAntiquitiesBasis = IndexOfChoice(antiquityColorBasisChoices, val)
                        addon.TreeProgress.Refresh()
                    end,
                    disabled = function() return not db.enableAntiquities or not db.colorAntiquities end,
                    width    = "half",
                    default  = antiquityColorBasisChoices[Addon.ANTIQUITY_COLOR_BASIS_FOUND],
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_ANTIQUITIES_FOUND_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ANTIQUITIES_FOUND_TOOLTIP),
                    getFunc  = function() return db.textAntiquitiesFound end,
                    setFunc  = function(val) db.textAntiquitiesFound = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAntiquities or not db.textAntiquities end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_ANTIQUITIES_CODEX_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ANTIQUITIES_CODEX_TOOLTIP),
                    getFunc  = function() return db.textAntiquitiesCodex end,
                    setFunc  = function(val) db.textAntiquitiesCodex = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAntiquities or not db.textAntiquities end,
                    width    = "half",
                    default  = true,
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_ANTIQUITIES_MAIN_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_ANTIQUITIES_MAIN_TOOLTIP),
                    getFunc  = function() return db.textAntiquities end,
                    setFunc  = function(val) db.textAntiquities = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAntiquities end,
                    width    = "half",
                    default  = true,
                },

                { type = "divider", width = "full" },

                {
                    type  = "description",
                    title = GetString(SBP_TREECOLOR_SCRYABLE_TITLE),
                    width = "full",
                },
                {
                    type     = "checkbox",
                    name     = GetString(SBP_TREECOLOR_SCRYABLE_NAME),
                    tooltip  = GetString(SBP_TREECOLOR_SCRYABLE_TOOLTIP),
                    getFunc  = function() return db.textAntiquitiesScryable end,
                    setFunc  = function(val) db.textAntiquitiesScryable = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableAntiquities end,
                    width    = "half",
                    default  = true,
                },
        },
    }
end

-- These 4 colors are shared by ALL areas that have their "Color categories"
-- toggle enabled in the previous submenu.
local function BuildColorLevelsSubmenu(db, addon)
    return {
        type     = "submenu",
        name     = GetString(SBP_COLORLEVELS_SUBMENU),
        controls = {
                {
                    type  = "description",
                    text  = GetString(SBP_COLORLEVELS_DESC),
                    width = "full",
                },

                { type = "divider", width = "full" },

                {
                    type     = "checkbox",
                    name     = GetString(SBP_COLORLEVELS_COMPLETE_NAME),
                    tooltip  = GetString(SBP_COLORLEVELS_COMPLETE_TOOLTIP),
                    getFunc  = function() return db.colorCompleteEnabled end,
                    setFunc  = function(val) db.colorCompleteEnabled = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets and not db.enableOutfits and not db.enableCollections and not db.enableLore and not db.enableAchievements and not db.enableAntiquities end,
                    width    = "half",
                    default  = true,
                },
                MakeColorPicker(
                    GetString(SBP_COLORLEVELS_COMPLETE_COLOR_NAME),
                    GetString(SBP_COLORLEVELS_COMPLETE_COLOR_TOOLTIP),
                    "colorComplete",
                    { r = 0.1961, g = 1.0, b = 0.2078, a = 0.7843 },
                    "colorCompleteEnabled",
                    db, addon
                ),
                {
                    type     = "checkbox",
                    name     = GetString(SBP_COLORLEVELS_PARTIAL_NAME),
                    tooltip  = GetString(SBP_COLORLEVELS_PARTIAL_TOOLTIP),
                    getFunc  = function() return db.colorPartialEnabled end,
                    setFunc  = function(val) db.colorPartialEnabled = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets and not db.enableOutfits and not db.enableCollections and not db.enableLore and not db.enableAchievements and not db.enableAntiquities end,
                    width    = "half",
                    default  = true,
                },
                MakeColorPicker(
                    GetString(SBP_COLORLEVELS_PARTIAL_COLOR_NAME),
                    GetString(SBP_COLORLEVELS_PARTIAL_COLOR_TOOLTIP),
                    "colorPartial",
                    { r = 0.6667, g = 0.6667, b = 0.6667, a = 0.7843 },
                    "colorPartialEnabled",
                    db, addon
                ),
                {
                    type     = "checkbox",
                    name     = GetString(SBP_COLORLEVELS_MISSING_NAME),
                    tooltip  = GetString(SBP_COLORLEVELS_MISSING_TOOLTIP),
                    getFunc  = function() return db.colorMissingEnabled end,
                    setFunc  = function(val) db.colorMissingEnabled = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets and not db.enableOutfits and not db.enableCollections and not db.enableLore and not db.enableAchievements and not db.enableAntiquities end,
                    width    = "half",
                    default  = true,
                },
                MakeColorPicker(
                    GetString(SBP_COLORLEVELS_MISSING_COLOR_NAME),
                    GetString(SBP_COLORLEVELS_MISSING_COLOR_TOOLTIP),
                    "colorMissing",
                    { r = 0.7451, g = 0.0118, b = 0.0, a = 0.7843 },
                    "colorMissingEnabled",
                    db, addon
                ),
                {
                    type     = "checkbox",
                    name     = GetString(SBP_COLORLEVELS_SELECTED_NAME),
                    tooltip  = GetString(SBP_COLORLEVELS_SELECTED_TOOLTIP),
                    getFunc  = function() return db.colorSelectedEnabled end,
                    setFunc  = function(val) db.colorSelectedEnabled = val; addon.TreeProgress.Refresh() end,
                    disabled = function() return not db.enableSets and not db.enableOutfits and not db.enableCollections and not db.enableLore and not db.enableAchievements and not db.enableAntiquities end,
                    width    = "half",
                    default  = false,
                },
                MakeColorPicker(
                    GetString(SBP_COLORLEVELS_SELECTED_COLOR_NAME),
                    GetString(SBP_COLORLEVELS_SELECTED_COLOR_TOOLTIP),
                    "colorSelected",
                    { r = 0.3098, g = 0.8706, b = 1.0, a = 1.0 },
                    "colorSelectedEnabled",
                    db, addon
                ),
        },
    }
end

local function BuildSortSubmenu(db, addon)
    return {
        type     = "submenu",
        name     = GetString(SBP_SORT_SUBMENU),
        controls = {
            {
                type  = "description",
                text  = GetString(SBP_SORT_DESC),
                width = "full",
            },

            {
                type     = "checkbox",
                name     = GetString(SBP_SORT_LORE_NAME),
                tooltip  = GetString(SBP_SORT_LORE_TOOLTIP),
                getFunc  = function() return db.sortMissingLore end,
                setFunc  = function(val)
                    db.sortMissingLore = val
                    addon.TreeProgress.RefreshLoreSort()
                end,
                disabled = function() return not db.enableLore end,
                width    = "half",
                default  = false,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_SORT_ANTIQUITIES_NAME),
                tooltip  = GetString(SBP_SORT_ANTIQUITIES_TOOLTIP),
                getFunc  = function() return db.sortMissingAntiquities end,
                setFunc  = function(val)
                    db.sortMissingAntiquities = val
                    addon.TreeProgress.RefreshAntiquitiesSort()
                end,
                disabled = function() return not db.enableAntiquities end,
                width    = "half",
                default  = false,
            },

            {
                type     = "checkbox",
                name     = GetString(SBP_SORT_ACHIEVEMENTS_NAME),
                tooltip  = GetString(SBP_SORT_ACHIEVEMENTS_TOOLTIP),
                getFunc  = function() return db.sortMissingAchievements end,
                setFunc  = function(val)
                    db.sortMissingAchievements = val
                    addon.TreeProgress.RefreshAchievementsSort()
                end,
                disabled = function() return not db.enableAchievements end,
                width    = "half",
                default  = false,
            },
            {
                type     = "checkbox",
                name     = GetString(SBP_SORT_OUTFITS_NAME),
                tooltip  = GetString(SBP_SORT_OUTFITS_TOOLTIP),
                getFunc  = function() return db.sortMissingOutfits end,
                setFunc  = function(val)
                    db.sortMissingOutfits = val
                    addon.TreeProgress.RefreshOutfitSort()
                end,
                disabled = function() return not db.enableOutfits end,
                width    = "half",
                default  = false,
            },

            {
                type     = "checkbox",
                name     = GetString(SBP_SORT_SETS_NAME),
                tooltip  = GetString(SBP_SORT_SETS_TOOLTIP),
                getFunc  = function() return db.sortMissingSets end,
                setFunc  = function(val)
                    db.sortMissingSets = val
                    addon.TreeProgress.RefreshSetSort()
                end,
                disabled = function() return not db.enableSets end,
                width    = "half",
                default  = false,
            },
        },
    }
end

local function BuildMarkAllSubmenu(db, markAllLabelChoices)
    return {
        type     = "submenu",
        name     = GetString(SBP_MARKALL_SUBMENU),
        controls = {
            {
                type    = "checkbox",
                name    = GetString(SBP_MARKALL_SHOWBUTTON_NAME),
                tooltip = GetString(SBP_MARKALL_SHOWBUTTON_TOOLTIP),
                getFunc = function() return db.showMarkAllButton end,
                setFunc = function(val)
                    db.showMarkAllButton = val
                    Addon.MarkAll.RefreshVisibility()
                end,
                width   = "full",
                default = true,
            },
            {
                type     = "dropdown",
                name     = GetString(SBP_MARKALL_LABEL_NAME),
                tooltip  = GetString(SBP_MARKALL_LABEL_TOOLTIP),
                choices  = markAllLabelChoices,
                getFunc  = function() return markAllLabelChoices[db.markAllButtonLabel] end,
                setFunc  = function(val)
                    db.markAllButtonLabel = IndexOfChoice(markAllLabelChoices, val)
                    Addon.MarkAll.RefreshButtonLabel()
                end,
                disabled = function() return not db.showMarkAllButton end,
                width    = "full",
                default  = markAllLabelChoices[Addon.MARK_ALL_LABEL_CLEAR],
            },
        },
    }
end

local function BuildAdvancedSubmenu(db, addon)
    return {
        type     = "submenu",
        name     = GetString(SBP_ADVANCED_SUBMENU),
        controls = {
            {
                type    = "checkbox",
                name    = GetString(SBP_ADVANCED_CHATMSG_NAME),
                tooltip = GetString(SBP_ADVANCED_CHATMSG_TOOLTIP),
                getFunc = function() return db.showChatMessages end,
                setFunc = function(val) db.showChatMessages = val end,
                width   = "full",
                default = true,
            },

            { type = "divider", width = "full" },

            {
                type  = "description",
                title = GetString(SBP_ADVANCED_TOOLTIPID_TITLE),
                text  = GetString(SBP_ADVANCED_TOOLTIPID_DESC),
                width = "full",
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_ADVANCED_SETID_NAME),
                tooltip = GetString(SBP_ADVANCED_SETID_TOOLTIP),
                getFunc = function() return db.showSetIds end,
                setFunc = function(val) db.showSetIds = val end,
                width   = "full",
                default = false,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_ADVANCED_OUTFITID_NAME),
                tooltip = GetString(SBP_ADVANCED_OUTFITID_TOOLTIP),
                getFunc = function() return db.showOutfitId end,
                setFunc = function(val) db.showOutfitId = val end,
                width   = "full",
                default = false,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_ADVANCED_COLLECTIONID_NAME),
                tooltip = GetString(SBP_ADVANCED_COLLECTIONID_TOOLTIP),
                getFunc = function() return db.showCollectionId end,
                setFunc = function(val) db.showCollectionId = val end,
                width   = "full",
                default = false,
            },

            { type = "divider", width = "full" },

            {
                type  = "description",
                title = GetString(SBP_ADVANCED_CROWNSTORE_TITLE),
                text  = GetString(SBP_ADVANCED_CROWNSTORE_DESC),
                width = "full",
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_ADVANCED_COUNTHIDDEN_NAME),
                tooltip = GetString(SBP_ADVANCED_COUNTHIDDEN_TOOLTIP),
                getFunc = function() return db.countHiddenCollectibles end,
                setFunc = function(val)
                    db.countHiddenCollectibles = val
                    addon.TreeProgress.Refresh()
                    addon.Overlay.RefreshAll()
                end,
                disabled = function() return not db.enableCollections and not db.enableOutfits end,
                width   = "full",
                default = false,
            },
            {
                type    = "checkbox",
                name    = GetString(SBP_ADVANCED_CROWNTAG_NAME),
                tooltip = GetString(SBP_ADVANCED_CROWNTAG_TOOLTIP),
                getFunc = function() return db.showCrownTag end,
                setFunc = function(val)
                    db.showCrownTag = val
                    addon.Hooks.RefreshAllCrownTags()
                end,
                disabled = function() return not db.enableCollections and not db.enableOutfits end,
                width   = "half",
                default = false,
            },
            {
                type     = "colorpicker",
                name     = GetString(SBP_ADVANCED_CROWNTAG_COLOR_NAME),
                tooltip  = GetString(SBP_ADVANCED_CROWNTAG_COLOR_TOOLTIP),
                getFunc  = function()
                    local c = db.crownTagColor
                    return c.r, c.g, c.b, c.a
                end,
                setFunc  = function(r, g, b, a)
                    db.crownTagColor = { r = r, g = g, b = b, a = a or 1 }
                    addon.Hooks.RefreshAllCrownTags()
                end,
                disabled = function() return (not db.enableCollections and not db.enableOutfits) or not db.showCrownTag end,
                width    = "half",
                default  = { r = 1.0, g = 0.9333, b = 0.0, a = 1.0 },
            },
        },
    }
end

function Settings.Initialize(addon)
    local LAM = LibAddonMenu2
    if not LAM then return end

    local db = addon.db
    local SOURCE = addon.SOURCE

    local panelData = {
        type                = "panel",
        name                = "Stickerbook+",
        displayName         = "Stickerbook+",
        author              = "R0ctan",
        version             = addon.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local markAllLabelChoices = {
        GetString(SBP_MARKALL_LABEL_REMOVE),
        GetString(SBP_MARKALL_LABEL_CLEAR),
        GetString(SBP_MARKALL_LABEL_DONE),
        GetString(SBP_MARKALL_LABEL_SEEN),
    }

    local antiquityColorBasisChoices = {
        GetString(SBP_ANTIQUITY_BASIS_FOUND),
        GetString(SBP_ANTIQUITY_BASIS_CODEX),
    }

    local optionsData = {
        {
            type  = "description",
            title = nil,
            text  = GetString(SBP_SETTINGS_DESCRIPTION),
            width = "full",
        },
        {
            type    = "checkbox",
            name    = GetString(SBP_SETTINGS_ENABLED_NAME),
            tooltip = GetString(SBP_SETTINGS_ENABLED_TOOLTIP),
            getFunc = function() return db.enabled end,
            setFunc = function(val)
                addon.SetEnabled(val)
            end,
            width   = "full",
            default = true,
        },
        BuildAreasSubmenu(db, addon, SOURCE),
        BuildNewOverlaySubmenu(db, addon),
        BuildMissingOverlaySubmenu(db, addon, SOURCE),
        BuildTreeColorSubmenu(db, addon, antiquityColorBasisChoices),
        BuildColorLevelsSubmenu(db, addon),
        BuildSortSubmenu(db, addon),
        BuildMarkAllSubmenu(db, markAllLabelChoices),
        BuildAdvancedSubmenu(db, addon),
    }

    LAM:RegisterAddonPanel("StickerbookPlus", panelData)
    LAM:RegisterOptionControls("StickerbookPlus", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel.data and panel.data.name == "Stickerbook+" then
            RefreshNewPreview()
        end
    end)
end
