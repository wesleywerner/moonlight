local responses = {
	["close"] = {
		["succeed"] = "You close the %s.",
		["when closed"] = "The %s is already closed.",
		["cannot"] = "The %s cannot be closed."
	},
	["examine"] = {
		["in the dark"] = "You are in the dark.",
	},
	["drop"] = {
		["success"] = "You drop the %s."
	},
	["go"] = {
		["cannot"] = "You cannot go that way."
	},
	["insert"] = {
		["in"] = "You put the %s in the %s.",
		["on"] = "You put the %s on the %s.",
		["not container"] = "You can't put things in %s.",
		["not supporter"] = "You can't put things on %s.",
		["into closed"] = "You can't put things in the %s, it is closed."
	},
	["inventory"] = {
		["in the dark"] = "It is too dark to do that.",
		["empty"] = "You are carrying nothing."
	},
	["lead"] = {
		["room"] = "There is %s here.",
		["supporter"] = "On it is %s.",
		["container"] = "Inside it is %s.",
	},
	["missing"] = {
		["direction"] = "I can't tell which direction you want to go, N, S, E or W?",
		["noun"] = "Be a little more specific what you want to %s."
	},
	["open"] = {
		["success"] = "You open the %s.",
		["when locked"] = "It is locked.",
		["when open"] = "The %s is already open.",
		["cannot"] = "The %s cannot be opened."
	},
	["take"] = {
		["in the dark"] = "It is too dark to do that.",
		["when carried"] = "You already have it.",
		["success"] = "You take the %s.",
		["person"] = "%s wouldn't like that.",
		["not container"] = "You can't put things in %s.",
		["from closed container"] = "The %s is closed."
	},
	["thing"] = {
		["not carried"] = "You don't have the %s.",
		["fixed"] = "The %s is fixed in place."
	},
	["unknown"] = {
		["verb"] = "I don't know what %q means.",
		["thing"] = "I don't see the %s."
	},
	["unlock"] = {
		["needs door"] = "You probably meant UNLOCK THE DOOR WITH THE KEY.",
		["needs key"] = "You need a key to do that.",
		["wont unlock"] = "It won't unlock.",
		["already unlocked"] = "It is already unlocked",
		["not unlockable"] = "That is not something you can unlock.",
		["succeed"] = "You unlock the %s with the %s."
	}
}

return responses
