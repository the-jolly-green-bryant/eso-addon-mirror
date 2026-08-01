BSCScribingFavorite = BSCScribingFavorite or {}
local BSCSF = BSCScribingFavorite

-------------------------------------------------------------------------------------------------
local ZO_SCRIBING_KEYBOARD_MODE_FAVORITE = 3
local FAVORITE_ABILITIES_LIST_ABILITY_ENTRY_ID = 2
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
local function RefreshModeBar()
    if SCRIBING_KEYBOARD and SCRIBING_KEYBOARD.modeBar then
		local hasAnyRecentCraftedAbilities = BSCSF:HasAnyFavoriteCraftedAbilities()
		ZO_MenuBar_SetDescriptorEnabled(SCRIBING_KEYBOARD.modeBar, ZO_SCRIBING_KEYBOARD_MODE_FAVORITE, hasAnyRecentCraftedAbilities)
	end
end
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
local function TryAddRemoveFavoriteAbility(control)
	local entry = ZO_ScrollList_GetData(control)
	if not entry then return end
	local FavoriteCraftedAbilityData = entry.recentCraftedAbilityData
	
	if SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_RECENT then
		ZO_Dialogs_ShowPlatformDialog("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM", { AbilityData = FavoriteCraftedAbilityData } )
	elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE then
		ZO_Dialogs_ShowPlatformDialog("SCRIBING_REMOVE_FAVORITE_SKILLS_CONFIRM", { AbilityData = FavoriteCraftedAbilityData })				
	end
end
-------------------------------------------------------------------------------------------------
function BSCSF.OnMouseClickRecentCraftedAbility(control, button)
	if not SCRIBING_KEYBOARD:IsShowing() then
        return
    end
    if button == MOUSE_BUTTON_INDEX_LEFT then
        SCRIBING_KEYBOARD:TrySelectRecentCraftedAbilityFromList(control)
	elseif button == MOUSE_BUTTON_INDEX_RIGHT then
		TryAddRemoveFavoriteAbility(control)
    end
end
-------------------------------------------------------------------------------------------------
local function SetMouseOverRecentCraftedAbilityEntry()
	KEYBIND_STRIP:UpdateKeybindButtonGroup(BSCSF.keybindStripDescriptor)
end
-------------------------------------------------------------------------------------------------
local function GetCraftedAbilityName(abilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId)
    local craftedAbilityData = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(abilityId)
    if not craftedAbilityData then return "" end

    -- wie ESO-Tooltip: ScriptData setzen
    local pData = SCRIBING_DATA_MANAGER:GetCraftedAbilityScriptData(primaryScriptId)
    local sData = SCRIBING_DATA_MANAGER:GetCraftedAbilityScriptData(secondaryScriptId)
    local tData = SCRIBING_DATA_MANAGER:GetCraftedAbilityScriptData(tertiaryScriptId)
    craftedAbilityData:SetScriptDataSelectionOverride(pData, sData, tData)

    -- Name aus Representative Ability holen (so macht's das Tooltip)
    local repAbilityId = craftedAbilityData:GetRepresentativeAbilityId()
    if repAbilityId and repAbilityId ~= 0 then
        local repName = GetAbilityName(repAbilityId)
        if repName and repName ~= "" then
            return ZO_CachedStrFormat(SI_ABILITY_NAME, repName)
        end
    end

    -- Fallbacks
    local name = craftedAbilityData:GetFormattedName()
    if not name or name == "" then
        local skillsData = craftedAbilityData:GetSkillData()
        if skillsData and skillsData.skillProgressionData then
            name = skillsData.skillProgressionData:GetName()
        end
    end
    return ZO_CachedStrFormat(SI_ABILITY_NAME, name or "")
end

local function GetFavoriteDisplayName(fav)
    if not fav then return "" end

    local abilityId         = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]
    local primaryScriptId   = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.PRIMARY_SCRIPT]
    local secondaryScriptId = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.SECONDARY_SCRIPT]
    local tertiaryScriptId  = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.TERTIARY_SCRIPT]
	local customName        = fav[5] -- optional
	
	local repName = GetCraftedAbilityName(abilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId)
	
    if customName and customName ~= "" then
        repName = string.format("%s - %s", repName, customName)
    end
	return ZO_CachedStrFormat(SI_ABILITY_NAME, repName or "")
