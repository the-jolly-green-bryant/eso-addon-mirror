LibDataStructures = LibDataStructures or {}
local LDS = LibDataStructures

LDS.Tests = LDS.Tests or {}
LDS.Tests.Queue = {}

-- /script LibDataStructures.Tests.Queue.Functionality()
LDS.Tests.Queue.Functionality = function()
    local testQueue = LDS.Queue:New()

    -- Test: New queue is empty
    assert(testQueue:IsEmpty(), "New queue should be empty")
    assert(testQueue:Len() == 0, "New queue length should be 0")
    assert(testQueue:Peek() == nil, "Peek on empty queue should return nil")
    assert(testQueue:Dequeue() == nil, "Dequeue on empty queue should return nil")

    -- Test: Enqueue and Peek
    testQueue:Enqueue(10)
    assert(not testQueue:IsEmpty(), "Queue should not be empty after Enqueue")
    assert(testQueue:Len() == 1, "Queue length should be 1 after one Enqueue")
    assert(testQueue:Peek() == 10, "Peek should return the first enqueued value")

    testQueue:Enqueue(20)
    assert(testQueue:Len() == 2, "Queue length should be 2 after two Enqueues")
    assert(testQueue:Peek() == 10, "Peek should still return the first enqueued value")

    -- Test: Dequeue
    local dequeuedValue = testQueue:Dequeue()
    assert(dequeuedValue == 10, "Dequeue should return the first enqueued value")
    assert(testQueue:Len() == 1, "Queue length should be 1 after one Dequeue")
    assert(testQueue:Peek() == 20, "Peek should return the next front value after Dequeue")

    dequeuedValue = testQueue:Dequeue()
    assert(dequeuedValue == 20, "Dequeue should return the last remaining value")
    assert(testQueue:IsEmpty(), "Queue should be empty after all elements are dequeued")
    assert(testQueue:Len() == 0, "Queue length should be 0 when empty")

    -- Test: Clear
    testQueue:Enqueue(10)
    testQueue:Enqueue(20)
    testQueue:Enqueue(30)
    assert(testQueue:Len() == 3, "Queue length should be 3 after three Enqueues")
    testQueue:Clear()
    assert(testQueue:IsEmpty(), "Queue should be empty after Clear")
    assert(testQueue:Len() == 0, "Queue length should be 0 after Clear")

    -- Test: Clone
    testQueue:Enqueue(10)
    testQueue:Enqueue(20)
    local clonedQueue = testQueue:Clone()
    assert(clonedQueue:Len() == testQueue:Len(), "Cloned queue should have the same length as the original")
    assert(clonedQueue:Dequeue() == testQueue:Peek(), "Cloned queue should have the same front element as the original")
    assert(clonedQueue:Len() == testQueue:Len() - 1, "Cloned queue should decrease independently")
    assert(not testQueue:IsEmpty(), "Original queue should remain unaffected by clone modifications")

    -- Test: Iterate
    testQueue:Clear()
    testQueue:Enqueue(1)
    testQueue:Enqueue(2)
    testQueue:Enqueue(3)
    local values = {}
    for value in testQueue:Iterate() do
        table.insert(values, value)
    end
    assert(#values == 3, "Iterate should traverse all elements")
    assert(values[1] == 1 and values[2] == 2 and values[3] == 3, "Iterate should traverse in queue order (front to back)")

    -- Test: Enqueue with nil value
    local success, _ = pcall(function() testQueue:Enqueue(nil) end)
    assert(not success, "Enqueuing nil value should raise an error")

    d("All queue tests passed!")
end

-- /script LibDataStructures.Tests.Queue.Performance()
LDS.Tests.Queue.Performance = function()
    local iterations = LDS.Tests.PERFORMANCE_ITERATIONS
    local measureTime = LDS.Tests.measureTime
    local testQueue = LDS.Queue:New()

    -- Test: Enqueue
    measureTime("Enqueue Performance", function()
        for i = 1, iterations do
            testQueue:Enqueue(i)
        end
    end)

    -- Test: Peek
    measureTime("Peek Performance", function()
        for i = 1, iterations do
            local _ = testQueue:Peek()
        end
    end)

    -- Test: Dequeue
    measureTime("Dequeue Performance", function()
        for i = 1, iterations do
            testQueue:Dequeue()
        end
    end)

    -- Test: Iterate
    for i = 1, iterations do
        testQueue:Enqueue(i)
    end
    measureTime("Iterate Performance", function()
        for _ in testQueue:Iterate() do
            -- do nothing, just iterate
        end
    end)

    -- Cleanup
    testQueue:Clear()
    d("Queue Performance Test completed!")
end
