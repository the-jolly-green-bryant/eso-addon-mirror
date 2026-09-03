HousingVote = HousingVote or {}

HousingVote.name = "HousingVote"
HousingVote.savedVarsVersion = 1

-- Mail protocol: every message we send/parse carries this tag in the subject
-- so we can tell our own mail apart from everything else in a player's inbox.
HousingVote.PROTOCOL_TAG = "[HousingVote]"
HousingVote.PROTOCOL_VERSION = "HV1"

-- Field/list delimiters used inside the mail body. Free-text fields (rules,
-- house names) are sanitized on the way in to strip these so parsing never
-- breaks on user-entered text.
HousingVote.FIELD_SEP = "|"
HousingVote.LIST_SEP = "~"
HousingVote.SUB_SEP = "^"

-- Message types carried in the body, see Mail.lua for handlers.
HousingVote.MSG = {
    REQUEST = "REQUEST", -- voter -> host: "send me the current contest state"
    INFO    = "INFO",    -- host -> voter: rules + roster snapshot
    INTEREST = "INTEREST", -- voter -> host: "count me in, here is my house"
    VOTE    = "VOTE",    -- voter -> host: ballot
    RESULTS = "RESULTS", -- host -> voter: final tally
}

HousingVote.CONTEST_STATE = {
    NONE = "NONE",
    INTEREST = "INTEREST",   -- accepting interest submissions
    VOTING = "VOTING",       -- roster locked, accepting votes
    CLOSED = "CLOSED",       -- tallied, results published
}

-- Outbound mail is sent from a queue, one every OUTBOUND_SEND_INTERVAL_MS,
-- so a burst of incoming requests can never turn into a mail spam spike.
HousingVote.OUTBOUND_SEND_INTERVAL_MS = 4000
