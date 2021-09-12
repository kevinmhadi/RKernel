#' @export
View <- function(x,title) UseMethod("View")


# str_ <- function(nm,envir) chartr(r"(\)",r"(\\)",
#           trimws(capture.output(str(get(nm,envir)))))


str_ <- function(nm,envir) htmlEscape(trimws(capture.output(str(get(nm,envir)))))

#' @export
ls_str <- function(pos = -1, name, envir, all.names = FALSE, pattern, 
    mode = "any"){
    if (missing(envir)) 
        envir <- as.environment(pos)
    nms <- ls(name, envir = envir, all.names = all.names, pattern = pattern)
    r <- vapply(nms, exists, NA, envir = envir, mode = mode, 
        inherits = FALSE)
    nms <- nms[r]
    res <- matrix("",ncol=2,nrow=length(nms))
    res[,1] <- nms
    str_nms <- sapply(nms,str_,envir=envir)
    res[,2] <- sapply(str_nms,"[",1)
    colnames(res) <- c("Object","Structure")
    data_table(res,use.rownames=FALSE,paging=FALSE,expand=TRUE,ordering=nrow(res) > 1,
               info=FALSE,
               html_class="cell-border tab-left-aligned",
               wrap_cells=c("<code>","</code>"))
}

#' @export
View.default <- function(x,title){
    scrolling_table(x)
}