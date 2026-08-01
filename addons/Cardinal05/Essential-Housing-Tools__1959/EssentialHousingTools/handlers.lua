if not EHT then EHT = { } end
if not EHT.Handlers then EHT.Handlers = { } end

local MAX_CHANGE_SUPPRESSION_DURATION = 3000
local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end
local originalGetGameCameraInteractableActionInfo
local GuiHiddenExemptWindows = { ["ZO_Subtitles"] = true, ["EHTParticle"] = true, ["EHTCameraWin"] = true, ["EHTDeathCounterDialog"] = true, ["EHTGlobalCrossfadeWindow"] = true, }

---[ Events : Furniture Change Overrides ]---

local suppressChanges = { }

local function IsChangeSuppressed( furnitureId )
	if not furnitureId then
		return false
	end

	if "string" ~= type( furnitureId ) then
		furnitureId = string.fromId64( furnitureId )
	end

	if "0" == furnitureId then
		return false
	end

	local suppress = suppressChanges[furnitureId]

	if not suppress or GetFrameTimeMilliseconds() > ( suppress + MAX_CHANGE_SUPPRESSION_DURATION ) then
		return false
	end

	suppressChanges[furnitureId] = nil
	return true
end

function EHT.Handlers.SuppressFurnitureChange( furnitureId )
	if not furnitureId then
		return false
	end

	if "string" ~= type( furnitureId ) then
		furnitureId = string.fromId64( furnitureId )
	end

	if "0" == furnitureId then
		return false
	end

	suppressChanges[furnitureId] = GetFrameTimeMilliseconds()
	return true
end

function EHT.Handlers.ResetFurnitureChangeSuppression()
	suppressChanges = { }
end

---[ Events : Handlers ]---

EHT.LinkHandlers = { }

EHT.LinkHandlers[ "communityapp" ] = function()
	EHT.UI.ShowCommunityAppDialog()
end

function EHT.Handlers.OnAddOnLoaded( event, addonName )
	if addonName == EHT.ADDON_NAME then
		EHT.PushTS( "EHT.Handlers.OnAddOnLoaded" )

		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_ADD_ON_LOADED )
		if not EHT.Setup.Initialize() then
			return
		end

		if EHT.SavedVars.SelectionVolatile then
			EHT.Data.ResetAllSelections()
		end
		
		EHT.UI.SetInspectionItemInfoDialogEnabled(EHT.SavedVars.EnableHUDItemData ~= false)

		EHT.PopTS( "EHT.Handlers.OnAddOnLoaded" )
	end
end

function EHT.Handlers.PlayerActivated(event, initial)
	EHT.PushTS( "EHT.Handlers.PlayerActivated" )

	EHT.LastMouseClick = 0

	if EHT.Housing.GetHouseOwner() ~= "" and EHT.Housing.GetHouseId() ~= 0 then
		EHT.Biz.SetHouseInaccessibleFlag( EHT.Housing.GetHouseOwner(), EHT.Housing.GetHouseId(), false )
	end

	EHT.UI.RefreshEHTButton()
	EHT.UI.RefreshHousingHUDButton()
	EHT.UI.SetToolDialogWindowTitle()
	EHT.UI.SetCustomHouseName( nil )

	EHT.Effect.OnPortalJumpComplete()
	EHT.UsingPortal, EHT.JumpingToHouse, EHT.JumpToHouseId, EHT.JumpingToOwner = false, false, nil, nil
	EHT.SavedVars.SelectionLinkItems = false

	EHT.Data.ClearHouseLookupCache()
	EHT.Handlers.ResetFurnitureChangeSuppression()

	EHT.Housing.GetAllHouses( true )
	EHT.Util.RestoreAllSettings()
	EHT.Data.UpdateRecentlyVisited()
	EHT.Social:Refresh()
	EHT.Housing.RefreshFurnitureIds()
	EHT.Interop.DisableOopsI()
	EHT.CT.RegisterSlashCommands()

	local isOwner = IsOwnerOfCurrentHouse()
	local previousHouseId, previousHouseOwner = EHT.PreviousZoneHouseId, EHT.PreviousHouseOwner
	local houseId, houseOwner = EHT.Housing.GetHouseInfo()
	local zoneChanged = houseId ~= previousHouseId or houseOwner ~= previousHouseOwner

	if zoneChanged then
		EHT.EffectFurnitureStateManager:Reset()
		EHT.UnregisterTemporaryUpdateEvents()
		EHT.Effect:ResetDeferralQueues()
		EHT.Data.OnZoneChanged(houseId, houseOwner, previousHouseId, previousHouseOwner)
	end

	EHT.UI.UpdateUIMode( nil, nil ~= previousHouseId and zoneChanged )
	EHT.PreviousZoneHouseId, EHT.PreviousHouseOwner = houseId, houseOwner

	EHT.CurrentHousePopulation = GetCurrentHousePopulation() or 0
	EHT.TriggerPhrases = { }
	EHT.TriggerQueue = { }
	EHT.Data.RefreshTriggerStates()
	EHT.Handlers.SetTriggerCheck()
	EHT.Housing.OnWorldChange()
	EHT.Pointers.LockGuidelines( false )
	EHT.Pointers.OnWorldChange()
	EHT.World.OnWorldChange()
	EHT.PreviewScale:Reset()
	EHT.Effect:DeleteAll()
	EHT.UI.RefreshUI()
	EHT.UI.RefreshLockedIndicators()
	EHT.UI.RefreshAdjustGuidelinesDialog()
	EHT.UI.SetupHousingEditorUndoStack()
	EHT.UI.HideEHTEffectsButtonContextMenu()
	EHT.UI.HideInteractionPrompt()
	EHT.CT.OnPlayerActivated()

	if EHT.Interop.HasEHTSavedVarsReset() then
		EHT.UI.SetPersistentNotification( "CorruptSaveData", "Data Corrupt. Repair from Settings." )
	else
		EHT.UI.ClearPersistentNotification( "CorruptSaveData" )
	end

	zo_callLater( function()
		EHT.PushTS( "EHT.Housing.RefreshFurnitureCache()" )
		EHT.Housing.RefreshFurnitureCache()
		EHT.PopTS( "EHT.Housing.RefreshFurnitureCache()" )
	end, 1000 )

	EHT.EffectUI.PreloadAll()

	zo_callLater( function()
		EHT.UI.SetCustomHouseName()
	end, 3000 )

	zo_callLater( function()
		EHT.PushTS( "EHT.Effect:ProcessMailInbox()" )
		EHT.Effect:ProcessMailInbox()
		EHT.PopTS( "EHT.Effect:ProcessMailInbox()" )
	end, 9000 )

	if nil ~= houseId and 0 ~= houseId and ( houseId ~= previousHouseId or houseOwner ~= previousHouseOwner ) then
		if isOwner then
			if EHT.SavedVars.AutoBackup then
				zo_callLater( function()
					EHT.Biz.CreateBackup()
				end, 7000 )
			end
		end

		EHT.Biz.CreateTrigger()
	end

	zo_callLater( function()
		EHT.Handlers.RegisterChatFilter()
	end, 8000 )

	zo_callLater( function()
		EHT.PushTS( "EHT.Guilds:OnGuildDataLoaded()" )
		EHT.Guilds:OnGuildDataLoaded()
		EHT.PopTS( "EHT.Guilds:OnGuildDataLoaded()" )
	end, 5000 )

	EHT.EffectUI.CancelPreviewEffects( true )
	EHT.UI.RefreshEffectsPreviewState()

	EHT.ADDON_COMPOUND_VERSION = EHT.Util.ParseVersionString( EHT.ADDON_VERSION )

	EHT.UI.ShowCommunityAppReminder()

	EHT.PopTS( "EHT.Handlers.PlayerActivated" )
	EHT.DumpTS()
end

function EHT.Handlers.PlayerDeactivated()
	if EHT.SavedVars.AutoBackup then
		EHT.Biz.CreateBackup()
	end
end

function EHT.Handlers.OnPlayerDeactivated( event )
	EHT.Handlers.PlayerDeactivated()
end

function EHT.Handlers.LoggingOut()
	EHT.Handlers.PlayerDeactivated()

	if EHT.SavedVars.VolatileHouseHistory then
		if not EHT.Data.IsHouseListEmpty() then
			for _, house in pairs( EHT.Data.GetHouses() ) do
				if house.History then
					house.History = {}
					house.HistoryIndex = 0
				end
			end
		end
	end
end

function EHT.Handlers.OnLoggingOut( event )
	EHT.Handlers.LoggingOut()
end

function EHT.Handlers.OnFurnitureStateChanged( event, furnitureId, newStateIndex, oldStateIndex )
	local newState = EHT.Housing.GetFurnitureStateByStateIndex( furnitureId, newStateIndex )
	local oldState = EHT.Housing.GetFurnitureStateByStateIndex( furnitureId, oldStateIndex )

	EHT.Handlers.OnRecordingSceneFurnitureStateChanged( furnitureId, newState, oldState )
	EHT.EffectFurnitureStateManager:OnFurnitureStateChanged( furnitureId, newState, oldState )

	local triggers = EHT.Biz.MatchTriggersByFurnitureState( furnitureId, newState, oldState )
	if triggers and 0 ~= #triggers then
		EHT.Biz.QueueTriggerActions( triggers, EHT.CONST.TRIGGER_CONDITION.FURNITURE_STATE )
	end
