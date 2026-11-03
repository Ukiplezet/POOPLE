# POOPLE

A daily word-ladder game. Every day you get a 4-letter word. Change one letter at a time, with every step a real 4-letter word, until you reach **POOP**. Fewest steps wins.

https://poople-rho.vercel.app

## How it works

- **Daily word:** one of 558 start words, picked by date. It resets at midnight, Israel time. Every start word reaches POOP in 3–7 steps.
- **Rules:** exactly one letter changes per step, every word must be in the word list (about 3,400 words), and no word can repeat.
- **Par:** the shortest ladder that uses only everyday words. Obscure words are allowed, so you can beat par.
- **Scoreboard:** a daily ranking (fewest steps, then earliest finish) and an all-time ranking (average steps over par). Each player gets one scored run per day.

## Files

| Path | What it is |
|---|---|
| `index.html` | The whole game: one self-contained page |
| `config.js` | Supabase URL and public key for the scoreboard. If left empty, the game runs without a scoreboard |
| `supabase/schema.sql` | Tables, security rules and the `submit_score` function that checks ladders |
| `supabase/seed.sql` | Word list and daily start words for the database (generated) |
| `tools/build_words.py` | Builds the word lists from `wordfreq` and `english-words` |
| `tools/export_seed.py` | Regenerates `supabase/seed.sql` from `index.html` |

## Run locally

Open `index.html` in a browser. There's no build step.

## Deploy

See **[DEPLOY.md](DEPLOY.md)** to set up the Supabase scoreboard and publish the site on GitHub Pages or Vercel.
