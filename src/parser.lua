local utils = require("utils")

--- Parse a sentence into a command object.
-- It extracts the verb and nouns from the sentence, and partially
-- input noun names are replaced by their full equivalent.
-- @function parse
--
-- @param self
--
-- @param sentence
-- The sentence to parse.
--
-- @param options
-- Table of options.
-- known_nouns
-- (a table of noun names to match partial noun names in the sentence),
-- directions (a table of known compass directions in all variations),
-- ignores
-- (a table of words to ignore)
-- synonyms
-- (a list of tables of synonymous words, the first word being the root)
--
-- @return @{command}
return function (sentence, options)

	-- assume safe defaults
	options = options or { }
	options.directions = options.directions or { }
	options.ignores = options.ignores or { }
	options.synonyms = options.synonyms or { }

	-- Split the sentence into parts. Always work in lowercase.
	local parts = utils.split(sentence:lower(), " ")

	-- Extract the direction.
	local function findDirectionFilter(k, v)
		return utils.contains(options.directions, v)
	end

	local direction = utils.find(parts, findDirectionFilter)

	-- Remove directions
	local function removeDirectionsFilter(k, v)
		return not utils.contains(options.directions, v)
	end

	parts = utils.filter(parts, removeDirectionsFilter)

	-- Remove ignored words
	local function removeIgnoresFilter(k, v)
		return not utils.contains(options.ignores, v)
	end

	parts = utils.filter(parts, removeIgnoresFilter)

	-- Replace any partial nouns with the known nouns.
	-- If a partial matches multiple known nouns, it will match the last one.
	if options.known_nouns then
		for partno, part in ipairs(parts) do
			for nounno, noun in ipairs(options.known_nouns) do
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
		return utils.indexOf(parts, v) == k
	end

	parts = utils.filter(parts, removeDuplicatesFilter)

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

	-- Change verbs to their root synonym.
	-- The first entry is the synonym list is the root word.
	for i, wl in ipairs(options.synonyms) do
		if utils.contains(wl, verb) then
			verb = wl[1]
		end
	end

	-- Change direction to the root synonym.
	for i, wl in ipairs(options.synonyms) do
		if utils.contains(wl, direction) then
			direction = wl[1]
		end
	end

	return { verb=verb, nouns=nouns, direction=direction }

end

