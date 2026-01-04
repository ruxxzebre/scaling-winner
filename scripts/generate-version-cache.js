const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// Prevent recursion when we push from within the hook
if (process.env.VERSION_CACHE_RUNNING) {
  process.exit(0);
}

function git(cmd, opts = {}) {
  try {
    return execSync(`git ${cmd}`, { encoding: "utf8", ...opts }).trim();
  } catch {
    return null;
  }
}

const hash = git("rev-parse --short HEAD") || "initial";
const msg = git("log -1 --format=%s") || "Initial commit";
const date = git("log -1 --format=%ci") || new Date().toISOString();
const now = new Date().toISOString().replace("T", " ").slice(0, 19);

const cache = {
  version: hash,
  commit: msg,
  date: date,
  cached_at: now,
};

const cachePath = path.join(__dirname, "..", "mods", "ModpackUpdater", "version_cache.json");
fs.mkdirSync(path.dirname(cachePath), { recursive: true });

const oldContent = fs.existsSync(cachePath) ? fs.readFileSync(cachePath, "utf8") : "";
const newContent = JSON.stringify(cache, null, 2) + "\n";

if (oldContent !== newContent) {
  fs.writeFileSync(cachePath, newContent);
  execSync("git add mods/ModpackUpdater/version_cache.json");
  execSync('git commit -m "update version_cache"');
  console.log("Created version_cache commit:", hash);

  // Push with the new commit, skip hooks to prevent recursion
  execSync("git push", {
    env: { ...process.env, VERSION_CACHE_RUNNING: "1" },
    stdio: "inherit"
  });

  // Exit with error to abort original push (we already pushed)
  process.exit(1);
}