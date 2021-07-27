--[[
	Sets whether the user is saving a script.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Type = t.optional(t.literal("RootScripts", "PropsScripts")),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		SavingScript = action.Type or Cryo.None,
	})
end

return Action(script.Name, create, reduce)
