Locker = Locker or {} 
Locker.name = "Locker" 
Locker.bankView=false 
local words = {"lock", "unlock"} 

DIM_RATIO = 0.5012 -- Will let user customize.  Using this number to avoid coincidental clashes with in game ui or other Addons  
local pleaseHold = 0  -- Turns to 1 as user is depositing items into the bank.  

local function C(string,color)  -- Colors text, red by default 
  color = color or "FF0000"
  return ZO_ColorDef:New(color):Colorize(string)
end   
 

local dbg = d  

function CountSet(table)
    
    local count =0 
    
    for i in pairs(table)
        do count = count+1
    end 

    return count 
end     

--function MOC()
--    COUNT=COUNT or 0
--    COUNT=COUNT+1 
--    return moc()
--end     
 
function Locker:LookUp(controlMO) -- toBank)  -- toBank is true only when right clicking to bank something in the future 

  controlMO= controlMO or moc() -- WINDOW_MANAGER:GetMouseOverControl()   
  -- ZO_PlayerInventoryList1Row1, etc (2nd number changes in backpack)
  
  if (not controlMO.dataEntry) or (not controlMO.dataEntry.data)  or (not controlMO.dataEntry.data.slotIndex) then
  --  if not wm.dataEntry then dbg("1")
   -- elseif (not wm.dataEntry) then dbg("2") 
  --  elseif (not wm.dataEntry.data.slotIndex) then dbg("3")
  --  end 
  --  dbg("Invalid target")  
    return  
  end
  

  return controlMO.dataEntry.data.slotIndex ,       controlMO.dataEntry.data.bagId,   controlMO.dataEntry.data.itemInstanceId
end 
  
function Locker:Dimmer(controlMO,toDim)  -- toDim = -1 means make alpha = 1  toDim = 1 means alpha =1   
   
    if (controlMO.dataEntry.data.bagId == BAG_BACKPACK) then   
        if toDim == -1 then --local a= controlMO:GetAlpha()
        --if a==DIM_RATIO then 
       -- d(a)
            controlMO:SetAlpha(1)
    --    d(controlMO:GetAlpha())  ZO_PlayerInventoryList1Row1.dataEntry.data.itemInstanceId
        elseif toDim==1 then 
       -- d(a)
            controlMO:SetAlpha(DIM_RATIO)  -- DIM_RATIO = 0.5, defined above, by default.  Eventually will let user customize this if they don't like it  
     --   d(controlMO:GetAlpha())
        end 
    end   
end 

Locker.Saved={}  -- Table of links of items to be deposited 
Locker.SavedR={}  -- Table of links of items to be withdrawn 
--|H1:item:30357:175:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h
--|H1:item:134583:121:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h
Locker.CanNotbeDeposited = {[ 55448] = true,   -- Undaunted keys Sigil of retreat 
                            [68347] = true,   -- sigil of retreat 
                            [134583] = true,  --  
                            [134588] = true, -- 
}  -- List of items not able to be deposited.  Does zos have a built in check for this?  
-- or GetItemId(bagId,slotIndex) == 68347 then   -- Keys or Sigils of retreat 
   
--|H1:item:134591:124:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h|H1:item:134588:122:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h

