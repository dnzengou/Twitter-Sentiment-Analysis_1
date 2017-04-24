getwd();
# [1] "C:/Users/dez/Documents"
setwd();
# ("C:/Users/dez/Documents/R/Projects/Twitter-Sentiment-Analysis_1")

## THE DATASET
# First we'll retrieve the content of Donald Trump's timeline using the userTimeline function in the twitteR package:[^fullcode]

library(dplyr);
library(purrr);
library(twitteR);

# You'd need to set global options with an authenticated app
setup_twitter_oauth(getOption("twitter_consumer_key"),
                    getOption("twitter_consumer_secret"),
                    getOption("twitter_access_token"),
                    getOption("twitter_access_token_secret"))

# We can request only 3200 tweets at a time; it will return fewer
# depending on the API
trump_tweets <- userTimeline("realDonaldTrump", n = 3200)
trump_tweets_df <- tbl_df(map_df(trump_tweets, as.data.frame))

# if you want to follow along without setting up Twitter authentication,
# just use my dataset:
load(url("http://varianceexplained.org/files/trump_tweets_df.rda"))

# We clean this data a bit, extracting the source application. (We're looking only at the iPhone and Android tweets- a much smaller number are from the web client or iPad).

library(tidyr)

tweets <- trump_tweets_df %>%
  select(id, statusSource, text, created) %>%
  extract(statusSource, "source", "Twitter for (.*?)<") %>%
  filter(source %in% c("iPhone", "Android"))

  # Overall, this includes r sum(tweets$source == "iPhone") tweets from iPhone, and r sum(tweets$source == "Android") tweets from Android.
  # One consideration is what time of day the tweets occur, which we'd expect to be a "signature" of their user. Here we can certainly spot a difference

  library(lubridate)
library(scales)

tweets %>%
  count(source, hour = hour(with_tz(created, "EST"))) %>%
  mutate(percent = n / sum(n)) %>%
  ggplot(aes(hour, percent, color = source)) +
  geom_line() +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Hour of day (EST)",
       y = "% of tweets",
       color = "")

       # Trump on the Android does a lot more tweeting in the morning, while the campaign posts from the iPhone more in the afternoon and early evening.
       # Another place we can spot a difference is in Trump's anachronistic behavior of "manually retweeting" people by copy-pasting their tweets, then surrounding them with quotation marks
       # Almost all of these quoted tweets are posted from the Android

       library(stringr)

tweets %>%
  count(source,
        quoted = ifelse(str_detect(text, '^"'), "Quoted", "Not quoted")) %>%
  ggplot(aes(source, n, fill = quoted)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "", y = "Number of tweets", fill = "") +
  ggtitle('Whether tweets start with a quotation mark (")')

  # In the remaining by-word analyses in this text, I'll filter these quoted tweets out (since they contain text from followers that may not be representative of Trump's own tweets).
  # Somewhere else we can see a difference involves sharing links or pictures in tweets.

  tweet_picture_counts <- tweets %>%
  filter(!str_detect(text, '^"')) %>%
  count(source,
        picture = ifelse(str_detect(text, "t.co"),
                         "Picture/link", "No picture/link"))

ggplot(tweet_picture_counts, aes(source, n, fill = picture)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "", y = "Number of tweets", fill = "")

  spr <- tweet_picture_counts %>%
  spread(source, n) %>%
  mutate_each(funs(. / sum(.)), Android, iPhone)

rr <- spr$iPhone[2] / spr$Android[2]

# It turns out tweets from the iPhone were r round(rr) times as likely to contain either a picture or a link. This also makes sense with our narrative: the iPhone (presumably run by the campaign) tends to write "announcement" tweets about events
# While Android (Trump himself) tends to write picture-less tweets

# COMPARISON OF WORDS
# Now that we're sure there's a difference between these two accounts, what can we say about the difference in the content? We'll use the tidytext package that Julia Silge and I developed.
# We start by dividing into individual words using the unnest_tokens function (see this vignette for more), and removing some common "stopwords"[^regex]

library(tidytext)

reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"
tweet_words <- tweets %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

tweet_words

# What were the most common words in Trump's tweets overall?

