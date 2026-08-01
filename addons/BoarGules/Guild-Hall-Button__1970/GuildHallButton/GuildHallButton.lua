-- $Revision: 1095 $
-- Create namespace
GuildHallButton = {}

-- Name for registering events
GuildHallButton.name = "GuildHallButton"

-- Global locals
local TB_TO_CHAT = GetWorldName() == "PTS"
local QUOTING_COLOUR = ZO_ColorDef:New("A397B4")
local COMMAND_COLOUR = ZO_ColorDef:New("0095B6")
local THROWS = {}
if LibDebugLogger then
    local LOGGER = LibDebugLogger(GuildHallButton.name)
end


--[[
local function throw_exception(id)
-- Code to test exception handling. If the call to throw_exception is in a line where the line number is a key
-- of the table THROWS, deliberately call the non-existent global function exception.
    if THROWS[id] then
        d(string.format("Throwing exception raised at invocation %d", id))
        exception()
    end
end
--]]
    
local function initialize_houses()
--[[
  Create 2 global tables. 
  GuildHallButton.HOUSES: 
      key: ZOS house_id derived by calling GetFastTraveNodeHouseId on all fast travel nodes with a poi type of hose
      value: {node_id, house_name, house_category}
  GuildHallButton.HOUSE_IDS: (inverse of the other tables)
      key:   house_name
      value: house_id
--]]
  GuildHallButton.destination = nil
  GuildHallButton.origin = nil
  GuildHallButton.HOUSES = {}
  GuildHallButton.HOUSE_IDS = {}
  for node_id = 1, GetNumFastTravelNodes() do
    local _, node_name, _, _, _, _, poi, _, _ = GetFastTravelNodeInfo(node_id)
    if poi == POI_TYPE_HOUSE then 
      local house_id = GetFastTravelNodeHouseId(node_id)
      GuildHallButton.HOUSES[house_id] = {node_id=node_id, house_name=node_name, house_category=GetHouseCategoryType(house_id)}
      GuildHallButton.HOUSE_IDS[node_name] = house_id
    end
  end
end

local function tb_d(error, chat_window)
    --[[
      Writes the traceback to saved_variables. If chat_window is set true, also works like d() 
      but sends the lines one at a time, useful for tracebacks that may consist of many lines 
      that would otherwise be truncated.
    --]]
    if not GuildHallButton.Tracebacks then
        GuildHallButton.Tracebacks = {}
    end
    local latest_traceback = {timestamp=os.time(), traceback={}}
    table.insert(GuildHallButton.Tracebacks,1,latest_traceback)
    if type(error) == "string" then
        for line in error:gmatch("[^\r\n]+") do  
            table.insert(latest_traceback.traceback,line)
            if chat_window then d(line) end
        end -- for
    else
        table.insert(latest_traceback.traceback,tostring(error))
        if chat_window then d(error) end
    end
    if #GuildHallButton.Tracebacks > 9 then
        table.remove(GuildHallButton.Tracebacks)
    end
end -- function

local function report_error (activity, error) 
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(activity .. "\n" .. 
            -- i18n: This follows: Error executing command ...
            gettext.gettext('to see the traceback: ')..
            -- i18n: This follows: to see the traceback
            QUOTING_COLOUR:Colorize(gettext.gettext('/gh traceback'))))
    tb_d(error,TB_TO_CHAT)
    end

local function guild_no_lookup(guild_id)
  --[[
    Inverse of GetGuildId. Translate guild id's to guild numbers 1..5 
  --]]
  for i = 1,GetNumGuilds() do 
    --d(string.format("Checking guild no %s of %s for a match with guild id %s ", i, GetNumGuilds(), guild_id)) 
    if GetGuildId(i) == guild_id then
      --d(string.format("Matched guild no %s of %s with guild id %s ", i, GetNumGuilds(), guild_id)) 
      return i
      end
  end
  --d(string.format("Could not match any guild 1..%s with guild id %s ", GetNumGuilds(), guild_id)) 
  return nil
end

local function make_empty_guildhall(name, open, castellan, house_override)
   return {name=name, open=open, castellan=castellan, house_overrid=house_override} 
end

local function initialize_guild_halls()
-- Return an array [1..5] of name: string, open: boolean, castellan: string, house_override: string
-- If n is a valid guild then name = "Greatest Guild Ever Guild Hall" and open is true  
-- Otherwise name = "Guild Hall n" and open is false
  local GuildHallNames = {}

  for guild_no = 1, 5 do
    --i18n: Makes dummy name of the form guild hall 3
    GuildHallNames[guild_no] = make_empty_guildhall(zo_strformat("<<z:1>> <<2>>",gettext.gettext("Guild Hall"), guild_no), false)
  end

  for guild_no = 1,5 do
    local guild_id = GetGuildId(guild_no)
    if ZO_ValidatePlayerGuildId(guild_id) then
      --i18n: Placeholder guild hall name for screen until we jump there and learn what it is
      zo_strformat(gettext.gettext("Guild Hall <<G:1>>"), GetGuildName(guild_id))
      GuildHallNames[guild_no].open = true
    end
  end
  return GuildHallNames
end

local function refresh_guild_names()
-- Return a table, key: Guild name, value: guild no (1..5) 
-- Later, a value of nil will indicate a guild that the player was in but left.
local guild_names = {}
  for guild_no = 1, GetNumGuilds() do
    local guild_id = GetGuildId(guild_no)
    guild_names[GetGuildName(guild_id)] = guild_no
  end
  return guild_names
end

local function report_traceback(keyword, n)
    -- i18n: Echo in chat window to /guildhall traceback
    -- i18n: <<1>> is what the user typed eg trace; <<2>> is the traceback number
    local prologue = COMMAND_COLOUR:Colorize(zo_strformat(gettext.gettext("/guildhall <<1>> <<2>>"), keyword, n))
    -- i18n: <<1>> is the traceback number
    local tb = GuildHallButton.Tracebacks[n]
    if not tb or #tb.traceback == 0 then
        -- i18n: Alert in response in chat window to /guildhall traceback
        -- i18n: <<1>> is the traceback number that does not exist
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("No traceback numbered <<1>> is available"),n))
    else
        local tb_traceback = {unpack(tb.traceback)}
        -- i18n: <<1>> is a traceback number, 1..9, most recent is 1; <<2>> is a datetime
        -- i18n: <<1>> is a traceback number, 1..9, most recent is 1; <<2>> is a datetime
        local tb_title = zo_strformat(gettext.gettext("Guild Hall Button traceback <<1>> from <<2>>"), n, os.date("%Y-%m-%d %H:%M", tb.timestamp))
        if n > 1 then
            local match = #tb_traceback > 1
            for k,v in ipairs(tb_traceback) do match = match and GuildHallButton.Tracebacks[n-1].traceback[k] == v end
            if match then
                -- i18n: <<1>> is a traceback number, 2..9, most recent is 1; <<2>> is a datetime; <<3>> is the previous number 1..8 
                -- i18n: <<1>> is a traceback number, 2..9, most recent is 1; <<2>> is a datetime; <<3>> is the previous number 1..8 
                tb_title = zo_strformat(gettext.gettext("Guild Hall Button traceback <<1>> from <<2>>: identical to traceback <<3>>"), n, os.date("%Y-%m-%d %H:%M", tb.timestamp), n-1)
            end 
        end
        table.insert(tb_traceback, 1, COMMAND_COLOUR:Colorize(tb_title))
        if ZO_ERROR_FRAME.suppressErrorDialog then
            ZO_ERROR_FRAME:ToggleSupressDialog()
        end
        --GetControl(ZO_ERROR_FRAME.control, "Title"):SetText(tb_title)
        ZO_ERROR_FRAME.displayingError = false
        ZO_ERROR_FRAME:OnUIError(table.concat(tb_traceback,"\n"))
    end
end

