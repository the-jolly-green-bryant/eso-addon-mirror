MARKEditProfile = MARKEditProfile or {}
MARKEditMarker = MARKEditMarker or {}

local CONFIG_TYPE_ELMS = "/(%d+)//(%d+),(%d+),(%d+),(%d+)/"
local CONFIG_TYPE_MARKER = "(%d+)//%d+/%d+/%d+/%d+/%d+"
local CONFIG_GET_MARKER = "//(%d+)/(%d+)/(%d+)/(%d+)/(%d+)"

-- Localize heavily used globals for performance
local EM = EVENT_MANAGER
local t_tonumber = tonumber
local s_match = string.match
local s_gmatch = string.gmatch

function MARKEditProfile.new(self, id)
    local data = MARK.copyTable(MARK.getProfileData(id))
    if data == nil then return end
    setmetatable(data, self)
    self.__index = self
    MARK.UI.Edit.Profile = data
end

function MARKEditProfile.setConfig(self, config)
    self.marker = {}
    
    -- Localize utility functions accessed inside the loop to avoid global lookups
    local getUuid = LibAkaUtils.uuid
    local getEmote = LibEmote.GetEmoteByIndex
    
    if s_match(config, CONFIG_TYPE_ELMS) ~= nil then
        MARK.importConfig = function(elmsSize)
            elmsSize = t_tonumber(elmsSize) or 100
            for zone, x, y, z, e in s_gmatch(config, CONFIG_TYPE_ELMS) do
                zone = t_tonumber(zone)
                x = t_tonumber(x)
                y = t_tonumber(y)
                z = t_tonumber(z)
                e = t_tonumber(e)
                
                if zone == nil or zone ~= self.zone then 
                    MARK.notify("Invalid Config!")
                    MARK.notify("You are not in the right zone")
                    return
                end
                
                if x and y and z and e then
                    local marker = {
                        id = getUuid(),
                        x = x,
                        y = y,
                        z = z,
                        texture = MARK.getMarkerIndexElms(e),
                        size = elmsSize,
                    }
                    self.marker[marker.id] = marker
                end
            end
        end
        MARK.hideall()
        MarkerUIImportSizeSelector:SetHidden(false)
        
    elseif s_match(config, CONFIG_TYPE_MARKER) ~= nil then
        local zone = s_match(config, CONFIG_TYPE_MARKER)
        zone = t_tonumber(zone or 0)
        
        if zone == nil or zone ~= self.zone then
            MARK.notify("Invalid Config!")
            MARK.notify("You are not in the right zone")
            return 
        end
        
        for xn, yn, zn, s, e in s_gmatch(config, CONFIG_GET_MARKER) do
            local x = t_tonumber(xn)
            local y = t_tonumber(yn)
            local z = t_tonumber(zn)
            s = t_tonumber(s)
            e = t_tonumber(e)
            
            if x and y and z and s and e then
                local emote = getEmote(e)
                if emote and emote.name ~= "" then
                    local marker = {
                        id = getUuid(),
                        x = x,
                        y = y,
                        z = z,
                        texture = e,
                        size = s,
                    }
                    self.marker[marker.id] = marker
                end
            end
        end
    else
        local decoded = {}
        local success = pcall(function() decoded = LibJson.decode(config) end)
        
        if success and decoded then
            local zone = t_tonumber(decoded.zone or 0)
            if zone == nil or zone ~= self.zone then
                MARK.notify("Invalid Config!")
                MARK.notify("You are not in the right zone")
                return 
            end
            self.zone = decoded.zone
            self.marker = decoded.marker
            self.onLoad = decoded.onLoad
            self.onUnload = decoded.onUnload
        else
            MARK.notify("Invalid Config!")
            MARK.notify("Supported: Marker, MarkerJson, Elms")
            return
        end
    end
end

function MARKEditProfile.setOnLoad(self, code)
    self.onLoad = code
end

function MARKEditProfile.setOnUnload(self, code)
    self.onUnload = code
end

function MARKEditProfile.setName(self, name)
    self.name = name
end

function MARKEditProfile.save(self)
    -- PERFORMANCE FIX: Do not deep copy the 'self' metatable object.
    -- Build a pure data table directly. This saves immense GC pressure.
    local cleanData = {
        id = self.id,
        zone = self.zone,
        name = self.name,
        marker = self.marker,
        onLoad = self.onLoad,
        onUnload = self.onUnload
    }
    
    MARK.saveProfileData(self.id, cleanData)
    MARK.unloadProfile(true)
    MARK.loadProfile(self.id)
    MARK.UI.Edit.Profile = nil
end

function MARKEditMarker.new(self, id)
    local profile = MARK.loadedProfile
    if profile == nil then return end
    
    local originalData = profile.data.marker[id]
    if originalData == nil then return end
    
    -- PERFORMANCE FIX: Marker data is flat. We don't need a heavy recursive deep copy. 
    -- A simple shallow iteration is much faster here.
    local data = {}
    for k, v in pairs(originalData) do
        data[k] = v
    end
    
    setmetatable(data, self)
    self.__index = self
    MARK.UI.Edit.Marker = data
    
    data.moveMarker = PreviewMarker:new(data.texture, function()
        RightMarkerViewInput1:SetText(data.moveMarker.x)
        RightMarkerViewInput2:SetText(data.moveMarker.y)
        RightMarkerViewInput3:SetText(data.moveMarker.z)
        EM:UnregisterForEvent(MARK.name .. "UpdateEdit", EVENT_RETICLE_HIDDEN_UPDATE)
        data.moveMarker:unbind()
    end, profile:getMarkerObject(id))
    
    data.moveMarker:unbind()
    
    -- PERFORMANCE FIX: Replaced expensive 200ms polling loop with Native State-Change Event
    EM:UnregisterForEvent(MARK.name .. "UpdateEdit", EVENT_RETICLE_HIDDEN_UPDATE)
    EM:RegisterForEvent(MARK.name .. "UpdateEdit", EVENT_RETICLE_HIDDEN_UPDATE, function(_, hidden)
        if hidden then
            data.moveMarker:unbind()
        else
            data.moveMarker:bind()
        end
    end)
end

function MARKEditMarker.setRequirement(self, code)
    self.requirement = code
end

function MARKEditMarker.setData(self, x, y, z, texture, size)
    self.x = x or self.x
    self.y = y or self.y
    self.z = z or self.z
    self.texture = texture or self.texture
    self.size = size or self.size
end

function MARKEditMarker.save(self)
    self.moveMarker = nil
    local profile = MARK.loadedProfile
    if profile == nil then return end
    
    -- PERFORMANCE FIX: Create a pure data object instead of deep copying a metatable object.
    local cleanData = {
        id = self.id,
        x = self.x,
        y = self.y,
        z = self.z,
        texture = self.texture,
        size = self.size,
        requirement = self.requirement
    }
    
    profile:setMarker(cleanData)
    MARK.UI.Edit.Marker = nil
    EM:UnregisterForEvent(MARK.name .. "UpdateEdit", EVENT_RETICLE_HIDDEN_UPDATE)
end