fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp <- tempfile()
download.file(fileurl, temp) 
unzip(temp, list = T)
library(data.table)

activity_labels <- read.table(unzip(temp, "UCI HAR Dataset/activity_labels.txt"))
features <- read.table(unzip(temp, "UCI HAR Dataset/features.txt"))

# Extract all test data tables

x_test <- read.table(unzip(temp, "UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(unzip(temp, "UCI HAR Dataset/test/y_test.txt"))
subject_test <- read.table(unzip(temp, "UCI HAR Dataset/test/subject_test.txt"))

# Extract all train data tables

x_train <- read.table(unzip(temp, "UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(unzip(temp, "UCI HAR Dataset/train/y_train.txt"))
subject_train <- read.table(unzip(temp, "UCI HAR Dataset/train/subject_train.txt"))

# Revome tempoary file

unlink(temp)

# rename the test and train column labels to create a common id

setnames(y_test, c("V1"), c("activity_id"))
setnames(subject_test, c("V1"), c("subject_id"))
setnames(y_train, c("V1"), c("activity_id"))
setnames(subject_train, c("V1"), c("subject_id"))

# create common id in order to merge Test sets with labels and subjects
# add an experiment column that tells its test

TestSet <- data.table(experiment_type = "test", x_test, sn = 1:2947)
TestLabel <- data.table(y_test, sn = 1:2947)
TestSubject <- data.table(subject_test, sn = 1:2947)
setkey(TestSet, sn); setkey(TestLabel, sn)
DT_test <- merge(TestLabel, TestSubject)
setkey(DT_test, sn); setkey(TestSubject, sn)
DT_test <- merge(DT_test, TestSet)

# create common id in order to merge Train sets with labels and subjects
# add an experiment column that tells its train

TrainSet <- data.table(experiment_type = "train", x_train, sn = 1:7352)
TrainLabel <- data.table(y_train, sn = 1:7352)
TrainSubject <- data.table(subject_train, sn = 1:7352)
setkey(TrainSet, sn); setkey(TrainLabel, sn)
DT_train <- merge(TrainLabel, TrainSubject)
setkey(DT_train, sn); setkey(TrainSubject, sn)
DT_train <- merge(DT_train, TrainSet)

# remove the sn column

DT_train[, sn := NULL]
DT_test[, sn := NULL]
names(DT_train)
names(DT_test)

# merge the two data tables (set and train) by row

dataset <- rbind(DT_test, DT_train)
dataset <- as.data.frame(dataset)
class(dataset)

# delete column V1 from features

features[["V1"]] <- NULL

# assign descriptive column names from features to the dataset
# first create 2 subsets of the dataset

part1 <- dataset[, 1:3]
part2 <- dataset[, 4:564]
colnames(part2) <- features[1:561,]
dataset2 <- cbind(part1, part2)
names(dataset2)

# create an activity column by matching the corresponding
## activity id with the activity label

dataset2$ativity_label <- activity_labels[match(dataset2$activity_id, activity_labels$V1),2]

# move the activitly label to the first position in the dataset

part3 <- dataset2[, 1:564]
part4 <- dataset2[, 565]
dataset3 <- cbind(part4, part3)

# change the column name from part4 back to activity_label
# remove the activity_id column

colnames(dataset3)[1] <- "activity_label"

# reshape the dataset
# create a tidy dataset of all the mean and std columns
## include a dataset of the activity, subject and experiment

p1 <- dataset3[, c("activity_label", "subject_id", "experiment_type")]
p2 <- dataset3[, grepl("mean", names(dataset3), ignore.case = T)]
p3 <- dataset3[, grepl("std", names(dataset3), ignore.case = T)]
tidy1 <- data.table(cbind(p1, p2, p3))

library(reshape2)
# use melt to shrink dataset and then dcast to get the mean for each activity and subject
tidy2 <- melt(tidy1, id.vars = c("activity_label", "subject_id", "experiment_type"))
tidy_mean <- dcast(tidy2, activity_label + subject_id + experiment_type ~ variable, mean)

# write tidy data to text file
if (!file.exists("Week4")) {
  dir.create("Week4")
}
setwd("./Week4/")
write.table(tidy_mean, "mean_tidydata.txt", row.name = F)
