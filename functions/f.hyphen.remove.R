#'## f.hyphen.remove: Remove Hyphenation across Linebreaks
#' Hyphenation spanning linebreaks is a serious issue for longer texts. Hyphenated words are often not recognized as a single token by standard tokenization. The result is two mostly non-expressive and unique tokens instead of a single and expressive token. The function removes linebreaking hyphenations. It does not attempt to cover hyphenation spanning pagebreaks, as there is often confounding header/footer/footnote text in extracted text from PDFs which needs to be uniquely processed for specific corpora.
#'
#' The first REGEX matches regular hyphenation of words. The second REGEX matches compounds (e.g. SARS-CoV-2) broken across lines.


#'@param text A character vector of text.


#  test <- "Ham-\nburg Mei-\n   nungsäußerung SARS-CoV-\n2  hat-    2\nte  Unsterb-    6\nliche  hat-  \n  2 te, Unsterb-  \n  6 liche"



f.hyphen.remove <- function(text){
    ## Examples: Ham-\nburg, Mei-\n   nungsäußerung
    text.out <- gsub("([a-zöäüß])-[[:blank:]]*\n[[:blank:]]*([a-zöäüß])",
                     "\\1\\2",
                     text)
    ## Examples: SARS-CoV-\n2
    text.out <- gsub("([a-zA-ZöäüÖÄÜß])-[[:blank:]]*\n[[:blank:]]*([A-Z0-9ÖÄÜß])",
                     "\\1-\\2",
                     text.out)
    ## Example: hat-    2\nte, Unsterb-    6\nliche
    text.out <- gsub("([a-zöäüß])-[[:blank:]]*[0-9]+[[:blank:]]*\n[[:blank:]]*([a-zöäüß])",
                     "\\1\\2",
                     text.out)
    
    ## Example: hat-  \n  2 te, Unsterb-  \n  6 liche
    text.out <- gsub("([a-zöäüß])-[[:space:]]*[0-9]+[[:blank:]]*([a-zöäüß])",
                     "\\1\\2",
                     text.out)
    
    return(text.out)
}
