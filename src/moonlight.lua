

--- Moonlight interactive fiction world simulator.
--
-- Local functions are used internally by the simulator and not meant
-- to be called directly.
--
-- See @{getting_started.lua} for a quick introduction.
--
-- @module moonlight

------------------------------------------------------------------------

--- A table of the parsed sentence, and world items that match any nouns.
-- @table command
--
-- @field verb
-- The verb word as interpreted by the parser.
-- It may mutate into a root word if the player input a synonym.
--
-- @field nouns
-- Indexed table of noun words parsed from the sentence.
-- It is not guaranteed these nouns match any items visible to the player.
--
-- @field direction
-- The word of the direction implied in the sentence.
--
-- @field first_noun
-- An alias for nouns[1].
--
-- @field second_noun
-- An alias for nouns[2].
--
-- @field first_item
-- The first @{thing} in the nouns list.
-- If this has a value it is guaranteed to match an item in the world.
--
-- @field second_item
-- The second @{thing} in the nouns list.
-- If this has a value it is guaranteed to match an item in the world.
--

------------------------------------------------------------------------

--- Output of responses generated by a turn.
-- And example response is:
-- {"You take the envelope", "It feels like there is something heavy inside it"}
--
-- @table output

------------------------------------------------------------------------

--- The world model.
-- The world model is a table of @{room}s.
--
-- See @{getting_started.lua} for a quick introduction.
--
-- @table world

------------------------------------------------------------------------

--- A room in the world.
--
-- @field name
-- The name of the room, this is also used when referencing exits from
-- rooms and doors.
--
-- @field description
-- The detailed description of the room when it is examined.
--
-- @field contains
-- A table of @{thing}s in the room.
--
-- @field dark
-- A boolean if the room is dark. The player is limited to what they can
-- see and do in dark rooms. This value stays true even if there is a
-- light source in the room. When that light is removed then darkness
-- returns.
--
-- @field is_dark
-- Boolean if the room is dark, and there is no light source.
-- This value is set by the simulator and should be used in rulebooks to
-- determine visibility.
--
-- @field is_lit
-- Boolean if the room is not dark, or there is a light source.
-- This value is set by the simulator and should be used in rulebooks to
-- determine visibility.
--
-- @field exits
-- Table of exits in a room, defined as direction=room key-values.
-- The exit value can also point to the name of a @{thing}
-- providing that thing has a `destination` property.
--
-- @table room

------------------------------------------------------------------------

--- A thing that exists in the simulated world.
-- Things are whatever is seen, touched, held or manipulated in the world.
-- Things are also people and doors.
--
-- @table thing
--
-- @field name
-- The name of the thing
--
-- @field count
-- A key-value table of counts that a VERB was used on this thing.
-- For example, if a a thing was examined 42 times, then item.count["examine"] == 42
--
-- @field description
-- The detailed description of the thing when it is examined.
-- If not set a generic description is generated.
--
-- @field person
-- A boolean indicating the thing is a person.
-- The default article rule is ignored when the person is listed.
--
-- @field appearance
-- Optional wording to display for an item when listing it in a room.
-- This is used to make things stand out, instead of listing it as
-- "There is an orchid here", you can specify
-- "A sweet scent draws your eyes to an orchid nearby."
--
-- @field article
-- Optional article used to prefix the thing's description.
-- If not given the article will default to "a" or "an" depending
-- on vowel rules. To list the thing as plural set the article to
-- "some" or any similar text.
--
-- @field fixed
-- The thing is fixed in place, meaning the player cannot take it.
-- When set true, a default response is given to the player.
-- The value can also be set as a custom response text.
--
-- @field contains
-- A table of @{thing}s that is held. People and boxes can contain things.
--
-- @field supports
-- A table of @{thing}s supported. Tables can supporting things.
--
-- @field closed
-- A boolean if the thing is closed. Closed things do not reveal
-- their contents until opened.
--
-- @field locked
-- A boolean if the thing is locked. Locked things cannot be opened or
-- closed until they are unlocked with a key.
--
-- @field unlocks
-- A table listing names of other things it can unlock.
--
-- @field destination
-- The name of the room this thing leads to when entered. This turns
-- the thing into a door.
--
-- @field edible
-- A boolean indicating the thing is edible by the player.
--
-- @field parts
-- A table of @{thing}s that are a part of this thing.
-- Parts are not listed in room or item descriptions, but the player
-- can interact with them using the standard verb rules.
-- The purpose of the parts table is to allow game developers to combine
-- multiple things together to form a larger whole.
-- Buttons and levers can be parts on a control panel, for example.

