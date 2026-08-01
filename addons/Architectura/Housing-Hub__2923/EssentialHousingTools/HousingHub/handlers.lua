if IsNewerEssentialHousingHubVersionAvailable() or not IsEssentialHousingHubRootPathValid() then
	return
end

local EHH = EssentialHousingHub
if not EHH then
	return
end

---[ Event Handlers ]---

function EHH:OnPlayerActivated(_, initialActivation)
	self:InitUMTD()

	-- This flag must be set first before anything else.
	self.IsEHT = self:IsEHTEnabled()
	if self.IsEHT then
		-- Allow EHT's effects system to override the Hub's system.
		self.Defs.EnableEffects = false
	end
	
	self:LoadAllCommunityMetaData()
	self:DeferredInitialize()
	self:OnKeybindingsUpdated()

	if self.IsEHT then
		-- Perform one-time data migration from EHT.
		local DO_NOT_FORCE_MIGRATION = nil
		self:MigrateHouseDataFromEHT(DO_NOT_FORCE_MIGRATION)
	end

	if self.HouseJumpRequest and self.HouseJumpRequest.OnSuccess then
		local callback = self.HouseJumpRequest.OnSuccess
		local houseId = self.HouseJumpRequest.HouseId
		local owner = self.HouseJumpRequest.Owner
		local metaData = self.HouseJumpRequest.MetaData

		zo_callLater(function()
			callback(houseId, owner, metaData)
		end, 1)
	end
	
	self.LastMouseClick = 0
	self.FurnitureIdList = {}
	self.HouseJumpRequest = nil
	self:CancelJumpToHouse()

	local FORCE_REFRESH = true
	self:GetAllHouses(FORCE_REFRESH)
	self:DeferredInitializeHub()
	self:OnHubTileMoveStopped()

	if self.Defs.EnableEffects then
		self.Effect:DeleteAll()
	end

	local didZoneChange = self:IsInDifferentZone()
	local isInHouse = self:IsHouseZone()
	if didZoneChange or not isInHouse then
		self:OnCurrentHouseChanged(isInHouse)
	end
	self:UpdateCurrentZone()
	self:UpdateCurrentHouseStats()
	self:RefreshWidgetPosition()
	self:ResetWidget()
	self:RefreshWidget()

	if self.Defs.EnableEffects then
		self.Effect.OnWorldChange()
		self.EffectUI.PreloadAll()
	end

	if didZoneChange then
		if self.Defs.EnableEffects then
			self.EffectFurnitureStateManager:Reset()
		end

		local USE_DEFAULT_HOUSE_NAME = nil
		self:SetCustomHouseName(USE_DEFAULT_HOUSE_NAME)
	end
end

function EHH:OnCommunityMetaDataLoaded()
	self:QueueLiveStreamerMessages()
end

function EHH:OnGlobalMouseDown(event, button, ctrl, alt, sh, cmd)
	if button == MOUSE_BUTTON_INDEX_LEFT then
		self.LastMouseClick = GetFrameTimeMilliseconds()
	end
end

function EHH:OnCurrentHouseChanged(isInHouse)
	self:RestoreAllGameSettings()

	if isInHouse then
		self:UpdateRecentlyVisitedHouses()

		if not self:IsOwner() then
			local houseId = self:GetHouseId()
			local owner = self:GetOwner()
			self:SetHouseInaccessibleFlag(self.World, houseId, owner, false)
		end
	end

	if self.Defs.EnableEffects then
		EHH.EffectFurnitureStateManager:Reset()
	end
end

function EHH:OnHousePopulationChanged(_, population)
	if population and self.CurrentHousePopulation ~= population then
		if 0 ~= population then
			self:ShowHousePopulationChanged(population)
		end

		self.CurrentHousePopulation = population
	end
end

function EHH:OnFurnitureStateChanged(_, furnitureId, newStateIndex, oldStateIndex)
	if not self.Defs.EnableEffects then
		return
	end

	local newState = self:GetFurnitureStateByStateIndex(furnitureId, newStateIndex)
	local oldState = self:GetFurnitureStateByStateIndex(furnitureId, oldStateIndex)
	EHH.EffectFurnitureStateManager:OnFurnitureStateChanged(furnitureId, newState, oldState)
end

function EHH:OnHouseJumpRequestTimedOut()
	HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".HouseJumpRequested")

	if self.HouseJumpRequest and self.HouseJumpRequest.OnFailure then
		local callback, houseId, owner, metaData
		callback = self.HouseJumpRequest.OnFailure
		houseId = self.HouseJumpRequest.HouseId
		owner = self.HouseJumpRequest.Owner
		metaData = self.HouseJumpRequest.MetaData
		zo_callLater(function() callback(houseId, owner, metaData) end, 1)
	end

	self.HouseJumpRequest = nil
end

