ZO_PostHook(COLLECTIONS_BOOK, 'InitializeCategories', function()
    ZO_PreHook(COLLECTIONS_BOOK.categoryTree, 'Commit', function(self)
        local children = self.rootNode.children
        if children[1] and children[2] then
            children[1], children[2] = children[2], children[1]
        end
    end)
end)
