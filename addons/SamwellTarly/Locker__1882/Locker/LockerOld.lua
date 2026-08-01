Locker = Locker or {} 
Locker.name = "Locker" 
Locker.bankView=false 

DIM_RATIO = 0.5012 -- Will let user customize.  Using this number to avoid coincidental clashes with in game ui or other Addons  
local pleaseHold = 0  -- Turns to 1 as user is depositing items into the bank.  

local function C(string,color)  -- Colors text, red by default 
  color = color or "FF0000"
  return ZO_ColorDef:New("FF0000"):Colorize(string)
end   


local dbg = d  
 
function Locker:LookUp()
 
  local controlMO=WINDOW_MANAGER:GetMouseOverControl()
  
  if (not controlMO.dataEntry) or (not controlMO.dataEntry.data)  or (not controlMO.dataEntry.data.slotIndex) then
  --  if not wm.dataEntry then dbg("1")
   -- elseif (not wm.dataEntry) then dbg("2") 
  --  elseif (not wm.dataEntry.data.slotIndex) then dbg("3")
  --  end 
    dbg("Invalid target")  
    return  
  end
  
    if controlMO.dataEntry.data.bagId == BAG_BACKPACK then 
        local a= controlMO:GetAlpha()
        if a==DIM_RATIO then 
       -- d(a)
            controlMO:SetAlpha(1)
    --    d(controlMO:GetAlpha())
        elseif a==1 then 
       -- d(a)
            controlMO:SetAlpha(DIM_RATIO)  -- DIM_RATIO = 0.5, defined above, by default.  Eventually will let user customize this if they don't like it  
     --   d(controlMO:GetAlpha())
        end 
    end 
  return controlMO.dataEntry.data.slotIndex ,       controlMO.dataEntry.data.bagId
end 
  
Locker.Saved={}  -- Table of links of items to be deposited 

function Locker:Save()  --Actived whenever player uses the hotkey 
    
    local flag = 0 -- Will determine if player is already in their bank scene   
    
    if pleaseHold ==1 then 
        dbg("Please wait till current deposits complete.")
        return 
    end 
    
    local slotIndex,bagId=Locker:LookUp()
   
    if (bagID ~=BAG_WORN and bagId ~= BAG_BACKPACK) then 
      return 
    end     
   
    local link = GetItemLink(bagId,slotIndex)
    
    if (not link) or link == "" then 
        return 
    end 
    
    if  Locker.Saved[link] then 
        Locker.Saved[link]= nil  
        dbg("Make up your mind " .. link .. " will not be deposited on next bank trip")
    else 
        Locker.Saved[link]= true dbg(link .. " to be deposited (if possible) on next bank trip")
        if Locker.bankView==true then 
            dbg("Don't be so lazy!  You're already at the bank!")
            --Locker:Deposit() -- If player happens to be at bank at the time, will just deposit this item 
            flag = 1
        end             
    end         
   if flag ~=1 then 
        Locker:CompareWithTable(Locker.Saved)
--    else 
        --dbg("Currrently viewing bank")
    end         
end
  
function Locker:CompareWithTable(T)  -- T = Locker.Saved 
  
    if type(T) ~= "table" or T=={} then return end 
  
   -- dbg(T)
  
    for i=1, 13 do 
        local A=GetControl("ZO_PlayerInventoryList1Row", i .. "Name")   -- TODO These 13 controls were defined universally somewhere in the ZOS controls, should find that and use that instead for a more universal definition!  1/14/18 
        if A then 
            A:SetHandler("OnTextChanged", function(self) 
                local sP=self:GetParent() 
                if sP 
                    and sP.dataEntry 
                    and sP.dataEntry.data 
                    and sP.dataEntry.data.slotIndex 
                    and T
                    and GetItemLink(BAG_BACKPACK,sP.dataEntry.data.slotIndex) 
                    and T[GetItemLink(BAG_BACKPACK,sP.dataEntry.data.slotIndex)]  
                then 
                    sP:SetAlpha(DIM_RATIO) 
                else 
                    sP:SetAlpha(1) 
                end 
            end) 
        end
    end              
end   
 
function Locker:Deposit()  -- This is the function called by the Event 
 
    if  Locker.bankView==false
        or (not Locker.Saved) 
        or Locker.Saved == {} then
        return
    end 
 
  
    
    local function NextSlot()
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
  
 
    
    for _slotIndex = 1, GetBagSize(BAG_BACKPACK) do   
        local _link = GetItemLink(BAG_BACKPACK,_slotIndex)
    
