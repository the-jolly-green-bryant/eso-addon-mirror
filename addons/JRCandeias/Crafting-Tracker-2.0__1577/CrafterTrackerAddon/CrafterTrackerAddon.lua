-----------------------------------------------------------------------------------
-----------------------------------  Libraries  -----------------------------------
-----------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

-----------------------------------------------------------------------------------

CrafterTrackerAddon = {}

-- Addon Vars
CrafterTrackerAddon.name    = "CrafterTrackerAddon"
CrafterTrackerAddon.version = 2
CrafterTrackerAddon.Default = {
	OffsetX = 0,
	OffsetY = 0,
	Show = false,
	
}
local hidden = false

local collected = false
local reset = true 
	
local temperingAlloy = 0
local dreughWax = 0
local rosin = 0
local kuta = 0
local perfectRoe = 0
local potentNirncrux = 0
local fortifiedNirncrux = 0

local regulus = 0
local bast = 0
local heartwood = 0
local mundaneRune = 0
local alchemicalResin = 0
local decorativeWax = 0
local cleanPelt = 0
local alchemicalResin = 0

local rudebiteOre = 0
local rawAncestorSilk = 0
local rubedoHideScraps = 0
local alchemicalResin = 0
local roughRubyAsh = 0
local platinumDust = 0
local aetherialDust = 0

local chromiumGrains = 0
local chromiumPlating = 0
local zirconGrains = 0
local zirconPlating = 0

local blessedThistle = 0
local _bugloss = 0
local _columbine = 0
local cornFlower = 0
local _dragonthorn = 0
local ladysSmoke = 0
local mountainFlower = 0
local nightshade = 0
local nirnroot = 0
local waterHyacinth = 0
local wormwood = 0

-- Items Vars
CrafterTrackerAddon.item                 			= {}
CrafterTrackerAddon.item.Tempering_Alloy  			= "|H0:item:54173:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Dreugh_Wax  				= "|H0:item:54177:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Rosin    				  	= "|H0:item:54181:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Kuta       			 	= "|H0:item:45854:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Perfect_Roe  				= "|H0:item:64222:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Potent_Nirncrux 			= "|H0:item:56863:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Fortified_Nirncrux  		= "|H0:item:56862:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

CrafterTrackerAddon.item.Regulus  					= "|H0:item:114889:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Bast  						= "|H0:item:114890:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Heartwood    				= "|H0:item:114895:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Mundane_Rune       		= "|H0:item:114892:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Alchemical_Resin  			= "|H0:item:114893:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Decorative_Wax  			= "|H0:item:114894:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Clean_Pelt  				= "|H0:item:114891:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

CrafterTrackerAddon.item.RubediteOre  				= "|H0:item:71198:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.RawAncestorSilk  			= "|H0:item:71200:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.RubedoHideScraps  			= "|H0:item:71239:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.RoughRubyAsh  				= "|H0:item:71199:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.PlatinumDust  				= "|H0:item:135145:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.AetherialDust  			= "|H0:item:115026:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

CrafterTrackerAddon.item.ChromiumGrains  			= "|H0:item:135154:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.ChromiumPlating  			= "|H0:item:135150:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.ZirconGrains  				= "|H0:item:135153:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.ZirconPlating  			= "|H0:item:135149:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

CrafterTrackerAddon.item.BlessedThistle  			= "|H0:item:30157:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Bugloss  					= "|H0:item:30160:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Columbine  				= "|H0:item:30164:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.CornFlower  				= "|H0:item:30161:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Dragonthorn  				= "|H0:item:30162:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.LadysSmoke  				= "|H0:item:30158:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.MountainFlower  			= "|H0:item:30163:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Nightshade  				= "|H0:item:77590:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Nirnroot  					= "|H0:item:30165:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.WaterHyacinth				= "|H0:item:30166:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
CrafterTrackerAddon.item.Wormwood  					= "|H0:item:30159:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

-----------------------------------------------------------------------------------
---------------------------------  OnAddOnLoaded  ---------------------------------
-----------------------------------------------------------------------------------
function CrafterTrackerAddon.OnAddOnLoaded(event, addonName)
	if addonName ~= CrafterTrackerAddon.name then return end
		CrafterTrackerAddon: Initialize()
	
	EVENT_MANAGER:UnregisterForEvent("CrafterTrackerAddon", EVENT_ADD_ON_LOADED)
	zo_callLater(function() CrafterTrackerAddon.beginInit() end, 2000)
	
	CrafterTrackerAddon: SetDisplay()
end

-----------------------------------------------------------------------------------
-----------------------------------  Initialize  ----------------------------------
-----------------------------------------------------------------------------------
function CrafterTrackerAddon: Initialize()
	CrafterTrackerAddon.SavedVariables = ZO_SavedVars:New("CrafterTrackerAddon_SavedVariables", CrafterTrackerAddon.version, nil, CrafterTrackerAddon.Default)
	
	CrafterTrackerAddon.CreateSettingsWindow()
	CrafterTrackerAddonContainer:SetHidden(not CrafterTrackerAddon.SavedVariables.Show)
	
	CrafterTrackerAddonContainer: ClearAnchors()
	CrafterTrackerAddonContainer: SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CrafterTrackerAddon.SavedVariables.OffsetX, CrafterTrackerAddon.SavedVariables.OffsetY)

	if CrafterTrackerAddon.SavedVariables.Show == true then
		hidden = true
	end
	if CrafterTrackerAddon.SavedVariables.Show == false then
		hidden = false
	end
	
	EVENT_MANAGER:UnregisterForEvent(CrafterTrackerAddon.name, EVENT_ADD_ON_LOADED)
end

function CrafterTrackerAddon: onPlayerActivated()
	
    CrafterTrackerAddon: UpdateUI()
end

function CrafterTrackerAddon: SetDisplay()
    CrafterTrackerAddonShow()
end

-- Update the Addon UI
function CrafterTrackerAddon: UpdateUI()
	if collected == false then
		CrafterTrackerAddon: Set_Stacks_Number()
	end
	if collected == true then
		CrafterTrackerAddon: ShowCollected()
	end
		
end

-- Save Addon Position
function CrafterTrackerAddon.SaveLoc()
	CrafterTrackerAddon.SavedVariables.OffsetX = CrafterTrackerAddonContainer: GetLeft()
	CrafterTrackerAddon.SavedVariables.OffsetY = CrafterTrackerAddonContainer: GetTop()
end

-------------------------------------------------------------------------------------
----------------------------------  Menu Functions ----------------------------------
-------------------------------------------------------------------------------------
function CrafterTrackerAddon.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Crafting Tracker",
		displayName = "|c77ee02Crafting Tracker|r",
		author = "JRCandeias",
		slashCommand = "/ctmenu",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Crafting_Tracker", panelData)
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "|c77ee02Crafting Tracker Settings|r"
		},
		[2] = {
			type = "checkbox",
			name = "Enable Crafting Tracker",
			tooltip = "When ON the Crafting Tracker will be visible at start. When OFF the Crafting Tracker will be hidden at start.",
			default = false,
			getFunc = function() return CrafterTrackerAddon.SavedVariables.Show end,
			setFunc = function(newValue) 
				CrafterTrackerAddon.SavedVariables.Show = newValue
				CrafterTrackerAddonContainer: SetHidden(not newValue)  end,
		}
	}
	LAM2:RegisterOptionControls("Crafting_Tracker", optionsData)
end

-- Process inventory and bank data to get the real amount of an item
function CrafterTrackerAddon: ProcessInventoryData(ItemLink)
    local itemInventory, itemBank, itemCraft = GetItemLinkStacks(ItemLink)
    local total = itemInventory + itemBank + itemCraft
		return total
end

