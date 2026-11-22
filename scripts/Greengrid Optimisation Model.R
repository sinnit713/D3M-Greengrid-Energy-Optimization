

#Name: Nitish Kumar Singh
#Program: MSc. Business Analytics


# Note on this code development:
# This code is developed based on the assignment requirement and lecture material on optimization modelling using ompr

# Loading necessary libraries
library(magrittr)
library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)
library(ROI.plugin.highs)

# This sink function logs all the solver message of both "HiGHS" and "GLPK" solver in a separate .txt file  
# and stores it in the same directory where the file path is saved
# Approach for capturing solver logs was implemented with help from ChatGPT
sink("solver_logs.txt")

#Creating Function: GreenGrid Optimization Model
GreenGrid_Optimization_Model <- function(file_path, dataset_name = "dataset") {
  
  # Data extraction logic is implemented based on assignment format
  # Some syntax (like string splitting and matrix construction) was clarified using ChatGPT
  # and is adapted to fit the dataset structure
  
  # READ DATA
  data_lines <- readLines(file_path)
  
  # EXTRACT DATA
  D <- as.numeric(strsplit(data_lines[1], ",")[[1]])
  T <- length(D)
  
  alpha <- as.numeric(strsplit(data_lines[2], ",")[[1]])
  beta  <- as.numeric(strsplit(data_lines[3], ",")[[1]])
  
  m <- as.numeric(strsplit(data_lines[4], ",")[[1]])
  S <- length(m)
  
  total_lines <- length(data_lines)
  A <- total_lines - 4 - S  
  
  alliances <- list()
  for (k in 1:A) {
    alliances[[k]] <- as.numeric(strsplit(data_lines[4 + k], ",")[[1]])
  }
  
  C <- matrix(0, nrow = S, ncol = T)
  for (i in 1:S) {
    C[i, ] <- as.numeric(strsplit(data_lines[4 + A + i], ",")[[1]])
  }
  
  
  # BUILD MILP MODEL
  
  M <- max(D) # Using max(D) as Big-M value after testing, as it is providing a tight bound
  
  # Model formulation using ompr package
  # Syntax for variable definition and constraints was referenced from lecture notes
  # and ompr documentation, and adapted to fit this problem
  
  model <- MIPModel() %>%
    add_variable(x[i, j], i = 1:S, j = 1:T, lb = 0) %>%
    add_variable(y[i], i = 1:S, type = "binary") %>%
    
  set_objective(
    sum_expr(C[i, j] * x[i, j], i = 1:S, j = 1:T), sense = "min") %>%
    
    add_constraint(sum_expr(x[i, j], i = 1:S) == D[j], j = 1:T) %>%
    
    add_constraint(x[i, j] <= alpha[j] * D[j], i = 1:S, j = 1:T) %>%
    
    add_constraint(sum_expr(x[i, j], j = 1:T) >= m[i] * y[i], i = 1:S) %>%
    
    add_constraint(x[i, j] <= M * y[i], i = 1:S, j = 1:T)
  
  for (k in 1:A) {
    model <- model %>%
      add_constraint(sum_expr(x[i, j], i = alliances[[k]]) <= beta[j] * D[j], j = 1:T)
  }
  
  # SOLVE MILP (PART B)
  # Solver integration is done using ROI interface
  # Syntax structure is based on examples from class material
  time_highs <- system.time(
    result_highs <- solve_model(model, with_ROI(solver = "highs", verbose = TRUE, control = list(time_limit = 3600)))
    )
  
  time_glpk <- system.time(
    result_glpk <- solve_model(model, with_ROI(solver = "glpk", verbose = TRUE, control = list(tm_limit = 3600000)))
  )
  
  obj_highs <- objective_value(result_highs)
  obj_glpk  <- objective_value(result_glpk)
  
  runtime_highs <- as.numeric(time_highs["elapsed"])
  runtime_glpk  <- as.numeric(time_glpk["elapsed"])
  
  # LP RELAXATION (PART B)
  model_lp <- MIPModel() %>%
    add_variable(x[i, j], i = 1:S, j = 1:T, lb = 0) %>%
    add_variable(y[i], i = 1:S, lb = 0, ub = 1) %>%
    
  set_objective(
    sum_expr(C[i, j] * x[i, j], i = 1:S, j = 1:T), sense = "min") %>%
    
    add_constraint(sum_expr(x[i, j], i = 1:S) == D[j], j = 1:T) %>%
    
    add_constraint(x[i, j] <= alpha[j] * D[j], i = 1:S, j = 1:T) %>%
    
    add_constraint(sum_expr(x[i, j], j = 1:T) >= m[i] * y[i], i = 1:S) %>%
    
    add_constraint(x[i, j] <= M * y[i], i = 1:S, j = 1:T)
  
  for (k in 1:A) {
    model_lp <- model_lp %>%
      add_constraint(sum_expr(x[i, j], i = alliances[[k]]) <= beta[j] * D[j], j = 1:T)
  }
  
  result_lp <- solve_model(model_lp, with_ROI(solver = "highs", verbose = TRUE))
  obj_lp <- objective_value(result_lp)
  
  # PART D: PRICING FAIRNESS
  model_d <- model %>%
    add_constraint(sum_expr(C[i, j] * x[i, j], i = 1:S) <= 1.2 * D[j] * sum_expr(C[i, j] * y[i], i = 1:S), j = 1:T)
 
   # SOLVE PART D
  time_highs_d <- system.time(
    result_highs_d <- solve_model(model_d, with_ROI(solver = "highs",verbose = TRUE, control = list(time_limit = 3600)))
  )
  
  time_glpk_d <- system.time(
    result_glpk_d <- solve_model(model_d, with_ROI(solver = "glpk", verbose = TRUE,control = list(tm_limit = 3600000)))
  )
  
  obj_highs_d <- objective_value(result_highs_d)
  obj_glpk_d  <- objective_value(result_glpk_d)
  
  runtime_highs_d <- as.numeric(time_highs_d["elapsed"])
  runtime_glpk_d  <- as.numeric(time_glpk_d["elapsed"])
  
  # LP RELAXATION (PART D)
  model_lp_d <- MIPModel() %>%
    add_variable(x[i, j], i = 1:S, j = 1:T, lb = 0) %>%
    add_variable(y[i], i = 1:S, lb = 0, ub = 1) %>%
    
  set_objective(sum_expr(C[i, j] * x[i, j], i = 1:S, j = 1:T), sense = "min") %>%
    
    add_constraint(sum_expr(x[i, j], i = 1:S) == D[j], j = 1:T) %>%
    
    add_constraint(x[i, j] <= alpha[j] * D[j], i = 1:S, j = 1:T) %>%
    
    add_constraint(sum_expr(x[i, j], j = 1:T) >= m[i] * y[i], i = 1:S) %>%
    
    add_constraint(x[i, j] <= M * y[i], i = 1:S, j = 1:T) %>%
    
    add_constraint(sum_expr(C[i, j] * x[i, j], i = 1:S) <= 1.2 * D[j] * sum_expr(C[i, j] * y[i], i = 1:S), j = 1:T)
  
  for (k in 1:A) {
    model_lp_d <- model_lp_d %>%
      add_constraint(sum_expr(x[i, j], i = alliances[[k]]) <= beta[j] * D[j], j = 1:T)
  }
  
  result_lp_d <- solve_model(model_lp_d, with_ROI(solver = "highs", verbose = TRUE))
  obj_lp_d <- objective_value(result_lp_d)
  
  # RETURN RESULTS
  return(list(
    PartB = data.frame(
      MILP_HiGHS = obj_highs,
      Runtime_HiGHS = runtime_highs,
      MILP_GLPK = obj_glpk,
      Runtime_GLPK = runtime_glpk,
      LP_Relaxation = obj_lp
    ),
    PartD = data.frame(
      MILP_HiGHS = obj_highs_d,
      Runtime_HiGHS = runtime_highs_d,
      MILP_GLPK = obj_glpk_d,
      Runtime_GLPK = runtime_glpk_d,
      LP_Relaxation = obj_lp_d
    )
  ))
}

# RUN FOR DATASETS
result_small  <- GreenGrid_Optimization_Model("small.csv", "SMALL")
result_medium <- GreenGrid_Optimization_Model("medium.csv", "MEDIUM")
result_large  <- GreenGrid_Optimization_Model("large.csv", "LARGE")

# STOP LOGGING
sink()
file.show("solver_logs.txt")

# VIEW RESULTS
result_small$PartB
result_small$PartD

result_medium$PartB
result_medium$PartD

result_large$PartB
result_large$PartD

sessionInfo()



