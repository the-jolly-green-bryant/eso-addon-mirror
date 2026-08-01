



----------------------------------------------------------
--  Remove Loot Item --
-- Release the loot item window back into the control 	--
-- pool and remove its position from my position pool 	--
----------------------------------------------------------
local function RemoveLootItem(_tItemData)
	-- Release the item window from the loot pool
	LootIt.LootPool:ReleaseObject(_tItemData.key)
	-- grab the saved, used, loot positions
	local tPoolTable = LootIt.lootPositionPool
	
	-- find & remove the loot position from the used positions table.
    for k,v in pairs(tPoolTable) do
		if v == _tItemData.position then
			table.remove(LootIt.lootPositionPool, k)
		end
	end
end

----------------------------------------------------------
--  Fade Out  --
----------------------------------------------------------
local function FadeOut(_tItemData) 
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	
	local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, _tItemData.control, LootIt.SavedVariables["ITEMVISIBLETIME"])
	fadeOut:SetAlphaValues(1, 0)
	fadeOut:SetDuration(LootIt.SavedVariables["ITEMFADEDURATION"])
	
	timeline:SetHandler('OnStop',function() 
		-- May want to add a zo_callLater to this, if items start overlapping --
		RemoveLootItem(_tItemData)
		end)
	
	timeline:PlayFromStart()
end

----------------------------------------------------------
--  Translate UP  --
----------------------------------------------------------
local function Translate(_tItemData)    
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = _tItemData.control:GetAnchor()
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	local translate = timeline:InsertAnimation(ANIMATION_TRANSLATE, _tItemData.control, 0)
	
	local iTransOffsetY = offsetY+_tItemData.winYFactor*(_tItemData.windowHeight * (_tItemData.position -1))
	local iTransOffsetX = offsetX+_tItemData.winXFactor*(_tItemData.windowWidth * (_tItemData.position -1))
	
	translate:SetTranslateOffsets(offsetX, offsetY, iTransOffsetX, iTransOffsetY)
	translate:SetDuration(LootIt.SavedVariables["ITEMTRANSLATETIME"])
	translate:SetEasingFunction(ZO_EaseInQuadratic)
	
	timeline:SetHandler('OnStop',function() 
		FadeOut(_tItemData)    
		end)
	  
	timeline:PlayFromStart()
end

----------------------------------------------------------
--  FADE IN  --
----------------------------------------------------------
local function FadeIn(_tItemData)     
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	local iFadeInDelay 	= (LootIt.SavedVariables["ITEMFADEINTIME"])*(_tItemData.lootCounter-1)
	
	local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, _tItemData.control, iFadeInDelay)
	fadeIn:SetAlphaValues(0, 1)
	fadeIn:SetDuration(LootIt.SavedVariables["ITEMFADEINTIME"])
	fadeIn:SetEasingFunction(ZO_EaseOutQuadratic)
	
	-- Start the trasnlating up animation when the fade in stops --
	timeline:SetHandler('OnStop',function() 
		Translate(_tItemData)  
		end)
	
	timeline:PlayFromStart()
end

--------------------------------------------------------------------------------------------------
--  Animate  																					--
-- I could have called LootIt.FadeIn directly, but this is like my initialization function for 	--
-- all animations. I wasn't sure if things would change or if they do in the future.		   	--
-- and Animate is more descriptive to what is happening when it gets called, because really 	--
-- the FadeIn automatically calls the translate up, which automatically calls the fade out.		--
-- So when reading code elsewhere if you just say a function call to FadeIn you may not have 	--
-- really understood everything it is going to do.												--
--------------------------------------------------------------------------------------------------
function LootIt.Animate(_tItemData)
	FadeIn(_tItemData)
end






