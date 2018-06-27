return function (rulebooks)

	rulebooks.before.close = {
		{
			name = "check items exist",
			action = function (self, command)
				if not command.item1 then
					return string.format(self.template.missingFirstNoun, command.verb), false
				end
			end
		},
		{
			name = "not something that can close",
			action = function (self, command)
				if command.item1.closed == nil then
					return string.format(self.template.notCloseable, command.item1.name), false
				end
			end
		},
		{
			name = "already closed",
			action = function (self, command)
				if command.item1.closed == true then
					return string.format(self.template.alreadyClosed, command.item1.name), false
				end
			end
		},
	}

	rulebooks.on.close = {
		{
			name = "closing",
			action = function (self, command)
				command.item1.closed = true
				return string.format(self.template.closed, command.item1.name)
			end
		}
	}

end
