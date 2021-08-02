--[[
	Used to show info about the plugin.
]]

local aboutText = [[Roact Visualizer
Plugin by pa00 (@ZeroIndex)

DevForum Thread Link:]]

local forumPost = "https://devforum.roblox.com/t/tweensequence-editor/218976"

local main = script:FindFirstAncestor("Roact-Visualizer")
local Roact = require(main.Packages.Roact)
local RoactRodux = require(main.Packages.RoactRodux)
local Message = require(main.Src.Components.Message)
local SetShowAboutScreen = require(main.Src.Reducers.PluginState.Actions.SetShowAboutScreen)

local AboutScreen = Roact.PureComponent:extend("AboutScreen")

function AboutScreen:render()
	local props = self.props
	return Roact.createFragment({
		Cover = Roact.createElement("ImageButton", {
			ZIndex = 4,
			Size = UDim2.fromScale(1, 1),
			ImageTransparency = 1,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.new(),
			AutoButtonColor = false,
			[Roact.Event.Activated] = props.Close,
		}),

		AboutMessage = Roact.createElement(Message, {
			ZIndex = 5,
			Visible = true,
			Text = aboutText,
			Icon = "rbxassetid://7138347364",
			TextBox = {
				InitialText = forumPost,
				TextEditable = false,
				OnTextSubmitted = props.Close,
			},
		}),
	})
end

AboutScreen = RoactRodux.connect(nil, function(dispatch)
	return {
		Close = function()
			dispatch(SetShowAboutScreen({
				ShowAboutScreen = false,
			}))
		end,
	}
end)(AboutScreen)

return AboutScreen
