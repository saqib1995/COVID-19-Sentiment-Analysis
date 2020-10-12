library(ggplot2)
library(tm)
library(wordcloud)
library(syuzhet)

tweets <- searchTwitter("covid19", n=50, lang="en")
text <- read.csv("COVID-19Analysis.csv")
tweetTxt = sapply(text, function(x) x$getText())
docs <- Corpus(VectorSource(text))
tdm = TermDocumentMatrix(docs,control = list(removePunctuation = TRUE,stopwords = c("new", "year", stopwords("english")), removeNumbers = TRUE, tolower = TRUE))



trans <- content_transformer(function(x,pattern) gsub(pattern, " " ,x))
docs <- tm_map(docs,content_transform(tolower))
docs <- tm_map(docs,removeWords,stopwords('english'))
docs <- tm_map(docs,removePunctuation)
docs <- tm_map(docs,stripWhitespace)
docs <- tm_map(docs,stemDocument)
docs <- tm_map(docs,trans,"/")
docs <- tm_map(docs,trans,"@")
docs <- tm_map(docs,trans,"]")
docs <- tm_map(docs,trans,"RT")
docs <- tm_map(docs,trans,":")
docs <- tm_map(docs,trans,"[]")
docs <- tm_map(docs,trans,"\\!")

dtm <-TermDocumentMatrix(docs)
mat <- as.matrix(dtm)
v <- sort(rowSums(mat),decreasing=TRUE)

d <- data.frame(word=names(v),freq=v)
head(d,10)


set.seed(1056)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,max.words = 200, random.order = FALSE, rot.per = 0.35,colors = brewer.pal(8, "Dark2"))

sentiment <-get_nrc_sentiment(text)
text <- cbind(text,sentiment)

TotalSentiments <- data.frame(colSums(text[,c(2:11)]))
names(TotalSentiments) <- "count"
TotalSentiments <- cbind("sentiment"= rownames(TotalSentiments), TotalSentiments)
rownames(TotalSentiments) <- NULL


ggplot(data = TotalSentiments, aes(x=sentiment,y=count)) + geom_bar(aes(fill=sentiment),stat = "identity") +
  xlab("sentiment") + ylab("total count") + ggtitle("total sentiment score")
                              