#Import necessary libraries

library(devtools)
#remotes::install_github("joachim-gassen/tidycovid19")

library(tidycovid19)
library(dplyr)
library(tidyr)
library(ggplot2)
library(R0)
library(MASS)

#Get the merged data from tidycovid19 library.
#In case of other countries, replace the 'iso3c' value and the pop.size value in est.R0.TD
#The lastest date of received data is 20-07-2020

df <- download_merged_data(cached = TRUE, silent = TRUE)
vietnamdata <- df %>% filter(iso3c == "USA", date != "2020-07-21") %>% dplyr::select(date, confirmed, recovered)

#The 'id' column contains the number of infected people everyday, which equals the number of confirmed case minus recovered ones.

vietnamdata <- vietnamdata %>% mutate(Id = confirmed - recovered)

#Normalize the data

for (i in 1:(nrow(vietnamdata))) {
  if (is.na(vietnamdata$Id[i])) vietnamdata$Id[i] <- 1
  else if (vietnamdata$Id[i] == 0) vietnamdata$Id[i] <- 1
}

#Fit the data to the log-normal distribution

param <- as.vector(fitdistr(vietnamdata$Id, "lognormal")$estimate)

#Generate the generation time distribution

mGT <- generation.time("lognormal", param)

#Estimate R_0(t) with time-dependant algorithm

est <- est.R0.TD(vietnamdata$Id, mGT, begin = 0, end = 180, pop.size = 90000000, nsim = 500)

#Plot R_0(t) and E(R)

plot <- ggplot(data = data.frame(x = vietnamdata$date[1:179], y = est$R[1:179]), aes(x = x, y = y)) + geom_line() + 
geom_hline(yintercept = mean(est$R[1:179]), color="blue") +
labs(title = "R0 prediction in Vietnam", x = "Time", y = "R0") +
theme_classic() +
theme(plot.title = element_text(size = 16), text = element_text(size = 13), axis.text = element_text(size = 13))