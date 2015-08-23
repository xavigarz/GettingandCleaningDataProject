# Loads the libraries needed
library(plyr)
library(dplyr)

#Reads the labels as vectos
label_columns<-read.table("features.txt")
label_columns<-as.vector(label_columns$V2)
label_activity<-read.table("activity_labels.txt")
label_activity<-as.vector(label_activity$V2)

#Reads all the data from test and train, for observables, activities and subjects
data_test<-read.table("test/X_test.txt")
activity_test<-read.table("test/y_test.txt")
data_train<-read.table("train/X_train.txt")
activity_train<-read.table("train/y_train.txt")
subject_test<-read.table("test/subject_test.txt")
subject_test<-as.vector(subject_test$V1)
subject_train<-read.table("train/subject_train.txt")
subject_train<-as.vector(subject_train$V1)

#Replaces the activity id for the tag_name
activity_train<-mapvalues(as.vector(activity_train$V1),from = c(1,2,3,4,5,6), to=label_activity)
activity_test<-mapvalues(as.vector(activity_test$V1),from = c(1,2,3,4,5,6), to=label_activity)

label_columns<-gsub("[[:punct:]]","",label_columns)

#Names the columns for both data sets
colnames(data_test)<-label_columns
colnames(data_train)<-label_columns

#Add the activities and subjects to the data set
data_test$activity<-activity_test
data_train$activity<-activity_train
data_test$subject<-subject_test
data_train$subject<-subject_train

#Create a combined data set
data<-rbind(data_test,data_train)
data<-tbl_df(data)

valid_column_names <- make.names(names=names(data), unique=TRUE, allow_ = TRUE)
names(data) <- valid_column_names

#Selects only the mean, std, activity and subject
data_mean<-select(data,contains("std"),contains("mean"),contains("activity"),contains("subject"))

#Creates a new table with the mean of each variable for subject and activity
result<-data_mean %>%
  group_by(subject,activity) %>%
  summarise_each(funs(mean(., na.rm=TRUE)))

#Write the result in a file.txt
write.table(result,"tidy_data.txt",row.name=FALSE)
