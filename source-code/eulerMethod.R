# Import necessry libraries

library(ggplot2)
library(tidyr)

# Initialize variables from user input

s0 <- readline("Initial value of S: ")
i0 <- readline("Initial value of I: ")
r0 <- readline("Initial value of R: ")
beta <- readline("Possion rate (beta): ")
gamma <- readline("Recovery rate (gamma): ")
t <- readline("Period of time: ")

s0 <- as.numeric(s0)
i0 <- as.numeric(i0)
r0 <- as.numeric(r0)
beta <- as.numeric(beta)
gamma <- as.numeric(gamma)
t <- as.numeric(t)

#Predict SIR value based on Euler's algorithm

euler <- function(s0, i0, r0, beta, gamma, t) {
  s = i = r = numeric(t + 1)
  N = s0 + i0 + r0
  s[1] = s0; i[1] = i0; r[1] = r0
  j = 1
  while (j <= t) {
    s[j+1] = s[j] + (-beta*i[j]*s[j])
    i[j+1] = i[j] + (beta*i[j]*s[j]) - gamma*i[j]
    r[j+1] = r[j] + (gamma*i[j])
    j = j + 1
  }
  x = 0:t
  return (data.frame(Time = x, Susceptible = s, Infectious = i, Recovered = r))
}

#Get the result and display it

res <- euler(s0, i0, r0, beta, gamma, t)
View(res)

#Create a line plot to visualize results

res %>% gather(key, value, Susceptible, Infectious, Recovered) %>% ggplot(aes(x = Time, y = value, colour = key, shape = key)) + 
  geom_line(size = 1) +
  labs(title = "SIR Prediction", x = "Time", y = "Number of people (Scaled)") +
  theme_classic() +
  theme(plot.title = element_text(size = 16), text = element_text(size = 13), axis.text = element_text(size = 13)) +
  theme(legend.position = c(0.9, 0.85), legend.title = element_blank(), legend.background = element_blank(), legend.box.background = element_rect(color = "black")) 
