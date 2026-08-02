local C = Conductor
C.ProviderIndex = C.ProviderIndex or {}
function C.ProviderIndex:Rebuild()
    if C.KnowledgeBase and C.KnowledgeBase.RebuildIndexes then C.KnowledgeBase:RebuildIndexes() end
    self.byEffect = C.KnowledgeBase and C.KnowledgeBase.providersByEffect or {}
    self.effectsByProvider = C.KnowledgeBase and C.KnowledgeBase.effectsByProvider or {}
end