function Locker:Save()  --Actived whenever player uses the hotkey to bank something 
 
 
    local controlMO=moc() -- WINDOW_MANAGER:GetMouseOverControl()   
    local flag = 0 -- Will determine if player is already in their bank scene   
    
    if pleaseHold ==1 then 
        
        dbg("Please wait till current deposits complete.")
        return 
    end 
    
    local slotIndex,bagId,itemInstanceId=Locker:LookUp(controlMO)  
   
    local link = GetItemLink(bagId,slotIndex,1)
    
    if (not link) or link == "" then 
        return 
    end 
       
   
   if (bagID ==BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) then 
       Locker.SavedR[slotIndex]= {["link"]=link, ["slotIndex"]=slotIndex, ["itemInstanceId"] = itemInstanceId, ["bagId"]=bagId} 
        dbg(link .. " to be withdrawn (if possible) on next bank trip")
       return 
    end    
   
   
    if (bagID ~=BAG_WORN and bagId ~= BAG_BACKPACK) then 
       return 
    end     


    if  Locker.Saved[slotIndex] and Locker.Saved[slotIndex].itemInstanceId==itemInstanceId then 
        Locker.Saved[slotIndex] = nil   
        dbg("Make up your mind " .. link .. " will " .. C("not") .. " be deposited on next bank trip")
        Locker:Dimmer(controlMO,-1)
    else
        if Locker.Saved[slotIndex] and Locker.Saved[slotIndex].itemInstanceId ~=itemInstanceId then 
            dbg(Locker.Saved[slotIndex].link ..  " seems to have one missing.  Perhaps you deleted it or stacked it with another item.  However " .. link .. " will be deposited in its place.")
        elseif IsItemStolen(bagId,slotIndex) then         
            dbg(link .. " is stolen and, as such, cannot be deposited.")
       
   
    elseif Locker.CanNotbeDeposited[GetItemId(bagId,slotIndex)] then-- == 55448 or GetItemId(bagId,slotIndex) == 68347 then   -- Keys or Sigils of retreat 
            dbg(C(link .. " cannot be deposited in your bank","00FF00"))
        elseif IsItemLinkUnique(link) then 
            dbg(link .. C(" cannot be deposited because it is unique.","00FF00"))
        else 
            Locker.Saved[slotIndex]= {["link"]=link, ["slotIndex"]=slotIndex, ["itemInstanceId"] = itemInstanceId, ["bagId"]=bagId} 
            Locker:Dimmer(controlMO,1)
            if (not DoesBagHaveSpaceFor(BAG_BANK,bagId,slotIndex)) and (not DoesBagHaveSpaceFor(BAG_SUBSCRIBER_BANK,bagId,slotIndex)) then 
                dbg(link .. " to be deposited, but your bank is currently full")

            else  
                 dbg(link .. " to be deposited (if possible) on next bank trip")
            end 
            if Locker.bankView==true then 
                dbg(C("(You are currently at the bank)","00FF00"))
                --Locker:Deposit() -- If player happens to be at bank at the time, will just deposit this item 
                flag = 1
            end
        end     
    end         
    if flag ~=1 then 
        Locker:CompareWithTable(Locker.Saved)
--    else 
        --dbg("Currrently viewing bank")
    end         
end
  
function Locker:CompareWithTable(T)  -- T = Locker.Saved  Assigns the OnTextChanged handler to each row  called only through Locker:Save
  
    if type(T) ~= "table" or CountSet(T)==0 then 
        return 
    end 
  
   -- dbg(T)
  
    for i=1, 13 do 
        local A=GetControl("ZO_PlayerInventoryList1Row", i .. "Name")   -- TODO These 13 controls were defined universally somewhere in the ZOS controls, should find that and use that instead for a more universal definition!  1/14/18 
        if A then 
            A:SetHandler("OnTextChanged", function(self)   -- GetControl("ZO_PlayerInventoryList1Row", i)  
                local sP=self:GetParent() -- 
                local data= sP and sP.dataEntry and sP.dataEntry.data 
                local slotIndex= data and data.slotIndex 
                local itemInstanceId=data and data.itemInstanceId 
                --then 
                --   local slotIndex=sP.dataEntry.data.slotIndex
                --   local itemInstanceId = sP.dataEntry.data.itemInstanceId
                --end 
                if T and T[slotIndex] and itemInstanceId == T[slotIndex].itemInstanceId then 
                    sP:SetAlpha(DIM_RATIO) 
                else 
                    sP:SetAlpha(1) 
                end 
            end) 
        end
    end              
end   
 
