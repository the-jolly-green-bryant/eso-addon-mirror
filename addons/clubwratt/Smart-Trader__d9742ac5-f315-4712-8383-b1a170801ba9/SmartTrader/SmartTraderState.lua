-- SmartTraderState.lua: Pure data initialization
-- Creates the initial state structure

local SmartTraderState = {}

function SmartTraderState.Create()
    ---@type SmartTraderState
    return {
        savedVars = {
            guildDataById = {},
            guildDataByTraderName = {},
            nextFlipTime = nil,
            logExport = {
                url = "",
                maxUrlLength = 8191,
            },
        },
        scanState = {
            active = false,
            cancelled = false,
            searchQueue = {},
            currentSearchId = nil,
            currentSearchParams = nil,
            searchesCompleted = 0,
            totalSearches = 0,
            overflowWarnings = {}
        },
        reticleState = {
            lastCheckedGuildId = nil,
            lastCheckedTraderName = nil,
            lastFormattedText = nil
        },
        ---@type MapState
        mapState = {
            -- Hover logging state (transient, not saved)
            hoverLogEnabled = false,
            hoverLogSessionId = 0,
            hoverLogSeenKeys = {}, -- dedupe set: key -> true
            hoverLogLines = {},    -- buffered log lines
            hoverLogKeys = {},     -- parallel array of keys for hoverLogLines (to allow bounded memory)
            hoverLogBytes = 0,     -- approx byte size of hoverLogLines payload (bounded)
        }
    }
end

SmartTrader.State = SmartTraderState
