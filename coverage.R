#!/usr/bin/env Rscript

#install and call required packages
install.packages(dplyr)
library(dplyr)

#set working directory to where bedtools coverage files are. 
setwd("C:/Users/katiehanratty/Documents/Research_Project/Bedtools_Coverage")

#list the depth files in working directory.
bed_files <- list.files(pattern = "*.txt") 

get_value <- function(df, depth_value, column) {
  value <- df %>% filter(depth == depth_value) %>% slice_head(n = 1) %>% pull({{ column }})
  if (length(value) == 0) return(NA) else return(value)
}

#create loop for all depth of coverage files

# Loop through each file and create a data table from all rows with 'all' in column 1
for (file in bed_files) {
  data <- read.table(file=file, header=FALSE)
  colnames(data) <- c("col1", "depth", "num_bases", "total_targeted_bases", "proportion_targeted_bases")
  coverage <- filter(data, col1 == "all") %>% arrange(desc(depth))
  if (nrow(coverage) == 0) {
    print(paste("Skipping file (no 'all' rows found):", file))
    next 
  }
  
  # Calculate cumulative percentage of targetted bases
  coverage$cumulative_percentage <- (cumsum(coverage$proportion_targeted_bases) * 100)
  
  # Calculate average read depth
  avg_read_depth <- weighted.mean(coverage$depth, coverage$proportion_targeted_bases, na.rm = TRUE)
  
  # Save key statistics in a summary table
  summary_stats <- data.frame(
    File = file,
    No_Coverage_Bases = get_value(coverage, 0, num_bases),
    No_Coverage_Percentage = get_value(coverage, 0, proportion_targeted_bases) * 100,
    Coverage_10x = get_value(coverage, 10, cumulative_percentage),
    Coverage_30x = get_value(coverage, 30, cumulative_percentage),
    Coverage_100x = get_value(coverage, 100, cumulative_percentage),
    Average_Read_Depth = avg_read_depth  
  )
  
  # Save these summary statistics to a CSV file
  write.csv(summary_stats, paste0("summary_", file, ".csv"), row.names = FALSE)
  
  print(paste("Processed:", file))
} #end of loop
