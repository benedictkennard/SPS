# STEP 1 - OBTAIN TICKER AND NAME FOR ALL MUTUAL AND EXCHANGE TRADED FUNDS
setwd("G:/My Documents/Jose/Employment/Mayara")
start = Sys.time(); m = 0                                                            # initiate variables
FundSearch = Ticker = Fund = Family = Issue = Class = URL = character();             # declare variables
a = b = c = d = e = f = g = h = hh = numeric()                                       # declare variables
TickerPattern = '<td class="quotelist-symb"><a href=(.+)</a></td>'                   # HTML pattern for Tickers
NamePattern = '<td class="quotelist-name"><a href=(.+)</a></td>'                     # HTML pattern for Fund Names
for (i in 1:26) {                                                                    # loop through webpages
  pre =  'http://www.marketwatch.com/tools/mutual-fund/list/'                        # prefix for urls
  FundSearch[i] = paste0(pre, letters[i])                                            # urls
  FundLists = FindTickers = FindFunds = character()                                  # declare variables
  FundLists = readLines(FundSearch[i]); unlink(FundSearch[i])                        # Read data from url i
  FindTickers = grep(TickerPattern,FundLists,value=TRUE)                             # Find Tickers
  FindFunds = grep(NamePattern,FundLists,value=TRUE)                                 # Find Fund Names
  v = length(FindTickers)                                                            # vector length of all funds
  if (v != 0) {                                                                      # Check if Tickers found
    n = m + 1; m = n - 1 + v                                                         # Set nested for-loop indexes
    for(j in n:m) {                                                                  # loop through page data
      w = max(v - (m - j), 1)                                                        # Set index for new FindTickers
      a[j] = gregexpr(">",FindTickers[w],TRUE)[[1]][2]+1                             # Ticker Begin position
      b[j] = gregexpr("<",FindTickers[w],TRUE)[[1]][3]-1                             # Ticker End position
      colon = tail(gregexpr(":",FindFunds[w],TRUE)[[1]],n=1)                         # Position of last colon
      semicolon = tail(gregexpr(";",FindFunds[w],TRUE)[[1]],n=1)                     # Position of last semi-colon
      anchor = gregexpr("<",FindFunds[w],TRUE)[[1]][3]                               # Position of last HTML anchor
      c[j] = gregexpr(">",FindFunds[w],TRUE)[[1]][2]+1                               # Fund & Family Begin position
      if (colon != -1) { d[j] = colon - 1                                            # Family End position
                       } else if (semicolon != -1) { d[j] = semicolon - 1            # Family End position
                                                   } else { d[j] = anchor - 1 }      # Family End position
      if (colon == -1) { e[j] = 0 } else { e[j] = colon + 1}                         # Issue Begin position
      if (colon == -1) { f[j] = 0                                                    # Issue End position
                       } else if (semicolon !=- 1) { f[j] = semicolon - 1            # Issue End position
                                                   } else { f[j] = anchor - 1 }      # Issue End position
      if (semicolon == -1) { g[j] = 0 } else { g[j] = semicolon + 1}                 # Class Begin position
      if (semicolon == -1) { h[j] = 0 } else { h[j] = anchor - 1 }                   # Class End position
      if (h[j] == 0) { hh[j] = anchor - 1 } else { hh[j] = h[j] }                    # Fund End position
      rm(colon,semicolon,anchor)                                                     # remove tempvars
      Ticker[j] = substr(FindTickers[w],start=a[j],stop=b[j])                        # Store Tickers
      Fund[j] = gsub("^\\s+|\\s+$|([^[:alnum:]|[:space:]|:|;])", "",                 # Remove spec chr+lead space+trail space
                     substr(FindFunds[w],start=a[j],stop=hh[j]))                     # Store Full fund name
      Family[j] = gsub("^\\s+|\\s+$|([^[:alnum:]|[:space:]])", "",                   # Remove spec chr+lead space+trail space
                       substr(FindFunds[w],start=c[j],stop=d[j]))                    # Store Fund family
      Issue[j] = gsub("^\\s+|\\s+$|([^[:alnum:]|[:space:]])", "",                    # Remove spec chr+lead space+trail space
                      substr(FindFunds[w],start=e[j],stop=f[j]))                     # Store Fund name
      Class[j] = gsub("^\\s+|\\s+$|([^[:alnum:]|[:space:]])","",                     # Remove spec chr+lead space+trail space
                      substr(FindFunds[w],start=g[j],stop=h[j]))                     # Store class of shares)
      if (!is.na(Ticker[j])) { URL[j] = FundSearch[i] } else { URL[j] = NA }         # URL where info obtained
    }
  }
  rm('FundLists','FindTickers','FindFunds')                                          # Free up memory for next iteration
}
AllFunds = data.frame(cbind(Ticker,Fund,Family,Issue,Class,URL))                     # Create Data frame
write.table(AllFunds, "All_Funds.txt", sep="\t", row.names = F)                      # Save as text file
difftime(Sys.time(), start, units = "mins")                                          # Run time
rm(start,TickerPattern,NamePattern,FundSearch,Issue,Class,URL                        # Clean up
   ,pre,a,b,c,d,e,f,g,h,hh,i,j,m,n,v,w,AllFunds)                                     # Clean up
