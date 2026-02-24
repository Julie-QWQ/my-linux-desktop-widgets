-- ~/.config/conky/icon/ubuntu_logo.lua
require("cairo")

local LOGO_X = 80
local LOGO_Y = 1100
local LOGO_FONT = "Ubuntu Sans Mono"
local LOGO_SIZE = 15
local LOGO_LINE_GAP = 17
local LOGO_FONT_WEIGHT = "bold" -- "normal" | "bold"
local LOGO_ORANGE_RGBA = {0xE9/255, 0x54/255, 0x20/255, 0.98}
local LOGO_WHITE_RGBA = {0xF2/255, 0xF2/255, 0xF2/255, 0.98}
local LOGO_SHADOW_OPTS = {
  dx = 3, dy = 3,
  blur_r = 4,
  core_alpha = 0.85,
  blur_alpha = 0.25,
  sigma = 2.5,
  blur_gain = 5,
  blur_max_a = 0.035,
}

local LOGO_SEGMENTS = {
  {{"o", "            .-/+oossssoo+/-. "}},
  {{"o", "        `:+ssssssssssssssssss+:`"}},
  {{"o", "      -+ssssssssssssssssssyyssss+-"}},
  {{"o", "    .ossssssssssssssssss"}, {"w", "dMMMNy"}, {"o", "sssso."}},
  {{"o", "   /sssssssssss"}, {"w", "hdmmNNmmyNMMMMh"}, {"o", "ssssss/"}},
  {{"o", "  +sssssssss"}, {"w", "hm"}, {"o", "yd"}, {"w", "MMMMMMMNddddy"}, {"o", "ssssssss+"}},
  {{"o", " /ssssssss"}, {"w", "hNMMM"}, {"o", "yh"}, {"w", "hyyyyhmNMMMNh"}, {"o", "ssssssss/"}},
  {{"o", ".ssssssss"}, {"w", "dMMMNh"}, {"o", "sssssssss"}, {"w", "hNMMMd"}, {"o", "ssssssss."}},
  {{"o", "+ssss"}, {"w", "hhhyNMMNy"}, {"o", "ssssssssssss"}, {"w", "yNMMMy"}, {"o", "sssssss+"}},
  {{"o", "oss"}, {"w", "yNMMMNyMMh"}, {"o", "sssssssssssss"}, {"w", "hmmmh"}, {"o", "ssssssso"}},
  {{"o", "oss"}, {"w", "yNMMMNyMMh"}, {"o", "sssssssssssss"}, {"o", "hmmmhssssssso"}},
  {{"o", "+ssss"}, {"w", "hhhyNMMNy"}, {"o", "ssssssssssss"}, {"w", "yNMMMy"}, {"o", "sssssss+"}},
  {{"o", ".ssssssss"}, {"w", "dMMMNh"}, {"o", "sssssssss"}, {"w", "hNMMMd"}, {"o", "ssssssss."}},
  {{"o", " /ssssssss"}, {"w", "hNMMM"}, {"o", "yh"}, {"w", "hyyyyhdNMMMNh"}, {"o", "ssssssss/"}},
  {{"o", "  +sssssssss"}, {"w", "dm"}, {"o", "yd"}, {"w", "MMMMMMMMddddy"}, {"o", "ssssssss+"}},
  {{"o", "   /sssssssssss"}, {"w", "hdmNNNNmyNMMMMh"}, {"o", "ssssss/"}},
  {{"o", "    .ossssssssssssssssss"}, {"w", "dMMMNy"}, {"o", "sssso."}},
  {{"o", "      -+sssssssssssssssss"}, {"w", "yyy"}, {"o", "ssss+-"}},
  {{"o", "        `:+ssssssssssssssssss+:`"}},
  {{"o", "            .-/+oossssoo+/-. "}},
}

local function font_weight_from_string(s)
  if s == "normal" then return CAIRO_FONT_WEIGHT_NORMAL end
  return CAIRO_FONT_WEIGHT_BOLD
end

function draw_ubuntu_logo(cr)
  local fw = font_weight_from_string(LOGO_FONT_WEIGHT)
  cairo_select_font_face(cr, LOGO_FONT, CAIRO_FONT_SLANT_NORMAL, fw)
  cairo_set_font_size(cr, LOGO_SIZE)

  for i, segs in ipairs(LOGO_SEGMENTS) do
    local px = LOGO_X
    local py = LOGO_Y + (i - 1) * LOGO_LINE_GAP
    for _, seg in ipairs(segs) do
      local shadow_opts = {
        dx = LOGO_SHADOW_OPTS.dx,
        dy = LOGO_SHADOW_OPTS.dy,
        blur_r = LOGO_SHADOW_OPTS.blur_r,
        core_alpha = LOGO_SHADOW_OPTS.core_alpha,
        blur_alpha = LOGO_SHADOW_OPTS.blur_alpha,
        sigma = LOGO_SHADOW_OPTS.sigma,
        blur_gain = LOGO_SHADOW_OPTS.blur_gain,
        blur_max_a = LOGO_SHADOW_OPTS.blur_max_a,
        font_weight = fw,
      }
      if seg[1] == "w" then
        shadow_draw_text(cr, seg[2], px, py, LOGO_FONT, LOGO_SIZE, LOGO_WHITE_RGBA, shadow_opts)
      else
        shadow_draw_text(cr, seg[2], px, py, LOGO_FONT, LOGO_SIZE, LOGO_ORANGE_RGBA, shadow_opts)
      end

      local te = cairo_text_extents_t:create()
      cairo_text_extents(cr, seg[2], te)
      px = px + te.x_advance
      te:destroy()
    end
  end
end
