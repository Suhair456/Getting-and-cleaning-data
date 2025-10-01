# run_analysis.R
# Getting and Cleaning Data - Course Project
# Author: Suhair Mohammed
# Date: 2025-09-30

# -------------------------------------------------------------
# 1. تحميل المكتبات
library(dplyr)

# -------------------------------------------------------------
# 2. قراءة البيانات
# اضبطي الـ working directory بحيث يحتوي مجلد "UCI HAR Dataset"
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("index", "feature"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$feature)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$feature)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")

# -------------------------------------------------------------
# 3. دمج بيانات التدريب والاختبار
subject <- rbind(subject_train, subject_test)
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)

merged_data <- cbind(subject, y_data, x_data)

# -------------------------------------------------------------
# 4. استخراج المتغيرات الخاصة بالـ mean و std فقط
tidy_data <- merged_data %>%
  select(subject, code, contains("mean"), contains("std"))

# -------------------------------------------------------------
# 5. استبدال رموز النشاط بأسماء وصفية
tidy_data$code <- activities[tidy_data$code, 2]
names(tidy_data)[2] <- "activity"

# -------------------------------------------------------------
# 6. إعادة تسمية الأعمدة بأسماء واضحة
names(tidy_data) <- gsub("Acc", "Accelerometer", names(tidy_data))
names(tidy_data) <- gsub("Gyro", "Gyroscope", names(tidy_data))
names(tidy_data) <- gsub("BodyBody", "Body", names(tidy_data))
names(tidy_data) <- gsub("Mag", "Magnitude", names(tidy_data))
names(tidy_data) <- gsub("^t", "Time", names(tidy_data))
names(tidy_data) <- gsub("^f", "Frequency", names(tidy_data))
names(tidy_data) <- gsub("tBody", "TimeBody", names(tidy_data))
names(tidy_data) <- gsub("-mean\\(\\)", "Mean", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("-std\\(\\)", "STD", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("-freq\\(\\)", "Frequency", names(tidy_data), ignore.case = TRUE)
names(tidy_data) <- gsub("angle", "Angle", names(tidy_data))
names(tidy_data) <- gsub("gravity", "Gravity", names(tidy_data))

# -------------------------------------------------------------
# 7. إنشاء مجموعة بيانات جديدة مع المتوسط لكل subject ولكل activity
final_data <- tidy_data %>%
  group_by(subject, activity) %>%
  summarise(across(everything(), mean))

# -------------------------------------------------------------
# 8. حفظ البيانات في ملف نصي
write.table(final_data, "tidy_dataset.txt", row.name = FALSE)
