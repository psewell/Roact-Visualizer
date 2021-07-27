--[[
	Sets whether the user is deleting a script.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Name = t.optional(t.string),
	Type = t.optional(t.literal("RootScripts", "PropsScripts")),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	local props
	if action.Name and action.Type then
		props = action
	else
		props = Cryo.None
	end
	return Cryo.Dictionary.join(state, {
		DeletingScript = props,
	})
end

return Action(script.Name, create, reduce)
