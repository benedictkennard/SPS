# http://www.bls.gov/developers/api_signature_v2.htm
# http://www.bls.gov/data/
# http://www.bls.gov/ggs/#data

library(blsAPI)
library(dplyr)
library(tidyr)

BLS_Products <- read.csv(paste0("https://raw.githubusercontent.com/jzuniga123/SPS/master/",
                                "DATA%20607/BLS_Products.csv"), stringsAsFactors = F)
# View(BLS_Products)
BLS_Products <- BLS_Products %>% filter(SIC_BASIS !=1 & HISTORIC !=1)
# BLS_Products[ ,"ID_EXAMPLE"]
BLS_Products %>% select(2)
payload <- list('seriesid' = BLS_Products[ ,"ID_EXAMPLE"])
Sample_Data <- blsAPI(payload, api.version = 1, return.data.frame = T)



length(blsAPI(BLS_Products[ 1,3]))

BLS_Products[ c(9:11,13:16),3]

payload <- list('seriesid' = BLS_Products[ ,"ID_EXAMPLE"],
               'registrationKey' = 'bb016a4cc84c4212bf47c3c56434f385')
payload[[2]][1]
# Sample_Data <- blsAPI(payload, api.version = 2, return.data.frame = T)

for (i in 1:30) {
  payload <- list('seriesid' = BLS_Products[ i,"ID_EXAMPLE"],
                  'registrationKey' = 'bb016a4cc84c4212bf47c3c56434f385')  
  x <- blsAPI(payload, api.version = 2, return.data.frame = T)
  y <- data.frame(NO = i, SERIES = BLS_Products[ i, 2],
                 ID_EXAMPLE = BLS_Products[ i, 3], ROWS = nrow(x))
  print(y)
}
