--- The standard closing things rulebook.
-- @module close_rules
return function (rulebooks)

	rulebooks.before.close = {
		{
			name = "check items exist",
			action = function (self, command)
				if not command.item1 then
					return string.format(self.responses.unknown["thing"], command.verb), false
				end
			end
		},
		{
			name = "not something that can close",
			action = function (self, command)
				if command.item1.closed == nil then
					return string.format(self.responses.close["cannot"], command.item1.name), false
				end
			end
		},
		{
			name = "already closed",
			action = function (self, command)
				if command.item1.closed == true then
					return string.format(self.responses.close["when closed"], command.item1.name), false
				end
			end
		},
	}

	rulebooks.on.close = {
		{
			name = "closing",
			action = function (self, command)
				command.item1.closed = true
				return string.format(self.responses.close["succeed"], command.item1.name)
			end
		}
	}

end
