

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
		}
}

--- API callbacks for [verb][noun] combinations
local hooks = { }

-- List of output responses for the current turn
local responses = { }

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
	
	-- Extract the target noun
	local item = nil
	if #parts > 1 then
		item = parts[2]
	end
	
	-- Remove first two parts to get the remaining nouns.
	local nouns = parts
	if #parts > 2 then
		table.remove(nouns, 1)
		table.remove(nouns, 1)
	else
		nouns = nil
	end

	-- Change verbs to their root synonymn.
	-- The first entry is the synonym list is the root word.
	for i, wl in ipairs(self.options.synonymns) do
		if contains(wl, verb) then
			verb = wl[1]
		end
	end

	-- TODO: rename item to noun
	return { verb=verb, item=item, direction=direction, nouns=nouns }

end


--- Apply a parsed command to a world model.
-- The model can be a partial view of the world, usually the room
-- that the player is in.
local function apply (self, command)



end


--- The main turn step.
-- The given sentence is parsed, applied to the world model
-- and a response is generated.
local function turn (self, sentence)

	-- Clear the previous turn responses
	responses = { }

	-- Parse the sentence
	local command = parse (self, sentence)
	
	-- Call any hooks for the verb and noun
	if type(hooks[command.verb]) == "table" then
		local hook = hooks[command.verb][command.item]
		if type(hook) == "function" then
			local hookResult = hook(self, command)
			-- Stop further processing
			if hookResult == false then
				return
			end
		end
	end
	
	-- Apply the command to the model
	local commandResult = apply (self, command)
	
	-- Increase the turn
	if commandResult == true then
		
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
return { options=options, parse=parse, turn=turn, hook=hook, responses=responses }
