

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
-- @field item1
-- The world item (table) that matches the first of the nouns field.
-- If this has a value it is guaranteed to match an item in the world.
--
-- @field item2
-- The world item (table) that matches the second of the nouns field.
-- If this has a value it is guaranteed to match an item in the world.
--

------------------------------------------------------------------------

--- Output of responses generated by a turn.
-- And example response is:
-- {"You take the envelope", "It feels like there is something heavy inside it"}
--
-- @table output

------------------------------------------------------------------------

--- The world model definition.
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
-- see and do in dark rooms.
--
-- @field lit
-- A room is lit if dark and there is light source inside the room.
-- This value is set by the simulator, and is used in rulebooks to
-- determine visibililty.
--
-- @field exits
-- A key-value table of compass directions as keys, with room names
-- for values, of all the exits in a room.
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
-- A table of other things that is held. People and boxes can contain things.
--
-- @field supports
-- A table of other things supported. Tables can supporting things.
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

--- A table of options that define parser and response behavior.
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
-- @field auto
-- @{moonlight.auto} options that set automatic responses to certain actions.
--
-- @field soundex
-- A boolean to enable soundex matching of known nouns to the player's
-- input during sentence parsing.
--
-- @field verbose
-- A table of @{verboseOptions}.
local options = require ("options")

------------------------------------------------------------------------

--- List of standard responses.
-- It is categorized by [verb][state], where state varies by the action performed.
-- See the link to the source for the template wording.
--
-- @table responses
local responses = require ("responses")

local utils = require("utils")
local parse = require("parser")

--- Test if the command object refers to all things.
-- @return boolean
local function commandRefersAll (self, command)
	return (not command.item1) and (command.nouns[1] == "all")
end


--- Increment the number of times a noun has been verbed.
local function countVerbUsedOnNoun (self, command)
	-- the counter can live on a thing or a room
	local target = command.item1 or self.room
	local verb = command.verb

	if type(command) == "string" then
		verb = command
	end

	if target then
		target.count = target.count or { }
		target.count[verb] = (target.count[verb] or 0) + 1
	end
end


--- Builds the standard set of rulebooks.
local function standardRulebooks ()

	local rulebooks = {
		["before"] = { }, -- before action rules
		["on"] = { }, -- action rules
		["after"] = { }, -- after action rules
		["turn"] = { }, -- rules for before and after turns
	}

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

	return rulebooks

end


--- Reset the simulator.
-- Clears the internal state of the player, the world and loads
-- the standard rulebooks.
local function reset (self)
	self.rulebooks = standardRulebooks()
	self.player = nil
	self.room = nil
	self.world = nil
end


