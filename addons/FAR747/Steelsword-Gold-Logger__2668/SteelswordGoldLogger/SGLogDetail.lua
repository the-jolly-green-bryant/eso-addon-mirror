SGLogDetail = ZO_Object:Subclass()

function SGLogDetail:New(data)
    local entry = ZO_Object.New(self)
    entry:Init(data)
    return entry
end

function SGLogDetail:Init(data)
    self.name = data.name
    self.date = data.date
    self.udate = data.udate
    self.price = data.price
end

function SGLogDetail:Add(data)
    local minus = true
    if data.isday ~= nil then
        if data.isday then
        minus = false
        end
    end
    if minus then
        self.price = self.price + data.price
    else
        self.price = data.price
    end
    self.date = data.date
    self.udate = data.udate
    self.name = data.name
end