------------------------------------------------------------------------

--- Defines behavior for performing actions during simulation.
-- @table rule
--
-- @field name
-- The name of the rule.
--
-- @field action
-- A function defining the rule logic. It receives (@{moonlight:instance}, @{moonlight:command})
-- as parameters.
-- The action can return up to 2 values.
-- The first return value is the response text.
-- The second return value is a boolean false indicating failure.
-- Further rulebook processing stops if the rule fails.

------------------------------------------------------------------------

--- A table of options defining verbose output.
-- @table verboseOptions
--
-- @field parser
-- Set true to output parser debug output to the @{instance}.log table.
--
-- @field rulebooks
-- Set true to output rulebook debug output to the @{instance}.log table.
--
-- @field descriptions
-- Set true to print full room descriptions every time a room is entered.
-- Otherwise full descriptions are printed only on first entry.

------------------------------------------------------------------------

--- A table of options that define parser and response behaviour.
-- @table options
--
-- @field verbs
-- Indexed table of words considered valid verbs.
-- If the player tries using a verb not in this list
-- then the unknown verb response is issued.
--
-- @field ignores
-- Indexed table of words to ignore when parsing a sentence.
-- These are words not considered verbs or nouns.
--
-- @field synonyms
-- Indexed table of tables of words. The first word is the root word and
-- following words are the synonyms. When a sentence is parsed all words
-- are replaced by their root equivalent.
--
-- @field vowels
-- Indexed table english vowels, used to generate noun articles when
-- describing or listing things.
--
-- @field directions
-- Indexed table of known directions.
--
-- @field flag
-- @{flags} modify the engine behaviour
--
-- @field soundex
-- A boolean to enable soundex matching of known nouns to the player's
-- input during sentence parsing.
--
-- @field verbose
-- A table of @{verboseOptions}.
--
-- @field testing
-- A boolean indicating that testing verbs can be used while testing the
-- simulation.
-- True by default.
-- See @{testing.lua}.

local options = require ("options")

------------------------------------------------------------------------

--- A table of optional flags to modify the engine behaviour.
-- @table flags
-- @field flag true/false
-- @usage
-- -- list all exits after the room description
-- ["list exits"] = true
--
-- -- list the contents of a container when opening it
-- ["list contents of opened"] = true
--
-- -- take things found while searching
-- ["take things searched"] = false
--
-- -- open things when unlocking them
-- ["open unlocked things"] = false

options.flags = {
	-- list all exits after the room description
	["list exits"] = true,
	-- list the contents of a container when opening it
	["list contents of opened"] = true,
	-- take things found while searching
	["take things searched"] = false,
	-- open things when unlocking them
	["open unlocked things"] = false
}

------------------------------------------------------------------------

--- List of standard responses.
-- It is categorized by [verb][state], where state varies by the action performed.
-- See the link to the source for the template wording.
--
-- @table responses
local responses = require ("responses")

--- An instance of the @{agency} module.
local agency = require ("agency")

--- An instance of the @{utils} module.
local utils = require("utils")

--- Count the number of times a verb is used on a thing.
-- The counter is stored on the @{thing} as a key-number table of verbs.
-- item.count["examine"] = 42
--
-- @param self @{instance}
--
-- @param command @{command}
local function count_verb_usage (self, command)
	local target = command.first_item or self.room
	local verb = command.verb

	if type(command) == "string" then
		verb = command
	end

	if target then
		target.count = target.count or { }
		target.count[verb] = (target.count[verb] or 0) + 1
	end
end


