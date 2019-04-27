--- The standard reword rulebook.
-- These are special rules, referred to before an action is taken, adjusting
-- the verb to be more correct in certain cases.
-- @module reword_rules
return function (rulebooks)

	rulebooks.reword = rulebooks.reword or { }

	rulebooks.reword.examine = {
		{
			name = "looking under or behind will search instead",
			action = function (self, command)
				if command.direction == "under" or
				command.direction == "behind" then
					command.verb = "search"
				end
			end
		}
	}

end
