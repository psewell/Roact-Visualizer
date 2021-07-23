--[[
	Main background for the plugin.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local getColor = require(main.Src.Util.getColor)

local MainBackground = Roact.PureComponent:extend("MainBackground")

function MainBackground:render()
	local props = self.props
	local theme = props.Theme

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = getColor(function(c)
			return theme:GetColor(c.ViewPortBackground)
		end),
	})
end

MainBackground = RoactRodux.connect(function(state)
	return {
		Theme = state.PluginState.Theme,
	}
end)(MainBackground)

return MainBackground
