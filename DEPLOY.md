# Deploying POOPLE

POOPLE is one static page (`index.html` + `config.js`). The scoreboard lives in a free Supabase project. Setup takes about 10 minutes.

## How the scoreboard works

- Each browser signs in to Supabase **anonymously**. Players don't create an account, and each device gets its own player id.
- Scores are written only through the `submit_score` database function. It checks the ladder against the real puzzle: today's start word (or yesterday's, for games that end after midnight), one letter changed per step, every word in the list, no repeats, and ending at POOP. Faked scores are rejected.
- Each player can score once per day. The first finish counts.
- Anyone can read the scoreboard.

## 1. Create the database

1. Sign in at [supabase.com](https://supabase.com) and click **New project**. Any name and region work; Frankfurt (eu-central-1) is closest to Israel. Save the database password somewhere safe. You won't need it below.
2. Wait for the project to finish setting up (about 1–2 minutes).
3. Go to **Authentication → Sign In / Providers** (on older dashboards, **Authentication → Providers**). Turn on **Allow anonymous sign-ins** and save.
4. Go to **SQL Editor → New query**. Paste all of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**.
5. Open another new query. Paste all of [`supabase/seed.sql`](supabase/seed.sql) and click **Run**. This loads the 3,380 accepted words and the 558 daily start words.
6. Check that it worked: in **Table Editor**, `words` should have 3380 rows and `start_words` should have 558.

## 2. Connect the game to the database

1. In Supabase, open **Project Settings → API** (on newer dashboards, **API Keys**).
2. Copy the **Project URL** and the **anon public** key. On newer dashboards the anon key is under the **Legacy API keys** tab. The newer *publishable* key also works.
3. Paste both into [`config.js`](config.js):

   ```js
   window.POOPLE_CONFIG = {
     supabaseUrl: "https://YOUR-PROJECT.supabase.co",
     supabaseAnonKey: "eyJhbGciOi...",
   };
   ```

   This key is safe to commit. It is designed to be public, and the database rules decide what it can do. **Never** put the `service_role` or secret key in this file.
4. Commit and push:

   ```bash
   git add config.js
   git commit -m "Connect scoreboard"
   git push
   ```

## 3. Put the site online

Pick one option.

### Option A: GitHub Pages (simplest)

1. On GitHub, open the repo's **Settings → Pages**.
2. Under **Build and deployment**, set **Source** to *Deploy from a branch*, choose **main** and **/ (root)**, and click **Save**.
3. After about a minute the game is live at **https://ukiplezet.github.io/POOPLE/**. Every later push to `main` redeploys it automatically.

### Option B: Vercel

1. At [vercel.com/new](https://vercel.com/new), import **Ukiplezet/POOPLE**.
2. Set **Framework Preset** to *Other*. Leave the build command and output directory empty.
3. Click **Deploy**. You get a `*.vercel.app` address, and every push to `main` redeploys it.

## 4. Test it

1. Open the live site, solve today's ladder, enter a name and click **Post score**. Your row should appear under **Today**.
2. In Supabase, open **Table Editor → scores**. Your row should be there.
3. Open the site in a private window. It counts as a new player, so you can check that a second score shows up.

## Troubleshooting

| What you see | Fix |
|---|---|
| "The scoreboard isn't connected on this copy of POOPLE" | `config.js` is still empty, or the deployed site has an old copy. Fill it in and push. |
| "Anonymous sign-ins are disabled" | Turn on anonymous sign-ins (step 1.3). |
| "relation public.scores does not exist" or "Could not find the function" | `schema.sql` didn't run. Run it again; it's safe to re-run. |
| "The ladder must go from X to poop" for a correct game | `seed.sql` is missing or out of date. Run it again. |
| "That puzzle is closed" | The game was started more than a day ago. Reload for today's word. |

## Maintenance

- **Remove a score:** in **Table Editor → scores**, delete the row.
- **Reset the scoreboard:** run `truncate public.scores;` in the SQL editor.
- **Change the word lists:** edit the lists in `index.html`, run `python3 tools/export_seed.py`, then run the new `supabase/seed.sql` in the SQL editor. Keep the start date (`2026-11-03`) the same in `index.html` and `schema.sql`, because both use it to pick the day's word.
- **Abuse limits:** Supabase limits anonymous sign-ins per IP address by default (**Authentication → Rate Limits**). If bots become a problem, turn on CAPTCHA under **Authentication → Attack Protection**.
