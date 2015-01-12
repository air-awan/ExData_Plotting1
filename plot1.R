# Check dependency
if (!is.element("RCurl", installed.packages()[,1])) {
    stop("RCurl package not installed")
}
if (!is.element("dplyr", installed.packages()[,1])) {
    stop("dplyr package not installed")
}
if (!is.element("sqldf", installed.packages()[,1])) {
    stop("sqldf package not installed")
}

# Set dataset and working directory
folder.name <- "./ExData_Plotting1"
file.name <- "exdata-data-household_power_consumption.zip"
library(RCurl)
if (!grepl("ExData_Plotting1",getwd(),)){
    if (!file.exists(folder.name)) {
        dir.create(folder.name)
        if(!file.exists(paste(file.name))) {
            get.url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
            if(url.exists(url = get.url, ssl.verifypeer = F)) {
                file.data = CFILE(file.name, "wb")
                curlPerform(url = get.url, writedata=file.data@ref, ssl.verifypeer = F)
                close(file.data)
            } 
            else {
                stop("Source dataset cannot be downloaded.")
            }
        }
        if(!file.exists(paste(folder.name,"/household_power_consumption.txt"))) {
            unzip(file.name,exdir = folder.name)
        }
    }
    setwd(folder.name)
}

subset.datafile <- "subset_data.txt"
if(!file.exists(subset.datafile)) {
    #Load and filter data file using sqldf package
    #http://www.cerebralmastication.com/2009/11/loading-big-data-into-r/
    library(sqldf)
    datafile <- file("household_power_consumption.txt")
    target.data <- sqldf("select * from datafile where Date = '1/2/2007' or Date ='2/2/2007'", 
                         dbname = tempfile(), file.format = list(header = T, sep=";", row.names = F))
    close(datafile)
    #Create Datetime column for plotting
    library(dplyr)
    target.data<-mutate(target.data,Datetime=paste(target.data$Date,target.data$Time))
    target.data$Datetime<-strptime(target.data$Datetime, "%d/%m/%Y %H:%M:%S")
    #Save subset data for future use
    write.table(target.data, file = subset.datafile, row.names = FALSE)
} else {
    target.data <- read.table(subset.datafile, header = T)
}
    
#http://www.ats.ucla.edu/stat/r/faq/saving.htm
png("./plot1.png")
hist(target.data$Global_active_power, col = "Red", main = "Global Active Power", 
     xlab = "Global Active Power (kilowatts)")
dev.off()
setwd("..")