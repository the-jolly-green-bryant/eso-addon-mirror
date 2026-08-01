

local Timer = FasterTravel.class()

function Timer:init(func,interval)
	local enabled = false
	
	self.Tick = function(self)
	
		zo_callLater(function() 
		
			if enabled == true then 
				func() 
				
					if enabled == true then 
					
						self:Tick()
						
					end
					
				end 
				
			end, interval)
	end
	
	self.Start = function(self)
		if enabled == true then return end 
		enabled = true
		self:Tick()
	end 
	
	self.Stop = function(self)
		if enabled == false then return end 
		enabled = false 
	end

end

FasterTravel.Timer = Timer