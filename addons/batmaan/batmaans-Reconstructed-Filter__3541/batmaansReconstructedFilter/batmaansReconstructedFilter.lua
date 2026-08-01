brf={}

brf.name = "batmaansReconstructedFilter"




local function batmaansReconstructedFilter()
local i = 0
local lines = IIFA_GUI_ListHolder.dataLines
while i < #lines do
if lines[i] then
    if not IsItemLinkReconstructed(lines[i].link) then
        table.remove(lines, i)
    else
        i = i + 1
    end
else
i=i+1
end
end
IIfA:UpdateInventoryScroll()

end




SLASH_COMMANDS["/brf"] = batmaansReconstructedFilter