local rng = require("rng")
local aspect = {}
local instance_logic = {}

function aspect.collection(self)
    -- new collection
    local c = {}
    -- copy logic across
    for k,v in pairs(instance_logic) do
        c[k] = v
    end
    -- init storage
    c.contents = {}
    return c
end

function instance_logic.add(self, aspect)
    assert(aspect, "missing argument: aspect (table)")
    assert(type(aspect.affects) == "function", "missing argument: affects (function)")
    assert(type(aspect.change) == "function", "missing argument: change (function)")
    table.insert(self.contents, aspect)
end

function instance_logic.apply_single(self, person, aspect, year)
    if aspect:affects(person) then
        aspect:change(person, year)
    end
end

function instance_logic.apply(self, arg)
    assert(arg, "missing arguments: count, period, person")
    assert(type(arg.count) == "number", "missing argument: count")
    assert(type(arg.period) == "number", "missing argument: period")
    assert(type(arg.person) == "table", "missing argument: person")
    range = rng:even_distribution{count=arg.count, period=arg.period}
    for year in range do
        local aspect = self:pick_one_for(arg.person)
        if aspect then
            aspect:change(arg.person, year)
        end
    end
end

function instance_logic.pick_one_for(self, person)
    if not self.bag then
        self.bag = rng:shuffle_bag(self.contents)
    end
    local limit_tries = 10
    while limit_tries > 0 do
        limit_tries = limit_tries - 1
        local aspect = self.bag:next()
        if aspect:affects(person) then
            return aspect
        end
    end
end

return aspect
