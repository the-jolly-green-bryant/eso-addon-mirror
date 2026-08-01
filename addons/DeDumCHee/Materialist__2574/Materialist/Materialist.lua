Mvars = {}
Mvars.default = {}
Mvars.default.chatColor = {r=204,g=102,b=255}
Mvars.default.hex = "cc66ff"
Mvars.default.iniText = false
thisName = "Materialist"
 
function onInitialize(event, addonName)
  if (addonName == thisName) then
    Mvars.saved = ZO_SavedVars:NewAccountWide("Mvars",1,nil,Mvars.default)
    deconTable = {}
    createSettings()
      if (Mvars.saved.hex ~= nil) then
        d("|c" .. Mvars.saved.hex .. "Materialist Initialized|r")
      else
        d(d("|ccc66ffMaterialist Initialized|r"))
      end
  end
end

--I totally stole this from Phinix but I didn't want an extra dependency
--All credit to original author, thanks <3
function rgbtohex(rgb)
    local r = (rgb['r']) and rgb['r'] or rgb[1]
    local g = (rgb['g']) and rgb['g'] or rgb[2]
    local b = (rgb['b']) and rgb['b'] or rgb[3]
  
    local cstring = ""
    local function cProc(val)
      local colornum = val * 255
      local hexstr = "0123456789abcdef"
      local s = ""
      while colornum > 0 do
        local mod = math.fmod(colornum, 16)
        s = string.sub(hexstr, mod+1, mod+1) .. s
        colornum = math.floor(colornum / 16)
      end
      if #s == 1 then s = "0" .. s end
      if s == "" then s = "00" end
      return s
    end
    cstring = cProc(r)..cProc(g)..cProc(b)
    return cstring
  end


function createSettings()
  local panelData = {
      type = "panel",
      name = "Materialist",
      author = "De",
      version = "1.2",
      registerForRefresh = true,
      registerForDefaults = true,
      }
  local optionsData = {
      {
          type = "checkbox",
          name = "Crafting Text",
          tooltip = "Show a message in chat when opening a crafting station.",
          getFunc = function() 
                      return Mvars.saved.iniText 
                    end,
          setFunc = function(value) 
                      Mvars.saved.iniText = value 
                    end,
      },
      {
          type = "colorpicker",
          name = "Alert Color",
          tooltip = "Color of chat prefixing the item log",
          getFunc = function() 
                      return Mvars.saved.chatColor.r,Mvars.saved.chatColor.g,Mvars.saved.chatColor.b 
                    end,
          setFunc = function(r,g,b) 
                      Mvars.saved.chatColor = {r=r,g=g,b=b}
                      Mvars.saved.hex = rgbtohex(Mvars.saved.chatColor)
                    end,
      }
  }
  local LAM = LibAddonMenu2  
  LAM:RegisterAddonPanel("MaterialistSettings", panelData)
  LAM:RegisterOptionControls("MaterialistSettings", optionsData)
end

function onCraftInteract(_, craftSkill, sameStation)
  deconTable = {}
  if (Mvars.saved.iniText == true) then
  currentCraft = GetCraftingSkillName(craftSkill)
    if (currentCraft == "Alchemy") then
        d("Ah, I see you're an alchemist!")
    elseif (currentCraft == "Blacksmithing") then
      d("Ah, I see you're a blacksmith!")
    elseif (currentCraft == "Clothing") then
      d("Ah, I see you're a clothier!")
    elseif (currentCraft == "Enchanting") then
      d("Ah, I see you're an enchanter!")
    elseif (currentCraft == "Jewelry Crafting") then
      d("Ah, I see you're a jeweler!")
    elseif (currentCraft == "Provisioning") then
        d("Ah, I see you're a chef!")
    elseif (currentCraft == "Woodworking") then
        d("Ah, I see you're a woodworker!")
    end
  end
end

function onItemReceived(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason, countChange)
  if (IsPlayerInteractingWithObject()) then
    curItemId = GetItemId(bagId, slotId)
    curItemCharge = IsItemChargeable(bagId, slotId)
    curItemConsum = IsItemConsumable(bagId, slotId)
    curItemEnchant = IsItemEnchantable(bagId, slotId)
    curItemRune = IsItemEnchantment(bagId, slotId)
    if(countChange >= 1 and curItemCharge ~= true and curItemConsum ~= true and curItemEnchant ~= true and curItemRune ~= true) then
        if (deconTable[curItemId] ~= nil) then
          deconTable[curItemId] = deconTable[curItemId] + countChange
        else 
          deconTable[curItemId] = countChange
        end
    end
  end
end

function onCraftLeave(craftSkill)
  if next(deconTable) ~= nil then
    if (Mvars.saved.hex ~= nil) then
      d("|c" .. Mvars.saved.hex .. "Received:|r")
      for key,value in pairs(deconTable) do d("|H1:item:" .. key .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h |c" .. Mvars.saved.hex .. "x" .. value .. "|r") end
    else
      d("|ccc66ffReceived:|r")
      for key,value in pairs(deconTable) do d("|H1:item:" .. key .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h |ccc66ffx" .. value .. "|r") end
    end
 end
end

EVENT_MANAGER:RegisterForEvent("beginCrafting", EVENT_CRAFTING_STATION_INTERACT, onCraftInteract)
EVENT_MANAGER:RegisterForEvent("itemGet", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onItemReceived)
EVENT_MANAGER:RegisterForEvent("stopCrafting", EVENT_END_CRAFTING_STATION_INTERACT, onCraftLeave)
EVENT_MANAGER:RegisterForEvent("loadAddon", EVENT_ADD_ON_LOADED, onInitialize)