end
-------------------------------------------------------------------------------------------------
local function SetupAddFavoriteConfirmDialog()
    local customControl = BSC_InitialScribeAddFavoriteConfirmationDialog
	ZO_Dialogs_RegisterCustomDialog("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM",
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.STATIC_LIST,
        },
        customControl = customControl,
        canQueue = true,
        title =
        {
            text = GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE).." ?",
        },
        mainText =
		{
			text = function(dialog)
				local FavoriteCraftedAbilityData = dialog.data.AbilityData
				
				local AbilityID = 			FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]
				local primaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.PRIMARY_SCRIPT]
				local secondaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.SECONDARY_SCRIPT]
				local tertiaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.TERTIARY_SCRIPT]
				
				return GetCraftedAbilityName(AbilityID, primaryScriptId, secondaryScriptId, tertiaryScriptId)
			end,
		},
        setup = function(dialog, data)
            if IsInGamepadPreferredMode() then
                dialog:setupFunc()
            else
				local FavoriteCraftedAbilityData = dialog.data.AbilityData
				
				local AbilityID = 			FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]
				local primaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.PRIMARY_SCRIPT]
				local secondaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.SECONDARY_SCRIPT]
				local tertiaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.TERTIARY_SCRIPT]
								
				-- Icon
                local iconControl = customControl:GetNamedChild("ScribedSkill")
				iconControl:SetTexture(GetCraftedAbilityIcon(FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]) )
				-- Desciption				
				local skillInfo = GetCraftedAbilityDescription(AbilityID)
				local pScriptInfo = GetCraftedAbilityScriptDescription(AbilityID, primaryScriptId)
				local sScriptInfo = GetCraftedAbilityScriptDescription(AbilityID, secondaryScriptId)
				local tScriptInfo = GetCraftedAbilityScriptDescription(AbilityID, tertiaryScriptId)
								
				local SDescControl = customControl:GetNamedChild("SkillDesc")	
				SDescControl:SetText(string.format("%s\n\n%s\n\n%s\n\n%s", skillInfo, pScriptInfo, sScriptInfo, tScriptInfo))	

                local nameInput = customControl:GetNamedChild("NameInput")
                nameInput:SetText("")				
            end
        end,
        itemInfo = function(dialog)
			local FavoriteCraftedAbilityData = dialog.data.AbilityData	
            local iconTable =
            {
                {
					icon = GetCraftedAbilityIcon(FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]), 
                    iconSize = 64,
                }
            }
            return iconTable
        end,
        buttons =
        {
            {
                control = customControl:GetNamedChild("Confirm"),
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
					local fav = dialog.data.AbilityData
                    local nameInput = customControl:GetNamedChild("NameInput")
                    local customName = zo_strtrim(nameInput:GetText())
                    if customName == "" then customName = nil end

                    local newFav = {
                        fav[1], fav[2], fav[3], fav[4], customName
                    }					
					BSCSF:AddToFavorite(newFav)
					RefreshModeBar()
					if SCRIBING_KEYBOARD and SCRIBING_KEYBOARD.modeBar then
						ZO_MenuBar_SelectDescriptor(SCRIBING_KEYBOARD.modeBar, ZO_SCRIBING_KEYBOARD_MODE_FAVORITE)
					end
                end,
            },
            {
                control = customControl:GetNamedChild("Cancel"),
                text = SI_DIALOG_CANCEL,
                callback = function(dialog)
					
                end,
            }
        }
	})