local function report_version(keyword)
    -- i18n: Code is expecting a Subversion $Id string
    local _, _, fn, rev, dt, usr = string.find(gettext.gettext("Translation Version"), "$Id:%s+(%S+)%s+(%S+)%s+(%S+%s+%S+)%s+(%S+)")  
    --'$Id: GuildHallButton.lua 1095 2024-08-18 13:25:05Z paulk $'
    
    local version_text = {  
                        zo_strformat(gettext.gettext("Add-on version is <<1>>.<<2>>.<<3>>+<<4>>"),
                            GuildHallButtonVersion.major, 
                            GuildHallButtonVersion.minor, 
                            GuildHallButtonVersion.patch, 
                            GuildHallButtonVersion.build) .. "\n",
                        zo_strformat(gettext.gettext("API version is <<1>>"),  GetAPIVersion()) .. "\n",
                        zo_strformat(gettext.gettext("Add-on compatibility is <<1>> and <<2>>"), GuildHallButtonVersion.current_api, GuildHallButtonVersion.future_api) .. "\n",
                        zo_strformat(gettext.gettext("Translation Version <<1>> <<2>> <<3>>"), fn, rev, dt)
                        }
        
    ZO_Dialogs_ShowDialog("GuildHallButtonVersionDialog", {}, 
                          { mainTextParams = version_text }           
                         )
    end


local function report_configuration(keyword)
  -- i18n: Echoes the slash command in the chat window
  try 
    {
    function()
        local report = {}
        for guild_no = 1,5 do
          local guild_id = GetGuildId(guild_no)
          if ZO_ValidatePlayerGuildId(guild_id) then
              if GuildHallButton.GuildHallNames[guild_no].open then
                local house_name = gettext.gettext("principal residence")
                -- i18n: Appears in configuration report in response to /gh list command
                if GuildHallButton.GuildHallNames[guild_no].house_override then
                   house_name = GuildHallButton.HOUSES[GuildHallButton.GuildHallNames[guild_no].house_override].house_name 
                   -- local house_name = GuildHallButton.GuildHallNames[guild_no].house_override 
                end
                -- i18n: Appears in configuration report in response to /gh list command 
                local castellan = GuildHallButton.GuildHallNames[guild_no].castellan or gettext.gettext("guild leader")
                local zh_format = "<<Z:1>> (<<2>>)\n<<3>>: <<4>>\n"
                report[#report+1] = 
                  zo_strformat(zh_format, GetGuildName(guild_id), guild_id, castellan, house_name)
              end -- if open  
          end --if valid guild
        end --for
     report[#report] = string.sub(report[#report],1,-2)   -- remove trailing CR
     ZO_Dialogs_ShowDialog("GuildHallButtonDestinationDialog", {}, 
                          { mainTextParams = report }
                          )
--[[ For screenshots
     ZO_Dialogs_ShowDialog("GuildHallButtonDestinationDialog", {}, 
                          { mainTextParams = 
                            {"RICH MAHOGANY (34567)\nguild leader: principal residence\n",
                             "RANGIEST RANGERS (12345)\n@Slartibartfast: principal residence\n",
                             "MERCHANTS OF THE MERCHANTS (23456)\nguild leader: principal residence"},
                          }
                          )
]]--


        
     --[[throw_exception(2)]]
     end, --function
    except 
       {
       function(error)
           -- i18n Exception trap in processing /gh list
           report_error(gettext.gettext('Configuration report failed:'), error)
       end
       } -- except
     } --try
end


local function register_slash_commands()
    local lsc = LibSlashCommander
    -- i18n: Slash commands
    local slash_commands = {gettext.gettext("/guildhall"),gettext.gettext("/gh")}
    local registerable_slash_commands = {}
    local conflicting_slash_commands = {}
    for _, sc in pairs(slash_commands) do
        if SLASH_COMMANDS[sc] then
            table.insert(conflicting_slash_commands, sc)
        else
            table.insert(registerable_slash_commands, sc)
        end
    end
    if #registerable_slash_commands ~= #slash_commands then
        -- i18n: slash commands restricted due to conflicts
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, 
                        zo_strformat(gettext.gettext(
                        "Guild Hall Button cannot register <<1[any/the following/the following]>> slash " .. 
                        "<<1[command/command/commands]>> due to <<1[conflicts/a conflict/conflicts]>>: " .. 
                        "<<2>> will not work as described because <<1[it has/it has/they have]>> " .. 
                        "been registered by the game or <<1[.../another add-on/other add-ons]>>."), #conflicting_slash_commands, 
                        COMMAND_COLOUR:Colorize(ZO_GenerateCommaSeparatedList(conflicting_slash_commands,", ")))) 
    end   
    if #registerable_slash_commands and lsc then
        local cmd = lsc:Register( registerable_slash_commands,
                                  function(cmd) GuildHallButton.process_slash_gh_command(cmd) end,
                                  -- i18n: Meaning of slash command (for hint)
                                  gettext.gettext("Travel to Guild Hall"))
        GuildHallButton.slashcommand = cmd
        
        local subcmd2 = cmd:RegisterSubCommand()
        -- i18n: /gh subcommand (for hint)
        subcmd2:AddAlias(gettext.gettext("traceback"))
        --subcmd2:SetCallback(function(input) GuildHallButton.process_slash_gh_command("traceback " .. (tonumber(input) or "1")) end)
        subcmd2:SetCallback(function(input) report_traceback(gettext.gettext("traceback"), tonumber(n) or 1) end) 
        -- i18n: Description of subcommand 
        subcmd2:SetDescription(gettext.gettext("Display traceback n in a UI Error window, n=1..9, newest to oldest"))
    
        local subcmd3 = cmd:RegisterSubCommand()
        -- i18n: /gh subcommand (for hint)
        subcmd3:AddAlias(gettext.gettext("version"))
        subcmd3:SetCallback(function(input) report_version(gettext.gettext("version")) end)
        -- i18n: Description of subcommand 
        subcmd3:SetDescription(gettext.gettext("Report add-on version and compatibility"))
        
        local subcmd4 = cmd:RegisterSubCommand()
        -- i18n: /gh subcommand (for hint)
        subcmd4:AddAlias(gettext.gettext("list"))
        subcmd4:SetCallback(function(input) report_configuration(gettext.gettext("list")) end)
        -- i18n: Description of subcommand 
        subcmd4:SetDescription(gettext.gettext("Report add-on guild configuration"))
    elseif #registerable_slash_commands then
        for _, sc in pairs(registerable_slash_commands) do
            SLASH_COMMANDS[sc] = GuildHallButton.process_slash_gh_command
        end
    end
    
    if GuildHallButton.VisitCmd and GuildHallButton.VisitCmd.enabled and lsc then
        local cmd = lsc:Register( {gettext.gettext("/visit")},
                                  function(cmd) GuildHallButton.process_slash_visit_command(cmd) end,
                                  -- i18n: Meaning of /visit (for hint)
                                  gettext.gettext("Visit a player’s house"))
        GuildHallButton.slashvisitcmd = cmd
    elseif GuildHallButton.VisitCmd and GuildHallButton.VisitCmd.enabled then
        SLASH_COMMANDS["/visit"] = GuildHallButton.process_slash_visit_command
    end
  
end


-- Initialization function
function GuildHallButton:Initialize()
  -- Add a /guildhall command
  local GuildHallNames = initialize_guild_halls()
  local ReloadUiSwitches = {on_join=false, on_leave=false}
  local VisitCmd = {enabled=true}
  
  GuildHallButton.saved_variables = ZO_SavedVars:NewAccountWide("GuildHallButtonSavedVariables",5,GetWorldName(),
                                                 {GuildHallNames=GuildHallNames, 
                                                  Tracebacks={}, 
                                                  ReloadUiSwitches=ReloadUiSwitches,
                                                  VisitCmd=VisitCmd})
  GuildHallButton.GuildHallNames = GuildHallButton.saved_variables.GuildHallNames
  GuildHallButton.Tracebacks = GuildHallButton.saved_variables.Tracebacks
  GuildHallButton.ReloadUiSwitches = GuildHallButton.saved_variables.ReloadUiSwitches
  GuildHallButton.VisitCmd = GuildHallButton.saved_variables.VisitCmd
  initialize_houses()
  GuildHallButton.GuildNames = refresh_guild_names()
  
  GuildHallButton.scene_fragment = ZO_SimpleSceneFragment:New(GuildHallButtonFrame)
  GUILD_HOME_SCENE:AddFragment(GuildHallButton.scene_fragment)
  
  GuildHallButton.guild_hall_frame_label = GuildHallButtonFrameLabel
  GuildHallButton.guild_hall_name_label = GuildHallButtonFrameGuildHallName
  GuildHallButton.guild_hall_name_label:RegisterForEvent(EVENT_GUILD_DATA_LOADED, GuildHallButton.OnGuildDataLoaded)
  GuildHallButton.guild_hall_name_label:RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, GuildHallButton.OnSelfLeftGuild)
  GuildHallButton.guild_hall_name_label:RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, GuildHallButton.OnSelfJoinedGuild)
  
  GuildHallButton.guild_hall_icon_texture = GuildHallButtonFrameGuildHallIcon
  GuildHallButton.goto_guild_hall_button = GoToGuildHallButton
  
  GuildHallButton.SetCurrentGuildHallName(guild_no_lookup(GUILD_SHARED_INFO.guildId))
  
  register_slash_commands()
  --d("Initializing GuildHallButton is complete")
  
  EVENT_MANAGER:UnregisterForEvent(GuildHallButton.name, EVENT_ADD_ON_LOADED)
  
  ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", GuildHallButton.OnGuildIdChanged)
  
  -- Library imports

  local LAM = LibAddonMenu2
  
  if LAM then 
      local optionsettings = {guild_hall_names=GuildHallButton.GuildHallNames,
                              tracebacks=GuildHallButton.Tracebacks, 
                              reload_ui_switches=GuildHallButton.ReloadUiSwitches,
                              visit_cmd=GuildHallButton.VisitCmd}
      try {
        function()
          GuildHallButton.BuildLAM(LAM, optionsettings)
        end, 
      except {
        function(error) 
          -- i18n: Generic error report: followed by instructions for retrieving the traceback
          report_error(gettext.gettext('Add-on menu call failed:'), error)
      end}
      }
  else 
      d(gettext.gettext('Add-on menu library LibAddonMenu-2.0 unavailable or is out of date'))
  end
  
  -- Dialogues
  
  local version_dialog = {
    title    = {text = gettext.gettext("Guild Hall Button") .. "\n" .. 
                       gettext.gettext("Version Information")},
    mainText = {text = gettext.gettext("<<1>><<2>><<3>><<4>><<5>>"),
                       align = TEXT_ALIGN_CENTER},
    buttons =           {
    [1] = {
            text = GetString(SI_DIALOG_CLOSE),
        },
    }
  }    
  ZO_Dialogs_RegisterCustomDialog("GuildHallButtonVersionDialog", version_dialog)
  
  local destination_dialog = {
    title = { text = gettext.gettext("Guild Hall Button")  .. "\n" .. 
                     gettext.gettext("Destinations")},
    mainText = {text = gettext.gettext("<<1>><<2>><<3>><<4>><<5>>"), 
    align = TEXT_ALIGN_CENTER},
    buttons =           {
    [1] = {
            text = GetString(SI_DIALOG_CLOSE),
        },
    }
  }    
  ZO_Dialogs_RegisterCustomDialog("GuildHallButtonDestinationDialog", destination_dialog)

end


-- Event handlers
function GuildHallButton.OnAddonLoaded(event, addonName)
  -- Fires each time *any* addon loads, but we only care about this one
  if addonName == GuildHallButton.name then
    GuildHallButton:Initialize()
  end
end

function GuildHallButton.OnClicked(self,button)
    try {
        function()
        GuildHallButton.process_slash_gh_command("") 
        --[[throw_exception(1)]]
        end, 
    except {
        function(error) 
            -- i18n: Generic error report: followed by instructions for retrieving the traceback
            report_error(gettext.gettext('Button press failed:'), error)
        end}
    }
end

local function guess_which_house(house_category_type)
  -- Called when a guild leader presses the button. We find the guild leader's biggest house and return that.
  -- If there is more than one candidate for "biggest house" then we take the first one.
  if not house_category_type then
    house_category_type = HOUSE_CATEGORY_TYPE_MAX_VALUE
  elseif house_category_type < HOUSE_CATEGORY_TYPE_MIN_VALUE then
    return
  end
  for _,v in pairs(COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()) do
    if GetHouseCategoryType(v.houseId) == house_category_type then
      return v.houseId
    end
  end
  -- if we get here then there was no house in the category, so go downmarket
  return guess_which_house(house_category_type - 1)
end

local function identify_primary_house()
  -- Called when a guild leader presses the button. 
  -- We find the guild leader's primary house and return that.
  for _,v in pairs(COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()) do
    if IsPrimaryHouse(v.houseId) then
      return v.houseId
    end
  end
  -- if we get here then we could not find a primary house, so guess it is the biggest one
  return guess_which_house()
end


local function do_debug(cmd)
    --local house_id = identify_primary_house()
    --d("Your primary residence is " .. GuildHallButton.HOUSES[house_id].house_name)
    d(string.format("Guild ID is now %s", GUILD_SHARED_INFO.guildId or "nil"))
    d(string.format("API version is %s declared compatibility is %s %s", GetAPIVersion(), GuildHallButtonVersion.current_api, GuildHallButtonVersion.future_api))
    d(string.format("Plugin version is %s.%s.%s-%s", GuildHallButtonVersion.major, GuildHallButtonVersion.minor, GuildHallButtonVersion.patch, GuildHallButtonVersion.build))
    --local guild_member_index = GetGuildMemberIndexFromDisplayName(GUILD_SHARED_INFO.guildId, tostring("@BoarGules"))
    --d("Guild member index is " .. guild_member_index)
    --[[
    exception()
    --]]  
end

local function parse_command_line(cmd)
  local pattern = "(%d*)%s*(@%S+)%s*(.*)"   -- matches guild_number @LeaderName house_substring              
  local guild_no, castellan, house_indicator = string.match(cmd, pattern)
  guild_no = tonumber(guild_no)
  if castellan then
    return guild_no, castellan, house_indicator
    end
  pattern = "(%d*)%s*(.*)"            -- matches 2 house_substring 
  guild_no, house_indicator = string.match(cmd, pattern)
  guild_no = tonumber(guild_no)
  if guild_no then
    return guild_no, nil, house_indicator
    end
  return nil, nil, nil
end


