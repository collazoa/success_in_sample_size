setwd("~/Desktop/samplesize_for_decisionmaking")

# source packages and additional functions
source("./scripts/simulation/functions_for_simulation.R")
source("./scripts/data_wrangling/load_packages.R")


# load combined data of all three replication projects
load("./data/df_combined.RData")

# calculate sample size for replication

# Approach C:
# Replication study powered at 80% for the lower 80% confidence bound 
# obtained from the original study
# if lower CI bound < 0, the rep_sample_size_c column will display NA

# use des() function from compute.es package to compute CI around orig_d
# ci_80_low is the lower bound of the 80% CI

df_combined$ci_80_low <- NULL

for (i in 1:nrow(df_combined)) {
  
  df_combined$ci_80_low[i] <-
    
    des(d =df_combined$ orig_d[i], 
        n.1 = df_combined$orig_ss[i] / 2, 
        n.2 = df_combined$orig_ss[i] / 2,
        level = 80)$l.d
  
}

# now compute replication sample size with the lower 80% confidence bound
rep_sample_size_c <- NULL

for (i in 1:nrow(df_combined)) {
  
  if (df_combined$ci_80_low[i] > 0) {
    
    rep_sample_size_c[i] <-
      ceiling(sample_size_c(data = df_combined[i, ],
                            power = 0.8))
    
  } else {
    
    rep_sample_size_c[i] <- NA
    
  }
  
}

df_combined$rep_sample_size_c <- rep_sample_size_c * 2

# how many of the studies give NA for rep_sample_size?
sum(is.na(df_combined$rep_sample_size_c))

# for simulation do not take NAs
helper <- which(df_combined$rep_sample_size_c != is.na(df_combined$rep_sample_size_c))

##################################
### Simulate replication study ###
### SCENARIO 1: ##################
##################################

# add column study_id to loop over later
df_combined <-
  df_combined %>% 
  mutate(study_id = 1:86) %>% 
  select(study_id, everything())

# set seed to reproduce results
set.seed(84335)

# number of experiments we run for each true underlying effect size
n_exp <- 100

study_id_vector <- c(1:86)

list_rep_data <- 
  
  foreach(study_id = study_id_vector[helper]) %do% {
    
    rep_data <- list()
    
    for(i in 1:n_exp) {
      
      rep_data[[i]] <- 
        
        rep_data[[i]] <- 
        generate_study(ES_true = df_combined$orig_d[study_id] / 2,
                       sample_size = df_combined$rep_sample_size_c[study_id])
      
      rep_data[[i]] <-
        rep_data[[i]] %>% 
        mutate(study_id = study_id_vector[study_id],
               ES_true = df_combined$orig_d[study_id] / 2)
      
    }
    
    list_rep_data <- rep_data
    
  }

rep_data_summary <- list()

plan(multicore)
for (i in 1:length(study_id_vector[helper])) {
  
  rep_data_summary[[i]] <- 
    future_map(list_rep_data[[i]], get_summary_study_rep)
  
}

# rep_data_summary[[1]]

row_names <- NULL
col_names <- c("study_id", "p_value", "effect")

res_summary_rep_c <-
  as_tibble(matrix(unlist(rep_data_summary),
                   nrow = n_exp * length(study_id_vector[helper]), byrow = TRUE,
                   dimnames = list(c(row_names),
                                   c(col_names))))

res_summary_c <-
  res_summary_rep_c %>%
  group_by(study_id) %>%
  summarize(n_success = sum(p_value <= 0.05),
            N = n(),
            pct_success = n_success/N * 100) %>%
  mutate(orig_ss = df_combined$orig_ss[helper],
         rep_sample_size = df_combined$rep_sample_size_c[helper],
         es_true = df_combined$orig_d[helper] / 2,
         sample_size_approach = "c",
         project = df_combined$project[helper],
         scenario = "m_error")

helper_dat <-
  df_combined %>% 
  filter(is.na(rep_sample_size_c)) %>% 
  select(study_id, orig_ss, project)

res_summary_c_m_err <-
  bind_rows(helper_dat, res_summary_c) %>% 
  arrange(study_id) %>% 
  mutate(es_true = df_combined$orig_d[study_id] / 2,
         sample_size_approach = "c",
         scenario = "m_error")
<<<<<<< HEAD

=======
  
>>>>>>> 2d2c31ce1d125297b53024198e4c137373510072

res_summary_c_m_err$conducted <- 
  ifelse(is.na(res_summary_c_m_err$rep_sample_size) | res_summary_c_m_err$rep_sample_size >= 280, "unfeasible", 
         ifelse(res_summary_c_m_err$rep_sample_size < 4, "not_necessary", "yes"))


# save(res_summary_c_m_err, file = "./data/res_summary_c_m_err.RData")


##################################
### Simulate replication study ###
### SCENARIO 2: ##################
##################################

set.seed(84335)

list_rep_data <- 
  
  foreach(study_id = study_id_vector[helper]) %do% {
    
    rep_data <- list()
    
    for(i in 1:n_exp) {
      
      rep_data[[i]] <- 
        
        rep_data[[i]] <- 
        generate_study(ES_true = 0,
                       sample_size = df_combined$rep_sample_size_c[study_id])
      
      rep_data[[i]] <-
        rep_data[[i]] %>% 
        mutate(study_id = study_id_vector[study_id],
               ES_true = 0)
      
    }
    
    list_rep_data <- rep_data
    
  }

