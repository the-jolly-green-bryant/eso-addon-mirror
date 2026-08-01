--[[
Author: Jarth
Filename: Fragment.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function base:UpdateFragments(fragmentType)
	base:Debug("UpdateFragments", fragmentType)

	for _, category in pairs(base.Categories) do
		if category.Saved.Enabled then
			base:UpdateFragment(category, fragmentType)
		end
	end

	base:UpdateFragment(base.Global.Combine, fragmentType)
end

function base:UpdateFragment(category, fragmentType)
	base:Debug("UpdateFragment", category, fragmentType)

	local currentScene = SCENE_MANAGER:GetCurrentScene()
	local isHidden = (currentScene == nil or currentScene:GetName() == "empty") and not base.Saved.Scene.OnHud

	if category.Fragment == nil then
		category.Fragment = ZO_HUDFadeSceneFragment:New(category.Frames.Frame)
	end

	for _, scene in ipairs(base.Global.Scenes) do
		if (not fragmentType or scene.Name == fragmentType) and scene ~= nil and scene.Instance ~= nil then
			if base.Saved.Scene[scene.Name] then
				if not scene.Instance:HasFragment(category.Fragment) then
					scene.Instance:AddFragment(category.Fragment)
				end
			else
				scene.Instance:RemoveFragment(category.Fragment)
			end
		end

		if scene.Instance == currentScene then
			isHidden = isHidden or not base.Saved.Scene[scene.Name]
		end
	end

	category.Frames.Frame:SetHidden(isHidden)
end

function base:RemoveFragments(category)
	base:Debug("RemoveFragments", category)

	if category.Fragment ~= nil then
		for _, scene in ipairs(base.Global.Scenes) do
			if scene ~= nil and scene.Instance ~= nil then
				scene.Instance:RemoveFragment(category.Fragment)
			end
		end
	end
end
