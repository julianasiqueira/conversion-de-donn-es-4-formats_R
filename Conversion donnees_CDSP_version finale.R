
#2020-11 version 0.1
#R script to unzip and convert data files in 4 formats
# update the init data to scan and modify a batch of "enquetes"
# the input files should be .zip and contains .sav or .csv data (set in the init data)
# phase of the script : Load lib >> init data >> load data >> convert data >> move other files to the results folder


# *****************loading libraries*****************
library(tidyverse)
library(haven)

#*****************init data*****************
ENQUETES_dir<-"C:/data_cdsp/data/ENQUETES - Copie"
ENQUETES_name<-c("Enquêtes interrégionales des phénomènes politiques (1985-2004)")# "Baromètre de la citoyenneté" 'Database regarding the North Indian MPs since 1952' 'Démocratie 2000''Enquête députés 1968''Enquêtes Agoramétrie (1977-2005)''Enquêtes auprès des élus'
#'Enquêtes électorales françaises''Enquêtes IFEN sur l'environnement''Enquêtes Image de la science' 'Enquêtes interrégionales des phénomènes politiques (1985-2004)' 'Enquêtes OIP Jeunes et Seniors' 'French Electoral Study'
#'General election study Belgium' 'La socialisation professionnelle des gardiens de la paix''Les militants socialistes à l'épreuve du pouvoir (1984-1986)' 'Panel électoral français'
#'Sondages de Sortie des Urnes 1995' 'Regional Income Inequality in the United States (1917-2011)' 'Autres'
tmpfolder<-"temp" #used to store unzip information during processing
INPUTFORMAT<-".sav" #input file format to convert possible inputs : ".sav" , ".csv" 
SUBT <- 8 # subtract the characters ZIP and or SAV from the name of the folders and/or directories : 8 , 4

#*****************loading data*****************

#Move to the work directory (enquete folder)
setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/"))

#listing the zip file to process
file_names <- list.files(paste0(ENQUETES_dir,"/",ENQUETES_name[1]))

# unzip multiple files in cdsp_cidem directory
walk(file_names, ~ unzip(zipfile = str_c(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/"), .x), 
                         exdir = str_c(paste0(tmpfolder,"/"), .x)))

#move to the tmp folder
setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder))

# create a list from these files _ identify all the files with the selected INPUTFORMAT
list.filenames<-list.files(pattern = INPUTFORMAT,recursive = TRUE) #list all files  the input file format (INPUTFORMAT) example ".sav" use the pattern argument to define a common pattern  for import files
list.files(recursive = TRUE) #list of subfolders and files within the subfolders
list.filenames

# create an empty list that will serve as a container to receive the incoming files
list.data<-list()

# Read SAV data and convert in data frame
if(INPUTFORMAT==".sav")
{
# create a loop to read in your data
  i<-1
for (i in 1:length(list.filenames))
{
  list.data[[i]]<-read_sav(list.filenames[i])
  list.data[[i]]<-as.data.frame(list.data[[i]])
}#end for
}#end if SAV

# Read csv data and convert in data frame
if(INPUTFORMAT==".csv")
{
# create a loop to read in your data
  i<-1
for (i in 1:length(list.filenames))
{
  list.data[[i]]<-read.table(list.filenames[i], header = FALSE, dec =",", sep = ";")
  list.data[[i]]<-as.data.frame(list.data[[i]])
}#end for
}#end if CSV


# add the names of your data to the list
#names(list.data)<-list.filenames

# now you can index one of your tables like this
#list.data[1]
#list.data[2]
#list.data[3]

# save it to the folder with your custom functions
save(list.data,file="list.data.RData")

# load it like this whenever you need it in another script with

load("list.data.RData")

# *****************CONVERT Data***************** 

fileformat<-c("STATA","CSV","SPSS","SAS")
setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder))
i<-1
# Loop to create output directories and subdirectories
for(i in 1:length(list.filenames)) {
  tmp_filename<-str_split(list.filenames[i],"/",simplify = TRUE)
  new_filename<-substr(tmp_filename[1,1],1,nchar(tmp_filename[1,1]) -SUBT)#removing .zip (-4) and/or .sav(-4) of the output folder name
  
  dir.create(path = paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",new_filename, "/Donnees/STATA"), recursive = TRUE)
  dir.create(path = paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",new_filename, "/Donnees/CSV"), recursive = TRUE)
  dir.create(path = paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",new_filename, "/Donnees/SPSS"), recursive = TRUE)
  dir.create(path = paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",new_filename, "/Donnees/SAS"), recursive = TRUE)
}#end for 

# create a loop to convert and store your data
i<-1
for (i in 1:length(list.filenames))# loop on the folder to address
{j<-1
  for (j in 1:4)#converting and storing the data files
    {
    tmp_filename<-str_split(list.filenames[i],"/",simplify = TRUE) #retruve the results folder name
    new_filename<-substr(tmp_filename[1,1],1,nchar(tmp_filename[1,1])-SUBT)#removing .zip of the output folder name
    
    setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",new_filename,"/Donnees/", fileformat[j]))
      if (j==1){write_dta(list.data[[i]],paste0(new_filename,".dta"))}
      if (j==2){write.csv2(list.data[[i]],paste0(new_filename,".csv"))}
      if (j==3){write_sav(list.data[[i]],paste0(new_filename,".sav"))}
      if (j==4){write_sas(list.data[[i]],paste0(new_filename,".sas7bdat"))}
 
    }#end for j
}#end for i
setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1]))


# *****************move other files to the result folder*****************

setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder))# move to temp folder
list.filenames<-list.files(pattern = INPUTFORMAT,recursive = TRUE) #list all files  the input file format (INPUTFORMAT) example ".sav" use the pattern argument to define a common pattern  for import files
list.files(recursive = TRUE) #list of subfolders and files within the subfolders
list.filenames

