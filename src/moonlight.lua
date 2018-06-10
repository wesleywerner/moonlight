

local options = {
	ignores = {"an", "a", "the", "for", "to", "at", "of", "with", "about", "on"},
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
	supporterLead = "On it is %s."
}

--- API callbacks for [verb][noun] combinations
local hooks = { }

--- Split a string.
local function split(s, delimiter)
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
	if t == nil then
		print("this one is nil", cmp)
	end
	return indexOf(t, cmp) > 0
end


--- Parse a sentence and return a table of the verb, target item and nouns.
local function parse (self, sentence, known_nouns)

	-- Split the sentence into parts. Always work in lowercase.
	local parts = split(sentence:lower(), " ")

	-- Extract the direction.
	local direction = find(parts, function(k, v)
		return contains(self.options.directions, v)
	end)

	-- Remove ignored words and directions from further processing.
	parts = filter(parts, function(k, v)
		return not contains(self.options.directions, v)
	end)

	parts = filter(parts, function(k, v)
		return not contains(self.options.ignores, v)
	end)

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
	parts = filter(parts, function(k, v)
		return indexOf(parts, v) == k
	end)

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
local function findPlayer(self)

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


--- Finds the given item by name
local function findItem(self, name)

	local checklist = { }

	if type(self.room.contains) == "table" then
		for a, b in pairs(self.room.contains) do
			table.insert(checklist, b)
		end
	end

	while #checklist > 0 do

		local v = table.remove(checklist)

		if v.name == name then
			return v
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


--- Returns the given name with the article prefixed.
local function withArticle(self, noun)

	if noun.person == true then
		return noun.name
	end

	if noun.article then
		return string.format("%s %s", noun.article, noun.name)
	end

	if indexOf(self.options.vowels, string.sub(noun.name, 1, 1)) == 0 then
		return string.format("a %s", noun.name)
	else
		return string.format("an %s", noun.name)
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


--- Describes the given noun.
local function describe(self, noun, isRoom)

	-- default item description if none is specified
	local desc = noun.description or string.format("It is a %s.", noun.name)

	-- list all the items contained in the noun, or on top of the noun.
	local items = { }
	local containerText = nil
	local supporterText = nil

	if type(noun.contains) == "table" then
		for k, v in pairs(noun.contains) do
			if not v.player then
				table.insert(items, withArticle(self, v))
			end
		end
		-- switch to room lead text
		if isRoom then
			containerText = string.format(self.options.roomLead, joinNames(self, items))
		else
			containerText = string.format(self.options.containerLead, joinNames(self, items))
		end
	end

	-- list things on top of the noun
	if type(noun.supports) == "table" then
		for k, v in pairs(noun.supports) do
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


--- Apply a parsed command to a world model.
-- The model can be a partial view of the world, usually the room
-- that the player is in.
local function apply (self, command)

	local nounIsRoom = false
	local noun = findItem(self, command.nouns[1])

	-- apply the verb to the room if no nouns are given
	if #command.nouns == 0 then
		noun = self.room
		nounIsRoom = true
	end

	-- TODO: add response
	if noun == nil then
		table.insert(self.responses, "I don't see the " .. command.nouns[1])
		return false
	end

	print("applying " .. command.verb .. " to " .. tostring(noun.name))

	if command.verb == "examine" then

		if nounIsRoom then
			table.insert(self.responses, describe(self, noun, true))
		else
			table.insert(self.responses, describe(self, noun))
		end
		return true

	end

end


--- Calls a verb/noun hook if it exists.
local function callHook(self, command)

	-- Call any hooks for the verb and noun
	if type(hooks[command.verb]) == "table" then

		local noun = command.nouns[1]
		local hook = hooks[command.verb][noun]

		if type(hook) == "function" then
			local hookResult = hook(self, command.verb, noun, command)
			-- Stop further processing
			if hookResult == false then
				return
			end
		end

	end

end


--- The main turn step.
-- The given sentence is parsed, applied to the world model
-- and a response is generated.
local function turn (self, sentence)

	-- Clear the previous turn responses
	self.responses = { }

	self.player, self.room = findPlayer(self)

	-- TODO: boil the room down

	if self.player == nil then
		error("I could not find a player in the world. They should have the \"player\" value of true.")
	end

	-- Parse the sentence
	-- TODO: get list of known nouns from the current room
	local command = parse (self, sentence)

	if callHook(self, command) == false then
		return false
	end

	-- Apply the command to the model
	local commandResult = apply (self, command)

	-- Increase the turn
	if commandResult == true then
		self.turnNumber = self.turnNumber + 1
	end

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
return { options=options, parse=parse, turn=turn, hook=hook, responses={}, turnNumber=1 }
