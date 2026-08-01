local AR_COST_COEFF = 0.78
local AR_TRAIT_COST_COEFF = 0.70

local function getOptionValue(value, defaultValue)

	if value == nil then return defaultValue end	
	return value
end 

function AutoRefine:GetWoodworkingCoeff()
	return getOptionValue(self.settings.woodworkingCoeff, AR_COST_COEFF)
end 

function AutoRefine:GetWoodworkingTraitCoeff()
	return getOptionValue(self.settings.woodworkingTraitCoeff, AR_TRAIT_COST_COEFF)
end 

function AutoRefine:GetClothierCoeff()
	return getOptionValue(self.settings.clothierCoeff, AR_COST_COEFF)
end

function AutoRefine:GetClothierTraitCoeff()
	return getOptionValue(self.settings.clothierTraitCoeff, AR_TRAIT_COST_COEFF)
end

function AutoRefine:GetBlacksmithingCoeff()
	return getOptionValue(self.settings.blacksmithingCoeff, AR_COST_COEFF)
end

function AutoRefine:GetBlacksmithingTraitCoeff()
	return getOptionValue(self.settings.blacksmithingTraitCoeff, AR_TRAIT_COST_COEFF)
end

function AutoRefine:GetJewelrycraftingCoeff()
	return getOptionValue(self.settings.jewelrycraftingCoeff, AR_COST_COEFF)
end

function AutoRefine:GetJewelrycraftingTraitCoeff()
	return getOptionValue(self.settings.jewelrycraftingTraitCoeff, AR_TRAIT_COST_COEFF)
end

function AutoRefine:GetRefineStyleMats()
	return getOptionValue(self.settings.refineStyleMats, false)
end 

function AutoRefine:GetRefineJewelryTraits()
	return getOptionValue(self.settings.refineJewelryTraits, false)
end 

function AutoRefine:GetRefineJewelryBoosters()
	return getOptionValue(self.settings.refineJewelryBoosters, false)
end 

function AutoRefine:GetPrintMMPrice()
	return getOptionValue(self.settings.printMMPrice, true)
end 

function AutoRefine:GetPrintTTCPrice()
	return getOptionValue(self.settings.printTTCPrice, true)
end 

function AutoRefine:GetPrintATTPrice()
	return getOptionValue(self.settings.printATTPrice, true)
end 

function AutoRefine:GetPrintStatistics()
	return getOptionValue(self.settings.printStatistics, true)
end 

function AutoRefine:GetPrintCurrentResult()
	return getOptionValue(self.settings.printCurrentResult, true)
end

function AutoRefine:GetAutoRefine()
	return getOptionValue(self.settings.autoRefine, false)
end  



function resetOptions(options)
	options.woodworkingCoeff = AR_COST_COEFF
	options.clothierCoeff = AR_COST_COEFF
	options.blacksmithingCoeff = AR_COST_COEFF
	options.jewelrycraftingCoeff = AR_COST_COEFF
	options.woodworkingTraitCoeff = AR_TRAIT_COST_COEFF
	options.clothierTraitCoeff = AR_TRAIT_COST_COEFF
	options.blacksmithingTraitCoeff = AR_TRAIT_COST_COEFF
	options.jewelrycraftingTraitCoeff = AR_TRAIT_COST_COEFF
	options.refineStyleMats = false
	options.refineJewelryTraits = false	
	options.refineJewelryBoosters = false
	options.printMMPrice = true
	options.printTTCPrice = true
	options.printATTPrice = true
	options.printStatistics = true
	options.printCurrentResult = true
	options.autoRefine = false
end

function AutoRefine.resetOptions()
	resetOptions(AutoRefine.settings)
end

AutoRefine.OptionsPanel =  
{
     type = "panel",
     name = "AutoRefine",
     registerForRefresh = true,
     displayName = "|c6699CC Auto Refine|r",
     author = "@ihause, Zed",
	 version = "0.9.1",
	 website = "https://esoui.com/downloads/info2175-AutoRefine.html#info",
     registerForRefresh = true,
     registerForDefaults = true,
     resetFunc = AutoRefine.resetSettings
}


