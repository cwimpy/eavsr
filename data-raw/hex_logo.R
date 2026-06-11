# Hex sticker for eavsr -------------------------------------------------
# Draws the logo with ggplot2 only (no hexSticker dependency): a ballot
# with a checkmark dropping into a ballot box, on a navy hexagon.
# Output: data-raw/eavsr-hex.png (then wired in via usethis::use_logo()).

library(ggplot2)

navy <- "#1D3557"
cream <- "#F1FAEE"
light <- "#A8DADC"
red <- "#E63946"

# Hexagon with vertices at top/bottom (standard R sticker orientation)
hex_pts <- function(r = 1) {
  theta <- seq(90, 450, by = 60) * pi / 180
  data.frame(x = r * cos(theta), y = r * sin(theta))
}

# Rotate points about a center, then translate
rot <- function(df, deg, cx = 0, cy = 0) {
  th <- deg * pi / 180
  data.frame(
    x = cx + df$x * cos(th) - df$y * sin(th),
    y = cy + df$x * sin(th) + df$y * cos(th)
  )
}

# Ballot card (rotated, bottom edge tucked behind the box lid)
card_w <- 0.40
card_h <- 0.52
card_angle <- -13
card_cx <- 0.06
card_cy <- 0.46

card <- rot(
  data.frame(
    x = c(-1, 1, 1, -1) * card_w / 2,
    y = c(-1, -1, 1, 1) * card_h / 2
  ),
  card_angle, card_cx, card_cy
)

# Checkmark and text lines, in card-local coordinates
check <- rot(
  data.frame(
    x = c(-0.085, -0.015, 0.105),
    y = c(0.060, -0.020, 0.130)
  ),
  card_angle, card_cx, card_cy
)
line1 <- rot(data.frame(x = c(-0.10, 0.10), y = c(-0.10, -0.10)),
             card_angle, card_cx, card_cy)
line2 <- rot(data.frame(x = c(-0.10, 0.04), y = c(-0.17, -0.17)),
             card_angle, card_cx, card_cy)

p <- ggplot() +
  geom_polygon(data = hex_pts(1), aes(x, y), fill = navy) +
  geom_polygon(data = hex_pts(0.93), aes(x, y),
               fill = NA, color = light, linewidth = 0.8) +
  # box body (drawn first so the card slips behind the lid)
  annotate("rect", xmin = -0.42, xmax = 0.42, ymin = -0.40, ymax = 0.05,
           fill = cream) +
  # ballot card
  geom_polygon(data = card, aes(x, y), fill = "white",
               color = navy, linewidth = 0.6) +
  geom_path(data = check, aes(x, y), color = red,
            linewidth = 2.6, lineend = "round", linejoin = "round") +
  geom_path(data = line1, aes(x, y), color = light, linewidth = 1.1,
            lineend = "round") +
  geom_path(data = line2, aes(x, y), color = light, linewidth = 1.1,
            lineend = "round") +
  # box lid with slot
  annotate("rect", xmin = -0.50, xmax = 0.50, ymin = 0.05, ymax = 0.17,
           fill = cream) +
  annotate("rect", xmin = -0.18, xmax = 0.18, ymin = 0.085, ymax = 0.135,
           fill = navy) +
  # red stripe on the box front
  annotate("rect", xmin = -0.42, xmax = 0.42, ymin = -0.40, ymax = -0.33,
           fill = red) +
  annotate("text", x = 0, y = -0.55, label = "eavsr",
           family = "Helvetica", fontface = "bold",
           color = cream, size = 16) +
  coord_fixed(xlim = c(-1, 1), ylim = c(-1.05, 1.05), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_blank(),
        panel.background = element_blank())

ggsave(
  file.path("data-raw", "eavsr-hex.png"),
  p,
  width = 5.18, height = 6, dpi = 320, bg = "transparent"
)
