-------------------------------------------
-- Globals
-------------------------------------------
cl = {}

cl.VERSION = "1.0.1"
cl.SAV_VERSION = 0.7

cl.LAM = LibAddonMenu2
cl.LMP = LibMediaProvider

-------------------------------------------
-- main
-------------------------------------------

local lastUpdate = math.huge;

------------------
-- Events
------------------
function cl.OnMoved()
    local x, y = ClockUITime:GetCenter()
    if cl.settings ~= nil and cl.st.IsMoveable() then
        cl.st.SetPosition(x, y)
    end
    cl.vi.UpdateClock()
end

function cl.OnMoonMoved()
    local x, y = ClockUIMoon:GetCenter()
    if cl.settings ~= nil and cl.st.IsMoveable() then
        cl.st.SetMoonPosition(x, y)
    end
    cl.vi.UpdateMoon()
end

function cl.OnUpdate()
    if cl.settings ~= nil then
        if math.floor(GetTimeStamp() - lastUpdate) == 0 then
            return
        end
        lastUpdate = GetTimeStamp()
        if cl.st.IsActive() then
            cl.vi.PrintClock()
        else
            cl.vi.HideClock()
        end
    end
end

function cl.OnLoad(_, addOnName)
    if (addOnName ~= "Clock") then
        return
    end
    cl.st.Init()
    cl.vi.InitClock()
    cl.vi.InitMoon()
    cl.ui.InitSettings()
end

------------------
-- Start
------------------
EVENT_MANAGER:RegisterForEvent("Clock", EVENT_ADD_ON_LOADED, cl.OnLoad)