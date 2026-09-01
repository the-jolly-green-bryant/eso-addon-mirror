-- Common informal chat / MMO vocabulary that a formal English dictionary may omit.
local FSC = FlamechasersSpellcheck
local C = FSC.Chat

C.tokens = {
    ["afk"] = true, ["brb"] = true, ["btw"] = true, ["cya"] = true,
    ["gg"] = true, ["ggs"] = true, ["grats"] = true, ["gz"] = true,
    ["idk"] = true, ["ikr"] = true, ["imo"] = true, ["imho"] = true,
    ["lmao"] = true, ["lol"] = true, ["ngl"] = true, ["omg"] = true,
    ["pls"] = true, ["plz"] = true, ["rofl"] = true, ["tbh"] = true,
    ["thx"] = true, ["ty"] = true, ["wdym"] = true, ["wtf"] = true,
    ["bruh"] = true, ["dunno"] = true, ["gonna"] = true, ["gotta"] = true,
    ["kinda"] = true, ["lemme"] = true, ["nope"] = true, ["sorta"] = true,
    ["wanna"] = true, ["yep"] = true, ["yup"] = true,
    ["hello"] = true, ["hey"] = true, ["hiya"] = true, ["okay"] = true, ["ok"] = true,
    ["sorry"] = true, ["thanks"] = true, ["welcome"] = true, ["np"] = true, ["nvm"] = true,
    ["omw"] = true, ["rn"] = true, ["lfg"] = true, ["lfm"] = true, ["wts"] = true,
    ["wtb"] = true, ["tyvm"] = true, ["ggwp"] = true,

    ["aggro"] = true, ["bis"] = true, ["crit"] = true, ["crits"] = true,
    ["dd"] = true, ["dds"] = true, ["dps"] = true, ["guildie"] = true,
    ["guildies"] = true, ["hm"] = true, ["hms"] = true, ["parse"] = true,
    ["parsed"] = true, ["parsing"] = true, ["proc"] = true, ["procs"] = true,
    ["pug"] = true, ["pugs"] = true, ["pugging"] = true, ["rez"] = true,
    ["rezzed"] = true, ["rezzing"] = true, ["rng"] = true, ["ult"] = true,
    ["ults"] = true, ["vet"] = true, ["vets"] = true, ["wipe"] = true,
    ["wiped"] = true, ["wipes"] = true, ["trifecta"] = true, ["trifectas"] = true,
    ["aoe"] = true, ["aoes"] = true, ["dot"] = true, ["dots"] = true, ["hot"] = true, ["hots"] = true,
    ["gcd"] = true, ["weave"] = true, ["weaving"] = true, ["prebuff"] = true, ["prebuffing"] = true,
    ["backbar"] = true, ["frontbar"] = true, ["mag"] = true, ["stam"] = true, ["pen"] = true,
    ["resists"] = true, ["sustain"] = true, ["uptime"] = true, ["mit"] = true, ["mitigation"] = true,
}

function C.ContainsNormalized(word)
    return C.tokens[word] == true
end

return C
