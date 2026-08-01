function PB.SetTrackerBagHook()
	for k,v in pairs(PLAYER_INVENTORY.inventories) do
    local listView = v.listView
		if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
      ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
        --local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
        --PB.AddSetIndicator(control, control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, itemLink, RIGHT, 1)
			end)
		end
  end
  
  ZO_PreHook(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)
    --local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
    --PB.AddSetIndicator(control, control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, itemLink, RIGHT, 1)
  end)
end

local selectedItem = {
  bagID = -1,
  slotIndex = -1,
  setName = "",
  control = nil
}

function PB.UpdateInventories()
  for k,v in pairs(PLAYER_INVENTORY.inventories) do
    PLAYER_INVENTORY:UpdateList(k)
  end
end

local TrashKeyBinding = {
	{
		name = "Full/Set Not Trash",
		keybind = "UI_SHORTCUT_PRIMARY",
    callback = function()
      PB.db.setData.setOverrides[selectedItem.setName] = {
        isTrash = false
      }
      PB.UpdateInventories()
    end,
	},
	--{
	--	name = "Type/Set Not Trash",
	--	keybind = "UI_SHORTCUT_SECONDARY",
	--	callback = function() MyDoSomethingElse() end,
	--},
	alignment = KEYBIND_STRIP_ALIGN_RIGHT,
}

local SetKeyBinding = {
	{
		name = "Full/Set Trash",
		keybind = "UI_SHORTCUT_PRIMARY",
    callback = function()
      PB.db.setData.setOverrides[selectedItem.setName] = {
        isTrash = true
      }
      PB.UpdateInventories()
    end,
	},
	--{
	--	name = "Type/Set Trash",
	--	keybind = "UI_SHORTCUT_SECONDARY",
	--	callback = function() MyDoSomethingElse() end,
	--},
	alignment = KEYBIND_STRIP_ALIGN_RIGHT,
}

local OverrideKeyBinding = {
	{
		name = "Remove Rule",
		keybind = "UI_SHORTCUT_PRIMARY",
    callback = function()
      PB.db.setData.setOverrides[selectedItem.setName] = nil
      PB.UpdateInventories()
    end,
	},
	--{
	--	name = "Edit Rule",
	--	keybind = "UI_SHORTCUT_SECONDARY",
	--	callback = function() MyDoSomethingElse() end,
	--},
	alignment = KEYBIND_STRIP_ALIGN_RIGHT,
}

--            <Label name="$(parent)Name" width="200" height="25" font="ZoFontGameLargeBold" inheritAlpha="true" color="EFEFEF"
--wrapMode="TRUNCATE" verticalAlignment="TOP" horizontalAlignment="LEFT" text="Recruitment Leader Boards">
--<Anchor point="TOP" relativeTo="$(parent)" relativePoint="TOP" offsetX="150" />
--</Label>