tweet_words %>%
  count(word, sort = TRUE) %>%
  head(20) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_bar(stat = "identity") +
  ylab("Occurrences") +
  coord_flip()

  # Now let's consider which words are most common from the Android relative to the iPhone, and vice versa. We'll use the simple measure of log odds ratio, calculated for each word as:[^plusone]
  # $$\log_2(\frac{\frac{\mbox{# in Android} + 1}{\mbox{Total Android} + 1}} {\frac{\mbox{# in iPhone} + 1}{\mbox{Total iPhone} + 1}})$$

  android_iphone_ratios <- tweet_words %>%
  count(word, source) %>%
  filter(sum(n) >= 5) %>%
  spread(source, n, fill = 0) %>%
  ungroup() %>%
  mutate_each(funs((. + 1) / sum(. + 1)), -word) %>%
  mutate(logratio = log2(Android / iPhone)) %>%
  arrange(desc(logratio))
  
  #Which are the words most likely to be from Android and most likely from iPhone?

  android_iphone_ratios %>%
  group_by(logratio > 0) %>%
  top_n(15, abs(logratio)) %>%
  ungroup() %>%
  mutate(word = reorder(word, logratio)) %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  ylab("Android / iPhone log ratio") +
  scale_fill_manual(name = "", labels = c("Android", "iPhone"),
                    values = c("red", "lightblue"))

## SENTOMENT ANALYSIS
# Since we've observed a difference in sentiment between the Android and iPhone tweets, let's try quantifying it. We'll work with the NRC Word-Emotion Association lexicon, available from the tidytext package, which associates words with 10 sentiments: positive, negative, anger, anticipation, disgust, fear, joy, sadness, surprise, and trust

nrc <- sentiments %>%
  filter(lexicon == "nrc") %>%
  dplyr::select(word, sentiment)

nrc

# To measure the sentiment of the Android and iPhone tweets, we can count the number of words in each category

sources <- tweet_words %>%
  group_by(source) %>%
  mutate(total_words = n()) %>%
  ungroup() %>%
  distinct(id, source, total_words)

by_source_sentiment <- tweet_words %>%
  inner_join(nrc, by = "word") %>%
  count(sentiment, id) %>%
  ungroup() %>%
  complete(sentiment, id, fill = list(n = 0)) %>%
  inner_join(sources) %>%
  group_by(source, sentiment, total_words) %>%
  summarize(words = sum(n)) %>%
  ungroup()

head(by_source_sentiment)

# (For example, we see that r by_source_sentiment$words[1] of the r by_source_sentiment$total_words[1] words in the Android tweets were associated with "anger"). 
# We then want to measure how much more likely the Android account is to use an emotionally-charged term relative to the iPhone account. Since this is count data, we can use a Poisson test to measure the difference

library(broom)

sentiment_differences <- by_source_sentiment %>%
  group_by(sentiment) %>%
  do(tidy(poisson.test(.$words, .$total_words)))

sentiment_differences

# And we can visualize it with a 95% confidence interval

library(scales)

sentiment_differences %>%
  ungroup() %>%
  mutate(sentiment = reorder(sentiment, estimate)) %>%
  mutate_each(funs(. - 1), estimate, conf.low, conf.high) %>%
  ggplot(aes(estimate, sentiment)) +
  geom_point() +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high)) +
  scale_x_continuous(labels = percent_format()) +
  labs(x = "% increase in Android relative to iPhone",
       y = "Sentiment")

# Thus, Trump's Android account uses about 40-80% more words related to disgust, sadness, fear, anger, and other "negative" sentiments than the iPhone account does. (The positive emotions weren't different to a statistically significant extent).

# We're especially interested in which words drove this different in sentiment. Let's consider the words with the largest changes within each category

android_iphone_ratios %>%
  inner_join(nrc, by = "word") %>%
  filter(!sentiment %in% c("positive", "negative")) %>%
  mutate(sentiment = reorder(sentiment, -logratio),
         word = reorder(word, -logratio)) %>%
  group_by(sentiment) %>%
  top_n(10, abs(logratio)) %>%
  ungroup() %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  facet_wrap(~ sentiment, scales = "free", nrow = 2) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "", y = "Android / iPhone log ratio") +
  scale_fill_manual(name = "", labels = c("Android", "iPhone"),
                    values = c("red", "lightblue"))


