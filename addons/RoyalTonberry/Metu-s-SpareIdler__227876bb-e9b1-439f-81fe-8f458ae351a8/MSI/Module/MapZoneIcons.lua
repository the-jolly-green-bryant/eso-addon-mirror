-- MapZoneIcons.lua
if MSI == nil then MSI = MSI or {} end
local MSI = _G['MSI']

MSI.MapZoneIDsList = {
--Aldmeri Dominion
    [179] = MSI.Name.."/Media/media_rene_metu.dds",--51, --Auridon
    -- [295] = 11, --Khenarthi's Roost
    -- [181] = 44, --Grahtwood
    -- [19]  = 50, --Greenshade
    -- [12]  = 45, --Malabal Tor
    -- [180] = 60, --Reaper's March
-- --Daggerfall Covenant
    -- [293] = 15, --Stros M'Kai
    -- [294] = 9,  --Betnikh
    [2]   = MSI.Name.."/Media/media_metu_liber.dds",--67, --Glenumbra
    -- [4]   = 70, --Stormhaven
    -- [5]   = 48, --Rivenspir
    -- [18]  = 53, --Alik'r Desert
    -- [15]  = 47, --Bangkorai
-- --Ebonheart Pact
    -- [110] = 12, --Bleakrock Isle
    -- [111] = 9,  --Bal Foyen
    -- [9]   = 76, --Stonefalls
    [11]  = MSI.Name.."/Media/media_icon_metu_liber.dds",--67, --Deshaan
    -- [20]  = 64, --Shadowfen
    -- [16]  = 52, --Eastmarch
    -- [17]  = 73, --The Rift
-- --All other quest/other
    -- [155] = 32, --Coldharbour
    -- [353] = 18, --Craglorn
    -- [38] = 566, --Cyrodiil
}

local function WindowManager()
	local topLevelWindow = WINDOW_MANAGER:CreateTopLevelWindow("IconMetuLiber")
		topLevelWindow:SetDimensions(128, 128)
		topLevelWindow:SetAnchor(CENTER)
		topLevelWindow:SetHidden(true)

	local image = WINDOW_MANAGER:CreateControl("ImageMetuLiber", topLevelWindow, CT_TEXTURE)
		image:SetAnchorFill(topLevelWindow)
		--ImageMetuLiber:SetTexture("EsoUI/Art/Inventory/inventory_tabicon_all_up.dds")
end

local function ZoneChanged()
	local textureIndex = GetCurrentMapZoneIndex()
	local textureImage = MSI.MapZoneIDsList[textureIndex]
	if textureImage ~= nil then
		ImageMetuLiber:SetTexture(textureImage)
		IconMetuLiber:SetHidden(false)
	else
		IconMetuLiber:SetHidden(true)
	end
end

function MSI.ShowZoneIcon()
	if IconMetuLiber:IsHidden() then
		IconMetuLiber:SetHidden(false)
	else
		IconMetuLiber:SetHidden(true)
	end
end

-- InitModMapZoneIcons()
function MSI.InitModMapZoneIcons()
	local function UnRegModuleEvents()
		EVENT_MANAGER:UnregisterForEvent(MSI.Name.."ZoneChanged", EVENT_ZONE_CHANGED)
	end
	local function RegModuleEvents()
		UnRegModuleEvents()
		EVENT_MANAGER:RegisterForEvent(MSI.Name.."ZoneChanged", EVENT_ZONE_CHANGED, ZoneChanged)
	end
	if MSI.SVars.IsMapZoneIcons and MSI.SVars.IsMSIActive then
		RegModuleEvents()
		WindowManager()
		--MSI.Print("d", "Modul enabled!! MapZoneIcons Event registered")
	elseif not MSI.SVars.IsMapZoneIcons or not MSI.SVars.IsMSIActive then
		UnRegModuleEvents()
		--MSI.Print("d", "Modul disabled!! MapZoneIcons Event unregistered")
	else
		UnRegModuleEvents()
		--MSI.Print("d", "MSI |c8B0000not|r Active!! MapZoneIcons Event unregistered")
	end
end
-- eof