--- Loads the standard rulebooks.
--
-- These additional rules are loaded conditionally upon the relevant
-- @{instance}.options.flags:
--
-- @param self @{instance}
--
-- @return table of standard rules.
local function load_standard_rulebooks (self)

	local rulebooks = { }
	require("rulebooks")(rulebooks)
	require("take_rules")(rulebooks)
	require("drop_rules")(rulebooks)
	require("examine_rules")(rulebooks)
	require("going_rules")(rulebooks)
	require("inventory_rules")(rulebooks)
	require("insert_rules")(rulebooks)
	require("open_rules")(rulebooks)
	require("close_rules")(rulebooks)
	require("turn_rules")(rulebooks)
	require("unlock_rules")(rulebooks)
	require("search_rules")(rulebooks)
	require("all_rules")(rulebooks)
	require("reword_rules")(rulebooks)
	require("simulate_rules")(rulebooks)

	-- include testing rules
	if self.options.testing then
		require("purloin_rules")(rulebooks)
		require("inspect_rules")(rulebooks)
	end

	return rulebooks

end


--- Reset the simulator state.
-- Clears the internal state of the world
-- and loads the standard rulebooks.
--
-- @param self @{instance}
local function reset_simulation (self)
	self.rulebooks = nil
	self.player = nil
	self.room = nil
	self.world = nil
	self.turnNumber = 1
end


--- Test if the command passes checks in rulebook.
--
-- @param self
-- @{instance}
--
-- @param timing
-- The applicable timing as defined in
--
-- @param command
-- The @{command} to validate.
--
-- @return boolean
-- Boolean value indicating that the rules passed.
local function consult_rulebook (self, timing, command)

	local book = self.rulebooks[timing]

	if not book then
		return true
	end

	local rules

	if type(command) == "string" then
		-- if this is a non-action rulebook
		rules = book[command]
		command = { verb = command, nouns = {} }
	else
		-- this is an action rulebook
		rules = book[command.verb]
	end

	if not rules then
		return true
	end

	for _, rule in ipairs(rules) do

		if type(rule.action) == "function" then

			-- log before rules, first
			if timing == "after" and self.options.verbose.rulebooks then
				table.insert (self.log,
				string.format("Consulting the [%s] [%s] [%s] rule",
					timing or "none", command.verb, rule.name))
			end

			local message, result = rule.action(self, command)

			-- log other rules, second
			if timing ~= "after" and self.options.verbose.rulebooks then
				table.insert (self.log,
				string.format("Consulted the [%s] [%s] [%s] rule: %s",
					timing or "none",
					command.verb,
					rule.name,
					(result == false) and "fail" or "pass"
					))
			end

			if message then
				table.insert (self.output, message)
			end

			-- a failed rule stops immediately
			if result == false then
				return false
			end

		end

	end

	return true

end


