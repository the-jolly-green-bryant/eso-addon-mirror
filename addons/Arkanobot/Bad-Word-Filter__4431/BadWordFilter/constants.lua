-- constants.lua
BadWordFilter = BadWordFilter or {}

--------------------------------------------------
-- DEFAULT SETTINGS
--------------------------------------------------
BadWordFilter.DEFAULTS = {
    mode = "censor",
    replacementWord = "beep",
    words = {
        "fuck",
        "bitch",
        "moron",
        "retard",
        "asshole",
        "cunt"
    }
}

--------------------------------------------------
-- LEETSPEAK MAP
--------------------------------------------------
BadWordFilter.LEET_MAP = {
    ["@"] = "a", ["4"] = "a",
    ["3"] = "e",
    ["1"] = "i", ["!"] = "i",
    ["0"] = "o",
    ["$"] = "s", ["5"] = "s"
}

--------------------------------------------------
-- CHARACTER CLASSES FOR PATTERN MATCHING
--------------------------------------------------
BadWordFilter.CHAR_CLASSES = {
    a = "[aA@4]",
    b = "[bB]",
    c = "[cC]",
    d = "[dD]",
    e = "[eE3]",
    f = "[fF]",
    g = "[gG]",
    h = "[hH]",
    i = "[iI1!]",
    j = "[jJ]",
    k = "[kK]",
    l = "[lL]",
    m = "[mM]",
    n = "[nN]",
    o = "[oO0]",
    p = "[pP]",
    q = "[qQ]",
    r = "[rR]",
    s = "[sS5$]",
    t = "[tT]",
    u = "[uU]",
    v = "[vV]",
    w = "[wW]",
    x = "[xX]",
    y = "[yY]",
    z = "[zZ]"
}