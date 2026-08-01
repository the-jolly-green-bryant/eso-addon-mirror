
local testLinkFormat = "|H1:item:%u:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local invalidLinkFormat = "|H1:item:%u:20:51:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

local herbs
local potions

WritGrabberAlchemy = {}
WritGrabberAlchemy.name = "WritGrabberAlchemy"
WritGrabberAlchemy.isInitalised = false
WritGrabberAlchemy.traceEnabled = false

local function trace(msg)
  if WritGrabberAlchemy.traceEnabled then
    WritGrabber:Trace(msg)
  end
end

function WritGrabberAlchemy:Initialise()
  local lang = GetCVar("language.2")
  
  for i = 1, #herbs do
    local herb = herbs[i]
    herb.link = string.format(testLinkFormat, herb.id)
    herb.name = zo_strformat("<<1>>", GetItemLinkName(herb.link)):lower()
  end
  
  local replaceText
  local replaceWith
  if lang == "en" then
    replaceText = "sip "
  elseif lang == "de" then
    replaceText = "schlückchen "
  elseif lang == "fr" then
    replaceText = "gorgée "    
  end
  replaceWith = "%%w-%%s"
  
  for i = 1, #potions do
    local potion = potions[i]
    potion.link = string.format(testLinkFormat, potion.id)
    potion.name = zo_strformat("<<1>>", GetItemLinkName(potion.link))
    potion.nameLower = potion.name:lower()
    if replaceText then
      potion.matchName = string.gsub(potion.nameLower, replaceText, replaceWith, 1)
    end   
  end
  
  self.isInitalised = true
end

function WritGrabberAlchemy:FindHerb(text)
  
  if not self.isInitalised then
    self:Initialise()
  end
  
  local textLower = text:lower()
  local lang = GetCVar("language.2")
  -- Fix up Lorkhans tears
  if lang == "de" then        
    local tearsIndex, endIndex = text:find("tränen", 1, true)
    if tearsIndex then
      trace("- Found tränen. Changing")
      text = "lorkhans tränen"
    end
  end
    
  for i = 1, #herbs do
    local herb = herbs[i]
    if herb.name and herb.name ~= "" then
      local startIndex, endIndex = text:find(herb.name, 1, true)
      if startIndex then
        trace("Herb Name ["..herb.name.."]")
        return startIndex, endIndex, herb
      end
    end
  end
end

function WritGrabberAlchemy:FindPotion(text)
  
  if not self.isInitalised then
    self:Initialise()
  end
  local lang = GetCVar("language.2")
  
  local textLower = text:lower()
  
  for i = 1, #potions do
    local potion = potions[i]
    --trace("- Checking for "..potion.name)
    local startIndex, endIndex = textLower:find(potion.matchName)
    if startIndex then
      trace("Potion matchName["..potion.matchName.."]")
      trace("Matched potion at "..startIndex.." to "..endIndex)
      local match = text:sub(startIndex, endIndex)
      trace("Matched text["..match.."]")
      if lang == "de" then        
        local esssenceIndex, endIndex = match:find("esssenz", 1, true)
        if esssenceIndex then
          trace("-esssenz found. replacing")
          -- Check for esssence (the match string is already lowercase)
          match = string.gsub(match, "esssenz", "essenz", 1)
        end
      end      
      return match, potion
    end
  end
end

function WritGrabberAlchemy:DumpHerbs()
  for i = 1, #herbs do
    local herb = herbs[i]
    d(herb)
  end
end

--[[
potions =
                  {
                        [1] = 
                        {
                            ["id"] = 44821,
                        },
                        [2] = 
                        {
                            ["id"] = 54337,
                        },
                        [3] = 
                        {
                            ["id"] = 44810,
                        },
                        [4] = 
                        {
                            ["id"] = 44813,
                        },
                        [5] = 
                        {
                            ["id"] = 54336,
                        },
                        [6] = 
                        {
                            ["id"] = 44814,
                        },
                        [7] = 
                        {
                            ["id"] = 44809,
                        },
                        [8] = 
                        {
                            ["id"] = 30141,
                        },
                        [9] = 
                        {
                            ["id"] = 44815,
                        },
                        [10] = 
                        {
                            ["id"] = 44812,
                        },
                        [11] = 
                        {
                            ["id"] = 27039,
                        },
                        [12] = 
                        {
                            ["id"] = 44714,
                        },
                        [13] = 
                        {
                            ["id"] = 27040,
                        },
                        [14] = 
                        {
                            ["id"] = 44715,
                        },
                        [15] = 
                        {
                            ["id"] = 30145,
                        },
                        [16] = 
                        {
                            ["id"] = 30146,
                        },
                        [17] = 
                        {
                            ["id"] = 44811,
                        },
                        [18] = 
                        {
                            ["id"] = 44817,
                        },
                        [19] = 
                        {
                            ["id"] = 44822,
                        },
                        [20] = 
                        {
                            ["id"] = 30142,
                        },
                        [21] = 
                        {
                            ["id"] = 44820,
                        },
                        [22] = 
                        {
                            ["id"] = 54340,
                        },
                        [23] = 
                        {
                            ["id"] = 54341,
                        },
                        [24] = 
                        {
                            ["id"] = 44816,
                        },
                        [25] = 
                        {
                            ["id"] = 54339,
                        },
                        [26] = 
                        {
                            ["id"] = 44818,
                        },
                        [27] = 
                        {
                            ["id"] = 30144,
                        },
                        [28] = 
                        {
                            ["id"] = 27041,
                        },
                        [29] = 
                        {
                            ["id"] = 44819,
                        },
                        [30] = 
                        {
                            ["id"] = 27042,
                        },
                        [31] = 
                        {
                            ["id"] = 54335,
                        },
                        [32] = 
                        {
                            ["id"] = 54333,
                        }
                    }
                    ]]--
