--[[HELP
	Edit this script to modify the tree passed to the Roact Visualizer.
	The following special variables are available:
		Roact: A reference to your local Roact install.
		component: The current component in the Roact Visualizer.

	EXAMPLES:
	-- Providing a Roact Context
	return Roact.createElement(MyContext.Provider, {
		value = myContextValue,
	}, Roact.createElement(component, props)}))

	-- White background
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, Roact.createElement(component, props)))

	-- Preview in 3D window
	return Roact.createElement(Roact.Portal, {
		target = game.StarterGui,
	}, {
		RoactVisualizer = Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
		}, Roact.createElement(component, props)),
	})

	(You can disable these comments by unchecking "Show Help" in Settings.)
HELP]]
