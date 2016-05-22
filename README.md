# week4




 title: "README"
 author: "Emi Harry"
 date: "May 21, 2016"

## SCRIPT DESCRIPTION
The steps used in reading and cleaning up the dataset are as follows:
Step 1:  Assign the link to a variable, create a tempoary download file and download the file. Unzip and list the files contained in order to identify the files you want to work on.
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp <- tempfile()
download.file(fileurl, temp) 
unzip(temp, list = T)
Step 2: load the data table package and extract all test and train datasets as data tables.
library(data.table)
activity_labels <- read.table(unzip(temp, "UCI HAR Dataset/activity_labels.txt"))
features <- read.table(unzip(temp, "UCI HAR Dataset/features.txt"))
x_test <- read.table(unzip(temp, "UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(unzip(temp, "UCI HAR Dataset/test/y_test.txt"))
subject_test <- read.table(unzip(temp, "UCI HAR Dataset/test/subject_test.txt"))
x_train <- read.table(unzip(temp, "UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(unzip(temp, "UCI HAR Dataset/train/y_train.txt"))
subject_train <- read.table(unzip(temp, "UCI HAR Dataset/train/subject_train.txt"))
Step 3: Revome tempoary file, rename the test and train column labels to create a common id
unlink(temp)
setnames(y_test, c("V1"), c("activity_id"))
setnames(subject_test, c("V1"), c("subject_id"))
setnames(y_train, c("V1"), c("activity_id"))
setnames(subject_train, c("V1"), c("subject_id"))
Step 4: create common id in order to merge Test  sets with labels and subjects. Add an experiment column that tells its test.
TestSet <- data.table(experiment_type = "test", x_test, sn = 1:2947)
TestLabel <- data.table(y_test, sn = 1:2947)
TestSubject <- data.table(subject_test, sn = 1:2947)
setkey(TestSet, sn); setkey(TestLabel, sn)
DT_test <- merge(TestLabel, TestSubject)
setkey(DT_test, sn); setkey(TestSubject, sn)
DT_test <- merge(DT_test, TestSet)
Step 5: create common id in order to merge Train sets with labels and subjects.  Add an experiment column that tells its train
TrainSet <- data.table(experiment_type = "train", x_train, sn = 1:7352)
TrainLabel <- data.table(y_train, sn = 1:7352)
TrainSubject <- data.table(subject_train, sn = 1:7352)
setkey(TrainSet, sn); setkey(TrainLabel, sn)
DT_train <- merge(TrainLabel, TrainSubject)
setkey(DT_train, sn); setkey(TrainSubject, sn)
DT_train <- merge(DT_train, TrainSet)
Step 6: remove the sn columns, then check the names of each datatable.
DT_train[, sn := NULL]
DT_test[, sn := NULL]
names(DT_train)
names(DT_test)
Step 7: merge the two data tables (set and train) by row and then convert the dataset to a dataframe
dataset <- rbind(DT_test, DT_train)
dataset <- as.data.frame(dataset)
class(dataset)
Step 8: delete column V1 from features
features[["V1"]] <- NULL
Step 9: assign descriptive column names from features to the dataset. First create 2 subsets of the dataset
part1 <- dataset[, 1:3]
part2 <- dataset[, 4:564]
colnames(part2) <- features[1:561,]
dataset2 <- cbind(part1, part2)
Step 10:  create an activity column by matching the corresponding activity id with the activity label
dataset2$ativity_label <- activity_labels[match(dataset2$activity_id, activity_labels$V1),2]
Step 11: move the activitly label to the first position in the dataset
part3 <- dataset2[, 1:564]
part4 <- dataset2[, 565]
dataset3 <- cbind(part4, part3)
Step 12: change the column name from part4 back to activity_label 
colnames(dataset3)[1] <- "activity_label"
Step 13: to reshape the dataset, create 3 new dataframes by subsetting dataset3. p1 is a subset that contains the labels. p2 is a subset of all mean colums by using grepl to search and subset. p3 is a subset of all standard deviation colums by using grepl to search and subset.
p1 <- dataset3[, c("activity_label", "subject_id", "experiment_type")]
p2 <- dataset3[, grepl("mean", names(dataset3), ignore.case = T)]
p3 <- dataset3[, grepl("std", names(dataset3), ignore.case = T)]
Step 14: combine all the dataframes into a the first tidy data table
tidy1 <- data.table(cbind(p1, p2, p3))
Step 15: load the reshape package. Use melt to shrink dataset and then dcast to get the mean for each activity and subject
library(reshape2)
tidy2 <- melt(tidy1, id.vars = c("activity_label", "subject_id", "experiment_type"))
tidy_mean <- dcast(tidy2, activity_label + subject_id + experiment_type ~ variable, mean)
Step 16: create a folder in your working directory where you want the file to be written to, set the folder as the working directory and write tidy data to text file
if (!file.exists("Week4")) {
  dir.create("Week4")
}
setwd("./Week4/")
write.table(tidy_mean, "mean_tidydata.txt", row.name = F)
