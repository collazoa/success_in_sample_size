# Data wranging for Descriptive analysis and visualization

source("./scripts/data_wrangling/load_packages.R")


#selecting relevant columns 
##################################################
#
# crp

crp_d <- read.csv("./scripts/data_wrangling/crp_d.R") 
crp_d$project <- "CRP"
 
######################################
#
# bri

bri_d <- read.csv("./scripts/data_wrangling/bri_d.R")

#######################################
#
# cps 

cps_d <- read.csv("./scripts/data_wrangling/cps_d.R")
cps_d$project <- "CPS"


#######################################
# merge project for description 

vec_col <- c("project", "orig_ss", "rep_ss", "orig_d")


crp_des<-crp_d[,vec_col]

bri_des<-bri_d[,vec_col]

cps_des<-cps_d[,vec_col]

df_descriptive <- rbind(cps_des, crp_des, bri_des) 

write.csv(df_descriptive, "./scripts/data_wrangling/df_descriptive.R")






