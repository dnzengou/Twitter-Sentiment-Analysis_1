#assuming input = Marine

a_trends = availableTrendLocations(); # gives trends by location and the world ID
woeid = a_trends[which(a_trends$name=="Paris"),115];
France_trend = getTrends(woeid)
trends = France_trend[1:2]

#To clean data and remove Non English words: 
dat <- cbind(trends$name)
dat2 <- unlist(strsplit(dat, split=", "))
dat3 <- grep("dat2", iconv(dat2, "latin1", "ASCII", sub="dat2"))
dat4 <- dat2[-dat3]
dat4