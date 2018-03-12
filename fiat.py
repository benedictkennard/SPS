import bs4, urllib2, time
import pandas as pd
import numpy as np

# Am I allowed to use content (screenshots, data, graphs, etc.) for one of my personal projects and/or commercial use?
# Absolutely! Feel free to use any content as you see fit. We kindly ask that you cite us as a source.
# https://coinmarketcap.com/faq/

# AGGREGATE PAGE
coin_table = []
main_url = "https://coinmarketcap.com/all/views/all/"
main_page = urllib2.urlopen(main_url)
main_soup = bs4.BeautifulSoup(main_page.read())
main_raw_table = main_soup.find('table')
for table_row in main_raw_table.find_all('tr'):
    cells = table_row.find_all('td')
    if len(cells) > 0: # Ignore rows with zero cells
        Name = cells[1].text.strip().split('\n')[1]
        Symbol = cells[2].text.strip()
        Cap = str(cells[3].text.strip())
        Price = cells[4].text.strip()
        Supply = cells[5].text.strip()
        Vol = cells[6].text.strip()
        href = table_row.find_all('a', href=True)[2]['href']
        sub_url = 'https://coinmarketcap.com' + href
        Coin = [Name, Symbol, Cap, Price, Supply, Vol, sub_url]
        coin_table.append(Coin)
coin_df = pd.DataFrame(coin_table, columns=['Name', 'Symbol', 'Cap', 'Price', 'Supply', 'Vol', 'URL'])
coin_df.iloc[:,2:6] = coin_df.iloc[:,2:6].replace('[^\w\d\.]|\s', '', regex=True).convert_objects(convert_numeric=True)

# INDIVIDUAL PAGES
temp_table, market_table = ([], [])
for i in range(0, len(coin_df)):
# for i in range(0, 0 + 3):
    time.sleep(np.random.uniform(low=0, high=3, size=1))
    sub_url = coin_df.iloc[i, 6]
    sub_page = urllib2.urlopen(sub_url)
    sub_soup = bs4.BeautifulSoup(sub_page.read())
    sub_raw_table = sub_soup.find('table')
    if sub_raw_table is None:
        Coin = coin_df.iloc[i, 0]
        message = "No info for: " + Coin
        print(message)
        continue
    for table_row in sub_raw_table.find_all('tr')[1:]:
        cells = table_row.find_all('td')
        if len(cells) > 0:  # Ignore rows with zero cells
            Coin = coin_df.iloc[i, 0]
            Source = cells[1].text.strip()
            Quote = cells[2].text.strip().split('/')[0]
            Base = cells[2].text.strip().split('/')[1]
            Quote_Fiat = not any(coin_df.Symbol == Quote)
            base_Fiat = not any(coin_df.Symbol == Base)
            Fiat = Quote_Fiat or base_Fiat
            Vol = str(cells[3].text.strip())
            Price = cells[4].text.strip()
            market = [Coin, Source, Quote, Base, Fiat, Vol, Price]
            market_table.append(market)
market_df = pd.DataFrame(market_table, columns=['Coin', 'Source', 'Quote', 'Base', 'Fiat','Vol', 'Price'])
market_df.iloc[:,5:] = market_df.iloc[:,5:].replace('[^\w\d\.]|\s', '', regex=True).convert_objects(convert_numeric=True)
market_df["Duplicate"] = market_df.iloc[:,1:4].duplicated()

# BREAKDOWN COMPARISON
total_dup = coin_df.Vol.sum()
fiat_dup = market_df.Vol[market_df.Fiat == True].sum()
fiat_unq = market_df.Vol[(market_df.Fiat == True) & (market_df.Duplicate == False)].sum()
comm_dup = market_df.Vol[market_df.Fiat == False].sum()
comm_unq = market_df.Vol[(market_df.Fiat == False) & (market_df.Duplicate == False)].sum()
total_unq = fiat_unq + comm_unq
unique = [fiat_unq, comm_unq, total_unq]
duplicate = [fiat_dup, comm_dup, total_dup]
compare_df = pd.DataFrame([unique, duplicate], index=['Unique', 'Duplicates'], columns=['Fiat', 'Commodity', 'Total'])

# OUTPUT FILE
timestr = time.strftime("%Y%m%d%H%M%S")
file = 'M:\\Data Operations\\DSR\\' + timestr + '_CoinMarketCap.xlsx'
writer = pd.ExcelWriter(file)
compare_df.to_excel(writer,'Summary')
coin_df.iloc[:,0:6].to_excel(writer,'Coins', index=False)
market_df.to_excel(writer,'Markets', index=False)
writer.save()