require("git"):setup({
	order = 1500,
})

require("session"):setup({
	sync_yanked = true,
})

require("what-size"):setup({
	priority = 400,
	LEFT = "",
	RIGHT = " ",
})