end

function EHT.Handlers.OnFurnitureSelected( item )
	local _, group = EHT.Data.GetCurrentHouseRecords()

	local build = EHT.Data.GetBuild()
	if nil ~= build then build.SelectionChanged = true end

--	EHT.UI.QueueCheckForProtractedSelection()

	if nil ~= group then EHT.Biz.MeasureDimensions( group, nil, true ) end
end

function EHT.Handlers.OnFurnitureUnselected( item )
	local build = EHT.Data.GetBuild()
	if nil ~= build then build.SelectionChanged = true end

--	EHT.UI.QueueCheckForProtractedSelection()
end

function EHT.Handlers.OnRecordingSceneFurnitureStateChanged( id, newState, oldState )
	if nil ~= id and EHT.RecordingSceneFrames and nil ~= EHT.Data.GetSceneFurniture( id ) then EHT.Biz.InsertSceneFrame() end
end

function EHT.Handlers.OnFurnitureChanged( item, itemBefore, source )
	-- if EHT.Util.LoopCounter( "EHT.Handlers.OnFurnitureChanged" ) then return end
	if nil == item or nil == item.Id then return end

	local furniture = nil
	local processName = EHT.Biz.GetProcess()

	if EHT.Housing.IsEffectId( item.Id ) and ( not item.SizeX or ( itemBefore and not itemBefore.SizeX ) ) then
		local effect = EHT.Data.GetEffectRecordById( item.Id )
		if effect then
			item.SizeX, item.SizeY, item.SizeZ, item.Color, item.Color, item.Alpha = effect.SizeX, effect.SizeY, effect.SizeZ, effect.Color, effect.Alpha
			if itemBefore then
				itemBefore.SizeX, itemBefore.SizeY, itemBefore.SizeZ, itemBefore.Color, itemBefore.Color, item.Alpha = effect.SizeX, effect.SizeY, effect.SizeZ, effect.Color, effect.Alpha
			end
		end
	end

	if EHT.RecordingSceneFrames then
		if source ~= "SnapFurniture" and "LinkItems" ~= source and "PlayScene" ~= source and processName ~= EHT.PROCESS_NAME.ADJUST_SELECTED_GROUP and processName ~= EHT.PROCESS_NAME.BUILD then
			furniture = EHT.Data.GetSceneFurniture( item.Id )
			if nil ~= furniture then
				EHT.Biz.InsertSceneFrame()
			end
		end
	end

	if source ~= "GroupEdit" then
		furniture = EHT.Data.GetGroupFurniture( item.Id )
		if nil ~= furniture then
			-- Furniture
			furniture.X = item.X
			furniture.Y = item.Y
			furniture.Z = item.Z
			furniture.Pitch = item.Pitch
			furniture.Yaw = item.Yaw
			furniture.Roll = item.Roll
			
			-- Path Node (Additional)
			furniture.Speed = item.Speed
			furniture.DelayTime = item.DelayTime

			-- Effect (Additional)
			furniture.EffectTypeId = item.EffectTypeId
			furniture.SizeX = item.SizeX
			furniture.SizeY = item.SizeY
			furniture.SizeZ = item.SizeZ
			furniture.Color = item.Color
			furniture.Alpha = item.Alpha
		end
	end

	if source ~= "PositionDialog" and nil ~= EHT.PositionItemId then
		if "string" == type( item.Id ) then
			if string.fromId64( EHT.PositionItemId ) == item.Id then EHT.UI.RefreshPositionDialog( item ) end
		else
			if string.fromId64( EHT.PositionItemId ) == string.fromId64( item.Id ) then EHT.UI.RefreshPositionDialog( item ) end
		end
	end

	if nil ~= itemBefore and source ~= "SnapFurniture" and source ~= "LinkItems" and processName ~= EHT.PROCESS_NAME.UNDO and processName ~= EHT.PROCESS_NAME.REDO then
		EHT.CT.OnFurnitureChanged( item, itemBefore )
		EHT.UI.RefreshHistory()
	end
end

function EHT.Handlers.OnFurnitureEditStarted( item )

end

function EHT.Handlers.OnFurnitureEditCommitted( item, itemBefore, snapped )
	-- if EHT.Util.LoopCounter( "EHT.Handlers.OnFurnitureEditCommitted" ) then return end
	if not EHT.Biz.IsProcessRunning( true ) then
		if not snapped and item then
			if item.Id == EHT.ManuallyEditingId then
				local horiz, vert = EHT.Biz.AreGuidelinesSnapped()

				if horiz or vert then
					EHT.ManuallyEditingId = nil
					item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = EHT.Biz.SnapToGuidelines( item.Id, itemBefore )
					--return
				end
			end

			EHT.SnappedItemId = nil
		end

		local linkItems = nil
		--EHT.Housing.AutoLevelInteractable( item )

		if EHT.SavedVars.SelectionLinkItems then
			local deltaX, deltaY, deltaZ = item.X - itemBefore.X, item.Y - itemBefore.Y, item.Z - itemBefore.Z
			local deltaPitch, deltaYaw, deltaRoll = item.Pitch - itemBefore.Pitch, item.Yaw - itemBefore.Yaw, item.Roll - itemBefore.Roll

			if 0 ~= deltaX or 0 ~= deltaY or 0 ~= deltaZ or 0 ~= deltaPitch or 0 ~= deltaYaw or 0 ~= deltaRoll then
				linkItems = EHT.Data.GetGroupFurniture( itemBefore.Id )
			end
		end

		if nil == linkItems then
			EHT.Handlers.OnFurnitureChanged( item, itemBefore )
		else
			EHT.Handlers.OnFurnitureChanged( item, itemBefore, "LinkItems" )

			local _, group = EHT.Data.GetCurrentHouse()
			if nil == group or 1 >= #group or ( nil ~= EHT.UI.ToolDialog and not EHT.UI.ToolDialog.Window:IsHidden() ) then
				-- Revert the item's state to the "before" state because the item
				-- will be updated in the upcoming Link Items operation.

				linkItems.X = itemBefore.X
				linkItems.Y = itemBefore.Y
				linkItems.Z = itemBefore.Z
				linkItems.Pitch = itemBefore.Pitch
				linkItems.Yaw = itemBefore.Yaw
				linkItems.Roll = itemBefore.Roll
				linkItems.Speed = itemBefore.Speed
				linkItems.DelayTime = itemBefore.DelayTime
				EHT.Biz.AdjustRelativeFurniture( item, itemBefore, linkItems.Id )
			else
				local preservedItem, preservedItemBefore = EHT.Util.CloneTable( item ), EHT.Util.CloneTable( itemBefore )

				EHT.UI.ShowConfirmationDialog( EHT.ADDON_TITLE, "The item you just edited is part of your current selection. Do you want to move the entire group with this item?",
					function()
						linkItems.X = preservedItemBefore.X
						linkItems.Y = preservedItemBefore.Y
						linkItems.Z = preservedItemBefore.Z
						linkItems.Pitch = preservedItemBefore.Pitch
						linkItems.Yaw = preservedItemBefore.Yaw
						linkItems.Roll = preservedItemBefore.Roll
						linkItems.Speed = itemBefore.Speed
						linkItems.DelayTime = itemBefore.DelayTime
						EHT.Biz.AdjustRelativeFurniture( preservedItem, preservedItemBefore, linkItems.Id )
					end, nil, false )
			end
		end
	end

	EHT.UI.RefreshHistory()
end

