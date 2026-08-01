local addon = LibMapThemer

local debugPolygon


local function ResetRecordWindow()
   LibMapThemer_Polycode:SetText("")
end

local function ShowRecordWindow()
   LibMapThemer_RecordPolygonWindow:SetHidden(false)
   ResetRecordWindow()
end

local function HideRecordWindow()
   LibMapThemer_RecordPolygonWindow:SetHidden(true)
   ResetRecordWindow()
end

local xNEquals, yNEquals, newLine = "   { xN = ", ", yN = ", ", },\n"
local function AddPointToPolycode(xN, yN)
   local polygonCode = LibMapThemer_Polycode:GetText()
   local mouseXN = string.format("%.04f", xN)
   local mouseYN = string.format("%.04f", yN)
   polygonCode = polygonCode..xNEquals..mouseXN..yNEquals..mouseYN..newLine
   LibMapThemer_Polycode:SetText(polygonCode)
end

--TODO: add customizations
local function AttachDebugToZone(mapId, zoneId) 
   local map, zone

   if (not mapId or not zoneId) then return end

   local theme = addon:GetCurrentTheme()

   if theme then
      map = theme:GetMapById(tonumber(mapId))
   else
      addon:Print("No Theme Detected")
   end

   if map then
      zone = map:GetZoneById(tonumber(zoneId))
   else
      addon:Print("No Map Detected "..mapId)
   end

   if (not zone) then return end
   local blob = zone:GetZoneBlob()
   if (not blob) then return end
   
   addon:Print("Creating DebugPoly for "..zone:GetZoneName()..", mapId: "..zone:GetMapId()..", zoneId: "..zone:GetZoneId())
   
   debugPolygon = blob:GetNamedChild("DebugPoly")
   debugPolygon:AddPoint(0.0, 0.0) debugPolygon:AddPoint(1.0, 0.0)
   debugPolygon:AddPoint(1.0, 1.0) debugPolygon:AddPoint(0.0, 1.0)
   debugPolygon:SetCenterColor(0, 1, 1, 0.3)
   
   debugPolygon:SetHandler("OnMouseUp", function (control, button, upInside)
      if(upInside and button == MOUSE_BUTTON_INDEX_LEFT) then 
         local xN, yN = blob:GetLeft(), blob:GetTop() 
         local widthN, heightN = blob:GetDimensions()
         local mouseXN, mouseYN = addon:GetNormalizeMouse(xN, yN, widthN, heightN)
         AddPointToPolycode(mouseXN, mouseYN)
      end
   end)

   debugPolygon:SetMouseEnabled(true)
   debugPolygon:SetHidden(false)
end

local function DetachDebug()
   if (not debugPolygon) then return end
   debugPolygon:ClearPoints()
   debugPolygon:SetMouseEnabled(false)
   debugPolygon:SetHidden(true)
   debugPolygon = nil
end

local function StartRecord( arg1, arg2 )
   DetachDebug()
   AttachDebugToZone( arg1, arg2 )
   ShowRecordWindow()
end

local function StopRecord()
   DetachDebug()
   HideRecordWindow()
end

addon.IsRecordingPolygon = function (self) return (debugPolygon ~= nil) end

local function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

SLASH_COMMANDS["/start_debugrecord"] = function( arg )
   DetachDebug()
   local args = split(arg)
   addon:Print(args[1].." "..args[2])
   AttachDebugToZone( args[1], args[2] )
   ShowRecordWindow()
end

SLASH_COMMANDS["/stop_debugrecord"] = StopRecord


