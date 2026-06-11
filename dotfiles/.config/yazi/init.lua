require("no-status"):setup()

require("zoxide"):setup({
	update_db = true,
})

require("session"):setup({
	sync_yanked = true,
})

require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})

require("git"):setup({
	order = 1500,
})