for (n in 1:length(list.filenames))
{
  tmp_filename<-str_split(list.filenames[n],"/",simplify = TRUE) #retrive the results folder name

  setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder,"/",tmp_filename[1,1]))
  
  #indentify the data files prossed (inputformat) and delete them from temp folder
  tmp_fileslist<-list.files(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder,"/",tmp_filename[1,1]))
  tmp_list.filenames<-list.files(pattern = INPUTFORMAT,recursive = TRUE)
  file.remove(tmp_list.filenames)
  # list all the other files remaing in the temp folder and copy them in the destination folder
  
  tmp_fileslist<-list.files(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder,"/",tmp_filename[1,1]))
  destination_folder<-str_split(list.filenames[i],"/",simplify = TRUE) #retrive the results folder name
  destination_folder<-substr(tmp_filename[1,1],1,nchar(tmp_filename[1,1])-SUBT)#removing .zip of the output folder name

  file.copy(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder,"/",tmp_filename[1,1],"/",tmp_fileslist),paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",destination_folder,"/",tmp_fileslist),overwrite = TRUE)
  
}# end for n



# *****************delete the temporary files*****************

#file_tmp <- list.files(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder))#list all folder and files in temp

#for (n in 1:length(file_tmp))# parse all folder and delete files
#{
#setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder,"/",file_tmp[n]))
#file_to_del<-list.files(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder,"/",file_tmp[n]))
#file.remove(file_to_del)
#}# end for n

#delete tmp folders. note you might run the script with the admin right to be able to perform this action
#setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1],"/",tmpfolder))
#file.remove(file_tmp)
#setwd(paste0(ENQUETES_dir,"/",ENQUETES_name[1]))
#file.remove(tmpfolder)





















# *****************Panel électoral français *****************

setwd("C:/data_cdsp/data/ENQUETES/Panel électoral français/cdsp_pef2007/Donnees/")

library(haven)

PEF2017 <- read_sav('SPSS/cdsp_pef2007_v1p1.sav')
write_dta(PEF2017,'STATA/cdsp_pef2007_v1p1.dta')
write.csv2(PEF2017,'CSV/cdsp_pef2007_v1p1.csv')
write_sas(PEF2017,'SAS/cdsp_pef2007_v1p1.sas7bdat') #

PEF2017_2 <- read_sav('SPSS/cdsp_pef2007_v1p1+p2.sav')
write_dta(PEF2017_2,'STATA/cdsp_pef2007_v1p1+p2.dta')
write.csv2(PEF2017_2,'CSV/cdsp_pef2007_v1p1+p2.csv')
write_sas(PEF2017_2,'SAS/cdsp_pef2007_v1p1+p2.sas7bdat') #


PEF2017_3 <- read_sav('SPSS/cdsp_pef2007_v1p1+p2+p3.sav')
write_dta(PEF2017_3,'STATA/cdsp_pef2007_v1p1+p2+p3.dta')
write.csv2(PEF2017_3,'CSV/cdsp_pef2007_v1p1+p2+p3.csv')
write_sas(PEF2017_3,'SAS/cdsp_pef2007_v1p1+p2+p3.sas7bdat') #

PEF2017_4 <- read_sav('SPSS/cdsp_pef2007_v1p1+p2+p3+p4.sav')
write_dta(PEF2017_4,'STATA/cdsp_pef2007_v1p1+p2+p3+p4.dta')
write.csv2(PEF2017_4,'CSV/cdsp_pef2007_v1p1+p2+p3+p4.csv')
write_sas(PEF2017_4,'SAS/cdsp_pef2007_v1p1+p2+p3+p4.sas7bdat') #

# *****************Regional Income Inequality in the United States (1917-2011)*****************

setwd("C:/data_cdsp/data/ENQUETES/Regional Income Inequality in the United States (1917-2011)/cdsp_riius2011/")

library(readxl)
RIIUS <- read_xlsx('Regional_Income_Inequality_in_the_United_States_1917_2011.xlsx',1) # read in the first worksheet from the workbook myexcel.xlsx
write_sav(RIIUS,'Donnees/SPSS/Regional_Income_Inequality_in_the_United_States_1917_2011.sav')
write_dta(RIIUS,'Donnees/STATA/Regional_Income_Inequality_in_the_United_States_1917_2011.dta')
write.csv2(RIIUS,'Donnees/CSV/Regional_Income_Inequality_in_the_United_States_1917_2011.csv')
write_sas(RIIUS,'Donnees/SAS/Regional_Income_Inequality_in_the_United_States_1917_2011.sas7bdat')

