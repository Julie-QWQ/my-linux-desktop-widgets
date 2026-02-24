-- ~/.config/conky/signature/widget.lua
require("cairo")

local SIGN_TEXT = "Julieqwq."
local SIGN_FONT = "Italianno"
local SIGN_SIZE = 316
local SIGN_RGBA = {0xDC/255, 0x8A/255, 0xDD/255, 1.0}
local HOLD_FULL_TICKS = 5

local X = 1720
local Y = 550

local SHADOW_OPTS = {
  dx = 4, dy = 4,
  blur_r = 5,
  core_alpha = 1.0,
  blur_alpha = 0.3,
  sigma = 3,
  blur_gain = 6,
  blur_max_a = 0.04,
}

local function typewriter_text(base)
  local len = #base
  local cycle = len + HOLD_FULL_TICKS + 1
  local k = conky_updates() % cycle
  if k == 0 then return "" end
  if k > len then return base end
  return base:sub(1, k)
end

function draw_signature(cr, w, h)
  cairo_set_antialias(cr, CAIRO_ANTIALIAS_BEST)
  local s = typewriter_text(SIGN_TEXT)
  shadow_draw_text(cr, s, X, Y, SIGN_FONT, SIGN_SIZE, SIGN_RGBA, SHADOW_OPTS)
end