function EHT.Handlers.OnHousingEditorModeChanged( event, oldMode, newMode )
	--EVENT_MANAGER:UnregisterForUpdate( "EHTEditorPrecisionEdit" )
	--EHT.UI.EndSteadyCam( "mode" )
	EHT.Pointers.ClearPointers()

	local furnitureId = EHT.Housing.GetSelectedFurnitureAndNode()
	local manualEditId = EHT.ManuallyEditingId

	if oldMode ~= HOUSING_EDITOR_MODE_BROWSE then
		EHT.EffectUI.ClearTargetFurniture( "Waypoint" )
	end
	
	if oldMode == HOUSING_EDITOR_MODE_BROWSE then
		EHT.EffectUI.ClearTargetFurniture( "Breadcrumb" )
	end

	if newMode == HOUSING_EDITOR_MODE_PLACEMENT or newMode == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
		EHT.ManuallyEditingId = furnitureId or EHT.ManuallyEditingId
		manualEditId = EHT.ManuallyEditingId
	end

	if EHT.Effect then
		if newMode == HOUSING_EDITOR_MODE_SELECTION then
			EHT.Effect.RegisterFlashReticleTargetEffect()
		else
			EHT.Effect.UnregisterFlashReticleTargetEffect()
		end
	end

	-- Reroute to the Choose An Item workflow.
	if EHT.ChooseItemCallback then
		if newMode == HOUSING_EDITOR_MODE_PLACEMENT then
			EHT.UI.ChooseAnItemCallback()
			return
		end

		if newMode == HOUSING_EDITOR_MODE_DISABLED then
			EHT.ChooseItemCallback = nil
			EHT.UI.ChooseAnItemFailedCallback()
			return
		end
	else
		EHT.UI.HideInteractionPrompt()
	end

	-- Cancel any placement of a Locked Item.
	if nil ~= furnitureId and EHT.Biz.CheckItemLock( furnitureId ) then
		HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
		return
	end

	if newMode == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
		local selectedFurnitureId = EHT.Housing.GetSelectedFurnitureAndNode()
		if selectedFurnitureId and EHT.Housing.IsFurniturePathNodeId( selectedFurnitureId ) then
			if EHT.Biz.CheckItemLock( selectedFurnitureId ) then
				HousingEditorRequestModeChange( HOUSING_EDITOR_MODE_SELECTION )
				return
			end
		end
	end

	if newMode == HOUSING_EDITOR_MODE_SELECTION then
		EHT.Housing.RefreshFurnitureCache()
	end

	EHT.World:ResetReticleCheck()

	if EHT.GetSetting( "ShowGroupSelectReticleReminder" ) then
		if newMode == HOUSING_EDITOR_MODE_SELECTION and ( not EHT.GroupSelectHintExpires or EHT.GroupSelectHintExpires > GetFrameTimeMilliseconds() ) then
			if not EHT.ChooseItemCallback then
				if not EHT.GroupSelectHintExpires then
					EHT.GroupSelectHintExpires = GetFrameTimeMilliseconds() + 1000
				end

				local label = "Select / Deselect"
				EHT.UI.ShowInteractionPrompt( "EHT_SELECT_DESELECT", label, EHT.UI.GroupUngroupFurniture )

				zo_callLater( function()
					if label == EHT.UI.GetInteractionPromptLabel() then
						EHT.UI.HideInteractionPrompt()
					end
				end, 2000 )
			end
		elseif newMode == HOUSING_EDITOR_MODE_PLACEMENT and ( not EHT.OrganizeHintExpires or EHT.OrganizeHintExpires > GetFrameTimeMilliseconds() ) then
			if not EHT.ChooseItemCallback then
				if not EHT.OrganizeHintExpires then
					EHT.OrganizeHintExpires = GetFrameTimeMilliseconds() + 1000
				end

				local label = "(Press & Hold) Organize"
				EHT.UI.ShowInteractionPrompt( "EHT_QUICK_ACTIONS", label, nil )

				zo_callLater( function()
					if label == EHT.UI.GetInteractionPromptLabel() then
						EHT.UI.HideInteractionPrompt()
					end
				end, 6000 )
			end
		end
	end

	-- Show/Hide 3D elements.
	local hideIndicators = not ( newMode == HOUSING_EDITOR_MODE_SELECTION or newMode == HOUSING_EDITOR_MODE_PLACEMENT )
	EHT.Pointers.SetLockedHidden( hideIndicators )
	EHT.Pointers.SetGuidelinesHidden( hideIndicators )
	EHT.Pointers.SetIndicatorsHidden( hideIndicators )
	if hideIndicators then EHT.UI.HideAdjustGuidelinesDialog() end
	EHT.EffectUI.RefreshEditorButtons()
	EHT.Pointers.ShowGuidelinesArrows( newMode == HOUSING_EDITOR_MODE_SELECTION )

	hideIndicators = not ( newMode == HOUSING_EDITOR_MODE_SELECTION )
	if not hideIndicators then
		local _, group = EHT.Data.GetCurrentHouseRecords()
		if nil == group or 0 >= #group then hideIndicators = true end
	end

	EHT.Pointers.SetGroupedHidden( hideIndicators )
	EHT.Pointers.SetGroupOutlineHidden( hideIndicators )

	-- Show/Hide the Heads Up Display.
	if newMode == HOUSING_EDITOR_MODE_PLACEMENT then
		EHT.UI.ShowItemInfoDialog()
	else
		EHT.UI.HideItemInfoDialog()
	end

	EHT.UI.UpdateUIMode()

	if EHT.Biz.IsUninterruptableProcessRunning( true ) then
		return
	end

	EHT.UI.UpdateKeybindStrip( newMode )

	if newMode == HOUSING_EDITOR_MODE_DISABLED or ( newMode == HOUSING_EDITOR_MODE_SELECTION and oldMode == HOUSING_EDITOR_MODE_PLACEMENT ) then
		if not EHT.Biz.IsProcessRunning( true ) then
			EHT.Biz.RefreshGroupState()
		end
	end
end

function EHT.Handlers.OnHousePopulationChanged( _, population )
	if population then
		EHT.UI.OnHousePopulationChanged( population )
		EHT.Biz.OnHousePopulationChanged( population )
	end
end

function EHT.Handlers.OnFurnitureMoved( _, furnitureId, collectibleId )
	EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.MOVE_OP )

	if not furnitureId and collectibleId then
		furnitureId = GetFurnitureIdFromCollectibleId( collectibleId )
	end

	if furnitureId == EHT.PositionItemId then
		EHT.UI.RefreshPositionDialog()
	end

	if IsChangeSuppressed( furnitureId ) then
		EHT.ManuallyEditingId = nil
		return
	end

	if EHT.ManuallyEditingId == furnitureId then
		-- Before, After
		local b, a = EHT.Housing.GetCachedFurniture( furnitureId ), EHT.Housing.CreateFurnitureCacheObject( furnitureId )
		local changed = false

		if a and b and 0 ~= a[1] and 0 ~= a[2] and 0 ~= a[3] then
			for i = 1, #a do
				if a[i] ~= b[i] then
					changed = true
					break
				end
			end
		end

		if changed then
			local after = { Id = furnitureId, X=a[1], Y=a[2], Z=a[3], Pitch=a[4], Yaw=a[5], Roll=a[6], Link=a[7], }
			local before = { Id = furnitureId, X=b[1], Y=b[2], Z=b[3], Pitch=b[4], Yaw=b[5], Roll=b[6], Link=b[7], }

			EHT.Handlers.OnFurnitureEditCommitted( after, before )
		end
	end

	EHT.ManuallyEditingId = nil
	local processName = EHT.Biz.GetProcess()

	if processName == EHT.PROCESS_NAME.SUMMON_KIOSK then
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.SummonKioskProcess, 150 )
	elseif processName == EHT.PROCESS_NAME.DISMISS_KIOSK then
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.DismissKioskProcess, 150 )
	end

	EHT.UI.QueueRefreshGroupedIndicators()
	EHT.UI.QueueRefreshGroupOutlineIndicators()
	EHT.UI.QueueRefreshLockedIndicators()

	if EHT.CONST.TOOL_TABS.TRIGGERS == EHT.UI.GetCurrentToolTab() then
		if EHT.Housing.AreFurnitureIdsEqual( furnitureId, EHT.UI.ToolDialog.TriggerConditionItemFurnitureId ) then
			EHT.UI.ShowTriggerPointers()
		end
	end
end

function EHT.Handlers.OnFurniturePlaced(_, furnitureId, collectibleId, suppressChangeTracking)
	EHT.Biz.DecrementPendingFurnitureOperations(EHT.CONST.PLACE_OP)
	EHT.ManuallyEditingId = nil
	EHT.UI.SetToolDialogWindowTitle()

	if nil ~= furnitureId and 0 ~= furnitureId then
		local isEffectId = EHT.Housing.IsEffectId(furnitureId)
		EHT.Housing.RegisterFurnitureId(furnitureId)
		EHT.EffectUI.RefreshPOIEffects()

		if EHT.SelectNextPlacedItem then
			EHT.SelectNextPlacedItem = false
			EHT.Biz.GroupUngroupFurnitureById(furnitureId)
		end

		if not EHT.Biz.IsProcessRunning(true) then
			if not suppressChangeTracking then EHT.CT.OnFurniturePlaced(furnitureId, collectibleId) end
		else
			local processName = EHT.Biz.GetProcess()

			if processName == EHT.PROCESS_NAME.SUMMON_KIOSK then

				EHT.Biz.ScheduleProcessActivity( EHT.Biz.SummonKioskProcess, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_PLACE_DELAY )

			elseif processName == EHT.PROCESS_NAME.UNDO then

				EHT.CT.OnFurniturePlaced( furnitureId, collectibleId, suppressChangeTracking )
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessCallback, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_PLACE_DELAY )

			elseif processName == EHT.PROCESS_NAME.REDO then

				EHT.CT.OnFurniturePlaced( furnitureId, collectibleId, suppressChangeTracking )
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessCallback, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_PLACE_DELAY )

			elseif processName == EHT.PROCESS_NAME.RESET_FURNITURE then

				EHT.CT.OnFurniturePlaced( furnitureId, collectibleId, suppressChangeTracking )
				EHT.Biz.ScheduleProcessActivity( EHT.Biz.ResetFurnitureProcess, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_PLACE_DELAY )

			elseif processName == EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_INVENTORY then

				local house, group = EHT.Data.GetCurrentHouse( true )
				if nil ~= group then
					local furniture = EHT.Data.AddGroupFurniture( furnitureId, group )
					EHT.ProcessData.Pasted = EHT.ProcessData.Pasted + 1

					if nil ~= furniture then
						local historyBatch = EHT.ProcessData.History.Batch
						table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.PLACE, nil, furniture ) )
					end

					EHT.Biz.ScheduleProcessActivity( EHT.Biz.PasteClipboardFromInventoryProcess, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_PLACE_DELAY )
				end

			elseif processName == EHT.PROCESS_NAME.ADD_FROM_INVENTORY then

				zo_callLater( function() EHT.Biz.AddItemsFromInventoryCallback( furnitureId ) end, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_PLACE_DELAY )
				return

			elseif processName == EHT.PROCESS_NAME.REPLACE_MISSING_ITEMS then

				if not isEffectId then
					local data = EHT.ProcessData
					local index, group = data.Index, data.Group
					local house = EHT.Data.GetCurrentHouse()

					if nil == house or nil == group or nil == index or index > #group then
						EHT.Biz.EndProcess()
					else
						local newId = string.fromId64( furnitureId )
						local validIds = data.ValidIds
						if not validIds then validIds = { } data.ValidIds = validIds end

						validIds[ newId ] = true
						EHT.Biz.SubstituteFurnitureId( house, string.fromId64( group[ index ].Id ), newId )
						group[ index ].Id = newId
						data.Index = data.Index + 1
						data.Replaced = data.Replaced + 1

						local x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( furnitureId )
						table.insert( EHT.ProcessData.HistoryPlacements.Batch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.PLACE, nil, { Id = newId, X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll } ) )
						EHT.Biz.ScheduleProcessActivity( EHT.Biz.ReplaceMissingItemsProcess, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_PLACE_DELAY )
					end
				end

			end

		end

	end

	EHT.UI.RefreshHistory()
