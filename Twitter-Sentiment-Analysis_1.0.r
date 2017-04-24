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

# Compare tweets words against bag of words
pos.words = scan("C:/Users/dez/Documents/R/Projects/Twitter-Sentiment-Analysis_1/positive-words_FR.txt", what='character', comment.char = ';');
# Read 2410 items
neg.words = scan("C:/Users/dez/Documents/R/Projects/Twitter-Sentiment-Analysis_1/negative-words_FR.txt", what='character', comment.char = ';');
# Read 5561 items

# If necessary, apend word bags with additional sentiment words
pos.words = c(pos.words, 'Slt', 'bye', 'ciao', 'stp','svp', 'youpi');
neg.words = c(neg.words, 'pq', 'pcq', 'no', 'na','pfff');

# Let's call the sentiment function to analyze our tweets sample
# to clean the tweets and return merged data frame
library(stringr);
require(stringr);
result = score.sentiment(sample, pos.words, neg.words);

library(reshape)
# Create a copy of result data frame
test1 = result[[1]];
test2 = result[[2]];
test3 = result[[3]];

# Check data structure 1, 2 and/or 3 giving the positive and negative scores
# result[[1]]
# result[[2]]
# result[[3]]

# Let's remove ltext part from tweets so we only keep the scores
test1$text = NULL;
test2$text = NULL;
test3$text = NULL;

# and store them in q1, q2 and q3
q1 = test1[1,];
q2 = test2[1,];
q3 = test3[1,];

# Let's visualize scores and corresponding values
qq1 = melt(q1, , var='Score');
qq2 = melt(q2, , var='Positive');
qq3 = melt(q3, , var='Negative');

# Let's remove Score, Positive and Negative columns
qq1['Score'] = NULL;
qq2['Positive']=NULL;
qq3['Negative']=NULL;

# Let's convert into data frames
table1 =  data.frame(Text=result[[1]]$text, Score=qq1);
table2 =  data.frame(Text=result[[2]]$text, Score=qq2);
table3 =  data.frame(Text=result[[3]]$text, Score=qq3);

# Merge the tables
table_final = data.frame(Text = table1$Text, Score = table1$value, Positive = table2$value, Negative = table3$value)