function PB.AddSetIndicator(control, bagID, slotIndex, itemLink, relativePoint, opt)
	local function CreateSetSetTrackerControl(parent)
		local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. 'SetSetTrackerControl', parent, CT_TEXTURE)
		control:SetDrawTier(DT_HIGH)
		control:SetHidden(true)
		return control
  end
  
  -- functions to manipulate tooltips for icons
	local function AddIconTooltips(control, linkType, text, setName)
    control:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, TOP, text)
      selectedItem.bagID = bagID
      selectedItem.slotIndex = slotIndex
      selectedItem.setName = setName
      selectedItem.control = control
      if( linkType == "trash" and PB.db.setData.setOverrides[setName] == nil ) then
        KEYBIND_STRIP:AddKeybindButtonGroup(TrashKeyBinding)
      elseif( linkType == "set" and PB.db.setData.setOverrides[setName] == nil ) then
        KEYBIND_STRIP:AddKeybindButtonGroup(SetKeyBinding)
      elseif( PB.db.setData.setOverrides[setName] ~= nil ) then
        KEYBIND_STRIP:AddKeybindButtonGroup(OverrideKeyBinding)
      end
    end)
    control:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
      selectedItem.bagID = -1
      selectedItem.slotIndex = -1
      selectedItem.setName = ""
      selectedItem.control = nil
      if( linkType == "trash" and PB.db.setData.setOverrides[setName] == nil ) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(TrashKeyBinding)
      elseif( linkType == "set" and PB.db.setData.setOverrides[setName] == nil ) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(SetKeyBinding)
      elseif( PB.db.setData.setOverrides[setName] ~= nil ) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(OverrideKeyBinding)
      end
    end)
  end
  local function RemoveIconTooltips(control)
    control:SetHandler("OnMouseEnter", nil)
    control:SetHandler("OnMouseExit", nil)
  end
  local function HandleTooltips(control, linkType, text, setName)
    control:SetMouseEnabled(true)
    AddIconTooltips(control, linkType, text, setName)
  end
  local function SetInventoryIcon(control, linkType, icontext, setName)
    control:SetDimensions(32, 32)
    if( PB.db.setData.setOverrides[setName] ) then
      control:SetTexture("/PB/assets/" .. linkType .. "-override.dds")
    else
      control:SetTexture("/PB/assets/" .. linkType .. ".dds")
    end
    control:SetHidden(PB.db.setOptions.core.disabled)
    HandleTooltips(control, linkType, icontext, setName)
  end



  local SetTrackerControl = control:GetNamedChild('SetSetTrackerControl')
	if not SetTrackerControl then SetTrackerControl = CreateSetSetTrackerControl(control) end
  SetTrackerControl:SetHidden(true)

  local IsGridViewEnabled = false
  if ( control.isGrid or ( control:GetWidth() - control:GetHeight() < 5 ) ) then
		IsGridViewEnabled = true else IsGridViewEnabled = false
	end
  
  local itemType = GetItemLinkItemType(itemLink)
  --local itemId = GetItemIdFromLink(itemLink)
  if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
    local name = GetItemName( bagID, slotIndex )
    local level = GetItemRequiredLevel( bagID, slotIndex )
    local champLevel = GetItemRequiredChampionPoints( bagID, slotIndex )
    local linkName = ""
    local linkText = ""
    local setData = {}
    local hasSet, setName = GetItemLinkSetInfo( itemLink, false )
    local creator = GetItemCreatorName( bagID, slotIndex )
    if creator == nil or creator == "" then
      if level < 50 or champLevel < 160 then
        if hasSet and PB.db.setOptions.core.junkLowLevel then
          linkName = "junk"
          linkText = "|cff0000Junk|r\nBelow CP160"
        elseif hasSet and PB.db.setOptions.core.junkLowLevel == false then
          linkName, linkText = PB.CheckSetDatabase( setName, PB.NormaliseEquipType( itemType, bagID, slotIndex, itemLink ) )
        elseif hasSet == false and PB.db.setOptions.core.junkNonSets then
          linkName = "junk"
          linkText = "|cff0000Junk|r\nNot in a set"
        end
      else
        if hasSet then
          linkName, linkText = PB.CheckSetDatabase( setName, PB.NormaliseEquipType( itemType, bagID, slotIndex, itemLink ) )
        elseif hasSet == false and PB.db.setOptions.core.junkNonSets then
          linkName = "junk"
          linkText = "|cff0000Junk|r\nNot in a set"
        end
      end
    else
      linkName = "crafted"
      if hasSet then
        _, linkText = PB.CheckSetDatabase( setName, PB.NormaliseEquipType( itemType, bagID, slotIndex, itemLink ), true )
      else
        linkText = "|c4444ffCrafted|"
      end

      linkText = "|c4444ffCrafted|r\n" .. linkText
    end
    
    if linkName ~= "" and linkName ~= nil then
      -- handle positioning icons from saved variables
      local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
      SetTrackerControl:ClearAnchors()
      SetTrackerControl:SetAnchor(LEFT, controlName, relativePoint, 9, 0)
      SetInventoryIcon(SetTrackerControl, linkName, linkText, setName )
    end

    --d( name .. " " .. level .. " " .. champLevel )
  end
  --d( itemType )