local function identify_house(indicator)
  -- indicator can be blank or nil: return nil, nil, nil (no house specified, name unimportant)
  -- indicator can be a string consisting of only digits: do a table lookup on indicator
  -- indicator can be a string: search the house names for a name that contains indicator 
  -- if search succeeded return house id (integer), house name (string), 1
  -- if search yielded no matches return nil, nil, 0
  -- if search yielded n>1 matches return nil, nil, n
  if not indicator then
    return nil, nil, nil
    end
  if indicator == "" then
    return nil, nil, nil
    end 
  local house_id = tonumber(indicator)
  if house_id then
    -- Look up the name and return it
    return house_id, GuildHallButton.HOUSES[house_id].house_name, 1
    end
  -- indicator is present but a not a number: search
  local candidates = {}
  for id, h in pairs(GuildHallButton.HOUSES) do
    if string.find(string.lower(h.house_name),string.gsub(string.lower(indicator),"%-","%%-")) then
      -- this elaborate cartwheel is to make search strings that contain hyphens to work
      table.insert(candidates, {id=id, name=h.house_name})
    end -- if
  end -- for
  if #candidates == 0 then
      -- i18n: Alert in response to a partial name in /guildhall 1 partial-name if there is no match 
      -- i18n: For example user typed /gh 1 griffin but the house name is actually gryphon.
      ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t match <<1>> with any house name"),COMMAND_COLOUR:Colorize(indicator)))
      return nil, nil, 0
  elseif #candidates == 1 then
      return candidates[1].id,candidates[1].name, 1
  else
      local names = {}
      for _, candidate in pairs(candidates) do
          table.insert(names, zo_strformat("<<C:1>>", candidate.name))
          end
      -- i18n: Alert in response to a partial name in /guildhall 1 partial-name (or /visit @player partial-name) if there is more than one match 
      -- i18n: For example user typed /gh 1 dawn (or /visit @Slartibartfast dawn) but that could mean Dawnshadow or Princely Dawnlight Palace 
      -- i18n: 1: short name that player typed, 2: number of matches, 3: list of matches
      ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, 
                      zo_strformat(gettext.gettext("Short name <<1>> matches <<n:2>> different houses: <<3>>"),COMMAND_COLOUR:Colorize(indicator), 
                      #candidates, ZO_GenerateCommaSeparatedList(names)))
--      for _, candidate in ipairs(candidates) do
--          ZO_Alert(UI_ALERT_CATEGORY_ERROR, None, candidate.name)
--          end
--      -- i18n: Alert in response to a partial name in /guildhall 1 partial-name (or /visit @player partial-name) if there is more than one match 
--      -- i18n: For example user typed /gh 1 dawn (or /visit @Slartibartfast dawn) but that could mean Dawnshadow or Princely Dawnlight Palace 
--      -- i18n: 1: short name that player typed, 2: number of matches, 3: list of names of matches
--      d(zo_strformat(gettext.gettext('Short name <<1>> matches <<n:2>> different houses: <<3>>'),COMMAND_COLOUR:Colorize(indicator), #names, ZO_GenerateCommaSeparatedList(names)))
      return nil, nil, #candidates
  end
end

local function inside_outside(house_indicator)
--[[Check house_indicator to see if it is prefixed by the keyword outside. If it is, strip it off. 
    Return house_indicator without the keyword, and true if it was present, false otherwise
--]]
    local outside = {out=true, outs=true, outsi=true, outsid=true, outside=true}
    local outside_pattern = "^%s*[outsideOUTSIDE]+"  -- brute-force pattern that will get false positives, we shall check later
    local to_outside = false
    local token, s, e 
    s,e = house_indicator:find(outside_pattern)
    if s then
        token = house_indicator:sub(s,e):gsub("^%s+",""):gsub("%s+$","") -- extract the match and strip any delimiting spaces
        to_outside = outside[token:lower()]              -- check that the match really is the keyword
        if to_outside then                               -- if it is, strip it and all delimiting spaces off
            house_indicator = house_indicator:gsub(token,""):gsub("^%s+",""):gsub("^%s+","")
        end
    end                
    return house_indicator, to_outside
end

function GuildHallButton.process_slash_visit_command(cmd)
--[[
  The command /visit introduces cmd.  See also process_slash_gh_command().
  
  Possible values of cmd           Example /command                      Effect
  ----------------------           ----------------                      ------
  @player                          /visit @Slartibartfast                Go to @Slartibartfast's principal residence         
  @player outside                  /visit @Slartibartfast                Go to outside of @Slartibartfast's principal residence         
  @player house_substring          /visit @Slartibartfast sleek          Go to @Slartibartfast's house Sleek Creek
  @player outside house_substring  /visit @Slartibartfast outside sleek  Go to outside of @Slartibartfast's house Sleek Creek
  @player house_number             /visit @Slartibartfast 30             Go to @Slartibartfast's house Old Mistveil Manor
  @player outside house_number     /visit @Slartibartfast outside 30     Go to outside of @Slartibartfast's house Old Mistveil Manor
  house_substring                  /visit sleek                          Go to current player's house Sleek Creek
  outside house_substring          /visit outside sleek                  Go to outside of current player's house Sleek Creek
  house_number                     /visit 30                             Go to current player's house Old Mistveil Manor
  outside house_number             /visit outside30                      Go to outside of current player's house Old Mistveil Manor
  The keyword outside can be abbreviated down to 3 characters: out, outs, outsi etc
--]]

    try {
        function() 
        
            -- 1. Look for: @player house_substring
            local _, _, player, house_indicator = string.find(cmd,"(@%S+)%s+(.+)")
            local outside = {out=true, outs=true, outsi=true, outsid=true, outside=true}
            local outside_pattern = "^[outside]+"
            local to_outside = false
            if player and house_indicator then   -- there is a player and a house indicator but if the indicator is invalid there will be no id
                house_indicator, to_outside = inside_outside(house_indicator)
                -- now do we still have a house indicator?
                if house_indicator then
                    local house_id, house_name, candidates = identify_house(house_indicator)
                    --d("::House indicator is " .. house_indicator .. " Returns house " .. (house_id or "((nil))") .. " " .. (house_name or "((nil))") .. " " .. (candidates or "((nil))") )
                    if candidates ~= 1 then  -- we got a house_indicator but the search failed: error message already issued, just bail
                        return
                        end                    
                    if house_id then   -- there is a player and a house indicator but if the indicator is invalid there will be no id
                        -- i18n: Alert in response to a /visit @player partial-name command that succeeds 
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(gettext.gettext("Visiting <<C:1>>’s house <<l:2>>"),UndecorateDisplayName(player) .. "^M", house_name))
                        JumpToSpecificHouse(player, house_id, to_outside)
                        return -- whether we acted on the command or only gave an error message, return
                        end
                    end
                end
            -- 2. Look for: @player
            _, _, player = string.find(cmd,"(@%S+)")
            if player then -- there was no match on player and house indicator, only on player
               -- to_outside might have been found in the previous step
               -- i18n: Alert in response to a /visit @player command that succeeds 
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(gettext.gettext("Visiting <<C:1>>’s house"),UndecorateDisplayName(player) .. "^M"))
                JumpToHouse(player, to_outside)
                return 
                end
            -- 3. Look for house_substring
            _, _, house_indicator = string.find(cmd,"([^@]%S.+)") -- there was no match on player, only on house indicator
            if house_indicator then
                house_indicator, to_outside = inside_outside(house_indicator)
                local house_id, house_name, candidates = identify_house(house_indicator)
                --d("==House indicator is " .. house_indicator .. " Returns house " .. (house_id or "((nil))") .. " " .. (house_name or "((nil))") .. " " .. (candidates or "((nil))") )
                if candidates ~= 1 then -- we got a house_indicator but the search failed: error message already issued, just bail
                    return
                    end
                if house_id then   -- there is a house indicator but if the indicator is invalid there will be no id
                    -- i18n: Alert in response to a /visit partial-name command that succeeds
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(gettext.gettext("Visiting your house <<l:1>>"), house_name))
                    RequestJumpToHouse(house_id, to_outside)
                    end
                return -- whether we acted on the command or only gave an error message, return
                end
            -- 4. Complain
            -- i18n: Alert in response to a /visit @player partial-name command that fails 
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext('Can’t identify <<1>> as a valid place to go'),house_indicator or '""'))
        end,
    except {
        function(error) 
          -- i18n: Alert in response to a command that threw an unhandled exception 
          -- i18n: There follow instructions for retrieving the stack trace
          report_error(gettext.gettext("Error while executing command /visit ") .. (house_indicator or ""), error)        
        end
        }
    }
end