end
-------------------------------------------------------------------------------------------------
local function SetupRemoveFavoriteConfirmDialog()
    local customControl = BSC_InitialScribeRemoveFavoriteConfirmationDialog	
    ZO_Dialogs_RegisterCustomDialog("SCRIBING_REMOVE_FAVORITE_SKILLS_CONFIRM",
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.STATIC_LIST,
        },
        customControl = customControl,
        canQueue = true,
        title =
        {
            text = GetString(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE).." ?",
        },
        mainText =
		{
			text = function(dialog)
				return GetFavoriteDisplayName(dialog.data.AbilityData)
			end,
		},
        setup = function(dialog, data)
            if IsInGamepadPreferredMode() then
                dialog:setupFunc()
            else
				local FavoriteCraftedAbilityData = dialog.data.AbilityData
				
				local AbilityID = 			FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]
				local primaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.PRIMARY_SCRIPT]
				local secondaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.SECONDARY_SCRIPT]
				local tertiaryScriptId = 	FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.TERTIARY_SCRIPT]
								
				-- Icon
                local iconControl = customControl:GetNamedChild("ScribedSkill")
				iconControl:SetTexture(GetCraftedAbilityIcon(FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]) )
				-- Desciption				
				local skillInfo = GetCraftedAbilityDescription(AbilityID)
				local pScriptInfo = GetCraftedAbilityScriptDescription(AbilityID, primaryScriptId)
				local sScriptInfo = GetCraftedAbilityScriptDescription(AbilityID, secondaryScriptId)
				local tScriptInfo = GetCraftedAbilityScriptDescription(AbilityID, tertiaryScriptId)
								
				local SDescControl = customControl:GetNamedChild("SkillDesc")	
				SDescControl:SetText(string.format("%s\n\n%s\n\n%s\n\n%s", skillInfo, pScriptInfo, sScriptInfo, tScriptInfo))				
            end
        end,
        itemInfo = function(dialog)
			local FavoriteCraftedAbilityData = dialog.data.AbilityData	
            local iconTable =
            {
                {
					icon = GetCraftedAbilityIcon(FavoriteCraftedAbilityData[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]), 
                    iconSize = 64,
                }
            }
            return iconTable
        end,
        buttons =
        {
            {
                control = customControl:GetNamedChild("Confirm"),
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
					local FavoriteCraftedAbilityData = dialog.data.AbilityData
					BSCSF:RemoveFavoriteSkill(FavoriteCraftedAbilityData)	
					BSCSF:ShowFavoriteCraftedAbilities()
					RefreshModeBar()
					if nCount == 0 then
						ZO_MenuBar_SelectDescriptor(SCRIBING_KEYBOARD.modeBar, ZO_SCRIBING_KEYBOARD_MODE_SCRIBING)
					end
                end,
            },
            {
                control = customControl:GetNamedChild("Cancel"),
                text = SI_DIALOG_CANCEL,
                callback = function(dialog)
					
                end,
            }
        }
    })
end
-------------------------------------------------------------------------------------------------
function BSCSF:ShowFavoriteCraftedAbilities()
    local RESET_TO_TOP = true
    BSCSF:RefreshFavoriteCraftedAbilitiesList(RESET_TO_TOP)
end
function BSCSF:RefreshFavoriteCraftedAbilitiesList(resetToTop)
    if SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE then
        local list = SCRIBING_KEYBOARD.favoriteScribedAbilitiesList
        ZO_ScrollList_Clear(list)
        local scrollData = ZO_ScrollList_GetDataList(list)

        local favorites = BSCSF.SV_ACC.SCAL
        for i = 1, #favorites do
            local fav = favorites[i]
            if fav ~= nil then
                local craftedAbilityId = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.CRAFTED_ABILITY]
                local craftedAbilityData = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(craftedAbilityId)
                if craftedAbilityData and not craftedAbilityData:IsDisabled() then
                    local primaryScriptId  = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.PRIMARY_SCRIPT]
                    local secondaryScriptId= fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.SECONDARY_SCRIPT]
                    local tertiaryScriptId = fav[ZO_RECENT_SCRIBE_SAVED_VAR_INDEX.TERTIARY_SCRIPT]

                    craftedAbilityData:SetScriptIdSelectionOverride(primaryScriptId, secondaryScriptId, tertiaryScriptId)

                    local entryData = {
                        name = GetFavoriteDisplayName(fav),
                        icon = craftedAbilityData:GetIcon(),
                        recentCraftedAbilityData = fav,
                    }
                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(FAVORITE_ABILITIES_LIST_ABILITY_ENTRY_ID, entryData))
                end
            end
        end
        ZO_ScrollList_Commit(list)
    end
