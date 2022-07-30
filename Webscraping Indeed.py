#!/usr/bin/env python
# coding: utf-8

# In[46]:


from bs4 import BeautifulSoup
import requests
import time
from collections import defaultdict 
import pandas as pd


# In[21]:


# Skills & Place of Work
job_title = input('Enter job title: ').strip()
location = input('Enter location: ').strip()
pages = int(input('Enter the # of pages to scrape: '))


# In[70]:


indeed_posts=[]

for page in range(no_of_pages):
    
    # Connecting to Indeed
    url = 'https://www.indeed.co.in/jobs?q=' + job_title +         '&l=' + location + '&sort=date' +'&start='+ str(pages * 10)
        
    # Get request to Indeed 
    response = requests.get(url)
    html = response.text

    # Scrapping the Web 
    soup = BeautifulSoup(html, 'lxml')

    # Outer Most Entry Point of HTML:
    outer_most_point=soup.find('div',attrs={'id': 'mosaic-provider-jobcards'})
        
    # "UL" lists where the data are stored:
        
    for i in outer_most_point.find('ul'):
            
        # Job Title:
        
        job=i.find('div',{'class':'job_seen_beacon'})

        if job != None:
            position=job.find('a').text
        
        # Company Name:
        
        if i.find('span',{'class':'companyName'}) != None:
            company=i.find('span',{'class':'companyName'}).text   
    
        # Job Location:
        
        if i.find('div',{'class':'companyLocation'}) != None:
            job_location=i.find('div',{'class':'companyLocation'}).text  
                  
        # Links: these Href links will take us to full job description
        
        if i.find('a') != None:
            links=i.find('a',{'class':'jcs-JobTitle'})['href']

        # Job Post Date:
        
        if i.find('span', attrs={'class': 'date'}) != None:
            post_date = i.find('span', attrs={'class': 'date'}).text
            
        # Put everything together in a list of lists for the default dictionary
                        
        indeed_posts.append([position,company,job_location,post_date,links])


# In[71]:


# put together in list
indeed_dict_list=defaultdict(list)

# Fields for our DF 
indeed_spec=['Position','Company Name','Job Location','Post Date','Links']


# In[72]:


indeed_posts[0:2]


# In[73]:


pd.DataFrame(indeed_posts,columns=indeed_spec)


# In[ ]:





# In[ ]:




