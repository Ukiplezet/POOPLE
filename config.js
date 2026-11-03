// Scoreboard settings. Fill these in from Supabase: Project Settings -> API.
// The anon (public) key is meant to be public; row level security and the
// submit_score() function in supabase/schema.sql protect the data.
// Leave both empty to run POOPLE without a scoreboard.
window.POOPLE_CONFIG = {
  supabaseUrl: "",     // e.g. "https://abcdefghijkl.supabase.co"
  supabaseAnonKey: "", // the long "anon public" key
};
