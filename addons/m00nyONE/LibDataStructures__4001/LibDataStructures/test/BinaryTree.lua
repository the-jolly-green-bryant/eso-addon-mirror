LibDataStructures = LibDataStructures or {}
local LDS = LibDataStructures

LDS.Tests = LDS.Tests or {}
LDS.Tests.BinaryTree = {}
-- /script LibDataStructures.Tests.BinaryTree.Functionality()
LDS.Tests.BinaryTree.Functionality = function()
    local testTree = LDS.BinaryTree:New()

    -- Test: Neuer Baum ist leer
    assert(testTree:IsEmpty(), "New tree should be empty")
    assert(testTree:Len() == 0, "New tree length should be 0")

    -- Test: Insert
    testTree:Insert(10)
    assert(not testTree:IsEmpty(), "Tree should not be empty after Insert")
    assert(testTree:Len() == 1, "Tree length should be 1 after one Insert")
    assert(testTree:Find(10), "Tree should contain inserted value")
    assert(not testTree:Find(5), "Tree should not contain non-inserted value")

    testTree:Insert(5)
    testTree:Insert(15)
    assert(testTree:Len() == 3, "Tree length should be 3 after three Inserts")
    assert(testTree:Find(5), "Tree should contain inserted value 5")
    assert(testTree:Find(15), "Tree should contain inserted value 15")

    -- Test: Remove
    testTree:Remove(5)
    assert(not testTree:Find(5), "Value 5 should be removed")
    assert(testTree:Len() == 2, "Tree length should be 2 after removing one element")

    testTree:Remove(10)
    assert(not testTree:Find(10), "Value 10 should be removed")
    assert(testTree:Len() == 1, "Tree length should be 1 after removing another element")

    testTree:Remove(15)
    assert(testTree:Len() == 0, "Tree length should be 0 after removing all elements")
    assert(testTree:IsEmpty(), "Tree should be empty after all elements are removed")

    -- Test: Insert wiederholt für Traversal Tests
    testTree:Insert(10)
    testTree:Insert(5)
    testTree:Insert(15)
    testTree:Insert(3)
    testTree:Insert(7)
    testTree:Insert(12)
    testTree:Insert(20)

    -- InOrder traversal sollte sortierte Reihenfolge liefern: 3,5,7,10,12,15,20
    local inOrderValues = {}
    testTree:InOrder(function(v) table.insert(inOrderValues, v) end)
    assert(#inOrderValues == 7, "InOrder should visit all elements")
    local expectedInOrder = {3,5,7,10,12,15,20}
    for i,v in ipairs(expectedInOrder) do
        assert(inOrderValues[i] == v, string.format("InOrder element at index %d should be %d, got %d", i, v, inOrderValues[i]))
    end

    -- PreOrder Traversal: Root, Left, Right => 10,5,3,7,15,12,20
    local preOrderValues = {}
    testTree:PreOrder(function(v) table.insert(preOrderValues, v) end)
    local expectedPreOrder = {10,5,3,7,15,12,20}
    for i,v in ipairs(expectedPreOrder) do
        assert(preOrderValues[i] == v, string.format("PreOrder element at index %d should be %d, got %d", i, v, preOrderValues[i]))
    end

    -- PostOrder Traversal: Left, Right, Root => 3,7,5,12,20,15,10
    local postOrderValues = {}
    testTree:PostOrder(function(v) table.insert(postOrderValues, v) end)
    local expectedPostOrder = {3,7,5,12,20,15,10}
    for i,v in ipairs(expectedPostOrder) do
        assert(postOrderValues[i] == v, string.format("PostOrder element at index %d should be %d, got %d", i, v, postOrderValues[i]))
    end

    -- Test: Clear
    testTree:Clear()
    assert(testTree:IsEmpty(), "Tree should be empty after Clear")
    assert(testTree:Len() == 0, "Tree length should be 0 after Clear")

    -- Test: Clone
    testTree:Insert(10)
    testTree:Insert(5)
    testTree:Insert(15)
    local clone = testTree:Clone()
    assert(clone:Len() == testTree:Len(), "Cloned tree should have the same length as the original")
    assert(clone:Find(10) and clone:Find(5) and clone:Find(15), "Cloned tree should contain the same elements")
    -- Entfernen wir ein Element aus dem Clone und prüfen, dass das Original unverändert bleibt
    clone:Remove(10)
    assert(not clone:Find(10), "Cloned tree should no longer have 10")
    assert(testTree:Find(10), "Original tree should still have 10")

    d("All BinaryTree tests passed!")
end

-- /script LibDataStructures.Tests.BinaryTree.Performance()
LDS.Tests.BinaryTree.Performance = function()
    --local iterations = LDS.Tests.PERFORMANCE_ITERATIONS
    local iterations = 1000 -- binary trees are quite slow in general...
    local measureTime = LDS.Tests.measureTime

    local testTree = LDS.BinaryTree:New()

    -- Test: Insert Performance
    measureTime("BinaryTree Insert Performance", function()
        for i = 1, iterations do
            testTree:Insert(i)
        end
    end)

    -- Test: Find Performance
    -- Wir suchen Elemente, von denen wir wissen, dass sie eingefügt wurden.
    measureTime("BinaryTree Find Performance (existing)", function()
        for i = 1, iterations do
            testTree:Find(i)
        end
    end)

    -- Falls du auch das Suchen von nicht vorhandenen Elementen testen willst:
    measureTime("BinaryTree Find Performance (non-existing)", function()
        for i = 1, iterations do
            testTree:Find(iterations + i) -- Werte, die nicht im Baum sind
        end
    end)

    -- Test: Traversal Performance
    measureTime("BinaryTree InOrder Traversal Performance", function()
        testTree:InOrder(function(v)
            -- Nichts tun, nur traversieren
        end)
    end)

    measureTime("BinaryTree PreOrder Traversal Performance", function()
        testTree:PreOrder(function(v)
            -- Nichts tun, nur traversieren
        end)
    end)

    measureTime("BinaryTree PostOrder Traversal Performance", function()
        testTree:PostOrder(function(v)
            -- Nichts tun, nur traversieren
        end)
    end)

    -- Test: Remove Performance
    measureTime("BinaryTree Remove Performance", function()
        for i = 1, iterations do
            testTree:Remove(i)
        end
    end)

    -- Cleanup
    testTree:Clear()
    d("BinaryTree Performance Test completed!")
end