# lee-ready_algorithm_TAQ
Code that indexes trades and runs Lee-Ready algorithm for CVS stock'S trade and quote TAQ data.  

Results:
The fraction of trades print (a) below the bid, (b) at the bid, (c) in between the bid and ask, (d) at the ask, and (e) above the ask.  
a. 0.005376344  
b. 0.293450635  
c. 0.404203324  
d. 0.326001955  
e. 0.015542522  
There are a small, but non-zero, percentages of trades in categories a and e.  

I assigned trades above the midpoint as buy and trades below the midpoint as sell. The tie breaker for equals is assign whatever type preceded it. More trades happen following momentum (same direction) than going opposite to it.
Same Direction: 0.7826002
Opposite Direction: 0.2173021