--- Search for a world thing.
-- @function search
--
-- @param self
-- @{instance}
--
-- @param term
-- The name of the thing to find, the thing itself (to find it's parent)
-- or a predicate function to match items.
--
-- @param[opt] parent
-- The room to search. If given as `nil` all rooms are searched.
--
-- @param[opt] options
-- A table of @{search_options}
--
-- @return
-- An indexed table of matches, each match a collection
-- { item, parent }
-- Returns nil if no matches found.
local function search (self, term, parent, options)

	-- helper to match a thing
	local match = function (item)
		if type(term) == "string" then
			-- the hyphen is a magic character in Lua patterns.
			-- escape them in the item name to get a match.
			local escapedTerm = string.gsub(term, "%-", "%%-")
			return string.match(item.name, escapedTerm)
		elseif type(term) == "table" then
			return item == term
		elseif type(term) == "function" then
			return term (item)
		end
	end

	--- A table of options affecting how searches are carried out.
	-- Each option is toggled with a Boolean `true` value.
	-- If `true` is given instead this table itself, then all possible
	-- options are taken as `true`.
	--
	-- @table search_options
	--
	-- @field includeClosed
	-- Search inside closed containers
	--
	-- @field includeDark
	-- Search inside unlit containers (including rooms)
	--
	-- @field includePersonal
	-- Search inside the player's inventory

	-- options of true allows all
	if options == nil then
		options = {
			includeClosed = false,
			includeDark = false
		}
	elseif options == true then
		options = {
			includeClosed = true,
			includeDark = true,
			includePersonal = true
		}
	end

	-- helper to test if item contents should be queried,
	-- based on seen things and if the item is closed or dark.
	local queryContents = function (item)
		-- do not query dark things
		if not options.includeDark and item.is_dark then
			return false
		end
		-- do not query closed things
		if not options.includeClosed and item.closed then
			return false
		end
		-- do not query persons
		if item.person == true and item ~= self.player and not options.includePersonal then
			return false
		end
		return true
	end

	-- use stack-based searching to query deep structures
	local stack = { }

	-- table of matched items found by the search
	local results = { }

	if parent then
		-- include the parent in the search
		if queryContents (parent) then
			table.insert (stack, {parent})
		end
	else
		-- search all rooms if no parent specified
		for _, room in ipairs(self.world) do
			table.insert (stack, {room})
		end
	end

	-- while there are items on the stack
	while #stack > 0 do

		-- load the next item
		local item, parent = unpack (table.remove(stack))

		-- add it's children to the stack
		if queryContents (item) then
			for i, n in ipairs(item.contains or {}) do
				table.insert (stack, { n, item })
			end
			for i, n in ipairs(item.supports or {}) do
				table.insert (stack, { n, item })
			end
			for i, n in ipairs(item.hides or {}) do
				table.insert (stack, { n, item })
			end
			for i, n in ipairs(item.parts or {}) do
				table.insert (stack, { n, item })
			end
		end

		-- query the current item
		if match (item) then
			table.insert (results, { item, parent })
		end

	end

	if #results > 0 then
		return results
	end

end


--- Search and return the first match.
-- @function search_first
--
-- @param self
-- @{instance}
--
-- @param term
-- The name of the thing to find, the thing itself (to find it's parent)
-- or a predicate function to match items.
--
-- @param[opt] parent
-- The room to search. If given as `nil` all rooms are searched.
--
-- @param[opt] options
-- A table of @{search_options}
--
-- @return @{thing} or nil if no match found.
-- @see search
local function search_first (self, term, parent, options)
	local matches = search (self, term, parent, options)
	if matches then
		return unpack(matches[1])
	end
end


--- Set the player character in the world simulation.
-- The simulation will only run once a player has been set.
--
-- @function set_player
--
-- @param self @{instance}
--
-- @param name
-- The name of the player @{thing}
local function set_player (self, name)

	-- TODO we have isPlayer and player. remove one.
	-- TODO self.player clashes with the thing.player property? Rename to self.ego?
	-- unassign the current player
	if self.player then
		self.player.isPlayer = nil
	end

	local match = search (self, name, nil, true)

	if not match then
		error(string.format("I could not find a thing named %q.", name))
	end

	self.player, self.room = unpack (match[1])

	if not self.room then
		error(string.format("The thing named %q is not a child of a room.", name))
	end

	-- ensure the player can carry things
	self.player.contains = self.player.contains or { }

	self.player.isPlayer = true

end


--- Load a world model into the simulator.
-- This method resets to the standard rulebooks, so be sure to add
-- your rules after loading the world.
-- @function load_world
--
-- @param self
-- @{instance}
--
-- @param world @{world}
-- The world model to load.
--
-- @see scaffold
--
-- @return Three values: bool (no errors or warnings),
--   table (list of warnings), table (list of errors).
--   The simulation can continue if there are warnings.
--   Any errors will prevent the simulation from running.
--
local function load_world (self, world)

	assert (type(world) == "table", "The world object must be a table")

	-- ensure all rooms can contain things
	for _, room in ipairs(world) do
		room.contains = room.contains or { }
	end

	-- load standard rulebooks
	self.rulebooks = load_standard_rulebooks (self)

	-- set the world
	self.world = world

	-- validate
	local warnings, errors = self:validate (world)
	return warnings, errors

end


--- Format the name of an item with the article prefixed.
-- If no article is defined on the item, then standard "a/an" rules apply.
--
-- @param self @{instance}
--
-- @param item @{thing}
--
-- @return string
local function format_name (self, item)

	if item.person == true then
		if item.article then
			return string.format("%s %s", item.article, item.name)
		else
			return item.name
		end
	end

	if item.article then
		return string.format("%s %s", item.article, item.name)
	end

	if utils.indexOf(self.options.vowels, string.sub(item.name, 1, 1)) == 0 then
		return string.format("a %s", item.name)
	else
		return string.format("an %s", item.name)
	end

end


--- Join a list of names into a sentence.
-- Names are joined with commas, while the last item
-- receives the "and" join, depending on how many names are listed.
--
-- @param self
-- @{instance}
--
-- @param names
-- indexed table of names
--
-- @return string
local function list_join(self, names)

	if #names == 2 then
		return table.concat(names, " and ")
	elseif #names > 2 then
		local lastitem = table.remove(names)
		return table.concat(names, ", ") .. " and " .. lastitem
	else
		return table.concat(names)
	end

end


--- List the things inside and/or on top of an item.
--
-- @param self @{instance}
--
-- @param item @{thing}
-- The item to query
--
-- @return string
local function list_contents (self, item)

	local items = { }
	local containerText = nil
	local supporterText = nil

	-- default container lead text
	local lead = self.responses.lead["container"]

	-- switch to room lead text
	local isRoom = self:room_by_name (item.name)
	if isRoom then
		lead = self.responses.lead["room"]
	end

	if item.contains and (not item.closed) and (self.room.is_lit) then
		for k, v in pairs(item.contains) do
			-- list items that are not the player, or don't have custom appearances.
			if not v.isPlayer and not v.appearance then
				table.insert(items, format_name(self, v))
			end
		end
		if #items > 0 then
			containerText = string.format(lead, list_join(self, items))
		end
	end

	-- clear items list for supporter listing
	items = { }

	-- list things on top of the item
	if item.supports then
		for k, v in pairs(item.supports) do
			-- list items that are not the player, or don't have custom appearances.
			if not v.isPlayer and not v.appearance then
				table.insert(items, format_name(self, v))
			end
		end
		if #items > 0 then
			supporterText = string.format(self.responses.lead["supporter"], list_join(self, items))
		end
	end

	if containerText and supporterText then
		return string.format("%s %s", containerText, supporterText)
	elseif containerText then
		return containerText
	elseif supporterText then
		return supporterText
	end

end


--- List special appearance descriptions of child items.
-- A special appearance usually replaces the item's room listing.
--
-- @param self @{instance}
--
-- @param item @{thing}
-- The item to query
--
-- @return string
local function list_child_appearances (self, item)

	local items = { }

	for _, v in pairs(item.contains or {}) do
		-- list items that are not the player, or don't have custom appearances.
		if v.appearance and v.appearance ~= "" then
			table.insert(items, v.appearance)
		end
	end

	for _, v in pairs(item.supports or {}) do
		-- list items that are not the player, or don't have custom appearances.
		if v.appearance and v.appearance ~= "" then
			table.insert(items, v.appearance)
		end
	end

	if #items > 0 then
		return table.concat (items, " ")
	end

end


--- Describe the given item in detail.
-- The item's description is generated if it has none defined.
--
-- @param self
--
-- @param item
-- The item that will be described
--
-- @return string
local function describe (self, item)

	-- default item description if none is specified
	local desc = item.description or string.format("It is a %s.", item.name)
	local specialAppearances = list_child_appearances (self, item)
	local contents = list_contents (self, item)

	-- Omit the description if the player has examined the item before
	-- This option is ignored if options.verbose.descriptions is true.
	if not self.options.verbose.descriptions then
		local first_visit = item.count["examine"] == 1
		if (not first_visit) then
			-- negate the full room description
			desc = nil
		end
	end

	local closed = item.closed and "It is closed." or nil

	local itemlist = utils.filter(
		{ desc, closed, specialAppearances, contents },
		function (n)
			return n ~= nil
		end)

	if #itemlist > 0 then
		return table.concat(itemlist, " ")
	else
		return nil
	end

end


--- List the exits in a room.
-- The exits match the list of known directions.
--
-- @param self @{instance}
--
-- @return string
-- In the format "You can go north, south, east, west ..."
local function list_room_exits (self)

	-- always list exits in a dark room
	if self.options.flags["list exits"] or self.room.is_dark then
		if type(self.room.exits) == "table" then
			local possibleWays = { }
			for k, v in pairs(self.room.exits) do
				table.insert(possibleWays, k)
			end
			if #possibleWays > 0 then
				table.sort(possibleWays)
				return "You can go " .. list_join(self, possibleWays) .. "."
			end
		end
	end

	return nil

end


--- Lists items carried by the player.
--
-- @param self @{instance}
--
-- @return string in the format "You are carrying..."
local function list_inventory (self)

	if #self.player.contains == 0 then
		return self.responses.inventory["empty"]
	end

	local items = { }

	for _, v in pairs(self.player.contains) do
		table.insert (items, format_name (self, v))
	end

	return string.format ("You are carrying %s.", list_join (self, items))

end


--- Detach a thing from it's parent.
-- This function is used internally to detach things when moving
-- them between owners.
--
-- @param self
-- @{instance}
--
-- @param thing
-- The @{thing} to detach
local function detach (self, thing)
	local _, parent = self:search_first (thing)
	if parent then
		for place, cmp in ipairs(parent.contains or {}) do
			if thing == cmp then
				table.remove (parent.contains, place)
			end
		end
		for place, cmp in ipairs(parent.supports or {}) do
			if thing == cmp then
				table.remove (parent.supports, place)
			end
		end
		for place, cmp in ipairs(parent.hides or {}) do
			if thing == cmp then
				table.remove (parent.hides, place)
			end
		end
	end
end


--- Move the player into a room.
-- Usually a room or a container.
--
-- @param self
-- @{instance}
--
-- @param where
-- A container @{thing}.
local function move_player (self, where)
	self:move_thing_into (self.player, where)
	self.room = where
end


--- Move an item into a container.
--
-- @param self
-- @{instance}
--
-- @param what
-- The @{thing} to move.
--
-- @param where
-- A container @{thing}.
local function move_thing_into (self, what, where)
	self:detach (what)
	table.insert(where.contains, what)
end


--- Put an item on top of a supporter.
--
-- @param self
-- @{instance}
--
-- @param what
-- The @{thing} to move.
--
-- @param where
-- The supporter @{thing}.
local function move_thing_onto (self, what, where)
	self:detach (what)
	table.insert(where.supports, what)
end


--- Test if a thing is carrying another thing.
--
-- @param self @{instance}
--
-- @param item string or @{thing}
-- The thing or name of the thing to query.
--
-- @param owner @{thing}
-- The owner to query, if not given then the player is assumed.
local function is_carrying (self, item, owner)
	return search_first(self, item, owner or self.player, true)
end


--- Warp any thing to the player's inventory
local function purloin (self, what)
	-- wizard search, all rooms
	local thing, parent = self:search_first (what, nil, true)
	if thing then
		move_thing_into (self, thing, self.player)
		table.insert (self.output, string.format("Purloined the %s", thing.name))
	else
		table.insert (self.output, string.format("%s not found", tostring(what)))
	end
end


--- Get a list of children, contained or supported, by an item.
--
-- @param self @{instance}
--
-- @param item @{thing}
-- The item to query
--
-- @return table of children @{thing}s
local function list_children (self, item)

	local list = { }

	if type(item.contains) == "table" then
		for _, v in pairs(item.contains) do
			table.insert(list, v)
		end
	end

	if type(item.supports) == "table" then
		for _, v in pairs(item.supports) do
			table.insert(list, v)
		end
	end

	return list

end


--- Get a room by its name.
-- This method does not limit the scope of the search.
--
--
-- @param self @{instance}
--
-- @param name string
-- The name of the room to query.
--
-- @return @{thing} or nil if no exit in that direction.
local function room_by_name (self, name)
	name = string.lower(name)
	for _, r in pairs(self.world) do
		if string.lower(r.name) == name then
			return r
		end
	end
end


--- Get the room adjoining the current by direction
--
-- @param self @{instance}
--
-- @param direction string
-- The name of the direction to query.
--
-- @return @{thing} or nil if no exit in that direction.
local function room_by_direction (self, direction)
	if not self.room.exits then
		return
	end
	local way = self.room.exits[direction]
	if not way then
		return
	end
	return room_by_name (self, way)
end


--- Simulate an action in the world.
-- This requires a valid world state (room and a player is set).
-- This action does not forward the turn counter.
--
-- @param self
-- @{instance}
--
-- @param command
-- The @{command} to simulate.
--
-- @return boolean
-- True if the action succeeded.
local function simulate (self, command)

	-- Evaluate room light levels
	consult_rulebook (self, "before", "simulate")

	local queue = { }

	-- The command applies to ALL items
	local refersAll = (not command.first_item) and (command.first_noun == "all")

	if refersAll then

		-- The ALL rulebook should identify the thing we are looking
		-- at during the bulk action, stored in the allFrom value.
		if consult_rulebook (self, "all", command) then

			-- Queue a new command for each child item
			local children = list_children (self, command.allFrom)
			for _, child in ipairs (children) do
				if not child.isPlayer then
					local newcommand = { }
					for commandKey, commandValue in pairs (command) do
						newcommand[commandKey] = commandValue
					end
					newcommand.first_item = child
					table.insert (queue, newcommand)
				end
			end
		end
	else
		-- Only queue a single command
		table.insert (queue, command)
	end

	-- Process each command in the queue
	for _, cmd in ipairs (queue) do
		if consult_rulebook (self, "before", cmd) then
			count_verb_usage (self, cmd)
			consult_rulebook (self, "on", cmd)
			consult_rulebook (self, "after", cmd)
		end
	end

end


--- Calls a predefined hook that was defined by you, for the given
-- noun/verb combination of the command.
--
-- @param self
-- @param command
-- The @{command} object to check for hook existence.
local function callHook (self, command)

	-- Call any hooks for the verb and noun
	if type(self.hooks[command.verb]) == "table" then

		local noun = command.nouns[1]
		local hook = self.hooks[command.verb][noun]

		if type(hook) == "function" then
			return hook(self, command)
		end

	end

end


--- List the nouns in the room that the player is in.
-- Used to assist the parser in noun lookup.
--
-- @param self @{instance}
--
-- @return table of nouns
local function list_room_nouns (self)

	local checklist = { }
	local nounlist = { }

	for k, r in pairs(self.room.contains) do
		table.insert(checklist, r)
	end

	while #checklist > 0 do

		local v = table.remove(checklist)
		table.insert(nounlist, v.name)

		if type(v.contains) == "table" then
			for a, b in pairs(v.contains) do
				table.insert(checklist, b)
			end
		end
		if type(v.supports) == "table" then
			for a, b in pairs(v.supports) do
				table.insert(checklist, b)
			end
		end
		if type(v.parts) == "table" then
			for a, b in pairs(v.parts) do
				table.insert(checklist, b)
			end
		end

	end

	return nounlist

end


--- Test if the rulebooks will recognise a verb.
-- This function scans the rulebooks to determine
-- if the verb is implemented.
--
-- @param self
-- @{instance}
--
-- @param verb string
--
-- @return Boolean
local function is_verb_valid (self, verb)
	local valid = false

	-- test before rules
	if self.rulebooks.before[verb] then
		valid = true
	end

	-- test on rules
	if self.rulebooks.on[verb] then
		valid = true
	end

	return valid
end


--- Parse a sentence into a command object.
-- The player's location is inferred when parsing so that visible
-- items are matched to the nouns in the sentence.
--
-- @param self
-- @{instance}
--
-- @param sentence string
--
-- @return @{command} object
local function parse (self, sentence)

	local parser = require("parser")

	-- list of known nouns in the current room
	local known_nouns = list_room_nouns(self)

	-- Parse the sentence
	local command = parser (sentence, {
		known_nouns = known_nouns,
		directions = self.options.directions,
		ignores = self.options.ignores,
		synonyms = self.options.synonyms,
		soundex = self.options.soundex
		})

	-- Alias nouns
	command.first_noun = command.nouns[1]
	command.second_noun = command.nouns[2]

	-- Lookup world items by name
	command.first_item = self:search_first(command.first_noun, self.room)
	command.second_item = self:search_first(command.second_noun, self.room)

	-- Handle referring to "it"
	if (command.first_noun == "it") and (not command.first_item) then
		command.first_item = self.lastKnownThing
	else
		self.lastKnownThing = command.first_item
	end

	-- Handle "going" a direction.
	-- Exits could point to items like doors.
	-- If there is no found item, try to find it using the
	-- name of the thing stored in the exit direction.
	-- The item will remain nil if it is not a thing.
	if command.verb == "go" and command.direction then
		if not command.first_item and self.room.exits then
			command.first_item = search_first(self, self.room.exits[command.direction], self.room)
		end
	end

	-- Log the parsed values
	if self.options.verbose.parser then

		table.insert(self.log,
			string.format("Parsed verb as %q", tostring(command.verb)))

		table.insert(self.log,
			string.format("Parsed first noun as %q", tostring(command.first_noun)))

		table.insert(self.log,
			string.format("Parsed second noun as %q", tostring(command.second_noun)))

		table.insert(self.log,
			string.format("Parsed direction as %q", tostring(command.direction)))

	end

	return command

end


--- Process the player's turn.
-- The sentence is parsed into actionable verbs and nouns, those are
-- applied to the world model and a response is generated.
--
-- @function turn
--
-- @param self The moonlight instance.
--
-- @param sentence The input sentence that is parsed into actions.
--
-- @return @{command}
local function turn (self, sentence)

	-- Clear the previous turn output and log
	self.output = { }
	self.log = { }

	-- Consult the "before turn" rulebook
	if consult_rulebook (self, "before", "turn") == false then
		return
	end

	-- Parse the sentence
	local command = self:parse (sentence)

	-- Do we understand the verb?
	if not is_verb_valid (self, command.verb) then
		table.insert(self.output, string.format(self.responses.unknown["verb"], command.verb))
		return command
	end

	-- call any hooks for this command
	local hookSet, hookResponse = callHook(self, command)

	-- the hook has handled the request
	if hookSet then
		-- add a custom response if there is one
		if hookResponse then
			table.insert(self.output, hookResponse)
		end
		-- stop further processing
		return command
	end

	-- refer the special reword rulebook, which can change the verb
	-- to make more sense to the simulation
	consult_rulebook (self, "reword", command)

	-- Process independent agents
	agency:turn (self)

	-- apply the player command to the simulation
	simulate (self, command)

	-- add a custom response if there is one
	-- TODO hooks obsoleted by rulebooks
	if hookResponse then
		table.insert(self.output, hookResponse)
	end

	consult_rulebook (self, "after", "turn")

	-- Increase the turn
	self.turnNumber = self.turnNumber + 1

	return command

end


--- Add a callback hook for any verb and noun combination.
-- If verb and noun match the parsed command it triggers the callback.
-- A nil noun matches any verb, while a nil verb is not allowed.
-- The callback should return a false to stop further turn processing.
-- @function hook
--
-- @param self
--
-- @param verb
-- The verb that triggers the hook.
--
-- @param noun
-- The noun that triggers the hook.
--
-- @param callback
-- The function to call when the hook is triggered.
--
-- TODO hooks obsoleted by rulebooks
local function hook (self, verb, noun, callback)

	if type(verb) == "nil" then
		error(string.format("No verb provided for the hook."), noun)
	end

	self.hooks[verb] = self.hooks[verb] or { }

	-- use default if noun is nil
	if type(noun) == "nil" then
		noun = "default"
	end

	self.hooks[verb][noun] = callback

end


--- The moonlight instance.
-- @table instance
-- @field options The simulator @{options}
-- @field world A table of @{thing}s that make up the simulated world.
-- @field turn The @{turn} function.
-- @field hook The @{hook} function.
-- @field set_player The @{set_player} function.
-- @field output The @{output} table from the last @{turn}.
-- @field turnNumber The simulation turn number.
return {
	options = options,
	responses = responses,
	turn = turn,
	hook = hook,
	output = { },
	log = { },
	utils = utils,
	turnNumber = 1,
	rulebooks = { },
	-- functions
	agency = agency,
	simulate = simulate,
	reset_simulation = reset_simulation,
	load_world = load_world,
	set_player = set_player,
	is_carrying = is_carrying,
	move_player = move_player,
	move_thing_into = move_thing_into,
	move_thing_onto  = move_thing_onto,
	describe = describe,
	list_room_exits = list_room_exits,
	room_by_name = room_by_name,
	room_by_direction = room_by_direction,
	list_inventory = list_inventory,
	format_name = format_name,
	list_contents = list_contents,
	search = search,
	search_first = search_first,
	validate = require("world_validator"),
	detach = detach,
	purloin = purloin,
	parse = parse,
	hooks = { },
}
