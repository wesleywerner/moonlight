local shuffle_bag_logic = {}
local rng = {}

-- Random Number Generator
--  ____  _   _  ____
-- |  _ \| \ | |/ ___|
-- | |_) |  \| | |  _
-- |  _ <| |\  | |_| |
-- |_| \_\_| \_|\____|
--

function rng.seed(self, seed_value)
    self.seed = seed or os.time()
    math.randomseed(seed)
end

function rng.random()
    return math.random()
end

function rng.shuffle_bag(self, tokens)
    assert(tokens, "missing argument: tokens (table)")
    local b = {} -- a new shuffle bag
    -- copy logic across
    for k,v in pairs(shuffle_bag_logic) do
        b[k] = v
    end
    b.tokens = tokens
    b:fill()
    return b
end

function rng.even_distribution(self, args)
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

--      _            __  __ _        _
--  ___| |__  _   _ / _|/ _| | ___  | |__   __ _  __ _
-- / __| '_ \| | | | |_| |_| |/ _ \ | '_ \ / _` |/ _` |
-- \__ \ | | | |_| |  _|  _| |  __/ | |_) | (_| | (_| |
-- |___/_| |_|\__,_|_| |_| |_|\___| |_.__/ \__,_|\__, |
--                                               |___/

function shuffle_bag_logic.fill(self)
    self.contents = {}
    for _, v in pairs(self.tokens) do
        table.insert(self.contents, v)
    end
end

function shuffle_bag_logic.next(self)
    if not self.contents then
        self:fill()
    end
    local position = math.random(1, #self.contents)
    local pick = table.remove(self.contents, position)
    if #self.contents == 0 then
        self.contents = nil
    end
    return pick
end

return rng