end

function EHT.Handlers.OnFurnitureRemoved(event, furnitureId, collectibleId, furnitureRecord)
	EHT.Biz.DecrementPendingFurnitureOperations(EHT.CONST.REMOVE_OP)
	EHT.ManuallyEditingId = nil

	local cacheItem = EHT.Housing.GetCachedFurniture(furnitureId)
	local isEffectId = EHT.Housing.IsEffectId(furnitureId)

	EHT.UI.SetToolDialogWindowTitle()

	if nil ~= furnitureId and 0 ~= furnitureId then
		EHT.Housing.UnregisterFurnitureId(furnitureId)
		EHT.Housing.UnregisterAllFurniturePathNodes(furnitureId)
		EHT.EffectFurnitureStateManager:UnregisterHandlers(furnitureId)

		if EHT.Data.IsLocked(furnitureId) then
			EHT.Data.SetLock(furnitureId, false)
			EHT.UI.QueueRefreshLockedIndicators()
		end

		if furnitureId == EHT.PositionItemId then EHT.UI.HidePositionDialog() end

		if EHT.Process == EHT.PROCESS_NAME.UNDO then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessCallback, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_REMOVE_DELAY )
			return
		end

		if EHT.Process == EHT.PROCESS_NAME.REDO then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessCallback, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_REMOVE_DELAY )
			return
		end

		if EHT.Process == EHT.PROCESS_NAME.RESET_FURNITURE then
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.ResetFurnitureCallback, isEffectId and EHT.CONST.FX_REQUEST_DELAY or EHT.CONST.HOUSING_REMOVE_DELAY )
			return
		end

		if not EHT.Biz.IsProcessRunning( true ) then
			if not furnitureRecord then
				if cacheItem then
					local furniture = { Id = furnitureId, X = cacheItem[1], Y = cacheItem[2], Z = cacheItem[3], Pitch = cacheItem[4], Yaw = cacheItem[5], Roll = cacheItem[6], Link = cacheItem[7] }
					EHT.CT.OnFurnitureRemoved( furniture )
				end
			else
				EHT.CT.OnFurnitureRemoved( furnitureRecord )
			end
		end

		local house, group = EHT.Data.GetCurrentHouse( true )
		if nil ~= group then
			EHT.Data.RemoveGroupFurniturePathNodes( furnitureId, group )
			EHT.Data.RemoveGroupFurniture( furnitureId, group )
			EHT.UI.QueueRefreshSelection()
		end
	end

	EHT.UI.RefreshHistory()
end

function EHT.Handlers.OnFurniturePathNodeMoved( event, furnitureId, pathIndex )
	local id = EHT.Housing.GetFurniturePathNodeId( furnitureId, pathIndex )
	EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.MOVE_PATH_NODE_OP )
	EHT.Housing.RegisterAllFurniturePathNodes( furnitureId )

	--if EHT.ManuallyEditingId == id then
	local SUPPRESS_MESSAGE = true
	if not EHT.Biz.IsProcessRunning( SUPPRESS_MESSAGE ) then
		-- Before, After
		local b, a = EHT.Housing.GetCachedFurniture( id ), EHT.Housing.CreateFurnitureCacheObject( id )
		local changed = false

		if a and b then
			for i = 1, #a do
				if a[i] ~= b[i] then
					changed = true
					break
				end
			end
		end

		if changed then
			local after = { Id = id, X=a[1], Y=a[2], Z=a[3], Pitch=a[4], Yaw=a[5], Roll=a[6], Link=a[7], Speed=a[8], DelayTime=a[9], }
			local before = { Id = id, X=b[1], Y=b[2], Z=b[3], Pitch=b[4], Yaw=b[5], Roll=b[6], Link=b[7], Speed=b[8], DelayTime=b[9], }

			EHT.Handlers.OnFurnitureEditCommitted( after, before )
		end
	end

	EHT.Housing.RefreshCachedFurniture( id )
	EHT.ManuallyEditingId = nil

	EHT.UI.QueueRefreshGroupedIndicators()
	EHT.UI.QueueRefreshGroupOutlineIndicators()
	EHT.UI.QueueRefreshLockedIndicators()
end

function EHT.Handlers.OnFurniturePathNodeAdded( event, furnitureId, pathIndex )
	local pathNodeId = EHT.Housing.GetFurniturePathNodeId( furnitureId, pathIndex )
	EHT.ManuallyEditingId = nil

	EHT.Housing.RegisterAllFurniturePathNodes( furnitureId )
	EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.PLACE_PATH_NODE_OP )

	if EHT.Biz.IsProcessRunning( true ) then
		local processName = EHT.Biz.GetProcess()

		if processName == EHT.PROCESS_NAME.UNDO then
			EHT.CT.OnFurniturePlaced( pathNodeId )
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessCallback, EHT.CONST.HOUSING_PLACE_DELAY )
		elseif processName == EHT.PROCESS_NAME.REDO then
			EHT.CT.OnFurniturePlaced( pathNodeId )
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessCallback, EHT.CONST.HOUSING_PLACE_DELAY )
		elseif processName == EHT.PROCESS_NAME.RESET_FURNITURE then
			EHT.CT.OnFurniturePlaced( pathNodeId )
			EHT.Biz.ScheduleProcessActivity( EHT.Biz.ResetFurnitureProcess, EHT.CONST.HOUSING_PLACE_DELAY )
		elseif processName == EHT.PROCESS_NAME.PASTE_CLIPBOARD_FROM_INVENTORY then
			local house, group = EHT.Data.GetCurrentHouse( true )
			if nil ~= group then
				local furniture = EHT.Data.AddGroupFurniture( pathNodeId, group )
				EHT.ProcessData.Pasted = EHT.ProcessData.Pasted + 1

				if nil ~= furniture then
					local historyBatch = EHT.ProcessData.History.Batch
					table.insert( historyBatch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.PLACE, nil, furniture ) )
				end
			end
		end
	end
end

function EHT.Handlers.OnFurniturePathNodeRemoved( event, furnitureId, pathIndex )
	local pathNodeId = EHT.Housing.GetFurniturePathNodeId( furnitureId, pathIndex )
	local cacheItem = EHT.Housing.GetCachedFurniture( pathNodeId )
	EHT.ManuallyEditingId = nil

	EHT.Housing.RegisterAllFurniturePathNodes( furnitureId )
	EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.REMOVE_PATH_NODE_OP )

	if EHT.Data.IsLocked( pathNodeId ) then
		EHT.Data.SetLock( pathNodeId, false )
		EHT.UI.QueueRefreshLockedIndicators()
	end

	if pathNodeId == EHT.PositionItemId then
		EHT.UI.HidePositionDialog()
	end

	if EHT.Process == EHT.PROCESS_NAME.UNDO then
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessCallback, EHT.CONST.HOUSING_REMOVE_DELAY )
		return
	end

	if EHT.Process == EHT.PROCESS_NAME.REDO then
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessCallback, EHT.CONST.HOUSING_REMOVE_DELAY )
		return
	end

	if EHT.Process == EHT.PROCESS_NAME.RESET_FURNITURE then
		EHT.Biz.ScheduleProcessActivity( EHT.Biz.ResetFurnitureCallback, EHT.CONST.HOUSING_REMOVE_DELAY )
		return
	end

	if cacheItem and not EHT.Biz.IsProcessRunning( true ) then
		local item =
		{
			Id = pathNodeId,
			X = cacheItem[1],
			Y = cacheItem[2],
			Z = cacheItem[3],
			Pitch = cacheItem[4],
			Yaw = cacheItem[5],
			Roll = cacheItem[6],
			Link = cacheItem[7],
			Speed = cacheItem[8],
			DelayTime = cacheItem[9],
		}
		EHT.CT.OnFurnitureRemoved( item )
	end

	local house, group = EHT.Data.GetCurrentHouse( true )
	if nil ~= group then
		EHT.Data.RemoveGroupFurniture( pathNodeId, group )
		EHT.Data.ShiftGroupFurniturePathNodes( furnitureId, pathIndex, -1, group )
		EHT.UI.QueueRefreshSelection()
	end

	EHT.UI.RefreshHistory()
