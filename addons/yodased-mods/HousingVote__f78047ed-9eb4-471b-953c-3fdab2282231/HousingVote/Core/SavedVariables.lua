local HV = HousingVote

local function GetDefaults()
    return {
        -- Contests this character is HOSTING, keyed by contestId.
        hostedContests = {},

        -- Contests this character has JOINED as a voter, keyed by contestId.
        -- Kept separately from hostedContests so a player can be a voter in
        -- someone else's contest and a host of their own at the same time.
        joinedContests = {},

        -- mailId -> true, so we never reprocess the same inbound protocol
        -- mail twice (e.g. if EVENT_MAIL_INBOX_UPDATE fires more than once
        -- before we get around to deleting it).
        seenMailIds = {},
    }
end

function HV.InitSavedVariables()
    HV.sv = ZO_SavedVars:NewAccountWide("HousingVote_SavedVariables", HV.savedVarsVersion, nil, GetDefaults())
end
