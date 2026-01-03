#!/usr/bin/env Rscript
# Generate README figures for moschooldata

library(ggplot2)
library(dplyr)
library(scales)
devtools::load_all(".")

# Create figures directory
dir.create("man/figures", recursive = TRUE, showWarnings = FALSE)

# Theme
theme_readme <- function() {
  theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

colors <- c("total" = "#2C3E50", "white" = "#3498DB", "black" = "#E74C3C",
            "hispanic" = "#F39C12", "asian" = "#9B59B6")

# Get available years (handles both vector and list return types)
years <- get_available_years()
if (is.list(years)) {
  max_year <- years$max_year
  min_year <- years$min_year
} else {
  max_year <- max(years)
  min_year <- min(years)
}

# Fetch data
message("Fetching data...")
enr <- fetch_enr_multi((max_year - 7):max_year)
key_years <- seq(max(min_year, 2006), max_year, by = 5)
if (!max_year %in% key_years) key_years <- c(key_years, max_year)
enr_long <- fetch_enr_multi(key_years)
enr_current <- fetch_enr(max_year)

# 1. St. Louis decline
message("Creating St. Louis decline chart...")
stl <- enr_long %>%
  filter(is_district, district_id == "115115",
         subgroup == "total_enrollment", grade_level == "TOTAL")

p <- ggplot(stl, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "St. Louis City: A District in Crisis",
       subtitle = "Lost over 50% of enrollment since 2000",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/stl-decline.png", p, width = 10, height = 6, dpi = 150)

# 2. Kansas City decline
message("Creating Kansas City decline chart...")
kc <- enr_long %>%
  filter(is_district, district_id == "048078",
         subgroup == "total_enrollment", grade_level == "TOTAL")

p <- ggplot(kc, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Kansas City 33 Isn't Much Better",
       subtitle = "Lost nearly half its students",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/kc-decline.png", p, width = 10, height = 6, dpi = 150)

# 3. District fragmentation
message("Creating fragmentation chart...")
sizes <- enr_current %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  mutate(size = case_when(
    n_students < 500 ~ "Under 500",
    n_students < 1000 ~ "500-999",
    n_students < 2000 ~ "1,000-1,999",
    n_students < 5000 ~ "2,000-4,999",
    TRUE ~ "5,000+"
  )) %>%
  group_by(size) %>%
  summarize(n_districts = n(), .groups = "drop")

p <- ggplot(sizes, aes(x = size, y = n_districts)) +
  geom_col(fill = colors["total"]) +
  labs(title = "St. Louis County's Fragmented System",
       subtitle = "Dozens of tiny districts - most fragmented in America",
       x = "District Size", y = "Number of Districts") +
  theme_readme()
ggsave("man/figures/fragmentation.png", p, width = 10, height = 6, dpi = 150)

# 4. Springfield stability
message("Creating Springfield chart...")
springfield <- enr %>%
  filter(is_district, grepl("Springfield R-XII", district_name, ignore.case = TRUE),
         subgroup == "total_enrollment", grade_level == "TOTAL")

p <- ggplot(springfield, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Springfield is Stable",
       subtitle = "Third-largest city maintains ~25,000 students",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/springfield-stable.png", p, width = 10, height = 6, dpi = 150)

# 5. Demographics
message("Creating demographics chart...")
demo <- enr_long %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian"))

p <- ggplot(demo, aes(x = end_year, y = pct * 100, color = subgroup)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = colors,
                     labels = c("Asian", "Black", "Hispanic", "White")) +
  labs(title = "Missouri Diversifying Slowly",
       subtitle = "From 80% white to ~70% with Hispanic growth",
       x = "School Year", y = "Percent", color = "") +
  theme_readme()
ggsave("man/figures/demographics.png", p, width = 10, height = 6, dpi = 150)

# 6. COVID kindergarten
message("Creating COVID K chart...")
k_trend <- enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("PK", "K", "01", "06", "12")) %>%
  mutate(grade_label = case_when(
    grade_level == "PK" ~ "Pre-K",
    grade_level == "K" ~ "Kindergarten",
    grade_level == "01" ~ "Grade 1",
    grade_level == "06" ~ "Grade 6",
    grade_level == "12" ~ "Grade 12"
  ))

p <- ggplot(k_trend, aes(x = end_year, y = n_students, color = grade_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2021, linetype = "dashed", color = "red", alpha = 0.5) +
  scale_y_continuous(labels = comma) +
  labs(title = "COVID Crushed Missouri Kindergarten",
       subtitle = "Lost 10,000+ kindergartners - a 14% drop",
       x = "School Year", y = "Students", color = "") +
  theme_readme()
ggsave("man/figures/covid-k.png", p, width = 10, height = 6, dpi = 150)

# 7. Charter enrollment
message("Creating charter enrollment chart...")
charter <- enr %>%
  filter(is_charter, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE), .groups = "drop")

p <- ggplot(charter, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma) +
  labs(title = "Charter Schools Limited to KC and STL",
       subtitle = "Over 30,000 students in state-law restricted charters",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/charter-enrollment.png", p, width = 10, height = 6, dpi = 150)

# 8. Columbia growth
message("Creating Columbia chart...")
columbia <- enr %>%
  filter(is_district, grepl("Columbia 93", district_name, ignore.case = TRUE),
         subgroup == "total_enrollment", grade_level == "TOTAL")

p <- ggplot(columbia, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(title = "Columbia Grows with the University",
       subtitle = "One of few mid-Missouri districts gaining students",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/columbia-growth.png", p, width = 10, height = 6, dpi = 150)

# 9. Economic disadvantage
message("Creating econ disadvantage chart...")
econ <- enr_current %>%
  filter(is_district, subgroup == "econ_disadv", grade_level == "TOTAL") %>%
  arrange(desc(pct)) %>%
  head(10) %>%
  mutate(district_label = reorder(district_name, pct))

p <- ggplot(econ, aes(x = district_label, y = pct * 100)) +
  geom_col(fill = colors["total"]) +
  coord_flip() +
  labs(title = "Economic Disadvantage is Widespread",
       subtitle = "Over 50% of Missouri students are economically disadvantaged",
       x = "", y = "Percent Economically Disadvantaged") +
  theme_readme()
ggsave("man/figures/econ-disadvantage.png", p, width = 10, height = 6, dpi = 150)

# 10. Ozarks decline
message("Creating Ozarks decline chart...")
ozarks <- c("Mountain Grove", "West Plains", "Willow Springs", "Cabool")
ozark_trend <- enr %>%
  filter(is_district, grepl(paste(ozarks, collapse = "|"), district_name, ignore.case = TRUE),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(n_students = sum(n_students, na.rm = TRUE), .groups = "drop")

p <- ggplot(ozark_trend, aes(x = end_year, y = n_students)) +
  geom_line(linewidth = 1.5, color = colors["total"]) +
  geom_point(size = 3, color = colors["total"]) +
  scale_y_continuous(labels = comma) +
  labs(title = "The Ozarks Are Aging Out",
       subtitle = "Mountain Grove, West Plains, Willow Springs, Cabool combined",
       x = "School Year", y = "Students") +
  theme_readme()
ggsave("man/figures/ozarks-decline.png", p, width = 10, height = 6, dpi = 150)

message("Done! Generated 10 figures in man/figures/")