end

function EHT.Handlers.OnFurniturePathDataChanged( event, furnitureId )
	EHT.ManuallyEditingId = nil
	EHT.Data.SetGroupFurniturePathInfo( furnitureId )
end

function EHT.Handlers.OnFurniturePathNodesRestored( event, furnitureId )
	EHT.ManuallyEditingId = nil
	EHT.Housing.RegisterAllFurniturePathNodes( furnitureId )
end

function EHT.Handlers.OnQuickslotActionReleased(button)
	if 0 == GetCurrentZoneHouseId() then
		return false
	end

	local slotIndex = button:GetSlot()
	local hotbarCategory = button:GetHotbarCategory()
	local link = GetSlotItemLink( slotIndex, hotbarCategory )
	if nil ~= link and "" ~= link then
		local ui = EHT.UI.ToolDialog
		if nil ~= ui then
			if not ui.Conditions[1].TriggerConditionQuickslotContainer:IsHidden() then
				ui.Conditions[1].TriggerConditionQuickslotLink:SetText(link)
			elseif not ui.Conditions[2].TriggerConditionQuickslotContainer:IsHidden() then
				ui.Conditions[2].TriggerConditionQuickslotLink:SetText(link)
			end
		end

		EHT.Biz.ProcessTriggersByQuickslotItem(link)

		if EHT.Biz.SummonDismissAssistant(link) then
			return true
		end
	end

	return false
end

function EHT.Handlers.OnChatMessage( evt, channel, from, text, isCustServ, fromDN )
	-- Process any messages containing Trigger key phrases.
	-- This event does NOT intercept messages; instead, it responds with Trigger actions in addition to the standard chat display functionality.
	
	if not (text ~= nil and text ~= "" and EHT.TriggerPhrases ~= nil and EHT.Biz and not EHT.Biz.AreTriggersDisabled() and EHT.CONST ~= nil and EHT.CONST.TRIGGER_CONDITION ~= nil) then
		return
	end

	if channel == CHAT_CHANNEL_SAY or channel == CHAT_CHANNEL_PARTY or channel == CHAT_CHANNEL_WHISPER or channel == CHAT_CHANNEL_WHISPER_SENT or channel == CHAT_CHANNEL_ZONE or channel == CHAT_CHANNEL_YELL then
		local triggers = EHT.Biz.MatchTriggersByPhrase( text )
		if triggers then
			EHT.Biz.QueueTriggerActions( triggers, EHT.CONST.TRIGGER_CONDITION.PHRASE )
		end
	end
end