function GuildHallButton.process_slash_gh_command(cmd)
--[[
  The command /gh introduces cmd. See also process_slash_visit_command().
   
  Possible values of cmd                        Example /command                 Effect
  ----------------------                        ----------------                 ------
  (blank)                                       /gh                              Go to guild hall of current guild
  guild number                                  /gh 3                            Go to guild hall of guild 3
  guild_number house_substring                  /gh 1 sleek                      Go to the guild 1 leader's house called Sleek Creek 
  guild_number house_number                     /gh 1 30                         Go to the guild 1 leader's house called Old Mistveil Manor
  guild_number @player house_substring          /gh 2 @cyberjanet gryph          Go to @player's house The Flaming Gryphon and make that the guild hall of guild 2
  guild_number @player house_number             /gh 1 @cyberjanet 30             Go to @player's house Old Mistveil Manor and make that the guild hall of guild 2
  ??                                            /gh ??                           Do current debug action (commented out)
  ?                                             /gh ?                            List all guilds and guild halls in chat
  list                                          /gh list                         List all guilds and guild halls in chat
  version                                       /gh version                      Give add-on version number and API compatibility
  traceback                                     /gh traceback                    Display the most recent traceback in a UI Error window
  traceback number                              /gh traceback 3                  Display traceback 3 in a UI Error window (1..9, most recent is one)
  guilds                                        /gh guilds                       List of guilds giving guild_no (1..5) and guild_id (5 consecutive) (commented out)
  throw                                         /gh throw 2                      Generate an exception at throw_exception(2) in the code (commented out)
--]]

  local special_command
  try {function ()
       
      if cmd == "??" then
          --d("Got command ?, doing debug")
          special_command = cmd
          do_debug(cmd)
          return
          end
      
      local _, _, keyword, _, n = string.find(cmd,"(list%a*)(%s*)(%d?)")
      if keyword then
          special_command = cmd
          report_configuration(keyword)
          end
      local _, _, keyword, _, n = string.find(cmd,"(%?)(%s*)(%d?)")
      if keyword then
          special_command = cmd
          report_configuration("list")
          end
      local _, _, keyword, _, n = string.find(cmd,"(vers%a*)(%s*)(%d?)")
      if keyword then
          special_command = cmd
          report_version(keyword)
          end
      --[[
      local _, _, keyword, _, n = string.find(cmd,"(guil%a*)(%s*)(%d?)")
      if keyword then
          special_command = cmd
          for guild_name, guild_no in pairs(GuildHallButton.GuildNames) do
              d(string.format("Guild %s is guild no %s", guild_name, guild_no or "((ex-guild))"))
              end
          end
      --]]
      local _, _, keyword, _, n = string.find(cmd,"(trac%a*)(%s*)(%d?)")
      if keyword then
          special_command = cmd
          report_traceback(keyword, tonumber(n) or 1)
          end
      --[[
      local _, _, keyword, _, n = string.find(cmd,"(thro%a*)(%s*)(%d?)")
      -- The command /gh throw 6 will cause the call to throw_exception(6) 
      -- to actually throw an exception: function expected instead of nil
      -- Repeating the command with the same number will switch this off again.
      if keyword then
          special_command = cmd
          THROWS[tonumber(n)] = not THROWS[tonumber(n)]
          end 
      --]]

      end, 
  except {function(error)
      -- i18n: Alert in response to a command that threw an unhandled exception 
      -- i18n: There follow instructions for retrieving the stack trace
      report_error(gettext.gettext("Error while executing command ") ..
                  COMMAND_COLOUR:Colorize(zo_strformat(gettext.gettext("/guildhall <<1>>"),cmd)), error)
      end 
      }}
      
  if special_command then
      return
      end
            
  local guild_no, castellan, house_indicator = parse_command_line(cmd)
  if castellan and not guild_no then
    -- i18n: Alert on failure to provide guild number as in /guildhall @Name house.
    -- i18n: Guild number not optional for this command format.
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Command /guildhall <<1>> invalid: expecting a guild number 1..5 (not optional)"),cmd))
    return
  end
  local guild_id = nil
  --d("Guild '" .. (guild_no or "((nil))") .. "' Castellan " .. (castellan or "((nil))") .. " House " .. (house_indicator or "((nil))"))
  local house_id, house_name = identify_house(house_indicator)
  --d("House " .. (house_id or "((nil))") .. " name " .. (house_name or "((nil))"))
  if castellan then  
      -- Validate supplied name
      guild_id = GetGuildId(guild_no) or GUILD_SHARED_INFO.guildId
      local guild_member_index = GetGuildMemberIndexFromDisplayName(guild_id, tostring(castellan))
      if not guild_member_index then
          -- i18n: Alert on failure to match the input name in /guildhall 2 @Name
          -- i18n: Such as user typed @slartibartfast but it should be @Slartibartfast
          ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext('Can’t identify "<<1>>" as a guild member: check spelling and capitalization'),tostring(castellan)))
          return
      end
      -- Check that the supplied name isn't the guild leader
      local _, _, leader_name = GetGuildInfo(guild_id)
      if castellan == leader_name then
        castellan = nil
      end
      GuildHallButton.GuildHallNames[guild_no].castellan = castellan
      GuildHallButton.GuildHallNames[guild_no].house_override = house_id
  end
    
  local house_specified = false
  if house_id then
    house_specified = true
  end
  
  if cmd ~= "" and not guild_no and not house_id then
    -- i18n: Alert on failure to recognize an slash command, for example /guildall tarceback
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Command /guildhall <<1>> invalid: expecting a guild number 1..5 (or nothing)"),cmd))
    return
    end
    
  if guild_no then
    guild_id = GetGuildId(guild_no)
  else
    guild_id = GUILD_SHARED_INFO.guildId
    guild_no = guild_no_lookup(guild_id)
  end
  
  if not ZO_ValidatePlayerGuildId(guild_id) then
      -- i18n: Alert in response to /guildhall 4 when player has only 3 guilds
      ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Command /guildhall <<1>> invalid: you do not have a guild numbered <<1>>"),guild_no))
    return
    end
    
  local leader_name, guild_name
  
  try {function()
         guild_name = GetGuildName(guild_id)
         if GuildHallButton.GuildHallNames[guild_no].castellan then
             leader_name = GuildHallButton.GuildHallNames[guild_no].castellan
         else
             _, _, leader_name = GetGuildInfo(guild_id)
         end
      --[[throw_exception(3)]]   
      end,
  except {function(error)
      -- i18n: Exception trap when identifying castellan
      -- i18n: There follow instructions for retrieving the stack trace
      report_error(zo_strformat(gettext.gettext("Attempt to establish castellan of guild no <<1>> id <<2>> failed:"),guild_no,guild_id), error)
      end
      }  -- except
  } -- try
  
  if not string.match(tostring(leader_name), '@%S+') then
    -- i18n: Alert response to unrecognized value in place of  @playername 
    -- i18n: Should only happen if player has managed to defeat the validation in the config screen 
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext('Can’t identify "<<1>>" as a player name: check configuration settings'),tostring(leader_name)))
    return
  end
  local house_override = GuildHallButton.GuildHallNames[guild_no].house_override
  if GetDisplayName() == leader_name then -- avoid message You cannot travel to yourself
    if not house_id then
      house_id = identify_primary_house()
    end
    if not house_id then
    -- i18n: Alert in response to unrecognized value in house override 
    -- i18n: Should only happen if player has managed to defeat the validation in the config screen 
    -- i18n: Also appears if a guild leader presses the button but the add-on can't identify the guild leader's primary residence
      ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t identify a suitable house as <<1>> guild hall to travel to"),guild_no))
    return
    end
    -- i18n: Alert when the guild leader presses the button
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(gettext.gettext("Traveling to your house <<l:1>>"),GuildHallButton.HOUSES[house_id].house_name))
    FastTravelToNode(GuildHallButton.HOUSES[house_id].node_id)
  elseif house_id or house_override then
    local destination = house_override or house_id
    local destination_name = GuildHallButton.HOUSES[destination].house_name
    -- i18n: Alert when the button press (or slash command) takes you to a house other than the guild leader's primary residence
    -- i18n: <<C:1>> is conversion of @player to Player; <<2>> is name of house
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(gettext.gettext("Traveling to <<C:1>>’s house <<l:2>>"),UndecorateDisplayName(leader_name) .. "^M", destination_name))
    JumpToSpecificHouse(leader_name, destination)
  else
    -- i18n: Normal alert on travelling to guild hall
    -- i18n: <<1>> is a guild name; <<2>> is normally empty
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(gettext.gettext("Traveling to the <<1>> guild hall <<2>>"),guild_name,house_id))
    --d(string.format("JumpToHouse (%q)", leader_name or "((nil))"))
    JumpToHouse(leader_name)
  end
  if not house_specified then -- we look at where we got to to save names and stuff
      EVENT_MANAGER:RegisterForEvent(GuildHallButton.name, EVENT_PLAYER_ACTIVATED, GuildHallButton.OnFastTravelComplete)
      GuildHallButton.destination = guild_no
      ZO_CachedStrFormat("<<C:1>>", GetPlayerLocationName())
      
      end
end

function GuildHallButton.OnFastTravelComplete(event_code,node_index)
  if GuildHallButton.destination and ZO_CachedStrFormat("<<C:1>>", GetPlayerLocationName()) ~= GuildHallButton.origin then
    local destination = GuildHallButton.destination
    local old_value = GuildHallButton.GuildHallNames[destination].name
    GuildHallButton.GuildHallNames[destination].name = ZO_CachedStrFormat("<<C:1>>", GetPlayerLocationName())
    GuildHallButton.GuildHallNames[destination].open = true
    GuildHallButton.saved_variables.GuildHallNames[destination].name = GuildHallButton.GuildHallNames[destination].name
    local name = GuildHallButton.GuildHallNames[destination].name
    local guild_id = GUILD_SHARED_INFO.guildId
    GuildHallButton.SetSlashCommandDescription(name,guild_id)
    GuildHallButton.SetCurrentGuildHallName(destination)
  end
  GuildHallButton.destination = nil
  GuildHallButton.origin = nil
  EVENT_MANAGER:UnregisterForEvent(GuildHallButton.name, EVENT_PLAYER_ACTIVATED)
