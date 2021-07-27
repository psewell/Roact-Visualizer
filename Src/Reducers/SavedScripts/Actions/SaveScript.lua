--[[
	Saves a script.
]]

local pattern = "%s*%-%-%[%[HELP.*HELP%]%]"

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Name = t.string,
	Container = t.literal("RootScripts", "PropsScripts"),
	Script = t.instanceIsA("ModuleScript"),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	local source = action.Script.Source
	local container = action.Container
	source = string.gsub(source, pattern .. "%s*", "", 1) .. "\n"

	return Cryo.Dictionary.join(state, {
		[container] = Cryo.Dictionary.join(state[container], {
			[action.Name] = source,
		}),
	})
end

return Action(script.Name, create, reduce)
