V.Titles = {
    list = {},
    globalTitle = 92,

    Add = function(self, name, k, t)
        if not self.list[name] then self.list[name] = {} end
        if k == self.globalTitle and self.list[name][k] then return
        elseif k == "global" then  k = self.globalTitle end 
        _, oT = GetAchievementRewardTitle(k)
        self.list[name][k] = { title = t, og = oT }
    end,

    Get = function(self, name) 
        return self.list[name]
     end,

    GetTitle = function(self, name, k)
        p = self:Get(name)
        if p and p[k] then return p[k].title
        else return nil end
    end,

    GetTitleByTitleName = function(self, name, t)
        p = self:Get(name)
        if p and type(p) == "table" then
            for k, v in pairs(p) do
                if v.og == t then
                    return v.title
                end
            end
        end
        return nil
    end,
    
    GetGlobalTitle = function(self, name)
        return self:GetTitle(name, self.globalTitle)
    end,
}