end

function GuildHallButton.SetSlashCommandDescription(guild_hall_name, guild_id)
    -- i18n: generic slash command description
    local travel_to_desc = gettext.gettext("Travel to Guild Hall")
    if guild_id then
        -- i18n: specific slash command description: <<1>> is house name, <<2>> is guild name
        travel_to_desc = zo_strformat(gettext.gettext("Travel <<L:1>> (<<2>>)"), guild_hall_name, GetGuildName(guild_id))
    end
    if GuildHallButton.slashcommand then
        GuildHallButton.slashcommand:SetDescription(travel_to_desc)
    end
end

function GuildHallButton.SetCurrentGuildHallName(guild_no)
    if not GuildHallButton.GuildHallNames[guild_no] then
        d(string.format("No guild_no %s to set name", guild_no or "((nil))"))
        return
        end
    try {function() 
        local name = GuildHallButtonFrameGuildHallName
        local old_value = name:GetText()
        local new_value = GuildHallButton.GuildHallNames[guild_no].name
        name:SetText(new_value)
        GuildHallButton.SetSlashCommandDescription(name:GetText(),guild_no)
        -- Apparently redundantly repeated, but OnGuildDataLoaded only fires on startup which means
        -- a /reloadui will not pick up changes to the language files for these controls:
        -- i18n: Text on guild screen (above the picture of the house)
        GuildHallButton.guild_hall_frame_label:SetText(gettext.gettext("Guild Hall"))
        -- i18n: Text on button on guild screen
        GuildHallButton.goto_guild_hall_button:SetText(gettext.gettext("Travel to Guild Hall")) 
        --[[throw_exception(4)]]
        end, 
    except {function(error) 
        -- i18n: Unhandled exception trap when identifying name of guild hall
        -- i18n: There follow instructions for retrieving the stack trace      
        report_error(zo_strformat(gettext.gettext("Could not set guild hall name for <<1>>: "), guild_no), error)
        end
    }}
end
  
function GuildHallButton.OnGuildDataLoaded(event_code, guild_id)
    --Note: This event only fires on startup, not on /reloadui
    --d("OnGuildDataLoaded")
    --d(string.format("GUILD_SHARED_INFO.guildId=%s",GUILD_SHARED_INFO.guildId))
    
    if not GUILD_SHARED_INFO or not GUILD_SHARED_INFO.guildId then
        return
        end

    local name = GuildHallButtonFrameGuildHallName
    local old_value = name:GetText()
    local guild_no = guild_no_lookup(GUILD_SHARED_INFO.guildId)
    local new_value = GuildHallButton.GuildHallNames[guild_no].name
    if old_value == new_value then
        return
        end
    name:SetText(new_value)
    GuildHallButton.SetSlashCommandDescription(name:GetText(),GUILD_SHARED_INFO.guildId)

    --GuildHallButton.guild_hall_icon_texture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    GuildHallButton.guild_hall_frame_label:SetText(gettext.gettext("Guild Hall"))
    GuildHallButton.goto_guild_hall_button:SetText(gettext.gettext("Travel to Guild Hall"))
    
    --d(string.format("Guild %d hall name on screen now changed from %s to %s", GUILD_SHARED_INFO.guildId, old_value, GuildHallButton.GuildHallNames[GUILD_SHARED_INFO.guildId].name))
    --d("OnGuildDataLoaded exit")
end

function GuildHallButton.OnSelfLeftGuild(event_code, some_id, guild_name, guild_id)
    -- event_code is EVENT_GUILD_SELF_LEFT_GUILD 327703
    local guild_no = guild_no_lookup(guild_id)
    --d(string.format("Change detected to guild event_code=%s some_id=%s guild_name=%s guild_id=%s guild_no=%s", 
    --                 event_code, some_id, guild_name, guild_id, guild_no or "((nil))"))
    try {function()
         -- determine the number of the guild we just left
        --d(string.format("Closed guild hall of guild %q", guild_name))
        if GuildHallButton.ReloadUiSwitches.on_left then 
            ReloadUI() 
            --ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, 
            --        gettext.gettext("UI reloaded at your request because you left a guild"))
        end
        GuildHallButton.GuildNames[guild_name] = nil
        for guild_no = GetNumGuilds() + 1, 5 do
            -- i18n: dummy name, <<1>> is a guild number from 1 to 5, only used when a player has fewer than 5 guilds
            local dummy_numeric_guildhall_name = zo_strformat(gettext.gettext("Guild Hall <<1>>"), guild_no)
            GuildHallButton.GuildHallNames[guild_no] = make_empty_guildhall(dummy_numeric_name, false)
        end -- for
        for guild_name, guild_no in pairs(refresh_guild_names()) do
            GuildHallButton.GuildNames[guild_name] = guild_no
        end
    --[[throw_exception(5)]]
    end, -- try function 
    except {function(error)
        -- i18n: exception trap when responding to player leaving a guild
        -- i18n: There follow instructions for retrieving the stack trace      
        report_error(gettext.gettext("Failed to process left-guild event: "), error) 
    end}} -- try/except
end

function GuildHallButton.OnSelfJoinedGuild(event_code, some_id, guild_name, guild_id)
    -- event_code is EVENT_GUILD_SELF_JOINED_GUILD 327702
    local guild_no = guild_no_lookup(guild_id)
    --d(string.format("Change detected to guild event_code=%s some_id=%s guild_name=%s guild_id=%s guild_no=%s", 
    --                 event_code, some_id, guild_name, guild_id, guild_no or "((nil))"))
    try {function() 
          if ZO_ValidatePlayerGuildId(guild_id) then
              -- i18n: Dummy guild hall name; <<t:1>> is name of guild with only initial caps
              local dummy_alpha_guildhall_name = 
                zo_strformat("Guild Hall of the <<t:1>>",zo_strformat("<<z:1>>",guild_name))
              GuildHallButton.GuildHallNames[guild_no] = make_empty_guildhall(dummy_alpha_guildhall_name, true)
          else
              -- i18n: Dummy guild hall name; <<1>> is number of guild (when we can't find the name out because the player left it)
              local dummy_numeric_guildhall_name = zo_strformat(gettext.gettext("Guild Hall <<1>>"), guild_no)
              GuildHallButton.GuildHallNames[guild_no] = make_empty_guildhall(dummy_numeric_guildhall_name, true)
          end
          GuildHallButton.GuildNames[guild_name] = GetNumGuilds() 
          --d(string.format("Opened guild hall %q (of guild %q): name is now %q", guild_no, guild_id, GuildHallButton.GuildHallNames[guild_no].name)) 
          if GuildHallButton.ReloadUiSwitches.on_join then 
              ReloadUI() 
              --ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, 
              --       gettext.gettext("UI reloaded at your request because you joined a new guild"))
          end
      --[[
      exception(6)
      --]]
      end,
    except {function(error)
        -- i18n: Unhandled exception trap when responding to player joining a guild
        -- i18n: There follow instructions for retrieving the stack trace      
        report_error(gettext.gettext("Failed to process joined-guild event: "), error) 
        end
    }} -- try/except
end

function GuildHallButton.OnGuildIdChanged(guild_roster_manager)
    --d("OnGuildIdChanged")
    if not guild_roster_manager then
        -- i18n: Alert in response changing guilds when the guild id has changed but no data is available from the game 
        -- i18n: Message appears after guild information has changed (because the player joined a new guild or left an 
        -- i18n: existing one) but the game hasn't yet updated the guild info in the API.
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t identify the guild hall yet")))
        return
        end
    local guild_id = guild_roster_manager.guildId
    if not guild_id then
        return
        end
    local guild_no
    guild_no = guild_no_lookup(guild_id)
    if not guild_no then 
        -- i18n: Chat window response to changing guilds: can't work out what guild has been joined 
        -- i18n: Should never happen
        d(string.format("Could not identify guild no from guild id %s", guild_id or "((nil))"))
        return
        end 
    if not GuildHallButton.GuildHallNames[guild_no] then    
        local dummy_numeric_guildhall_name = zo_strformat(gettext.gettext("Guild Hall <<1>>"), guild_no)
        GuildHallButton.GuildHallNames[guild_no] = make_empty_guildhall(dummy_numeric_guildhall_name, true)
        end
    --d(string.format("self.guildId=%s",guild_id))
    GuildHallButton.SetSlashCommandDescription(GuildHallButton.GuildHallNames[guild_no].name,guild_id)
    local name = GuildHallButtonFrameGuildHallName
    local old_value = name:GetText()
    if old_value == GuildHallButton.GuildHallNames[guild_no].name then
        return
        end
    name:SetText(GuildHallButton.GuildHallNames[guild_no].name)
    GuildHallButton.guild_hall_icon_texture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    --d(string.format("Guild %d hall name on screen now changed from %s to %s", guild_id, old_value, GuildHallButton.GuildHallNames[guild_id].name))
    --d("OnGuildIdChanged exit")
