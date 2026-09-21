PBWT = PBWT or {}
PBWT.Config = {
    TITLE = "三旗の戦卓 ― 帝位と星霜 ―",
    SUBTITLE = "The Three Banners War Table",
    -- Widest board and largest army any variant may declare; the wire format is sized for these.
    MAX_BOARD = 9, MAX_PIECES = 20, GUARDIAN_FLAG_BONUS = 1,
    ACTIONS_PER_TURN = 1, CHARGE_DISTANCE = 2, HORN_DISTANCE = 1,
    SIEGE_ATTACK_BONUS = 1, CARD_MOVE_KINDS = { soldier = true, scout = true },
    SCROLL = { READER_DEFENSE=1, THREAT_WEIGHT=650 },
    -- Development ID: distinct from 509/510/511, not publicly reserved.
    NETWORK = { DEVELOPMENT_ID = 508, VERSION = 1, BUILD = 1200,
        RETRY = 6, TIMEOUT = 60, INVITE_TIMEOUT = 45, HEARTBEAT = 15, MAX_LOG = 390, SYNC_TIMEOUT = 300 },
    PIECES = {
        soldier = { name = "兵士", attack = 2, defense = 2, move = 1 },
        scout = { name = "斥候", attack = 1, defense = 1, move = 2 },
        guardian = { name = "守護者", attack = 2, defense = 3, move = 1 },
    },
    -- Two boards share every rule above. P2 is the exact horizontal reflection of P1 in both,
    -- including home squares, so neither seat gains from the geometry. Per board: the grid,
    -- the army, the keeps, the point threshold, the turn cap, the first-move compensation
    -- (KOMI is the extra points the second seat needs, SECOND_TURN_ACTIONS its opening
    -- actions), whether all-keeps crowns an emperor, and how far the COM may search.
    VARIANT_ORDER = { "light", "standard" },
    VARIANTS = {
        light = { id = 1, key = "light", name = "軽量版", short = "軽量",
            SIZE = 5, WIN_SCORE = 20, MAX_TURNS = 30, EMPEROR = false, KOMI = 1, SECOND_TURN_ACTIONS = 2, NODE_SCALE = 1,
            SCROLL = { COST = 4, FLAGS_REQUIRED = 2, SQUARE = { x = 3, y = 3 }, SQUARE_IS_FLAG = true },
            FLAGS = { { x = 2, y = 3, points = 1 }, { x = 3, y = 3, points = 2 }, { x = 4, y = 3, points = 1 } },
            START = {
                { kind = "soldier", x = 1, y = 1 }, { kind = "soldier", x = 1, y = 3 },
                { kind = "soldier", x = 1, y = 5 }, { kind = "scout", x = 2, y = 1 },
                { kind = "scout", x = 1, y = 4 }, { kind = "guardian", x = 1, y = 2 },
            } },
        -- Cyrodiil's six emperor keeps, kept in their real ring around the Imperial City:
        -- Aleswell and Chalman north, Ash and Blue Road either side, Roebeck and Alessia south.
        standard = { id = 2, key = "standard", name = "スタンダード版", short = "標準",
            SIZE = 9, WIN_SCORE = 60, MAX_TURNS = 40, EMPEROR = true, KOMI = 1, SECOND_TURN_ACTIONS = 3, NODE_SCALE = 3,
            IMPERIAL = { x = 5, y = 5 },
            SCROLL = { COST = 10, FLAGS_REQUIRED = 3, SQUARE = { x = 5, y = 5 }, SQUARE_IS_FLAG = false },
            FLAGS = {
                { x = 4, y = 3, points = 1, name = "アレスウェル", code = "ALE" },
                { x = 6, y = 3, points = 1, name = "チャルマン", code = "CHA" },
                { x = 3, y = 5, points = 1, name = "アッシュ", code = "ASH" },
                { x = 7, y = 5, points = 1, name = "ブルーローズ", code = "BRK" },
                { x = 4, y = 7, points = 1, name = "ローベック", code = "ROE" },
                { x = 6, y = 7, points = 1, name = "アレッシア", code = "ALS" },
            },
            START = {
                { kind = "soldier", x = 1, y = 1 }, { kind = "soldier", x = 1, y = 5 },
                { kind = "soldier", x = 1, y = 9 }, { kind = "soldier", x = 2, y = 3 },
                { kind = "soldier", x = 2, y = 7 }, { kind = "scout", x = 2, y = 1 },
                { kind = "scout", x = 2, y = 5 }, { kind = "scout", x = 2, y = 9 },
                { kind = "guardian", x = 1, y = 3 }, { kind = "guardian", x = 1, y = 7 },
            } },
    },
    FACTION_BONUSES = { DOMINION_SCOUT_MOVE=1, COVENANT_FLAG_DEFENSE=1, PACT_GUARDIAN_ATTACK=1 },
    CARD_ORDER = { "charge", "stealth", "siege", "revive", "horn", "supply" },
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
-- The invite carries the board as a number; both peers must build the same initial state.
function PBWT.Config.VariantKey(id)
    for _,key in ipairs(PBWT.Config.VARIANT_ORDER) do
        if PBWT.Config.VARIANTS[key].id==id then return key end
    end
    return "light"
end
