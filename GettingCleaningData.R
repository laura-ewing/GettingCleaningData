#Week 1 Materials
#Tiday data - each variable should be in one column, each different observation
#of that variable should be in a different row, should be one table for each
#kind of variable, and if multiple tables they should include a column in the 
#table that allows them to be linked

#Code book - information about the variables in data set not contained in the
#tidy data, information about the summary choices you have made, and information
#about the experimental study design you used; contain section called study
#design and section called code book (variables, units, etc)

#instruction list - computer script, input for script is the raw data, output
#is the processed tidy data, no parameters in script

#downloading files
#downloading process can be included in the script
#getwd() and setwd()
getwd()
#setwd("../") moves up one level in the directory
#in Windows, use \\ instead of /
#file.exists("directoryName") sees if directory exists; returns T, F
#dir.create() creates directory
#sample code to create directory if it doesn't already exist
if (!file.exists("data")) {
    dir.create("data")
}

#download.file() to download from internet; parameters: url, destfile, method
#example: Baltimore speed camera data
fileUrl <- "https://data.baltimorecity.gov/api/views/dz54-2aru/rows.csv?accessType=DOWNLOAD"
download.file(fileUrl, destfile = "C:/Users/ewinglaurae/Documents/gitrcodes/GettingCleaningData/data/cameras.csv", method = "curl")
dateDownloaded <- date() #keep track of date data downloaded
dateDownloaded
list.files("./data") #list files in directory

#if url starts with http, use download.file(); if starts with https, may need
#to use method = "curl" to download


#Reading local files
#read.table(); flexible, robust, but needs more parameters (file, header, sep,
#row.names, nrows); reads into RAM; not best for large data sets
cameraData <- read.table("./data/cameras.csv", sep = ",", header = T)
head(cameraData) #probably older website info, so not much in the file now
#quote = "" means no quotes; use if random quotes or ' in data
#na.strings set the character that represents a missing value
#nrows tells how many rows of the file to read
#skip tells number of rows to skip before reading


#Reading Excel files
fileUrl <- "https://data.baltimorecity.gov/api/views/dz54-2aru/rows.xlsx?accessType=DOWNLOAD" #website no longer exists
download.file(fileUrl, destfile = "./data/cameras.xlsx", method = "curl")
#since website doesn't exist, just use code as example and don't run
dateDownloaded <- date()
library(xlsx)
cameraData <- read.xlsx("./data/cameras.xlsx", sheetIndex = 1, header = T)
#read specific rows/col using colIndex and rowIndex parameters in read function
#use write.xlsx function to create Excel files
#better to store data in csv, tab, or txt files as these are easier to distribute


#Reading XML files
#used to store structured data; internet applications; components: markup, content
#tags: general labels; start <section>, end </section>, empty <line-break />
#attributes are components of the label
library(XML)
fileUrl <- "https://www.w3schools.com/xml/simple.xml" #again, does not load
doc <- xmlTreeParse(fileUrl, useInternalNodes = T, isURL = T)
rootNode <- xmlRoot(doc)
xmlName(rootNode)
names(rootNode)
#directly access parts of XML
rootNode[[1]] #access first element
rootNode[[1]][[1]] #first part of first element
xmlSApply(rootNode, xmlValue) #get value of every tagged element
#get items on menu and their prices
xpathSApply(rootNode, "//name", xmlValue)
xpathSApply(rootNode, "//price", xmlValue)
#more complicated example; let's see if this page works :)
fileUrl <- "http://espn.go.com/nfl/team/_/name/bal/baltimore-ravens" #webpage blocked at UAMS
#try different file
fileUrl <- "https://www.arkansasrocks.com"
doc <- htmlParse(fileUrl) #nothing seems to XML???

#try downloading different way
fileUrl <- "https://www.w3schools.com/xml/simple.xml"
doc <- download.file(fileUrl, destfile = "./data/schools.xml") #still doesn't work
#gives a 0 byte file
head(doc)

#none of this XML crap is working; network errors?


#Reading JSON data: javascript object notation, lightweight data storage
#data stored as numbers, strings, boolean, array, objects
library(jsonlite)
jsonData <- fromJSON("https://api.github.com/users/jtleek/repos")
names(jsonData)
names(jsonData$owner)
names(jsonData$owner$login)
#writing dataframes to JSON
myjson <- toJSON(iris, pretty = T)
cat(myjson)
#convert back to dataframe
iris2 <- fromJSON(myjson)
head(iris2)


