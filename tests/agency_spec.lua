describe ("agency", function()

	local function make_world ()
		return {
			{
				name = "open field",
				contains  = {
					{
						name = "You",
						player = true,
						contains = { }
					},
					{
						name = "Bob",
						person = true
					},
					{
						name = "coin",
						description = "The stained face of a gold lion looks up at you."
					}
				},
				exits = {
					["south"] = "barn"
				}
			},
			{
				name = "barn",
				contains = {
					{
						name = "shovel",
						description = "It looks more like a spade."
					}
				},
				exits = {
					["north"] = "open field"
				}
			}
		}
	end

	it ("should not error with an empty roster", function()

		local ml = require ("moonlight")
		ml:load_world (make_world())
		ml:set_player ("Bob")
		ml:turn("look")

	end)

	it ("validates on agent add", function()

		local bobs_agent = { }
		local ml = require ("moonlight")

		local add_agent_func = function()
			ml.agency:add(bobs_agent)
		end

		assert.has_error(add_agent_func, "agent needs a name")

		bobs_agent.name = "pass"
		assert.has_error(add_agent_func, "agent needs a turn function")

		bobs_agent.turn = function()end
		assert.has_no.errors(add_agent_func)

	end)


	it ("basic agent test", function()

		local bobs_agent = { name = "bob's agent" }
		bobs_agent.turn = function (self, moonlight)
			if moonlight.turnNumber == 2 then
				local bob, bobs_room = moonlight:search_first ("Bob")
				local exit_to = bobs_room.exits["south"]
				local exit_room = moonlight:room_by_name (exit_to)
				moonlight:move_thing_into (bob, exit_room)
			end
		end

		local ml = require ("moonlight")
		ml:reset_simulation ()
		ml:load_world (make_world())
		ml:set_player ("Bob")
		ml.agency:add(bobs_agent)

		-- use turn 1
		ml:turn("look")

		-- test if Bob is NOT in the barn
		local barn_room = ml:room_by_name ("barn")
		local bob, bobs_room = ml:search_first ("Bob")
		assert.are_not.equals (barn_room, bobs_room)

		-- use turn 2
		ml:turn("look")

		-- test if Bob is in the barn NOW
		local barn_room = ml:room_by_name ("barn")
		local bob, bobs_room = ml:search_first ("Bob")
		assert.are.equals (barn_room, bobs_room)

	end)

end)
