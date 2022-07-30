#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# Automate Crypto Website API Pull


# In[2]:


from requests import Request, Session
from requests.exceptions import ConnectionError, Timeout, TooManyRedirects
import json

url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
parameters = {
  'start':'1',
  'limit':'15',
  'convert':'USD'
}
headers = {
  'Accepts': 'application/json',
  'X-CMC_PRO_API_KEY': 'f7562bb4-0e1d-473d-8ecb-6a68f85d24f7',
}

session = Session()
session.headers.update(headers)

try:
  response = session.get(url, params=parameters)
  data = json.loads(response.text)
  print(data)
except (ConnectionError, Timeout, TooManyRedirects) as e:
  print(e)


# In[3]:


type(data)


# In[4]:


import pandas as pd

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)


# In[5]:


#Put data in dataframe

df = pd.json_normalize(data['data'])
df['timestamp'] = pd.to_datetime('now')
df


# In[24]:


def api_runner():
    global df
    url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest' 
    
    parameters = {
      'start':'1',
      'limit':'15',
      'convert':'USD'
    }
    headers = {
      'Accepts': 'application/json',
      'X-CMC_PRO_API_KEY': '0ad53085-1cb2-4eb8-ad9e-3ffbd7e56509',
    }

    session = Session()
    session.headers.update(headers)

    try:
      response = session.get(url, params=parameters)
      data = json.loads(response.text)
      #print(data)
    except (ConnectionError, Timeout, TooManyRedirects) as e:
      print(e)

    # Create a csv and append data to it
    df = pd.json_normalize(data['data'])
    df['timestamp'] = pd.to_datetime('now')
    df

    if not os.path.isfile(r'C:/Users/alpin/OneDrive/Desktop/api.csv'):
        df.to_csv(r'C:/Users/alpin/OneDrive/Desktop/api.csv', header='column_names')
    else:
        df.to_csv(r'C:/Users/alpin/OneDrive/Desktop/api.csv', mode='a', header=False)


# In[27]:


df2 = pd.read_csv(r'C:/Users/alpin/OneDrive/Desktop/api.csv')
df2


# In[25]:


import os 
from time import time
from time import sleep

for i in range(333):
    api_runner()
    print('API Runner completed')
    sleep(60) #sleep for 1 minute
exit()


# In[28]:


# Look at the coin trends over time

df3 = df.groupby('name', sort=False)[['quote.USD.percent_change_1h','quote.USD.percent_change_24h','quote.USD.percent_change_7d','quote.USD.percent_change_30d','quote.USD.percent_change_60d','quote.USD.percent_change_90d']].mean()
df3


# In[35]:


df3 = df3.stack()
df3


# In[36]:


type(df3)


# In[37]:


df3 = df3.to_frame(name='values')
df3


# In[38]:


df3 = df3.reset_index()
df3


# In[39]:


# Change the column name

df3 = df3.rename(columns={'level_1': 'percent_change'})
df3


# In[41]:


df3['percent_change'] = df3['percent_change'].replace(['quote.USD.percent_change_1h','quote.USD.percent_change_24h','quote.USD.percent_change_7d','quote.USD.percent_change_30d','quote.USD.percent_change_60d','quote.USD.percent_change_90d'],['1h','24h','7d','30d','60d','90d'])
df3


# In[42]:


import seaborn as sns
import matplotlib.pyplot as plt

sns.catplot(x='percent_change', y='values', hue='name', data=df3, kind='point')


# In[51]:


# Create a dataframe with only the coins we're interested

df4 = df2[['name','quote.USD.price','timestamp']]
df4 = df4.query("name == 'Bitcoin'")
df4


# In[55]:


df4['timestamp'] = df4['timestamp'].str.slice(0, 20)


# In[56]:


sns.set_theme(style="darkgrid")

sns.lineplot(x='timestamp', y='quote.USD.price', data = df4)


# In[ ]:




