local main = script:FindFirstAncestor("Roact-Visualizer")
local Rodux = require(main.Packages.Rodux)

local Actions = script.Parent.Actions
local initialState = {
	RootModule = nil,
	Theme = settings().Studio.Theme,
	ThemeConnection = nil,
	RoactInstall = nil,
	ReloadCode = "",

	ShowAboutScreen = false,
	SelectingModule = nil,
	SelectingRoact = false,
	InputAutoRefreshDelay = false,
	HasScriptPermission = false,
	SavingScript = nil,
	DeletingScript = nil,
	StartupState = nil,
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
