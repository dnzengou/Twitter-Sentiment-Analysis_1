#Histograms
hist(table_final$Positive, col=rainbow(10));
hist(table_final$Negative, col=rainbow(10));
hist(table_final$Score, col=rainbow(10));

# If willing, save them locally in png (or jpeg)

# png('rplot-colour_hist-table_finalPositive.png')
# hist(table_final$Positive, col=rainbow(10))
# dev.off()

# png('rplot-colour_hist-table_finalNegative.png')
# hist(table_final$Negative, col=rainbow(10))
# dev.off()

# png('rplot-colour_hist-table_finalScore.png');
# hist(table_final$Score, col=rainbow(10));
# dev.off();

#Pie
slices <- c(sum(table_final$Positive), sum(table_final$Negative));
labels <- c("Positive", "Negative");

install.packages("plotrix");
library(plotrix);
#pie(slices, labels = labels, col=rainbow(length(labels)), main="Sentiment Analysis");
pie3D(slices, labels = labels, col=rainbow(length(labels)),explode=0.00, main="Sentiment Analysis on #Presidentielle2017 tweets - FR");

# If need for a backup, save it locally in png - 2D piechart verion
# png('Sentiment-Analysis_Presidentielle2017_tweets-FR_pie-chart-2D.png');
# pie(slices, labels = labels, col=rainbow(length(labels)), main="Sentiment Analysis on #Presidentielle2017 tweets - FR");
# dev.off();

# And 3D piechart version
# png('Sentiment-Analysis_Presidentielle2017_tweets-FR.png');
# pie3D(slices, labels = labels, col=rainbow(length(labels)),explode=0.00, main="Sentiment Analysis on #Presidentielle2017 tweets - FR");
# dev.off();