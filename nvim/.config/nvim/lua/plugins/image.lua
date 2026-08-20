local function is_badge_url(url)
	return url:match("shields%.io")
		or url:match("badgen%.net")
		or url:match("img%.shields%.io")
		or url:match("github%.com/.+/workflows/")
		or url:match("codecov%.io/gh/.+/badge")
		or url:match("%.svg(%?.*)?$")
end

return {
	"3rd/image.nvim",
	build = false,
	init = function()
		local home = os.getenv("HOME")
		package.path = package.path
			.. ";" .. home .. "/.luarocks/share/lua/5.1/?.lua"
			.. ";" .. home .. "/.luarocks/share/lua/5.1/?/init.lua"
		package.cpath = package.cpath
			.. ";" .. home .. "/.luarocks/lib/lua/5.1/?.so"
	end,
	config = function(_, opts)
		require("image").setup(opts)
		local api = require("image")
		local original_from_url = api.from_url
		api.from_url = function(url, options, callback)
			if is_badge_url(url) then
				if callback then callback(nil) end
				return
			end
			return original_from_url(url, options, callback)
		end
	end,
	opts = {
		backend = "kitty",
		integrations = {
			markdown = {
				enabled = true,
				only_render_image_at_cursor = true,
			},
		},
		max_width = 100,
		max_height = 12,
		max_width_window_percentage = math.huge,
		max_height_window_percentage = math.huge,
		window_overlap_clear_enabled = true,
		window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		editor_only_render_when_focused = true,
	},
}
