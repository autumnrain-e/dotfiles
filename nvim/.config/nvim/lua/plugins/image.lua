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
	opts = {
		backend = "kitty",
		integrations = {
			markdown = {
				enabled = true,
				only_render_image_at_cursor = true,
				resolve_image_path = function(document_path, image_path, fallback)
					return fallback(document_path, image_path)
				end,
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