function EHH:OnHouseJumpFailed(message, invalidOwner, inaccessible)
	HUB_EVENT_MANAGER:UnregisterForUpdate(self.Name .. ".HouseJumpRequested")

	local request = self.HouseJumpRequest
	if not request then
		return
	end

	if self.HouseJumpRequest and self.HouseJumpRequest.OnFailure then
		local callback, houseId, owner, metaData
		callback = self.HouseJumpRequest.OnFailure
		houseId = self.HouseJumpRequest.HouseId
		owner = self.HouseJumpRequest.Owner
		metaData = self.HouseJumpRequest.MetaData
		zo_callLater(function() callback(houseId, owner, metaData) end, 1)
	end

	local dialogShown = false

	if request.Owner and (invalidOwner or inaccessible) then
		self:SetHouseInaccessibleFlag(self.World, request.HouseId, request.Owner, true)

		if inaccessible then
			self:ConfirmNotifyOpenHouseOwner(request.HouseId, request.Owner)
			dialogShown = true
		end
	end

	if message then
		self:DisplayNotification(message)
		self:ShowChatMessage(message)
	end

	if not dialogShown then
		if "hub" == request.Source then
			self:ShowHousingHub()
		end
	end

	if self.Defs.EnableEffects then
		if "portal" == request.Source then
			self.Effect.OnPortalJumpComplete()
		end
	end

	self.HouseJumpRequest = nil
end

function EHH:OnSocialError(_, socialActionResult)
	local request = self.HouseJumpRequest
	if request then
		local invalidOwner, inaccessible = false, false
		local message

		if socialActionResult == SOCIAL_RESULT_CHARACTER_NOT_FOUND or socialActionResult == SOCIAL_RESULT_ACCOUNT_NOT_FOUND then
			message = "The specified @player name is invalid."
			invalidOwner = true
		elseif socialActionResult == SOCIAL_RESULT_CANT_JUMP_INVALID_TARGET then
			message = "That home is currently inaccessible."
		elseif socialActionResult == SOCIAL_RESULT_DESTINATION_FULL then
			message = "That home is currently at maximum player capacity."
		elseif socialActionResult == SOCIAL_RESULT_NO_HOUSE_PERMISSION then
			message = "You do not have permission to visit that home."
			inaccessible = true
		end

		self:OnHouseJumpFailed(message, invalidOwner, inaccessible)
	end
end

function EHH:OnJumpFailed(_, jumpResult)
	local request = self.HouseJumpRequest
	if request then
		local invalidOwner, inaccessible = false, false
		local message

		if jumpResult == JUMP_RESULT_JUMP_FAILED_NO_HOUSE_PERMISSION then
			message = "You do not have permission to visit that home."
			inaccessible = true
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_DONT_OWN_HOUSE then
			message = "That instance is unavailable at the moment."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_INSTANCE_FULL or jumpResult == JUMP_RESULT_JUMP_FAILED_INSTANCE_CAP_REACHED then
			message = "That home is at full player capacity."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_INVALID_HOUSE then
			message = "That home is invalid."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_NO_SOCIAL or jumpResult == JUMP_RESULT_NO_JUMP_PERMISSION then
			message = "Fast travel request failed."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_QUEUING then
			message = "Failed to queue fast travel."
		elseif jumpResult ~= JUMP_RESULT_LOCAL_JUMP_SUCCESSFUL and jumpResult ~= JUMP_RESULT_JUMP_FAILED_ALREADY_JUMPING and jumpResult ~= JUMP_RESULT_REMOTE_JUMP_INITIATED then
			message = string.format("Fast travel failed. (Code: %d)", jumpResult or -1)
		end

		self:OnHouseJumpFailed(message, invalidOwner, inaccessible)
		self.HouseJumpRequest = nil
	end
end

function EHH:OnGuildUpdated()
	self:ClearGuildCache()
end

function EHH:OnCollectibleUpdated(eventCode, collectibleId)
	local FORCE_REFRESH = true
	self:GetAllHouses(FORCE_REFRESH)
	self:UpdateOpenHouseNickname(collectibleId)
end

function EHH:OnFurniturePlaced(_, furnitureId, collectibleId)
	if furnitureId and 0 ~= furnitureId then
		self:UpdateCurrentHouseStats()
	end
end

function EHH:OnFurnitureRemoved(_, furnitureId, collectibleId)
	if furnitureId and 0 ~= furnitureId then
		if self.Defs.EnableEffects then
			self.EffectFurnitureStateManager:UnregisterHandlers(furnitureId)
		end
		self:UpdateCurrentHouseStats()
	end
end