end
-------------------------------------------------------------------------------------------------
local function SetMode(_, mode)
    if BSCSF.mode ~= mode then
		local oldMode = BSCSF.mode
        BSCSF.mode = mode		
		if mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE  then
			BSCSF:ShowFavoriteCraftedAbilities()
        end		
        local isFavoriteMode = mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE
		if SCRIBING_KEYBOARD.favoriteContainer ~= nil then
			SCRIBING_KEYBOARD.favoriteContainer:SetHidden(not isFavoriteMode)
			BSCScribingFavoriteUI:SetHidden(not isFavoriteMode)
		end		
        KEYBIND_STRIP:UpdateKeybindButtonGroup(BSCSF.keybindStripDescriptor)
	end
end
-------------------------------------------------------------------------------------------------
local function InitializeFavoriteTab()
    local function LayoutFavoriteScribesTabTooltip(tooltip)
        SetTooltipText(tooltip, zo_strformat(SI_MENU_BAR_TOOLTIP, GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER)))
        if not BSCSF:HasAnyFavoriteCraftedAbilities() then
            tooltip:AddLine(GetString(SI_SCRIBING_RECENT_CRAFTED_ABILITIES_TAB_DISABLED_TOOLTIP_TEXT))
        end
    end		
	SCRIBING_KEYBOARD.favoriteScribesTab =
    {
        categoryName = SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER,
        descriptor = ZO_SCRIBING_KEYBOARD_MODE_FAVORITE,
        normal = "EsoUI/Art/Crafting/scribing_tabIcon_recent_up.dds",
        pressed = "EsoUI/Art/Crafting/scribing_tabIcon_recent_down.dds",
        highlight = "EsoUI/Art/Crafting/scribing_tabIcon_recent_over.dds",
        disabled = "EsoUI/Art/Crafting/scribing_tabIcon_recent_disabled.dds",
        alwaysShowTooltip = true,
        CustomTooltipFunction = LayoutFavoriteScribesTabTooltip,
        callback = function(tabData)
            SCRIBING_KEYBOARD.modeBarLabel:SetText(GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER))
            SCRIBING_KEYBOARD:SetMode(ZO_SCRIBING_KEYBOARD_MODE_FAVORITE)
        end,
    }	
	SCRIBING_KEYBOARD.recentScribesButton = ZO_MenuBar_AddButton(SCRIBING_KEYBOARD.modeBar, SCRIBING_KEYBOARD.favoriteScribesTab)
    SCRIBING_KEYBOARD:RefreshModeBar()
	RefreshModeBar()
end
local function InitializeFavoriteScribesList()	
    SCRIBING_KEYBOARD.favoriteContainer = BSCScribingFavoriteUI:GetNamedChild("Favorite") 	
    SCRIBING_KEYBOARD.favoriteScribedAbilitiesList = SCRIBING_KEYBOARD.favoriteContainer:GetNamedChild("ScribedAbilities")
    local function FavoriteCraftedAbilitySetup(control, data)
        control.owner = SCRIBING_KEYBOARD
        local nameLabel = control:GetNamedChild("Name")
        nameLabel:SetText(data.name)

        local iconControl = control:GetNamedChild("Icon")
        iconControl:SetTexture(data.icon)
    end
    ZO_ScrollList_AddDataType(SCRIBING_KEYBOARD.favoriteScribedAbilitiesList, FAVORITE_ABILITIES_LIST_ABILITY_ENTRY_ID, "BSC_Scribing_RecentCraftedAbilityRow_Keyboard", ZO_SCRIBING_RECENT_CRAFTED_ABILITY_ENTRY_HEIGHT_KEYBOARD, FavoriteCraftedAbilitySetup)
    ZO_ScrollList_EnableHighlight(SCRIBING_KEYBOARD.favoriteScribedAbilitiesList, "ZO_ThinListHighlight")
