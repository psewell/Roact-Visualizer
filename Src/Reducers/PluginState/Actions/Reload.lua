--[[
	Reloads the current component by updating the ReloadCode.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)
local generateId = require(main.Packages.generateId)

local typecheck = t.interface({})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state)
	return Cryo.Dictionary.join(state, {
		ReloadCode = generateId(),
	})
end

return Action(script.Name, create, reduce)