end

-- Register event handler
EVENT_MANAGER:RegisterForEvent(GuildHallButton.name, EVENT_ADD_ON_LOADED, GuildHallButton.OnAddonLoaded)

-- Build LAM Option Table, used when AddonLoads or when a player join/leave a guild
function GuildHallButton.BuildLAMPanel(LAM, settings_panel_name, option_settings)

  local config_controls = {}
  
  
  for guild_no = 1, GetNumGuilds() do
    
    -- Guild name
    local guild_id = GetGuildId(guild_no)
    local guild_name = GetGuildName(guild_id)
    local num_guild_members, num_members_online, guild_leader_name = GetGuildInfo(guild_id)

    --[[
    -- For screenshots
    local guild_name_override = {"Rich Mahogany", "Merchants of the Merchants", "Rangiest Rangers"}
    guild_name = guild_name_override[guild_id]
    --]]
        
    -- Guild members
    -- Get names and ranks
    local guild_member_names_ranks = {}
    local rank_count = 0  
    for member = 1, num_guild_members do
        local guild_member_name, _, rank = GetGuildMemberInfo(guild_id, member)
        guild_member_names_ranks[member] = {name=guild_member_name, rank=rank}
        if rank > rank_count then   
            rank_count = rank
            end
        end
    -- Tally number of members with each rank
    local rank_tally = {}
    for k,v in pairs(guild_member_names_ranks) do
        if not rank_tally[v.rank] then
            rank_tally[v.rank] = 0
            end
        rank_tally[v.rank] = rank_tally[v.rank] + 1
        end 
    -- for k,v in pairs(rank_tally) do d(guild_name.." rank "..k..":"..(v or "no").."members") end
    local rank_cume = {}
    rank_cume[1] = rank_tally[1]
    for rank = 2, #rank_tally do
        rank_cume[rank] = (rank_tally[rank] or 0) + rank_cume[rank-1]
        end
    -- for k,v in pairs(rank_cume) do d(guild_name.." rank "..k..": cumulative"..(v or "none").."members") end
    -- Get the rank range that covers 12 to 20 members
    local rank_cohort = 0
    local rank_limit = 0
    for rank = 1, #rank_tally do
        rank_cohort = rank_cume[rank]
        -- d(guild_name.." rank " .. rank .. " cohort is " .. rank_cohort)
        if rank_cohort > 20 then -- but if going to the next rank leaves us with more than 20, back up
            rank_limit = rank - 1
            break
            end
        if rank_cohort >= 12 then  -- if we have twelve or more, we are done 
            rank_limit = rank
            break
            end
        end
      -- If we get this far with no rank limit then there are fewer than 12 officers and no rank for ordinary members
      if rank_limit == 0 then
          rank_limit = #rank_tally
          end
    -- d(guild_name.." final rank limit is " .. rank_limit)
    -- Build shortlist of names of members likely to be castellans, but admit any member already registered
    local guild_member_names = {}
    local member_number = 0
    for _, member in pairs(guild_member_names_ranks) do
        if member.rank <= rank_limit or (option_settings.guild_hall_names[guild_no] and member.name == option_settings.guild_hall_names[guild_no].castellan) then
            guild_member_names[#guild_member_names+1] = member.name
            --d(guild_name.." retaining "..member.name..": rank "..member.rank)
        end
        end
    -- i18n: Configuration screen: Default value (top item) in drop-down list of officers
    guild_member_names[#guild_member_names+1] = gettext.gettext("(guild leader)")
    --[[ 
    -- For screenshots
    guild_member_names[#guild_member_names+1] = "@Slartibartfast"
    --]]
    --d(guild_name.." final list is ".. #guild_member_names)
    
    -- House names
    local house_names = {}
    local house_names_clean = {}
    local house_names_capraw = {}
    local house_number = 0
    
    for _,v in pairs(GuildHallButton.HOUSES) do
        if v.house_category > HOUSE_CATEGORY_TYPE_STAPLE + 1 then
            house_number = house_number + 1
            --house_names[house_number] = v.house_name 
            local house_name_capraw = {cap=ZO_CachedStrFormat("<<C:1>>", v.house_name ), raw=v.house_name}
            house_names_capraw[house_number] = house_name_capraw
            local formatted_house_name = ZO_CachedStrFormat("<<C:1>>", v.house_name )
            house_names[house_number] = formatted_house_name
            --d(ZO_CachedStrFormat("House number <<1>> changed from <<X:2>> to <<2>>",house_number, v.house_name )) 
            end
        end
    -- i18n: Configuration screen: Default value (top item) in drop-down list of houses
    house_names_capraw[house_number+1] = {cap=gettext.gettext("(principal residence)"), raw=nil}
    table.sort(house_names_capraw, function(a,b) return (a.raw or "") < (b.raw or "") end)
    for n, v in ipairs(house_names_capraw) do
        house_names[n] = v.cap
        house_names_clean[n] = v.raw
        end
    
    -- Occurs sometimes
    if(not guild_name or (guild_name):len() < 1) then
        -- i18n: Configuration screen: Dummy guild name for when the game does not report it: occurs sometimes
        zo_strformat(gettext.gettext("Guild <<1>>"),guild_id)
    end
    local static_guild_name = guild_name
        
    local header_control = {
      type = "header",
      name = function() 
                local guild_no = GuildHallButton.GuildNames[static_guild_name]
                if guild_no then
                    return static_guild_name
                else
                    -- i18n: Configuration screen: placed after the name of a guild the player has left  
                    return string.format("%s (%s)",static_guild_name,gettext.gettext("ex-guild"))
                end 
                end,
      width = "full",
    }    
    
    table.insert(config_controls, header_control)
       
    local override_switch_value     
    local override_switch_control = {
      type = "checkbox",
      -- i18n: Configuration screen:  Switch name
      name = gettext.gettext("Override default guild hall"),
      -- i18n: Configuration screen:  Switch mouseover hint
      tooltip = gettext.gettext("Default guild hall is guild leader’s principal residence. Enable override to specify something different."),
      getFunc = function()
          local guild_no = GuildHallButton.GuildNames[static_guild_name]
          override_switch_value = option_settings.guild_hall_names[guild_no] and option_settings.guild_hall_names[guild_no].castellan  
          return  override_switch_value
          end,
      setFunc = function(new_value)
          local guild_no = GuildHallButton.GuildNames[static_guild_name]       
          if not option_settings.guild_hall_names[guild_no] then
              option_settings.guild_hall_names[guild_no] = {}
          end
          override_switch_value = new_value
          --d(string.format("Override switch %s is now %s", #config_controls, tostring(new_value)))
          if not new_value then
              option_settings.guild_hall_names[guild_no].castellan = nil
              option_settings.guild_hall_names[guild_no].house_override = nil
          end
          end,
      disabled = function() 
          local guild_no = GuildHallButton.GuildNames[static_guild_name]
          if guild_no then
              return false
          else
              override_switch_value = false
              return true
          end
          end,
      default=false,
      width = "full",
    }
    
    table.insert(config_controls, override_switch_control)
                
    local castellan_list_control = {
      type = "dropdown",
      choices = guild_member_names,
      sort = "name-up",
      -- i18n: Configuration screen: Castellan dropdown list
      name = gettext.gettext("Castellan officer"),
      -- i18n: Configuration screen: Castellan dropdown list mouseover hint
      tooltip = gettext.gettext("Name of the guild officer who is the formal owner of the guild hall"),
      getFunc = function() 
                    local guild_no = GuildHallButton.GuildNames[static_guild_name]
                    return 
                        option_settings.guild_hall_names[guild_no] and option_settings.guild_hall_names[guild_no].castellan 
                        or gettext.gettext("(guild leader)") 
                    end,
      setFunc = function(new_value) 
                    local guild_no = GuildHallButton.GuildNames[static_guild_name]
                    if new_value == gettext.gettext("(guild leader)") 
                    or new_value == guild_leader_name
                    or not new_value then
                        new_value = nil
                        end
                    option_settings.guild_hall_names[guild_no].castellan = new_value
                end,
      width = "full",
      default = gettext.gettext("(guild leader)"),
      --disabled = function() return not option_settings.guild_hall_names[guild_no] or not option_settings.guild_hall_names[guild_no].castellan end
      disabled = function() return not override_switch_value end
    }
    
    table.insert(config_controls, castellan_list_control)    
    
    local house_list_control = {
      type = "dropdown",
      choices = house_names,
      choicesValues = house_names_clean,
      scrollable = 20,
      sort = nil,
      -- i18n: Configuration screen: House dropdown list
      name = gettext.gettext("Name of guild hall"),
      -- i18n: Configuration screen: House dropdown list mouseover hint
      tooltip = gettext.gettext("Specify when the guild hall is not the castellan officer’s principal residence"),
      width = "full",
      default = "",
      getFunc = function()
          local guild_no = GuildHallButton.GuildNames[static_guild_name]
          if not option_settings.guild_hall_names[guild_no] then return gettext.gettext("(principal residence)") end
          local house_override
          local house_override_name
          try {function() 
                  house_override = GuildHallButton.HOUSES[option_settings.guild_hall_names[guild_no].house_override]
                  if house_override then
                      house_override_name = house_override.house_name
                  else
                      house_override_name = gettext.gettext("(principal residence)")
                  end
              --[[throw_exception(7)]]
              end, 
          except {function (error)
              -- i18n: Unhandled exception trap when retrieving configured house name for display on config screen
              -- i18n: There follow instructions for retrieving the stack trace
              report_error(gettext.gettext("Failed to retrieve configured house name: "), error) 
          end
          }} 
      return house_override_name
      end,
      setFunc = function(new_value)
                    local new_override
                    if new_value == gettext.gettext("(principal residence)") then
                        new_override = nil
                    else
                        new_override =  GuildHallButton.HOUSE_IDS[new_value]
                        --d(zo_strformat("Setting guildhall override to <<1>> based on dropdown value <<2>>",new_override, new_value))
                        --d(zo_strformat("Trying to match dropdown value <<1>> to house <<2>>", new_value, GuildHallButton.HOUSES[44].house_name))
                    end 
                    local guild_no = GuildHallButton.GuildNames[static_guild_name]
                    option_settings.guild_hall_names[guild_no].house_override = new_override
                end,
      disabled = function() return not override_switch_value end,
      default = gettext.gettext("(principal residence)"),
      
    }
    
    table.insert(config_controls, house_list_control)    
        
  
            
  end
  
  local behaviour_header_control = {
  type = "header",
  -- i18n: Configuration screen: Header
  name = gettext.gettext("When Leaving and Joining Guilds"),
  width = "full",
  }    

  table.insert(config_controls, behaviour_header_control)    
  
  local behaviour_desc_control = {
      type = "description",
      -- i18n: Configuration screen: Description 1 of 4
      text = gettext.gettext("When you leave a guild or join a new one, this screen will not show your changed membership until the next UI reload. ")..
             -- i18n: Configuration screen: Description 2 of 4
             gettext.gettext("This happens when you log out or issue the /reloadui command. ").. 
             -- i18n: Configuration screen: Description 3 of 4
             gettext.gettext("You can choose to have the Guild Hall Button do an automatic UI reload when you leave or join a guild. ")..
             -- i18n: Configuration screen: Description 4 of 4
             gettext.gettext("If in doubt, leave these options switched off."), 
      width = "full", --or "half" (optional)
      reference = "behaviour_desc_control" -- unique global reference to control (optional)
  }
  
  table.insert(config_controls, behaviour_desc_control)    

  local auto_reload_on_join = {
    type = "checkbox",
    -- i18n: Configuration screen: new-guild switch
    name = gettext.gettext("Reload UI on joining a new guild"),
    -- i18n: Configuration screen: new-guild switch mouseover hint
    tooltip = gettext.gettext("Switch on to automatically issue a /reloadui command on your behalf after joining a guild. If you join 2 guilds in succession you will get 2 /reloadui commands. This may not be what you want"),
    getFunc = function() return option_settings.reload_ui_switches.on_join end,
    setFunc = function(new_value) option_settings.reload_ui_switches.on_join = new_value end, 
    default=false,
    width = "full",
    }
    
  table.insert(config_controls, auto_reload_on_join)
  
  local auto_reload_on_leave = {
    type = "checkbox",
    -- i18n: Configuration screen: leave-guild switch
    name = gettext.gettext("Reload UI on leaving a guild"),
    -- i18n: Configuration screen: leave-guild switch mouseover hint
    tooltip = gettext.gettext("Switch on to automatically issue a /reloadui command on your behalf after leaving a guild. If you leave 2 guilds in succession you will get 2 /reloadui commands. This may not be what you want"),
    getFunc = function() return option_settings.reload_ui_switches.on_leave end,
    setFunc = function(new_value) option_settings.reload_ui_switches.on_leave = new_value end, 
    default=false,
    width = "full",
    }
    
  table.insert(config_controls, auto_reload_on_leave)

  --d("Registering option controls " .. (settings_panel_name or "??"))
  LAM:RegisterOptionControls(settings_panel_name,config_controls)
  
  local visit_cmd_header_control = {
  type = "header",
  -- i18n: Configuration screen: Header
  name = gettext.gettext("Visit anyone’s house"),
  width = "full",
  }    

  table.insert(config_controls, visit_cmd_header_control) 
  
  local visit_cmd_desc_control = {
      type = "description",
      -- i18n: Configuration screen: Description 1 of 3
      text = gettext.gettext("Switch on to enable the /visit command. This allows you to visit, not just the guild hall, but any player’s house, ")..
      -- i18n: Configuration screen: Description 2 of 3
      gettext.gettext("and not just their principal residence. You will get only an error message if you don’t have permission to go there, ")..
      -- i18n: Configuration screen: Description 3 of 3
      gettext.gettext("or if you try to visit a house the player doesn’t own."),
      width = "full", --or "half" (optional)
      reference = "visit_cmd_desc_control" -- unique global reference to control (optional)
  }
  
  table.insert(config_controls, visit_cmd_desc_control)    
     
  local visit_cmd_enable = {
    type = "checkbox",
    -- i18n: Configuration screen: /visit switch
    name = gettext.gettext("Enable /visit command"),
    -- i18n: Configuration screen: /visit switch mouseover hit.
    tooltip = gettext.gettext("Switch on to enable the /visit command"),
    getFunc = function() return option_settings.visit_cmd.enabled end,
    setFunc = function(new_value) option_settings.visit_cmd.enabled = new_value end, 
    default = false,
    requiresReload = true,
    width = "full",
    }
    
  table.insert(config_controls, visit_cmd_enable)
  
  
end

-- Initialises the settings and settings menu
function GuildHallButton.BuildLAM(LAM, option_settings)
  
  local panelData = {
    type = "panel",
    -- i18n: Name on config screen 
    name = gettext.gettext("Guild Hall Button"),
    -- i18n: Name on config screen 
    displayName = ZO_HIGHLIGHT_TEXT:Colorize(gettext.gettext("Guild Hall Button")),
    author = "Boar Gules",
    version = string.format("%s.%s.%s-%s", GuildHallButtonVersion.major, GuildHallButtonVersion.minor, GuildHallButtonVersion.patch, GuildHallButtonVersion.build), 
    website = "http://www.esoui.com/downloads/info1970-GuildHallButton.html",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  
  local settings_panel_name = GuildHallButton.name .. "Options"
  GuildHallButton.LAMPanel = LAM:RegisterAddonPanel(settings_panel_name, panelData)
  GuildHallButton.BuildLAMPanel(LAM, settings_panel_name, option_settings)
  
end
