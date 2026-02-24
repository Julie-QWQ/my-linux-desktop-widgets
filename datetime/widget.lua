-- ~/.config/conky/datetime/widget.lua
require("cairo")

local TIME_FONT, TIME_SIZE = "Ubuntu Sans", 168
local DATE_FONT, DATE_SIZE = "Ubuntu Sans", 78

local TIME_RGBA = {0x61/255, 0x69/255, 0xC7/255, 1.0}
local DATE_RGBA = {0x62/255, 0xA0/255, 0xEA/255, 1.0}

local TIME_X, TIME_Y = 115, 460
local DATE_X, DATE_Y = 160, 625

local SHADOW_OPTS = {
  dx = 4, dy = 4,
  blur_r = 5,
  core_alpha = 1.0,
  blur_alpha = 0.3,
  sigma = 3,
  blur_gain = 6,
  blur_max_a = 0.04,
}

function draw_datetime(cr, w, h)
  local t = os.date("%H:%M:%S")
  local d = os.date("%A %b %d")

  shadow_draw_text(cr, t, TIME_X, TIME_Y, TIME_FONT, TIME_SIZE, TIME_RGBA, SHADOW_OPTS)
  shadow_draw_text(cr, d, DATE_X, DATE_Y, DATE_FONT, DATE_SIZE, DATE_RGBA, SHADOW_OPTS)
end
