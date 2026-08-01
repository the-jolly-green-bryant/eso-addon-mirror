LibExoYsUtilities = LibExoYsUtilities or {}

local LibExoY = LibExoYsUtilities

--[[ --------------------------------------------- ]]
--[[ -- Debug-Buffer before Chat Initialization -- ]]
--[[ --------------------------------------------- ]]

-- any debug prior to chat initialization will be buffered 
-- and flushed, once the initial "player activated" event occurs

local debugBuffer = {}
local chatInitialized = false 

local function FlushInitMsgBuffer()
  for _,output in ipairs(debugBuffer) do
    d(output) 
  end
  if not ZO_IsTableEmpty(debugBuffer) then 
    local miniSpacer = LibExoY.ColorString("-------------------------", "gray")
    d( zo_strformat("<<1>> <<2>> <<3>>", miniSpacer, LibExoY.ColorString("LibExoY - Debug Buffer Flushed"), miniSpacer ) )  
    --d("--- LibExoY: debug buffer flushed ---")
  end
  chatInitialized = true 
  debugBuffer = nil 
end


--[[ --------------- ]]
--[[ -- Debug Msg -- ]]
--[[ --------------- ]]

---Inputs: 
-- debug  *string*  displayed text 
-- info   *table*:nilable   [1] = *string*, [2] = color (rgb table, name, or hex)  
-- auth   *bool*:nilable or *func*:nilable  - controls if debug is displayed    

function LibExoY.Debug( debug, info, auth )

  -- early out if debug is no string or empty
  if not LibExoY.IsString(debug) then return end
  if LibExoY.IsStringEmpty(debug) then return end

  --- check for debug trigger
  if not LibExoY.IsNil(auth) then 
    if not LibExoY.IsTrue(auth) then return end 
  end

  local prefix = ""

  --- add time stamp and info to string
  if info then 
    -- build time string
    local time = zo_strformat( "<<1>>.<<2>>", LibExoY.GetTimeString(), tostring(GetGameTimeMilliseconds()):sub(-3) )

    -- build info string
    local infoStr = ""
    if info[1] then infoStr = LibExoY.ColorString( info[1], LibExoY.ColorHex( info[2] ) ) end

    -- add prefix to output
    prefix = zo_strformat( "[<<1>> <<2>>] ", LibExoY.ColorString(time, "gray"), infoStr) 
  end

  --- add debug to message
  local msg = zo_strformat("<<1>><<2>>", prefix, debug) 

  if chatInitialized then 
    d(msg) 
  else 
    table.insert(debugBuffer, msg)
  end
end

--[[ ------------------ ]]
--[[ -- Debug Spacer -- ]]
--[[ ------------------ ]]

function LibExoY.DebugSpacer( auth )
  --- check for auth-trigger
  if not LibExoY.IsNil(auth) then 
    if not LibExoY.IsTrue(auth) then return end 
  end
  LibExoY.Debug( LibExoY.ColorString("--------------------------------------------------", "8F8F8F" ) )
  LibExoY.Debug( LibExoY.ColorString("--------------------------------------------------", "gray" ) ) 
end


--[[ ---------------- ]]
--[[ -- Initialize -- ]]
--[[ ---------------- ]]

local function Initialize()
  LibExoY.RegisterForInitialPlayerActivated( FlushInitMsgBuffer ) 
end
LibExoY.Debug_InitFunc = Initialize

