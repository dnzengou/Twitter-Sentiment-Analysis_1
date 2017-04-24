#Extract tweets
Presidentielle2017.tweets = searchTwitter("Presidentielle2017", n=1500);

#Convert into a dataframe
# Presidentielle2017.tweets_df<- tbl_df(map_df(trump_tweets, as.data.frame))
Presidentielle2017.tweets_df <- do.call("rbind", lapply(Presidentielle2017.tweets, as.data.frame))
# or
# Presidentielle2017.tweets_df <- tbl_df(map_df(trump_tweets, as.data.frame))

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
