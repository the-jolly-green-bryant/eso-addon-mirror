local LIB = "FLUFFIELS_PANICBEAMS";
local FLUFFIELS_PANICBEAMS = _G[LIB];

if not FLUFFIELS_PANICBEAMS then
   
    FLUFFIELS_PANICBEAMS = FLUFFIELS_PANICBEAMS or {}
    _G[LIB] = FLUFFIELS_PANICBEAMS
    
	--API global function to enable/disable the BFF feature
	--the function expects one string, it can be unitTag OR displayName
	--if no parameter is passed, the BFF will be disabled
	--example: FLUFFIELS_PANICBEAMS.SetBFF("@PlayerName") to set @PlayerName as BFF
	--example: FLUFFIELS_PANICBEAMS.SetBFF("group3") to set unitTag group3 as BFF
	--example: FLUFFIELS_PANICBEAMS.SetBFF() to disable
	function FLUFFIELS_PANICBEAMS.SetBFF(name)
		if FLUFFIELS_PANICBEAMS.state == nil or FLUFFIELS_PANICBEAMS.GetUnitTag == nil then return end
		if not IsUnitGrouped('player') then return end
		
		--disable BFF if nil
		if name == nil then
			FLUFFIELS_PANICBEAMS.state.BFF = nil
			return true
		end
		
		--convert displayName into unitTag
		if name ~= "" and IsDecoratedDisplayName(name) then
			local unitTag = FLUFFIELS_PANICBEAMS.GetUnitTag(name)
			if unitTag == nil then return end
			name = unitTag
		end
		
		--if the unitTag is invalid or self, don't proceed
		if (name == 'player') or
			(not ZO_Group_IsGroupUnitTag(name)) or
			(not DoesUnitExist(name)) or
			(not IsUnitGrouped(name)) or
			(AreUnitsEqual(name, 'player')) then
			return
		end
		
		FLUFFIELS_PANICBEAMS.state.BFF = name
		
		--return success boolean
		return true
	end
    
    function FLUFFIELS_PANICBEAMS.Class(base, init)
       local c = {}    -- a new class instance
       if not init and type(base) == 'function' then
          init = base
          base = nil
       elseif type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
          for i,v in pairs(base) do
             c[i] = v
          end
          c._base = base
       end
       -- the class will be the metatable for all its objects,
       -- and they will look up their methods in it.
       c.__index = c

       -- expose a constructor which can be called by <classname>(<args>)
       local mt = {}
       mt.__call = function(class_tbl, ...)
       local obj = {}
       setmetatable(obj,c)
       if init then
          init(obj,...)
       else 
          -- make sure that any stuff from the base class is initialized!
          if base and base.init then
          base.init(obj, ...)
          end
       end
       return obj
       end
       c.init = init
       c.is_a = function(self, klass)
          local m = getmetatable(self)
          while m do 
             if m == klass then return true end
             m = m._base
          end
          return false
       end
       setmetatable(c, mt)
       return c
    end
    
end