#the data.table package
library(data.table)
#all functions that accept data.frame work on data.table; faster processes
DF = data.frame(x = rnorm(9), y = rep(c("a", "b", "c"), each = 3), z = rnorm(9))
head(DF, 3)
DT = data.table(x = rnorm(9), y = rep(c("a", "b", "c"), each = 3), z = rnorm(9))
head(DT, 3)
tables()
#subset rows
DT[2, ]
DT[DT$y == "a"]
DT[c(2, 3)] #if subset with only one element, defaults to rows
#subset columns requires different syntax
DT[ , 2]
#argument you pass after comma is expression
{
    x = 1
    y = 2
}
k = {print(10); 5}
print(k)
DT[ , list(mean(x), sum(z))]
DT[ , table(y)]
#add new columns
DT[ , w:=z^2] #need := for new column
DT
DT2 <- DT
DT[ , y:=2]
DT
DT2
#updates DT2 at the same time; need to use copy function to make new, unlinked copy
DT[ , m := {tmp <- (x+z); log2(tmp+5)}] #only adds the results of the last expression
DT
#plyr-like operations
DT[ , a := x > 0]
DT
DT[ , b := mean(x+w), by = a]
DT
set.seed(123)
DT <- data.table(x = sample(letters[1:3], 1E5, T))
DT[ , .N, by = x] #to count numbers use .N
#keys for subsetting tables
DT <- data.table(x = rep(c("a", "b", "c"), each = 100), y = rnorm(100))
setkey(DT, x)
DT['a'] #subset values for x = a
#joins
DT1 <- data.table(x = c('a', 'a', 'b', 'dt1'), y = 1:4)
DT2 <- data.table(x = c('a', 'b', 'dt2'), z = 5:7)
setkey(DT1, x); setkey(DT2, x)
merge(DT1, DT2) #need same key in both data tables
#fast reading
big_df <- data.frame(x = rnorm(1E6), y = rnorm(1E6))
file <- tempfile()
write.table(big_df, file = file, row.names = F, col.names = T, sep = "\t",
            quote = F)
system.time(fread(file)) #much faster
system.time(read.table(file, header = T, sep = "\t")) #much slower



#week 1 quiz
#1. download file and load into R. how many properties are worth $1000000 or more?
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv",
              destfile = "C:/Users/ewinglaurae/Documents/gitrcodes/GettingCleaningData/data/hid.csv",
              method = "curl")
hid <- read.table("./data/hid.csv", sep = ",", header = T)
head(hid)
sum(hid$VAL == 24, na.rm = T) #53

#2. consider variable FES in code book. what 'tidy data' principle does this
#variable violate?
#column contains household and employment info: more than one variable

#3. download Excel sheet on natural gas aquisition program
#read rows 18-23 and columns 7-15 into R assigned to dat
#what is the value of sum(dat$Zip * dat$Ext, na.rm = T)
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx",
              destfile = "C:/Users/ewinglaurae/Documents/gitrcodes/GettingCleaningData/data/gas.xslx") #not working??
dat <- read.xlsx("./data/NGAP.xlsx", sheetIndex = 1, rowIndex = c(18:23), colIndex = c(7:15))
head(dat)
sum(dat$Zip * dat$Ext, na.rm = T) #36534720

#4. read xml file. how many restaurants in zip 21231?
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
restaurants <- xmlTreeParse("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml",
                            useInternalNodes = T, isURL = T)
#not working; just used find in XML for 127

#5. download csv file, use fread() command to load into R object DT, and which 
#of these deliver faster user time?
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv",
              destfile = "C:/Users/ewinglaurae/Documents/gitrcodes/GettingCleaningData/data/ACS.csv")
DT <- fread(file = "./data/ACS.csv")
head(DT)
DT[ , mean(pwgtp15), by = SEX]
system.time(DT[ , mean(pwgtp15), by = SEX]) #user 0.01, system 0.00, elapsed 0.01; fastest
mean(DT[DT$SEX==1,]$pwgtp15); mean(DT[DT$SEX==2,]$pwgtp15)
system.time(mean(DT[DT$SEX==1,]$pwgtp15), mean(DT[DT$SEX==2,]$pwgtp15))
#user 0.01, system 0.00, elapsed 0.02
sapply(split(DT$pwgtp15,DT$SEX),mean)
system.time(sapply(split(DT$pwgtp15,DT$SEX),mean)) #all 0s
rowMeans(DT)[DT$SEX==1]; rowMeans(DT)[DT$SEX==2] #error
tapply(DT$pwgtp15,DT$SEX,mean)
system.time(tapply(DT$pwgtp15,DT$SEX,mean)) #all 0s
mean(DT$pwgtp15,by=DT$SEX)
system.time(mean(DT$pwgtp15,by=DT$SEX)) #all 0s



