if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

local RAD45, RAD90, RAD180, RAD270, RAD360 = math.rad(45), math.rad(90), math.rad(180), math.rad(270), math.rad(360)
local ceil, floor, min, max, cos, sin, rad, deg = math.ceil, math.floor, math.min, math.max, math.cos, math.sin, math.rad, math.deg
local round = function(n, d) if nil == d then return zo_roundToZero(n) else return zo_roundToNearest(n, 1 / (10 ^ d)) end end
math.roundIntLarger = function(n) return 0 <= n and math.ceil(n) or math.floor(n) end
math.roundIntSmaller = function(n) return 0 <= n and math.floor(n) or math.ceil(n) end

---[ Miscellaneous ]---

function EHH:SlashCommandMyLocation()
	local x, y, z = self:GetPlayerWorldPosition()
	local cameraYaw = GetPlayerCameraHeading()

	self:ShowChatMessage("X (east/west): %d\nY (up/down): %d\nZ (north/south): %d\nCamera Heading: %.2f (degrees)", x, y, z, math.deg(cameraYaw))
end

function EHH:SlashCommandVersion()
	self:ShowChatMessage("%s, version %s installed.", self.Name, tostring(self.AddOnVersion))
end

function EHH:SlashCommandResetRecentHomes(...)
	self:RemoveAllRecentlyVisitedHouses()
	self:ShowChatMessage("Recently visited homes history cleared.")
end

function EHH:SlashCommandResetHome()
	local msg = "The |cffffff/home|r command will now return |cffffff%s|r to your primary home|cffffff%s|r."
	self:ShowChatMessage(" ")

	self:RemovePrimaryHouse()

	local houseId = GetHousingPrimaryHouse()
	local house = self:GetHouseById(houseId)

	if house and house.Description then
		self:ShowChatMessage(msg, self:GetCharacterName(), ", " .. house.Description)
	else
		self:ShowChatMessage(msg, self:GetCharacterName(), "")
	end

	return true
end

