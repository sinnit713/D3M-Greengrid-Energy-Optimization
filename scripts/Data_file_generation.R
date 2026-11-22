
seed_ID = 741 # replace 123 with the last 3 digits of your student ID.

seed = seed_ID

generate_energy_data <- function(
    n_suppliers = a ,
    n_periods = b,
    n_alliances = c,
    seed = d,
    file_name = "test.csv"
){
  
  set.seed(seed)
  
  ### ---------------------------
  ### Rule 1: Demand generation
  ### ---------------------------
  
  n_high <- round(0.10 * n_periods)
  n_med  <- round(0.60 * n_periods)
  n_low  <- n_periods - n_high - n_med
  
  d_high <- runif(n_high, 1000, 2000)
  d_med  <- runif(n_med, 100, 1000)
  d_low  <- runif(n_low, 10, 100)
  
  D <- sample(c(d_high, d_med, d_low))
  D <- round(D,0)
  
  ### -----------------------------------
  ### Rule 2: Supplier & alliance limits
  ### -----------------------------------
  
  supplier_limit <- numeric(n_periods)
  alliance_limit <- numeric(n_periods)
  
  for(j in 1:n_periods){
    
    d <- D[j]
    
    if(d >= 1000){
      supplier_limit[j] <- 0.20
      alliance_limit[j] <- 0.40
    }
    else if(d >= 500){
      supplier_limit[j] <- 0.30
      alliance_limit[j] <- 0.50
    }
    else if(d >= 200){
      supplier_limit[j] <- 0.40
      alliance_limit[j] <- 0.60
    }
    else{
      supplier_limit[j] <- 0.60
      alliance_limit[j] <- 0.80
    }
  }
  
  supplier_limit <- round(supplier_limit,2)
  alliance_limit <- round(alliance_limit,2)
  
  ### ---------------------------
  ### Rule 3: MCQ generation
  ### ---------------------------
  
  total_demand <- sum(D)
  
  MCQ <- runif(
    n_suppliers,
    0.10 * total_demand,
    0.16 * total_demand
  )
  
  ### Slight scaling for feasibility
  MCQ <- MCQ * 0.7
  MCQ <- round(MCQ,2)
  
  ### ---------------------------
  ### Rule 4: Price generation
  ### ---------------------------
  
  price_matrix <- matrix(0, n_suppliers, n_periods)
  
  for(j in 1:n_periods){
    
    base_price <- runif(1,20,100)
    
    for(i in 1:n_suppliers){
      
      price <- runif(1,0.8*base_price,1.2*base_price)
      
      if(MCQ[i] > 0.13*total_demand){
        r <- runif(1,0,(MCQ[i]-0.13*total_demand)/(0.26*total_demand))
      } else{
        r <- runif(1,(MCQ[i]-0.13*total_demand)/(0.26*total_demand),0)
      }
      
      price_matrix[i,j] <- (1-r)*price
    }
  }
  
  price_matrix <- round(price_matrix,2)
  
  ### Rule 5: Alliance generation (controlled number)
  
  if(n_alliances > n_suppliers){
    stop("Number of alliances cannot exceed number of suppliers")
  }
  
  suppliers <- sample(1:n_suppliers)
  
  alliances <- vector("list", n_alliances)
  
  remaining <- suppliers
  
  for(k in 1:n_alliances){
    
    remaining_alliances <- n_alliances - k + 1
    remaining_suppliers <- length(remaining)
    
    max_size <- min(6, remaining_suppliers - (remaining_alliances - 1))
    min_size <- max(1, remaining_suppliers - 6*(remaining_alliances - 1))
    
    size <- sample(min_size:max_size,1)
    
    alliances[[k]] <- remaining[1:size]
    
    remaining <- remaining[-(1:size)]
  }
  
  ### ---------------------------
  ### Write dataset to CSV
  ### ---------------------------
  
  con <- file(file_name,"w")
  
  writeLines(paste(D, collapse=","), con)
  writeLines(paste(supplier_limit, collapse=","), con)
  writeLines(paste(alliance_limit, collapse=","), con)
  writeLines(paste(MCQ, collapse=","), con)
  
  for(a in alliances){
    writeLines(paste(a, collapse=","), con)
  }
  
  for(i in 1:n_suppliers){
    writeLines(paste(price_matrix[i,], collapse=","), con)
  }
  
  close(con)
  
  cat("Dataset written to:", file_name,"\n")
}




generate_energy_data(
  n_suppliers = 8,
  n_periods = 3,
  n_alliances = 2,
  seed = seed_ID,
  file_name = "small_data.csv"
)

generate_energy_data(
  n_suppliers = 30,
  n_periods = 300,
  n_alliances = 8,
  seed = seed_ID,
  file_name = "medium_data.csv"
)

generate_energy_data(
  n_suppliers = 50,
  n_periods = 400,
  n_alliances = 10,
  seed = seed_ID,
  file_name = "large_data.csv"
)
