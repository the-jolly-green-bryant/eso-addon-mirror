-------------------------------------------
-- moon
-------------------------------------------
cl.mn = {}

local mn = cl.mn

local phaseLength = 30
------------------
-- Phase
------------------
function mn.GetMoonPhase(osT)
    local month = cl.st.GetTime("daytime") * phaseLength
    local fullT = cl.st.GetMoon("full") * month / 100
    local wayT = cl.st.GetMoon("way") / 2 * month / 100
    local newT = cl.st.GetMoon("new") * month / 100
    local phase = fullT + newT + wayT * 2
    local start = mn.CreateFullmoon(cl.st.GetMoon("name"), cl.st.GetMoon("start"))
    local moon

    while start + phase < osT do
        start = start + phase
    end

    local delta = osT - start

    local full = fullT
    local waning = full + wayT
    local new = waning + newT
    local waxing = new + wayT

    if full >= delta then
        moon = "full"
        delta = full - delta
    elseif waning >= delta then
        moon = "waning"
        delta = waning - delta
    elseif new >= delta then
        moon = "new"
        delta = new - delta
    else
        moon = "waxing"
        delta = waxing - delta
    end

    return moon, delta
end

------------------
-- returns the UNIX stamp for fullmoon start
------------------
function mn.CreateFullmoon(name, t)
    local tSinceStart = t
    local month = cl.st.GetTime("daytime") * phaseLength
    local way = cl.st.GetMoon("way") / 2 * month / 100
    local full = cl.st.GetMoon("full") * month / 100

    if name == "new" then
        tSinceStart = tSinceStart - way - full
    end

    return tSinceStart
end