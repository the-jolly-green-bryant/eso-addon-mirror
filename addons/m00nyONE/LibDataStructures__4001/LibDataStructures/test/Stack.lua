LibDataStructures = LibDataStructures or {}
local LDS = LibDataStructures

LDS.Tests = LDS.Tests or {}
LDS.Tests.Stack = {}

-- /script LibDataStructures.Tests.Stack.Functionality()
LDS.Tests.Stack.Functionality = function()
    local testStack = LDS.Stack:New()

    -- Test: New stack is empty
    assert(testStack:IsEmpty(), "New stack should be empty")
    assert(testStack:Len() == 0, "New stack length should be 0")
    assert(testStack:Peek() == nil, "Peek on empty stack should return nil")
    assert(testStack:Pop() == nil, "Pop on empty stack should return nil")

    -- Test: Push and Peek
    testStack:Push(10)
    assert(not testStack:IsEmpty(), "Stack should not be empty after Push")
    assert(testStack:Len() == 1, "Stack length should be 1 after one Push")
    assert(testStack:Peek() == 10, "Peek should return the last pushed value")

    testStack:Push(20)
    assert(testStack:Len() == 2, "Stack length should be 2 after two Pushes")
    assert(testStack:Peek() == 20, "Peek should return the last pushed value")

    -- Test: Pop
    local poppedValue = testStack:Pop()
    assert(poppedValue == 20, "Pop should return the last pushed value")
    assert(testStack:Len() == 1, "Stack length should be 1 after one Pop")
    assert(testStack:Peek() == 10, "Peek should return the next top value after Pop")

    poppedValue = testStack:Pop()
    assert(poppedValue == 10, "Pop should return the last remaining value")
    assert(testStack:IsEmpty(), "Stack should be empty after all elements are popped")
    assert(testStack:Len() == 0, "Stack length should be 0 when empty")

    -- Test: Clear
    testStack:Push(10)
    testStack:Push(20)
    testStack:Push(30)
    assert(testStack:Len() == 3, "Stack length should be 3 after three Pushes")
    testStack:Clear()
    assert(testStack:IsEmpty(), "Stack should be empty after Clear")
    assert(testStack:Len() == 0, "Stack length should be 0 after Clear")

    -- Test: Clone
    testStack:Push(10)
    testStack:Push(20)
    local clonedStack = testStack:Clone()
    assert(clonedStack:Len() == testStack:Len(), "Cloned stack should have the same length as the original")
    assert(clonedStack:Pop() == testStack:Peek(), "Cloned stack should have the same top element as the original")
    assert(clonedStack:Len() == testStack:Len() - 1, "Cloned stack should decrease independently")
    assert(not testStack:IsEmpty(), "Original stack should remain unaffected by clone modifications")

    -- Test: Iterate
    testStack:Clear()
    testStack:Push(1)
    testStack:Push(2)
    testStack:Push(3)
    local values = {}
    for value in testStack:Iterate() do
        table.insert(values, value)
    end
    assert(#values == 3, "Iterate should traverse all elements")
    assert(values[1] == 3 and values[2] == 2 and values[3] == 1, "Iterate should traverse in stack order (top to bottom)")

    -- Test: Push with nil value
    local success, err = pcall(function() testStack:Push(nil) end)
    assert(not success, "Pushing nil value should raise an error")

    d("All tests passed!")
end

-- /script LibDataStructures.Tests.Stack.Performance()
LDS.Tests.Stack.Performance = function()
    local iterations = LDS.Tests.PERFORMANCE_ITERATIONS
    local measureTime = LDS.Tests.measureTime
    local testStack = LDS.Stack:New()

    -- Test: Push
    measureTime("Push Performance", function()
        for i = 1, iterations do
            testStack:Push(i)
        end
    end)

    -- Test: Peek
    measureTime("Peek Performance", function()
        for i = 1, iterations do
            local _ = testStack:Peek()
        end
    end)

    -- Test: Pop
    measureTime("Pop Performance", function()
        for i = 1, iterations do
            testStack:Pop()
        end
    end)

    -- Test: Iterate
    for i = 1, iterations do
        testStack:Push(i)
    end
    measureTime("Iterate Performance", function()
        for _ in testStack:Iterate() do
            -- Nichts tun, nur iterieren
        end
    end)

    -- Cleanup
    testStack:Clear()
    d("Stack Performance Test completed!")
end