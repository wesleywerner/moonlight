--- The standard closing things rulebook.
-- @module close_rules
return function (rulebooks)

	rulebooks.before.close = {
		{
			name = "the noun exists",
			action = function (self, command)
				if not command.first_item then
					return string.format(self.responses.unknown["thing"], command.verb), false
				end
			end
		},
		{
			name = "the noun is something that can close",
			action = function (self, command)
				if command.first_item.closed == nil then
					return string.format(self.responses.close["cannot"], command.first_item.name), false
				end
			end
		},
		{
			name = "the noun is not already closed",
			action = function (self, command)
				if command.first_item.closed == true then
					return string.format(self.responses.close["when closed"], command.first_item.name), false
				end
			end
		},
	}

	rulebooks.on.close = {
		{
			name = "close the noun",
			action = function (self, command)
				command.first_item.closed = true
				return string.format(self.responses.close["succeed"], command.first_item.name)
			end
		}
	}

end