end
local function InitializeFavorite()	
	BSCSF.mode = nil
	InitializeFavoriteScribesList()
	InitializeFavoriteTab()
end
local function OnHiding()
	if SCRIBING_KEYBOARD.favoriteContainer ~= nil then
		SCRIBING_KEYBOARD.favoriteContainer:SetHidden(true)
		BSCScribingFavoriteUI:SetHidden(true)
	end	
	KEYBIND_STRIP:RemoveKeybindButtonGroup(BSCSF.keybindStripDescriptor)
end
local function OnShowing()
    KEYBIND_STRIP:AddKeybindButtonGroup(BSCSF.keybindStripDescriptor)
end
local function InitializeRecentScribesList()	
	ZO_PreHook(SCRIBING_KEYBOARD, "InitializeRecentScribesList", function()
			local RECENT_ABILITIES_LIST_ABILITY_ENTRY_ID = 1 	
		    SCRIBING_KEYBOARD.recentContainer = SCRIBING_KEYBOARD.control:GetNamedChild("Recent")
			SCRIBING_KEYBOARD.recentScribedAbilitiesList = SCRIBING_KEYBOARD.recentContainer:GetNamedChild("ScribedAbilities")
			local function RecentCraftedAbilitySetup(control, data)
				control.owner = SCRIBING_KEYBOARD
				local nameLabel = control:GetNamedChild("Name")
				nameLabel:SetText(data.name)

				local iconControl = control:GetNamedChild("Icon")
				iconControl:SetTexture(data.icon)
			end
			ZO_ScrollList_AddDataType(SCRIBING_KEYBOARD.recentScribedAbilitiesList, RECENT_ABILITIES_LIST_ABILITY_ENTRY_ID, "BSC_Scribing_RecentCraftedAbilityRow_Keyboard", ZO_SCRIBING_RECENT_CRAFTED_ABILITY_ENTRY_HEIGHT_KEYBOARD, RecentCraftedAbilitySetup)
			ZO_ScrollList_EnableHighlight(SCRIBING_KEYBOARD.recentScribedAbilitiesList, "ZO_ThinListHighlight")
		return true
	end)
end
function BSCSF:ShouldCraftButtonBeEnabled()
    if ZO_CraftingUtils_IsPerformingCraftProcess() then
        return false
    end
    local p,s,t = SCRIBING_KEYBOARD:GetSlottedScriptIds()
    if p == 0 or s == 0 or t == 0 then
        return false, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_EMPTY_SCRIPT_SLOT)
    end
    if not (SCRIBING_KEYBOARD:IsScriptIdUnlocked(p) and SCRIBING_KEYBOARD:IsScriptIdUnlocked(s) and SCRIBING_KEYBOARD:IsScriptIdUnlocked(t)) then
        return false, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_UNOWNED_SCRIPT)
    end
    local data = SCRIBING_KEYBOARD:GetSlottedCraftedAbilityData()
    if not data:IsScribableScriptIdCombination(p, s, t) then
        return false, GetString("SI_TRADESKILLRESULT", CRAFTING_RESULT_INVALID_SCRIBING_COMBINATION)
    end
    local id = SCRIBING_KEYBOARD:GetSlottedCraftedAbilityId()
    local cad = { id, p, s, t }
    if BSCSF:IsInFavorite(cad) then
        return false, GetString(SI_ITEM_FORMAT_STR_ALREADY_IN_COLLECTION)
    end
    return true
end

