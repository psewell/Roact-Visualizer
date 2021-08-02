--[[HELP
	Edit this script to modify the tree passed to the Roact Visualizer.
	The following special variables are available:
		Roact: A reference to your local Roact install.
		component: The current component in the Roact Visualizer.

	EXAMPLE:
	-- Providing a Roact Context
	return Roact.createElement(MyContext.Provider, {
		value = myContextValue,
	}, Roact.createElement(component, props))

	(You can disable these comments by unchecking "Show Help" in Settings.)
HELP]]