potions =
                      {
                        [1] = 
                        {
                            ["id"] = 44821,
                        },
                        [2] = 
                        {
                            ["id"] = 54337,
                        },
                        [3] = 
                        {
                            ["id"] = 44810,
                        },
                        [4] = 
                        {
                            ["id"] = 44813,
                        },
                        [5] = 
                        {
                            ["id"] = 54336,
                        },
                        [6] = 
                        {
                            ["id"] = 44814,
                        },
                        [7] = 
                        {
                            ["id"] = 44809,
                        },
                        [8] = 
                        {
                            ["id"] = 44815,
                        },
                        [9] = 
                        {
                            ["id"] = 30141,
                        },
                        [10] = 
                        {
                            ["id"] = 44812,
                        },
                        [11] = 
                        {
                            ["id"] = 27039,
                        },
                        [12] = 
                        {
                            ["id"] = 44715,
                        },
                        [13] = 
                        {
                            ["id"] = 27040,
                        },
                        [14] = 
                        {
                            ["id"] = 44714,
                        },
                        [15] = 
                        {
                            ["id"] = 30146,
                        },
                        [16] = 
                        {
                            ["id"] = 30145,
                        },
                        [17] = 
                        {
                            ["id"] = 30142,
                        },
                        [18] = 
                        {
                            ["id"] = 54340,
                        },
                        [19] = 
                        {
                            ["id"] = 54341,
                        },
                        [20] = 
                        {
                            ["id"] = 54339,
                        },
                        [21] = 
                        {
                            ["id"] = 27042,
                        },
                        [22] = 
                        {
                            ["id"] = 27041,
                        },
                        [23] = 
                        {
                            ["id"] = 54335,
                        },
                        [24] = 
                        {
                            ["id"] = 54333,
                        },
                    }

herbs =
                    {
                        [1] = 
                        {
                            ["id"] = 30159,
                        },
                        [2] = 
                        {
                            ["id"] = 30154,
                        },
                        [3] = 
                        {
                            ["id"] = 30166,
                        },
                        [4] = 
                        {
                            ["id"] = 30152,
                        },
                        [5] = 
                        {
                            ["id"] = 30149,
                        },
                        [6] = 
                        {
                            ["id"] = 64500,
                        },
                        [7] = 
                        {
                            ["id"] = 23267,
                        },
                        [8] = 
                        {
                            ["id"] = 4570,
                        },
                        [9] = 
                        {
                            ["id"] = 30165,
                        },
                        [10] = 
                        {
                            ["id"] = 883,
                        },
                        [11] = 
                        {
                            ["id"] = 30153,
                        },
                        [12] = 
                        {
                            ["id"] = 30163,
                        },
                        [13] = 
                        {
                            ["id"] = 30155,
                        },
                        [14] = 
                        {
                            ["id"] = 64501,
                        },
                        [15] = 
                        {
                            ["id"] = 30158,
                        },
                        [16] = 
                        {
                            ["id"] = 30156,
                        },
                        [17] = 
                        {
                            ["id"] = 23266,
                        },
                        [18] = 
                        {
                            ["id"] = 30151,
                        },
                        [19] = 
                        {
                            ["id"] = 30162,
                        },
                        [20] = 
                        {
                            ["id"] = 30161,
                        },
                        [21] = 
                        {
                            ["id"] = 30164,
                        },
                        [22] = 
                        {
                            ["id"] = 23268,
                        },
                        [23] = 
                        {
                            ["id"] = 1187,
                        },
                        [24] = 
                        {
                            ["id"] = 23265,
                        },
                        [25] = 
                        {
                            ["id"] = 30160,
                        },
                        [26] = 
                        {
                            ["id"] = 30148,
                        },
                        [27] = 
                        {
                            ["id"] = 30157,
                        },
                    }