end

function PB.EquipmentTooltip()

end

function PB.DecribeSet( env, role, knownBuilds, traits )
  if env == "Research" or env == "Utility" then
    return {
      env = env,
      purpose = stat
    }
  else
    return {
      env = env,
      role = role,
      stat = stat,
      class = class,
      knownBuilds = knownBuilds,
      traits = traits
    }
  end
end

function PB.NormaliseTrait( apiTrait )

end

function inTable(tbl, item)
  for key, value in pairs(tbl) do
    if value == item then return true end
  end
  return false
end

function PB.NormaliseWeight( items )
  if( inTable( items, "Light Armor" ) and not inTable( items, "Medium Armor" ) and not inTable( items, "Heavy Armor" ) ) then
    return "Light"
  elseif( not inTable( items, "Light Armor" ) and inTable( items, "Medium Armor" ) and not inTable( items, "Heavy Armor" ) ) then
    return "Medium"
  elseif( not inTable( items, "Light Armor" ) and not inTable( items, "Medium Armor" ) and inTable( items, "Heavy Armor" ) ) then
    return "Heavy"
  elseif( not inTable( items, "Light Armor" ) and not inTable( items, "Medium Armor" ) and not inTable( items, "Heavy Armor" ) ) then
    return "None"
  else
    return "All"
  end
end

function PB.NormaliseBuild( build )

end

