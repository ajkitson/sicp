; Give a scenario where the deadlock-avoidance mechanism described above does not work. (Hint: In the exchange problem, each process knows 
; in advance which accounts it will need to get access to. Consider a situation where a process must get access to some shared resources 
; before it can know hich additional shared resources it will require.)
; =======
; The hint is helpful. And it's not just that the updating process cannot know before accessing the resource, but that the updating process
; must access the resource in order to know. 
; 
; We can come up with some contrived examples. Sticking with the accounts, suppose we have a procedre that will exchange account a with 
; the account whose number matches the balance in account a. Far-fetched, sure, but in this case, we must get the balance of account a
; and exchange it with whatever account that matches the balance. If the account we're exchanging with is undergoing the same procedure
; and happens to have a balance that matches the number for account a, we could have deadlock if the timing is right, or, er, wrong.
;
; Or maybe you have a system for trading stocks. Your clients can set up trades to take place when a stock hits certain prices. Trading
; a stock means finding another client with a pre-configured trade to match. This means you need a procedure to get the stock price, 
; check for trades it should perform, and find a trading partner, and then effectuate the trade, all without allowing any other process
; to touch the price or trading configuration. In this case, we don't know who your trading partner will be when we execute the 
; pre-configured trade. If your trading partner is set up so that they automatically initiate a trade with you, then we could enter 
; deadlock.