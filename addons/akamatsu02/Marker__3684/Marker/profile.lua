MARK = MARK or {}
MarkerProfile = {}

-- PERFORMANCE: Localize globals for speed
local t_insert = table.insert
local t_concat = table.concat
local t_tostring = tostring
local t_tonumber = tonumber
local m_round = math.round
local s_gsub = string.gsub
local getPlayerPos = GetUnitRawWorldPosition
local EM = EVENT_MANAGER

function MarkerProfile.new(self, savedData)
	if savedData == nil then
		savedData = {
			id = LibAkaUtils.uuid(),
			name = "New Profile",
			zone = 0,
			marker = {},
			onLoad = nil,
			onUnload = nil
		}
	end
	local newprofile = {
		data = savedData,
		config = "",
		onUnloadFunc = nil,
		onLoadFunc = nil,
		markerObjects = {},
		nameList = {},
		loadedMarkers = 0,
		funcState = false
	}
    setmetatable(newprofile, self)
    self.__index = self
	newprofile:dataUpdate()
    return newprofile
end

function MarkerProfile.dataUpdate(self)
	self:unload()
	self.markerObjects = {}
	self.nameList = {}
	for markerId, marker in pairs(self.data.marker) do
		t_insert(self.nameList, markerId)
		self.markerObjects[markerId] = Marker:new(marker)
	end
	self:loadFuncs()
	MARK.RefreshList()
    return self
end

function MarkerProfile.loadFuncs(self)
    -- PERFORMANCE FIX: zo_loadstring natively returns nil, err on failure. 
    -- Removed expensive pcall wrapper.
	if self.data.onLoad ~= nil and self.data.onLoad ~= "" then
        local func, err = zo_loadstring(self.data.onLoad)
		if type(func) == "function" then
            self.onLoadFunc = func
        else
			d("Marker: onLoad invalid! " .. t_tostring(err))
            self.onLoadFunc = nil
		end
	else
		self.onLoadFunc = nil
	end
    
	if self.data.onUnload ~= nil and self.data.onUnload ~= "" then
        local func, err = zo_loadstring(self.data.onUnload)
		if type(func) == "function" then
            self.onUnloadFunc = func
        else
			d("Marker: onUnload invalid! " .. t_tostring(err))
            self.onUnloadFunc = nil
		end
	else
		self.onUnloadFunc = nil
	end
end

