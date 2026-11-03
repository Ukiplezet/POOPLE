import json, random, collections
from wordfreq import zipf_frequency, top_n_list
from english_words import get_english_words_set
loose = get_english_words_set(['web2'], lower=True) | get_english_words_set(['gcide'], lower=True)
strict = get_english_words_set(['web2'], lower=False)
cands = {w for w in top_n_list('en', 300000) if len(w)==4 and w.isalpha() and w.isascii()}
valid = sorted(w for w in cands if w in loose and zipf_frequency(w,'en')>=2.0)
V=set(valid); print(len(valid))
def nb(w):
    for i in range(4):
        for c in 'abcdefghijklmnopqrstuvwxyz':
            if c!=w[i]:
                x=w[:i]+c+w[i+1:]
                if x in V: yield x
# par computed only through strict common words would be unfair; use full valid graph
dist={'poop':0}; q=collections.deque(['poop'])
while q:
    w=q.popleft()
    for x in nb(w):
        if x not in dist: dist[x]=dist[w]+1; q.append(x)
print(collections.Counter(dist.values()))
BAD=set('arab jews homo dyke spic fags paki slut twat cunt damn hell gook kike wops coon tits porn rape kill dead gays nazi shit fuck piss crap alan carl brad kyle york eric hong jake jane josh june kent khan lucy luke marc mary mike nick pete rick ross ruth sept shaw tony cole dean earl hart jean dont cant wont nope yeah coke drug dogs sons tops lots does thee thou heck dude dick cock anal sexy suck nude'.split())
starts=[w for w in valid if w in strict and w not in BAD and zipf_frequency(w,'en')>=4.0 and 3<=dist.get(w,99)<=6]
print(len(starts), collections.Counter(dist[w] for w in starts))
random.seed(4242); random.shuffle(starts)
json.dump({'valid':valid,'starts':starts,'par':[dist[w] for w in starts]}, open('data.json','w'), separators=(',',':'))
print(starts[:20])