local function AddKeyBind()
	BSCSF.keybindStripDescriptor=
    {
		-- Add/Remove to Favorite
        {
            keybind = "UI_SHORTCUT_QUATERNARY",
			alignment = function()
				if SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_RECENT or SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE then
					return KEYBIND_STRIP_ALIGN_RIGHT
				elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_SCRIBING	then		
					return KEYBIND_STRIP_ALIGN_CENTER
				end
			end,
            name = function() 
				if SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_RECENT or SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_SCRIBING then
					return GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE)
				elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE	then	
					return GetString(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE)
				end
			end,
            callback = function()				
				if SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_SCRIBING then
					local craftedAbilityId = SCRIBING_KEYBOARD:GetSlottedCraftedAbilityId()					
					local primaryScriptId, secondaryScriptId, tertiaryScriptId = SCRIBING_KEYBOARD:GetSlottedScriptIds()
					local cad = { craftedAbilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId }	
					ZO_Dialogs_ShowPlatformDialog("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM", { AbilityData = cad } )
				elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_RECENT then
					if SCRIBING_KEYBOARD:HasMouseOverRecentCraftedAbilityEntry() then
						local FavoriteCraftedAbilityData = SCRIBING_KEYBOARD:GetMouseOverRecentCraftedAbilityEntry().dataEntry.data.recentCraftedAbilityData
						if FavoriteCraftedAbilityData then
							ZO_Dialogs_ShowPlatformDialog("SCRIBING_ADD_FAVORITE_SKILLS_CONFIRM", { AbilityData = FavoriteCraftedAbilityData } )
						end
					end
				elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE then
					if SCRIBING_KEYBOARD:HasMouseOverRecentCraftedAbilityEntry() then
						local FavoriteCraftedAbilityData = SCRIBING_KEYBOARD:GetMouseOverRecentCraftedAbilityEntry().dataEntry.data.recentCraftedAbilityData
						if FavoriteCraftedAbilityData then
							ZO_Dialogs_ShowPlatformDialog("SCRIBING_REMOVE_FAVORITE_SKILLS_CONFIRM", { AbilityData = FavoriteCraftedAbilityData })	
						end
					end
				end
            end,
            enabled = function()
				if SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_SCRIBING then
					return BSCSF:ShouldCraftButtonBeEnabled()
				elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_RECENT then
					if SCRIBING_KEYBOARD:HasMouseOverRecentCraftedAbilityEntry() then
						local FavoriteCraftedAbilityData = SCRIBING_KEYBOARD:GetMouseOverRecentCraftedAbilityEntry().dataEntry.data.recentCraftedAbilityData
						if FavoriteCraftedAbilityData and not BSCSF:IsInFavorite(FavoriteCraftedAbilityData) then
							return true
						end
					end	
					return false
				elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE then
					return not ZO_CraftingUtils_IsPerformingCraftProcess()
				end
            end,
            visible = function()
				if SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_SCRIBING then
					return not SCRIBING_KEYBOARD:AreCraftedAbilitiesShowing() and SCRIBING_KEYBOARD:HasCraftedAbilitySlotted()
				elseif SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_RECENT or SCRIBING_KEYBOARD.mode == ZO_SCRIBING_KEYBOARD_MODE_FAVORITE then
					return SCRIBING_KEYBOARD:HasMouseOverRecentCraftedAbilityEntry()
				end
            end,
        },
	}	
    ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(BSCSF.keybindStripDescriptor)	
end
local function ClearSelectedScripts()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(BSCSF.keybindStripDescriptor)
end

function BSCSF:InitKeyboard()
	AddKeyBind()
	-- Hook main init to catch mouse buttons on list controls
	InitializeRecentScribesList() 
	SetupRemoveFavoriteConfirmDialog()
	SetupAddFavoriteConfirmDialog()
	
	-- Keyboard Only
	ZO_PostHook(SCRIBING_KEYBOARD, "OnDeferredInitialize", InitializeFavorite)
	ZO_PostHook(SCRIBING_KEYBOARD, "RefreshModeBar", RefreshModeBar)
	ZO_PostHook(SCRIBING_KEYBOARD, "SetMode", SetMode)	
	ZO_PostHook(SCRIBING_KEYBOARD, "OnShowing", OnShowing)
	ZO_PostHook(SCRIBING_KEYBOARD, "OnHiding", OnHiding)	
	ZO_PostHook(SCRIBING_KEYBOARD, "SetMouseOverRecentCraftedAbilityEntry", SetMouseOverRecentCraftedAbilityEntry)
	
	
	ZO_PostHook(ZO_Scribing_Shared, "SlotScriptById", ClearSelectedScripts)
	ZO_PostHook(ZO_Scribing_Shared, "ClearSelectedScripts", ClearSelectedScripts)
end