#if "<-" it's lines of code from precept; if "=" it's lines I made

closeAllConnections()
rm(list=ls())
library(data.table)
library(chron)
setwd("C:\\Users\\benny\\OneDrive\\Desktop\\github\\lee-ready_algorithm")

Q <- fread("TAQquotes.gz", header=TRUE)
Q$DATE <- as.Date(as.character(Q$DATE),format='%Y%m%d') 
Q$TIME_M <- chron(times=Q$TIME_M)
Q <- Q[Q$TIME_M >= chron(times='09:30:00') & Q$TIME_M <= chron(times='16:00:00')]
Q <- Q[Q$EX == 'N' | Q$EX == 'T' | Q$EX == 'P' | Q$EX == 'Z']



T <- fread("TAQtrades.gz", header=TRUE)
T$DATE <- as.Date(as.character(T$DATE),format='%Y%m%d') 
T$TIME_M <- chron(times=T$TIME_M)
T <- T[T$TIME_M >= chron(times='09:30:00') & T$TIME_M <= chron(times='16:00:00')]
T <- T[T$EX == 'N' | T$EX == 'T' | T$EX == 'P' | T$EX == 'Z']
Q$EX <- factor(Q$EX) # make exchanges a categorical variable 

get_nbbo <- function(type, df, time) {
  arr <- c()
  
  for (ex in levels(df$EX)){
    if (type == 'bid') {
      tmp <- df[df$EX == ex & df$TIME_M <= time] 
      nbbo <- tail(tmp, 1)$BID
    } else if (type == 'offer') {
      tmp <- df[df$EX == ex & df$TIME_M <= time]
      nbbo <- tail(tmp, 1)$ASK
    }
    arr <- c(arr, nbbo)
  }
  
  if (length(arr) > 1) {
    if (type == 'bid') {
      max(arr)
    } else if (type == 'offer') {
      min(arr)
    }
  }
  else {
    arr
  }
}

T$NBBO_OFFER <- lapply(T$TIME_M, {function (x) get_nbbo('offer', Q, x)})
T$NBBO_BID <- lapply(T$TIME_M, {function (x) get_nbbo('bid', Q, x)})

tcopy = T #record keeping of big data


#get rid of no bids/offers
T$NBBO_OFFER[T$NBBO_OFFER == 0] <- NA
T$NBBO_BID[T$NBBO_BID == 0] <- NA

T$MIDPOINT = (as.numeric(T$NBBO_BID)+as.numeric(T$NBBO_OFFER))/2


T$a = T$NBBO_BID > T$PRICE
T$b = T$NBBO_BID == T$PRICE
T$c = T$NBBO_BID < T$PRICE & T$NBBO_OFFER > T$PRICE
T$d = T$NBBO_OFFER == T$PRICE
T$e = T$NBBO_OFFER < T$PRICE
problem4b = c(sum(T$a, na.rm = TRUE)/length(T$TIME_M), 
              sum(T$b, na.rm = TRUE)/length(T$TIME_M),
              sum(T$c, na.rm = TRUE)/length(T$TIME_M),
              sum(T$d, na.rm = TRUE)/length(T$TIME_M),
              sum(T$e, na.rm = TRUE)/length(T$TIME_M))

priceMatchCheck = function(trueID,dfTrade){
  if (dfTrade$PRICE[dfTrade$TR_ID == trueID] >  dfTrade$MIDPOINT[dfTrade$TR_ID == trueID]){
    1 #denote this integer as a buy
  }else if(dfTrade$PRICE[dfTrade$TR_ID == trueID] <  dfTrade$MIDPOINT[dfTrade$TR_ID == trueID]){
    0 #denote this integer as a sell
  }else if(dfTrade$PRICE[dfTrade$TR_ID == trueID] ==  dfTrade$MIDPOINT[dfTrade$TR_ID == trueID]){
  NA
  }
}


T$MATCH_INT = lapply(as.numeric(T$TR_ID), {function (x) priceMatchCheck(x, T)})

Tcopy = T 
library(zoo)
T$MATCH_INT = na.locf(T$MATCH_INT) #if on midpoint; I just labeled it as previous direction

T = T[ , DIFFERENCE := as.numeric(MATCH_INT) - shift(as.numeric(MATCH_INT))]
T$SameDirection = T$DIFFERENCE == 0
T$OppositeDirection = abs(T$DIFFERENCE) == 1
problem4d = c(sum(T$SameDirection, na.rm = TRUE), sum(T$OppositeDirection
                    ,na.rm = TRUE ))/length(T$DIFFERENCE)

#turn out I didn't need to calulated unique same direction event but I'll keep it
T$LEE_READY = as.numeric(T$MATCH_INT) + T$DIFFERENCE
#0 ss
#1 bb
#2 sb
#-1 bs

