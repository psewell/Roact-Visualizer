local Roact = script.Roact
local component = require(script.module)

return function(props)
	return Roact.createElement(Roact.Portal, {
		target = game.StarterGui,
	}, {
		RoactVisualizer = Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
		}, Roact.createElement(component, props)),
	})
end