# Fund with special char removed interpreted as years, for example 20/80 as 2080
# Time difference of 90.4651 mins, 5.958737 mins
#-----------------------------------------------------------------------------------------------------------------------------------#
# STEP 2 - OBTAIN TICKERS FOR LIFE CYCLE FUNDS
setwd("G:/My Documents/Jose/Employment/Mayara")
Ticker = as.vector(read.table("All_Funds.txt", header=TRUE, quote="\"")[[1]])
Fund = as.vector(read.table("All_Funds.txt", header=TRUE, quote="\"")[[2]])
Family = as.vector(read.table("All_Funds.txt", header=TRUE, quote="\"")[[3]])
start = Sys.time(); m = 0                                                            # initiate variables
year = as.numeric(format(Sys.Date(), format="%Y"))                                   # current year
TargetDate = FundYear = numeric(); TargetDateFund = TargetDateFamily = character()   # declare variables
for (i in 1:100) {                                                                   # loop through next 100 years
  TargetDate[i] = year + i                                                           # Vector of Years
  v = length(grep(TargetDate[i],Fund))                                               # Vector length of funds with year i
  if (v != 0) {                                                                      # Check if Funds found
    n = m + 1; m = n - 1 + v                                                         # Set nested for-loop indexes
    for(j in n:m) {                                                                  # loop through Tickers data
    w = v - (m - j)                                                                  # Set index for new Tickers
    if (!(w %in% grep(" ETN | Note ",Family[grep(TargetDate[i],Fund)],T))) {         # If Ticker is not for notes
      TargetDateFund[j] = Ticker[grep(TargetDate[i],Fund)][w]                        # Store Tickers
      FundYear[j] = TargetDate[i]                                                    # Note year of fund
      TargetDateFamily[j] = Family[grep(TargetDate[i],Fund)][w]                      # Store Families
      } 
    }
  }
}
TargetDateFund = TargetDateFund[!is.na(TargetDateFund)]                              # Remove NA left by ETN/Note
FundYear = FundYear[!is.na(FundYear)]                                                # Remove NA left by ETN/Note
TargetDateFamily = TargetDateFamily[!is.na(TargetDateFamily)]                        # Remove NA left by ETN/Note
TargetDateFunds = data.frame(cbind(TargetDateFund,FundYear,TargetDateFamily))        # Ticker+Family
write.table(TargetDateFunds, "Target_Date_Funds.txt", sep="\t", row.names = F)       # Save as text file
rm(Ticker,Fund,Family,TargetDate,i,j,m,n,v,w)                                        # Clean up
FundFamily = TargetDateFamily[duplicated(TargetDateFamily,T)==F]                     # Non-dup Fund Families
SearchTicker = TargetDateFund[duplicated(TargetDateFamily,T)==F]                     # Ticker to search
EDGAR = data.frame(cbind(SearchTicker,FundFamily))                                   # Non-dup family
write.table(EDGAR, "EDGAR_Search_Funds.txt", sep="\t", row.names = F)                # Save as text file
difftime(Sys.time(), start, units = "mins")                                          # Run time
rm(TargetDateFund,FundYear,TargetDateFamily,FundFamily,EDGAR,start,year)             # Clean up
# Time difference of 1.199187 mins
# STEP 4 - READ DATA FROM MORNINGSTAR
setwd("G:/My Documents/Jose/Employment/Mayara")
TargetDateFund = as.vector(read.table("Target_Date_Funds.txt", header=TRUE, quote="\"")[[1]])
start = Sys.time(); today = format(Sys.Date(),'%m_%d_%Y')                            # start time and today's date
AA = c("Cash",'US Stock','Non US Stock','Bond','Other')                              # Asset Allocation
MC = c("Giant",'Large','Medium','Small','Micro')                                     # Market Capitalization
CQ = c("AAA",'AA','A','BBB','BB','B','Below B','Not Rated')                          # Credit Quality
ESW = c("Basic Materials",'Consumer Cyclical','Financial Services', 'Real Estate',   # Equity Sector Weightings
        'Communication Services','Energy','Industrials','Technology',                # Equity Sector Weightings
        'Consumer Defensive','Healthcare','Utilities')                               # Equity Sector Weightings
BSW = c('Government','Government-Related','Corporate','Agency Mortgage-Backed',      # Bond Sector Weightings
        'Non-Agency Residential MBS','Commercial MBS','Asset-Backed',                # Bond Sector Weightings
        'Covered Bond','Municipal','Cash & Equivalents')                             # Bond Sector Weightings
CPN = c('0% PIK','0% to 4%','4% to 6%','6% to 8%','8% to 10%','10% to 12%',          # Coupon Range
        'More than 12%')                                                             # Coupon Range
MAT = c('1 to 3 Years','3 to 5 Years','5 to 7 Years','7 to 10 Years',                # Bond Maturity Breakdown
        '10 to 15 Years','15 to 20 Years','20 to 30 Years','Over 30 Years')          # Bond Maturity Breakdown
