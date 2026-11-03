# POOPLE

A daily word-ladder game. Every day you get a 4-letter word. Change one letter at a time — every step must be a real 4-letter word — until you reach **POOP**. Fewest steps wins.

## How it works

- **Daily word:** one of 558 start words, picked by date (resets at midnight, Asia/Jerusalem). Every start word reaches POOP in 3–7 steps.
- **Rules:** exactly one letter changes per step, the word must be in the word list (~3,400 words), and no word can repeat.
- **Par:** the shortest ladder using only everyday words (computed in the browser with a breadth-first search).
- **Scoreboard:** the hosted claude.ai version keeps a shared daily and all-time scoreboard. When `index.html` is opened on its own, the game works fully, but the scoreboard is unavailable.

## Run locally

Open `index.html` in a browser. It is a single self-contained file with no build step.
