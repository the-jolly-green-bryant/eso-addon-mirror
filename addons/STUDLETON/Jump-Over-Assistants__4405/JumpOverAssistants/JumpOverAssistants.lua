local namespace = "JumpOverAssistants"

local assistants = {
	"Drinweth",
	"Drinweth, Valenwood Armorer",
	"Ghrasharog",
	"Ghrasharog, Armory Assistant",
	"Voko",
	"Voko, Carnaval Weapondancer",
	"Zuqoth",
	"Zuqoth, Armory Advisor",
	"Baron Jangleplume",
	"Baron Jangleplume, the Banker",
	"Celia Tyde",
	"Celia Tyde, Lost Fleet Bursar",
	"Eri",
	"Eri, Barking Banker",
	"Ezabi",
	"Ezabi the Banker",
	"Factotum Property Steward",
	"Pyroclast",
	"Pyroclast, Infernace Conservator",
	"Tythis Andromo",
	"Tythis Andromo, the Banker",
	"Aderene",
	"Aderene, Fargrave Dregs Dealer",
	"Giladil",
	"Giladil the Ragpicker",
	"Siluruz",
	"Siluruz, Realm Craftsmaster",
	"Tzozabrar",
	"Tzozabrar, Dwarven Deconstructor",
	"Factotum Commerce Delegate",
	"Fezez",
	"Fezez the Merchant",
	"Hoarfrost",
	"Hoarfrost, Takubar Trader",
	"Nuzhimeh",
	"Nuzhimeh the Merchant",
	"Peddler of Prizes",
	"Peddler of Prizes, the Merchant",
	"Terilorne",
	"Terilorne, Dibellan Freetrader",
	"Xyn",
	"Xyn, Planar Purveyor",
	"Pirharri",
	"Pirharri the Smuggler",
	"Pontius Remus",
	"Pontius Remus, Lupine Scavenger"
}

EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, function(_, addonName)
	if(addonName ~= namespace) then return end

	ZO_PreHook(RETICLE, "TryHandlingInteraction", function()
		if IsUnitInDungeon("player") and GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT) == 0 then
			local _,text = GetGameCameraInteractableActionInfo()
			if text ~= '' and text ~= nil then
				for _, assistant in ipairs(assistants) do
					if text == assistant then return true end
				end
			end
		end
		return false
	end)

	EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_ADD_ON_LOADED)
end)

