# REORGANIZE THE DATA


# install/load required packages

if(!"tidyverse"%in%installed.packages()[,"Package"]){install.packages("tidyverse")}
library(tidyverse)


# custom function to handle the standard data reorg
# requires a path to a folder that contains
# a folder called "1_SourceData" with 2 files
# - Returns_ByAge_SOMELABEL.csv
# - Spawners_SOMELABEL.csv
# The function creates a folder with user-specified label
# that contains the reorganized csv files (by brood year,
# by first year at sea, Spawner-recruit)
# STILL NEED TO IMPLEMENT: STOCK SPECIFIC BROOD YEAR CUT_OFF
# FOR SR_DATA TO ONLY SHOW "FULL" COHORTS
# For now put in a user argument: sr.last.bryr

reorg_data <- function(path, label="DataPackage",sr.last.bryr){

target.folder <- paste(path,label, sep="/")

# create target folder if it doesn't exist
if(!dir.exists(target.folder)){dir.create(target.folder)}

# read in source files

# returns are the adults coming back in a calendar year at different ages
# (i.e., they come from different brood years)
returns.file <- list.files(paste0(path,"/1_SourceData") ,pattern = "^[\bReturnsByAge]",full.names=TRUE)
returns.df <- read_csv(returns.file,comment = "#")

spawners.file <- list.files(paste0(path,"/1_SourceData") ,pattern = "^[\bSpawners]",full.names=TRUE)
spawners.df <- read_csv(spawners.file,comment = "#")


# read in lookup files
age.classes.src <- read_csv("DATA/Lookup_Files/MANUALLY_UPDATED_AgeClass_Lookup.csv",comment="#")
stk.src <- read_csv("DATA/Lookup_Files/MANUALLY_UPDATED_Stock_Lookup.csv",comment="#")

# generate data frame with all the matches in long format
# NOTE: recruits by brood year calculation constrained to ages 3-6
#       to get some extra brood year recruit numbers
#      age comp in last brood year may be wonky, depending on stock -> should check!

full.data.long.df <- returns.df %>% pivot_longer(starts_with("AgeClass_"),names_to = "Label",values_to = "ReturnsByAgeClass") %>%
  left_join(age.classes.src,by="Label") %>%
  mutate(BroodYear = ReturnYear - Age, RecruitsByAgeClass = ReturnsByAgeClass) %>%
  mutate(MarineEntryYear = BroodYear + FW_Winters + 1 )

total.rec.calc <- full.data.long.df  %>%
  dplyr::filter(Age %in% 3:6) %>%
  group_by(System,River,BroodYear) %>%
  summarize(Total_Recruits = sum(RecruitsByAgeClass)) %>% ungroup()

full.data.long.df <- full.data.long.df %>% left_join(total.rec.calc,by = c("System","River","BroodYear") ) %>%
  mutate(PercOfBrdYr = round(RecruitsByAgeClass/Total_Recruits*100,2) )  %>%
  arrange(System, River, BroodYear, Age, Label) %>%
  left_join(spawners.df %>% pivot_longer(2:dim(spawners.df)[2],
                                    names_to = "River",values_to = "Total_Spawners_BroodYear") ,
            by=c("BroodYear","River")) %>%
  mutate(TotRecPerTotSpn = Total_Recruits/Total_Spawners_BroodYear) %>%
  arrange(System,River,ReturnYear,BroodYear) #%>%
  #left_join(efs.src %>% select(-Total_Spawners_BroodYear),by=c("BroodYear","River"))
  # NEED TO BUILD IN FLEXIBILITY FOR EFFECTIVE FEMALE SPAWNERS WHEN THE FRASER DATA COMES IN!


# Generate S-R Data

sr.df <-    spawners.df %>% pivot_longer(2:dim(spawners.df)[2], names_to = "River",values_to = "Total_Spawners_BroodYear") %>%
            left_join(stk.src %>% select(River,System), by="River") %>%
            left_join(full.data.long.df %>% select(River,BroodYear, Total_Recruits,TotRecPerTotSpn) %>% unique(),
                    by=c("BroodYear","River"))  %>%
            arrange(System, River, BroodYear)  %>%
            dplyr::filter(!is.na(Total_Spawners_BroodYear)) %>%
            select(System, River, BroodYear, everything())

# temp patch to clear out incomplete cohorts at the end

sr.df[sr.df$BroodYear > sr.last.bryr,c("Total_Recruits","TotRecPerTotSpn")] <-  NA





# write files to data package

write_csv(returns.df,paste0(target.folder,"/ReturnsByAge_WideFormat.csv"))
write_csv(spawners.df,paste0(target.folder,"/Spawners_WideFormat.csv"))
file.copy("DATA/Lookup_Files/MANUALLY_UPDATED_AgeClass_Lookup.csv",
          paste0(target.folder,"/KeyToAgeClasses.csv") )
write_csv(full.data.long.df,paste0(target.folder,"/FullDataSet_LongFormat.csv"))
write_csv(sr.df,paste0(target.folder,"/SpawnerRecruit_ByBroodYear.csv"))


# Add a notes file

sink(paste0(target.folder,"/DataNotes.txt"))
cat("DATA NOTES\n\n")
cat("Data Package created on ")
cat(as.character(Sys.Date()))
cat("\n\n")
cat("Documentation at https://github.com/SOLV-Code/SalmonPrize_DataManagement")
cat("\n\n")
cat("Source files and notes for this data package in the folder\n")
cat(path)
cat("\n\n")
cat("R code to generate these files is at CODE/1_ReorganizeData.R")

cat("THIS DATA PROCESSING CODE WAS JUST CREATED FRESH AND IS STILL UNDER DEVELOPMENT.\n")
cat("PLEASE DOUBLE CHECK AND LEAVE A COMMENT IF ANYTHING LOOKS WEIRD.\n")
cat("For comments, go to the Issues page at https://github.com/SOLV-Code/SalmonPrize_DataManagement/issues")

sink()



}



# 2026 Sockeye International - COLUMBIA

reorg_data(path = "DATA/2026_Sockeye_International/Columbia",
           label= "DataPackage_Columbia_2026",
           sr.last.bryr = 2019)
            # have returns for 2025, and using ages 3:6
            # 2019 is the last year for which we have age 6 recruits

