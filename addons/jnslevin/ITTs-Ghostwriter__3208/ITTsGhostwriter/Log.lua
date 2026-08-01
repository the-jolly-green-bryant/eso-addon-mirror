GWLogger = ZO_Object:Subclass()
GWLogger.instances = {}
local ITTName = "ITTsGhostwriter"
function GWLogger:New( name )
    local obj = ZO_Object.New( self )
    local mainLogger = LibDebugLogger( ITTName )

    obj.mainLogger = mainLogger
    obj.logger = mainLogger:Create( name )
    obj.logger:SetMinLevelOverride( LibDebugLogger.LOG_LEVEL_VERBOSE )
    obj.logLevels = {
        [ 1 ] = LibDebugLogger.LOG_LEVEL_VERBOSE,
        [ 2 ] = LibDebugLogger.LOG_LEVEL_DEBUG,
        [ 3 ] = LibDebugLogger.LOG_LEVEL_INFO,
        [ 4 ] = LibDebugLogger.LOG_LEVEL_WARNING,
        [ 5 ] = LibDebugLogger.LOG_LEVEL_ERROR,
    }
    table.insert( GWLogger.instances, obj )

    return obj
end

function GWLogger:Log( level, message, ... )
    local function table_to_string( t )
        local result = {}
        for k, v in pairs( t ) do
            result[ #result + 1 ] = tostring( v )
        end
        return "{ " .. table.concat( result, ", " ) .. " }"
    end

    if type( level ) == "table" then
        -- If `level` is a table, concatenate the table values with `\n` as a delimiter
        message = table_to_string( level )
        level = 2 -- Default to Debug level
    elseif type( level ) == "number" then
        -- If there are additional arguments, treat `message` as a format string
        if select( "#", ... ) > 0 then
            local args = { ... }
            for i = 1, #args do
                if args[ i ] ~= nil then
                    args[ i ] = type( args[ i ] ) == "table" and table_to_string( args[ i ] ) or tostring( args[ i ] )
                else
                    args[ i ] = "nil"
                end
            end
            --apparently table.unpack doesnt work
            message = string.format( message, args[ 1 ], args[ 2 ],
                                     args[ 3 ],
                                     args[ 4 ], args[ 5 ], args[ 6 ],
                                     args[ 7 ], args[ 8 ],
                                     args[ 9 ], args[ 10 ] )
        end
    else
        -- If `level` is not a number, treat it as a format string
        local args = { message, ... }
        for i = 1, #args do
            if args[ i ] ~= nil then
                args[ i ] = type( args[ i ] ) == "table" and table_to_string( args[ i ] ) or tostring( args[ i ] )
            else
                args[ i ] = "nil"
            end
        end
        -- Use individual arguments instead of table.unpack
        message = string.format( level, args[ 1 ], args[ 2 ], args[ 3 ],
                                 args[ 4 ], args[ 5 ], args[ 6 ], args[ 7 ],
                                 args[ 8 ], args[ 9 ],
                                 args[ 10 ] )
        level = 2 -- Default to Debug level, could be changed to verbose
    end

    self.logger:Log( self.logLevels[ level ], tostring( message ) )
end

function GWLogger:UpdateEnabledState()
    --used to disable all loggers
    self.logger:SetEnabled( ITTsGhostwriter.Vars.debugMode )
end
