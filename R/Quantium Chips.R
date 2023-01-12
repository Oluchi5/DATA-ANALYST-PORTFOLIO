## Load required libraries
library(data.table) #helps enhanced version of data frames
library(tidyverse)  #helps wrangle data
library(lubridate)  #helps wrangle date attributes
library(ggplot2)  #helps visualize data
library(ggmosaic)#helps visualize data
library(stringr) #helps provide functions for working with strings
library(readr)
library(dplyr) #helps manipulation data 

#=======================================================================
# Point the file Path to download the data sets 
#======================================================================

getwd() #displays your working directory
setwd("/Users/Oluchukwu Anene/Documents/Quantium Chips data") 


#========================================================
#Upload CSV Files
#=======================================================
transactionData <- read_csv("QVI_transaction_data.csv")
customerData <- read_csv("QVI_purchase_behaviour.csv")

#========================================================
#Exploratory data analysis for transactionData
#========================================================
#view colunms
colnames(transactionData)


#### Examine transaction data
str(transactionData)


#### Examine PROD_NAME
table(transactionData[ "PROD_NAME"]) #to find the unique containt and its no. of occurance

 #or You can use                        

transactionData %>%
  count(PROD_NAME)

#From the output the Product names is populated by chips so we will be working with various chips.

'There are salsa products in the dataset but we are only interested in the chips category, so let’s remove
these.'
#--------------------------------------------------------------------------------------------------------

#### Remove salsa products
# Create a new column indicating whether each row contains the word "salsa" in the PROD_NAME column
transactionData <- transactionData %>%
  mutate(SALSA = grepl("salsa", tolower(PROD_NAME)))

# Remove rows with the word "salsa" in the PROD_NAME column
transactionData <- transactionData %>%
  filter(SALSA == FALSE) %>%
  select(-SALSA)
#----------------------------------------------------------------------------------------------------------

#### Summaries the data to check or nulls and possible outliers
summary(transactionData)

#======================================================================================================
#PROD_QTY has an outlier of 200
#Filter the dataset to find the outlier
#=======================================================================================================

# Select rows with PROD_QTY equal to 200
 transactionData[transactionData$PROD_QTY == 200, ]
 
# Let's see if the customer has had other transactions
 transactionData[transactionData$LYLTY_CARD_NBR == 226000, ]
 
' It looks like this customer has only had the two transactions over the year and is not an ordinary retail
 customer. The customer might be buying chips for commercial purposes instead. We’ll remove this loyalty
 card number from further analysis.'
#-----------------------------------------------------------------------------------------------------------
 
 # Use the base R's subsetting methodto keep only rows where LYLTY_CARD_NBR does not equal 226000
 transactionData <- transactionData[transactionData$LYLTY_CARD_NBR != 226000, ]
 
 # Re‐examine transaction data
 summary(transactionData)
 
# That’s better. Now, let’s look at the number of transaction lines over time to see if there are any obvious data issues such as missing data.
#------------------------------------------------------------------------------------------------------------------------------------------------
  ## Count the number of transactions by date
 transactionData %>%
   group_by(DATE) %>%
   summarize(n = n())
 
 # Show the top 5 dates with the highest number of transactions
 head(arrange(transactionData, DATE),5)
 
 # Show the bottom 5 dates with the lowest number of transactions
 tail(arrange(transactionData, DATE),5)
 
 'There’s only 364 rows, meaning only 364 dates which indicates a missing date. Let’s create a sequence of
 dates from 1 Jul 2018 to 30 Jun 2019 and use this to create a chart of number of transactions over time to
 find the missing date.'