function EHH:SlashCommandSetHome(houseName)
	local msg = "The |cffffff/home|r command will now return |cffffff%s|r to |cffffff%s|r."
	self:ShowChatMessage(" ")

	houseName = self:Trim(houseName or "")

	local house = nil
	if "" == houseName then
		local houseId = GetCurrentZoneHouseId()
		house = self:GetHouseById(houseId)

		if nil == house then
			self:ShowChatMessage("You must be in a house that you own, or you must specify a house name.")
			return false
		end
	end

	if not house then
		local matches = self:FindHousesByName(houseName)

		if not matches or 0 >= #matches then
			self:ShowChatMessage("No houses match '%s'.", houseName)
			return false
		elseif 1 < #matches then
			self:ShowChatMessage("Matched %d houses to '%s':", #matches, houseName)
			for houseId, house in pairs(matches)
				do self:ShowChatMessage("%s", house.Description)
			end
			self:ShowChatMessage("Please be more specific.")
			return false
		end

		house = matches[1]
		if not house.Collected then
			self:ShowChatMessage("You do not own |cffffff%s|r.", house.Name)
			return false
		end
	end

	local CURRENT_CHARACTER = nil
	self:SetPrimaryHouse(CURRENT_CHARACTER, house.Id)
	self:ShowChatMessage(msg, self:GetCharacterName(), house.Description)

	return true
end

function EHH:SlashCommandListFavHouses()
	self:ShowChatMessage(" ")
	self:ShowChatMessage("Favorite Houses:")

	local favorites = self:GetFavoriteHouses()
	for index, houseKey in ipairs(favorites) do
		local houseId, owner = self:GetHouseKeyInfo(houseKey)
		local houseDescription = self:GetHouseDescription(houseId, owner)
		self:ShowChatMessage("|cffffff%d|r. |cffffff%s|r", index, houseDescription)
	end
end

function EHH:SlashCommandSetFavHouse(command)
	self:ShowChatMessage(" ")
	local msgHelp = "For more information, use: |cffffff/setfavhouse|r"
	local msgSuccess = "Set Favorite House |cffffff%d|r to |cffffff%s|r"

	local favHouses = self:GetFavoriteHouses()
	local numFavorites = #favHouses
	local favIndex, houseOwner, houseId, houseName = nil, nil, nil, nil
	local spaceIndex
	command = self:Trim(command or "")

	if "" ~= command then
		spaceIndex = string.find(command, " ")
		if nil == spaceIndex then
			self:ShowChatMessage("Invalid parameters specified.")
			self:ShowChatMessage(msgHelp)
			return false
		end

		favIndex = tonumber(string.sub(command, 1, spaceIndex - 1))
		if not favIndex then
			favIndex = numFavorites + 1
		end

		local maxFavorites = math.min(numFavorites + 1, self.Defs.Limits.MaxFavoriteHouses)
		if 1 > favIndex or favIndex > maxFavorites then
			self:ShowChatMessage("Invalid Favorite Index. Please use 1 through %d.", maxFavorites)
			self:ShowChatMessage(msgHelp)
			return false
		end

		command = self:Trim(string.sub(command, spaceIndex + 1))

		if "@" == string.sub(command, 1, 1) then
			spaceIndex = string.find(command, " ")
			if nil == spaceIndex then
				houseOwner = command
				houseName = ""
			else
				houseOwner = string.sub(command, 1, spaceIndex - 1)
				houseName = self:Trim(string.sub(command, spaceIndex + 1))
			end
		else
			houseName = command
		end

		if "" == houseOwner and "" == houseName then
			self:ShowChatMessage("Invalid Player or House Name specified.")
			self:ShowChatMessage(msgHelp)
			return false
		end

		if houseOwner then houseOwner = self:Trim(string.lower(houseOwner)) end

		if "" ~= houseName then
			local matches = self:FindHousesByName(houseName, nil == houseOwner)
			if nil == matches or 0 >= #matches then
				self:ShowChatMessage("Invalid House Name specified: %s", houseName)
				self:ShowChatMessage(msgHelp)
				return false
			end

			if 1 < #matches then
				self:ShowChatMessage("%d houses match '%s':", #matches, houseName)

				for houseId, house in ipairs(matches) do
					self:ShowChatMessage(" %s", (nil == houseOwner and house.Description or house.Name))
				end

				self:ShowChatMessage("Please be more specific.")
				self:ShowChatMessage(msgHelp)
				return false
			end

			houseId = matches[1].Id
			houseName = matches[1].Name
		end

		if nil ~= favIndex and (nil ~= houseOwner or nil ~= houseId) then
			if self:AddOrUpdateFavoriteHouse(self.World, houseId, houseOwner, favIndex) then
				local houseDescription = self:GetHouseDescription(houseId, houseOwner)
				self:ShowChatMessage(msgSuccess, favIndex, houseDescription)
				return true
			else
				self:ShowChatMessage("Failed to set favorite house.")
				return false
			end
		end
	end

	self:ShowChatMessage("Commands to set a Favorite House:\n")
	self:ShowChatMessage("|cffffff/setfavhouse Index House|r")
	self:ShowChatMessage("|cffffff/setfavhouse Index @Player House|r")
	self:ShowChatMessage("Valid Favorite House indexes are |cffffff1|r through |cffffff%d|r.", math.min(numFavorites + 1, self.Defs.Limits.MaxFavoriteHouses))

	return false
end

function EHH:SlashCommandHome(houseName)
	houseName = self:Trim(houseName or "")
	if "" == houseName then
		self:ShowChatMessage(" ")

		local house = self:GetPrimaryHouse()
		if not house then
			self:ShowChatMessage("You do not have a primary house set up.")
			self:ShowChatMessage("Consider using the |cffffff/house|r command to jump to a specific house,")
			self:ShowChatMessage("or use the |cffffff/sethome|r command to choose a personal home for this character.")
		else
			self:ShowChatMessage("Jumping to your primary home, |cffffff%s|r...", house.Description)
			self:JumpToHouse(house.Id)
		end
	else
		EHH:SlashCommandHouse(houseName)
	end
end

function EHH:SlashCommandHouse(houseName, accountName)
	if nil == houseName then
		return false
	end

	houseName = self:Trim(houseName)
	accountName = self:Trim(accountName)
	
	local outside = false
	if "string" == type(accountName) and "outside" == string.sub(string.lower(accountName), -7, -1) then
		outside = true
		accountName = self:Trim(string.sub(accountName, 1, -7))
	end
	if not outside and "string" == type(houseName) and "outside" == string.sub(string.lower(houseName), -7, -1) then
		outside = true
		houseName = self:Trim(string.sub(houseName, 1, -7))
	end
	
	local originalHouseName = houseName
	local houseIndex = tonumber(houseName)
	local favHouses = self:GetFavoriteHouses()

	self:ShowChatMessage(" ")

	if "" == houseName then 
		self:ShowChatMessage("%s can quickly teleport you to any house, including another player's...\n", self.Name)
		self:ShowChatMessage("Commands:")
		self:ShowChatMessage("|cffffff/home|r")
		self:ShowChatMessage("|cffffff/house House|r")
		self:ShowChatMessage("|cffffff/house @Player|r")
		self:ShowChatMessage("|cffffff/house @Player House|r\n")
		self:ShowChatMessage("|cffffff/house FavoriteIndex|r")
		self:ShowChatMessage("       (such as |cffffff/house 8|r)")

		return false
	end

	if nil ~= houseIndex then
		houseIndex = math.floor(houseIndex)

		if 1 > houseIndex or houseIndex > self.Defs.Limits.MaxFavoriteHouses then
			self:ShowChatMessage("Specify a valid Favorite House using |cffffff1|r through |cffffff%d|r.", self.Defs.Limits.MaxFavoriteHouses)
			return false
		end

		local houseId, houseOwner = self:GetFavoriteHouse(houseIndex)
		if not houseId and not houseOwner then
			self:ShowChatMessage("Favorite House %d has not been set.", houseIndex)
			return false
		end

		local house = self:GetHouseById(houseId)
		if self:IsOwnerLocalPlayer(houseOwner) then
			if not house then
				house = self:GetHouseById(self:GetPrimaryHouseId())
			end
			if house then
				self:ShowChatMessage("Jumping to Favorite House |cffffff%d|r: |cffffff%s|r", houseIndex, house and house.Description or "Primary house")
				self:JumpToHouse(houseId, nil, nil, nil, outsideEntrance)
			end
		else
			if house then
				self:ShowChatMessage("Jumping to Favorite House |cffffff%d|r: |cffffff%s|r owned by |cffffff%s|r", houseIndex, house.Description, houseOwner)
				self:JumpToHouse(houseId, houseOwner, nil, nil, outsideEntrance)
			else
				self:ShowChatMessage("Jumping to Favorite House |cffffff%d|r: |cffffffPrimary house|r of |cffffff%s|r", houseIndex, houseOwner)
				local PRIMARY_HOUSE_ID = nil
				self:JumpToHouse(PRIMARY_HOUSE_ID, houseOwner, nil, nil, outsideEntrance)
			end
		end

		return true
	end

	if nil == accountName and "@" == string.sub(houseName, 1, 1) then
		local nameIndex = string.find(houseName, " ")
		accountName = self:Trim(string.sub(houseName, 1, nameIndex))

		if nil ~= nameIndex then
			houseName = self:Trim(string.sub(houseName, nameIndex + 1))
		else
			houseName = ""
		end
	end

	local matches = self:FindHousesByName(houseName)
	local numMatches = #matches

	if "" ~= houseName and 0 >= numMatches then
		if originalHouseName == houseName then
			self:ShowChatMessage("No house names or nicknames match '%s'.", houseName)
		else
			self:ShowChatMessage("No house names or nicknames match '%s' or '%s'", houseName, originalHouseName)
		end

		return false
	elseif 1 < numMatches then
		self:ShowChatMessage("%d houses match '%s':", numMatches, houseName)

		for houseId, house in ipairs(matches) do
			self:ShowChatMessage(" %s", house.Description)
		end

		self:ShowChatMessage("Please be more specific.")

		return false
	end

	if 1 == numMatches then
		local house = matches[1]
		self:ShowChatMessage("Jumping to %s%s...", nil ~= accountName and string.format("%s's ", accountName) or "", nil == accountName and house.Description or house.Name)
		self:JumpToHouse(house.Id, accountName, nil, nil, outsideEntrance)
	else
		self:ShowChatMessage("Jumping to %s's primary house...", accountName)
		local PRIMARY_HOUSE_ID = nil
		self:JumpToHouse(PRIMARY_HOUSE_ID, accountName, nil, nil, outsideEntrance)
	end

	return true
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Business = true