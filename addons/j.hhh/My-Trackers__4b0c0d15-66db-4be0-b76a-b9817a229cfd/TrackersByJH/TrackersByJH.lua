TrackersByJH = TrackersByJH or {}
local TBJH = TrackersByJH
TBJH.name = "TrackersByJH"
TBJH.version = "1.0.6"
TBJH.menus = TBJH.menus or {}

function TrackersByJH_RegisterMenu(name, controls)
    TBJH.menus[name] = controls
end

local SET_TRACKERS = {
    { menu="Arkasis Tracker", key="Arkasis's Genius" },
    { menu="Sul-Xan Tracker", key="Sul-Xan's Torment" },
    { menu="Null Arca Tracker", key="Slivers of the Null Arca" },
    { menu="Mara's Balm Tracker", key="Mara's Balm" },
    { menu="Advancing Yokeda Tracker", key="Berserking Warrior" },
    { menu="Mechanical Acuity Tracker", key="Mechanical Acuity" },
    { menu="Ansuul Tracker", key="Ansuul's Torment" },
    { menu="Aegis Caller Tracker", key="Aegis Caller" },
}

local function SetTrackerControls(key)
    return {
        { type="description", text="This tracker is shown when the set has a complete 5-piece setup on the body, front bar, or back bar. A running cooldown remains visible after the set is unequipped until the cooldown ends." },
        { type="slider", name="Tracker size", min=32, max=300, step=2,
          getFunc=function()
              local p=JHSetTrackers and JHSetTrackers.preferences and JHSetTrackers.preferences.sets[key]
              return (p and p.size) or 64
          end,
          setFunc=function(v)
              local p=JHSetTrackers and JHSetTrackers.preferences and JHSetTrackers.preferences.sets[key]
              if not p then return end
              p.global.size=false; p.size=v
              local c=WINDOW_MANAGER:GetControlByName(key .. "_Container")
              if c then c:SetScale(v/64) end
          end,
          default=64, width="full" },
        { type="slider", name="Gamepad move speed", min=100, max=1000, step=25,
          getFunc=function() return (JHSetTrackers and JHSetTrackers.ConsoleMove and JHSetTrackers.ConsoleMove.speed) or 420 end,
          setFunc=function(v) if JHSetTrackers and JHSetTrackers.ConsoleMove then JHSetTrackers.ConsoleMove.speed=v end end,
          default=420, width="full" },
        { type="button", name="Start move mode", func=function()
              if JHSetTrackers and JHSetTrackers.ConsoleMove then
                  JHSetTrackers.ConsoleMove.Select(key)
                  JHSetTrackers.ConsoleMove.Start()
              end
          end, width="full" },
        { type="button", name="Save position / Stop move mode", func=function()
              if JHSetTrackers and JHSetTrackers.ConsoleMove then
                  -- Deliberately never toggles back on. Repeated button callbacks are safe.
                  JHSetTrackers.ConsoleMove.Stop()
              end
          end, width="full" },
        { type="button", name="Reset position", func=function()
              if JHSetTrackers and JHSetTrackers.ConsoleMove then
                  JHSetTrackers.ConsoleMove.Select(key)
                  JHSetTrackers.ConsoleMove.Reset()
              end
          end, width="full" },
    }
end

local function BuildMainMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end
    LAM:RegisterAddonPanel("TrackersByJHOptions", {
        type="panel", name="Trackers by JH", displayName="Trackers by JH",
        author="JH", version=TBJH.version, registerForRefresh=true, registerForDefaults=true,
    })
    local controls = {
        { type="description", text="All JH trackers in one menu. Select a tracker below to configure it." },
        { type="submenu", name="Bright Harbinger Tracker", controls=TBJH.menus["Bright Harbinger Tracker"] or {} },
        { type="submenu", name="Alkosh Tracker", controls=TBJH.menus["Alkosh Tracker"] or {} },
        { type="submenu", name="Warmask Tracker", controls=TBJH.menus["Warmask Tracker"] or {} },
        { type="header", name="Set Proc Trackers" },
    }
    for _,entry in ipairs(SET_TRACKERS) do
        table.insert(controls, { type="submenu", name=entry.menu, controls=SetTrackerControls(entry.key) })
    end
    LAM:RegisterOptionControls("TrackersByJHOptions", controls)
end

local function OnLoaded(_, addonName)
    if addonName ~= TBJH.name then return end
    EVENT_MANAGER:UnregisterForEvent(TBJH.name .. "_Main", EVENT_ADD_ON_LOADED)
    zo_callLater(BuildMainMenu, 800)
end
EVENT_MANAGER:RegisterForEvent(TBJH.name .. "_Main", EVENT_ADD_ON_LOADED, OnLoaded)
