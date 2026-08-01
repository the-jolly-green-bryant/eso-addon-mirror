-- Create namespace
DsRGuildAllies = {}
local DsRGuildAllies = DsRGuildAllies or {}

DsRGuildAllies.name = "DsRGuildAllies"

DsR_ASSISTANTS =
{
    ASSISTANT_ADERENE                    = 10617,
    ASSISTANT_ALLARIA                    = 396,
    ASSISTANT_BARON_JANGLEPLUME          = 8994,
    ASSISTANT_CASSUS_ANDRONICUS          = 397,
    ASSISTANT_DRINWETH                   = 11876,
    ASSISTANT_ERI                        = 12413,
    ASSISTANT_EZABI                      = 6376,
    ASSISTANT_FACTOTUM_COMMERCE_DELEGATE = 9744,
    ASSISTANT_FACTOTUM_PROPERTY_STEWARD  = 9743,
    ASSISTANT_FEZEZ                      = 6378,
    ASSISTANT_GHRASHAROG                 = 9745,
    ASSISTANT_GILADIL                    = 10184,
    ASSISTANT_HOARFROST                  = 11059,
    ASSISTANT_NUZHIMEH                   = 301,
    ASSISTANT_PEDDLER_OF_PRIZES          = 8995,
    ASSISTANT_PIRHARRI                   = 300,
    ASSISTANT_PYROCLAST                  = 11097,
    ASSISTANT_TYTHIS_ANDROMO             = 267,
    ASSISTANT_TZOZABRAR                  = 11877,
    ASSISTANT_XYN                        = 12414,
    ASSISTANT_ZUQOTH                     = 10618,
}

DsR_COMPANIONS =
{
	COMPANION_AZANDAR_AL_CYBIADES   = 11114,
	COMPANION_BASTIAN_HALLIX        = 9245,
	COMPANION_EMBER                 = 9911,
	COMPANION_ISOBEL_VELOISE        = 9912,
	COMPANION_MIRRI_ELENDIS         = 9353,
	COMPANION_SHARP_AS_NIGHT        = 11113,
	COMPANION_TANLORIN              = 12172,
	COMPANION_ZERITH_VAR            = 12173,
}

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateBindingsAssistants()
    for Ass = 1, GetTotalCollectiblesByCategoryType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT ) do
        local id = GetCollectibleIdFromType( COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, Ass )
        local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(id)
		if unlocked then
			local stringId = "SI_BINDING_NAME_DSRGUILD_ASSISTANT_" .. Ass
			if GetString(_G[stringId]) == "" then
				ZO_CreateStringId(stringId, ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, name))
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateBindingsCompanions()
	for Com = 1, GetTotalCollectiblesByCategoryType( COLLECTIBLE_CATEGORY_TYPE_COMPANION ) do
        local id = GetCollectibleIdFromType( COLLECTIBLE_CATEGORY_TYPE_COMPANION, Com )
        local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(id)
		if unlocked then
            local stringId = "SI_BINDING_NAME_DSRGUILD_COMPANION_" .. Com
		    if GetString(_G[stringId]) == "" then
			    ZO_CreateStringId(stringId, ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, name))
		    end
        end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAllies.OnAddOnLoaded(event, name)

    CreateBindingsAssistants()
    EVENT_MANAGER:RegisterForEvent(DsRGuildAllies.name, EVENT_COLLECTIBLE_UPDATED, CreateBindingsAssistants)
    EVENT_MANAGER:RegisterForEvent(DsRGuildAllies.name, EVENT_COLLECTION_UPDATED, CreateBindingsAssistants)

    CreateBindingsCompanions()
    EVENT_MANAGER:RegisterForEvent(DsRGuildAllies.name, EVENT_COLLECTIBLE_UPDATED, CreateBindingsCompanions)
    EVENT_MANAGER:RegisterForEvent(DsRGuildAllies.name, EVENT_COLLECTION_UPDATED, CreateBindingsCompanions)

    EVENT_MANAGER:UnregisterForEvent(DsRGuildAllies.name, EVENT_ADD_ON_LOADED)
end
