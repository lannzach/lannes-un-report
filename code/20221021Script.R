#load tidyverse, read data
library(tidyverse)
gapminder_data <- read.csv("data/gapminder_data.csv")

#summarize outputs 
summarize(gapminder_data, averageLifeExp = mean(lifeExp))

#pipe operator allows for easy passing of functions to datasets
#good way to hold off on creating new vars before necessary
gapminder_data %>% summarize(gapminder_data, averageLifeExp = mean(lifeExp))

#Store summary in file
gapminder_data_summarized <- summarize(gapminder_data, averageLifeExp = mean(lifeExp))

gapminder_data %>% filter(year == 2007)

#Grouping Data
#take gapminder_data, pass it to a function that orders by year
#then find the mean of each year 
gapminder_data %>%
  group_by(year) %>%
  summarize(average = mean(lifeExp))

#the same, but grouping by continent
gapminder_data %>%
  group_by(continent) %>%
  summarize(average = mean(lifeExp))

#It is possible to pass more than one arg to summarize
#In this case, passing minimum year
gapminder_data %>%
  group_by(continent) %>%
  summarize(average = mean(lifeExp),min = min(year))

#mutate() adds columns
#possible to add multiple columns passing multiple args
gapminder_data %>%
  mutate(gdp = pop*gdpPercap, popInMillions = pop/1000000)

#select() chooses columns and/or changes order
#allows us to examine specific 
gapminder_data %>%
  select(pop,year)

#lets us arrange
gapminder_data %>%
  select(continent, country)
