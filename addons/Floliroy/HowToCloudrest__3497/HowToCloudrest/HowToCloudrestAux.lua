HowToCloudrest = HowToCloudrest or {}
HTC_AUX = {}
local HowToCloudrest = HowToCloudrest
----------------------------------------------------------
--                  Auxilliary functions                --
----------------------------------------------------------
-- Takes a deep copy of a lua table
function HTC_AUX:DeepCopy(obj, seen)
    -- credit: https://gist.github.com/tylerneylon/81333721109155b2d244
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[HTC_AUX:DeepCopy(k, s)] = HTC_AUX:DeepCopy(v, s) end
    return res
end

function HTC_AUX:FadeInControl(control, duration)
  local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, control)
  control:SetAlpha(0)
  control:SetHidden(false)
  animation:SetAlphaValues(0, 1)
  animation:SetDuration(duration or 1000)
  timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
  timeline:PlayFromStart()
end
----------------------------------------------------------
--                      Colors                          --
----------------------------------------------------------
HowToCloudrest.Color = {
    green = function (stringToColor) return "|c00ff00".. stringToColor .. "|r" end,
    yellow = function (stringToColor) return "|cffff00".. stringToColor .. "|r" end,
    red = function (stringToColor) return "|cff0000".. stringToColor .. "|r" end,
    white = function (stringToColor) return "|cffffff".. stringToColor .. "|r" end,

    heavyAttack = function (stringToColor) return "|cff1493".. stringToColor .. "|r" end,

    siroLight = function (stringToColor) return "|cff4500".. stringToColor .. "|r" end,
    releLight = function (stringToColor) return "|c33ccff".. stringToColor .. "|r" end,

    releDark = function (stringToColor) return "|cff3f3f".. stringToColor .. "|r" end,

    galeLight = function (stringToColor) return "|c66EFEF" .. stringToColor .. "|r" end,
    galeDark = function (stringToColor) return "|c3269df".. stringToColor .. "|r" end,

    portalClosed = function (stringToColor) return "|c7e7aff".. stringToColor .. "|r" end,
    portalOpen = function (stringToColor) return "|c4b4999".. stringToColor .. "|r" end,
    portalOne = function (stringToColor) return "|cff4500".. stringToColor .. "|r" end,
    portalTwo = function (stringToColor) return "|c3269df".. stringToColor .. "|r" end,

    zmajaDark = function (stringToColor) return "|cff00ff".. stringToColor .. "|r" end,
    orbs = function (stringToColor) return "|cB439A3".. stringToColor .. "|r" end,

    creeper = function (stringToColor) return "|c2D9239".. stringToColor .. "|r" end,
}

