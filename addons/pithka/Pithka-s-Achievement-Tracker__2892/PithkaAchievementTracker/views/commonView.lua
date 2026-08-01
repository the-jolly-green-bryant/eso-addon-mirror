-- Initialize File
PITHKA = PITHKA or {}
PITHKA.views = PITHKA.views or {}
PITHKA.views.commonView = {}

local commonView = PITHKA.views.commonView
local savedVars = PITHKA.data.savedVars
local ui = PITHKA.ui
local constants = PITHKA.common.constants
local views = PITHKA.views


local worldLookup = {
 ["NA Megaserver"]="PC NA",
 ["EU Megaserver"]="PC EU",
 ["XB1live"] = "XBox NA",
 ["XB1live-eu"] = "XBox EU",
 ["PS4live"] = "PS NA",
 ["PS4live-eu"] = "PS EU",
 ["PTS"] = "PTS"
}

local function GetFriendlyWorldName()
	local rawWorldName = GetWorldName()
	local friendlyWorldName = worldLookup[rawWorldName]
	if friendlyWorldName == nil then
	friendlyWorldName = rawWorldName
	end
	return friendlyWorldName
end

function commonView.initialize()
    -- export button
    local control = ui.button.enumToggleButton({
        size = 50,
        tooltipText = 'Toggle Watermark And QR For Export',
        textureBundle = constants.textureBundles.COMPOSE,
        savedVarKey = 'currentTray',
        enumValue = 'Export',
    })
    control:SetAnchor(BOTTOMRIGHT, PITHKA_GUI, BOTTOMRIGHT, 0, 0)


    -- watermarks (anchor not required for watermark, handled in label function)
    local isHidden = savedVars.get('showWatermark') ~= 'Export'
    local watermarkName = ui.label.watermark{text=GetDisplayName(), vOffset=-150, hidden=isHidden}
    local watermarkDate = ui.label.watermark{text=os.date('%b %d, %y'), vOffset=0, hidden=isHidden}
	local watermarkWorld = ui.label.watermark{text=GetFriendlyWorldName(), vOffset=150, hidden=isHidden}
    
    -- bind watermark to savedVars value using callback
    local function toggleWatermark(var, value)
        if var ~= 'currentTray' then return end
        local isVisible = value == 'Export'
        watermarkName:SetHidden(not isVisible)
        watermarkDate:SetHidden(not isVisible)
		watermarkWorld:SetHidden(not isVisible)
    end
    savedVars.registerCallback(toggleWatermark)

    -- run the callback to set the initial state
    toggleWatermark('currentTray', savedVars.get('currentTray'))

   
    -- info label for group finder
    local infoLabel = ui.label.basic({
        text = 'Click name to queue or teleport, click achievement to link or group, /pgf for group finder.',
        font = constants.font.smallThinFont,
        width = 700,
        color = {1,1,1,1},
        align = TEXT_ALIGN_CENTER,
        parent = PITHKA_GUI,
    })
    infoLabel:SetAnchor(BOTTOM, PITHKA_GUI, BOTTOM, 0, 5)
end