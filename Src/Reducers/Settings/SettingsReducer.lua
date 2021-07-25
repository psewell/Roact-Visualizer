local main = script:FindFirstAncestor("Roact-Visualizer")
local Rodux = require(main.Packages.Rodux)

local Actions = script.Parent.Actions
local initialState = {
	ShowHelp = true,
}

local function registerActions()
	local result = {}
	for _, actionScript in ipairs(Actions:GetChildren()) do
		local action = require(actionScript)
		result[action.name] = action.reduce
	end
	return result
end

return Rodux.createReducer(initialState, registerActions())
