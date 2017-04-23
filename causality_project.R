# Load the libraries 
# To install pcalg library you may first need to execute the following commands:
# source("https://bioconductor.org/biocLite.R")
# biocLite("graph")
# biocLite("RBGL")
install.packages("vars")
library(vars)
install.packages("stats")
library(stats)
install.packages("urca")
library(urca)
install.packages("pcalg")
library(pcalg)
install.packages("Rgraphviz")
library(Rgraphviz)

# Read the input data 
data1 <- read.csv("data.csv")

# Build a VAR model 
# Select the lag order using the Schwarz Information Criterion with a maximum lag of 10
# see ??VARSelect to find the optimal number of lags and use it as input to VAR()
VARselect(data1, lag.max=10, type="const")$selection
var <- VAR(data1, p = 1, type = "const")

# Extract the residuals from the VAR model 
# see ?residuals
var.resid <- resid(var)

# Check for stationarity using the Augmented Dickey-Fuller test 
# see ?ur.df
ur.df(var.resid[,1],selectlags ="BIC")
#The value of the test statistic is: -8.9308 
ur.df(var.resid[,2],selectlags ="BIC")
#The value of the test statistic is: -9.3992 
ur.df(var.resid[,3],selectlags ="BIC")
#The value of the test statistic is: -10.94 

# Check whether the variables follow a Gaussian distribution  
# see ?ks.test
ks.test(var.resid[,1],"pnorm",mean(var.resid[,1]),sd(var.resid[,1]))
# data:  var.resid[, 1]
# D = 0.2261, p-value = 1.757e-11
# alternative hypothesis: two-sided
ks.test(var.resid[,2],"pnorm",mean(var.resid[,2]),sd(var.resid[,2]))
# data:  var.resid[, 2]
# D = 0.13685, p-value = 0.000178
# alternative hypothesis: two-sided

ks.test(var.resid[,3],"pnorm",mean(var.resid[,3]),sd(var.resid[,3]))
# data:  var.resid[, 3]
# D = 0.21043, p-value = 5.293e-10
# alternative hypothesis: two-sided

# Write the residuals to a csv file to build causal graphs using Tetrad software
write.csv(var.resid,"residuals.csv")

# OR Run the PC and LiNGAM algorithm in R as follows,
# see ?pc and ?LINGAM 

# PC Algorithm
suffStat <- list(C=cor(var.resid), n=1000)
pc_fit <- pc(suffStat, indepTest=gaussCItest, alpha=0.05, labels=colnames(var.resid), skel.method="original")
plot(pc_fit, main="PC Output")


# LiNGAM Algorithm
lingam_fit <- LINGAM(var.resid)
show(lingam_fit)