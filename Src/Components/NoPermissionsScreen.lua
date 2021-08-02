--[[
	Used to show that permissions must be granted.
]]

local errorMessage = [[This plugin requires script injection permissions in order to function. It uses this to insert the Tree and Props scripts for editing.

You can grant this permission via Plugins → Manage Plugins. Once granted, close and reopen this plugin to begin using it.]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local Message = require(main.Src.Components.Message)

local NoPermissionsScreen = Roact.PureComponent:extend("NoPermissionsScreen")

function NoPermissionsScreen:render()
	return Roact.createFragment({
		Cover = Roact.createElement("ImageButton", {
			ZIndex = 4,
			Size = UDim2.fromScale(1, 1),
			ImageTransparency = 1,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.new(),
			AutoButtonColor = false,
			[Roact.Event.Activated] = function() end,
		}),

		AboutMessage = Roact.createElement(Message, {
			ZIndex = 5,
			Visible = true,
			Text = errorMessage,
			Icon = "rbxasset://textures/StudioSharedUI/alert_warning@2x.png",
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

return NoPermissionsScreen
