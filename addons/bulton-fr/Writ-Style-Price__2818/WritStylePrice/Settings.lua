WritStylePrice.Settings = {}

-- @var string The name of the setting panel
WritStylePrice.Settings.panelName = "WritStylePriceSettingsPanel"

--[[
-- Initialise the Setting interface
--]]
function WritStylePrice.Settings:init()
    local panelData = {
        type   = "panel",
        name   = WritStylePrice.name,
        author = "bulton-fr",
    }

    WritStylePrice.LAM:RegisterAddonPanel(self.panelName, panelData)
    self:build()
end

--[[
-- Build the settings interface
--]]
function WritStylePrice.Settings:build()
    local optionsData = {
        {
            type = "description",
            text = GetString(SI_WRITSTYLEPRICE_SETTINGS_SCAN_DESC)
        },
        self:buildScanCharBag(),
        self:buildScanBank(),
        self:buildScanHouseBank(),
        {
            type = "header",
            name = GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_TITLE)
        },
        {
            type = "description",
            text = GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_DESC)
        },
        self:buildPreferredPriceOrder(1),
        self:buildPreferredPriceOrder(2),
        self:buildPreferredPriceOrder(3),
        self:buildPreferredPriceOrder(4),
        self:buildPreferredPriceOrder(5)
    }

    WritStylePrice.LAM:RegisterOptionControls(self.panelName, optionsData)
end

--[[
-- Return info to build the setting panel for "scan character bag"
--
-- @return table
--]]
function WritStylePrice.Settings:buildScanCharBag()
    return {
        type    = "checkbox",
        name    = GetString(SI_WRITSTYLEPRICE_SETTINGS_SCAN_CHAR_BAG),
        getFunc = function()
            return WritStylePrice.Collect:obtainScanCharBag()
        end,
        setFunc = function(value)
            WritStylePrice.Collect:defineScanCharBag(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "scan bank"
--
-- @return table
--]]
function WritStylePrice.Settings:buildScanBank()
    return {
        type    = "checkbox",
        name    = GetString(SI_WRITSTYLEPRICE_SETTINGS_SCAN_BANK),
        getFunc = function()
            return WritStylePrice.Collect:obtainScanBank()
        end,
        setFunc = function(value)
            WritStylePrice.Collect:defineScanBank(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "scan house bank"
--
-- @return table
--]]
function WritStylePrice.Settings:buildScanHouseBank()
    return {
        type    = "checkbox",
        name    = GetString(SI_WRITSTYLEPRICE_SETTINGS_SCAN_HOUSE_BANK),
        getFunc = function()
            return WritStylePrice.Collect:obtainScanHouseBank()
        end,
        setFunc = function(value)
            WritStylePrice.Collect:defineScanHouseBank(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "preferred price" order
--
-- @param integer pos The sort order
--
-- @return table
--]]
function WritStylePrice.Settings:buildPreferredPriceOrder(pos)
    return {
        type          = "dropdown",
        name          = zo_strformat("#<<1>>", pos),
        choices       = {
            GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_TTC),
            GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_MM),
            GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_ATT),
            GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_CROWN),
            GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_ROLIS),
        },
        choicesValues = {
            LibPrice.TTC,
            LibPrice.MM,
            LibPrice.ATT,
            LibPrice.CROWN,
            LibPrice.ROLIS
        },
        getFunc       = function()
            return WritStylePrice.Price:obtainOrder()[pos]
        end,
        setFunc       = function(sortOrder)
            WritStylePrice.Price:defineOrder(pos, sortOrder)
        end
    }
end
