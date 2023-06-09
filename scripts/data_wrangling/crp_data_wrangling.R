# Reproducibility Project: Cancer Biology 
#########################################


#preparing crp (Reproducibility Project Cancer Biology) data set 
# https://osf.io/39s7j

crp<-read.csv(file = "./scripts/data_wrangling/crp.csv", header = TRUE, sep = ",")

crp$Original.sample.size<-as.numeric(crp$Original.sample.size)

#crp <- mutate(crp, index = 1:nrow(crp))

vec_not_NA <- !is.na(crp$Original.sample.size)

crp <- crp[vec_not_NA,]


#selecting relevant columns 

sel <- colnames(crp) %in% c("Original.sample.size","Original.p.value",
                            "Original.effect.size", "Replication.effect.size",
                            "Original.lower.CI","Original.upper.CI", 
                            "Replication.sample.size", "Effect.size.type", "Replication.p.value") 
crp <- crp[,sel]

#assigning standardized names to the tibble
names<-c("orig_ss", "rep_ss", "orig_p_2sided", "rep_p_2sided", "effect_size_type", "orig_d", "orig_ci_low", "orig_ci_high", "rep_d")
colnames(crp)<-names


#############################################
# generating dataset for descriptive analysis 
crp_d <- crp

#write.csv(crp_d, "./scripts/data_wrangling/crp_d.R")
#############################################


crp <- crp %>%
  filter(effect_size_type == "Cohen's d" | effect_size_type == "Glass' delta") %>%
  filter(!is.na(orig_d) == TRUE)

crp$project<-"CRP"

for (i in 1:nrow(crp)) {
  crp$orig_se[i] <-
    ci2se(lower = crp$orig_ci_low[i], 
          upper = crp$orig_ci_high[i])
  
  
  crp$zo[i] <-
    crp$orig_d[i]/crp$orig_se[i]
}






