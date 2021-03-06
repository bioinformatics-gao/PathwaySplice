#' LRtestBias
#'
#' Logistic regression to check bias
#'
#' @param jscs_genewise_object gene based table returned
#' from ReformatData and MakeGeneWiseTable_JunctionSeq
#' @param genewise.pvalue whether you use smallest p value or geneWisePadj
#' @param sig.threshold threshold to define differential gene list
#' @param type whether you are interested in exon or splicing junction
#' @param p.x x coordinate for p value label 
#' @param p.y y coordinate for p value label
#' @param boxplot_width parameter for boxplot width
#'
#' @return return results from logistic regression
#' @export
#'
#' @examples
#'
#' data(mds11)
#' mds33<-mds.11.sample[which(as.numeric(mds.11.sample$numExons)<=50),]
#' re<-LRtestBias(mds33,p.x=2,p.y=70,y_lim=80,boxplot_width=0.3)
#' 
#' 
LRtestBias <- function(jscs_genewise_object, genewise.pvalue = "geneWisePadj", 
    sig.threshold = 0.05, type = c("exon","splicing"),p.x,p.y,y_lim,boxplot_width) {
    mydata <- jscs_genewise_object
    
    n.gene <- dim(mydata)[1]
    
    DE.out <- rep(0, n.gene)
    
    if (genewise.pvalue == "geneWisePadj") {
        de.index <- which(mydata$geneWisePadj < sig.threshold)
    }
    
    DE.out[de.index] <- 1
    
    mydata.2 <- cbind(mydata, DE.out)
    
    par(mfrow = c(1, 1))
    
    mydata.3 <- mydata.2
    
    mydata.3[which(mydata.3$DE.out == 1), ]$DE.out <- "Differential genes"
    
    mydata.3[which(mydata.3$DE.out == 0), ]$DE.out <- "Non-differential genes"
    
    if (type == "splicing") {
        mylogit.2 <- glm(DE.out ~ as.numeric(numKnown), data = mydata.2, 
            family = "binomial")
        re <- summary(mylogit.2)
        
        pvalue <- re$coefficients[2, 4]
    } else {
        mylogit.2 <- glm(DE.out ~ as.numeric(numExons), data = mydata.2, 
            family = "binomial")
        re <- summary(mylogit.2)
        pvalue <- re$coefficients[2, 4]
    }
    
    boxplot(unlist(mydata.3[, c(10, 18)]$numExons) ~ unlist(mydata.3[, 
        c(10, 18)]$DE.out), boxwex=boxplot_width,ylab = "Number of exons", col = "lightgray",ylim=c(1,y_lim))
    
    text(x = p.x, y = p.y, labels = c("", paste0("p value from logistic regression:\n\n", 
        pvalue)), col = c(NA, "black"))
    
    re <- mydata.2
    
    return(re)
    
}