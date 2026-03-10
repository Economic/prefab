# prefab hex sticker logo
# Output: man/figures/logo.png at 240x278 (usethis::use_logo() standard)

library(ggplot2)
library(hexSticker)

# Building blocks as rectangles with slight offset
blocks <- data.frame(
  xmin = c(0.2, 0.5, 0.1),
  xmax = c(0.7, 1.0, 0.6),
  ymin = c(0.0, 0.0, 0.45),
  ymax = c(0.4, 0.4, 0.85),
  fill = c("#4A6274", "#6B8FA3", "#E8734A")
)

p <- ggplot(blocks) +
  geom_rect(
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
    fill = blocks$fill,
    color = "white",
    linewidth = 0.8
  ) +
  coord_fixed(ratio = 1, xlim = c(-0.1, 1.2), ylim = c(-0.15, 1.0)) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA)
  )

# Render at high DPI, then resize to 240x278 (usethis::use_logo() standard)
sticker(
  p,
  package = "prefab",
  p_size = 22,
  p_y = 1.45,
  p_color = "white",
  s_x = 1.0,
  s_y = 0.75,
  s_width = 1.4,
  s_height = 1.0,
  h_fill = "#2C3E50",
  h_color = "#E8734A",
  h_size = 1.8,
  filename = "man/figures/logo.png",
  dpi = 300
)

magick::image_read("man/figures/logo.png") |>
  magick::image_resize("240x278") |>
  magick::image_write("man/figures/logo.png")
