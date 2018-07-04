--- The standard turn rulebook.
-- @module turn_rules
return function (rulebooks)

	rulebooks.turn.before = {
		{
			name = "player exists check",
			action = function (self)
				if self.player == nil then
					return "No player character has been set.", false
				end
			end
		}
	}

	rulebooks.after.turn = { }

end
