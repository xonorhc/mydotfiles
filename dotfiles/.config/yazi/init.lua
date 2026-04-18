require("git"):setup()

require("session"):setup({
	sync_yanked = true,
})

require("what-size"):setup({
	priority = 400,
	LEFT = "",
	RIGHT = " ",
})
