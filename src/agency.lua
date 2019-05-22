--- Provides independent agent control.
-- @module agency

--- A table of agent details.
-- @table agent

local agency = { }

--- Add an agent to the simulation.
--
-- @param self instance
-- @param agent @{agent}
function agency.add (self, agent)

	-- init the roster if empty
	self.roster = self.roster or { }

	-- validate agent parameters
	if type(agent.name) ~= "string" then
		error ("agent needs a name")
	elseif type(agent.turn) ~= "function" then
		error ("agent needs a turn function")
	end

	-- add the agent to the simulation roster
	table.insert (self.roster, agent)

end

--- Simulate a turn with all agents.
function agency.turn (self, moonlight)

	if not self.roster then
		return
	end

	for _, agent in ipairs (self.roster) do
		agent:turn (moonlight)
	end

end




return agency
