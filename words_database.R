# Compare tweets words against bag of words
pos.words = scan("C:/Users/dez/Documents/R/Projects/Twitter-Sentiment-Analysis_1/positive-words_FR.txt", what='character', comment.char = ';');
# Read 2410 items
neg.words = scan("C:/Users/dez/Documents/R/Projects/Twitter-Sentiment-Analysis_1/negative-words_FR.txt", what='character', comment.char = ';');
# Read 5561 items

# If necessary, apend word bags with additional sentiment words
pos.words = c(pos.words, 'Slt', 'bye', 'ciao', 'stp','svp', 'youpi');
neg.words = c(neg.words, 'pq', 'pcq', 'no', 'na','pfff');