--[[HELP
	Edit this script to modify the tree passed to the Roact Visualizer.
	The following special variables are available:
		CurrentElement: The current component in the Roact Visualizer.
		Roact: A reference to your local Roact install.

	EXAMPLES:
	-- Providing a Roact Context
	return Roact.createElement(MyContext.Provider, {
		value = myContextValue,
	}, CurrentElement}))

	-- White background
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, CurrentElement))

	-- Preview in 3D window
	return Roact.createElement(Roact.Portal, {
		target = game.StarterGui,
	}, {
		RoactVisualizer = Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			IgnoreGuiInset = true,
		}, CurrentElement),
	})

	(You can disable these comments by unchecking "Show Help" in Settings.)
HELP]]
