Presidentielle2017_text = sapply(Presidentielle2017.tweets, function(x) x$getText()); #sapply returns a vector 
# Check the data
# head(Presidentielle2017_text, n=10);

# Convert it into a data frame
df <- do.call("rbind", lapply(Presidentielle2017.tweets, as.data.frame)); #lapply returns a list
#Check the data frame structure
# head(df, n=10)
Presidentielle2017_text <- sapply(df$text,function(row) iconv(row, "latin1", "ASCII", sub=""));
str(Presidentielle2017_text); #gives the (structure) summary/internal structure of an R object

# Install NLP package
install.packages("tm");
library(tm); #tm: text mining
Presidentielle2017_corpus <- Corpus(VectorSource(Presidentielle2017_text)); #corpus is a collection of text documents
Presidentielle2017_corpus;
inspect(Presidentielle2017_corpus[1]);

#clean text
install.packages("wordcloud");
library(wordcloud);
Presidentielle2017_clean <- tm_map(Presidentielle2017_corpus, removePunctuation);
Presidentielle2017_clean <- tm_map(Presidentielle2017_clean, removeWords, stopwords("english"));
Presidentielle2017_clean <- tm_map(Presidentielle2017_clean, removeNumbers);
Presidentielle2017_clean <- tm_map(Presidentielle2017_clean, stripWhitespace);
wordcloud(Presidentielle2017_clean, random.order=F,max.words=80, col=rainbow(50), scale=c(3.5,1));