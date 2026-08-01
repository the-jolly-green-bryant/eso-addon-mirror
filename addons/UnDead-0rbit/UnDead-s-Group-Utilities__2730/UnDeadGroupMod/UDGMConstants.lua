JOIN_GROUP_CODE = "UHU Group Invite"

FRIEND_STATUS = { NOT_FRIEND = 0, ONLINE = 1, AWAY = 2, DO_NOT_DISTURB = 3, OFFLINE = 4 }

-- Colors
COLOR_STATUS = {
    [FRIEND_STATUS.NOT_FRIEND]     = "990000",
    [FRIEND_STATUS.ONLINE]         = "89cff0",
    [FRIEND_STATUS.AWAY]           = "873260",
    [FRIEND_STATUS.DO_NOT_DISTURB] = "800020",
    [FRIEND_STATUS.OFFLINE]        = "3d2b1f",
    IN_MY_GROUP                    = "00cc99"
}

ELECTION = { ACTIVE = false, COUNTER = 0, PASSED = true }

-- Define the alias explicitly as the numeric literals to satisfy the union typing.
---@class UDGM_RoleMap
---@field HEALER LFGRole   # 4 (LFG_ROLE_HEAL)
---@field TANK LFGRole     # 2 (LFG_ROLE_TANK)
---@field DPS LFGRole      # 1 (LFG_ROLE_DPS)
---@field INVALID LFGRole  # 0 (LFG_ROLE_INVALID)
---@type UDGM_RoleMap
---@diagnostic disable-next-line: assign-type-mismatch
ROLE = { HEALER = LFG_ROLE_HEAL, TANK = LFG_ROLE_TANK, DPS = LFG_ROLE_DPS, INVALID = LFG_ROLE_INVALID }

QUEUE = { RANDOM_NORMAL_DUNGEON = 62, SOLO_RANDOM_BATTLEGROUND = 67 }
QUEUE_NAMES = {
    [QUEUE.SOLO_RANDOM_BATTLEGROUND] = "Solo Random Battleground",
    [QUEUE.RANDOM_NORMAL_DUNGEON] =
    "Random Normal Dungeon"
}

SKILLPOINT_QUEST_BY_ACTIVITY = {
    -- Base Game (normal only)
    [4] = 4107,
    [300] = 4597,
    [2] = 3993,
    [18] = 4303,
    [3] = 4054,
    [316] = 4555,
    [5] = 4145,
    [308] = 4641,
    [7] = 4336,
    [303] = 4675,
    [6] = 4246,
    [22] = 4813,
    [8] = 4202,
    [10] = 4778,
    [322] = 5120,
    [9] = 4379,
    [317] = 5113,
    [11] = 4346,
    [13] = 4538,
    [12] = 4432,
    [15] = 4589,
    [14] = 4469,
    [16] = 4733,
    [17] = 4822,
    -- DLC (normal only)
    [288] = 5342,
    [289] = 5136,
    [293] = 5403,
    [295] = 5702,
    [324] = 5889,
    [368] = 5891,
    [418] = 6065,
    [420] = 6064,
    [426] = 6186,
    [428] = 6188,
    [433] = 6249,
    [435] = 6251,
    [494] = 6349,
    [496] = 6351,
    [503] = 6414,
    [505] = 6416,
    [507] = 6505,
    [509] = 6507,
    [591] = 6576,
    [593] = 6578,
    [595] = 6683,
    [597] = 6685,
    [599] = 6740,
    [601] = 6742,
    [608] = 6835,
    [610] = 6837,
    [613] = 6896,
    [615] = 7027,
    [638] = 7105,
    [640] = 7155,
    [855] = 7235,
    [857] = 7237,
}