rep_data_summary <- list()

plan(multicore)
for (i in 1:length(study_id_vector[helper])) {
  
  rep_data_summary[[i]] <- 
    future_map(list_rep_data[[i]], get_summary_study_rep)
  
}

# rep_data_summary[[1]]

row_names <- NULL
col_names <- c("study_id", "p_value", "effect")

res_summary_rep_c <-
  as_tibble(matrix(unlist(rep_data_summary),
                   nrow = n_exp * length(study_id_vector[helper]), byrow = TRUE,
                   dimnames = list(c(row_names),
                                   c(col_names))))

res_summary_c <-
  res_summary_rep_c %>%
  group_by(study_id) %>%
  summarize(n_success = sum(p_value <= 0.05),
            N = n(),
            pct_success = n_success/N * 100) %>%
  mutate(orig_ss = df_combined$orig_ss[helper],
         rep_sample_size = df_combined$rep_sample_size_c[helper],
         es_true = 0,
         sample_size_approach = "c",
         project = df_combined$project[helper],
         scenario = "null_effect")

helper_dat <-
  df_combined %>% 
  filter(is.na(rep_sample_size_c)) %>% 
  select(study_id, orig_ss, project)

res_summary_c_null <-
  bind_rows(helper_dat, res_summary_c) %>% 
  arrange(study_id) %>% 
  mutate(es_true = 0,
         sample_size_approach = "c",
         scenario = "null_effect")

res_summary_c_null$conducted <- 
  ifelse(is.na(res_summary_c_null$rep_sample_size) | res_summary_c_null$rep_sample_size >= 280, "unfeasible", 
         ifelse(res_summary_c_null$rep_sample_size < 4, "not_necessary", "yes"))

# save(res_summary_c_null, file = "./data/res_summary_c_null.RData")


##################################
### Simulate replication study ###
### SCENARIO 3: ##################
##################################

set.seed(84335)

list_rep_data <- 
  
  foreach(study_id = study_id_vector[helper]) %do% {
    
    rep_data <- list()
    
    for(i in 1:n_exp) {
      
      rep_data[[i]] <- 
        
        rep_data[[i]] <- 
        generate_study(ES_true = df_combined$orig_d[study_id] - (1.25 * df_combined$orig_d[study_id]),
                       sample_size = df_combined$rep_sample_size_c[study_id])
      
      rep_data[[i]] <-
        rep_data[[i]] %>% 
        mutate(study_id = study_id_vector[study_id],
               ES_true = df_combined$orig_d[study_id] - (1.25 * df_combined$orig_d[study_id]))
      
    }
    
    list_rep_data <- rep_data
    
  }

rep_data_summary <- list()

plan(multicore)
for (i in 1:length(study_id_vector[helper])) {
  
  rep_data_summary[[i]] <- 
    future_map(list_rep_data[[i]], get_summary_study_rep)
  
}

# rep_data_summary[[1]]

row_names <- NULL
col_names <- c("study_id", "p_value", "effect")

res_summary_rep_c <-
  as_tibble(matrix(unlist(rep_data_summary),
                   nrow = n_exp * length(study_id_vector[helper]), byrow = TRUE,
                   dimnames = list(c(row_names),
                                   c(col_names))))

res_summary_c <-
  res_summary_rep_c %>%
  group_by(study_id) %>%
  summarize(n_success = sum(p_value <= 0.05),
            N = n(),
            pct_success = n_success/N * 100) %>%
  mutate(orig_ss = df_combined$orig_ss[helper],
         rep_sample_size = df_combined$rep_sample_size_c[helper],
         es_true = df_combined$orig_d[study_id] - (1.25 * df_combined$orig_d[study_id]),
         sample_size_approach = "c",
         project = df_combined$project[helper],
         scenario = "s_error")

helper_dat <-
  df_combined %>% 
  filter(is.na(rep_sample_size_c)) %>% 
  select(study_id, orig_ss, project)

res_summary_c_s_err <-
  bind_rows(helper_dat, res_summary_c) %>% 
  arrange(study_id) %>% 
  mutate(es_true = df_combined$orig_d[study_id] - (1.25 * df_combined$orig_d[study_id]),
         sample_size_approach = "c",
         scenario = "s_error")

res_summary_c_s_err$conducted <- 
  ifelse(is.na(res_summary_c_s_err$rep_sample_size) | res_summary_c_s_err$rep_sample_size >= 280, "unfeasible", 
         ifelse(res_summary_c_s_err$rep_sample_size < 4, "not_necessary", "yes"))

# save(res_summary_c_s_err, file = "./data/res_summary_c_s_err.RData")


res_summary_c <- 
  bind_rows(res_summary_c_m_err, 
            res_summary_c_null, 
            res_summary_c_s_err)

<<<<<<< HEAD
# save(res_summary_c, file = "./data/res_summary_c.RData")
=======
# save(res_summary_c, file = "./data/res_summary_c.RData")
>>>>>>> 2d2c31ce1d125297b53024198e4c137373510072
