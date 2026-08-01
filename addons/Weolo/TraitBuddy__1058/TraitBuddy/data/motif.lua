local sf = string.format
local zo_str = zo_strformat

TB_Data_Motif = TB_Data_Motif or {}
TB_Data_Motif.__index = TB_Data_Motif

local function GetCrownTestName()
	local id = 96954 -- Crown Crafting Motif 46: Frostcaster Style
	local link = GetItemLinkName(ZO_LinkHandler_CreateLink("Crown Motif",nil,ITEM_LINK_TYPE,id,ITEM_FUNCTIONAL_QUALITY_LEGENDARY+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
	local linkName = sf("%s", link)
	--local linkName = sf("%s", link)
	local found, findStart, findEnd = zo_plainstrfind(linkName, " 46: ")
	if found then
		return zo_strsub(linkName, 1, findStart):lower()
	end
end

local crownTestName = GetCrownTestName()

local crownStoreOnlyMotifs = {
	[43] = true,  -- Grim Harlequin
	[46] = true,  -- Frostcaster
	[53] = true,  -- Tsaesci
	[129] = true, -- Hircine Bloodhunter
}

TB_Data_Motif = ZO_Object:Subclass()
function TB_Data_Motif:New(test, itemStyleId, achievementId, collectibleId, id, quality, hasChapters)
	local o = ZO_Object.New(self)
	o._test = test
	o._id = id -- itemId
	if itemStyleId == 108 then
		-- Ancestral Akaviri does not have an all in one motif, or a crown store motif
		o._id = nil
		id = id - 1
	end
	o._quality = quality or ITEM_FUNCTIONAL_QUALITY_ARTIFACT
	o._itemStyleId = itemStyleId
	o._achievementId = achievementId -- Four motifs this is nil. Grim Harlequin, Frostcaster, Tsaesci, Hircine Bloodhunter
	o._collectibleId = collectibleId
	o._hasChapters = true
	if hasChapters == false then o._hasChapters = false end
	if o._hasChapters then
		o._chapters = {}
		for i = 1, 14 do
			o._chapters[i] = id + i
		end
	end
	o._materialId = nil
	o._materialIcon = nil
	o._order = nil
	o._issues = {}
	return o
end

function TB_Data_Motif:TestName()
	return self._test:lower()
end

function TB_Data_Motif:Id()
	return self._id
end

function TB_Data_Motif:Quality()
	return self._quality
end

function TB_Data_Motif:ItemStyleId()
	return self._itemStyleId
end

function TB_Data_Motif:AchievementId()
	return self._achievementId
end

function TB_Data_Motif:HasAchievement()
	return self._achievementId and true
end

function TB_Data_Motif:IsAchievementChapterKnown(chapter)
	if self:HasAchievement() and self:HasChapters() then
		local _, numCompleted, numRequired = GetAchievementCriterion(self._achievementId, chapter)
		return (numCompleted == numRequired)
	else
		return false
	end
end

function TB_Data_Motif:IsLoreBookChapterKnown(chapter)
	if self:HasAchievement() and self:HasChapters() then
		local categoryIndex, collectionIndex = GetLoreBookCollectionIndicesFromCollectionId(GetAchievementLinkedBookCollectionId(self._achievementId))
		local _, _, known, _ = GetLoreBookInfo(categoryIndex, collectionIndex, chapter) -- title, icon, known, bookId
		return known
	else
		return false
	end
end

function TB_Data_Motif:CollectibleId()
	return self._collectibleId
end

function TB_Data_Motif:CollectibleIcon()
	return GetCollectibleIcon(self._collectibleId)
end

function TB_Data_Motif:CollectibleDescription()
	return GetCollectibleDescription(self._collectibleId)
end

function TB_Data_Motif:HasChapters()
	return self._hasChapters
end

function TB_Data_Motif:Chapters(order)
	return self._chapters
end

function TB_Data_Motif:ChapterId(order)
	return self._chapters[order]
end

function TB_Data_Motif:IsCrownStoreOnly()
	-- Check explicit list first (most reliable)
	if crownStoreOnlyMotifs[self._order] then
		return true
	end
	
	-- Fallback to link name detection for older motifs
	local linkName = self:LinkName()
	if linkName == nil then return false end
	local found, findStart, findEnd = zo_plainstrfind(linkName:lower(), crownTestName)
	return found
end

function TB_Data_Motif:SetMaterial(id, icon)
	self._materialId = id
	self._materialIcon = icon
end

function TB_Data_Motif:MaterialId()
	return self._materialId
end

function TB_Data_Motif:MaterialIcon()
	return self._materialIcon
end

function TB_Data_Motif:MaterialLink()
	-- return ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,self._materialId,30,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	return ZO_LinkHandler_CreateChatLink(GetItemStyleMaterialLink, self._itemStyleId)
end

function TB_Data_Motif:Link()
	if self._id == nil then
		return nil
	else
		return ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,self._id,self._quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	end
end

function TB_Data_Motif:LinkNameFromAchievement()
	-- Where there is no learn all motif book, or a crown store motif book, make up a link name based off the achievement
	if self:HasAchievement() and self:HasChapters() then
		local achievementName = GetAchievementName(self._achievementId)
		local linkName = self:ChapterLinkName(1)
		local found, findStart, findEnd = zo_plainstrfind(linkName, ": ")
		if found then
			return sf("%s%s", zo_strsub(linkName, 1, findEnd-1), achievementName)
		end
	end
	return nil
end

function TB_Data_Motif:LinkName()
	local link = self:Link();
	if link then
		return zo_str("<<1>>", GetItemLinkName(link))
	else
		return self:LinkNameFromAchievement()
	end
end

function TB_Data_Motif:SimpleLinkName()
	local linkName = self:LinkName()
	if linkName ~= nil then
		local found, findStart, findEnd = zo_plainstrfind(linkName, ": ")
		if found then
			linkName = sf("%d%s", self._order, zo_strsub(linkName, findStart))
		end
	end
	return linkName
end

local function GetName(link)
	return zo_str("<<1>>", GetItemLinkName(link))
end

function TB_Data_Motif:ChapterLink(order)
	local chapterId = self._chapters[order]
	local link = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,chapterId,self._quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	return ZO_LinkHandler_CreateLink(GetName(link),nil,ITEM_LINK_TYPE,chapterId,self._quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
end

function TB_Data_Motif:ChapterLinkName(order)
	local chapterId = self._chapters[order]
	local link = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,chapterId,self._quality+1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	return GetName(link)
end

function TB_Data_Motif:SimpleChapterLinkName(order)
	local linkName = self:ChapterLinkName(order)
	local found, findStart, findEnd = zo_plainstrfind(linkName, ": ")
	if found then
		linkName = zo_strsub(linkName, findEnd)
	end
	return linkName
end

function TB_Data_Motif:AchievementLink()
	return ZO_LinkHandler_CreateChatLink(GetAchievementLink, self._achievementId)
end

function TB_Data_Motif:LoreBookChapterLink(chapter)
	if self:HasAchievement() and self:HasChapters() then
		local categoryIndex, collectionIndex = GetLoreBookCollectionIndicesFromCollectionId(GetAchievementLinkedBookCollectionId(self._achievementId))
		return ZO_LinkHandler_CreateChatLink(GetLoreBookLink, categoryIndex, collectionIndex, chapter)
	end
end

function TB_Data_Motif:Order()
	-- Could also be named 'motif number'
	return self._order
end

function TB_Data_Motif:SetOrder(order)
	self._order = order
end

function TB_Data_Motif:AddIssue(msg)
	self._issues[#self._issues+1] = msg
end
function TB_Data_Motif:Issues()
	return self._issues
end
function TB_Data_Motif:NumberOfIssues()
	return #self._issues
end
function TB_Data_Motif:HasIssues()
	return (#self._issues>0)
end
function TB_Data_Motif:Check()
	-- Check as many of the properties of the motif as I can
	local motifTest = self:TestName()

	-- Check order
	if not self._order then self:AddIssue("[order]: Missing") end

	-- Check itemStyleId
	if not self._itemStyleId then self:AddIssue("[itemStyleId]: Missing") end

	-- Don't do the other checks until the above is okay
	if self:HasIssues() then return end

	-- Always call the IsCrownStoreOnly() code
	local crownStoreOnly = self:IsCrownStoreOnly()

	-- Check motif name
	local linkName = self:LinkName()
	if not linkName then
		self:AddIssue("[LinkName]: Missing")
	else
		if linkName:len()==0 then
			self:AddIssue("[LinkName]: Missing, length is zero")
		else
			-- Crafting Motif 21: Ancient Orc Style
			local nameCheck = sf("crafting motif %d: %s style", self._order, motifTest)
			if crownStoreOnly then nameCheck = sf("crown %s", nameCheck) end
			if self._id == nil then nameCheck = sf("%s master", nameCheck) end
			if linkName:lower() ~= nameCheck then
				self:AddIssue(sf("[LinkName]: Correct '%s'", linkName))
				self:AddIssue(sf("[LinkName]: Checked '%s'", nameCheck))
			end
		end
	end
	local simpleLinkName = self:SimpleLinkName()
	if not simpleLinkName then
		self:AddIssue("[SimpleLinkName]: Missing")
	else
		if simpleLinkName:len()==0 then
			self:AddIssue("[SimpleLinkName]: Missing, length is zero")
		end
	end

	-- Check achievementId
	if (not self._achievementId) and (not crownStoreOnly) then self:AddIssue("[achievementId]: Missing") end
	if self._achievementId then
		-- Check achievment name
		local name = GetAchievementInfo(self._achievementId)
		name = name:lower()
		local nameTest = motifTest
		local nameCheck = ""
		if self._order >= 1 and self._order <= 9 then
			nameCheck = "alliance style master"
		elseif self._order >= 10 and self._order <= 14 then
			nameCheck = "rare style master"
		elseif self._order == 40 then
			nameCheck = "order of the hour style master"
		elseif self._order == 42 then
			nameCheck = sf("happy work for %s", motifTest)
		elseif self._order == 78 then
			nameCheck = "moongrave style master"
		elseif self._order == 107 then
			nameCheck = "annihilarch's style master"
		else
			nameCheck = sf("%s style master", motifTest)
		end
		if name ~= nameCheck then
			self:AddIssue(sf("[achievementId]: Correct '%s'", name))
			self:AddIssue(sf("[achievementId]: Name checked '%s'", nameCheck))
		end
	end
	
	-- Check collectible
	if not self._collectibleId then self:AddIssue("[collectibleId]: Missing") end
	local collectibleIcon = self:CollectibleIcon()
	if not collectibleIcon then
		self:AddIssue("[collectibleIcon]: Missing")
	else
		if collectibleIcon:len()==0 then self:AddIssue("[collectibleIcon]: Missing, length is zero") end
	end
	local collectibleDescription = self:CollectibleDescription():lower()
	if not collectibleDescription then
		self:AddIssue("[collectibleDescription]: Missing")
	else
		if collectibleDescription:len()==0 then
			self:AddIssue("[collectibleDescription]: Missing, length is zero")
		else
			local name = motifTest
			if self._order == 40 then name = "order of the hour" end
			if self._order == 61 then name = sf("%s order", motifTest) end
			if self._order == 71 then name = sf("%s goblin", motifTest) end
			-- Crafting Style, Style, or Motif
			local found = zo_plainstrfind(collectibleDescription, sf("%s crafting style", name))
			if not found then
				found = zo_plainstrfind(collectibleDescription, sf("%s motif", name))
				if not found then
					found = zo_plainstrfind(collectibleDescription, sf("%s style", name))
					if not found then
						self:AddIssue(sf("[collectibleDescription]: Does not contain %s crafting style, style, or motif", name))
					end
				end
			end
		end
	end

	-- Check material
	if not self._materialId then self:AddIssue("[materialId]: Missing") end
	if not self._materialIcon then self:AddIssue("[materialIcon]: Missing") end
	-- Check material description?

	if self._hasChapters then
		local types = {"axes", "belts", "boots", "bows", "chests", "daggers", "gloves", "helmets", "legs", "maces", "shields", "shoulders", "staves", "swords"}
		for i,type in pairs(types) do
			local linkName = self:ChapterLinkName(i):lower()
			if not linkName then
				self:AddIssue(sf("[Chapter %d linkName]: Missing", i))
			else
				if linkName:len()==0 then
					self:AddIssue(sf("[Chapter %d linkName]: Missing, length is zero", i))
				else
					-- Crafting Motif 21: Ancient Orc Axes
					if self._order == 59 and type == "shoulders" then type = "cops" end -- Scalecaller
					local nameCheck = sf("crafting motif %d: %s %s", self._order, motifTest, type)
					if linkName ~= nameCheck then
						self:AddIssue(sf("[Chapter %d linkName]: Correct '%s'", i, linkName))
						self:AddIssue(sf("[Chapter %d linkName]: Checked '%s'", i, nameCheck))
					end
				end
			end
		end
	end
end