--[[
	Deletes a script.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Name = t.string,
	Container = t.literal("RootScripts", "PropsScripts"),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	local container = action.Container

	return Cryo.Dictionary.join(state, {
		[container] = Cryo.Dictionary.join(state[container], {
			[action.Name] = Cryo.None,
		}),
	})
end

return Action(script.Name, create, reduce)
