// Scoreboard settings, from Supabase (Connect button, or Settings -> API Keys).
// The publishable key is meant to be public; row level security and the
// submit_score() function in supabase/schema.sql protect the data.
// Never put an sb_secret_ / service_role key here.
// Leave both empty to run POOPLE without a scoreboard.
window.POOPLE_CONFIG = {
  supabaseUrl: "https://lstzxrgdsqntofhxskta.supabase.co",
  supabaseAnonKey: "sb_publishable_IfNVerHI5QxZ5ICLFT_bSg_fyAFgn2X",
};
