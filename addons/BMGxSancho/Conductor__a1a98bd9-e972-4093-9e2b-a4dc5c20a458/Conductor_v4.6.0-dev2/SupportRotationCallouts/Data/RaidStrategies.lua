local C = Conductor
C.RaidStrategies = C.RaidStrategies or {}
local Strategies = C.RaidStrategies

Strategies.VERIFICATION = { VERIFIED="VERIFIED", COMMUNITY_VALIDATED="COMMUNITY_VALIDATED", FOUNDATION="FOUNDATION" }
Strategies.PLANNING_MODES = { RECOMMENDED="RECOMMENDED", ASSISTED="ASSISTED", CUSTOM="CUSTOM" }
Strategies.TRASH_FORMATS = { RECOMMENDED="RECOMMENDED", FOUR_TEAMS_OF_THREE="FOUR_TEAMS_OF_THREE", THREE_TEAMS_OF_FOUR="THREE_TEAMS_OF_FOUR", CUSTOM="CUSTOM" }

Strategies.TRIALS = {
    ["Aetherian Archive"] = {
        code = "AA",
        veteran = {
            { id="AA_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="AA_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="AA_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="AA_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="AA_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Hel Ra Citadel"] = {
        code = "HRC",
        veteran = {
            { id="HRC_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="HRC_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="HRC_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="HRC_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="HRC_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Sanctum Ophidia"] = {
        code = "SO",
        veteran = {
            { id="SO_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="SO_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="SO_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="SO_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="SO_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Maw of Lorkhaj"] = {
        code = "MOL",
        veteran = {
            { id="MOL_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="MOL_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="MOL_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="MOL_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="MOL_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Halls of Fabrication"] = {
        code = "HOF",
        veteran = {
            { id="HOF_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="HOF_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="HOF_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="HOF_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="HOF_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Asylum Sanctorium"] = {
        code = "AS",
        veteran = {
            { id="AS_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="AS_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="AS_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="AS_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="AS_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Cloudrest"] = {
        code = "CR",
        veteran = {
            { id="CR_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="CR_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="CR_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="CR_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="CR_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Sunspire"] = {
        code = "SS",
        veteran = {
            { id="SS_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="SS_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="SS_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="SS_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="SS_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Kyne's Aegis"] = {
        code = "KA",
        veteran = {
            { id="KA_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="KA_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="KA_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="KA_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="KA_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Rockgrove"] = {
        code = "RG",
        veteran = {
            { id="RG_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="COMMUNITY_VALIDATED", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="RG_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="RG_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="COMMUNITY_VALIDATED", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="RG_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="RG_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="COMMUNITY_VALIDATED", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Dreadsail Reef"] = {
        code = "DSR",
        veteran = {
            { id="DSR_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="COMMUNITY_VALIDATED", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="DSR_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="DSR_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="COMMUNITY_VALIDATED", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="DSR_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="DSR_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="COMMUNITY_VALIDATED", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Sanity's Edge"] = {
        code = "SE",
        veteran = {
            { id="SE_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="SE_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="SE_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="SE_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="SE_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Lucent Citadel"] = {
        code = "LC",
        veteran = {
            { id="LC_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="LC_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="LC_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="LC_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="LC_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
    ["Ossein Cage"] = {
        code = "OC",
        veteran = {
            { id="OC_VET_RECOMMENDED", label="Recommended Veteran", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="OC_VET_SAFE", label="Safe Progression", version=1, verification="FOUNDATION", ultimatePattern="ALTERNATING_TEAMS", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        hardmode = {
            { id="OC_HM_RECOMMENDED", label="Recommended Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_WITH_DD_TEAMS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
            { id="OC_HM_SAFE", label="Safe Hard Mode", version=1, verification="FOUNDATION", ultimatePattern="OPENING_RECOVERY_EXECUTE", trashTeamFormat="THREE_TEAMS_OF_FOUR", preBossPolicy="HOLD_FINAL_PULL" },
        },
        trifecta = {
            { id="OC_TRIFECTA_BASELINE", label="Trifecta Baseline", version=1, verification="FOUNDATION", ultimatePattern="SUPPORT_ROTATION_ALL_DDS", trashTeamFormat="FOUR_TEAMS_OF_THREE", preBossPolicy="HOLD_FINAL_PULL" },
        },
    },
}

local function DifficultyKey(difficulty, objective)
    local d = string.lower(tostring(difficulty or "veteran"))
    local o = string.lower(tostring(objective or ""))
    if o == "trifecta" or o == "achievement" or string.find(o, "trifecta", 1, true) then return "trifecta" end
    if d == "hardmode" or d == "hard_mode" or d == "hm" then return "hardmode" end
    return "veteran"
end

function Strategies:GetProfiles(trial, difficulty, objective)
    local trialData = self.TRIALS[tostring(trial or "")]
    if not trialData then return {} end
    return trialData[DifficultyKey(difficulty, objective)] or trialData.veteran or {}
end

function Strategies:GetById(id)
    id = tostring(id or "")
    for trialName, trialData in pairs(self.TRIALS) do
        for _, difficulty in ipairs({"veteran","hardmode","trifecta"}) do
            for _, profile in ipairs(trialData[difficulty] or {}) do
                if profile.id == id then
                    local copy = {}
                    for key, value in pairs(profile) do copy[key] = value end
                    copy.trial = trialName
                    copy.difficultyKey = difficulty
                    return copy
                end
            end
        end
    end
    return nil
end

function Strategies:GetRecommended(trial, difficulty, objective)
    return self:GetProfiles(trial, difficulty, objective)[1]
end

function Strategies:GetItems(trial, difficulty, objective)
    local items = {}
    for _, profile in ipairs(self:GetProfiles(trial, difficulty, objective)) do
        items[#items + 1] = { name=profile.label, data=profile.id }
    end
    if #items == 0 then items[1] = { name="Recommended Baseline", data="" } end
    return items
end