--    if BAG_NUMBER == math.huge then
--        return dbg(_link .. " could not be deposited because your bank is full.") 
--    end 
    
        pleaseHold=1  -- local var defined at start of addon to be 0 
        if Locker.Saved[_link] then 
            local count = GetItemLinkStacks(_link)
            nn=nn+1 
      
    --  d(n .. " BT=" .. BAG_TYPE .. " BN=" .. BAG_NUMBER)
            if BAG_BANKNUMBER < math.huge then 
                zo_callLater(function() 
                    CallSecureProtected("RequestMoveItem", BAG_BACKPACK,_slotIndex,BAG_BANKTYPE,BAG_BANKNUMBER,count) 
                    end,nn*1000) 
            else  
                dbg(C(n) .. ". " .. _link .. " and any further items could not be deposited because your bank is full.")  
                pleaeHold=0 
                return 
            end 
            zo_callLater(function() 
                if GetItemLink(BAG_BACKPACK,_slotIndex) ~= "" then 
                    dbg(C(n) .. ". " .. _link .. " apparently could" ..  C(" not ") .. "be deposited: item still occupies inventory slot. " .. slotIndex)
                    n=n+1
                    Locker.Saved[_link]=false            
                elseif GetItemLink(BAG_BANKTYPE,BAG_BANKNUMBER) =="" then 
                    dbg(C(n) .. ". " .. _link .. " apparently could" ..  C(" not ") ..  "be deposited: no item in targeted bank slot." .. BAG_BANKTYPE .. ":" .. BAG_BANKNUMBER)                    
                    n=n+1
                    Locker.Saved[_link]=false
                else 
                    dbg(C(n) .. ". " .. _link.. " appears to be deposited sucessfully.")
                    n=n+1
                    Locker.Saved[_link]=false 
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
end  



--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------- End of banking functions !  


local functions= { {CanItemBePlayerLocked,IsItemPlayerLocked,SetItemIsPlayerLocked,"Locked"}, {CanItemBeMarkedAsJunk,IsItemJunk,SetItemIsJunk, "Junked"}}


function Locker:MouseOver(i)   -- i = 1 for locking, i=2 for junking 
  
  local slotIndex,bagId= Locker:LookUp() 
  
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

function Locker:Search(str,binary)  

   local n=0 

   local function S(i)
      return GetItemName(BAG_BACKPACK,i):upper() 
   end    

   for _slotIndex = 1, GetBagSize(BAG_BACKPACK) do 
      if S(_slotIndex) ~="" and S(_itemLink):find(str:upper()) then 
        if CanItemBePlayerLocked(BAG_BACKPACK,_slotIndex) then 
          SetItemIsPlayerLocked(BAG_BACKPACK,i,binary)
         n=n+1 
        else dbg(S(_slotIndex) .. " cannot be locked.")
        end 
      end 
  end
   if binary 
      then    dbg(n .. " items were "    .. C("locked") )
      else    dbg(n .. " items were un"   ..   C("locked")) 
   end 

end 

 SLASH_COMMANDS["/locker"]= function(str) 
    str = str or "" 
    Locker:Search(str,true)
 end 


 SLASH_COMMANDS["/unlocker"]= function(str) 
    str = str or "" 
    Locker:Search(str,false)
 end   
 
  SLASH_COMMANDS["/printlocker"]= function() 
    dbg(Locker.Saved)
 end 
 
 -- EVENT_MANAGER:RegisterForEvent(Locker.name, EVENT_CHAT_MESSAGE_CHANNEL, function(eventCode,channelType,fromName,text,isCustomerService,fromDisplayName) d(channelType) d(text) d(fromName) d(fromDisplayName) end)  
 
  --(number eventCode, MsgChannelType channelType, string fromName, string text, boolean isCustomerService, string fromDisplayName)
 
 EVENT_MANAGER:RegisterForEvent(Locker.name, EVENT_OPEN_BANK, function(eventCode,bankBag) Locker.bankView=true Locker:Deposit() end)  
 
 EVENT_MANAGER:RegisterForEvent(Locker.name, EVENT_CLOSE_BANK, function(eventCode) Locker.bankView=false end) 
 
--EVENT_MANAGER:RegisterForEvent(Stoned.name, EVENT_ADD_ON_LOADED, Initialize)   