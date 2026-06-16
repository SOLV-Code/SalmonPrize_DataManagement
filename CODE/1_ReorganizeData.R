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
  mutate(TotRecPerTotSpn = round(Total_Recruits/Total_Spawners_BroodYear,3)) %>%
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
cat("\n\n")
cat("THIS DATA PROCESSING CODE WAS JUST CREATED FRESH AND IS STILL UNDER DEVELOPMENT.\n")
cat("PLEASE DOUBLE CHECK AND LEAVE A COMMENT IF ANYTHING LOOKS WEIRD.\n")
cat("For comments, go to the Issues page at https://github.com/SOLV-Code/SalmonPrize_DataManagement/issues")

sink()


# Add a template for the retrospective submission

retro.yrs <- tail(sort(unique(returns.df$ReturnYear)),5)

retro.df <- returns.df %>% select(System,River,	ReturnYear) %>%
            dplyr::filter(ReturnYear %in% retro.yrs ) %>%
            mutate(Predicted_TotalReturn = NA)

write_csv(retro.df,paste0(target.folder,"/Retrospective_Template.csv"))

sink(paste0(target.folder,"/Retrospective_Notes.txt"))
cat("RETROSPECTIVE NOTES\n\n")

cat("To enter for the retrospective prize:")
cat("\n\n")
cat("- Apply your candidate model in a true retrospective (e.g., use data up to 2023 to predict 2024)")
cat("\n\n")
cat("- Copy the results into the template")
cat("\n\n")
cat("You should be able to upload the complete template as part of the additional documentation field on the website.\n")
cat("If you run into any issues with the upload, just e-mail the file to one of the organizers.\n")


sink()





}


####################################################################################
# 2026 Sockeye International - COLUMBIA
####################################################################################

reorg_data(path = "DATA/2026_Sockeye_International/Columbia",
           label= "DataPackage_Columbia_2026",
           sr.last.bryr = 2019)
            # have returns for 2025, and using ages 3:6
            # 2019 is the last year for which we have age 6 recruits


####################################################################################
# 2026 Sockeye International - FRASER
####################################################################################

# prep: extract and reorg the returns by age

ages.lookup <- read_csv("DATA/Lookup_Files/MANUALLY_UPDATED_AgeClass_Lookup.csv",comment="#")

psc.sr.src <- read_csv("DATA/2026_Sockeye_International/Fraser/1_SourceData/PSC_Download/Stock-recruit-Data_Detailed-Format.csv") %>%
  dplyr::filter(!is.na(age)) %>%
  left_join(ages.lookup %>% select(Euro,GRShort) %>% dplyr::rename(age = GRShort), by = "age")


sort(unique(psc.sr.src$production_stock_name))

# extract returns by age

fraser.stks.vec <- c("Chilko","Late Stuart","Quesnel","Raft", "Stellako" )

fraser.returns <- psc.sr.src %>%
  dplyr::filter(production_stock_name %in% fraser.stks.vec) %>%
  mutate(System = "Fraser River") %>%
  dplyr::rename(River = production_stock_name,ReturnYear = returnyr) %>%
  pivot_wider(id_cols = c(System, River, ReturnYear),
              names_prefix = "AgeClass_", names_from = Euro,values_from = num_recruits) %>%
  replace_na(list(AgeClass_1.1 = 0, AgeClass_2.2 = 0)) %>% # fill in missing years for minor ages with 0 to get sum
  mutate(Total_Returns = AgeClass_1.1 + AgeClass_1.2 + AgeClass_1.3 + AgeClass_2.2) %>%
  select(System, River, ReturnYear,Total_Returns,everything()) %>%
  dplyr::filter(!is.na(ReturnYear))


# save to file -> his will be used in the reorg_data( function)
fraser.returns.filename <- "DATA/2026_Sockeye_International/Fraser/1_SourceData/ReturnsbyAge_FRASER_2026.csv"

comment.text1 <- paste("# FRASER SOCKEYE RETURNS BY AGE")
comment.text2 <- paste("# Data extracted from the Pacific Salmon Commission data page in June 2026")
comment.text3 <- paste("# Specifically the detailed version of the Fraser Sockeye Spawner-Recruit Data Set at")
comment.text4 <- paste("# https://www.psc.org/publications/data/fraser-sockeye-stock-recruit-dataset/")
comment.text5 <- paste("# The same website has detailed documentation for the data")
comment.text6 <- paste("# NOTES for this data set are available at https://github.com/SOLV-Code/SalmonPrize_DataManagement/tree/main/DATA/2026_Sockeye_International/Fraser")
comment.text7 <- paste("# IMPORTANT: Total_Returns are the sum of Ages 1.1; 1.2; 1.3; 2.2")


write_lines(comment.text1, fraser.returns.filename)
write_lines(comment.text2, fraser.returns.filename, append = TRUE)
write_lines(comment.text3, fraser.returns.filename, append = TRUE)
write_lines(comment.text4, fraser.returns.filename, append = TRUE)
write_lines(comment.text5, fraser.returns.filename, append = TRUE)
write_lines(comment.text6, fraser.returns.filename, append = TRUE)
write_lines(comment.text7, fraser.returns.filename, append = TRUE)

fraser.returns  |> colnames() |> paste0(collapse = ",") |> write_lines(fraser.returns.filename, append = TRUE)
write_csv(fraser.returns, fraser.returns.filename , append = TRUE)



#  Generate spawner input file from PSC source, filling in missing years from DFO source.

