TetrisMoves = {
    name = "TetrisMoves"
}

--local logger = LibDebugLogger(TetrisMoves.name)

function TetrisMoves.start(typus)
    Block = {}
    Block.typus = typus
    Block.rotation = 0
    Block.a = {}
    Block.b = {}
    Block.c = {}
    Block.d = {}

    if typus == 1 then --J
        Block.a.x = 4
        Block.a.y = -2
        Block.b.x = 4
        Block.b.y = -1
        Block.c.x = 5
        Block.c.y = -1
        Block.d.x = 6
        Block.d.y = -1

    elseif typus == 2 then --L
        Block.a.x = 4
        Block.a.y = -1
        Block.b.x = 5
        Block.b.y = -1
        Block.c.x = 6
        Block.c.y = -2
        Block.d.x = 6
        Block.d.y = -1

    elseif typus == 3 then --T
        Block.a.x = 4
        Block.a.y = -1
        Block.b.x = 5
        Block.b.y = -2
        Block.c.x = 5
        Block.c.y = -1
        Block.d.x = 6
        Block.d.y = -1

    elseif typus == 4 then --I
        Block.a.x = 3
        Block.a.y = -2
        Block.b.x = 4
        Block.b.y = -2
        Block.c.x = 5
        Block.c.y = -2
        Block.d.x = 6
        Block.d.y = -2

    elseif typus == 5 then --Z
        Block.a.x = 4
        Block.a.y = -2
        Block.b.x = 5
        Block.b.y = -2
        Block.c.x = 5
        Block.c.y = -1
        Block.d.x = 6
        Block.d.y = -1

    elseif typus == 6 then --S
        Block.a.x = 4
        Block.a.y = -1
        Block.b.x = 5
        Block.b.y = -2
        Block.c.x = 5
        Block.c.y = -1
        Block.d.x = 6
        Block.d.y = -2

    elseif typus == 7 then --O
        Block.a.x = 4
        Block.a.y = -2
        Block.b.x = 4
        Block.b.y = -1
        Block.c.x = 5
        Block.c.y = -2
        Block.d.x = 5
        Block.d.y = -1
    end

    return Block
end

--#######################################################

-- + means to the right/down
-- - means to the left/up

function TetrisMoves.left(Block)

    Block.a.x = Block.a.x - 1
    Block.b.x = Block.b.x - 1
    Block.c.x = Block.c.x - 1
    Block.d.x = Block.d.x - 1

    return Block
end

function TetrisMoves.right(Block)

    Block.a.x = Block.a.x + 1
    Block.b.x = Block.b.x + 1
    Block.c.x = Block.c.x + 1
    Block.d.x = Block.d.x + 1

    return Block
end

function TetrisMoves.down(Block)

    Block.a.y = Block.a.y + 1
    Block.b.y = Block.b.y + 1
    Block.c.y = Block.c.y + 1
    Block.d.y = Block.d.y + 1

    return Block
end


--#######################################################
function TetrisMoves.rotate(Block)

    if Block.typus == 1 then -- J Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y +2
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y -2
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 0
        end
    end



    if Block.typus == 2 then -- L Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +2
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x -2
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y -2
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +2
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 0
        end
    end


    if Block.typus == 3 then -- T Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 0
        end
    end

    if Block.typus == 4 then -- I Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +2
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +1
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +2
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +2
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x -1
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -2
            Block.d.y = Block.d.y -1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -2
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y -1
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -2
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -2
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +1
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +2
            Block.d.y = Block.d.y +1
            Block.rotation = 0
        end
    end

    if Block.typus == 5 then -- Z Block

        if Block.rotation == 0 then
            Block.a.x = Block.a.x +2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y +2
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y -2
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 0
        end
    end

    if Block.typus == 6 then -- S Block

        if Block.rotation == 0 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +0
            Block.d.y = Block.d.y +2
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -2
            Block.d.y = Block.d.y +0
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +0
            Block.d.y = Block.d.y -2
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +2
            Block.d.y = Block.d.y +0
            Block.rotation = 0
        end
    end

--[[    if Block.typus == 7: -- O Block
        Block.a.x = Block.a.x
        Block.a.y = Block.a.y
        Block.b.x = Block.b.x
        Block.b.y = Block.b.y
        Block.c.x = Block.c.x
        Block.c.y = Block.c.y
        Block.d.x = Block.d.x
        Block.d.y = Block.d.y
    end ]]

    return Block
end


--#######################################################
function TetrisMoves.rotatecounter(Block)

    if Block.typus == 1 then -- J Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y +2
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y -2
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x -2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 0
        end
    end



    if Block.typus == 2 then -- L Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x -2
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +2
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +2
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y -2
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 0
        end
    end


    if Block.typus == 3 then -- T Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 0
        end
    end

    if Block.typus == 4 then -- I Block
        if Block.rotation == 0 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +2
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x -1
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -2
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +2
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +1
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +2
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -2
            Block.b.x = Block.b.x +0
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +1
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +2
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x -2
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +0
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y -1
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -2
            Block.rotation = 0
        end
    end

    if Block.typus == 5 then -- Z Block

        if Block.rotation == 0 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y +2
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y -1
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -1
            Block.d.y = Block.d.y +1
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x +0
            Block.a.y = Block.a.y -2
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y +1
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x -2
            Block.a.y = Block.a.y +0
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +1
            Block.d.y = Block.d.y -1
            Block.rotation = 0
        end
    end

    if Block.typus == 6 then -- S Block

        if Block.rotation == 0 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x -2
            Block.d.y = Block.d.y +0
            Block.rotation = 3

        elseif Block.rotation == 3 then
            Block.a.x = Block.a.x +1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y +1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +0
            Block.d.y = Block.d.y +2
            Block.rotation = 2

        elseif Block.rotation == 2 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y -1
            Block.b.x = Block.b.x +1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +2
            Block.d.y = Block.d.y +0
            Block.rotation = 1

        elseif Block.rotation == 1 then
            Block.a.x = Block.a.x -1
            Block.a.y = Block.a.y +1
            Block.b.x = Block.b.x -1
            Block.b.y = Block.b.y -1
            Block.c.x = Block.c.x +0
            Block.c.y = Block.c.y +0
            Block.d.x = Block.d.x +0
            Block.d.y = Block.d.y -2
            Block.rotation = 0
        end
    end

--[[    if Block.typus == 7: -- O Block
        Block.a.x = Block.a.x
        Block.a.y = Block.a.y
        Block.b.x = Block.b.x
        Block.b.y = Block.b.y
        Block.c.x = Block.c.x
        Block.c.y = Block.c.y
        Block.d.x = Block.d.x
        Block.d.y = Block.d.y
    end ]]

    return Block
end