function Locker:Deposit()  -- This is the function called by the Event (bank being opened)  
 
    Locker.BadSlots = {} 
    
    if  Locker.bankView==false
        or (not Locker.Saved) 
        or CountSet(Locker.Saved)==0 then
        return
    end 
 
  
    
    function NextSlot(binary)
        
        if binary then 
            return BAG_BACKPACK, FindFirstEmptySlotInBag(BAG_BACKPACK)
        end             
        
        local BAG_TYPE,BAG_NUMBER =BAG_BANK, (FindFirstEmptySlotInBag(BAG_BANK) or math.huge)   -- Dolg suggested not using FindFirstEmptySlotInBag since this ZOS defined function sucks at updating.  Will need to look further into this if this addon gets more steam  1/14/18  
    
        if (FindFirstEmptySlotInBag(BAG_SUBSCRIBER_BANK) or math.huge) < BAG_NUMBER  then -- FindFirstEmptySlotInBag(BAG_BANK)
            BAG_TYPE,BAG_NUMBER= BAG_SUBSCRIBER_BANK, FindFirstEmptySlotInBag(BAG_SUBSCRIBER_BANK)
        --else  bag,number= BAG_BANK, FindFirstEmptySlotInBag(BAG_BANK) 
        end 
        return BAG_TYPE,BAG_NUMBER 
    end 
 
 -- if (not Locker.Saved) or Locker.Saved == {} then 
 --   return
 -- end 
  
    local n=1   
    local nn=0  
    local BAG_BANKTYPE,BAG_BANKNUMBER = NextSlot()
  
 
    
    for _slotIndex,_data in pairs(Locker.Saved) do   
        local _itemInstanceId = _data.itemInstanceId -- GetItemInstanceId(BAG_BACKPACK,_slotIndex)
        local _link  = _data.link  or ""-- GetItemItemLink(BAG_BACKPACK,_slotIndex)
        local _bagId = _data.bagId or 1
    
--    if BAG_NUMBER == math.huge then
--        return dbg(_link .. " could not be deposited because your bank is full.") 
--    end 
    
        pleaseHold=1  -- local var defined at start of addon to be 0 
        if _data.itemInstanceId == GetItemInstanceId(_bagId,_slotIndex) then 
            local count = select(2,GetItemInfo(_bagId, _slotIndex)) -- GetItemLinkStacks(_link)
            nn=nn+1 
      
    --  d(n .. " BT=" .. BAG_TYPE .. " BN=" .. BAG_NUMBER)
            if BAG_BANKNUMBER < math.huge then 
                zo_callLater(function() 
                    CallSecureProtected("RequestMoveItem", _bagId,_slotIndex,BAG_BANKTYPE,BAG_BANKNUMBER,count) 
                    end,nn*1000) 
            else  
                dbg(C(n) .. ". " .. _link .. " and any further items could not be deposited because your bank is full.")  
                pleaeHold=0 
                return 
            end 
            zo_callLater(function() 
                if #GetItemLink(_bagId,_slotIndex) > 0  then 
                    Locker.BadSlots[_slotIndex]=_link 
                   -- dbg(C(n) .. ". " .. _link .. " apparently could" ..  C(" not ") .. "be deposited: item still occupies inventory slot. " .. _slotIndex)
                    n=n+1
                    Locker.Saved[_slotIndex]=nil
                elseif GetItemLink(BAG_BANKTYPE,BAG_BANKNUMBER) =="" then 
                    dbg(C(n) .. ". " .. _link .. " apparently could" ..  C(" not ") ..  "be deposited: no item in targeted bank slot." .. BAG_BANKTYPE .. ":" .. BAG_BANKNUMBER)                    
                    n=n+1
                    Locker.Saved[_slotIndex]=nil
                else 
                    dbg(C(n) .. ". " .. _link.. " appears to be deposited sucessfully.")
                    n=n+1
                    Locker.Saved[_slotIndex]=nil 
                    BAG_BANKTYPE,BAG_BANKNUMBER = NextSlot()
                end
            end,nn*1000+500)
        end        
