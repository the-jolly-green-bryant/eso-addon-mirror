PBWT = PBWT or {}
PBWT.Config = {
    TITLE = "三旗の戦卓 ― 帝位と星霜 ―",
    SUBTITLE = "The Three Banners War Table",
    SIZE = 5, WIN_SCORE = 10, MAX_TURNS = 30, GUARDIAN_FLAG_BONUS = 1,
    ACTIONS_PER_TURN = 1, CHARGE_DISTANCE = 2, HORN_DISTANCE = 1,
    SCROLL = { COST=4, FLAGS_REQUIRED=2, CENTER_FLAG=2, READER_DEFENSE=1, THREAT_WEIGHT=650 },
    -- Development ID: distinct from 509/510/511, not publicly reserved.
    NETWORK = { DEVELOPMENT_ID = 508, VERSION = 1, BUILD = 1004,
        RETRY = 6, TIMEOUT = 60, INVITE_TIMEOUT = 45, HEARTBEAT = 15, MAX_LOG = 390, SYNC_TIMEOUT = 300 },
    PIECES = {
        soldier = { name = "兵士", attack = 2, defense = 2, move = 1 },
        scout = { name = "斥候", attack = 1, defense = 1, move = 2 },
        guardian = { name = "守護者", attack = 2, defense = 3, move = 1 },
    },
    FLAGS = { { x = 2, y = 3, points = 1 }, { x = 3, y = 3, points = 2 }, { x = 4, y = 3, points = 1 } },
    -- P2 is the exact horizontal reflection of P1, including home squares.
    START = {
        { kind = "soldier", x = 1, y = 1 }, { kind = "soldier", x = 1, y = 3 },
        { kind = "soldier", x = 1, y = 5 }, { kind = "scout", x = 2, y = 1 },
        { kind = "scout", x = 1, y = 4 }, { kind = "guardian", x = 1, y = 2 },
    },
    FACTION_BONUSES = { DOMINION_SCOUT_MOVE=1, COVENANT_FLAG_DEFENSE=1, PACT_GUARDIAN_ATTACK=1 },
    CARD_ORDER = { "charge", "stealth", "siege", "revive", "horn" },
    AI = {
        CANDIDATES_PER_TICK = 8, TICK_MS = 32, THINK_DELAY_MS = 450,
        SCORE_WEIGHT = 100, FLAG_WEIGHT = 18, OCCUPY_WEIGHT = 14,
        APPROACH_WEIGHT = 3, THREAT_WEIGHT = 0.8, CARD_RESERVE = 4,
        HORN_POTENTIAL = 0.25, WIN_VALUE = 100000,
        PIECE_VALUE = { soldier = 10, scout = 8, guardian = 15 },
        SLICE_MS = 2, MAX_THINK_MS = 4000,
        DIFFICULTIES = {
            beginner = { name = "初級", width = 1, nodes = 256, perTick = 8 },
            intermediate = { name = "中級", width = 4, nodes = 800, perTick = 16 },
            advanced = { name = "上級", width = 5, nodes = 1600, perTick = 24, combinations = true },
        },
    },
}
