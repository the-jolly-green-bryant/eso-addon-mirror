
local MapTab = FasterTravel.class()
FasterTravel.MapTab = MapTab

local Utils = FasterTravel.Utils

function MapTab:init(control)
	self.control = control
	
	local _refreshing = false
	local _isDirty = true 
	
	self.IsDirty = function()
		return _isDirty
	end
	
	self.SetDirty = function()
		_isDirty = true 
	end
	
	self.RefreshIfRequired = function(self,...)
		--df("RefreshIfRequired isDirty=%s refreshing=%s", tostring(_isDirty), tostring(_refreshing))
		if _isDirty == true and _refreshing == false then 
			_refreshing = true -- only allow one refresh at any one time
			self:Refresh(...)
			_isDirty = false
			_refreshing = false
		end 
	end
	
end

function MapTab:AddCategory(categoryId,item)

	local refresh = item.refresh 
	local clicked = item.clicked
	
	item.clicked =  function(data,c) 
							if clicked then 
								clicked(data,c)
							else
								self:SetCategoryHidden(categoryId,not self:IsCategoryHidden(categoryId)) 
							end
						end
	item.refresh =  function(data,c)
							c.label:SetText(data.name) 
							if refresh then
								
								refresh(data,c)
							end
						end
	--item.data = nil 
	local header = Utils.extend(item)
	header.hidden = nil 
	self.control:AddCategory(self.control.list,header,categoryId)
	return header
end

function MapTab:AddCategories(data, tab) -- tab = 0 for Players, 1 for Wayshrines
	local categoryId = 1
	local parentId
	
	local hideRecents = (tab == 1) and not FasterTravel.settings.recentsEnabled 
	local categories = {}
	
	for i,item in ipairs(data) do 
		if i ~= FasterTravel.settings.recentsPosition or not hideRecents then
			categories[i] = self:AddCategory(categoryId,item)
			if #item.data > 0 then
				self.control:AddEntries(self.control.list,item.data,1,categoryId)
				item.categoryId=categoryId
			end
		end
		categoryId = categoryId + 1
	end
	return categories
end

function MapTab:SetCategoryHidden(categoryId,value)
	self.control:SetCategoryHidden(self.control.list,categoryId,value)
end

function MapTab:IsCategoryHidden(categoryId)
	return self.control:GetCategoryHidden(self.control.list,categoryId)
end

function MapTab:ClearControl()
	self.control:Clear(self.control.list)
end

function MapTab:RefreshControl(categories)
	if self.control == nil then return end
	self.control:Refresh(self.control.list)
	if categories == nil then return end
	
	for i,item in ipairs(categories) do
		self.control:SetCategoryHidden(self.control.list,item.categoryId,item.hidden)
	end
	
	self.control:Refresh(self.control.list)
end


function MapTab:Refresh(...)

end

