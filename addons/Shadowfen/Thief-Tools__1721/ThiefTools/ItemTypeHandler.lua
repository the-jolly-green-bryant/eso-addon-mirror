ThiefTools_ItemTypeHandler = {}
local ItemTypeHandler = ThiefTools_ItemTypeHandler

local SF = LibSFUtils
local color = SF.hex

local TTmsg = SF.addonChatter:New("ThiefTools")
TTmsg:disableDebug()

local emptyfunction = function(...) return end
ItemTypeHandler.defaultHandler = emptyfunction
ItemTypeHandler.namelist = {
	[emptyfunction] = "No handler",
}


function ItemTypeHandler:New(itemtype)
	local ith = {}
	setmetatable(ith, self)
	self.__index = self

	ith.itemType = itemtype
	ith.primary = nil
	ith.secondary = nil
	ith.alternate = {}

	return ith
end

-- get the handler for an ITEMTYPE
function ItemTypeHandler:effectivePrimary(hotItem)
	local itemType = hotItem.itemType
    if( itemType ~= self.itemType ) then return end

	local specItem = hotItem.specializedItemType
	local handlerfunc = self:getEffectivePrimary(specItem)
	return handlerfunc(hotItem)
end

-- get the handler for an EQUIP_TYPE
function ItemTypeHandler:effectiveEquip(hotItem)
	local equipType = hotItem.equipType
    if( equipType ~= self.itemType ) then
		return
	end

	local handlerfunc = self:getEffectivePrimary()
	return handlerfunc(hotItem)
end

-- get the handler for a type (specialized or item if not specialized)
function ItemTypeHandler:getEffectivePrimary(altType)
	if( altType ~= nil ) then
      if( self.alternate[altType] ) then
          -- we have a handler for this specializedItemType
          return self.alternate[altType]
      end
	end

	if( self.primary ~= nil ) then
      -- return the primary handler since we're not specialized for altType
      return self.primary
	end

    -- didn't even have a primary handler so go with the default
  	return self.defaultHandler
end

function ItemTypeHandler:setPrimary(handler, handlername)
	self.primary=handler
	if( handlername ~= nil ) then
		ItemTypeHandler.namelist[handler] = handlername
	end
end

function ItemTypeHandler:setSecondary(handler, handlername)
	self.secondary=handler
	if( handlername ~= nil ) then
		ItemTypeHandler.namelist[handler] = handlername
	end
end

function ItemTypeHandler:setAlternate(altitemType, handler, handlername)
	if( type(altitemType) == "table" ) then
		for k,v in pairs(altitemType) do
			self.alternate[v] = handler
		end
	else
      self.alternate[altitemType]=handler
	end
	if( handlername ~= nil ) then
	  ItemTypeHandler.namelist[handler] = handlername
	end
end

function ItemTypeHandler:hasAlternate(itemType)
	if( self.alternate[itemType] ) then
		return true
	end
	return false
end

function ItemTypeHandler:displayAlternateList()
	TTmsg:d("alternates defined:")
	for k,h in pairs(self.alternate) do
		TTmsg:d("alternate: IT="..self.itemType,"  SIT="..k, self:getHandlerName(h))
	end
end

function ItemTypeHandler:getHandlerName(spec)
    local h = nil
    if( type(spec) == "function" ) then
        h = spec
    else
        h = self:getEffectivePrimary(spec)
    end
    if( h == nil ) then
        return "name lookup returned nil"
    end
    if( ItemTypeHandler.namelist[h] ) then
        return ItemTypeHandler.namelist[h]
    else
        TTmsg:d("don't have name for handler")
    end
    return "unknown"
end

function ItemTypeHandler:displayHandlerList()
    for k,v in pairs(ItemTypeHandler.namelist) do
        if( type(k) == "function" ) then
            TTmsg:d("["..self:getHandlerName(k).."] = "..v)
        else
            TTmsg:d("["..k.."] = "..v)
        end
    end
end