local Color = HowToCloudrest.Color
----------------------------------------------------------
--                      Strings                         --
----------------------------------------------------------
HowToCloudrest.Strings = {
    -- General
    RazorThorns = Color.zmajaDark(">>ROOTED<<"),
    DarkTalons = Color.siroLight(">>ROOTED<<"),

    Mini_Jump_Off_Cooldown = Color.yellow("INC"),
    Mini_Jump_Cast = Color.red("NOW"),

    Mini_Bash_Off_Cooldown = Color.yellow("INC"),
    Mini_Bash_Cast = Color.red("BASH"),
    Mini_Bash_Faded = Color.green("OK"),

    Mini_Skill_Off_Cooldown = Color.yellow("INC"),
    Mini_Skill_Cast = Color.red("NOW"),

    Mini_Dead = Color.green("DEAD"),

    -- Siroria
    Flare = Color.siroLight("        Flare on ") .. Color.white("@Floliroy") .. Color.siroLight(": "),
    FlareFunc = function (name) return Color.siroLight("        Flare on ") .. Color.white(name)  .. Color.siroLight(": ") end,
    FlareExecFunc = function (name1, name2, timer) 
        return Color.white(name1) .. Color.siroLight("|t100%:100%:Esoui/Art/Buttons/large_leftarrow_up.dds|t Flare: ") .. Color.red(timer) 
            .. Color.siroLight("|t100%:100%:Esoui/Art/Buttons/large_rightarrow_up.dds|t") .. Color.white(name2)
    end,

    -- Relequen
    Announcement_ReleBash_Faded = Color.releLight("OK"),
    Announcement_ReleBash_1 = Color.releLight("BASH"),
    Announcement_ReleBash_2 = Color.red(">") .. Color.releLight("BASH") .. Color.red("<"),
    Announcement_ReleBash_3 = Color.red(">>") .. Color.releLight("BASH") .. Color.red("<<"),
    Announcement_ReleBash_4 = Color.red(">>>") .. Color.releLight("BASH") .. Color.red("<<<"), -- never gets used

    Overload_Incoming = Color.releLight("Overload in: "),
    Overload_Static = Color.releDark("DONT SWITCH: "),
    Overload_Tab1 = Color.releLight("DONT ") .. Color.releDark("SWITCH    : "),
    Overload_Tab2 = Color.releDark("   DONT ") .. Color.releLight("SWITCH : "),

    ReleHA = Color.releLight("Smash: "),

    -- Galenwe
    Announcement_GaleBash_Faded = Color.galeDark("OK"),
    Announcement_GaleBash_1 = Color.galeDark("BASH"),
    Announcement_GaleBash_2 = Color.red(">") .. Color.galeDark("BASH") .. Color.red("<"),
    Announcement_GaleBash_3 = Color.red(">>") .. Color.galeDark("BASH") .. Color.red("<<"),
    Announcement_GaleBash_4 = Color.red(">>>") .. Color.galeDark("BASH") .. Color.red("<<<"),
    Announcement_GaleBash_5 = Color.yellow(">>>") .. Color.galeDark("BASH") .. Color.yellow("<<<"),
    Announcement_GaleBash_6 = Color.red(">>>") .. Color.galeDark("BASH") .. Color.red("<<<"),

    Hoarfrost_Base = Color.galeDark("Drop frost: "),
    Hoarfrost_Base_Last = Color.galeDark("Drop ") .. Color.green("LAST") .. Color.galeDark(" frost: "),
    Hoarfrost_Pick_Up = Color.galeDark("Pick up FROST!"),
    Hoarfrost_Incoming = Color.galeDark("FROST ") .. Color.red("INC"),
    Hoarfrost_Drop = Color.galeDark("DROP ") .. Color.red("NOW!"),
    Hoarfrost_Drop_Last = Color.galeDark("DROP ") .. Color.green("LAST") .. Color.galeDark(" FROST ") .. Color.red("NOW!"),

    ChillingComet_Base = Color.galeDark("Comet: "),

    -- Portal
    Portal_Open_Cast_1 = Color.portalOpen("Portal "),
    Portal_Open_Cast_2 = Color.portalOpen(" opening!"),
    Portal_Open_1 = Color.portalOpen("Portal "),
    Portal_Open_2 = Color.portalOpen(" closes: "),
    Portal_Off_Cooldown = Color.yellow("Soon"),
    Portal_Closed_Cast = Color.green("Portal done!"),
    Portal_Closed_1 = Color.portalClosed("Next portal ("),
    Portal_Closed_2 = Color.portalClosed("): "),
    Portal_Out_Of_Time = Color.red("PORTAL FAILED"),

    Portal_Announcement_1 = Color.portalOpen("Portal "),
    Portal_Announcement_2 = Color.portalOpen(" opening!"),

    -- Z'Maja
    ZMaja_Jump_Base = Color.zmajaDark("Z'Maja Jump: "),
    ZMaja_Jump_Off_Cooldown = Color.yellow("INC"),
    ZMaja_Jump_Cast = Color.red("NOW"),

    ZMaja_Bash_Cast_1 = Color.red(">") .. Color.zmajaDark("BASH") .. Color.red("<"),
    ZMaja_Bash_Cast_2 = Color.red(">>") .. Color.zmajaDark("BASH") .. Color.red("<<"),
    ZMaja_Bash_Cast_3 = Color.red(">>>") .. Color.zmajaDark("BASH") .. Color.red("<<<"),
    ZMaja_Bash_Cast_4 = Color.yellow(">>>") .. Color.zmajaDark("BASH") .. Color.yellow("<<<"),
    ZMaja_Bash_Faded = Color.zmajaDark("OK"),

    ZMaja_BanefulMark_Base = Color.zmajaDark("Baneful Mark: "),
    ZMaja_BanefulMark_Off_Cooldown = Color.yellow("INC"),
    ZMaja_BanefulMark_Cast = Color.red("NOW!"),

    ZMaja_CrushingDarkness_Kite_Base = Color.zmajaDark("Kiting: "),
    ZMaja_CrushingDarkness_Kite_Cast = Color.red("NOW"),
    ZMaja_CrushingDarkness_Kite_Faded = Color.green("DONE!"),

    ZMaja_CrushingDarkness_Next_Base = Color.zmajaDark("Next kite: "),
    ZMaja_CrushingDarkness_Next_Off_Cooldown = Color.yellow("INC"),
    ZMaja_CrushingDarkness_Next_Cast = Color.green("NOW"),

    ZMaja_MaliciousSphere_Timer_Next = Color.orbs("Next orbs: "),
    ZMaja_MaliciousSphere_Timer_Kill = Color.red("KILL") .. Color.orbs(" orbs: "),
    ZMaja_MaliciousSphere_Timer_Off_Cooldown = Color.yellow("INC"),
    ZMaja_MaliciousSphere_Timer_Cast = Color.red("NOW"),
    ZMaja_MaliciousSphere_Timer_Failed = Color.red("FAILED"),
    ZMaja_MaliciousSphere_Timer_Success = Color.green("OK"),
    Zmaja_MaliciousSphere_OrbSpawning = Color.orbs("ORBS SPAWNING!"),

    ZMaja_MaliciousSphere_Tracking_Alive = "esoui/art/mappins/battlegrounds_murderball_purple.dds",
    ZMaja_MaliciousSphere_Tracking_Dead = "esoui/art/mappins/battlegrounds_murderball_green.dds",
    ZMaja_MaliciousSphere_Tracking_Collided = "esoui/art/mappins/battlegrounds_murderball_orange.dds",

    Zmaja_CreeperSpawning = Color.creeper("CREEPER SPAWNING!"),
}
