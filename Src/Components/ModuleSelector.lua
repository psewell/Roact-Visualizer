--[[
	Used to select a RootModule.
]]

local Selection = game:GetService("Selection")

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local SetRootModule = require(main.Src.Reducers.PluginState.Actions.SetRootModule)
local Connection = require(main.Src.Components.Signal.Connection)

local ModuleSelector = Roact.PureComponent:extend("ModuleSelector")

function ModuleSelector:init()
	self.onSelectionChanged = function()
		local items = Selection:Get()
		if #items == 1 then
			local item = items[1]
			if item:IsA("ModuleScript") then
				self.props.SetRootModule(item)
			end
		end
	end
end

function ModuleSelector:render()
	return Roact.createElement(Connection, {
		Signal = Selection.SelectionChanged,
		Callback = self.onSelectionChanged,
	})
end

ModuleSelector = RoactRodux.connect(nil, function(dispatch)
	return {
		SetRootModule = function(module)
			dispatch(SetRootModule({
				RootModule = module,
			}))
		end,
	}
end)(ModuleSelector)

return ModuleSelector