#Week 2 Reading from MySQL
#mySQL - open source database software
#data in databases, tables within databases, fields within tables; each row
#is called a record
library(RMySQL)
ucscDb <- dbConnect(MySQL(), user = "genome", host = "genome-mysql.cse.ucsc.edu")
result <- dbGetQuery(ucscDb, "show databases;"); dbDisconnect(ucscDb)
head(result) #all databases in server
hg19 <- dbConnect(MySQL(), user = "genome", db = "hg19", host = "genome-mysql.cse.ucsc.edu") #hg19 - human genome database
allTables <- dbListTables(hg19)
allTables[1:5]
length(allTables)
#get dimensions of specific table
dbListFields(hg19, "affyU133Plus2") #lists fields in table within hg19 dataframe
dbGetQuery(hg19, "select count(*) from affyU133Plus2") #number of records
affyData <- dbReadTable(hg19, "affyU133Plus2") #gets dataframe
head(affyData)
#select specific subset
query <- dbSendQuery(hg19, "select * from affyU133Plus2 where misMatches between 1 and 3") #select columns
affyMis <- fetch(query); quantile(affyMis$misMatch)
affyMisSmall <- fetch(query, n = 10); dbClearResult(query) #little part of data; top 10 records; clear query from remote server
dim(affyMisSmall)
#don't forget to close the connection
dbDisconnect(hg19)


#Reading from HDF5
#for storing large datasets, heirarchial data format; groups containing >=0
#datasets and metadata; group header with group name and list of attributes,
#group cymbol table with list of objects in group
#must install through bioconductor
library(rhdf5)
created = h5createFile("example.h5")
created
created = h5createGroup("example.h5", "foo") #create groups within file
created = h5createGroup("example.h5", "baa")
created = h5createGroup("example.h5", "foo/foobaa")
h5ls("example.h5") #list what is in the file
#write to groups
A = matrix(1:10, nr = 5, nc = 2)
h5write(A, "example.h5", "foo/A")
B = array(seq(0.1, 2.0, by = 0.1), dim = c(5, 2, 2))
attr(B, "scale") <- "liter"
h5write(B, "example.h5", "foo/foobaa/B")
h5ls("example.h5")
#write a dataset
df = data.frame(1L:5L, seq(0, 1, length.out = 5), c("ab", "cde", "fghi", "a", "s"),
                stringsAsFactors = F)
h5write(df, "example.h5", "df")
h5ls("example.h5")
#reading data
readA = h5read("example.h5", "foo/A") #which file and which dataset
readB = h5read("example.h5", "foo/foobaa/B")
readdf = h5read("example.h5", "df")
readA
readdf
#writing and reading chunks
h5write(c(12, 13, 14), "example.h5", "foo/A", index = list(1:3, 1)) 
#write to specific part of dataset, first three rows of first column
h5read("example.h5", "foo/A")


