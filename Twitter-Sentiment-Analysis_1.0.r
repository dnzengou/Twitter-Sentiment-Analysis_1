getwd();
# [1] "C:/Users/dez/Documents"
setwd();
# ("C:/Users/dez/Documents/R/Projects/Twitter-Sentiment-Analysis_1")

# Install libraries and dependencies
# install.packages(c("devtools", "rjson", "bit64", "httr"))
install.packages('twitteR',dependencies = T);
install.packages('plyr',dependencies = T);
install.packages('ROAuth');
# library(RCurl)
library(plyr);
library(ROAuth);
library(devtools);
library(RCurl);
require(RCurl);

# set Twitter API access credentials
consumer_key <- "xxxxx";
consumer_secret <- "xxxxx";
access_token <- "xxxxx";
access_secret <- "xxxxx";


library(twitteR);
# setup_twitter_oauth(getOption("consumer_key"), getOption("consumer_secret"), getOption("access_token"), getOption("access_secret"))

# download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
# [1] "Using direct authentication"

cred <- OAuthFactory$new(consumerKey=consumer_key, consumerSecret=consumer_secret, requestURL='https://api.twitter.com/oauth/request_token', accessURL='https://api.twitter.com/oauth/access_token', authURL='https://api.twitter.com/oauth/authorize')

# cred$handshake(cainfo="cacert.pem")
cred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

# https://api.twitter.com/oauth/authorize OK after entering PIN
searchTwitter("#Presidentielle2017",n=1000)
# List of 1000 tweets about Presidentielle2017

Presidentielle2017.tweets = searchTwitter("#Presidentielle2017",n=1000)
Presidentielle2017.tweets_df <- do.call("rbind", lapply(Presidentielle2017.tweets, as.data.frame))

# Check data structure (the first and last 10 tweets)
# tail(Presidentielle2017.tweets_df, n=10)
# head(Presidentielle2017.tweets_df, n=10)

# Let's now do the same for the tweet itself (text column)
# head(Presidentielle2017.tweets_df$text, n=10)

Presidentielle2017.tweets_df$text <- sapply(Presidentielle2017.tweets_df$text, function(row) iconv(row, "latin1", "ASCII", sub=""));
Presidentielle2017.tweets_df$text = gsub("f|ht)tp(s?)://(.*)[.][a-z]+","",Presidentielle2017.tweets_df$text);
sample <- Presidentielle2017.tweets_df$text;

# Store clean tweets in a txt file
#sink("clean-tweet_Presidentielle2017.txt");
#sample;
#sink();
