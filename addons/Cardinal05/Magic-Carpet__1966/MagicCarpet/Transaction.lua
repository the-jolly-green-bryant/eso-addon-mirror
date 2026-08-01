------[[ Namespaces ]]------

if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.Transaction then MC.Transaction = ZO_Object:Subclass() end

do
	local a = { }
	MC.Transaction.States = a
	a.Queued = "Queued"
	a.Running = "Running"
	a.Aborted = "Aborted"
	a.Completed = "Completed"
end

------[[ Static Variables ]]------

local NS = "MC_Transaction"
local QUEUE_HANDLE = NS .. "_Queue"
local QUEUE_INTERVAL = 100

local Queue = { }
local NextTransactionId = 1

------[[ Constructors ]]------

function MC.Transaction:New( name, data, processFunc, initFunc, finalFunc )

    local obj = ZO_Object.New( self )

	obj.Id = NextTransactionId
	NextTransactionId = NextTransactionId + 1

	obj.Name = name
	obj.Data = data
	obj.ProcessFunc = processFunc
	obj.InitFunc = initFunc
	obj.FinalFunc = finalFunc
	obj.State = MC.Transaction.States.Queued

	if nil == obj.Id or nil == obj.Name or nil == obj.Data or nil == obj.ProcessFunc then return nil end

	table.insert( Queue, obj )
	EVENT_MANAGER:RegisterForUpdate( QUEUE_HANDLE, QUEUE_INTERVAL, MC.Transaction.ProcessQueue )

    return obj

end


------[[ Static Methods ]]------


function MC.Transaction:IsInstance( obj )

	return getmetatable( obj ) == self

end


function MC.Transaction:Cast( obj )

	if nil == obj or "table" ~= type( obj ) then return end
	setmetatable( obj, self )
	local mt = getmetatable( obj )
	mt.__index = self

end


function MC.Transaction:CastList( list )

	if nil == list or "table" ~= type( list ) then return end

	for index, obj in pairs( list ) do
		if not MC.Transaction:IsInstance( list[index] ) then
			MC.Transaction:Cast( list[index] )
		end
	end

end


function MC.Transaction:Dequeue()

	for index = 1, #Queue do
		if Queue[index] and Queue[index]:GetId() == self:GetId() then
			table.remove( Queue, index )
			return true
		end
	end

	return false

end


function MC.Transaction.ProcessQueue()

	if 0 >= #Queue then return end

	EVENT_MANAGER:UnregisterForUpdate( QUEUE_HANDLE )

	local tran = Queue[1]
	local interval = QUEUE_INTERVAL

	if nil == tran then

		table.remove( Queue, 1 )

	else

		local state = tran:GetState()

		if state == MC.Transaction.States.Queued then

			tran.State = MC.Transaction.States.Running
			tran:Initialize()

		elseif state == MC.Transaction.States.Running then

			local complete, newInterval = tran:Process()
			if complete then tran.State = MC.Transaction.States.Completed end
			if nil ~= newInterval then interval = newInterval end

		elseif state == MC.Transaction.States.Completed then

			tran:Finalize()
			tran:Dequeue()

		else

			tran:Dequeue()

		end

	end

	EVENT_MANAGER:RegisterForUpdate( QUEUE_HANDLE, interval, MC.Transaction.ProcessQueue )

end


------[[ Instance Methods ]]------


function MC.Transaction:GetState()

	return self.State

end


function MC.Transaction:GetId()

	return self.Id

end


function MC.Transaction:GetName()

	return self.Name

end


function MC.Transaction:GetData()

	return self.Data

end


function MC.Transaction:Initialize()

	if self.InitFunc then
		return self:InitFunc()
	end

end


function MC.Transaction:Finalize()

	local returnValue = nil

	if self.FinalFunc then
		 returnValue = self:FinalFunc()
	end

	if self:GetState() == MC.Transaction.States.Running then
		self.State = MC.Transaction.States.Completed
	end

	self:Dequeue()
	return returnValue

end


function MC.Transaction:Process()

	return self:ProcessFunc()

end


function MC.Transaction:Abort( skipFinalize )

	local id = self:GetId()
	local state = self:GetState()

	if state == MC.Transaction.States.Aborted then return end
	self.State = MC.Transaction.States.Aborted

	if state ~= MC.Transaction.States.Queued and not skipFinalize then
		self:Finalize()
	else
		self:Dequeue()
	end

	return self

end