#Reading from the web
#webscraping: programatically extracting data from HTML code of websites
#trying to read too many pages too quickly can get IP addressed blocked
#can be against terms and services
#example of instructor's google scholar page
con = url("http://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
htmlCode = readLines(con)
#get error from this webpage, try different page
con = url("https://www.accuweather.com/en/us/little-rock/72201/weather-forecast/326862")
htmlCode = readLines(con)
#this site was forbidden
con = url("http://www.google.com")
htmlCode = readLines(con)
#doesn't work either

#can also use XML package
library(XML)
url <- "http://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en"
html <- htmlTreeParse(url, useInternalNodes = T)
#fail to load; here's the rest of the commands anyway
xpathSApply(html, "//title", xmlValue)
xpathSApply(html, "//td[@id='col-citedby']", xmlValue)

#use GET from the httr package
library(httr)
html2 = GET(url) #after getting, extract content with content()
content2 = content(html2, as = "text") #after this, then use Parse command
parsedHtml = htmlParse(content2, asText = T) #then can use XML commands to extract info
xpathSApply(parsedHtml, "//title", xmlValue)
#this one works, yay!

#accessing webistes with passwords
pg1 = GET("http://httpbin.org/basic-auth/user/passwd")
pg1
#give 401 error because need to supply a password
#add authenticate
pg2 = GET("http://httpbin.org/basic-auth/user/passwd",
          authenticate("user", "passwd"))
pg2
#status 200: can access file
names(pg2)
#can then use content() function

#using handles; can save authentication across websites and paths
google = handle("http://google.com")
pg1 = GET(handle = google, path = "/")
pg2 = GET(handle = google, path = "search")


#Reading from APIs
#application programming interfaces
#use httr package
#need dev account (not user account)
#accessing twitter from R
myapp = oauth_app("twitter", key = "yourConsumerKeyHere", 
                  secret = "yourConsumerSecretHere")
sig = sign_oauth1.0(myapp, token = "yourTokenHere",
                    token_secret = "yourTokenSecretHere")
homeTL = GET("http://api.twitter/com/1.1/statuses/home_timeline.json", sig)
#sig is the authentication, instead of a log-in info
#error because don't have the actual key, secret, token, and token_secret
#need dev account for website to have these items
#converting the json object
#needs a working login and authorization data
json1 = content(homeTL)
json2 = jsonlite::fromJSON(toJSON(json1))
json2[1, 1:4] #rows in twitter correspond to individual tweets
#pick url from documentation for api: resource url
#page also gives parameters
#look at httr page on GitHub for examples of other websites to get info from


#reading from other sources
#almost all data types have R package
?connections
#different read.... functions for different stats files
#database packages: RPostresSQL, RODBC, RMongo, rmongodb
#most need to use syntax from database
#reading images: jpeg, readbitmap, png, EBImage (Bioconductor)
#GIS data: rdgal, rgeos, raster
#music: tuneR, seewave; read mp3



#quiz
#1. register an application with the Gihub API. access the API to get information
#on your instructors' repositories (https://api.github.com/users/jtleek/repos")
#use this data to find the time that thte datasharing repo was created
#accessed site directly and searched for different date options
#picked 2013-08-28T18:18:50z - incorrect
#searched datasharing
#dates: created: 2013-11-07T13:25:07Z, updated_at: 2021-12-06T13:40:00Z,
#pushed_at: 2021-12-05T17:16:12Z

#2. the sqldf package allows for execution of SQL commands on R dataframes. 
#download the American community survey data and load it into an R object called
#acs. which of the following commands will select only the data for the probability
#weight pwgtp1 with ages less than 50?
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
download.file(fileUrl, destfile = "C:/Users/ewinglaurae/Documents/gitrcodes/GettingCleaningData/data/acs.csv", method = "curl")
acs <- read.csv("./data/acs.csv")
head(acs)
library(sqldf)
library(RMySQL)
sqldf("select pwgtp1 from acs") #error
sqldf("select * from acs") #error
sqldf("select * from acs where AGEP < 50 and pwgtp1") #error; try this one, has *; incorrect
sqldf("select pwgtp1 from acs where AGEP < 50") #error; 2nd try - correct
#all these give connection errors

#3. using dataframe from 2, which is equivalent to unique(acs$AGEP)?
unique(acs$AGEP)
sqldf("select unique * from acs") #does not mention AGEP, so probably not it
sqldf("select distinct pwgtp1 from acs") #does not include AGEP, probably not it
sqldf("select distinct AGEP from acs") #could be - correct
sqldf("select AGEP where unique from acs") #possibly
#all give connection errors; try could be

#4. how many characters are in the 10th, 20th, 30th, and 100th lines from the
#html from this page: http://biostat.jhsph.edu/~jleek/contact.html
library(httr)
url <- "http://biostat.jhsph.edu/~jleek/contact.html"
html2 = GET(url) #after getting, extract content with content()
content2 = content(html2, as = "text") #after this, then use Parse command
parsedHtml = htmlParse(content2, asText = T) #then can use XML commands to extract info
content2
xpathSApply(parsedHtml, "//title", xmlValue)
parsedHtml
nchar(parsedHtml[10, ])
#different method
html <- readLines(url)
nchar(html[10]) #45
nchar(html[20]) #31
nchar(html[30]) #7
nchar(html[100]) #25
#correct

#5. read this data into R and report the sum of the numbers in the fourth of the
#nine columns
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for"
q5 <- read.fwf(url, widths = c(-1, 9, -5, 4, 4, -5, 4, 4, -5, 4, 4))
head(q5)
q5[-4, 4]
sum(as.numeric(q5[-(1:4), 4])) #32426.7; correct



#week 3

#subsetting and sorting
set.seed(13435)
X <- data.frame("var1" = sample(1:5), "var2" = sample(6:10),
                "var3" = sample(11:15))
X <- X[sample(1:5), ] #scramble order
X$var2[c(1,3)] = NA #make some NA
X
#subsetting
X[, 1] #subset column
X[ , "var1"] #subset column by name
X[1:2, "var2"] #subset by row and column
#logicals ands and ors
X[(X$var1 <= 3 & X$var3 > 11), ]
X[(X$var1 <= 3 | X$var3 > 15), ]
#dealing with missing values; subset by NA will not bring rows
X[which(X$var2 > 8), ]
#sorting
sort(X$var1)
sort(X$var1, decreasing = T)
sort(X$var2, na.last = T)
#ordering
X[order(X$var1), ]
X[order(X$var1, X$var3), ]
#ordering with plyr
library(plyr)
arrange(X, var1)
arrange(X, desc(var1))
#adding rows and oclumns
X$var4 <- rnorm(5) #make sure to have same number of rows
X
Y <- cbind(X, rnorm(5)) #binds in order
Y
#use rbind to bind rows


#summarizing data
#example data from https://data.baltimorecity.gov/Community/Restaurants/k5ry-ef3g
#except webpage doesn't exist
#get data from web
fileUrl <- "https://data.baltimorecity.gov/api/views/k5ry-ef3g/rows.csv?accessType=DOWNLOAD"
download.file(fileUrl, destfile = "./data/restaurants.csv", method = "curl")
restData <- read.csv("./data/restaurants.csv")
head(restData)
#bad webpage so functions, etc are just for example
summary(restData) #give min, max, mean, median, quantiles for each variable
str(restData) #gives info about dataframe: dimensions, classes, levels, etc.
quantile(restData$councilDistrict, na.rm = T)
quantile(restData$councilDistrict, probs = c(0.5, 0.75, 0.9)) #gives percentiles
#make a table
table(restData$zipCode, useNA = "ifany") #counts for each zipcode; useNA adds 
#column to end and how many NAs in dataset
#2-dimensional table
table(restData$councilDistrict, restData$zipCode)
#check for missing values
sum(is.na(restData$councilDistrict))
any(is.na(restData$councilDistrict))
all(restData$zipCode > 0) #check if all values are > 0
#sums
colSums(is.na(restData))
all(colSums(is.na(restData)) == 0)
#values for specific characteristics
table(restData$zipCode %in% c("21212"))
table(restData$zipCode %in% c("21212", "21213"))
restData[restData$zipCode %in% c("21212", "21213"), ] #rows with zipcodes specified
#cross tabs
data("UCBAdmissions")
DF = as.data.frame(UCBAdmissions)
summary(DF)
xt <- xtabs(Freq ~ Gender + Admit, data = DF) #variable displayed in table, broken down by other variables
xt
#flat tables
warpbreaks$replicate <- rep(1:9, len = 54)
xt = xtabs(breaks ~ ., data = warpbreaks)
xt
ftable(xt) #summarizes large table
#size of data set
fakedata <- rnorm(1e5)
object.size(fakedata)
print(object.size(fakedata), units = "Mb")


#creating new variables
#transform existing variables and add to existing dataframe
#again using Baltimore dataset, so website isn't likely working
fileUrl <- "https://data.baltimorecity.gov/api/views/k5ry-ef3g/rows.csv?accessType=DOWNLOAD"
download.file(fileUrl, destfile = "./data/restaurants.csv", method = "curl")
restData <- read.csv("./data/restaurants.csv")
head(restData)
#yep, website doesn't direct to an actual data file; code below just for reference
#creating sequences
s1 <- seq(1, 10, by = 2); s1
s2 <- seq(1, 10, length = 3); s2
x <- c(1, 3, 8, 25, 100); seq(along = x)
#subsetting variables
restData$nearMe <- restData$neighborhood %in% c("Roland Park", "Homeland")
table(restData$nearMe)
#creating binary variables
restData$zipWrong <- ifelse(restData$zipCode < 0, TRUE, FALSE)
table(restData$zipWrong, restData$zipCode < 0)
#creating categorical variables
restData$zipGroups <- cut(restData$zipCode, breaks = quantile(restData$zipCode))
#returns factor variable, break at 0, 25, 75, 100th percentiles
#easier cutting
library(Hmisc)
restData$zipGroups <- cut2(restData$zipCode, g = 4) #specify number of groups
#creating factor variables
restData$zcf <- factor(restData$zipCode) #esp if you have numeric variable but want it to be a category
#levels of factor variables
yesno <- sample(c("yes", "no"), size = 10, replace = TRUE)
yesnofac <- factor(yesno, levels = c("yes", "no"))
relevel(yesnofac, ref = "yes") #changes reference level from alphabetic to user defined
as.numeric(yesnofac)
#cutting produces factor variables
#use mutate function
library(plyr)
restData2 <- mutate(restData, zipGroups = cut2(zipCode, g = 4))
#common transforms: abs(x) for absolute value, sqrt(x), ceiling(x) to round up,
#floor(x) to round down, round(x, digits = n), signif(x, digits = n), cos(x), sin(x),
#log(x) for natural log, log2(x) for log base 2, log10(x) for log base 10, exp(x)



#Reshaping data
#making tidy data
#each variable forms a column, every observation has own row; each file has only one type of data
library(reshape2)
head(mtcars)
#melting data frames
mtcars$carname <- rownames(mtcars)
carMelt <- melt(mtcars, id = c("carname", "gear", "cyl"), measure.vars = c("mpg", "hp"))
#id tells descriptive terms for each observation, measure.vars tells which variables are measured
head(carMelt)
tail(carMelt, n =3)
#have one row for each mpg observation and one row for each hp observation
#casting data frames
cylData <- dcast(carMelt, cyl ~ variable) #summarizes by length (no. measures)
cylData
cylData <- dcast(carMelt, cyl ~ variable, mean) #indicate summary value
cylData
#averaging values
head(InsectSprays)
tapply(InsectSprays$count, InsectSprays$spray, sum) #apply sum to count along spray
#another way - split
spIns <- split(InsectSprays$count, InsectSprays$spray) #vector count for each spray
spIns
#apply
sprCount <- lapply(spIns, sum)
sprCount
#combine
unlist(sprCount)
sapply(spIns, sum)
#plyr package
ddply(InsectSprays, .(spray), summarise, sum = sum(count)) #.(category variable)
#create new variable
spraySums <- ddply(InsectSprays, .(spray), summarise, sum = ave(count, FUN = sum))
#summarize counts per spray with average per spray; gives dataset with same dim
spraySums
dim(spraySums)



#Managing data frames with dplyr
#one observation per row
#each column is a variable or measure or characteristic
#much faster than base R functions; simplifies base R functions
#select: return a subset of columns of data frame
#filter: extract a subset of rows from a data frame based on logical conditions
#arrange: reorder rows of a data frame
#rename: rename variables in a data frame
#mutate: add new variables/columns or transform existing variables
#summarize/summarise: generate summary statistics of different variables in the
#data frame, possibly within strata

#properties
#first argument is dataframe; refer to columns without using $; returns dataframe

library(dplyr)
chicago <- readRDS("chicago.rds") #does not give way to download file
dim(chicago)
str(chicago)
names(chicago) #variable names
head(select(chicago, city:dptp)) #only show certain columns; use - to not show those
#filter: subset rows based on conditions
chic.f <- filter(chicago, pm25tmean2 > 30)
chic.f <- filter(chicago, pm25tmean2 > 30 & tmpd > 80) #as simple or complex
#arrange to reorder based on a column
chicago <- arrange(chicago, date) #arrange by date
chicago <- arrange(chicago, desc(date)) #arrange descending order
#rename variable
chicago <- rename(chicago, pm25 = pm25tmean2) #new name = old name
#mutate to transform or create variables
chicago <- mutate(chicago, pm25detrend = pm25 - mean(pm25, na.rm = T))
#new variable deviations from mean
#group_by: split data frame according to categorical variables
chicago <- mutate(chicago, tempcat = factor(1 * tmpd > 80), labels = c("cold", "hot"))
hotcold <- group_by(chicago, tempcat)
summarzie(hotcold, pm25 = mean(pm25, na.rm = T), o3 = max(o3tmean2), no2 = median(no2tmean2))
#gives summary info for "cold" and "hot"
#create year variable
chicago <- mutate(chicago, year = as.POSIXlt(date)$year + 1900)
years <- group_by(chicago, year)
summarize(years, pm25 = mean(pm25, na.rm = T), o3 = max(o3tmean2), no2 = median(no2tmean2))

#chain operations: pipe; don't have to create intermediate variables
chicago %>% mutate(month = as.POSIXlt(date)$mon + 1) %>%
    group_by(month) %>%
    summarize(pm25 = mean(pm25, na.rm = T), o3 = max(o3tmean2), no2 = median(no2tmean2))
#other packages, then use dplyr on these
#data.table for large fast tables
#SQL for relational databases


#Merging data
#download data
fileUrl1 <- "https://dl.dropboxusercontent.com/u/7710864/data/reviews-apr29.csv"
fileUrl2 <- "https://dl.dropboxusercontent.com/u/7710864/data/solutions-apr29.csv"
download.file(fileUrl1, destfile = "./data/reviews.csv", method = "curl")
download.file(fileUrl2, destfile = "./data/solutions.csv", method = "curl")
reviews <- read.csv("./data/reviews.csv"); solutions <- read.csv("./data/solutions.csv")
head(reviews)
#still bad websites, no data
head(solutions, 2)
#merge dataframes
names(reviews) #to see if names match
names(solutions)
#merge with x, y, by, by.x, by.y, all
mergedData <- merge(reviews, solutions, by.x = "solution_id", by.y = "id", all = T)
#use all = T for when data points don't match, create new row with NA values
#merge all common column names
intersect(names(solutions), names(reviews))
mergedData2 <- merge(reviews.solutions, all = T) #will merge same columns and add
#new rows when data are different
#can use plyr to merge, but less features; only merge common columns
df1 <- data.frame(id = sample(1:10), x = rnorm(10))
df2 <- data.frame(id = sample(1:10), y = rnorm(10))
arrange(join(df1, df2), id)
df3 <- data.frame(id = sample(1:10), z = rnorm(10))
dfList <- list(df1, df2, df3)
join_all(dfList) #merge multiple datasets quickly



#Week 3 quiz
#1. download data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
download.file(fileUrl, destfile = ".data/acs.csv", method = "curl")
acs <- read.csv("./data/acs2.csv")
head(acs)
#create a logical vector that identifies the households on greater than 10 acres
#who sold more than $10000 worth of agriculture products. Assign the logical vector
#to the variable agricultureLogical. apply the which() function (which(agricultureLogical))
#to identify the rows of the data frame where the logical vector is TRUE. What 
#are the first 3 values that result?
#data in AGS, >10000 = 6
head(acs$AGS)
agricultureLogical <- acs$AGS == 6
agricultureLogical
which(agricultureLogical) #125, 238, 262

#2. using the jpeg package read in the following picture into R
library(jpeg)
file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg"
download.file(file, destfile = "./data/fjeff.jpg")
fjeff <- readJPEG("./data/fjeff.jpg", native = T)
quantile(fjeff, probs = c(0.3, 0.8)) #-16776396, -3735553; not an option
#chose -15259150, -10575416

#3. load the gross domestic product data for the 190 ranked countries
library(dplyr)
file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
#load the educational data from this dataset
file2 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
download.file(file, destfile = "./data/gdp.csv", method = "curl")
gdp <- read.csv("./data/gdp.csv")
gdp <- mutate(gdp, Gross.domestic.product.2012 = as.numeric(Gross.domestic.product.2012))
download.file(file2, destfile = "./data/education.csv", method = "curl")
education <- read.csv("./data/education.csv")
#match the data based on the country shortcode. how many IDs match? sort the data
#frame in descending order by GDP rank. what is the 13th country in the set?
#education uses CountryCode (Table.Name is full names), gdp uses X (X.3 is full names)
merged <- merge(education, gdp, by.x = "Table.Name", by.y = "X.2", all.x = F)
arrange(merged, desc(Gross.domestic.product.2012)) #St. Kitss and Nevis
nrow(merged) #215; not option; try 189

#4. what is the average GDP ranking for the "High income: OECD" and 
# "High income: nonOECD" group
library(dplyr)
merged %>% group_by(Income.Group) %>%
    summarize(average = mean(Gross.domestic.product.2012, na.rm = T))
#high income: oecd = 33.0; high income: nonoecd = 91.9; chose 32.96667, 91.91304
#if keep getting errors, restart R

#5. cut the gdp ranking into 5 separate quantile groups. make a table versus income.group.
#how many countries are lower middle income but among the 38 nations with highest gdp?
#use Hmisc and cut2 function
library(Hmisc)
merged$cut <- cut2(merged$Gross.domestic.product.2012, g = 5)
merged$cut
dataframe <- data.frame(merged$Income.Group, merged$cut)
dataframe %>% filter(merged.Income.Group == "Lower middle income" &
                         merged.cut == "[ 1, 39")
#manually sorted dataframe and filtered = 5
dataframe %>% filter(merged.Income.Group == "Lower middle income")
dataframe %>% filter(merged.cut == levels(merged.cut)[1]) %>%
    filter(merged.Income.Group == "Lower middle income")
#this worked


#week 4
#editing text variables
#using Baltimore data, so examples only
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://data.baltimorecity.gov/api/views/dz54-2aru/rows.csv?accessType=DOWNLOAD"    
download.file(fileUrl, destfile = "./data/cameras.csv", method = "curl")
cameraData <- read.csv("./data/cameras.csv")
names(cameraData)
#yep, webpage doesn't exist
tolower(names(cameraData)) #makes all column names lower case
#also toupper
#fixing character vectors strsplit()
splitNames <- strsplit(names(cameraData), "\\.") #need \\ because . is protected character
splitNames
#quick aside - lists
mylist <- list(letters = c("A", "b", "c"), numbers = 1:3, matrix(1:25, ncol = 5))
head(mylist)
mylist[1]
mylist$letters
mylist[[1]]
#fixing character vectors sapply()
splitNames[[6]][1]
firstElement <- function(x){x[1]}
sapply(splitNames, firstElement) #get first element of names

#peer review experiment data
fileUrl1 <- "https://dl.dropboxusercontent.com/u/7710864/data/reviews-apr29.csv"
fileUrl2 <- "https://dl.dropboxusercontent.com/u/7710864/data/solutions-apr29.csv"
download.file(fileUrl1, destfile = "./data/reviews.csv", method = "curl")
download.file(fileUrl2, destfile = "./data/solutions.csv", method = "curl")
reviews <- read.csv("./data/reviews.csv"); solutions <- read.csv("./data/solutions.csv")
head(reviews, 2)
#webpages don't work again
#fixing character vectors - sub()
names(reviews)
#remove underscore
sub("_", "", names(reviews), )
testName <- "this_is_a_test"
sub("_", "", testName) #just replaces first instance
gsub("_", "", testName) #replaces all instances
#finding values - grep(), grepl()
grep("Alameda", cameraData$intersection) #find all instances where Alameda appears
table(grepl("Alameda", cameraData$intersection)) #returns logical vector
cameraData2 <- cameraData[!grepl("Alameda", cameraData$intersection), ] #all places
#where Alameda doesn't appear
#use value = T, shows more info - values where "Alameda" appears
#look for values that don't appear - returns integer(0)
library(stringr)
nchar("Jeffrey Leek")
substr("Jeffrey Leek", 1, 7)
paste("Jeffrey", "Leek")
paste0("Jeffrey", "Leek") #no space
str_trim("Jeff     ") #trims off excess space

#lowercase, descriptive, not duplicated, character variables may need to be factors


#regular expressions
#combination of literals and metacharacters
#literals - words match exactly
#regular simplist - only literals
#metacharacters
#start of line: ^i think
#end of line $: morning$
#lists of characters, anyplace: [Bb][Uu][Ss][Hh] - match upper or lower
#character classes with []
#^[Ii] am - upper or lower I followed by am
#range of characters
#^[0-9][a-zA-Z] - any number followed by any letter
#[^?.]$

#9.11 - . will refer to any character
# | combine expression, match alternatives fire|flood; any number of alternatives
#alternatives can be expressions not just literals
#^[Gg]ood|[Bb]ad any form of good at beginning or any form of bad
#^([Gg]ood|[Bb]ad); in () both alternatives have same requirements
# [Gg]eorge( [Ww]\.)? [Bb]ush - \. is optional requirement; need \. to indicate literal .
# * repeat any number of the item including none
# + at least one of the item
#[0-9] (.*) [9-0] : any number followed by any number of characters followed by any number
# {} interval quantifiers; specify min and max number of matches of an expression
# {m,n} at least m but not as more than n matches
#{m} exactly m matches
# {m,} at least m matches
# \ means escape
# * always matches longest possible string that satisfies regular expression
#used with grep, grepl, sub, gsub


#working with dates
#simple
d1 <- date() #get current date and time
d1
class(d1)
d2 <- Sys.Date()
d2
class(d2)
#formatting dates
format(d2, "%a %b %d")
# %d = day as number (0-31); %a = abbreviated weekday; %A = unabbreviated weekday;
# %m = month (00-12); %b = abbreviated month; %B = unabbreviated month;
# %y = 2 digit year; %Y = four digit year
#creating dates
x <- c("1jan1960", "2jan1960", "31mar1960", "30jul1960")
x
z <- as.Date(x, "%d%b%Y")
z
z[1] - z[2]
as.numeric(z[1] - z[2])
#convert to Julian
weekdays(d2)
months(d2)
julian(d2) #number of days since origin date

library(lubridate)
ymd("20140108") #convert number to date; ymd = year month day
mdy("08/04/2013")
dmy("03-04-2013")
#times
ymd_hms("2011-08-03 10:15:03")
ymd_hms("2011-08-03 10:15:03", tz = "Greenwich")
#other syntax
x <- dmy(c("1jan2013", "2jan2013", "31mar2013", "30jul2013"))
wday(x[1]) #weekday, from lubridate
wday(x[1], label = T)



#week 4 quiz
#1. dowload american sommunity survey data
file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
download.file(file, destfile = "./data/acs.csv", method = "curl")
acs <- read.csv("./data/acs.csv")
#apply strsplit() to split all the names of the data frame on the characters
#"wgtp". what is the value of the 123 element of the resulting list?
head(acs)
acssplit <- strsplit(names(acs), split = "wgtp")
acssplit[123] # ""  "15"

#2. load the gross domestic product data for the 190 ranked countries
file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
download.file(file, destfile = "./data/gdp.csv", method = "curl")
gdp <- read.csv("./data/gdp.csv", skip = 4)
#remove commas from the GDP numbers in millions of dollars and average them
#in column X.3; need to convert to numeric after removing commas
gdp1 <- gdp
gdp1$X.4 <- gsub(",", "", gdp$X.4)
gdp1$X.4 <- as.numeric(gdp1$X.4)
#remove rows after 190
gdp2 <- gdp1[1:190, ]
mean(gdp2$X.4, rm.na = T) #377652.4

#3. in gdp dataset, what is a regular expression that would allow you to count
#the number of countries whose name begins with "United"
grep("*United", gdp$X.3) #1, 6, 32
grep("^United", gdp$X.3) #1, 6, 32
grep("United$", gdp$X.3) #this is for names that end in United
#pick function with ^, 3 countries

#4. with the gdp, load the education dataset
file <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
download.file(file, destfile = "./data/education.csv", method = "curl")
education <- read.csv("./data/education.csv")
#match based on education$CountryCode and gdp$X
merged <- merge(education, gdp, by.x = "CountryCode", by.y = "X", all.x = F)
#of the countries for which the end of the fiscal year is available, how many end in June?
#June is mentioned in Special.Notes
length(grep("June", merged$Special.Notes)) #16; incorrect, but passed

#5. using quantmod package for following:
library(quantmod)
library(lubridate)
amzn <- getSymbols("AMZN", auto.assign = F)
sampleTimes <- index(amzn)
#how many values were collected in 2012? how many on Mondays in 2012?
head(sampleTimes)
class(sampleTimes)
#extract year
sampleTimesyear <- year(ymd(sampleTimes))
sum(sampleTimesyear == 2012) #250
#use wday() for day of week
sum(wday(sampleTimes) == 2 & year(ymd(sampleTimes)) == 2012) #47
