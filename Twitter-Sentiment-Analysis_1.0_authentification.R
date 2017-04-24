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