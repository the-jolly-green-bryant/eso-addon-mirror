LibExoYsUtilities = LibExoYsUtilities or {}

local LibExoY = LibExoYsUtilities
LibExoY.instance = "LibExoY/SlashCmd"

-- cmd: *string* of the chat command 
-- callback: *func* or nil (if nil, displays overview of subCmds, if any exist)
-- info: *short description of chat command

-- subCmds: *table* with subCmds of the structure: 
-- key is cmdName, value is info = *string* and callback = *func*

function LibExoY.AddSlashCmd( cmd, callback, info, subCmdTable )

  --- early out 
  if not LibExoY.IsString(cmd) then return end 
  if LibExoY.IsStringEmpty(cmd) then return end
  if not LibExoY.IsFunc(callback) and not LibExoY.IsTable(subCmdTable) then return end  

  --- preparation
  cmd = string.find(cmd, "/") and cmd or "/"..cmd
  if SLASH_COMMANDS[cmd] then 
    LibExoY.Debug( zo_strformat("slashCmd <<1>> was overwritten", LibExoY.ColorString(cmd, "orange") ), {"LibExoY", "red"}, true)
  end

  --- subCmd  help 
  local function ShowSubCmdHelp() 
    for subCmd, data in pairs(subCmdTable) do 
      local info = data.info and data.info or ""
      d( zo_strformat("<<1>> - <<2>>", subCmd, info))
    end
  end
  if subCmdTable then 
    subCmdTable["help"] = {
      ["info"] = "overview of sub-commands", 
      ["callback"] = ShowSubCmdHelp 
    }
    callback = callback and callback or ShowSubCmdHelp
  end
    
  --- define slash command 
  SLASH_COMMANDS[cmd] = function( input ) 

    if LibExoY.IsStringEmpty(input) then  callback() return end

    --- deserialization of input 
    input = string.lower(input) 
    local param = {}
    for str in string.gmatch(input, "%S+") do
      table.insert(param, str)
    end

    --- call the appropriate function
    if subCmdTable[ param[1] ] then 
      local subCmd = param[1]
      table.remove(param, 1)
      subCmdTable[ subCmd].callback(param) 
    else 
      callback(param) 
    end

  end 

end

-- different function for chat cmds used during the development process 
-- makes it easier to find

function LibExoY.TestCmd(...) 
  LibExoY.AddSlashCmd(...) 
end