end  


 -- d(n) 
  --ZO_ClearTable(Locker.Saved) 
  --StackBag(BAG_BACKPACK)
  --StackBag(BAG_BANK)
  --StackBag(BAG_SUBSCRIBER_BANK)
  
  pleaseHold = 0 
    for i=1, 13 do 
        local A=GetControl("ZO_PlayerInventoryList1Row", i) 
        if A and A.SetAlpha then 
            A:SetAlpha(1)
        end 
    end  
    zo_callLater(function() 
        local nnn = 1 
        if CountSet(Locker.Saved) > 0 then 
            dbg("Yet to be deposited:")
            for _slotIndex, _data in pairs(Locker.Saved) do 
                dbg(C(nnn) .. ". " .. _data.link)
                nnn=nnn+1 
            end             
        end 
    end,(nn+1)*1000)
end  



--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------- End of banking functions !  


local functions= { {CanItemBePlayerLocked,IsItemPlayerLocked,SetItemIsPlayerLocked,"Locked"}, {CanItemBeMarkedAsJunk,IsItemJunk,SetItemIsJunk, "Junked"}}


function Locker:MouseOver(i)   -- i = 1 for locking, i=2 for junking 
  
  local slotIndex,bagId= Locker:LookUp(false)  --- false argument indicates the items are not to be dimmed 
  
  if not (slotIndex and bagId) then  -- SetItemIsJunk will junk 0,0 (player's cureen helm) if takes two nil args 
      return 
    end       
  
  if functions[i][1](bagId,slotIndex) then 
    local binary = functions[i][2](bagId,slotIndex)  
    functions[i][3](bagId,slotIndex,not binary)
    local tell=""
    if binary 
      then tell ="un" 
    end 
    dbg(zo_strformat("<<1>> <<2>> <<3>><<4>>", GetItemLink(bagId,slotIndex),"has been ", C(tell), C(functions[i][4])) )
    else dbg(zo_strformat("<<1>> <<2>> <<3>><<4>>", GetItemLink(bagId,slotIndex),"is not ", C(functions[i][4]),"able") )  
  end         
  
end 

Locker.Locked={} 
function Locker.ClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, ...) 
    if linkType == "locker" then
        local args={...}
        local slotIndex=tonumber(args[1])  
--        local binary = tonumber(args[2]) 
        local binary = not IsItemPlayerLocked(BAG_BACKPACK,slotIndex)
       -- dbg(slotIndex, binary)
        SetItemIsPlayerLocked(BAG_BACKPACK,slotIndex, binary)
        local linkT = C(linkText:match("%a+"))
        
        ZO_Tooltips_ShowTextTooltip(ZO_ChatWindow, RIGHT, "Item has been " .. linkT .. "ed")  -- linkT is the text of the link with brackets removed    
        zo_callLater(function() ZO_Tooltips_HideTextTooltip()   end   ,4000)  -- 4 seconds later, hide the popup 
        return true 
    end 
    
    return false 
