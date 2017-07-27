#Script to form a tidy dataset from UCI HAR Dataset
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# Load required library
library(dplyr)

# Load activity (Y), subject and features (X) from test and train data files
test_activity <- read.table("./test/y_test.txt", header = FALSE)
test_subject <- read.table("./test/subject_test.txt", header = FALSE)
test_features <- read.table("./test/X_test.txt", header = FALSE)

train_activity <- read.table("./train/y_train.txt", header = FALSE)
train_subject <- read.table("./train/subject_train.txt", header = FALSE)
train_features <- read.table("./train/X_train.txt", header = FALSE)

#Combine and merge test and train tables into one of each type
activity <- rbind(test_activity, train_activity)
subject <- rbind(test_subject, train_subject)
features <- rbind(test_features, train_features)

#Get label names for columns from respective description files
activity_labels <- read.table("./activity_labels.txt", header = FALSE)
feature_labels <- read.table("./features.txt", header = FALSE)

#Assign proper column names
names(activity) <- "activity_id"
names(subject) <- "subject_id"
names(activity_labels) <- c("activity_id", "activity")
names(feature_labels) <- c("col_num", "feature")
names(features) <- feature_labels$feature

#Merge activity data with activity labels
activity <- merge(activity, activity_labels)

#Filter mean an std features (causes duplicated column name: fBodyAcc-bandsEnergy() )
#First eliminate duplicated columns
features <- features[ !duplicated(names(features)) ]
filtered_features <- select(features, contains("mean"), contains("std"))

#Merge all data
merged_data <- cbind(subject, activity$activity, filtered_features)

#Rename columns begining with t to time and begining with f to frequency
names(merged_data) <- gsub("^t", "time", names(merged_data))
names(merged_data) <- gsub("^f", "frequency", names(merged_data))
names(merged_data)[1:2] <- c("subject", "activity")

#Create tidy data apliying mean on grouped data
tidy_data <- merged_data %>% group_by(subject, activity) %>% summarise_all(funs(mean))

#Write in a file
write.table(tidy_data, file = "./tidydata.txt", row.name=FALSE)

#Remove created objects
rm(list = ls(all = TRUE))





