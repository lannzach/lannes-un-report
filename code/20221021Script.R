#load tidyverse, read data
library(tidyverse)
gapminder_data <- read.csv("data/gapminder_data.csv")

#summarize outputs 
summarize(gapminder_data, averageLifeExp = mean(lifeExp))

#pipe operator allows for easy passing of functions to datasets
#good way to hold off on creating new vars before necessary
gapminder_data %>% summarize(gapminder_data, averageLifeExp = mean(lifeExp))

#Store summary in object
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

#and like this too
gapminder_data %>%
  select(gdpPercap, everything())

#long format data -- every observation is a row
#wide format data -- observations consist of columns
#tidyr allows for movement between formats
#pivot_wider() and pivot_longer() allow this
gapminder_data %>%
  select(country,continent,year,lifeExp) %>%
  pivot_wider(names_from = year,values_from = lifeExp)

#dataset for analysis
#good practice to read from original .csv to prevent mutations from affecting analysis
gapminder_data_2007 <- read.csv("data/gapminder_data.csv") %>%
  #boolean in R is &, not &&
  filter(year == 2007 & continent == "Americas") %>%
  #drop year & continent, since we've filtered by year and continent already
  select(-year,-continent)


#Data cleaning time
#skip arg tells read to realign columns
read_csv("data/co2-un-data.csv", skip = 1)

#c() is a list in R
read_csv("data/co2-un-data.csv", skip = 2, 
         col_names = c("region","country","year","series","value","footnotes","source"))

#rename() allows for finer renaming of groups
read_csv("data/co2-un-data.csv", skip = 1) %>%
  rename(country = ...2)

#give columns lowercase titles
read_csv("data/co2-un-data.csv", skip = 1) %>%
  rename_all(tolower)

co2_emissions_dirty <- read_csv("data/co2-un-data.csv", skip = 2, 
                                col_names = c("region","country","year","series","value","footnotes","source"))

#Select cols by country, year, series, and value
co2_emissions_dirty %>%
  select(country,year,series,value) %>%
  mutate(series = recode(series, "Emissions (thousand metric tons of carbon dioxide)" = "total_emissions",
                         "Emissions per capita (metric tons of carbon dioxide" = "emissions_per_capita")) %>%
  pivot_wider(names_from = series, values_from = value) %>%
  #number of observations per year
  count(year)

#note, R allows for clearer steps of analysis than excel. it does this thru explicit expression of steps thru functions

#continuing analysis, assign our emissions to a new object
co2_emissions <- co2_emissions_dirty %>%
  select(country,year,series,value) %>%
  mutate(series = recode(series, "Emissions (thousand metric tons of carbon dioxide)" = "total_emissions",
                         "Emissions per capita (metric tons of carbon dioxide" = "emissions_per_capita")) %>%
  pivot_wider(names_from = series, values_from = value) %>%
  #number of observations per year
  filter(year == 2005) %>%
  select(-year)

#we can join data frames together to make a new table
inner_join(gapminder_data_2007, co2_emissions)

#anti_join() returns observations that do not match between
anti_join(gapminder_data_2007, co2_emissions, by = "country")

#clean country names in co2_emissions
co2_emissions <- read_csv("data/co2-un-data.csv", skip = 2, 
                  col_names = c("region","country","year","series","value","footnotes","source")) %>%
  select(country,year,series,value) %>%
  mutate(series = recode(series, "Emissions (thousand metric tons of carbon dioxide)" = "total_emissions",
                         "Emissions per capita (metric tons of carbon dioxide" = "emissions_per_capita")) %>%
  pivot_wider(names_from = series, values_from = value) %>%
  #number of observations per year
  filter(year == 2005) %>%
  select(-year) %>%
  #we are renaming these to match categories between tables
  mutate(country=recode(country,
                        "Bolivia (Plurin. State of)" = "Bolivia",
                        "United States of America" = "United States",
                        "Venezuela (Boliv. Rep. of)" = "Venezuela")
  )

#now try anti joining to look for issues
anti_join(gapminder_data_2007,co2_emissions)

gapminder_data_2007 <- read_csv("data/gapminder_data.csv") %>%
  filter(year == 2007 & continent == "Americas") %>%
  select(-year,-continent) %>%
  mutate(country = recode(country,"Puerto Rico" = "United States")) %>%
  group_by(country) %>%
  #weighted avgs of Puerto Rico's population stats
  #summarize consolidates (and "mutates" multiple observations based on provided args)
  summarize(lifeExp = sum(lifeExp*pop)/sum(pop),
            gdpPercap = sum(gdpPercap*pop)/sum(pop),
            pop = sum(pop))

gapminder_co2 <- inner_join(gapminder_data_2007, co2_emissions, by="country")

gapminder_co2 %>%
  mutate(region = if_else(country == "Canada" | country == "United States"
                          | country == "Mexico", "north", "south"))

write_csv(gapminder_co2, "data/gapminder_co2.csv")


gapminder_co2 <- gapminder_co2 %>%
  rename("emissions_per_capita" = "Emissions per capita (metric tons of carbon dioxide)")

#Analyzing and Plotting combined data
ggplot(gapminder_co2) +
  aes(x = gdpPercap, y = emissions_per_capita) +
  geom_point() +
  labs(x = "GDP (per capita)",
       y = "CO2 emitted (per capita)",
       title = "There is a strong association between a nation's GDP \nand
       the amount of CO2 it produces") + geom_smooth(method = "lm")
