-- ~/.config/conky/icon/main.lua
require("cairo")

local BASE = os.getenv("HOME") .. "/.config/conky"

dofile(BASE .. "/common/shadow.lua")
dofile(BASE .. "/icon/widget.lua")

function conky_draw_all()
  if conky_window == nil then return end

  local w = conky_window.width
  local h = conky_window.height

  local cs = cairo_xlib_surface_create(
    conky_window.display, conky_window.drawable, conky_window.visual, w, h
  )
  local cr = cairo_create(cs)

  cairo_set_antialias(cr, CAIRO_ANTIALIAS_BEST)
  draw_ubuntu_logo(cr)

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
