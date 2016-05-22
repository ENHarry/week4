# week4




 title: "README"
 author: "Emi Harry"
 date: "May 21, 2016"

## SCRIPT DESCRIPTION
The steps used in reading and cleaning up the dataset are as follows:

Step 1:  Assign the link to a variable, create a tempoary download file and download the file. Unzip and list the files contained in order to identify the files you want to work on.


Step 2: load the data table package and extract all test and train datasets as data tables.

Step 3: Revome tempoary file, rename the test and train column labels to create a common id

Step 4: create common id in order to merge Test  sets with labels and subjects. Add an experiment column that tells its test.

Step 5: create common id in order to merge Train sets with labels and subjects.  Add an experiment column that tells its train

Step 6: remove the sn columns, then check the names of each datatable.

Step 7: merge the two data tables (set and train) by row and then convert the dataset to a dataframe

Step 8: delete column V1 from features

Step 9: assign descriptive column names from features to the dataset. First create 2 subsets of the dataset

Step 10:  create an activity column by matching the corresponding activity id with the activity label

Step 12: change the column name from part4 back to activity_label 

Step 13: to reshape the dataset, create 3 new dataframes by subsetting dataset3. p1 is a subset that contains the labels. p2 is a subset of all mean colums by using grepl to search and subset. p3 is a subset of all standard deviation colums by using grepl to search and subset.

Step 14: combine all the dataframes into a the first tidy data table

Step 15: load the reshape package. Use melt to shrink dataset and then dcast to get the mean for each activity and subject

Step 16: create a folder in your working directory where you want the file to be written to, set the folder as the working directory and write tidy data to text file
