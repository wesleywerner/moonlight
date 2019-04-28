--- The standard turn rulebook.
-- @module turn_rules
return function (rulebooks)

	rulebooks.before.turn = {
		{
			name = "the player character exists",
			action = function (self)
				if self.player == nil then
					return "No player character has been set.", false
				end
			end
		}
	}

end