#----------------------------------------------------------------------------------------------------------------------
  # Create a sequence of dates from 2018-07-01 to 2019-06-30
 allDates <- data.frame(DATE = seq(as.Date("2018-07-01"), as.Date("2019-06-30"), by = "day"))
 
 # Count the number of transactions by date and join it with the allDates dataframe
 transactions_by_day <- left_join(allDates, 
                                  transactionData %>% group_by(DATE) %>% summarize(transactions = n()),
                                  by = c("DATE"))
 
 # Plot transactions over time
 ggplot(transactions_by_day, aes(x = DATE, y = transactions)) +
   geom_line() +
   scale_x_date(date_breaks = "1 month", date_labels = "%b-%Y") +
   labs(title = "Transactions over time", x = "Date", y = "Number of transactions") +
   theme_bw() +
   theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
 #This code creates a sequence of dates between 2018-07-01 and 2019-06-30, and a data frame allDates which contains all the dates and labels them as "DATE". Then it uses group_by(), summarize() and left_join() functions to count the number of transactions by date, and join this dataframe with allDates dataframe.
 
 #The scale_x_date() function allows to format the x-axis with breaks set to 1 month and labels set to month-year format and other cosmetics are set using ggplot2's theme options.


 'We can see that there is an increase in purchases in December and a break in late December. Let’s zoom in
 on this.'
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
 #Filter to December and look at individual days
 ggplot(transactions_by_day[month(transactions_by_day$DATE) == 12, ], aes(x = DATE, y = transactions)) +
   geom_line() +
   scale_x_date(date_breaks = "1 day", date_labels = "%d-%b") +
   labs(title = "Transactions over time in December", x = "Date", y = "Number of transactions") +
   theme_bw() +
   theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
 #This code uses the month() function to filter out only December's dates, and then uses ggplot() function to create a line plot. The scale_x_date() function allows to format the x-axis with breaks set to 1 day and labels set to day-month format, cosmetics are set with ggplot2's theme options.
 
 
' We can see that the increase in sales occurs in the lead-up to Christmas and that there are zero sales on
 Christmas day itself. This is due to shops being closed on Christmas day.
 Now that we are satisfied that the data no longer has outliers, we can move on to creating other features
 such as brand of chips or pack size from PROD_NAME. We will start with pack size.'
 
#========================================================================================================================
 # Extract the pack size from PROD_NAME column
 transactionData$PACK_SIZE <- as.numeric(str_extract(transactionData$PROD_NAME, "\\d+"))
 
 # Check the result
 transactionData %>%
   group_by(PACK_SIZE) %>%
   summarize(count = n()) %>%
   arrange(PACK_SIZE)
#=========================================================================================================================== 
 
#View data set
transactionData
#----------------------------------------------------------------
#since we have a product size column, i will be removing ever 134g at the back of ever chip product since we are analyzing the types not size 

# Remove last 4 characters from the PROD_NAME column
transactionData$PROD_NAME<- substr(transactionData$PROD_NAME, 1, nchar(transactionData$PROD_NAME) - 4)

 #View data set
transactionData
#==================================================================================================================

# Plot a histogram of PACK_SIZE
ggplot(transactionData, aes(x = PACK_SIZE)) +
  geom_histogram(binwidth = 10, color = "black", fill = "white") +
  labs(title = "Histogram of Pack Size", x = "Pack Size", y = "Frequency") +
  theme_bw()

'Pack sizes created look reasonable and now to create brands, we can use the first word in PROD_NAME to
work out the brand name'

#====================================================================================================================
# Extract the brand from PROD_NAME column
transactionData$BRAND <- substr(transactionData$PROD_NAME,1,regexpr(" ",transactionData$PROD_NAME)-1)
transactionData$BRAND<-toupper(transactionData$BRAND)

# Check the result
transactionData %>%
  group_by(BRAND) %>%
  summarize(count = n()) %>%
  arrange(-count)

# Clean brand names
transactionData$BRAND <- 
  ifelse(transactionData$BRAND == "RED", "RRD", 
         ifelse(transactionData$BRAND == "SNBTS", "SUNBITES",
                ifelse(transactionData$BRAND == "INFZNS", "INFUZIONS",
                       ifelse(transactionData$BRAND == "WW", "WOOLWORTHS",
                              ifelse(transactionData$BRAND == "SMITH", "SMITHS",
                                     ifelse(transactionData$BRAND == "NCC", "NATURAL",
                                            ifelse(transactionData$BRAND == "DORITO", "DORITOS",
                                                   ifelse(transactionData$BRAND == "GRAIN", "GRNWVES", 
                                                          transactionData$BRAND))))))))

