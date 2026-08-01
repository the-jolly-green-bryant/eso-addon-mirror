local InfoControl = {}

function InfoControl:AddCategory(control,data,categoryId,typeId,parentId)
	if control == nil or data == nil or categoryId == nil then return end
	ZO_ScrollList_AddCategory(control,categoryId,parentId)
	typeId = data.typeId or typeId or 0
	self:AddEntries(control,{data},typeId,parentId)
end

function InfoControl:GetCategoryHidden(control,categoryId)
	if control == nil or categoryId == nil then return true end
	return ZO_ScrollList_GetCategoryHidden(control,categoryId)
end

function InfoControl:SetCategoryHidden(control,categoryId,hidden)
	if control == nil or categoryId == nil or hidden == nil then return end
	if hidden == true then
		ZO_ScrollList_HideCategory(control,categoryId)
	else
		ZO_ScrollList_ShowCategory(control,categoryId)
	end
end

function InfoControl:Clear(...)
	local count = select('#',...)
	local control 
	for i=1,count do
		control = select(i,...)
		ZO_ScrollList_Clear(control)
	end
end

function InfoControl:AddEntries(control,data,typeId,categoryId)
	if control == nil or data == nil then return end
	
	local count = #data

	if count < 1 then return end 
	
	local scrollData = ZO_ScrollList_GetDataList(control)
	
	for i,entry in ipairs(data) do 

		typeId = entry.typeId or typeId or 1
		categoryId = entry.categoryId or categoryId
		scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(typeId, entry,categoryId)

	end
	
	ZO_ScrollList_Commit(control)
end


function InfoControl:Refresh(...)

	local count = select('#',...)
	local control 
	for i=1,count do
		control = select(i,...)
		ZO_ScrollList_RefreshVisible(control)
	end

end

function InfoControl:RowMouseDown(control, button)
    if(button == 1) then
        control.label:SetAnchor(LEFT, nil, LEFT, control.offsetX or 0, 1)
    end
end

function InfoControl:RowMouseUp(control, button, upInside)
    if(button == 1) then
        control.label:SetAnchor(LEFT, nil, LEFT, control.offsetX or 0, 0)
	 end
	 
	if(upInside) then
		local data = ZO_ScrollList_GetData(control)
		if data.clicked then 
			data:clicked(control,button)
			self:RowMouseClicked(control,data,button)
		end
	end

end

function InfoControl:RowMouseClicked(control,data,button)

end

function InfoControl:OnRefreshRow(control,data)

end

function InfoControl:RefreshRow(control,data)

	if data ~= nil and data.refresh ~= nil then 
		data:refresh(control)
	end
	
	control.label:SetHidden(data == nil or (data.hidden ~= nil and data.hidden == true))

	control.RowMouseDown = function(...) self:RowMouseDown(...) end 
	
	control.RowMouseUp = function(...) self:RowMouseUp(...) end
	
	self:OnRefreshRow(control,data)
end

local WorldMapInfoControl = {}

FasterTravel.WorldMapInfoControl = WorldMapInfoControl

function WorldMapInfoControl.Initialise(control)
	for k,v in pairs(InfoControl) do
		control[k] = v
	end
end