--******************************************************************************--
--******************************************************************************--
--******************************************************************************--
--[[ For a different animation I'm not implementing yet. Items start offset & translate up/down then slide over into place. But it only works for up/down atm.
--******************************************************************************--
--******************************************************************************--
--------------------------------------------------------------------------------------------------
--  Animate  																					--
-- I could have called LootIt.FadeIn directly, but this is like my initialization function for 	--
-- all animations. I wasn't sure if things would change or if they do in the future.		   	--
-- and Animate is more descriptive to what is happening when it gets called, because really 	--
-- the FadeIn automatically calls the translate up, which automatically calls the fade out.		--
-- So when reading code elsewhere if you just say a function call to FadeIn you may not have 	--
-- really understood everything it is going to do.												--
--------------------------------------------------------------------------------------------------
function LootIt.Animate2(_tItemData)
	LootIt.FadeIn2(_tItemData)
end


function LootIt.FadeIn2(_tItemData)     
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	local iFadeInDelay 	= (LootIt.SavedVariables["ITEMFADEINTIME"]+LootIt.SavedVariables["ITEMTRANSLATETIME"]+LootIt.SavedVariables["ITEMTRANSLATETIME"])*(_tItemData.lootCounter-1)
	if _tItemData.lootCounter ~= 0 then

	end
	
	local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, _tItemData.control, iFadeInDelay)
	fadeIn:SetAlphaValues(0, 1)
	fadeIn:SetDuration(LootIt.SavedVariables["ITEMFADEINTIME"]/2)
	fadeIn:SetEasingFunction(ZO_EaseOutQuadratic)
	
	-- Start the trasnlating up animation when the fade in stops --
	timeline:SetHandler('OnStop',function() 
		LootIt.Translate2(_tItemData)  
		end)
	
	timeline:PlayFromStart()
end


-------------------------------------------------------------------------------------------------
--  Translate UP  --
-------------------------------------------------------------------------------------------------
function LootIt.Translate2(_tItemData)    
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = _tItemData.control:GetAnchor()
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	local translate = timeline:InsertAnimation(ANIMATION_TRANSLATE, _tItemData.control, 0)
	
	local iTransOffsetY = offsetY+_tItemData.winYFactor*(_tItemData.windowHeight * (_tItemData.position -1))
	local iTransOffsetX = offsetX+_tItemData.winXFactor*(_tItemData.windowWidth * (_tItemData.position -1))
	
	translate:SetTranslateOffsets(offsetX, offsetY, iTransOffsetX, iTransOffsetY)
	translate:SetDuration(LootIt.SavedVariables["ITEMTRANSLATETIME"]/_tItemData.position-1)
	translate:SetEasingFunction(ZO_EaseInQuadratic)
	
	timeline:SetHandler('OnStop',function() 
		_tItemData.control:ClearAnchors()
		_tItemData.control:SetAnchor(point, relativeTo, relativePoint, iTransOffsetX, iTransOffsetY)
		LootIt.Translate22(_tItemData)  
		end)
	  
	timeline:PlayFromStart()
end

function LootIt.Translate22(_tItemData)    
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = _tItemData.control:GetAnchor()
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	local translate = timeline:InsertAnimation(ANIMATION_TRANSLATE, _tItemData.control, 0)
	
	local iTransOffsetX = offsetX+200
	
	translate:SetTranslateOffsets(offsetX, offsetY, iTransOffsetX, offsetY)
	translate:SetDuration(LootIt.SavedVariables["ITEMTRANSLATETIME"]/4)
	translate:SetEasingFunction(ZO_EaseInQuadratic)
	
	timeline:SetHandler('OnStop',function() 
		_tItemData.control:ClearAnchors()
		_tItemData.control:SetAnchor(point, relativeTo, relativePoint, iTransOffsetX, offsetY)
		LootIt.FadeOut2(_tItemData)    
		end)
	  
	timeline:PlayFromStart()
end
-------------------------------------------------------------------------------------------------
--  Fade Out  --
-------------------------------------------------------------------------------------------------
function LootIt.FadeOut2(_tItemData) 
	local timeline = ANIMATION_MANAGER:CreateTimeline()
	
	local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, _tItemData.control, LootIt.SavedVariables["ITEMVISIBLETIME"])
	fadeOut:SetAlphaValues(1, 0)
	fadeOut:SetDuration(LootIt.SavedVariables["ITEMFADEDURATION"])
	
	timeline:SetHandler('OnStop',function() 
		-- May want to add a zo_callLater to this, if items start overlapping --
		LootIt.RemoveLootItem(_tItemData)
		end)
	
	timeline:PlayFromStart()
end

-- Release the loot item window back into the control pool and remove its position from my position pool --
function LootIt.RemoveLootItem(_tItemData)
	-- Release the item window from the loot pool
	LootIt.LootPool:ReleaseObject(_tItemData.key)
	-- grab the saved, used, loot positions
	local tPoolTable = LootIt.lootPositionPool
	
	-- find & remove the loot position from the used positions table.
    for k,v in pairs(tPoolTable) do
		if v == _tItemData.position then
			table.remove(LootIt.lootPositionPool, k)
		end
	end
end
--]]

