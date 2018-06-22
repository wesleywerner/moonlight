

local options = {
	verbs = { "examine", "take", "attack", "inventory", "insert" },
	ignores = {"an", "a", "the", "for", "to", "at", "of", "with", "about", "on", "and"},
	synonymns = {
		{"attack", "hit", "smash", "kick", "cut", "kill"},
		{"insert", "put"},
		{"take", "get", "pick"},
		{"inventory", "i"},
		{"examine", "x", "l", "look"},
	},
	vowels = {"a", "e", "i", "o", "u"},
	directions = {
		"north", "n",
		"south", "s",
		"east", "e",
		"west", "w",
		"northeast", "ne",
		"southeast", "se",
		"northwest", "nw",
		"southwest", "sw",
		"up", "down", "in", "out"
		},
	roomLead = "There is %s here.",
	containerLead = "Inside it is %s.",
	supporterLead = "On it is %s.",
	defaultResponses = {
		fixedInPlace = "The %s is fixed in place.",
		thingNotSeen = "I don't see the %s.",
		takePerson = "%s wouldn't like that.",
		taken = "You take the %s.",
		alreadyHaveIt = "You already have it.",
		unknownVerb = "I don't know what %q means."
	}
}

--- API callbacks for [verb][noun] combinations
local hooks = { }

