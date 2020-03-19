describe("shuffle bags", function()
    local rng = require("rng")
    it("fills a bag with tokens", function()
        local bag = rng:shuffle_bag({"apple", "grape", "pear"})
        assert(type(bag.contents) == "table", "bag has no contents.")
        assert(#bag.contents == 3, "bag should contain two items.")
        assert(bag.contents[1] == "apple", "bag does not contain the apple.")
    end)
end)

describe("aspects", function()

    local aspects = require("aspects")

--      _       _
--   __| | __ _| |_ __ _
--  / _` |/ _` | __/ _` |
-- | (_| | (_| | || (_| |
--  \__,_|\__,_|\__\__,_|
--

    local pottery_hobby = {
        affects = function(aspect, person)
            return person.name == "Mary"
        end,
        change = function(aspect, person, year)
            person.changed = true
        end
    }

    local sports_hobby = {
        affects = function(aspect, person)
            return person.name == "Bob"
        end,
        change = function(aspect, person, year)
            person.changed = true
            person.year = year
        end
    }

--  _            _
-- | |_ ___  ___| |_ ___
-- | __/ _ \/ __| __/ __|
-- | ||  __/\__ \ |_\__ \
--  \__\___||___/\__|___/
--

    it("makes a collection", function()
        local hobbies = aspects:collection()
        hobbies:add(pottery_hobby)
        hobbies:add(sports_hobby)
        assert(#hobbies.contents == 2, "the collection should have 2 items")
    end)

    it("changes a person", function()
        --local debug = require("debugger")
        --debug.auto_where = 3
        local Bob = {name="Bob"}
        local hobbies = aspects:collection()
        --debug()
        hobbies:apply_single(Bob, sports_hobby, 42)
        assert.is.equals(42, Bob.year, "Bob was not changed")
    end)

    it("changes a person", function()
        local Bob = {name="Bob"}
        local Mary = {name="Mary"}
        local hobbies = aspects:collection()
        hobbies:add(pottery_hobby)
        hobbies:add(sports_hobby)
        hobbies:apply{count=3, period=10, person=Bob}
        hobbies:apply{count=3, period=10, person=Mary}
        assert.is_true(Bob.changed, "Bob was not changed")
        assert.is_true(Mary.changed, "Mary was not changed")
    end)

end)
