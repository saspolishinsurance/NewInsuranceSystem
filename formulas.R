library(stringi)

str <- "519685455"

dl <- stri_length(str)

t1 <- Sys.time()
vv <- expand.grid(rep(list(c("+", "-", "*", "/", "")), (dl-2)), stringsAsFactors = FALSE)
dry <- sapply(1:(dl-1), function(q) {
    if (q == 1)
        vv2 <- cbind("==", vv)
    else if (q == (dl-1))
        vv2 <- cbind(vv, "==")
    else
        vv2 <- cbind(vv[,1:(q-1)], "==", vv[,q:(dl-2)])
        
    names(vv2) <- stri_c("Q", 1:(dl-1))
    qq <- stri_c(
        stri_sub(str, from = 1, length = 1),
        vv2$Q1,
        stri_sub(str, from = 2, length = 1),
        vv2$Q2,
        stri_sub(str, from = 3, length = 1),
        vv2$Q3,
        stri_sub(str, from = 4, length = 1),
        vv2$Q4,
        stri_sub(str, from = 5, length = 1),
        vv2$Q5,
        stri_sub(str, from = 6, length = 1),
        vv2$Q6,
        stri_sub(str, from = 7, length = 1),
        vv2$Q7,
        stri_sub(str, from = 8, length = 1),
        vv2$Q8,
        stri_sub(str, from = 9, length = 1)
    )
    dd <- sapply(qq, function(x) ifelse(eval(parse(text=x)), x, NA) )
    return(dd[!is.na(dd)])
})
wyniczek <- unlist(dry)
length(wyniczek)
names(wyniczek) <- NULL
wyniczek
t2 <- Sys.time()
(t2-t1)


writeLines(wyniczek, "C:/MB/PR_tel.txt")
min(stri_length(wyniczek))