WR = c('North America','Latin America','United Kingdom','Europe Developed',          # World Regions
       'Europe Emerging','Africa/Middle East','Japan','Australasia',                 # World Regions
       'Asia Developed','Asia Emerging','Developed Markets','Emerging Markets')      # World Regions
FileFields = c('Ticker',AA,MC,CQ,ESW,BSW,CPN,MAT,WR)                                 # fields being read
AApat = paste0('row">',AA,'</th>')                                                   # Asset Allocation
MCpat = paste0('row">',MC,'</th>')                                                   # Market Capitalization
CQpat = paste0('row">',CQ,'</th>')                                                   # Credit Quality
ESWpat = paste0('row_lbl">',ESW,'</th>')                                             # Equity Sector Weightings
BSWpat = paste0('row"(.*)>',BSW,'</th>')                                             # Bond Sector Weightings
CPNpat = paste0('row">',CPN,'</th>')                                                 # Coupon Range
MATpat = paste0('row_lbl">',MAT,'</th>')                                             # Bond Maturity Breakdown
WRpat = paste0('<td>([%]?[^[:alnum:]]?)',WR,'</td>')                                 # World Regions
patterns = c(AApat,MCpat,CQpat,ESWpat,BSWpat,CPNpat,MATpat,WRpat)                    # HTML patterns to look for
rm(AA,AApat,MC,MCpat,CQ,CQpat,ESW,ESWpat,BSW,BSWpat,CPN,CPNpat,MAT,MATpat,WR,WRpat)  # clean up
Data = matrix(nrow=length(TargetDateFund),ncol=length(FileFields))                   # declare data matrix
FilePath = character()                                                               # decalre variables
part1 = 'http://portfolios.morningstar.com/fund/summary?t='                          # Morningstar url
part2 = 'G:/My Documents/Jose/Employment/Mayara/Asset_Allocation/'                   # local file url
part3 = '_MorningStar_'                                                              # local file url
for (i in 1:length(TargetDateFund)) {                                                # loop through funds   
  url = paste0(part1,TargetDateFund[i])                                              # Morningstar url
  FilePath[i] = paste0(part2,TargetDateFund[i],part3,today,'.txt')                   # local file url
# download.file(url,FilePath[i])                                                     # Download and save page
  text = readLines(FilePath[i])                                                      # load page to vector
  Lines = numeric()                                                                  # vector for line numbers
  for (j in 1:length(patterns)) {                                                    # loop through page
    p = grep(patterns[j],text,ignore.case=T,value=F)+1                               # look for pattern i
    if (!(length(p) == 0)) {                                                         # if pattern i exists
      Lines[j] = max(grep(patterns[j],text,ignore.case=T,value=F))+1                 # find lines with pattern i
      text[Lines[j]] = gsub('&mdash;',"0.00",text[Lines[j]])                         # replace &mdash; value with 0
      a = gregexpr(">([-]?[0-9]{1,3}\\.[0-9]{1,2})<",text[Lines[j]],TRUE)[[1]][1]+1  # value Begin position
      b = gregexpr("</td>",text[Lines[j]],TRUE)[[1]][1]-1                            # value end position
      Data[i,1] = TargetDateFund[i]                                                  # save ticker to matrix
      Data[i,j+1] = as.numeric(substr(text[Lines[j]],start=a,stop=b))                # save value to matrix
    } else {                                                                         # if pattern i does not exist
      Data[i,1] = TargetDateFund[i]                                                  # save ticker to matrix
      Data[i,j+1] = 0.00                                                             # save 0 to matrix
    }
  }
  rm(text)                                                                           # free up memory
}
write.table(Data, "Fund_Data.txt", sep="\t", row.names = F, col.names= FileFields)   # Save as text file
difftime(Sys.time(), start, units = "mins")                                          # Run time
rm(FileFields,FilePath,Lines,TargetDateFund,a,b,i,j,p,part1,part2,part3,             # clean up
   patterns,start,today,url)                                                         # clean up
# Time difference of 82.92026 mins full; 32.43626 mins no download (10_19_2014)
# What to do with outliers?  Fund PQRZX_MorningStar_04_27_2015 is highly leveraged and returns an NA
# FundInfo[is.na(FundInfo)] = 0

# Data can also be extracted from SEC filing but it is inconsistent
# some pages list holdings with pics: https://code.google.com/p/tesseract-ocr/
# grep('>(.*)(Schedule|Portfolio|Statement)(s?) of Investments(.*)<'s                # schedule of investments begin
#   filing,ignore.case=T,value=F)                                                    # schedule of investments begin
# grep('>(.*)Total Investment(s?.*)<',filing,ignore.case=T,value=F)                  # End of investment sections
# grep('>(.*)Controls (and|&) Procedures(.*)<',filing,ignore.case=T,value=F)         # schedule of investments end N-Q 
# grep('>(.*)Statement(s?) of Assets and Liabilities(.*)<',                          # schedule of investments end not N-Q
#   filing,ignore.case=T,value=F)                                                    # schedule of investments end not N-Q
# clean = gsub("^\\s+|\\s+$","",x)                                                   # remove trailing/leading white space: 