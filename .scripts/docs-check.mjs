#!/usr/bin/env node
//
// docs-check: the onboarding documents have to tell one story.
//
// Four of them drifted apart (README sent people to a terminal, Welcome.md told them to run
// /init-bootstrap, CLAUDE.md forbade telling them to run anything, START HERE.md described the
// app) because nothing compared them. This compares them.
//
//   node .scripts/docs-check.mjs        or        pnpm docs:check
//
// What it enforces:
//   1. The onboarding files exist, and a fresh copy still has FIRST_RUN so it introduces itself.
//   2. No onboarding file tells the reader to run a command as a first step. Terminal
//      instructions are allowed only below an explicit <!-- docs-check: allow-commands --> marker.
//   3. Every reader-facing door either shows the canonical five steps or points at START HERE.md.
//   4. The retired setup wizard is not referenced anywhere outside the changelog.

import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";
import { execSync } from "node:child_process";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const ALLOW_MARKER = "<!-- docs-check: allow-commands -->";

// Files a person reads before they have done anything.
const ONBOARDING = ["README.md", "START HERE.md", "00_Inbox/Welcome.md", "CLAUDE.md"];

// Reader-facing doors. CLAUDE.md is excluded: it is addressed to Iris, not to the reader.
const DOORS = ["README.md", "START HERE.md", "00_Inbox/Welcome.md"];

// First tokens that mean "this line is a shell command."
const SHELL = /^(git|npm|pnpm|npx|yarn|node|claude|brew|curl|wget|sh|bash|zsh|chmod|cd|\.\/|source|export)\b/;

// Verbs that turn a mention into an instruction.
const IMPERATIVE = /\b(run|type|execute|paste|enter)\b/i;

const failures = [];
const fail = (file, line, message) =>
  failures.push(`${file}${line ? `:${line}` : ""}  ${message}`);

// --- 1. the files exist -----------------------------------------------------

for (const rel of ONBOARDING) {
  if (!existsSync(join(ROOT, rel))) fail(rel, 0, "onboarding file is missing");
}
const claudeMd = existsSync(join(ROOT, "CLAUDE.md"))
  ? readFileSync(join(ROOT, "CLAUDE.md"), "utf8")
  : "";
if (!/^## FIRST RUN/m.test(claudeMd)) {
  fail("CLAUDE.md", 0, "has no '## FIRST RUN' heading, so a fresh copy will not introduce itself");
}
if (existsSync(join(ROOT, "FIRST_RUN"))) {
  fail("FIRST_RUN", 0, "sentinel file is back; CLAUDE.md's '## FIRST RUN' heading is the only setup signal");
}
const settingsPath = join(ROOT, ".claude/settings.json");
if (existsSync(settingsPath)) {
  const settings = JSON.parse(readFileSync(settingsPath, "utf8"));
  if (settings.permissions?.defaultMode !== "acceptEdits") {
    fail(".claude/settings.json", 0, "permissions.defaultMode is not 'acceptEdits'; a first session starts in Manual and prompts on every write");
  }
  const hook = JSON.stringify(settings.hooks ?? {});
  if (hook.includes("FIRST_RUN")) {
    fail(".claude/settings.json", 0, "SessionStart hook still keys off the FIRST_RUN file instead of the CLAUDE.md heading");
  }
}
if (failures.length) report();

// --- 2. no command as a first step ------------------------------------------

for (const rel of ONBOARDING) {
  const text = readFileSync(join(ROOT, rel), "utf8");
  const lines = text.split("\n");
  const markerIndex = lines.findIndex((l) => l.includes(ALLOW_MARKER));
  const region = markerIndex === -1 ? lines : lines.slice(0, markerIndex);

  let inFence = false;
  region.forEach((line, i) => {
    const n = i + 1;

    if (/^\s*```/.test(line)) {
      inFence = !inFence;
      return;
    }

    if (inFence) {
      if (SHELL.test(line.trim())) {
        fail(rel, n, `first-step code block runs a command: "${line.trim()}"`);
      }
      return;
    }

    for (const [, code] of line.matchAll(/`([^`]+)`/g)) {
      const token = code.trim();
      if (/^\/[a-z][a-z0-9-]*$/.test(token) && IMPERATIVE.test(line)) {
        fail(rel, n, `tells the reader to run the slash command ${token}`);
      }
      if (SHELL.test(token) && IMPERATIVE.test(line)) {
        fail(rel, n, `tells the reader to run "${token}"`);
      }
    }
  });
}

// --- 3. the doors agree ------------------------------------------------------

for (const rel of DOORS) {
  const text = readFileSync(join(ROOT, rel), "utf8");
  const showsTheSteps = /Select folder/i.test(text) && /say \*{0,2}hi/i.test(text);
  const pointsAtStartHere = /START HERE\.md/.test(text);
  if (!showsTheSteps && !pointsAtStartHere) {
    fail(rel, 0, "neither shows the five steps (Code tab, Select folder, say hi) nor points at START HERE.md");
  }
}

// --- 4. the retired wizard stays retired -------------------------------------

const RETIRED = ["init-bootstrap", "IRIS-BOOTSTRAP.md"];
const EXEMPT = /^(CHANGELOG\.md|\.scripts\/docs-check\.mjs)$/;
let tracked = [];
try {
  tracked = execSync("git ls-files", { cwd: ROOT, encoding: "utf8" }).trim().split("\n");
} catch {
  tracked = [];
}
for (const rel of tracked) {
  if (!rel || EXEMPT.test(rel)) continue;
  if (!/\.(md|json|sh|mjs|js)$/.test(rel)) continue;
  const full = join(ROOT, rel);
  if (!existsSync(full)) continue;
  const lines = readFileSync(full, "utf8").split("\n");
  lines.forEach((line, i) => {
    for (const term of RETIRED) {
      if (line.includes(term)) {
        fail(rel, i + 1, `references the retired setup wizard (${term})`);
      }
    }
  });
}

report();

function report() {
  if (failures.length === 0) {
    console.log("docs:check  onboarding docs agree: download, unzip, open in the Claude app, say hi.");
    process.exit(0);
  }
  console.error("docs:check FAILED\n");
  for (const f of failures) console.error("  " + f);
  console.error(
    "\nThe onboarding story is: download, unzip, open the folder in the Claude app, say hi." +
      `\nTerminal instructions belong below a ${ALLOW_MARKER} marker.`
  );
  process.exit(1);
}