function EHT.Handlers.OnFilterChatEvent( channel, from, text, isCustServ, fromDN )
	-- Intercept, process and revise all "EHTfx"-prefixed data messages received via any chat channel.
	-- Return all other messages using standard chat formatting.

	if channel then
		local channelInfo = ZO_ChatSystem_GetChannelInfo()
		local info = channelInfo[ channel ]

		if nil ~= fromDN and "" ~= fromDN then
			if string.sub( text or "", 1, #EHT.CHATCAST_PREFIX ) == EHT.CHATCAST_PREFIX then
				if channel == CHAT_CHANNEL_WHISPER_SENT then fromDN = GetDisplayName() end
				EHT.Effect:ProcessInboundChatcast( fromDN, text, "Chat" )
				return "", info.saveTarget
			end
		end
	end

	-- Otherwise, display the standard chat message formatting.
	return nil, nil
end

function EHT.Handlers.OnChatFilter( event, ... )
	local message, target

	if event == EVENT_CHAT_MESSAGE_CHANNEL then
		message, target = EHT.Handlers.OnFilterChatEvent( ... )
	else
		message, target = EHT.Handlers.OnFilterChatEvent( event, ... )
	end

	if message then
		return message, target
	end

	if originalChatMessageHandler then
		if event == EVENT_CHAT_MESSAGE_CHANNEL then
			return originalChatMessageHandler( ... )
		else
			return originalChatMessageHandler( event, ... )
		end
	end
end

function EHT.Handlers.RegisterChatFilter()
	EVENT_MANAGER:RegisterForEvent( "EHT.Handlers.OnChatFilter" .. EVENT_CHAT_MESSAGE_CHANNEL, EVENT_CHAT_MESSAGE_CHANNEL, EHT.Handlers.OnChatFilter )
end

function EHT.Handlers.OnInventoryContextMenu( inventorySlot )
	if inventorySlot:GetOwningWindow() == ZO_TradingHouse then return end
	if 0 >= GetCurrentZoneHouseId() or not IsOwnerOfCurrentHouse() then return end

	local bag, slotIndex = ZO_Inventory_GetBagAndIndex( inventorySlot )
	if not EHT.Biz.IsPlaceableBag( bag ) then return end

	local link = GetItemLink( bag, slotIndex )
	if not IsItemLinkPlaceableFurniture( link ) then return end

	zo_callLater( function() EHT.Biz.AddInventoryContextMenuCallback( bag, slotIndex, link ) end, 10 )
end

function EHT.Handlers.OnSceneStateShown( sceneManager, scene, state )
	if scene then
		if not SCENE_MANAGER then
			return false
		end

		local scene = SCENE_MANAGER:GetCurrentScene()
		if not scene or not scene.GetName then
			return
		end

		EHT.UI.UpdateUIMode( scene:GetName() )
	end

	return false
end

function EHT.Handlers.OnTriggerQueue()
	if not EHT.Biz.AreTriggersDisabled() then
		EHT.Biz.TriggerQueueUpdate()
	end
end

function EHT.Handlers.OnTriggerCheck()
	if EHT.Biz.AreTriggersDisabled() then
		return
	end

	do
		local triggers = EHT.Data.GetTriggers()
		if nil == triggers or 0 == #triggers then
			return
		end
	end

	do
		local isDayTime = EHT.Util.IsDayTime()
		local triggers = EHT.Biz.MatchTriggersByTimeOfDay( isDayTime )
		if triggers and 0 ~= #triggers then
			EHT.Biz.QueueTriggerActions( triggers, EHT.CONST.TRIGGER_CONDITION.DAY_TIME )
		end
	end

	-- Check combat state.

	local combatState = IsUnitInCombat( "player" )
	if nil == EHT.CombatState then EHT.CombatState = combatState end

	if combatState ~= EHT.CombatState then
		local triggers = EHT.Biz.MatchTriggersByCombatState( combatState )
		if triggers and 0 ~= #triggers then
			EHT.Biz.QueueTriggerActions( triggers, combatState and EHT.CONST.TRIGGER_CONDITION.ENTER_COMBAT or EHT.CONST.TRIGGER_CONDITION.LEAVE_COMBAT )
		end
		EHT.CombatState = combatState
	end

	-- Queue Position-based Triggers whose conditions are currently met.

	do
		local triggers = EHT.Biz.MatchTriggersByPosition()
		if triggers and 0 ~= #triggers then
			EHT.Biz.QueueTriggerActions( triggers, EHT.CONST.TRIGGER_CONDITION.ENTER_POSITION )
		end
	end
end

function EHT.Handlers.SetTriggerCheck( enabled )
	EVENT_MANAGER:UnregisterForUpdate( "SetTriggerCheck" )
	EVENT_MANAGER:UnregisterForUpdate( EHT.TRIGGER_CHECK_ID )
	EVENT_MANAGER:UnregisterForUpdate( EHT.TRIGGER_QUEUE_ID )

	if nil == enabled then
		local houseId = GetCurrentZoneHouseId()
		enabled = nil ~= houseId and 0 < houseId --and IsOwnerOfCurrentHouse()
	end

	if enabled then
		local interval = EHT.TRIGGER_CHECK_INTERVAL
		local triggers = EHT.Data.GetTriggers()
		local triggerCount = 0

		if nil ~= triggers then triggerCount = #triggers end
		interval = interval + ( triggerCount * EHT.TRIGGER_CHECK_INTERVAL_INCREASE_PER_TRIGGER )

		EVENT_MANAGER:RegisterForUpdate( EHT.TRIGGER_CHECK_ID, interval, EHT.Handlers.OnTriggerCheck )
		EVENT_MANAGER:RegisterForUpdate( EHT.TRIGGER_QUEUE_ID, interval, EHT.Handlers.OnTriggerQueue )
	end
end

function EHT.Handlers.OnClientInteractResult( event, result, targetName )
	if result ~= CLIENT_INTERACT_RESULT_SUCCESS or nil == targetName or "" == targetName then return end
	targetName = ZO_StripGrammarMarkupFromCharacterName( targetName )

	if not EHT.Biz.AreTriggersDisabled() then
		local triggers = EHT.Biz.MatchTriggersByInteractTarget( targetName )

		if triggers and 0 < #triggers then
			EHT.Biz.QueueTriggerActions( triggers, EHT.CONST.TRIGGER_CONDITION.INTERACT_TARGET )
		end
	end

	if not EHT.UI or not EHT.UI.ToolDialog or "table" ~= type( EHT.UI.ToolDialog.Conditions ) or 2 > #EHT.UI.ToolDialog.Conditions then return end

	local ui = EHT.UI.ToolDialog
	if not ui.Conditions[1].TriggerConditionInteractContainer:IsHidden() then
		ui.Conditions[1].TriggerConditionInteractTarget:SetText( targetName )
	elseif not ui.Conditions[2].TriggerConditionInteractContainer:IsHidden() then
		ui.Conditions[2].TriggerConditionInteractTarget:SetText( targetName )
	end
end

function EHT.Handlers.OnPlayEmoteByIndex( index )
	if EHT.Biz.AreTriggersDisabled() then return end

	if nil == index then return end

	local slashName = GetEmoteSlashNameByIndex( index )
	if nil == slashName then return end

	local triggers = EHT.Biz.MatchTriggersByEmote( slashName )
	if nil ~= triggers and 0 < #triggers then 
		EHT.Biz.QueueTriggerActions( triggers, EHT.CONST.TRIGGER_CONDITION.EMOTE )
	end
end

function EHT.Handlers.OnPlaySound( soundName )
	if nil ~= soundName and "Map_Ping" == string.sub( soundName, 1, 8 ) and nil ~= EHT.MuteMapPingSoundFrameTime then
		if GetFrameTimeMilliseconds() > ( EHT.MuteMapPingSoundFrameTime + 1000 ) then
			EHT.MuteMapPingSoundFrameTime = nil
		else
			return true
		end
	end
end

function EHT.Handlers.OnCrouchResetting( unit )

end

function EHT.Handlers.OnStealthStateChanged( event, unit, newState )
	if nil == unit or "" == unit or string.find( unit, "reticle" ) or GetGroupUnitTagByIndex( GetGroupIndexByUnitTag( "player" ) ) == unit then return end

	local states = EHT.StealthStates	if nil == states then states = { } EHT.StealthStates = states end
	local resets = EHT.CrouchResets		if nil == resets then resets = { } EHT.CrouchResets = resets end

	local state = states[ unit ] or STEALTH_STATE_NONE
	local reset = resets[ unit ]

	if nil == reset then reset = { LastReset = 0, Resets = 0 } resets[ unit ] = reset end

	local t = GetGameTimeMilliseconds()

	if newState == STEALTH_STATE_NONE and ( state == STEALTH_STATE_HIDDEN or state == STEALTH_STATE_HIDDEN_ALMOST_DETECTED or state == STEALTH_STATE_HIDING ) then
		if ( t - reset.LastReset ) > 1000 then
			reset.Resets = 1
		else
			reset.Resets = reset.Resets + 1

			if reset.Resets >= 3 then
				reset.Resets = 0
				EHT.Handlers.OnCrouchResetting( unit )
			end
		end

		reset.LastReset = t
	end

	states[ unit ] = newState
end

function EHT.Handlers.OnWorldMapHouseRowClicked( control, button, upInside )
	if EHT.SavedVars.EnableHouseMapJumping and nil ~= control and button == MOUSE_BUTTON_INDEX_RIGHT then
		local data = ZO_ScrollList_GetData( control:GetParent() )
		if nil ~= data and nil ~= data.houseId then
			df( EHT.ADDON_TITLE .. " is jumping to |cffffff%s|r ...", data.houseName or "a home" )
			RequestJumpToHouse( data.houseId )
		end
	end
end

function EHT.Handlers.OnHousingEditorChangePositionAndOrientationRequestOverride( origFunc, id, x, y, z, pitch, yaw, roll, ... )
	if EHT.Biz.CheckItemLock( id ) then
		return HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED
	else
		EHT.Housing.AddCachedFurniture( id, x, y, z, pitch, yaw, roll )
		local result = origFunc( id, x, y, z, pitch, yaw, roll, ... )
		return result
	end
end

function EHT.Handlers.OnHousingEditorChangePositionRequestOverride( origFunc, id, x, y, z, ... )
	if EHT.Biz.CheckItemLock( id ) then
		return HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED
	else
		EHT.Housing.AddCachedFurniture( id, x, y, z )
		local result = origFunc( id, x, y, z, ... )
		return result
	end
end

function EHT.Handlers.OnHousingEditorChangeOrientationRequestOverride( origFunc, id, pitch, yaw, roll, ... )
	if EHT.Biz.CheckItemLock( id ) then
		return HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED
	else
		EHT.Housing.AddCachedFurniture( id, nil, nil, nil, pitch, yaw, roll )
		local result = origFunc( id, pitch, yaw, roll, ... )
		return result
	end
end

function EHT.Handlers.OnHousingEditorRemoveRequestOverride( origFunc, id, ... )
	if EHT.Biz.CheckItemLock( id ) then
		return HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED
	else
		-- EHT.Housing.RemoveCachedFurniture( id )
		local result = origFunc( id, ... )
		return result
	end
end

function EHT.Handlers.OnHousingEditorRequestModifyPathNodeOverride( origFunc, id, pathIndex, x, y, z, heading, speed, delayTime, ... )
	local furnitureId = EHT.Housing.GetFurniturePathNodeId( id, pathIndex )
	if EHT.Biz.CheckItemLock( furnitureId ) then
		return HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED
	else
		EHT.Housing.AddCachedFurniture( furnitureId, x, y, z, 0, heading, 0 )
		local result = origFunc( id, pathIndex, x, y, z, heading, speed, delayTime, ... )
		return result
	end
end

function EHT.Handlers.OnEditorPlaceTabClick( control, buttonIndex, upInside )
	if EHT.SavedVars.EnableQuickPlacement then
		if nil ~= control and buttonIndex == MOUSE_BUTTON_INDEX_RIGHT and upInside then
			if nil ~= KEYBOARD_HOUSING_FURNITURE_BROWSER and nil ~= KEYBOARD_HOUSING_FURNITURE_BROWSER.placeablePanel then
				local data = ZO_ScrollList_GetData( control )
				KEYBOARD_HOUSING_FURNITURE_BROWSER.placeablePanel:SelectForPlacement( data )
				return true
			end
		end
	end

	return false
end

function EHT.Handlers.OnEditorRetrieveTabClick( control, buttonIndex, upInside )
	if EHT.SavedVars.EnableQuickRetrieval then
		if nil ~= control and buttonIndex == MOUSE_BUTTON_INDEX_RIGHT and upInside then
			if nil ~= KEYBOARD_HOUSING_FURNITURE_BROWSER and nil ~= KEYBOARD_HOUSING_FURNITURE_BROWSER.retrievalPanel then
				local data = ZO_ScrollList_GetData( control )
				ZO_HousingFurnitureBrowser_Base.PutAwayFurniture( data )
				return true
			end
		end
	end

	return false
end

function EHT.Handlers.OnTriggerQueueChanged( queue )
	local queueSize = 0

	if queue then
		queueSize = #queue
		if 0 < queueSize then
			EHT.UI.SetPersistentNotification( "TriggerQueueSize", string.format( "Queued Trigger Actions: %d", queueSize ) )
		end
	end

	if 0 >= queueSize then
		EHT.UI.ClearPersistentNotification( "TriggerQueueSize" )
	end

	EHT.UI.RefreshTriggerQueue( queue )
end

function EHT.Handlers.OnMailInboxUpdate()
	if EHT.Effect then
		EVENT_MANAGER:RegisterForUpdate( "EHT.Effect:ProcessMailInbox", 1000, function() EHT.Effect:ProcessMailInbox() end )
	end
end

function EHT.Handlers.OnMailReadable( eventCode, mailId )
	EHT.Effect:ProcessMailItem( mailId )
end

function EHT.Handlers.OnMailRemoved( event, mailId )
	EHT.Effect:DeleteMailcasts()
end

function EHT.Handlers.OnMailSendSuccess( event )
	if EHT.DEBUG_MODE then
		d( "DEBUG: Mail send success event." )
	end

	local queue = EHT.Effect:GetMailcastQueue()
	if queue and queue[1] and "Sending" == queue[1].Status then
		local task = queue[1]
		task.Status = "Queued"
	end
end

function EHT.Handlers.OnMailSendFailed( event, result )
	if EHT.DEBUG_MODE then
		d( "DEBUG: Mail send failed event." )
	end

	local queue = EHT.Effect:GetMailcastQueue()
	if queue and queue[1] and "Sending" == queue[1].Status then
		local task = queue[1]
		task.Status = "Failed"

		local reason = ""
		if result == MAIL_SEND_RESULT_CANCELED then
			reason = "Mail send was canceled."
		elseif result == MAIL_SEND_RESULT_FAIL_DB_ERROR then
			reason = "Mail database or server error."
		elseif result == MAIL_SEND_RESULT_FAIL_IGNORED then
			reason = "Recipient has ignored you."
		elseif result == MAIL_SEND_RESULT_FAIL_INVALID_NAME then
			reason = "Invalid recipient name."
		elseif result == MAIL_SEND_RESULT_FAIL_MAILBOX_FULL then
			reason = "Recipient's mailbox is full."
		elseif result == MAIL_SEND_RESULT_MAILBOX_NOT_OPEN then
			reason = "Mailbox is not open."
		elseif result == MAIL_SEND_RESULT_MAIL_DISABLED then
			reason = "Mail sending is disabled."
		elseif result == MAIL_SEND_RESULT_RECIPIENT_NOT_FOUND then
			reason = "Recipient not found."
		else
			reason = "Unknown exception."
		end
		task.StatusReason = reason
	end
end

local function OnInaccessibleHouseJump()
	local notifyOwner = false

	if EHT.JumpingToHouseId and EHT.JumpingToOwner then
		EHT.Biz.SetHouseInaccessibleFlag( EHT.JumpingToOwner, EHT.JumpingToHouseId, true )
	end
--[[
	if EHT.IsOpenHouseHubView and EHT.JumpingToHouseId and EHT.JumpingToOwner and EHT.JumpingToOwner ~= "" and string.lower( GetDisplayName() ) ~= string.lower( EHT.JumpingToOwner ) then
		notifyOwner = true
	end
]]
	return notifyOwner
end

function EHT.Handlers.OnSocialError( eventCode, socialActionResult )
	if EHT.UsingPortal or EHT.JumpingToHouse then
		local msg

		if socialActionResult == SOCIAL_RESULT_CHARACTER_NOT_FOUND or socialActionResult == SOCIAL_RESULT_ACCOUNT_NOT_FOUND then
			msg = "The specified @player name is invalid."
			OnInaccessibleHouseJump()
		elseif socialActionResult == SOCIAL_RESULT_CANT_JUMP_INVALID_TARGET then
			msg = "That home is currently inaccessible."
		elseif socialActionResult == SOCIAL_RESULT_DESTINATION_FULL then
			msg = "That home is currently at maximum player capacity."
		elseif socialActionResult == SOCIAL_RESULT_NO_HOUSE_PERMISSION then
			msg = "You do not have permission to visit that home."
			if OnInaccessibleHouseJump() then
				EHT.UI.ConfirmNotifyOpenHouseOwner( EHT.JumpingToOwner, EHT.JumpingToHouseId )
			end
		end

		if msg then
			if EHT.UsingPortal then
				EHT.Effect.OnPortalJumpComplete()
			else
				EHT.UI.ShowHousingHub()
			end

			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.VisitHubEntryComplete" )
			EHT.UI.DisplayNotification( msg )
			d( msg )

			EHT.JumpingToHouse = false
			EHT.UsingPortal = false
		end
	end
end

function EHT.Handlers.OnJumpFailed( eventCode, jumpResult )
	if EHT.UsingPortal or EHT.JumpingToHouse then
		if EHT.IsDev then
			df( "EHT.Handlers.OnJumpFailed( %s, %s )", tostring(eventCode), tostring(jumpResult) )
		end

		local msg
		local notifyOwner = false

		if jumpResult == JUMP_RESULT_JUMP_FAILED_NO_HOUSE_PERMISSION then
			msg = "You do not have permission to visit that home."
			notifyOwner = OnInaccessibleHouseJump()
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_DONT_OWN_HOUSE then
			msg = "That instance is unavailable at the moment."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_INSTANCE_FULL or jumpResult == JUMP_RESULT_JUMP_FAILED_INSTANCE_CAP_REACHED then
			msg = "That home is at full player capacity."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_INVALID_HOUSE then
			msg = "That home is invalid."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_NO_SOCIAL or jumpResult == JUMP_RESULT_NO_JUMP_PERMISSION then
			msg = "Fast travel request failed."
		elseif jumpResult == JUMP_RESULT_JUMP_FAILED_QUEUING then
			msg = "Failed to queue fast travel."
		elseif jumpResult ~= JUMP_RESULT_LOCAL_JUMP_SUCCESSFUL and jumpResult ~= JUMP_RESULT_JUMP_FAILED_ALREADY_JUMPING and jumpResult ~= JUMP_RESULT_REMOTE_JUMP_INITIATED then
			msg = string.format( "Fast travel failed. (Code: %d)", jumpResult or -1 )
		end

		if msg then
			if notifyOwner then
				EHT.UI.ConfirmNotifyOpenHouseOwner( EHT.JumpingToOwner, EHT.JumpingToHouseId )
			elseif EHT.UsingPortal then
				EHT.Effect.OnPortalJumpComplete()
			else
				EHT.UI.ShowHousingHub()
			end

			EVENT_MANAGER:UnregisterForUpdate( "EHT.UI.VisitHubEntryComplete" )
			EHT.UI.DisplayNotification( msg )
			d( msg )
		end

		EHT.JumpingToHouse = false
		EHT.JumpingToHouseId = nil
		EHT.JumpingToOwner = nil
		EHT.UsingPortal = false
	end
end

function EHT.Handlers.OnJumpPending( eventCode, zoneName, zoneDescription, texture, instanceType )
	-- No Op
end

do
	local function SaveKeybinds()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.Setup.SaveKeybinds" )
		EHT.Setup.SaveKeybinds()
	end

	function EHT.Handlers.OnKeybindsUpdated()
		EVENT_MANAGER:UnregisterForUpdate( "EHT.Setup.SaveKeybinds" )
		EVENT_MANAGER:RegisterForUpdate( "EHT.Setup.SaveKeybinds", 100, SaveKeybinds )
	end
end

local function OnGuildMemberNoteChanged( eventCode, guildId, displayName, note )
	EHT.Guilds:FlushCache()

	if GetDisplayName() == displayName then
		EHT.Guilds:OnGuildMemberNoteChanged( guildId, note )

		if not EHT.IsChatcastReflectionEnabled() then
			return
		end
	end

	if string.sub( note or "", 1, #EHT.CHATCAST_PREFIX ) == EHT.CHATCAST_PREFIX then
		EHT.Effect:ProcessInboundChatcast( displayName, note, "Guild" )
	end
end

function EHT.Handlers.OnGuildMemberNoteChanged(eventCode, guildId, displayName, note)
	OnGuildMemberNoteChanged(eventCode, guildId, displayName, note)
end

function EHT.Handlers.OnGuildUpdates()
	EHT.Guilds:FlushCache()
end

function EHT.Handlers.OnCollectibleUpdated( eventCode, collectibleId )
	EHT.Housing.GetAllHouses( true )
	EssentialHousingHub:UpdateOpenHouseNickname( collectibleId )
end

function EHT.Handlers.OnItemPreviewStateChange( oldState, newState )
	if "hiding" == newState then
		EHT.UI.HidePreviewControlsDialog()
	elseif "shown" == newState then
		EHT.UI.ShowPreviewControlsDialog()
	end
end

function EHT.Handlers.OnInventoryFullUpdate( event )
	EHT.EffectUI.RefreshPOIEffects()
end

function EHT.Handlers.OnInventorySingleSlotUpdate( event, bag, slot, isNew, itemSoundCategory, inventoryUpdateReason, stackCountChange )
	EHT.EffectUI.RefreshPOIEffects()
end

do
	local craftCompleted = false

	function EHT.Handlers.OnCraftCompleted( event )
		craftCompleted = true
	end

	function EHT.Handlers.OnEndCraftingStationInteract( event, tradeskillType )
		if craftCompleted then
			craftCompleted = false
			EHT.EffectUI.RefreshPOIEffects()
		end
	end
end

function EHT.Handlers.OnRetrievableFurnitureRowMouseEnter( self, data, control )
	if data and data.retrievableFurnitureId then
		EHT.EffectUI.SetTargetFurniture( "Breadcrumb", data.retrievableFurnitureId )
	else
		EHT.EffectUI.ClearTargetFurniture( "Breadcrumb" )
	end
end

function EHT.Handlers.OnRetrievableFurnitureRowMouseExit( self, data, control )
	EHT.EffectUI.ClearTargetFurniture( "Breadcrumb" )
end

function EHT.Handlers.OnSetupRetrievableFurnitureRow( self, control, data, ... )
	control:SetHandler( "OnMouseEnter", function( c )
		EHT.Handlers.OnRetrievableFurnitureRowMouseEnter( self, data, c )
	end, "EHT" )

	control:SetHandler( "OnMouseExit", function( c )
		EHT.Handlers.OnRetrievableFurnitureRowMouseExit( self, data, c )
	end, "EHT" )

	return EHT.OldSetupRetrievableFurnitureRow( self, control, data, ... )
end

function EHT.Handlers.OnSharedFurnitureSetPlayerWaypointTo( self, data, ... )
	if data and data.retrievableFurnitureId then
		EHT.EffectUI.SetTargetFurniture( "Waypoint", data.retrievableFurnitureId )
	else
		EHT.EffectUI.ClearTargetFurniture( "Waypoint" )
	end

	return EHT.OldSharedFurnitureSetPlayerWaypointTo( self, data, ... )
end

---[ Events : Registrations ]---

local handlersRegistered = false
local shadowsRegistered = false

function EHT.Handlers.RegisterHandlers()
	if not handlersRegistered then
		handlersRegistered = true

		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_PLAYER_ACTIVATED, EHT.Handlers.PlayerActivated )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_PLAYER_DEACTIVATED, EHT.Handlers.OnLoggingOut )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_LOGOUT_DEFERRED, EHT.Handlers.OnLoggingOut )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED, EHT.Handlers.OnHousingEditorModeChanged )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_POPULATION_CHANGED, EHT.Handlers.OnHousePopulationChanged )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_MOVED, EHT.Handlers.OnFurnitureMoved )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, EHT.Handlers.OnFurniturePlaced )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED, EHT.Handlers.OnFurnitureRemoved )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_STATE_CHANGED, EHT.Handlers.OnFurnitureStateChanged )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODE_ADDED, EHT.Handlers.OnFurniturePathNodeAdded )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODE_MOVED, EHT.Handlers.OnFurniturePathNodeMoved )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODE_REMOVED, EHT.Handlers.OnFurniturePathNodeRemoved )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_DATA_CHANGED, EHT.Handlers.OnFurniturePathDataChanged )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODES_RESTORED, EHT.Handlers.OnFurniturePathNodesRestored )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_INVENTORY_FULL_UPDATE, EHT.Handlers.OnInventoryFullUpdate )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, EHT.Handlers.OnInventorySingleSlotUpdate )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_CRAFT_COMPLETED, EHT.Handlers.OnCraftCompleted )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_END_CRAFTING_STATION_INTERACT, EHT.Handlers.OnEndCraftingStationInteract )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_CLIENT_INTERACT_RESULT, EHT.Handlers.OnClientInteractResult )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_CHAT_MESSAGE_CHANNEL, EHT.Handlers.OnChatMessage )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_INBOX_UPDATE, EHT.Handlers.OnMailInboxUpdate )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_READABLE, EHT.Handlers.OnMailReadable )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_REMOVED, EHT.Handlers.OnMailRemoved )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_SEND_FAILED, EHT.Handlers.OnMailSendFailed )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_SEND_SUCCESS, EHT.Handlers.OnMailSendSuccess )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_SOCIAL_ERROR, EHT.Handlers.OnSocialError )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_JUMP_FAILED, EHT.Handlers.OnJumpFailed )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_PREPARE_FOR_JUMP, EHT.Handlers.OnJumpPending )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_NOTE_CHANGED, EHT.Handlers.OnGuildMemberNoteChanged )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_COLLECTIBLE_UPDATED, EHT.Handlers.OnCollectibleUpdated )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GLOBAL_MOUSE_DOWN, function( event, button, ctrl, alt, sh, cmd )
			if button == MOUSE_BUTTON_INDEX_LEFT then
				EHT.LastMouseClick = GetFrameTimeMilliseconds()
			end
		end )

		-- Guild Cache Flush Events
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_DESCRIPTION_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_ID_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_RANK_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_ADDED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_REMOVED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MOTD_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_RANK_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_RANKS_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_SELF_JOINED_GUILD, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_SELF_LEFT_GUILD, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_SAVE_GUILD_RANKS_RESPONSE, EHT.Handlers.OnGuildUpdates )

		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_KEYBINDINGS_LOADED, EHT.Handlers.OnKeybindsUpdated )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_KEYBINDING_CLEARED, EHT.Handlers.OnKeybindsUpdated )
		EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_KEYBINDING_SET, EHT.Handlers.OnKeybindsUpdated )

		ITEM_PREVIEW_KEYBOARD.fragment:RegisterCallback( "StateChange", EHT.Handlers.OnItemPreviewStateChange )

		---[ Events : Overrides ]---

		if not shadowsRegistered then
			shadowsRegistered = true

			ZO_PreHook( SCENE_MANAGER, "OnSceneStateShown", EHT.Handlers.OnSceneStateShown )
			ZO_PreHook( QuickslotActionButton, "OnRelease", EHT.Handlers.OnQuickslotActionReleased )
			ZO_PreHook( "ZO_InventorySlot_ShowContextMenu", EHT.Handlers.OnInventoryContextMenu )
			ZO_PreHook( "ZO_WorldMapHouseRow_OnMouseUp", EHT.Handlers.OnWorldMapHouseRowClicked )
			ZO_PreHook( "PlayEmoteByIndex", EHT.Handlers.OnPlayEmoteByIndex )
			ZO_PreHook( "PlaySound", EHT.Handlers.OnPlaySound )
			ZO_PreHook( KEYBOARD_HOUSING_FURNITURE_BROWSER.placeablePanel, "PlaceableFurnitureOnMouseClickCallback", EHT.Handlers.OnEditorPlaceTabClick )
			ZO_PreHook( KEYBOARD_HOUSING_FURNITURE_BROWSER.retrievalPanel, "RetrievableFurnitureOnMouseClick", EHT.Handlers.OnEditorRetrieveTabClick )

			EHT.Util.ShadowFunction( _G, "HousingEditorRequestChangePosition", EHT.Handlers.OnHousingEditorChangePositionRequestOverride )
			EHT.Util.ShadowFunction( _G, "HousingEditorRequestChangeOrientation", EHT.Handlers.OnHousingEditorChangeOrientationRequestOverride )
			EHT.Util.ShadowFunction( _G, "HousingEditorRequestChangePositionAndOrientation", EHT.Handlers.OnHousingEditorChangePositionAndOrientationRequestOverride )
			EHT.Util.ShadowFunction( _G, "HousingEditorRequestRemoveFurniture", EHT.Handlers.OnHousingEditorRemoveRequestOverride )
			EHT.Util.ShadowFunction( _G, "HousingEditorRequestModifyPathNode", EHT.Handlers.OnHousingEditorRequestModifyPathNodeOverride )

			if ZO_HousingFurnitureRetrieval_Keyboard and not EHT.OldSetupRetrievableFurnitureRow then
				EHT.OldSetupRetrievableFurnitureRow = ZO_HousingFurnitureRetrieval_Keyboard.SetupRetrievableFurnitureRow
				ZO_HousingFurnitureRetrieval_Keyboard.SetupRetrievableFurnitureRow = EHT.Handlers.OnSetupRetrievableFurnitureRow
			end
			
			if SHARED_FURNITURE and not EHT.OldSharedFurnitureSetPlayerWaypointTo then
				EHT.OldSharedFurnitureSetPlayerWaypointTo = SHARED_FURNITURE.SetPlayerWaypointTo
				SHARED_FURNITURE.SetPlayerWaypointTo = EHT.Handlers.OnSharedFurnitureSetPlayerWaypointTo
			end
		end
	end