# Check the result
transactionData %>%
  group_by(BRAND) %>%
  summarize(count = n()) %>%
  arrange(BRAND)



#=======================================================================================================================
#Examining customer data
#Now that the transaction dataset has been wrangled and cleaned, I can look at the customer dataset.

#=======================================================================================================================
#### Examining customer data
str(customerData)

summary(customerData)
#-----------------------------------------------------------------------------------------------------------------------
#Checking the LIFESTAGE and PREMIUM_CUSTOMER columns.
#Examine the values of LIFESTAGE
customerData %>%
  group_by(LIFESTAGE) %>%
  summarize(count = n()) %>%
  arrange(-count)

#--------------------------------------------------------------------------------------------------------------------------
#Examine the values of PREMIUM_CUSTOMER
customerData %>%
  group_by(PREMIUM_CUSTOMER) %>%
  summarize(count = n()) %>%
  arrange(-count)

'As there do not seem to be any issues with the customer data, we can now go ahead and oin the transaction
and customer data sets together'
#============================================================================================================
#### Merge transaction data to customer data
Chipsdata <- merge(transactionData, customerData, all.x = TRUE)

#View merged dataset
Chipsdata 
#=============================================================================================================
#check if some customers were not matched on by checking for nulls.

#count the number of rows with missing LIFESTAGE
Chipsdata %>%
  filter(is.na(LIFESTAGE)) %>%
  nrow()


#count the number of rows with missing PREMIUM_CUSTOMER
Chipsdata %>%
  filter(is.na(PREMIUM_CUSTOMER)) %>%
  nrow()
#There are no missing values



###Data exploration is now complete!
#=================================================================== 


#### Data analysis on customer segments
#=======================================================================================================
'Now that the data is ready for analysis, we can define some metrics of interest to the client:
  • Who spends the most on chips (total sales), describing customers by lifestage and how premium their
general purchasing behaviour is
• How many customers are in each segment
• How many chips are bought per customer by segment
• What’s the average chip price by customer segment
We could also ask our data team for more information. Examples are:
  • The customer’s total spend over the period and total spend for each transaction to understand what
proportion of their grocery spend is on chips
• Proportion of customers in each customer segment overall to compare against the mix of customers
who purchase chips
Let’s start with calculating total sales by LIFESTAGE and PREMIUM_CUSTOMER and plotting the split by
these segments to describe which customer segment contribute most to chip sales.'
#===================================================================================================================
#==================================================================================================================
# Sum total sales by LIFESTAGE and PREMIUM_CUSTOMER
sales <- Chipsdata %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarize(SALES = sum(TOT_SALES))