end
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, Locker.ClickEvent)
function Locker:Search(str,binary)  
  
   local n,nn=0,0   
   -- (binary and "locked") or "unlocked"

   local function S(i)
      return GetItemName(BAG_BACKPACK,i):upper() 
   end    

    if Locker.lockFlag then 
        for _slotIndex in pairs(Locker.Locked) do 
            SetItemIsPlayerLocked(BAG_BACKPACK,_slotIndex, not IsItemPlayerLocked(BAG_BACKPACK,_slotIndex))
        end 
        Locker.Locked[_slotIndex] = nil 
        Locker.lockFlag=false 
    end         

    for _slotIndex = 1, GetBagSize(BAG_BACKPACK) do 
        if #S(_slotIndex) ~=0 and S(_slotIndex):find(str:upper()) then 
            if CanItemBePlayerLocked(BAG_BACKPACK,_slotIndex) then 
                SetItemIsPlayerLocked(BAG_BACKPACK,_slotIndex,(binary==1 and true) or false)
                n=n+1  --|H1:foo:bar:baz|h[Test]|h"
                local redo1 = tostring("|H1:locker:" .. _slotIndex .. ":" .. 3-binary .. "|h[" ..words[3- binary] .. "]|h")
                local redo2 = tostring("|H1:locker:" .. _slotIndex .. ":" .. 3-binary .. "|h[" ..words[binary] .. "]|h")
                dbg("\n" .. redo1 .. "\t\t\t" .. redo2 .. "\n" .. C(n) .. ". " .. GetItemLink(BAG_BACKPACK,_slotIndex) .. " " .. C(words[binary]) .. "ed" .. "\n"  .. C("------------------------------") )                
                Locker.Locked[_slotIndex] = true 
            else 
                nn = nn+1 
                dbg(C(n,"00FF00") .. ". " .. GetItemLink(BAG_BACKPACK,_slotIndex) .. " cannot be locked.")
            end 
        end
        Locker.lockFlag=false 
    end
    --if binary then    
        dbg(n .. " items were "    .. C(words[binary]) .. "ed" )
    --else    
      --0  dbg(n .. " items were "   ..   C("locked")) 
   --end 
   zo_callLater(function() Locker.Locked={} dbg(C("All locks complete","00FF00")) end, 20000)
end 
   
 SLASH_COMMANDS["/locker"]= function(str) 
    str = str or "" 
    if #str ==0 and (not Locker.lockFlag) then 
        dbg("Nothing recieved!  Enter in the form " .. C("/locker " , "FFFFFF") .. C("search term.  " , "0000FF") .. "Retype in the next " ..  C("15", "FFFFFF") .. " seconds to undo previous.")
        Locker.lockFlag=true 
        zo_callLater(function() Locker.lockFlag = flase end, 15000)
        return 
    end     
    Locker:Search(str,1)
 end 


 SLASH_COMMANDS["/unlocker"]= function(str) 
    str = str or "" 
   Locker:Search(str,2) 
 end   
 
  SLASH_COMMANDS["/printlocker"]= function() 
    local n=1 
    for _slotIndex, _data in pairs(Locker.Saved) do 
        dbg(C(n) .. ". " .. _data.link)
        n = n+1 
    end         
 end 
 
 -- EVENT_MANAGER:RegisterForEvent(Locker.name, EVENT_CHAT_MESSAGE_CHANNEL, function(eventCode,channelType,fromName,text,isCustomerService,fromDisplayName) d(channelType) d(text) d(fromName) d(fromDisplayName) end)  
 
  --(number eventCode, MsgChannelType channelType, string fromName, string text, boolean isCustomerService, string fromDisplayName)
 
 EVENT_MANAGER:RegisterForEvent(Locker.name, EVENT_OPEN_BANK, function(eventCode,bankBag) Locker.bankView=true Locker:Deposit() end)  
 
 -- EVENT_MANAGER:RegisterForEvent(Locker.name, EVENT_CLOSE_BANK, function(eventCode,bankBag) Locker.bankView=true Locker:Deposit() end) 
 
 EVENT_MANAGER:RegisterForEvent(Locker.name, EVENT_CLOSE_BANK, function(eventCode) Locker.bankView=false 
    zo_callLater(function()  
        for _slotIndex, _link in pairs(Locker.BadSlots) do 
            if #GetItemLink(BAG_BACKPACK,_slotIndex) >0 and GetItemLink(BAG_BACKPACK,_slotIndex) == _link then
                dbg(C("Warning") .. ". " .. _link .. " apparently could" ..  C(" not ") .. "be deposited: item still occupies inventory slot. " .. _slotIndex)
            else Locker.BadSlots[_slotIndex] = nil         
            end 
        end     
    end, 5000) 
end) 
 
--EVENT_MANAGER:RegisterForEvent(Stoned.name, EVENT_ADD_ON_LOADED, Initialize)   