function PB.EquipmentText( setData, ignoreTrash )
  local text = ""
  if( setData["isTrash"] and ignoreTrash == false ) or ( #setData.guides > 0 and #setData.builds == 0 and PB.db.setOptions.core.trashGuides ) then
    text = "|cff0000Trash|r\n"
  end

  text = text .. "|c55ffffTypes|r: " .. setData["type"] .. "\n"
  text = text .. "|c55ffffWeight|r: " .. PB.NormaliseWeight( setData["items"] ) .. "\n"
  text = text .. "|c55ffffLocations|r:\n" .. table.concat( setData["locations"], "\n" )

  if #setData.builds > 0 then
    text = text .. "\n|c55ffffBuild Types|r:"
    local insertTypes = {}
    for b=1,#setData.builds do
      local nextType = PB.enums.envNames[setData.builds[b].environment] .. " "
      .. PB.enums.buildTypeName[setData.builds[b].role]
      if inTable( insertTypes, nextType ) == false then
        insertTypes[#insertTypes + 1] = nextType
        text = text .. "\n"
        .. nextType
      end
    end
  end
  if #setData.guides > 0 then
    text = text .. "\n|cffff55Guided|r"
  end
  if PB.db.setOptions.core.showBuilds and #setData.builds > 0 then
    text = text .. "\n|c55ffffBuilds|r:"
    for b=1,#setData.builds do
      text = text .. "\n"
      .. setData.builds[b].name .. " "
      .. PB.enums.classesNames[setData.builds[b].class]
    end
  end
  -- text = text .. "|c55ffffTypes|r: " .. setData["itemTypesText"]
  -- text = text .. "\n" .. "|c55ffffLocation|r: " .. setData["location"]

  return text
end

function PB.GetMergedSetItem( setName )
  if PB.setDb[setName] ~= nil then
    local setItem = {}
    for k,v in pairs(PB.setDb[setName]) do
      setItem[k] = v
    end
    if( PB.db.setData.setOverrides[setName] ~= nil ) then
      if( PB.db.setData.setOverrides[setName]["isTrash"] ~= nil ) then
        setItem["isTrash"] = PB.db.setData.setOverrides[setName]["isTrash"]
      end
    end

    return setItem
  else
    return nil
  end
end

function PB.BuildsOfValue( builds, value, type )

end

function PB.BuildSetTrashOverride( setData )
  if #setData.builds == 0 then
    return PB.db.setOptions.core.trashGuides
  end

  local loops = {
    ["environment"] = { "pve", "pvp" },
    ["role"] = { "tank", "heal", "mag", "stam", "support", "other" },
    ["class"] = { "dk", "blade", "sorc", "den", "cro", "plar", "wolf", "vamp" },
  }

  for type, options in pairs(loops) do
    if PB.db.setOptions[type].disabled == false then
      local types = {}
      for b=1,#setData.builds do
        local value = setData.builds[b][type]
        for o=1,#options do
          local option = options[o]
          if value == PB.enums[type][option] then
            if inTable( types, value ) == false and PB.db.setOptions[type][option] == true then
              types[#types + 1] = value
            end
          end
        end
      end
      if #types == 0 then
        return true
      end
    end
  end
  return false
end

function PB.IsOverride( setName )
  return PB.db.setData.setOverrides[setName] ~= nil
end

function PB.CheckSetDatabase( setName, itemType, ignoreTrash )
  
  if ignoreTrash == nil then
    ignoreTrash = false
  end

  local setItem = PB.GetMergedSetItem( setName )

  if setItem ~= nil and ( setItem["isTrash"] or ( PB.IsOverride( setName ) == false and PB.BuildSetTrashOverride( setItem ) ) ) then
    return "trash", PB.EquipmentText( setItem, ignoreTrash )
  elseif setItem ~= nil then
    --d( "is a build" )
    if itemType.type == PB.enums.itemType.weapon and ignoreTrash == false then
      --d( "is weapon not ignored" )

      --Basic logic here -- Shilds are only for tank builds
      --Bows are only for stam dps
      --Melee weapons are only for dps classes
      --Staffs are only for magic users unless resto then ok for tanks
      return "set", PB.EquipmentText( setItem, ignoreTrash )
    else
      --d( "is set returning" )
      return "set", PB.EquipmentText( setItem, ignoreTrash )
    end
  else
    return "unknown", "|cffff00Unknown Set|r"
  end
end

function PB.NormaliseEquipType( itemType, bagID, slotIndex, itemLink )
  if itemType == ITEMTYPE_ARMOR then
    local equipType = GetItemLinkEquipType( itemLink )
    if equipType == EQUIP_TYPE_CHEST then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.chest }
    elseif equipType == EQUIP_TYPE_FEET then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.feet }
    elseif equipType == EQUIP_TYPE_HAND then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.hands }
    elseif equipType == EQUIP_TYPE_HEAD then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.head }
    elseif equipType == EQUIP_TYPE_LEGS then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.legs }
    elseif equipType == EQUIP_TYPE_NECK then
      return { type = PB.enums.itemType.jewelry, subType = PB.enums.jewelry.neck }
    elseif equipType == EQUIP_TYPE_OFF_HAND then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.shield }
    elseif equipType == EQUIP_TYPE_RING then
      return { type = PB.enums.itemType.jewelry, subType = PB.enums.jewelry.ring }
    elseif equipType == EQUIP_TYPE_SHOULDERS then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.shoulder }
    elseif equipType == EQUIP_TYPE_WAIST then
      return { type = PB.enums.itemType.armor, subType = PB.enums.armor.belt }
    end
  elseif itemType == ITEMTYPE_WEAPON then
    local weaponType = GetItemWeaponType( bagID, slotIndex )
    if weaponType == WEAPONTYPE_TWO_HANDED_AXE then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.axeTwoHand }
    elseif weaponType == WEAPONTYPE_AXE then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.axe }
    elseif weaponType == WEAPONTYPE_BOW then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.bow }
    elseif weaponType == WEAPONTYPE_DAGGER then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.dagger }
    elseif weaponType == WEAPONTYPE_FIRE_STAFF then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.fireStaff }
    elseif weaponType == WEAPONTYPE_FROST_STAFF then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.iceStaff }
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.lightningStaff }
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.healingStaff }
    elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.hammerTwoHand }
    elseif weaponType == WEAPONTYPE_HAMMER then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.hammer }
    elseif weaponType == WEAPONTYPE_SHIELD then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.armor.shield }
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.swordTwoHand }
    elseif weaponType == WEAPONTYPE_SWORD then
      return { type = PB.enums.itemType.weapon, subType = PB.enums.weapons.sword }
    end
  end
  
end