do
	local suppressErrorMessages = false
	local errorQueue = {}

	local ERROR_DIALOG_BUTTONS =
	{
		{text = "Don't show anymore this session", handler = function() suppressErrorMessages = true end},
		{text = "Close Window", handler = function() end},
	}

	function EHH:QueueLuaErrorDialog(addOnName, stackString)
		if not suppressErrorMessages then
			table.insert(errorQueue, {addOnName = addOnName, stackString = stackString})

			HUB_EVENT_MANAGER:RegisterForUpdate("EssentialHousingHub.UpdateLuaErrorDialog", 100, function()
				local unregister = false
				if suppressErrorMessages then
					unregister = true
				elseif self:IsCustomDialogHidden() then
					local errorData = table.remove(errorQueue, 1)
					if errorData then
						self:ShowQueuedLuaErrorDialog(errorData.addOnName, errorData.stackString)
					else
						unregister = true
					end
				end

				if unregister then
					HUB_EVENT_MANAGER:UnregisterForUpdate("EssentialHousingHub.UpdateLuaErrorDialog")
					ZO_ClearNumericallyIndexedTable(errorQueue)
				end
			end)
		end
	end

	function EHH:ShowQueuedLuaErrorDialog(addOnName, stackString)
		if stackString and "" ~= stackString then
			local message = string.format("Well this is embarrassing...\n\n" ..
				"|ac%s seems to have run into something unexpected.", addOnName)
			local data =
			{
				body = message,
				edit =
				{
					defaultText = nil,
					editEnabled = false,
					maxLineCount = 15,
					text = stackString or "No stack trace available.",
				},
				buttons = ERROR_DIALOG_BUTTONS
			}
			self:ShowCustomDialog(data)
		end
	end

	local isFirstRelevantException = true

	function EHH:OnLuaError(_, stackString)
		if "string" == type(stackString) then
			local eht = PlainStringFind(stackString, "EssentialHousingTools")
			local hub = PlainStringFind(stackString, "HousingHub")
			if eht or hub then
				ZO_ERROR_FRAME:HideCurrentError()
				if suppressErrorMessages then
					return
				end

				local addOnName = eht and "Essential Housing Tools" or "Housing Hub"
				self:QueueLuaErrorDialog(addOnName, stackString)

				self:IncUMTD("n_exc", 1)
				if isFirstRelevantException then
					isFirstRelevantException = false
					self:SetUMTD("m_fexc", stackString)
				else
					self:SetUMTD("m_lexc", stackString)
				end
			end
		end
	end
end

---[ Events : Registrations ]---

function EHH:RegisterEventHandlers()
	if not self.RegisteredEventHandlers then
		self.RegisteredEventHandlers = true

		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_PLAYER_ACTIVATED, function(...) return self:OnPlayerActivated(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_HOUSING_POPULATION_CHANGED, function(...) return self:OnHousePopulationChanged(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_SOCIAL_ERROR, function(...) return self:OnSocialError(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_JUMP_FAILED, function(...) return self:OnJumpFailed(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_COLLECTIBLE_UPDATED, function(...) return self:OnCollectibleUpdated(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GLOBAL_MOUSE_DOWN, function(...) return self:OnGlobalMouseDown(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_HOUSING_FURNITURE_PLACED, function(...) return self:OnFurniturePlaced(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_HOUSING_FURNITURE_REMOVED, function(...) return self:OnFurnitureRemoved(...) end)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_HOUSING_FURNITURE_STATE_CHANGED, function(...) return self:OnFurnitureStateChanged(...) end)

		local function OnKeybindingsUpdated()
			self:OnKeybindingsUpdated()
		end

		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_KEYBINDINGS_LOADED, OnKeybindingsUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_KEYBINDING_CLEARED, OnKeybindingsUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_KEYBINDING_SET, OnKeybindingsUpdated)

		local function OnGuildUpdated(...)
			return self:OnGuildUpdated(...)
		end

		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_DESCRIPTION_CHANGED, OnGuildUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_ID_CHANGED, OnGuildUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_MEMBER_ADDED, OnGuildUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_MEMBER_REMOVED, OnGuildUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_MOTD_CHANGED, OnGuildUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_SELF_JOINED_GUILD, OnGuildUpdated)
		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_SELF_LEFT_GUILD, OnGuildUpdated)

		HUB_EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_LUA_ERROR, function(eventCode, stackString) return self:OnLuaError(eventCode, stackString) end)
	end
end

function EHH:UnregisterHandlers()
	if self.RegisteredEventHandlers then
		self.RegisteredEventHandlers = false

		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_PLAYER_ACTIVATED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_HOUSING_POPULATION_CHANGED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_CHAT_MESSAGE_CHANNEL)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_SOCIAL_ERROR)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_JUMP_FAILED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_COLLECTIBLE_UPDATED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_HOUSING_FURNITURE_PLACED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_HOUSING_FURNITURE_REMOVED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_HOUSING_FURNITURE_STATE_CHANGED)

		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_KEYBINDINGS_LOADED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_KEYBINDING_CLEARED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_KEYBINDING_SET)

		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GUILD_DESCRIPTION_CHANGED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GUILD_ID_CHANGED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GUILD_MEMBER_ADDED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GUILD_MEMBER_REMOVED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GUILD_MOTD_CHANGED)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GUILD_SELF_JOINED_GUILD)
		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GUILD_SELF_LEFT_GUILD)

		HUB_EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_LUA_ERROR)
	end
end

---[ Module Registration ]---

EssentialHousingHub.Modules.Handlers = true


function EE()
	df("Testing %d")
end