#### Create plot
p <- ggplot(data = sales) +
  geom_mosaic(aes(weight = SALES, x = product(PREMIUM_CUSTOMER, LIFESTAGE),
                   fill = PREMIUM_CUSTOMER)) +
  labs(x = "Lifestage", y = "Premium customer flag", title = "Proportion of
 sales") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
#### Plot and label with proportion of sales
p + geom_text(data = ggplot_build(p)$data[[1]], aes(x = (xmin + xmax)/2 , y =
                                                      (ymin + ymax)/2, label = as.character(paste(round(.wt/sum(.wt),3)*100,
                                                                                                  '%'))))




'Sales are coming mainly from Budget - older families, Mainstream - young singles/couples, and Mainstream
- retirees'
#==========================================================================================================
#Let’s see if the higher sales are due to there being more customers who buy chips.
#==========================================================================================================
# Number of customers by LIFESTAGE and PREMIUM_CUSTOMER
customers <- Chipsdata %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarize(CUSTOMERS = n_distinct(LYLTY_CARD_NBR)) %>%
  arrange(-CUSTOMERS)


#### Create Plot
p <- ggplot(data = customers) +
  geom_mosaic(aes(weight = CUSTOMERS, x = product(PREMIUM_CUSTOMER,
                                                   LIFESTAGE), fill = PREMIUM_CUSTOMER)) +
  labs(x = "Lifestage", y = "Premium customer flag", title = "Proportion of
 customers") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
#### Plot and label with Proportion of customers
p + geom_text(data = ggplot_build(p)$data[[1]], aes(x = (xmin + xmax)/2 , y =
                                                      (ymin + ymax)/2, label = as.character(paste(round(.wt/sum(.wt),3)*100,
                                                                                                  '%'))))

'There are more Mainstream - young singles/couples and Mainstream - retirees who buy chips. This con￾
tributes to there being more sales to these customer segments but this is not a major driver for the Budget
- Older families segment.'

#======================================================================================================================================
#Higher sales may also be driven by more units of chips being bought per customer. 
#======================================================================================================================================

# Average number of units per customer by LIFESTAGE and PREMIUM_CUSTOMER
avg_units <- Chipsdata %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarize(AVG = sum(PROD_QTY) / n_distinct(LYLTY_CARD_NBR)) %>%
  arrange(-AVG)

## Create Plot
ggplot(data = avg_units, aes(weight = AVG, x = LIFESTAGE, fill =
                                PREMIUM_CUSTOMER)) +
  geom_bar(position = position_dodge()) +
  labs(x = "Lifestage", y = "Avg units per transaction", title = "Units per
 customer") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

'Older families and young families in general buy more chips per customer'

#=========================================================================================================
#NOW for the average price per unit chips bought for each customer segment as this is also a driver of total sales.
#========================================================================================================
# Average price per unit by LIFESTAGE and PREMIUM_CUSTOMER
avg_price <- Chipsdata %>%
  group_by(LIFESTAGE, PREMIUM_CUSTOMER) %>%
  summarize(AVG = sum(TOT_SALES) / sum(PROD_QTY)) %>%
  arrange(-AVG)

#### Create Plot
ggplot(data = avg_price, aes(weight = AVG, x = LIFESTAGE, fill =
                                PREMIUM_CUSTOMER)) +
  geom_bar(position = position_dodge()) +
  labs(x = "Lifestage", y = "Avg price per unit", title = "Price per unit") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

'Mainstream midage and young singles and couples are more willing to pay more per packet of chips com￾
pared to their budget and premium counterparts. This may be due to premium shoppers being more likely to
buy healthy snacks and when they buy chips, this is mainly for entertainment purposes rather than their own
consumption. This is also supported by there being fewer premium midage and young singles and couples
buying chips compared to their mainstream counterparts.'

#===================================================================================================================
#As the difference in average price per unit isn’t large, we can check if this difference is statistically different.
#===================================================================================================================

# Perform independent t-test between Mainstream vs Premium
pricePerUnit <- Chipsdata %>%
  mutate(price = TOT_SALES/PROD_QTY)

result <- pricePerUnit %>%
  filter(LIFESTAGE %in% c("YOUNG SINGLES/COUPLES", "MIDAGE SINGLES/COUPLES")) %>%
  group_by(PREMIUM_CUSTOMER) %>%
  summarize(mean = mean(price))

t.test(pricePerUnit[pricePerUnit$PREMIUM_CUSTOMER == "Mainstream" & pricePerUnit$LIFESTAGE %in% c("YOUNG SINGLES/COUPLES", "MIDAGE SINGLES/COUPLES"),'price'],
       pricePerUnit[pricePerUnit$PREMIUM_CUSTOMER != "Mainstream" & pricePerUnit$LIFESTAGE %in% c("YOUNG SINGLES/COUPLES", "MIDAGE SINGLES/COUPLES"),'price'],
       alternative = "greater")


'The t-test results in a p-value < 2.2e-16, i.e. the unit price for mainstream, young and mid-age singles and
couples are significantly higher than that of budget or premium, young and midage singles and couples.'


#===============================================================================================================
'Checking customer segments that contribute the most to sales to retain them or further
increase sales. Let’s look at Mainstream - young singles/couples. For instance, let’s find out if they tend to
buy a particular brand of chips.'
#=================================================================================================================

# Deep dive into mainstream, young singles/couples
segment1 <- Chipsdata %>% 
  filter(LIFESTAGE == "YOUNG SINGLES/COUPLES", PREMIUM_CUSTOMER == "Mainstream")
other <- Chipsdata %>%
  filter(!(LIFESTAGE == "YOUNG SINGLES/COUPLES" & PREMIUM_CUSTOMER == "Mainstream"))

# Brand affinity compared to the rest of the population
quantity_segment1 <- segment1 %>% 
  summarize(total_qty = sum(PROD_QTY)) %>% 
  pull(total_qty)
quantity_other <- other %>% 
  summarize(total_qty = sum(PROD_QTY)) %>% 
  pull(total_qty)

quantity_segment1_by_brand <- segment1 %>%
  group_by(BRAND) %>% 
  summarize(targetSegment = sum(PROD_QTY)/quantity_segment1)
quantity_other_by_brand <- other %>%
  group_by(BRAND) %>% 
  summarize(other = sum(PROD_QTY)/quantity_other)

brand_proportions <- quantity_segment1_by_brand %>% 
  left_join(quantity_other_by_brand) %>% 
  mutate(affinityToBrand = targetSegment/other) %>% 
  arrange(affinityToBrand)


#Create plot
ggplot(brand_proportions, aes(x = BRAND, y = affinityToBrand)) + 
  geom_col() + 
  labs(x = "Brand", y = "Affinity to Brand", title = "Brand Affinity of Young Singles/Couples in Mainstream Segment")

'We can see that :
  • Mainstream young singles/couples are 23% more likely to purchase Tyrrells chips compared to the
rest of the population
• Mainstream young singles/couples are 56% less likely to purchase Burger Rings compared to the rest
of the population'


#======================================================================================================================
#Let’s also find out if our target segment tends to buy larger packs of chips.
#======================================================================================================================
# Join the dataset by pack_size column and calculate the proportion

#### Preferred pack size compared to the rest of the population
# Pack_size affinity compared to the rest of the population
# convert dataframes to data.tables
segment1 <- as.data.table(segment1)
other <- as.data.table(other)

#convert PACK_SIZE to numeric
segment1[, PACK_SIZE := as.numeric(PACK_SIZE)]
other[, PACK_SIZE := as.numeric(PACK_SIZE)]

quantity_segment1 <- sum(segment1[, PROD_QTY])
quantity_other <- sum(other[, PROD_QTY])

quantity_segment1_by_pack <- segment1[, .(targetSegment = sum(PROD_QTY) / quantity_segment1), by = PACK_SIZE]

quantity_other_by_pack <- other[, .(other = sum(PROD_QTY) / quantity_other), by = PACK_SIZE]

quantity_segment1_by_pack


'It looks like Mainstream young singles/couples are more likely to purchase a 270g pack of chips compared to the rest of the population' 

#==========================================================================================================================
#let’s dive into what brands sell this pack size.
#==========================================================================================================================

# convert dataframe to data.table
Chipsdata <- as.data.table(Chipsdata)

# filter for rows where PACK_SIZE is equal to 270
Chipsdata[Chipsdata$PACK_SIZE == 270, PROD_NAME]


# filter for rows where PACK_SIZE is equal to 270 and select BRAND column
Chipsdata[Chipsdata$PACK_SIZE == 270, unique(BRAND)]

#
'Twisties are the only brand offering 270g packs and so this may instead be reflecting a higher likelihood of
purchasing Twisties.'
#===============================================

#LET'S SAVE THE NEW DATASET for task2
write.csv(Chipsdata, file = '~/Quantium Chips data/Chipsdata.csv')

#================================================================================================
#Conclusion
#================================================================================================

'* Sales have mainly been due to Budget - older families, Mainstream - young singles/couples, and Mainstream retirees shoppers. 

* We found that the high spend in chips for mainstream young singles/couples and retirees is due to there being more of them than other buyers. Mainstream, midage and young singles and
couples are also more likely to pay more per packet of chips. This is indicative of impulse buying behaviour.

* We’ve also found that Mainstream young singles and couples are 23% more likely to purchase Tyrrells chips
compared to the rest of the population. 

* The Category Manager may want to increase the category’s performance by off-locating some Tyrrells and smaller packs of chips in discretionary space near segments
where young singles and couples frequent more often to increase visibilty and impulse behaviour.

*Quantium data analyst can help the Category Manager with recommendations of where these segments are and further
help them with measuring the impact of the changed placement'. 