fraser.spawners <- psc.sr.src %>%
  dplyr::filter(production_stock_name %in% fraser.stks.vec) %>%
  mutate(System = "Fraser River") %>%
  dplyr::rename(Stock = production_stock_name,BroodYear = broodyr) %>%
  select(BroodYear,Stock,total_broodyr_spawners) %>%
  unique() %>%
  pivot_wider(id_cols = c(BroodYear),
              names_from = Stock,values_from = total_broodyr_spawners)

spn.dfo.src <- read_csv("DATA/2026_Sockeye_International/Fraser/1_SourceData/DFO_SpawnerFile/DFO_SpawnerData_SupplementarySource.csv",
                    comment="#")

dfo.totspn <- spn.dfo.src %>% dplyr::filter(Variable == "TotalSpawners") %>%
                select(-Variable)

missing.yrs.idx <- !(dfo.totspn$BroodYear %in% fraser.spawners$BroodYear)
missing.yrs.idx

fraser.spawners <- rbind(fraser.spawners, dfo.totspn[missing.yrs.idx,]) %>%
                  arrange(BroodYear)

# save to file -> his will be used in the reorg_data( function)
fraser.spawners.filename <- "DATA/2026_Sockeye_International/Fraser/1_SourceData/Spawners_FRASER_2026.csv"

comment.text1 <- paste("# FRASER SOCKEYE TOTAL SPAWNERS")
comment.text2 <- paste("# Data extracted from the Pacific Salmon Commission data page in June 2026")
comment.text3 <- paste("# Specifically the detailed version of the Fraser Sockeye Spawner-Recruit Data Set at")
comment.text4 <- paste("# https://www.psc.org/publications/data/fraser-sockeye-stock-recruit-dataset/")
comment.text5 <- paste("# The same website has detailed documentation for the data")
comment.text6 <- paste("# NOTES for this data set are available at https://github.com/SOLV-Code/SalmonPrize_DataManagement/tree/main/DATA/2026_Sockeye_International/Fraser")
comment.text7 <- paste("# IMPORTANT: Missing recent years are filled in from file provided by DFO (Kaitlyn Dionne; Brian Smith)")


write_lines(comment.text1, fraser.spawners.filename)
write_lines(comment.text2, fraser.spawners.filename, append = TRUE)
write_lines(comment.text3, fraser.spawners.filename, append = TRUE)
write_lines(comment.text4, fraser.spawners.filename, append = TRUE)
write_lines(comment.text5, fraser.spawners.filename, append = TRUE)
write_lines(comment.text6, fraser.spawners.filename, append = TRUE)
write_lines(comment.text7, fraser.spawners.filename, append = TRUE)

fraser.spawners  |> colnames() |> paste0(collapse = ",") |> write_lines(fraser.spawners.filename, append = TRUE)
write_csv(fraser.spawners, fraser.spawners.filename , append = TRUE)


# Generate Data Pack
reorg_data(path = "DATA/2026_Sockeye_International/Fraser",
           label= "DataPackage_Fraser_2026",
           sr.last.bryr = 2019)
# have returns for 2025, and using ages 3:6
# 2019 is the last year for which we have age 6 recruits



#  Generate alternative spawner file with Effective Females from PSC source, filling in missing years from DFO source.

fraser.efs <- psc.sr.src %>%
  dplyr::filter(production_stock_name %in% fraser.stks.vec) %>%
  mutate(System = "Fraser River") %>%
  dplyr::rename(Stock = production_stock_name,BroodYear = broodyr) %>%
  select(BroodYear,Stock,total_broodyr_EFS) %>%
  unique() %>%
  pivot_wider(id_cols = c(BroodYear),
              names_from = Stock,values_from = total_broodyr_EFS)

dfo.efs <- spn.dfo.src %>% dplyr::filter(Variable == "EffectiveFemales") %>%
  select(-Variable)

missing.yrs.idx <- !(dfo.efs$BroodYear %in% fraser.efs$BroodYear)
missing.yrs.idx

fraser.efs <- rbind(fraser.efs, dfo.efs[missing.yrs.idx,]) %>%
  arrange(BroodYear)

# save to file -> his will be used in the reorg_data( function)
fraser.efs.filename <- "DATA/2026_Sockeye_International/Fraser/DataPackage_Fraser_2026/ALT_Spawners_EffectiveFemales_FRASER_2026.csv"

comment.text1 <- paste("# FRASER SOCKEYE EFFECTIVE FEMALES")
comment.text2 <- paste("# Data extracted from the Pacific Salmon Commission data page in June 2026")
comment.text3 <- paste("# Specifically the detailed version of the Fraser Sockeye Spawner-Recruit Data Set at")
comment.text4 <- paste("# https://www.psc.org/publications/data/fraser-sockeye-stock-recruit-dataset/")
comment.text5 <- paste("# The same website has detailed documentation for the data")
comment.text6 <- paste("# NOTES for this data set are available at https://github.com/SOLV-Code/SalmonPrize_DataManagement/tree/main/DATA/2026_Sockeye_International/Fraser")
comment.text7 <- paste("# IMPORTANT: Missing recent years are filled in from file provided by DFO (Kaitlyn Dionne; Brian Smith)")


write_lines(comment.text1, fraser.efs.filename)
write_lines(comment.text2, fraser.efs.filename, append = TRUE)
write_lines(comment.text3, fraser.efs.filename, append = TRUE)
write_lines(comment.text4, fraser.efs.filename, append = TRUE)
write_lines(comment.text5, fraser.efs.filename, append = TRUE)
write_lines(comment.text6, fraser.efs.filename, append = TRUE)
write_lines(comment.text7, fraser.efs.filename, append = TRUE)

fraser.efs  |> colnames() |> paste0(collapse = ",") |> write_lines(fraser.efs.filename, append = TRUE)
write_csv(fraser.efs, fraser.efs.filename , append = TRUE)


