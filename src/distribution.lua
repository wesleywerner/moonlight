--- Provides a set of distribution classes.
-- @module distribution

-- NOTE: MOVED TO RNG.LUA

--local class = require("class")
local module = {}

module.even = function(args)
        assert(args.count, "missing argument: count")
        assert(args.period, "missing argument: period")
        assert(type(args.count) == "number", "invalid argument type: count")
        assert(type(args.period) == "number", "invalid argument type: period")
        assert(args.count > 2 and args.period > 2, "must have at least 3 count/period")

        local counter = 1
        local value = 1
        --local step = math.floor(args.period / args.count)

        -- offset always includes first and last positions
        local step = math.floor((args.period - 2) / (args.count - 2))

        return function()
            if value == 1 then
                value = step
                return 1
            end
            if counter < args.count then
                counter = counter + 1
                local current = value
                value = value + step
                return current
            end
        end
    end

-- print("5/20")
-- for n in module.even{count=5, period=20} do print(n) end
print("\n4/10")
for n in module.even{count=4, period=10} do print(n) end
-- print("\n5/30")
-- for n in module.even{count=5, period=30} do print(n) end
-- local evener = module.even{count=5, period=30}
-- for n in evener do print(n) end

return module
