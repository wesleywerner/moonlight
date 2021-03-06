local options = {
	ignores = { "an", "a", "the", "for", "to", "at", "of",
		"with", "about", "on", "and", "from", "into" },
	synonyms = {
		{ "attack", "hit", "smash", "kick", "cut", "kill" },
		{ "go", "enter" },
		{ "insert", "put" },
		{ "take", "get", "pick" },
		{ "inventory", "i" },
		{ "examine", "x", "l", "look" },
		{ "north", "n" },
		{ "south", "s" },
		{ "east", "e" },
		{ "west", "w" },
		{ "northeast", "ne" },
		{ "southeast", "se" },
		{ "northwest", "nw" },
		{ "southwest", "sw" },
		{ "in", "inside" },
		{ "out", "outside" }
	},
	vowels = {"a", "e", "i", "o", "u"},
	directions = {
		"n","north",
		"s","south",
		"e","east",
		"w","west",
		"ne", "northeast",
		"se", "southeast",
		"nw", "northwest",
		"sw", "southwest",
		"up",
		"down",
		"in", "inside",
		"out", "outside",
		"under", "behind"
		},
	verbose = {
		rulebooks = true,
		parser = true,
		descriptions = false
	},
	-- enable testing to load the purloin rules
	testing = true
}

return options
