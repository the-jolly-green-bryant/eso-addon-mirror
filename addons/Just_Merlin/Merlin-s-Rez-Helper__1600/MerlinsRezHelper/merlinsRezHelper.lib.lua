local LIB = "MERLINS_REZHELPER";
local MERLINS_REZHELPER = _G[LIB];

if not MERLINS_REZHELPER then
   
    MERLINS_REZHELPER = MERLINS_REZHELPER or {}
    _G[LIB] = MERLINS_REZHELPER
    
    MERLINS_REZHELPER.NormalizeAngle = function (s, c)
        if c == nil then c = s end
        if c > math.pi then return c - 2 * math.pi end
        if c < -math.pi then return c + 2 * math.pi end
        return c
    end
    
    function MERLINS_REZHELPER.Extend(value, default)
        value = value or {}
        for k,v in pairs(default) do
            if type(value[k]) == "nil" then
                value[k] = v
            end
        end
        return value
    end
    
    function MERLINS_REZHELPER.Class(base, init)
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