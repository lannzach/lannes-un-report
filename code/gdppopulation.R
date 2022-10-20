#Tidyverse is actually a collection of packages
#Conflicts is a namespace type thing, overlapping titles
library(tidyverse)

#in addition to point-and-click readr input:
#variable assignment uses <-
gapminder_1997 <- read_csv("gapminder_1997.csv")
view(gapminder_1997)

#Good practice for naming: R is case sensitive,
#prolly use underscores also

#Use ?function to get info on a function.
#Can be in console or script
#Note: parentheses are not needed with ?

#Tells us working directory
getwd()

#Plot function, 1st arg = dataset used, 
ggplot(gapminder_1997) +
  #X axis assignment
  aes(x = gdpPercap) +
  #Change X axis name
  labs(x = "GDP Per Capita") +
  #Y axis assignment
  aes(y = lifeExp) +
  #Y axis name
  labs(y = "Life Expectancy") +
  #Type of plot, syntax is geom_ + type of plot
  #geom_point() does point plot
  geom_point() +
  #title the plot
  labs(title = "Do people in wealthy countries live longer") +
  #Choose color scheme
  aes(color = continent) +
  #Choose color scale
  scale_color_brewer(palette = "Set1") +
  #Change point design, set size to relate to population
  aes(size = pop/1000000) +
  #Change size labeling
  labs(size = "Population (in Millions)")

#Summary function
ggplot(gapminder_1997) +
  aes(x = gdpPercap, y = lifeExp, color = continent, size = pop/1000000) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "GDP Per Capita", y = "Life Expectancy", size = "Population in Millions", title = "Do people in wealthy countries live longer?", color = "Continent") + 
  geom_point()

#reading larger gapminder_data
gapminder_data <- read_csv("gapminder_data.csv")
view(gapminder_data)

#Plot some larger gapminder stuff
ggplot(gapminder_data) +
  aes(x = year, y = lifeExp, color = continent) +
  geom_point()
#Note: "obs" mean number of observations

#str() = structure of data
#Read structure of gapminder_data
str(gapminder_data)
#This viz may not be best

#Try again
ggplot(gapminder_data) +
  aes(x = year, y = lifeExp, color = continent) +
  geom_line()

#Maybe try grouping some stuff using aes(group = country)
ggplot(gapminder_data) +
  aes(x = year, y = lifeExp, color = continent, group = country) +
  geom_line()

#Categorical plotting using box plot, x = continent
#Note that removing grouping does provide cleaner viz of one category
ggplot(gapminder_data) +
  aes(x = continent, y = lifeExp) +
  labs(x = "Continent", y = "Life Expectancy") +
  geom_boxplot()

#Violin plot, adds density as a visual representation
ggplot(gapminder_data) +
  aes(x = continent, y = lifeExp) +
  labs(x = "Continent", y = "Life Expectancy") +
  geom_violin()

#Can mix types of representation
#Note: using 1997 data for easier viz
#Violin plot, adds density as a visual representation
#Geom jitter helps to spread points
violin <- ggplot(gapminder_1997,aes(x = continent, y = lifeExp)) +
  labs(x = "Continent", y = "Life Expectancy") +
  #can also use aes for specific aesthetic generation based on variable
  geom_violin(color = "black",aes(fill = continent)) +
  #alpha alters transparency
  geom_jitter(alpha = 0.5)
#Order matters for layers
#Can pass individual aes to geoms

#Create histogram
#Help -> cheat sheets -> choose pdf
ggplot(gapminder_1997) +
  aes(x = lifeExp) +
  geom_density(fill = "white", color = "black")

#ggplot2 Themes
ggplot(gapminder_1997) +
  aes(x = lifeExp) +
  geom_histogram() +
  theme_minimal() +
  #axis.text.x is basically "angle", element_text necessary for angles
  #vjust + hjust useful for moving things
  theme(axis.text.x = element_text(angle = 30,vjust = 1, hjust = 0.5))

#faceting
ggplot(gapminder_1997) +
  aes(x = gdpPercap, y = lifeExp) +
  geom_point() +
  #Facet wrap breaks up continents into individual charts
  facet_wrap(vars(continent))

ggplot(gapminder_1997) +
  aes(x = gdpPercap, y = lifeExp) +
  geom_point() +
  #Facet wrap breaks up continents into individual charts
  facet_grid(rows = vars(continent))

ggsave("awesome_plot.jpg", width = 6, height = 4,plot = violin)

#if we want to alter, use assignment operator, kindve like +=
violin <- violin + theme_bw()

#animated plots

#install and add
install.packages(c("gganimate","gifski"))
library(gganimate)
library(gifski)

ggplot(data = gapminder_data) +
  aes(x = log(gdpPercap),y = lifeExp, size = pop, color = continent) +
  geom_point()

#base object for animation
staticHansPlot <- ggplot(data = gapminder_data) +
  aes(x = log(gdpPercap),y = lifeExp, size = pop/1000000, color = continent) +
  geom_point(alpha = 0.5) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "GDP Per Capita", y = "Life Expectancy", color = "Continent", size = "Population (in Millions)") +
  theme_classic()

#animate it
animatedHansPlot <- staticHansPlot +
  transition_states(year, transition_length = 1, state_length = 1) +
  #Glue package -- uses curly braces to insert variable names (maybe)
  ggtitle("{closest_state}")

#Call it
animatedHansPlot

anim_save("animatedHansPlot.gif", plot = animatedHansPlot, renderer = gifski_renderer())
