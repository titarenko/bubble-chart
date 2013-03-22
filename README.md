Bubble Chart
============

Not so long ago, I spotted great library [D3](http://d3js.org/) for data visualization, then after looking at examples, I got to NYT page with fantastic interactive bubble chart ([At the National Conventions, the Words They Used](http://www.nytimes.com/interactive/2012/09/06/us/politics/convention-word-counts.html?_r=0)). 

That was awesome, so I started search for articles describing implementation experience. The search showed nice article by Jim Vallandingham [Building a Bubble Cloud](http://vallandingham.me/building_a_bubble_cloud.html) and I started looking at the implementation proposed. Essentially it was not intended to build the same interactive page, but what was offered completely satisfied me and I decided to use it in my pet project for easy-to-do keyword extraction, which I hope will be released shortly. 

Returning to the subject, while I managed to use the initial code in prototype just perfectly, but when preparing first beta, I decided to do some refactoring, since, as for me, SRP was broken there. The results of that refactoring are here - `bubble-chart.iced`. Please note, that some functionality mentioned in original article is missing, since other parts of application are assumed to provide it.