function AutoRefine:GetOptions() 

	local options =  
	{
		{
			type = "description",
			text = "Formula for raw mats prices suggestions:\n|c6699CCK * SUM(TemperPrice * TemperProbability)\n+ K * MatPrice * 0.75 [MatProbability]\n+ TK * SUM(TraitPrice * TraitProbability)|r"
		},
		{
			type = "description",
			text = "Formula for trash raw mats prices suggestions:\n|c6699CCK * Sum(TemperPrice * TemperProbability)\n+ 4 [NPC price for mats] * 0.75 [MatProbability]\n+ TK * Sum(TraitPrice * TraitProbability)\r"
		},
		{
			type = "description",
			text = "Recommend reset data after each big game patch."
		},
		{
			type = "header",
			name = "General Prices Suggestions Options"
		},
		{
			type = "checkbox",
			name = "Start To Refining Automatically",
			getFunc = function() return AutoRefine:GetAutoRefine() end,
			setFunc = function(value) AutoRefine.settings.autoRefine = value end,
		},		{
			type = "checkbox",
			name = "Print Current Refining Result",
			getFunc = function() return AutoRefine:GetPrintCurrentResult() end,
			setFunc = function(value) AutoRefine.settings.printCurrentResult = value end,
		},
		{
			type = "checkbox",
			name = "Print Saved Statistics",
			getFunc = function() return AutoRefine:GetPrintStatistics() end,
			setFunc = function(value) AutoRefine.settings.printStatistics = value end,
		},
		
		{
			type = "checkbox",
			name = "Print Master Merchant Prices",
			getFunc = function() return AutoRefine:GetPrintMMPrice() end,
			setFunc = function(value) AutoRefine.settings.printMMPrice = value end,
		},
		{
			type = "checkbox",
			name = "Print Tamriel Trade Center Prices",
			getFunc = function() return AutoRefine:GetPrintTTCPrice() end,
			setFunc = function(value) AutoRefine.settings.printTTCPrice = value end,
		},
		{
			type = "checkbox",
			name = "Print Arkadius Trade Tools Prices",
			getFunc = function() return AutoRefine:GetPrintATTPrice() end,
			setFunc = function(value) AutoRefine.settings.printATTPrice = value end,
		},
		{
			type = "header",
			name = "Woodworking"
		},
		{
			type = "slider",
			name = "K - Price coefficient",
			tooltip = "Using in raw woodworking materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetWoodworkingCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.woodworkingCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},
		{
			type = "slider",
			name = "TK - Traits price coefficient",
			tooltip = "Using in raw woodworking materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetWoodworkingTraitCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.woodworkingTraitCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},
		{
			type = "button",
			name = "Reset Woodworking Data",
			tooltip = "Reset all saved data for woodworking. ",
			func = function() AutoRefine.settings.woodworking = AutoRefine:GetDefaultSkillSettings() end,
			isDangerous = true, 
		},
		{
			type = "header",
			name = "Clothier"
		},
		{
			type = "slider",
			name = "K - Price coefficient",
			tooltip = "Using in raw clothier materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetClothierCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.clothierCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},
		{
			type = "slider",
			name = "TK - Traits price coefficient",
			tooltip = "Using in raw clothier materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetClothierTraitCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.clothierTraitCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},
		{
			type = "button",
			name = "Reset Clothier Data",
			tooltip = "Reset all saved data for clothier",
			func = function() AutoRefine.settings.clothier = AutoRefine:GetDefaultSkillSettings() end,
			isDangerous = true, 
		},
		{
			type = "header",
			name = "Blacksmithing"
		},
		{
			type = "slider",
			name = "K - Price coefficient",
			tooltip = "Using in raw blacksmithing materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetBlacksmithingCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.blacksmithingCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},	
		{
			type = "slider",
			name = "TK - Traits price coefficient",
			tooltip = "Using in raw blacksmithing materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetBlacksmithingTraitCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.blacksmithingTraitCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},
		{
			type = "button",
			name = "Reset Blacksmithing Data",
			tooltip = "Reset all saved data for blacksmithing",
			func = function() AutoRefine.settings.blacksmithing = AutoRefine:GetDefaultSkillSettings() end,
			isDangerous = true, 
		},
		{
			type = "header",
			name = "Jewelrycrafting"
		},
		{
			type = "slider",
			name = "K - Price coefficient",
			tooltip = "Using in raw jewelrycrafting materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetJewelrycraftingCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.jewelrycraftingCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},
		{
			type = "slider",
			name = "TK - Traits price coefficient",
			tooltip = "Using in raw jewelrycrafting materials prices suggestions formula",
			getFunc = function() return AutoRefine:GetJewelrycraftingTraitCoeff() end,
			setFunc = function(value) 
				AutoRefine.settings.jewelrycraftingTraitCoeff = value
			end,
			min = 0,
			max = 1.2,
			step = 0.01,
			decimals = 2
		},
		{
			type = "button",
			name = "Reset Jewelrycraft. Data",
			tooltip = "Reset all saved data for jewelrycrafting",
			func = function() AutoRefine.settings.jewelrycrafting = AutoRefine:GetDefaultSkillSettings() end,
			isDangerous = true, 
		},
		{
			type = "header",
			name = "Additional Refine Options"
		},
		{
			type = "checkbox",
			name = "Refine Style Mats",
			getFunc = function() return AutoRefine:GetRefineStyleMats() end,
			setFunc = function(value) AutoRefine.settings.refineStyleMats = value end,
		},
		{
			type = "checkbox",
			name = "Refine Jewelry Traits",
			getFunc = function() return AutoRefine:GetRefineJewelryTraits() end,
			setFunc = function(value) AutoRefine.settings.refineJewelryTraits = value end,
		},
		{
			type = "checkbox",
			name = "Refine Jewelry Boosters",
			getFunc = function() return AutoRefine:GetRefineJewelryBoosters() end,
			setFunc = function(value) AutoRefine.settings.refineJewelryBoosters = value end,
		}			
	}
		
	return options	
end

function AutoRefine:GetDefaultSkillSettings()
	return	
	{ 
		mat = 0
	}
end

function AutoRefine:GetDefaultSettings()
	
	local settings = 
	{
		woodworking = self:GetDefaultSkillSettings(),
		clothier = self:GetDefaultSkillSettings(),
		blacksmithing = self:GetDefaultSkillSettings(),
		jewelrycrafting = self:GetDefaultSkillSettings()
	}
	
	resetOptions(settings)
	
	return settings
end

local function convertSkillSettings(skill)

    local newSkill = { mat = skill.mat }
	for k,v in pairs(skill) do
		if k ~= "mat" then
			if v < 0 then
			    -- save was corrupted - reset data
				return { mat = 0 }
			else
				newSkill[AutoRefine:GetItemId(k)] = v
			end
		end
	end
	
	return newSkill
end


function AutoRefine:Convert_1_to_2(settings)
	if settings.saveVersion == nil then
    
		settings.woodworking = convertSkillSettings(settings.woodworking)
		settings.clothier = convertSkillSettings(settings.clothier)
		settings.blacksmithing = convertSkillSettings(settings.blacksmithing)
		settings.jewelrycrafting = convertSkillSettings(settings.jewelrycrafting)
		settings.woodworkingCoeff = self:GetWoodworkingCoeff()
		settings.clothierCoeff = self:GetClothierCoeff()
		settings.blacksmithingCoeff = self:GetBlacksmithingCoeff()
		settings.jewelrycraftingCoeff = self:GetJewelrycraftingCoeff()
		settings.woodworkingTraitCoeff = self:GetWoodworkingTraitCoeff()
		settings.clothierTraitCoeff = self:GetClothierTraitCoeff()
		settings.blacksmithingTraitCoeff = self:GetBlacksmithingTraitCoeff()
		settings.jewelrycraftingTraitCoeff = self:GetJewelrycraftingTraitCoeff()
		settings.refineStyleMats = self:GetRefineStyleMats()
		settings.refineJewelryTraits = self:GetRefineJewelryTraits()
		settings.printStatistics = true
		settings.printCurrentResult = true
		
		settings.saveVersion = 2
	end
	
	return settings
end


function AutoRefine:GetSettings() 
	local settings = ZO_SavedVars:NewAccountWide("AutoRefine_Data", 1, nil, self:GetDefaultSettings())	
	settings = self:Convert_1_to_2(settings)	
	return settings	
end

function AutoRefine:InitializeOptions()
	
	local LAM = LibAddonMenu2
	--LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("AutoRefineOptions", AutoRefine.OptionsPanel)
	AutoRefine.options = AutoRefine:GetOptions()
	LAM:RegisterOptionControls("AutoRefineOptions", AutoRefine.options)

end



