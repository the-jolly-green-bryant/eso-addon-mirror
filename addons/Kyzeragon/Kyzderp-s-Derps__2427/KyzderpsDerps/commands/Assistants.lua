local KD = KyzderpsDerps

local BANKER = "banker"
local MERCHANT = "merchant"
local DECON = "decon"
local ARMORY = "armory"
local FENCE = "fence"
local COMPANION = "companion"

local KNOWN_ASSISTANTS = {
    [ARMORY] = {
        ["ghrasharog"] = 9745, -- Ghrasharog, Armory Assistant
        ["zuqoth"] = 10618, -- Zuqoth, Armory Advisor
        ["drinweth"] = 11876, -- Drinweth, Valenwood Armorer
        ["voko"] = 13518, -- Voko, Carnaval Weapondancer
    },

    [BANKER] = {
        ["tythis"] = 267, -- Tythis Andromo, the Banker
        ["ezabi"] = 6376, -- Ezabi the Banker
        ["jangleplume"] = 8994, -- Baron Jangleplume, the Banker
        ["steward"] = 9743, -- Factotum Property Steward
        ["pyroclast"] = 11097, -- Pyroclast, Infernace Conservator
        ["eri"] = 12413, -- Eri, Barking Banker
        ["celia"] = 13517, -- Celia Tyde, Lost Fleet Bursar
    },

    [DECON] = {
        ["giladil"] = 10184, -- Giladil the Ragpicker
        ["aderene"] = 10617, -- Aderene, Fargrave Dregs Dealer
        ["tzozabrar"] = 11877, -- Tzozabrar, Dwarven Deconstructor
        ["siluruz"] = 13063, -- Siluruz, Realm Craftsmaster
        ["pontius"] = 14018, -- Pontius Remus, Lupine Scavenger
    },

    [MERCHANT] = {
        ["nuzhimeh"] = 301, -- Nuzhimeh the Merchant
        ["fezez"] = 6378, -- Fezez the Merchant
        ["peddler"] = 8995, -- Peddler of Prizes, the Merchant
        ["delegate"] = 9744, -- Factotum Commerce Delegate
        ["hoarfrost"] = 11059, -- Hoarfrost, Takubar Trader
        ["xyn"] = 12414, -- Xyn, Planar Purveyor
        ["terilorne"] = 13066, -- Terilorne, Dibellan Freetrader
    },

    [FENCE] = {
        ["pirharri"] = 300, -- Pirharri the Smuggler
        ["cambio"] = 14204, -- Cambio Zammes, Rooster in Exile
    },

    [COMPANION] = {
        ["bastian"] = 9245,
        ["mirri"] = 9353,
        ["ember"] = 9911,
        ["isobel"] = 9912,
        ["sharp"] = 11113,
        ["azandar"] = 11114,
        ["tanlorin"] = 12172,
        ["zerith"] = 12173,
    },
}

function KD.InitializeAssistantCommands()
    if (not KD.savedOptions.general.assistantCommands) then return end

    -- TODO: maybe rerun this when updated?
    for aType, assistants in pairs(KNOWN_ASSISTANTS) do
        local available = {}
        -- Make the individual commands regardless
        for cmd, id in pairs(assistants) do
            SLASH_COMMANDS["/" .. cmd] = function() UseCollectible(id) end
            if (IsCollectibleUnlocked(id)) then
                local questState = GetCollectibleAssociatedQuestState(id)
                if (questState ~= COLLECTIBLE_ASSOCIATED_QUEST_STATE_INACTIVE and questState ~= COLLECTIBLE_ASSOCIATED_QUEST_STATE_ACCEPTED) then
                    table.insert(available, id)
                end
            end
        end

        -- Randomizer for overall command like /banker
        if (#available > 0) then
            SLASH_COMMANDS["/" .. aType] = function()
                -- If one of this type is active, just unsummon
                for _, id in ipairs(available) do
                    if (IsCollectibleActive(id)) then
                        KD:msg(string.format("Unsummoning |H1:collectible:%d|h|h...", id))
                        UseCollectible(id)
                        return
                    end
                end

                -- Otherwise, randomize
                local chosen = available[math.random(1, #available)]
                KD:msg(string.format("Summoning |H1:collectible:%d|h|h...", chosen))
                UseCollectible(chosen)
            end
        end
    end
end
