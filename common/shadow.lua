-- ~/.config/conky/common/shadow.lua
require("cairo")

local function clamp(x, lo, hi)
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

local function set_rgba(cr, rgba)
  cairo_set_source_rgba(cr, rgba[1], rgba[2], rgba[3], rgba[4])
end

local function set_font(cr, font, size, weight)
  local w = weight or CAIRO_FONT_WEIGHT_NORMAL
  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, w)
  cairo_set_font_size(cr, size)
end

function shadow_draw_text(cr, text, x, y, font, size, rgba, opts)
  if text == nil or text == "" then return end
  opts = opts or {}

  local dx = opts.dx or 4
  local dy = opts.dy or 4
  local blur_r = opts.blur_r or 5

  local core_alpha = opts.core_alpha or 1.0
  local blur_alpha = opts.blur_alpha or 0.3

  local sigma = opts.sigma or 3
  local blur_gain = opts.blur_gain or 6
  local blur_max_a = opts.blur_max_a or 0.04

  set_font(cr, font, size, opts.font_weight)

  local s = sigma
  if s <= 0 then s = 1.0 end
  local two_sigma2 = 2.0 * s * s

  for yy = -blur_r, blur_r do
    for xx = -blur_r, blur_r do
      local d2 = xx * xx + yy * yy
      if d2 <= (blur_r * blur_r) then
        local w = math.exp(-d2 / two_sigma2)
        local a = blur_alpha * blur_gain * w
        a = clamp(a, 0.0, blur_max_a)
        if a > 0.0 then
          cairo_set_source_rgba(cr, 0, 0, 0, a)
          cairo_move_to(cr, x + dx + xx, y + dy + yy)
          cairo_show_text(cr, text)
        end
      end
    end
  end

  if core_alpha > 0 then
    cairo_set_source_rgba(cr, 0, 0, 0, core_alpha)
    cairo_move_to(cr, x + dx, y + dy)
    cairo_show_text(cr, text)
  end

  set_rgba(cr, rgba)
  cairo_move_to(cr, x, y)
  cairo_show_text(cr, text)
end