function MarkerProfile.getElmsConfig(self)
	local zone = t_tostring(self.data.zone)
	local emotes = LibEmote.SearchEmotesByName("mark")
    
    -- PERFORMANCE FIX: Use table.concat instead of string concatenation (..) in a loop
	local outTable = {}
    
    -- PERFORMANCE FIX: Use numeric for-loop for sequential arrays instead of pairs
	for i = 1, #self.nameList do
        local markerId = self.nameList[i]
		local data = self:getMarker(markerId)
		local index = s_gsub(data.texture, "^150", "")
		local textureNumber = "14"
        local numIndex = t_tonumber(index)
        
		if numIndex ~= nil and numIndex <= 70 and numIndex > 0 then
			textureNumber = index
		end
        
		local markerStr = "/"..zone.."//"..m_round(data.x)..","..m_round(data.y)..","..m_round(data.z)..","..textureNumber.."/"
		outTable[#outTable + 1] = markerStr
	end
    
	if #outTable == 0 then return "" end
	return t_concat(outTable, "")
end

function MarkerProfile.getConfig(self)
    -- PERFORMANCE FIX: Use table.concat instead of string concatenation (..) in a loop
	local outTable = { t_tostring(self.data.zone) }
    
    -- PERFORMANCE FIX: Use numeric for-loop for sequential arrays instead of pairs
	for i = 1, #self.nameList do
        local markerId = self.nameList[i]
		local data = self:getMarker(markerId)
		local markerStr = "//"..m_round(data.x).."/"..m_round(data.y).."/"..m_round(data.z).."/"..m_round(data.size).."/"..data.texture
		outTable[#outTable + 1] = markerStr
	end
    
	if #outTable == 1 then return "" end
    
	local out = t_concat(outTable, "")
	self.config = out
	return out
end

function MarkerProfile.getJsonConfig(self)
	local unencoded = self.data
	local encoded = ""
    -- pcall is acceptable here as LibJson.encode can throw hard errors on cyclic/bad tables
	if pcall(function() encoded = LibJson.encode(unencoded) end) then
		return encoded
	else
		return "Error with Config!"
	end
end

function MarkerProfile.load(self)
	local size = #self.nameList
	self:unload()
	MARK._v = {}
	MARK.loadedProfile = self
    
	if type(self.onLoadFunc) == "function" then
		if self.funcState == false then
			self.onLoadFunc()
			self.funcState = true
		end
	end
    
	if size == 0 then return end
    
	local dtime = MARK.savedVars.delay / size
	if dtime < MARK.savedVars.minimumdelay then dtime = MARK.savedVars.minimumdelay end
	local checked = 1
	local rad = MARK.savedVars.radius * MARK.savedVars.radius
	MARK.savedVars.lastProfilesOfZone[self.data.zone] = self.data.id
    
    -- PERFORMANCE FIX: Hoist GetUnitRawWorldPosition OUTSIDE the loop.
    -- Querying the C-API once is infinitely faster than querying it for every marker.
    local zoneId, wx, wy, wz = getPlayerPos("player")
    
    -- PERFORMANCE FIX: Use numeric for-loop for sequential arrays
	for i = 1, size do
        local markerId = self.nameList[i]
		self.markerObjects[markerId]:checkDistance(wx, wy, wz, rad)
	end
    
	MARK.RefreshList()
    
	EM:RegisterForUpdate(MARK.name .. "Update", dtime, function()
		local zId, cwx, cwy, cwz = getPlayerPos("player")
		if zId ~= self.data.zone then
			self:unload()
			return
		end
		if #self.nameList == 0 then return end
		if self.nameList[checked] == nil then checked = 1 end
        
		self.markerObjects[self.nameList[checked]]:checkDistance(cwx, cwy, cwz, rad)
		checked = checked + 1
	end)
end

function MarkerProfile.unload(self)
	MARK.loadedProfile = nil
	MARK.coordTable = {}
    
	if type(self.onUnloadFunc) == "function" then
		if self.funcState == true then
			self.onUnloadFunc()
			self.funcState = false
		end
	end
    
	EM:UnregisterForUpdate(MARK.name .. "Update")
    
	for _, marker in pairs(self.markerObjects) do
		marker:hide()
	end
    
	for _, osiIcon in pairs(OSI.GetPositionIcons()) do
		if osiIcon.data.color == MARK.iconColor then
			OSI.DiscardPositionIcon(osiIcon)
		end
	end
end

function MarkerProfile.remove(self)
    self:unload()
	MARK.savedVars.profiles[self.data.id] = nil
	MARK.RefreshList()
end

function MarkerProfile.setName(self, name)
    self.data.name = name
	self:save()
end

function MarkerProfile.setZone(self, zone)
    self.data.zone = zone
	self:save()
end

function MarkerProfile.removeMarker(self, markerId)
	self.data.marker[markerId] = nil
	self:save()
end

function MarkerProfile.editMarker(self, markerId, data)
	if self.markerObjects[markerId] == nil then return end
    self.markerObjects[markerId]:edit(data)
	self:save()
end

function MarkerProfile.getMarker(self, markerId)
	if markerId == nil then return {} end
	if self.markerObjects[markerId] == nil then return {} end
    return self.markerObjects[markerId]:getData() or {}
end

function MarkerProfile.getMarkerObject(self, markerId)
    return self.markerObjects[markerId]
end

function MarkerProfile.setMarker(self, data)
	self.data.marker[data.id] = data
	self:save()
	self.markerObjects[data.id]:show()
	return data.id
end

function MarkerProfile.save(self)
	MARK.saveProfileData(self.data.id, self.data)
	self:dataUpdate()
	self:load()
end