--- Split a string.
local function split (s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end


local function find (t, f)
	for k, v in pairs(t) do
		if f(k, v) then
			return v
		end
	end
	return nil
end


local function filter (t, f)
	local matches = {}
	for k, v in pairs(t) do
		if f(k, v) then
			table.insert(matches, v)
		end
	end
	return matches
end


local function indexOf (t, cmp)
	for k, v in pairs(t) do
		if v == cmp then
			return k
		end
	end
	return 0
end


local function contains (t, cmp)
	return indexOf(t, cmp) > 0
end


--- Parse a sentence and return a table of the verb, target item and nouns.
local function parse (self, sentence, known_nouns)

	-- Split the sentence into parts. Always work in lowercase.
	local parts = split(sentence:lower(), " ")

	-- Extract the direction.
	local function findDirectionFilter(k, v)
		return contains(self.options.directions, v)
	end

	local direction = find(parts, findDirectionFilter)

	-- Remove ignored words and directions from further processing.
	local function removeDirectionsFilter(k, v)
		return not contains(self.options.directions, v)
	end

	parts = filter(parts, removeDirectionsFilter)

	local function removeIgnoresFilter(k, v)
		return not contains(self.options.ignores, v)
	end

	parts = filter(parts, removeIgnoresFilter)

	-- Replace any partial nouns with the known nouns.
	-- If a partial matches multiple known nouns, it will match the last one.
	if known_nouns then
		for partno, part in ipairs(parts) do
			for nounno, noun in ipairs(known_nouns) do
				-- if the part matches a known noun
				if string.match(noun, part) then
					-- replace the part with the match
					parts[partno] = noun
				end
			end
		end
	end

	-- Remove duplicates which can occur from the above step.
	local function removeDuplicatesFilter(k, v)
		return indexOf(parts, v) == k
	end

	parts = filter(parts, removeDuplicatesFilter)

	-- Extract the verb
	local verb = #parts > 0 and parts[1]

	-- Extract the nouns.
	local nouns = parts
	if #parts > 1 then
		-- remove the verb
		table.remove(nouns, 1)
	else
		nouns = { }
	end

	-- Change verbs to their root synonymn.
	-- The first entry is the synonym list is the root word.
	for i, wl in ipairs(self.options.synonymns) do
		if contains(wl, verb) then
			verb = wl[1]
		end
	end

	return { verb=verb, nouns=nouns, direction=direction }

end


--- Finds the player in the world model.
local function findPlayer (self)

	if not self.world then
		error("The world is empty, you must set the world value first.")
	end

	for k, r in pairs(self.world) do

		local checklist = { }

		if type(r.contains) == "table" then
			for a, b in pairs(r.contains) do
				table.insert(checklist, b)
			end
		end

		while #checklist > 0 do

			local v = table.remove(checklist)

			if v.player == true then
				return v, r
			end

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

	end

end


--- Find an item by name in a parent.
local function search (self, term, parent, stack)

	-- can search by name or by item
	local isItemSearch = type(term) == "table"

	-- init searched table stack
	stack = stack or { }
	local container = nil

	if type(parent.contains) == "table" and not stack[parent.contains] then
		--print(tostring(parent.name) .. " is a container")
		container = parent.contains
	elseif type(parent.supports) == "table" and not stack[parent.supports] then
		--print(tostring(parent.name) .. " is a supporter")
		container = parent.supports
	end

	if container then

		for i, v in ipairs(container) do
			if isItemSearch then
				if v == term then
					return v, parent, i
				end
			else
				if string.lower(tostring(v.name)) == term then
					--print("found " .. tostring(term) .. " in " .. tostring(parent.name) .. "!")
					return v, parent, i
				end
			end
		end

		for k, v in ipairs(container) do
			-- TODO this might cause bugs if the item is both a supporter and a container.
			-- stack only tracks the searched space for one of those cases.
			if not stack[v] and (type(v.contains) == "table" or type(v.supports) == "table") then
				--print("looking inside " .. tostring(v.name))
				stack[v] = true
				local resv, resp = search(self, term, v, stack)
				if resv then
					return resv, resp
				end
			end
		end

	end

end


--- Returns the given name with the article prefixed.
local function withArticle (self, item)

	if item.person == true then
		return item.name
	end

	if item.article then
		return string.format("%s %s", item.article, item.name)
	end

	if indexOf(self.options.vowels, string.sub(item.name, 1, 1)) == 0 then
		return string.format("a %s", item.name)
	else
		return string.format("an %s", item.name)
	end

end


--- Joins an array of items to read naturally.
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


--- Describes the given item.
local function describe (self, item, leadFormat)

	-- default item description if none is specified
	local desc = item.description or string.format("It is a %s.", item.name)

	-- list all the items contained in the item, or on top of the item.
	local items = { }
	local containerText = nil
	local supporterText = nil

	if type(item.contains) == "table" then
		for k, v in pairs(item.contains) do
			if not v.player then
				table.insert(items, withArticle(self, v))
			end
		end
		containerText = string.format(leadFormat or self.options.containerLead, joinNames(self, items))
	end

	-- clear items list for supporter listing
	items = { }

	-- list things on top of the item
	if type(item.supports) == "table" then
		for k, v in pairs(item.supports) do
			table.insert(items, withArticle(self, v))
		end
		supporterText = string.format(self.options.supporterLead, joinNames(self, items))
	end

	if containerText and supporterText then
		return string.format("%s %s %s", desc, containerText, supporterText)
	elseif containerText then
		return string.format("%s %s", desc, containerText)
	elseif supporterText then
		return string.format("%s %s", desc, supporterText)
	else
		return desc
	end

end


--- Moves an item to another item.
local function move (self, item, parent)

	local item, oldparent, idx = search(self, item.name, self.room)

	if item and parent and oldparent then
		table.remove(oldparent.contains, idx)
		table.insert(parent.contains, item)
		return true
	end

end


local function playerHas (self, item)

	return search(self, item, self.player) ~= nil

end


--- Try to take the given item.
local function tryTake (self, item)

	if not item then
		table.insert(self.responses, "What do you want to take?")
		return false
	end

	if item.person then
		table.insert(self.responses, string.format(self.options.defaultResponses.takePerson, item.name))
		return false
	end

	if item.fixed then
		table.insert(self.responses, string.format(self.options.defaultResponses.fixedInPlace, item.name))
		return false
	end

	if playerHas(self, item) then
		table.insert(self.responses, self.options.defaultResponses.alreadyHaveIt)
		return false
	end

	-- TODO space check

	-- success
	table.insert(self.responses, string.format(self.options.defaultResponses.taken, item.name))
	move(self, item, self.player)
	return true

end


local function commandMissingNouns (self, command)
	return #command.nouns == 0
end

--- Counts the number of times a verb is used on each item
local function countVerbUsedOnNoun (self, command)
	if command.item1 then
		command.item1.count = command.item1.count or { }
		command.item1.count[command.verb] = (command.item1.count[command.verb] or 0) + 1
	end
end

--- Apply a parsed command to a world model.
-- The model can be a partial view of the world, usually the room
-- that the player is in.
local function apply (self, command)

	countVerbUsedOnNoun (self, command)

	if command.verb == "examine" then

		-- default to examining the room
		if commandMissingNouns(self, command) then
			table.insert(self.responses, describe(self, self.room, self.options.roomLead))
		elseif command.item1 then
			table.insert(self.responses, describe(self, command.item1))
		end

		return true

	elseif command.verb == "take" then

		if not command.item1 then
			if commandMissingNouns(self, command) then
				table.insert(self.responses, "Be a little more specific what you want to take.")
				return false
			else
				table.insert(self.responses, string.format(self.options.defaultResponses.thingNotSeen, command.nouns[1]))
				return false
			end
		end

		return tryTake(self, command.item1)

	end

end


--- Calls a verb/noun hook if it exists.
local function callHook (self, command)

	-- Call any hooks for the verb and noun
	if type(hooks[command.verb]) == "table" then

		local noun = command.nouns[1]
		local hook = hooks[command.verb][noun]

		if type(hook) == "function" then
			return hook(self, command)
		end

	end

end


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


--- The main turn step.
-- The given sentence is parsed, applied to the world model
-- and a response is generated.
local function turn (self, sentence)

	-- Clear the previous turn responses
	self.responses = { }

	self.player, self.room = findPlayer(self)

	-- TODO: boil the room down (copy the room object but only inlcude items visible. do not mutate the original room contents.)

	if self.player == nil then
		error("I could not find a player in the world. They should have the \"player\" value of true.")
	end

	-- list of known nouns from the current room
	local known_nouns = listNouns(self)

	-- Parse the sentence
	local command = parse (self, sentence, known_nouns)

	-- Do we understand the verb?
	if not contains (self.options.verbs, command.verb) then
		table.insert(self.responses, string.format(self.options.defaultResponses.unknownVerb, command.verb))
		return false
	end

	-- look up each noun item
	command.item1, command.item1Parent = search(self, command.nouns[1], self.room)
	command.item2, command.item2Parent = search(self, command.nouns[2], self.room)

	-- call any hooks for this command
	local hookSet, hookResponse = callHook(self, command)

	-- the hook has handled the request
	if hookSet then
		-- add a custom response if there is one
		if hookResponse then
			table.insert(self.responses, hookResponse)
		end
		-- stop further processing
		return false
	end

	-- Apply the command to the model
	local commandResult = apply (self, command)

	if commandResult == true then

		-- add a custom response if there is one
		if hookResponse then
			table.insert(self.responses, hookResponse)
		end

		-- Increase the turn
		self.turnNumber = self.turnNumber + 1

	end

	return command

end


--- Provide an API that hooks into the turn step.
-- If verb and noun match the parsed command it triggers the callback.
-- A nil noun matches any. A nil verb should not be allowed.
-- The callback should return a false to stop further turn processing.
local function hook (self, verb, noun, callback)

	if type(verb) == "nil" then
		error(string.format("You tried to hook a nil verb for the %s noun. The verb has to be a word for the hook to be useful."), noun)
	end

	hooks[verb] = hooks[verb] or { }

	-- use default if noun is nil
	if type(noun) == "nil" then
		noun = "default"
	end

	hooks[verb][noun] = callback

end

-- return the lantern object
return {
	options = options,
	turn = turn,
	hook = hook,
	responses = { }, turnNumber=1,
	api = {
		search = search,
		parse = parse,
	}
}
