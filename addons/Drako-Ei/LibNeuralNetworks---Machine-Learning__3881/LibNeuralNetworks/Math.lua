local lib = LibNeuralNetworks
local libMath = lib.math

libMath.randomNormal = function()
    local u1 = math.random()
    local u2 = math.random()
    local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return z0
end

libMath.heRandom = function(numInputs, numOutputs)
    local weights = {}
    local stddev = math.sqrt(2 / numInputs)
    return stddev * libMath.randomNormal()
end

-- Sigmoid function
libMath.sigmoid = function(x)
    return 1 / (1 + math.exp(-x))
end

-- Derivative of the sigmoid function
libMath.deltaSigmoid = function(x)
    local y = libMath.sigmoid(x)
    return y * (1 - y)
end

-- Re'LU function
libMath.relu = function(x)
    return math.max(0, x)
end

-- Derivative of the Re'LU function
libMath.deltaRelu = function(x)
    return x > 0 and 1 or 0
end

-- Leaky ReLU activation function
libMath.leakyRelu = function(x)
    return x > 0 and x or (0.01 * x)
end

-- Derivative of Leaky ReLU
libMath.leakyDeltaRelu = function(x)
    return x > 0 and 1 or 0.01
end

-- Multiply vector by scalar
libMath.multiplyVectorByScalar = function(vector, scalar)
    local result = {}
    for i = 1, #vector do
        table.insert(result, vector[i] * scalar)
    end
    return result
end

-- Randomize a vector between -1 and 1
libMath.randomVector = function(size, rng)
    local result = {}
    for i = 1, size do
        table.insert(result, rng() or (math.random() * 2 - 1))
    end
    return result
end

-- Average a collection of vectors
libMath.averageVectors = function(gradients)
    local numGradients = #gradients
    local avgGradient = {}

    for i = 1, #gradients[1] do
        avgGradient[i] = 0
    end

    for _, gradient in ipairs(gradients) do
        for i = 1, #gradient do
            avgGradient[i] = avgGradient[i] + gradient[i]
        end
    end

    for i = 1, #avgGradient do
        avgGradient[i] = avgGradient[i] / numGradients
    end

    return avgGradient
end

-- Randomize a matrix between -1 and 1
libMath.randomMatrix = function(rows, columns, rng)
    local result = {}
    for i = 1, rows do
        local row = {}
        for j = 1, columns do
            table.insert(row, rng() or (math.random() * 2 - 1))
        end
        table.insert(result, row)
    end
    return result
end

-- Outer product of 2 vectors
libMath.outerProduct = function(vector1, vector2)
    local result = {}
    for i = 1, #vector1 do
        local row = {}
        for j = 1, #vector2 do
            table.insert(row, vector1[i] * vector2[j])
        end
        table.insert(result, row)
    end
    return result
end

-- Multiply 2 vectors component by component
libMath.multiplyVectorComponents = function(vector1, vector2)
    local result = {}
    for i = 1, #vector1 do
        table.insert(result, vector1[i] * vector2[i])
    end
    return result
end

-- Get the other product of 2 vectors
libMath.outerProduct = function(vector1, vector2)
    local result = {}
    for i = 1, #vector1 do
        local row = {}
        for j = 1, #vector2 do
            table.insert(row, vector1[i] * vector2[j])
        end
        table.insert(result, row)
    end
    return result
end

-- Transpose a matrix
libMath.transposeMatrix = function(matrix)
    local result = {}
    for i = 1, #matrix[1] do
        local row = {}
        for j = 1, #matrix do
            table.insert(row, matrix[j][i])
        end
        table.insert(result, row)
    end
    return result
end

-- Matrix by vector multiplication
libMath.multiplyMatrixByVector = function(matrix, vector)
    assert(#matrix[1] == #vector, "Number of columns in matrix must be equal to number of elements in vector")
    local result = {}
    for i = 1, #matrix do
        local sum = 0
        for j = 1, #vector do
            sum = sum + matrix[i][j] * vector[j]
        end
        table.insert(result, sum)
    end
    return result
end

-- Vector addition
libMath.addVectors = function(vector1, vector2)
    local result = {}
    for i = 1, #vector1 do
        table.insert(result, vector1[i] + vector2[i])
    end
    return result
end

-- Dot product
libMath.dotProduct = function(vector1, vector2)
    assert(#vector1 == #vector2, "Vectors must have the same size")
    local result = 0
    for i = 1, #vector1 do
        result = result + vector1[i] * vector2[i]
    end
    return result
end

-- Peforms a function on all the vector components
libMath.mapVector = function(vector, func)
    local result = {}
    for i = 1, #vector do
        table.insert(result, func(vector[i]))
    end
    return result
end

-- Peforms a vector substraction
libMath.subtractVectors = function(vector1, vector2)
    local result = {}
    for i = 1, #vector1 do
        table.insert(result, vector1[i] - vector2[i])
    end
    return result
end

-- Initialize a matrix with zeros
libMath.zeroMatrix = function(rows, columns)
    local matrix = {}
    for i = 1, rows do
        local row = {}
        for j = 1, columns do
            table.insert(row, 0)
        end
        table.insert(matrix, row)
    end
    return matrix
end

-- Initialize a vector with zeros
libMath.zeroVector = function(size)
    local vector = {}
    for i = 1, size do
        table.insert(vector, 0)
    end
    return vector
end