-------------------------------------------------------------------------------------
--------------------------------------  Items ---------------------------------------
-------------------------------------------------------------------------------------
function CrafterTrackerAddon: Set_Stacks_Number()

	-- Tempering Alloy
    local Tempering_Alloy_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Tempering_Alloy)
	local temperingAlloyCollected = Tempering_Alloy_Number - temperingAlloy
	if reset == true then temperingAlloy = Tempering_Alloy_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowTemperingAlloyLabel:SetText(Tempering_Alloy_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowTemperingAlloyLabel:SetText(temperingAlloyCollected) end
	
	-- Dreugh Wax
    local Dreugh_Wax_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Dreugh_Wax)
	local dreughWaxCollected = Dreugh_Wax_Number - dreughWax
	if reset == true then dreughWax = Dreugh_Wax_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowDreughWaxLabel:SetText(Dreugh_Wax_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowDreughWaxLabel:SetText(dreughWaxCollected) end
	
	-- Rosin
    local Rosin_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Rosin)
	local rosinCollected = Rosin_Number - rosin
	if reset == true then rosin = Rosin_Number end
	if collected == false then  CrafterTrackerAddonContainerMaterialRowRosinLabel:SetText(Rosin_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowRosinLabel:SetText(rosinCollected) end
	
	-- Kuta
    local Kuta_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Kuta)
	local kutaCollected = Kuta_Number - kuta
	if reset == true then kuta = Kuta_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowKutaLabel:SetText(Kuta_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowKutaLabel:SetText(kutaCollected) end
	
	-- Perfect Roe
    local Perfect_Roe_Number = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Perfect_Roe)
    local perfectRoeCollected = Perfect_Roe_Number - perfectRoe
	if reset == true then perfectRoe = Perfect_Roe_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowPerfectRoeLabel:SetText(Perfect_Roe_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowPerfectRoeLabel:SetText(perfectRoeCollected) end

    -- Potent Nirncrux
    local Potent_Nirncrux_Number = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Potent_Nirncrux)
    local potentNirncruxCollected = Potent_Nirncrux_Number - potentNirncrux
	if reset == true then potentNirncrux = Potent_Nirncrux_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowPotentNirncruxLabel:SetText(Potent_Nirncrux_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowPotentNirncruxLabel:SetText(potentNirncruxCollected) end
	
	-- Fortified Nirncrux
    local Fortified_Nirncrux_Number = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Fortified_Nirncrux)
    local fortifiedNirncruxCollected = Fortified_Nirncrux_Number - fortifiedNirncrux
	if reset == true then fortifiedNirncrux = Fortified_Nirncrux_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowFortifiedNirncruxLabel:SetText(Fortified_Nirncrux_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowFortifiedNirncruxLabel:SetText(fortifiedNirncruxCollected) end
	
	-- Zircon Plating
    local Zircon_Plating_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.ZirconPlating)
    local zirconPlatingCollected = Zircon_Plating_Number - zirconPlating
	if reset == true then zirconPlating = Zircon_Plating_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowZirconPlatingLabel:SetText(Zircon_Plating_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowZirconPlatingLabel:SetText(zirconPlatingCollected) end
	
	-- Chromium Plating
    local Chromium_Plating_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.ChromiumPlating)
    local chromiumPlatingCollected = Chromium_Plating_Number - chromiumPlating
	if reset == true then chromiumPlating = Chromium_Plating_Number end
	if collected == false then CrafterTrackerAddonContainerMaterialRowChromiumPlatingLabel:SetText(Chromium_Plating_Number) end
	if collected == true then CrafterTrackerAddonContainerMaterialRowChromiumPlatingLabel:SetText(chromiumPlatingCollected) end
	
	-------------------------------------------------------------------------------------
	
	-- Regulus
    local Regulus_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Regulus)
    local regulusCollected = Regulus_Number - regulus
	if reset == true then regulus = Regulus_Number end
	if collected == false then CrafterTrackerAddonContainerFurnitureMaterialRowRegulusLabel:SetText(Regulus_Number) end
	if collected == true then CrafterTrackerAddonContainerFurnitureMaterialRowRegulusLabel:SetText(regulusCollected) end
	
	-- Bast
    local Bast_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Bast)
    local bastCollected = Bast_Number - bast
	if reset == true then bast = Bast_Number end
	if collected == false then CrafterTrackerAddonContainerFurnitureMaterialRowBastLabel:SetText(Bast_Number) end
	if collected == true then CrafterTrackerAddonContainerFurnitureMaterialRowBastLabel:SetText(bastCollected) end
	
	-- Heartwood
    local Heartwood_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Heartwood)
    local heartwoodCollected = Heartwood_Number - heartwood
	if reset == true then heartwood = Heartwood_Number end
	if collected == false then CrafterTrackerAddonContainerFurnitureMaterialRowHeartwoodLabel:SetText(Heartwood_Number) end
	if collected == true then CrafterTrackerAddonContainerFurnitureMaterialRowHeartwoodLabel:SetText(heartwoodCollected) end
	
	-- Mundane Rune
    local Mundane_Rune_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Mundane_Rune)
	local mundaneRuneCollected = Mundane_Rune_Number - mundaneRune
	if reset == true then mundaneRune = Mundane_Rune_Number end
	if collected == false then CrafterTrackerAddonContainerFurnitureMaterialRowMundaneRuneLabel:SetText(Mundane_Rune_Number) end
	if collected == true then CrafterTrackerAddonContainerFurnitureMaterialRowMundaneRuneLabel:SetText(mundaneRuneCollected) end
	
	-- Alchemical Resin
    local Alchemical_Resin_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Alchemical_Resin)
	local alchemicalResinCollected = Alchemical_Resin_Number - alchemicalResin
	if reset == true then alchemicalResin = Alchemical_Resin_Number end
	if collected == false then CrafterTrackerAddonContainerFurnitureMaterialRowAlchemicalResinLabel:SetText(Alchemical_Resin_Number) end
	if collected == true then CrafterTrackerAddonContainerFurnitureMaterialRowAlchemicalResinLabel:SetText(alchemicalResinCollected) end
	
	-- Decorative Wax
    local Decorative_Wax_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Decorative_Wax)
	local decorativeWaxCollected = Decorative_Wax_Number - decorativeWax
	if reset == true then decorativeWax = Decorative_Wax_Number end
	if collected == false then CrafterTrackerAddonContainerFurnitureMaterialRowDecorativeWaxLabel:SetText(Decorative_Wax_Number) end
	if collected == true then CrafterTrackerAddonContainerFurnitureMaterialRowDecorativeWaxLabel:SetText(decorativeWaxCollected) end
	
	-- Clean Pelt
    local Clean_Pelt_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Clean_Pelt)
    local cleanPeltCollected = Clean_Pelt_Number - cleanPelt
	if reset == true then cleanPelt = Clean_Pelt_Number end
	if collected == false then CrafterTrackerAddonContainerFurnitureMaterialRowCleanPeltLabel:SetText(Clean_Pelt_Number) end
	if collected == true then CrafterTrackerAddonContainerFurnitureMaterialRowCleanPeltLabel:SetText(cleanPeltCollected) end
	
	-------------------------------------------------------------------------------------
	
	-- Rubedite Ore
    local Rubedite_Ore_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.RubediteOre)
	local rudebiteOreCollected = Rubedite_Ore_Number - rudebiteOre
	if reset == true then rudebiteOre = Rubedite_Ore_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowRubediteOreLabel:SetText(Rubedite_Ore_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowRubediteOreLabel:SetText(rudebiteOreCollected) end
	
	-- Raw Ancestor Silk
    local Raw_Ancestor_Silk_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.RawAncestorSilk)
	local rawAncestorSilkCollected = Raw_Ancestor_Silk_Number - rawAncestorSilk
	if reset == true then rawAncestorSilk = Raw_Ancestor_Silk_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowRawAncestorSilkLabel:SetText(Raw_Ancestor_Silk_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowRawAncestorSilkLabel:SetText(rawAncestorSilkCollected) end
	
	-- Rubedo Hide Scraps
    local Rubedo_Hide_Scraps_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.RubedoHideScraps)
    local rubedoHideScrapsCollected = Rubedo_Hide_Scraps_Number - rubedoHideScraps
	if reset == true then rubedoHideScraps = Rubedo_Hide_Scraps_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowRubedoHideScrapsLabel:SetText(Rubedo_Hide_Scraps_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowRubedoHideScrapsLabel:SetText(rubedoHideScrapsCollected) end
	
	-- Rough Ruby Ash
    local Rough_Ruby_Ash_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.RoughRubyAsh)
    local roughRubyAshCollected = Rough_Ruby_Ash_Number - roughRubyAsh
	if reset == true then roughRubyAsh = Rough_Ruby_Ash_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowRoughRubyAshLabel:SetText(Rough_Ruby_Ash_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowRoughRubyAshLabel:SetText(roughRubyAshCollected) end
	
	-- Platinum Dust
    local Platinum_Dust_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.PlatinumDust)
    local platinumDustCollected = Platinum_Dust_Number - platinumDust
	if reset == true then platinumDust = Platinum_Dust_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowPlatinumDustLabel:SetText(Platinum_Dust_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowPlatinumDustLabel:SetText(platinumDustCollected) end
	
	-- Aetherial Dust
    local Aetherial_Dust_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.AetherialDust)
    local aetherialDustCollected = Aetherial_Dust_Number - aetherialDust
	if reset == true then aetherialDust = Aetherial_Dust_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowAetherialDustLabel:SetText(Aetherial_Dust_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowAetherialDustLabel:SetText(aetherialDustCollected) end
	
	-- Zircon Grains
    local Zircon_Grains_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.ZirconGrains)
    local zirconGrainsCollected = Zircon_Grains_Number - zirconGrains
	if reset == true then zirconGrains = Zircon_Grains_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowZirconGrainsLabel:SetText(Zircon_Grains_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowZirconGrainsLabel:SetText(zirconGrainsCollected) end
	
	-- Chromium Grains
    local Chromium_Grains_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.ChromiumGrains)
    local chromiumGrainsCollected = Chromium_Grains_Number - chromiumGrains
	if reset == true then chromiumGrains = Chromium_Grains_Number end
	if collected == false then CrafterTrackerAddonContainerRawMaterialRowChromiumGrainsLabel:SetText(Chromium_Grains_Number) end
	if collected == true then CrafterTrackerAddonContainerRawMaterialRowChromiumGrainsLabel:SetText(chromiumGrainsCollected) end
	
	-------------------------------------------------------------------------------------
	
	-- Blessed Thistle
    local Blessed_Thistle_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.BlessedThistle)
    local blessedThistleCollected = Blessed_Thistle_Number - blessedThistle
	if reset == true then blessedThistle = Blessed_Thistle_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowBlessedThistleLabel:SetText(Blessed_Thistle_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowBlessedThistleLabel:SetText(blessedThistleCollected) end
	
	-- Bugloss
    local Bugloss_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Bugloss)
    local buglossCollected = Bugloss_Number - _bugloss
	if reset == true then _bugloss = Bugloss_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowBuglossLabel:SetText(Bugloss_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowBuglossLabel:SetText(buglossCollected) end
	
	-- Columbine
    local Columbine_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Columbine)
    local columbineCollected = Columbine_Number - _columbine
	if reset == true then _columbine = Columbine_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowColumbineLabel:SetText(Columbine_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowColumbineLabel:SetText(columbineCollected) end
	
	-- Corn Flower
    local Corn_Flower_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.CornFlower)
    local cornFlowerCollected = Corn_Flower_Number - cornFlower
	if reset == true then cornFlower = Corn_Flower_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowCornFlowerLabel:SetText(Corn_Flower_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowCornFlowerLabel:SetText(cornFlowerCollected) end
	
	-- Dragonthorn 
    local Dragonthorn_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Dragonthorn)
    local dragonthornCollected = Dragonthorn_Number - _dragonthorn
	if reset == true then _dragonthorn = Dragonthorn_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowDragonthornLabel:SetText(Dragonthorn_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowDragonthornLabel:SetText(dragonthornCollected) end
	
	-- Lady's Smoke 
    local LadysSmoke_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.LadysSmoke)
    local ladysSmokeCollected = LadysSmoke_Number - ladysSmoke
	if reset == true then ladysSmoke = LadysSmoke_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowLadysSmokeLabel:SetText(LadysSmoke_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowLadysSmokeLabel:SetText(ladysSmokeCollected) end
	
	-- Mountain Flower 
    local Mountain_Flower_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.MountainFlower)
    local mountainFlowerCollected = Mountain_Flower_Number - mountainFlower
	if reset == true then mountainFlower = Mountain_Flower_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowMountainFlowerLabel:SetText(Mountain_Flower_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowMountainFlowerLabel:SetText(mountainFlowerCollected) end
	
	-- Nightshade 
    local Nightshade_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Nightshade)
    local nightshadeCollected = Nightshade_Number - nightshade
	if reset == true then nightshade = Nightshade_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowNightshadeLabel:SetText(Nightshade_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowNightshadeLabel:SetText(nightshadeCollected) end
	
	-- Nirnroot 
    local Nirnroot_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Nirnroot)
    local nirnrootCollected = Nirnroot_Number - nirnroot
	if reset == true then nirnroot = Nirnroot_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowNirnrootLabel:SetText(Nirnroot_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowNirnrootLabel:SetText(nirnrootCollected) end
	
	-- Water Hyacinth 
    local Water_Hyacinth_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.WaterHyacinth)
    local waterHyacinthCollected = Water_Hyacinth_Number - waterHyacinth
	if reset == true then waterHyacinth = Water_Hyacinth_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowWaterHyacinthLabel:SetText(Water_Hyacinth_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowWaterHyacinthLabel:SetText(waterHyacinthCollected) end
	
	-- Wormwood 
    local Wormwood_Number  = CrafterTrackerAddon: ProcessInventoryData(CrafterTrackerAddon.item.Wormwood)
    local wormwoodCollected = Wormwood_Number - wormwood
	if reset == true then wormwood = Wormwood_Number end
	if collected == false then CrafterTrackerAddonContainerAlchemyRowWormwoodLabel:SetText(Wormwood_Number) end
	if collected == true then CrafterTrackerAddonContainerAlchemyRowWormwoodLabel:SetText(wormwoodCollected) end
	
	reset = false
	
end

function CrafterTrackerAddon.beginInit()
	--Set up Slash Commands
	CrafterTrackerAddon.initCommands()
	
	--Display message
	d("\n---Crafting Tracker initialized ---\n")

end

-- Toggles the UI ON or OFF
function CrafterTrackerAddonShow()
	hidden = not hidden -- false = true ; true = false 
	CrafterTrackerAddonContainer: SetHidden(hidden) -- Set hidden to whichever
end

-- Toggles the raw materials section ON or Off
function CrafterTrackerAddon: ShowRawMaterials()
	hidden = not hidden -- false = true ; true = false 
	CrafterTrackerAddonContainerRawMaterialRow: SetHidden(hidden) -- Set hidden to whichever
end

-- Toggles the furniture materials section ON or Off
function CrafterTrackerAddon: ShowFurnitureMaterials()
	hidden = not hidden -- false = true ; true = false 
	CrafterTrackerAddonContainerFurnitureMaterialRow: SetHidden(hidden) -- Set hidden to whichever
end

function CrafterTrackerAddon: Reset()
	reset = true
end

function CrafterTrackerAddon: ShowCollected()
	collected = true
	CrafterTrackerAddon.Set_Stacks_Number()
end

function CrafterTrackerAddon: ShowTotal()
	collected = false
	CrafterTrackerAddon.Set_Stacks_Number()
end

-- Bindings
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_CT_UI", "Toogle Crafting Tracker UI")

function CrafterTrackerAddon.initCommands()
	CrafterTrackerAddon_Commands = {}
	CrafterTrackerAddon_Commands["/CrafterTrackerAddon.ToggleUI"] = CrafterTrackerAddonShow	
	
	for k,v in pairs(CrafterTrackerAddon_Commands) do
		SLASH_COMMANDS[k] = v
	end
end

-- Event registration
EVENT_MANAGER:RegisterForEvent(CrafterTrackerAddon.name, EVENT_ADD_ON_LOADED, CrafterTrackerAddon.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(CrafterTrackerAddon.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CrafterTrackerAddon.UpdateUI)
EVENT_MANAGER:RegisterForEvent(CrafterTrackerAddon.name, EVENT_PLAYER_ACTIVATED, CrafterTrackerAddon.onPlayerActivated)