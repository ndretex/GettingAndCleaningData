## set directory to your working directory where the raw data folder "UCI HAR Dataset" is located
setwd("C:/Users/Joel/Desktop/DataScience/3-getting data/course project")

workingdir <- getwd()

## checking if the raw data is in the working directory, 
## if not, i download the zip file and extract it 
## (it will create the data directory)

## I suppose that if the "UCI HAR Dataset" folder is present
## the raw data is present as extracted from the zip file
datadir <-file.path(workingdir,"UCI HAR Dataset")
if(!file.exists(datadir)) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","project_dataset.zip")
  unzip("project_dataset.zip")
}

# 1 loading and merging train and tests sets for subject, activity and dataset
library(data.table)
## loading subject sets
subjecttrain <- fread(file.path(datadir, "train", "subject_train.txt"))
subjecttest <- fread(file.path(datadir, "test", "subject_test.txt"))
subject <- rbind(subjecttrain,subjecttest)
setnames(subject,"V1","subject")

## loading activity sets
activitytrain <- fread(file.path(datadir, "train", "y_train.txt"))
activitytest <- fread(file.path(datadir, "test", "y_test.txt"))
activity <- rbind(activitytrain,activitytest)
setnames(activity,"V1","numactivity")

## 3. loading descriptive activity names
activitynames <- fread(file.path(datadir, "activity_labels.txt"))
setnames(activitynames,c("V1","V2"),c("numactivity","activity"))

activity <- merge(activity, activitynames, by="numactivity", all.x=TRUE)
dataset <- cbind(subject,activity)

# loading data sets
datatrain <- fread(file.path(datadir, "train", "x_train.txt"))
datatest <- fread(file.path(datadir, "test", "x_test.txt"))
data <- rbind(datatrain,datatest)

# 4 loading descriptive data variables names
features <- fread(file.path(datadir, "features.txt"))
featuresnames <- features$V2
setnames(data,names(data),featuresnames)

dataset <- cbind(dataset,data)
setkey(dataset,subject,activity)

# 2 Extracting only the measurements on the mean and standard deviation

### meanstdvars<-featuresnames[grepl("mean|std",namesdata)] 
### This will keep the variables that contains "meanFreq()" which shouldn't be taking in consideration
### i must then select the variables that contains "mean()" and "std()":
meanstdvars<-featuresnames[grepl("mean\\(\\)|std\\(\\)",featuresnames)] 
dataset<-dataset[,c("subject","activity",meanstdvars),with=FALSE]

## Reshaping the data to a narrow and tall format (must redefine key for dataset)
dataset <- data.table(melt(dataset, key(dataset), variable.name="feature"))
setkey(dataset,"subject","activity","feature")

# 5 independent tidy data set with the average of each variable for each activity and each subject.
tidydataset <- dataset[, list(average = mean(value)), by=key(dataset)]

## output:
write.table(tidydataset, file="tidydataset.txt", row.names = FALSE)