end

function EHT.Handlers.UnregisterHandlers()
	if handlersRegistered then
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_PLAYER_ACTIVATED, EHT.Handlers.PlayerActivated )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_PLAYER_DEACTIVATED, EHT.Handlers.OnLoggingOut )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_LOGOUT_DEFERRED, EHT.Handlers.OnLoggingOut )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED, EHT.Handlers.OnHousingEditorModeChanged )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_POPULATION_CHANGED, EHT.Handlers.OnHousePopulationChanged )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_MOVED, EHT.Handlers.OnFurnitureMoved )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, EHT.Handlers.OnFurniturePlaced )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED, EHT.Handlers.OnFurnitureRemoved )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_STATE_CHANGED, EHT.Handlers.OnFurnitureStateChanged )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODE_ADDED, EHT.Handlers.OnFurniturePathNodeAdded )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODE_MOVED, EHT.Handlers.OnFurniturePathNodeMoved )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODE_REMOVED, EHT.Handlers.OnFurniturePathNodeRemoved )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_DATA_CHANGED, EHT.Handlers.OnFurniturePathDataChanged )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_HOUSING_FURNITURE_PATH_NODES_RESTORED, EHT.Handlers.OnFurniturePathNodesRestored )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_INVENTORY_FULL_UPDATE, EHT.Handlers.OnInventoryFullUpdate )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, EHT.Handlers.OnInventorySingleSlotUpdate )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_CRAFT_COMPLETED, EHT.Handlers.OnCraftCompleted )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_END_CRAFTING_STATION_INTERACT, EHT.Handlers.OnEndCraftingStationInteract )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_CLIENT_INTERACT_RESULT, EHT.Handlers.OnClientInteractResult )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_CHAT_MESSAGE_CHANNEL, EHT.Handlers.OnChatMessage )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_INBOX_UPDATE, EHT.Handlers.OnMailInboxUpdate )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_READABLE, EHT.Handlers.OnMailReadable )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_REMOVED, EHT.Handlers.OnMailRemoved )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_SEND_FAILED, EHT.Handlers.OnMailSendFailed )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_MAIL_SEND_SUCCESS, EHT.Handlers.OnMailSendSuccess )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_SOCIAL_ERROR, EHT.Handlers.OnSocialError )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_JUMP_FAILED, EHT.Handlers.OnJumpFailed )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_NOTE_CHANGED, EHT.Handlers.OnGuildMemberNoteChanged )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_COLLECTIBLE_UPDATED, EHT.Handlers.OnCollectibleUpdated )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GLOBAL_MOUSE_DOWN )

		-- Guild Cache Flush Events
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_ID_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_RANK_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_ADDED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MEMBER_REMOVED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_MOTD_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_RANK_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_RANKS_CHANGED, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_SELF_JOINED_GUILD, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_GUILD_SELF_LEFT_GUILD, EHT.Handlers.OnGuildUpdates )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_SAVE_GUILD_RANKS_RESPONSE, EHT.Handlers.OnGuildUpdates )

		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_KEYBINDINGS_LOADED, EHT.Handlers.OnKeybindsUpdated )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_KEYBINDING_CLEARED, EHT.Handlers.OnKeybindsUpdated )
		EVENT_MANAGER:UnregisterForEvent( EHT.ADDON_NAME, EVENT_KEYBINDING_SET, EHT.Handlers.OnKeybindsUpdated )

		handlersRegistered = false
	end
end

EVENT_MANAGER:RegisterForEvent( EHT.ADDON_NAME, EVENT_ADD_ON_LOADED, EHT.Handlers.OnAddOnLoaded )

EHT.PopTS( "Initial Compilation" )

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Handlers = true