--- Test if the command passes checks in rulebook.
--
-- @param self
-- @{instance}
--
-- @param bookName
-- The name of the rulebook to test against.
--
-- @param command
-- The @{command} to validate.
--
-- @return boolean
local function referRulebook (self, bookName, command)

	local book = self.rulebooks[bookName]

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

			local message, result = rule.action(self, command)

			if self.options.verbose.rulebooks then
				table.insert (self.log,
				string.format("Consulted the [%s] [%s] [%s] rule: %s",
					bookName or "none",
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


local function thingClosed (self, thing)
	return thing.closed == true
end


local function thingDark (self, thing)
	if ((thing.dark == true) and not (thing.lit == true)) then
		return true
	end
	return false
end


--- Test if a thing is closed or dark, except when lit.
--
-- @param self
-- @{instance}
--
-- @param thing
-- The thing to query
--
-- @return
-- true if the thing is closed, or dark.
-- true if not closed, not dark, or dark and lit.
local function thingClosedOrDark (self, thing)
	return thingClosed (self, thing) or thingDark (self, thing)
--	if (thing.closed == true) then
--		return true
--	elseif ((thing.dark == true) and not (thing.lit == true)) then
--		return true
--	end
--	return false
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
-- @param parent
-- The room to search. If given as nil all rooms (inclusive) are searched.
--
-- @param wizard
-- Boolean flag includes searching things inside closed containers and
-- in dark unlit rooms.
--
-- @return
-- An indexed table of matches, each match a collection
-- { item, parent }
-- Returns nil if no matches found.
local function search (self, term, parent, options)

	-- helper to match a thing
	local function match (item)
		if type(term) == "string" then
			return string.lower(item.name) == string.lower(term)
		elseif type(term) == "table" then
			return item == term
		elseif type(term) == "function" then
			return term (item)
		end
	end

	-- options of true allows all
	if options == nil then
		options = {
			includeClosed = false,
			includeDark = false
		}
	elseif options == true then
		options = {
			includeClosed = true,
			includeDark = true
		}
	end

	-- helper to test if item contents should be queried,
	-- based on seen things and if the item is closed or dark.
	local function queryContents (item)
		if not options.includeDark and thingDark (self, item) then
			return false
		end
		if not options.includeClosed and thingClosed (self, item) then
			return false
		end
		return true
	end

	-- stored as { matched item, parent, index, parent type }
	local stack = { }

	-- stored as { matched item, parent, index, parent type }
	local results = { }

	if parent then
		-- include the parent in the search
		if queryContents (parent) then
			table.insert (stack, {parent})
		end
	else
		-- search all rooms if no parent specified
		for _, w in ipairs(self.world) do
			table.insert (stack, {w})
		end
	end

	-- while there are things on the stack to search
	while #stack > 0 do

		-- query the next item
		local item, itemparent, index, ctype = unpack (table.remove(stack))

		-- queue all it's children for later querying
		if queryContents (item) then
			for i, n in ipairs(item.contains or {}) do
				table.insert (stack, { n, item, i, "container" })
			end
			for i, n in ipairs(item.supports or {}) do
				table.insert (stack, { n, item, i, "supporter" })
			end
		end

		-- test matching
		if match (item) then
			table.insert (results, { item, itemparent, index, ctype })
		end

	end

	if #results > 0 then
		return results
	end

end


--- Search and return the first match.
local function searchFirst (self, term, parent, options)
	local matches = search (self, term, parent, options)
	if matches then
		return unpack(matches[1])
	end
end


--- Set the player character in the world simulation.
-- @function setPlayer
-- @param self
-- @param name
-- The name of the player character.
local function setPlayer (self, name)

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


--- Set the world model.
local function setWorld (self, world)
	-- ensure all rooms can contain things
	for _, room in ipairs(world) do
		room.contains = room.contains or { }
	end
	self.world = world
	local valid, issues = self:validate (world)
	return valid, issues
end


--- Get the name of an item with the article prefixed.
local function withArticle (self, item)

	if item.person == true then
		-- TODO include article with the person
		return item.name
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


--- Joins an array of items to read naturally.
-- It joins a list of names with commas or "and" depending on how
-- many names are listed.
local function joinNames(self, names)

	if #names == 2 then
		return table.concat(names, " and ")
	elseif #names > 2 then
		local lastitem = table.remove(names)
		return table.concat(names, ", ") .. " and " .. lastitem
	else
		return table.concat(names)
	end

end


--- Lists the contents of a container or supporter.
--
-- @param self
--
-- @param item
-- The item that will be described
--
-- @return string
local function listContents (self, item)

	-- list all the items contained in the item, or on top of the item.
	local items = { }
	local containerText = nil
	local supporterText = nil

	-- default container lead text
	local lead = self.template.lead["container"]

	-- switch to room lead text
	local isRoom = self:roomByName (item.name)
	if isRoom then
		lead = self.template.lead["room"]
	end

	if item.contains and not self:thingClosedOrDark (item) then
		for k, v in pairs(item.contains) do
			-- list items that are not the player, or don't have custom appearances.
			if not v.isPlayer and not v.appearance then
				table.insert(items, withArticle(self, v))
			end
		end
		if #items > 0 then
			containerText = string.format(lead, joinNames(self, items))
		end
	end

	-- clear items list for supporter listing
	items = { }

	-- list things on top of the item
	if item.supports then
		for k, v in pairs(item.supports) do
			-- list items that are not the player, or don't have custom appearances.
			if not v.isPlayer and not v.appearance then
				table.insert(items, withArticle(self, v))
			end
		end
		if #items > 0 then
			supporterText = string.format(self.template.lead["supporter"], joinNames(self, items))
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


local function listAppearances (self, item)

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
-- @param leadFormat
-- The description format which can vary for rooms vs containers.
--
-- @return string
local function describe (self, item, brief)

	-- default item description if none is specified
	local desc = item.description or string.format("It is a %s.", item.name)
	local specialAppearances = listAppearances (self, item)
	local contents = listContents (self, item)

	-- check if brief room descriptions have effect
	if brief then
		local verbose = self.options.verbose.descriptions
		local firstVisit = item.count["examine"] == 1
		if (not verbose and not firstVisit) then
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

--- Describe room.
local function describeRoom (self, brief)

	local output = { }
	table.insert (output, describe (self, self.room, brief))
	table.insert (output, self:listRoomExits())
	return table.concat (output, " ")

end


--- List exits in a room.
local function listRoomExits (self)

	-- always list exits in a dark room
	local darkroom = self.room.dark and not self.room.lit

	if self.options.auto["list exits"] or darkroom then
		if type(self.room.exits) == "table" then
			local possibleWays = { }
			for k, v in pairs(self.room.exits) do
				table.insert(possibleWays, k)
			end
			if #possibleWays > 0 then
				table.sort(possibleWays)
				return "You can go " .. joinNames(self, possibleWays) .. "."
			end
		end
	end

	return nil

end


--- Lists items carried by the player.
-- @return string
local function listInventory (self)

	if #self.player.contains == 0 then
		return self.template.inventory["empty"]
	end

	local items = { }

	for _, v in pairs(self.player.contains) do
		table.insert (items, withArticle (self, v))
	end

	return string.format ("You are carrying %s.", joinNames (self, items))

end


--- Detach a thing from it's parent
--
-- @param self
-- @{instance}
--
-- @thing
-- The @{thing} to detach
local function detach (self, thing)
	local _, parent = self:searchFirst (thing)
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
	end
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
local function moveIn (self, what, where)
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
local function moveOn (self, what, where)
	self:detach (what)
	table.insert(where.supports, what)
end


--- Test if a persons is carrying a thing.
local function isCarrying (self, item, owner)
	return searchFirst(self, item, owner or self.player, true)
end


--- Warp any thing to the player's inventory
local function purloin (self, what)
	-- wizard search, all rooms
	local thing, parent = self:searchFirst (what, nil, true)
	if thing then
		moveIn (self, thing, self.player)
		table.insert (self.output, string.format("Purloined the %s", thing.name))
	else
		table.insert (self.output, string.format("%s not found", tostring(what)))
	end
end


--- Get a list of children, contained or supported, by an item.
local function listChildrenOf (self, item)

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


--- Get a room by name.
local function roomByName (self, name)
	name = string.lower(name)
	for _, r in pairs(self.world) do
		if string.lower(r.name) == name then
			return r
		end
	end
end


--- Get the room adjoining the current by direction
local function roomByDirection (self, direction)
	if not self.room.exits then
		return
	end
	local way = self.room.exits[direction]
	if not way then
		return
	end
	return roomByName (self, way)
end


--- Apply a command to a world model.
-- This forwards the simulation by performing the command action against
-- the command nouns.
--
-- @return boolean
-- If the action succeeded.
local function applyCommand (self, command)

	local queue = { }

	-- this command applies to ALL things
	if commandRefersAll (self, command) then

		-- refer to the ALL rulebook if we can iterate over ALL things
		if referRulebook (self, "all", command) then

			-- The ALL rulebook should identify the thing we are looking
			-- at during the bulk action, stored in the allFrom value.
			local children = listChildrenOf (self, command.allFrom)

			for _, child in ipairs (children) do

				-- ignoring the player
				if not child.isPlayer then

					-- repack the command table
					-- (otherwise each iteration overrides the
					--  previous command reference)
					local newcommand = { }
					for commandKey, commandValue in pairs (command) do
						newcommand[commandKey] = commandValue
					end

					-- promote this child to item1
					newcommand.item1 = child
					newcommand.item1Parent = command.allFrom
					table.insert (queue, newcommand)

				end
			end
		end

	else
		table.insert (queue, command)
	end

	for _, cmd in ipairs (queue) do

		--print("\t", cmd.verb, cmd.item1.name, cmd.item2.name)

		-- call "before" rules
		-- explicit false results stops further processing
		if referRulebook (self, "before", cmd) then

			countVerbUsedOnNoun (self, cmd)

			-- call "on" rules
			referRulebook (self, "on", cmd)

			-- call "after" rules
			referRulebook (self, "after", cmd)

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
	if type(self.api.hooks[command.verb]) == "table" then

		local noun = command.nouns[1]
		local hook = self.api.hooks[command.verb][noun]

		if type(hook) == "function" then
			return hook(self, command)
		end

	end

end


--- List the nouns in the current room.
-- Used to assist the parser in noun lookup.
local function listNouns (self)

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

	end

	return nounlist

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

	if referRulebook (self, "turn", "before") == false then
		return
	end

	-- list of known nouns from the current room
	local known_nouns = listNouns(self)

	-- Parse the sentence
	local command = parse (sentence, {
		known_nouns = known_nouns,
		directions = self.options.directions,
		ignores = self.options.ignores,
		synonyms = self.options.synonyms,
		soundex = self.options.soundex
		})

	if self.options.verbose.parser then
		table.insert(self.log, string.format("Parsed verb as %s", tostring(command.verb)))
		table.insert(self.log, string.format("Parsed 1st noun as %s", tostring(command.nouns[1])))
		table.insert(self.log, string.format("Parsed 2nd noun as %s", tostring(command.nouns[2])))
		table.insert(self.log, string.format("Parsed direction as %s", tostring(command.direction)))
	end

	-- Do we understand the verb?
	if not utils.contains (self.options.verbs, command.verb) then
		table.insert(self.output, string.format(self.template.unknown["verb"], command.verb))
		return command
	end

	-- look up each noun item
	command.item1, command.item1Parent = searchFirst(self, command.nouns[1], self.room)
	command.item2, command.item2Parent = searchFirst(self, command.nouns[2], self.room)

	-- handle the player referring to "it"
	if (command.nouns[1] == "it") and (not command.item1) then
		command.item1 = self.lastKnownThing
	else
		self.lastKnownThing = command.item1
	end

	-- Exits could point to things too, like doors.
	-- If there is no command item, attempt to find it using the
	-- direction value. The item will remain nil if it is not a thing.
	if command.verb == "go" and command.direction then
		if not command.item1 and self.room.exits then
			command.item1 = searchFirst(self, self.room.exits[command.direction], self.room)
		end
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
	referRulebook (self, "reword", command)

	-- apply the player command to the simulation
	applyCommand (self, command)

	-- add a custom response if there is one
	-- TODO hooks obsoleted by rulebooks
	if hookResponse then
		table.insert(self.output, hookResponse)
	end

	referRulebook (self, "after", "turn")

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
-- TODO see hook example
local function hook (self, verb, noun, callback)

	if type(verb) == "nil" then
		error(string.format("No verb provided for the hook."), noun)
	end

	self.api.hooks[verb] = self.api.hooks[verb] or { }

	-- use default if noun is nil
	if type(noun) == "nil" then
		noun = "default"
	end

	self.api.hooks[verb][noun] = callback

end


--- Lists all the rulebooks and rules.
local function listRulebooks (self)
	for timing, collection in pairs(self.rulebooks) do
		for action, rules in pairs(collection) do
			print(string.format("The %s.%s book contains:", timing, action))
			for _, rule in ipairs(rules) do
				print(string.format("\tThe %s rule", rule.name))
			end
		end
	end
end


--- The moonlight instance.
-- @table instance
-- @field options The simulator @{options}
-- @field world A table of @{thing}s that make up the simulated world.
-- @field turn The @{turn} function.
-- @field hook The @{hook} function.
-- @field setPlayer The @{setPlayer} function.
-- @field output The @{output} table from the last @{turn}.
-- @field turnNumber The simulation turn number.
-- @field api The @{api} table.
return {
	options = options,
	template = responses,
	turn = turn,
	hook = hook,
	output = { },
	log = { },
	utils = utils,
	turnNumber = 1,
	rulebooks = standardRulebooks (),
	-- functions
	applyCommand = applyCommand,
	reset = reset,
	setWorld = setWorld,
	setPlayer = setPlayer,
	isCarrying = isCarrying,
	moveIn = moveIn,
	moveOn  = moveOn,
	describe = describe,
	describeRoom = describeRoom,
	listRoomExits = listRoomExits,
	roomByName = roomByName,
	roomByDirection = roomByDirection,
	listInventory = listInventory,
	withArticle = withArticle,
	listRulebooks = listRulebooks,
	listContents = listContents,
	search = search,
	searchFirst = searchFirst,
	validate = require("world_validator"),
	thingClosedOrDark = thingClosedOrDark,
	detach = detach,
	purloin = purloin,

	--- Used internally.
	-- This table contains functions and other tables used by the
	-- simulator. It is exposed to provide access to unit testing of
	-- the simulator logic.
	-- @table api
	api = {
		parse = parse, -- @{parser.parse}
		hooks = { }, -- The hooks as defined by @{hook}
	}
}
