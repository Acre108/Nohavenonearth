#!/usr/bin/env node
// Runs the shared test vectors (tabletop/vectors/*.json) against the combat sandbox's own rules code in node.
// Usage: node tabletop/sandbox/run_vectors.js [path/to/combat-sandbox.html] [-v]
//
// Each attack case becomes a tiny two-unit world on an empty map: frames, pilots and (except for the catalogue
// cases, which use the page's own weapon) a weapon whose totals are the case's. The page's functions then do the
// work: forecast() for forecasts, rollAttack() with the scripted dice for dice.json, lockInfo() and rollAttack() for
// locks, protoRoll() and useProtocol() for Protocols and Purges, stat() for stat totals, taskTarget() for task checks.
// Cover comes from terrain in the defender's hex (light 1, heavy 2), a lock of `none` from a Jam effect, a given lock
// from opts.locked, planted from a braced attacker that did not move, a full move from a Ground Move of the
// defender's whole Move.
//
// Prints a summary per file (cases, passed, failed, and fields the page cannot produce, with counts) and exits 1 on
// any failure or if the page's script cannot run. -v prints every failure, not just the first few per file.
'use strict';
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const args = process.argv.slice(2);
const VERBOSE = args.includes('-v');
const page = args.find(a => a !== '-v') || path.join(__dirname, 'combat-sandbox.html');
const VECTORS = path.join(__dirname, '..', 'vectors');

function pageScript(html) {
  const re = /<script>([\s\S]*?)<\/script>/g;
  let m;
  while ((m = re.exec(html))) if (m[1].includes('function runChecks')) return m[1];
  throw new Error(`No inline <script> with runChecks in ${page}`);
}

// The page's functions and tables, from the same vm context run_checks.js uses (no DOM).
function loadPage() {
  const src = pageScript(fs.readFileSync(page, 'utf8'));
  const context = vm.createContext({ console });
  vm.runInContext(`${src}
;globalThis.__page = { forecast, rollAttack, attackError, lockInfo, protoRoll, useProtocol, stat, taskTarget, makeUnit, moveOf, sf, st,
  toAxial, step, key, lc, DIFF, W, F, P, PROTOS, setS: v => { S = v; }, getS: () => S };`, context, { filename: path.basename(page) });
  return context.__page;
}

const pg = loadPage();
const load = name => JSON.parse(fs.readFileSync(path.join(VECTORS, name), 'utf8'));

// ------------------------------------------------------------------ defaults (vectors/README.md)
const DEFAULTS = {
  weapon: { ap: 0, aim: 0, heavy: false, melee: false, damage_type: 'Ballistic', on_hit: null, ignore_cover: 0, kneel_only: false },
  defender: { armour_type: 'None', size: 'Medium', brace: 5, stance: 'evade', full_move: false },
  situation: { cover: 0, lock: 'roll', push: false, see_it: false, planted: false, charged: false, modifier: 0 },
};
function withDefaults(c) {
  const out = Object.assign({}, c);
  for (const [part, d] of Object.entries(DEFAULTS)) out[part] = Object.assign({}, d, c[part] || {});
  return out;
}

// ------------------------------------------------------------------ worlds
const START = pg.toAxial(6, 11);
const COVER_TERRAIN = { 1: 'light', 2: 'heavy' };
const zeros = [0, 0, 0, 0, 0, 0], open = [99, 99, 99, 99, 99, 99];

function world() {
  pg.setS({ ver: 3, round: 1, phase: 'attack', units: [], wrecks: [], log: [], tiebreak: {}, initRef: {}, testTerrain: {}, ui: {} });
  return pg.getS();
}
// A test frame: no hardware and limits out of the way, so totals are the pilot's stats.
function frame(id, { size = 'medium', structure = 50, armour = 0, armourType = 'none' } = {}) {
  pg.F[id] = pg.sf(`Vector ${id}`, 2, size, structure, armour, armourType, 3, 99, 1, zeros, open, [0, 99], { melee: null });
  return id;
}
function pilot(id, { gunnery = 5, melee = 5, precision = 5, reflex = 5, systems = 5, countermeasures = 5, brace = 5 } = {}, abilities = ['push']) {
  pg.P[id] = { name: `Vector ${id}`, role: 'Test', stats: pg.st(gunnery, melee, precision, reflex, systems, countermeasures, brace, 99), abilities };
  return id;
}
function east(h, n) { for (let i = 0; i < n; i++) h = pg.step(h, 1); return h; }
function unit(S, spec) {
  const u = pg.makeUnit(Object.assign({ facing: 1, band: 0, weapons: [], noJam: true }, spec));
  S.units.push(u);
  return u;
}
// A weapon with the case's numbers, any range and arc, no magazine or Energy.
function vectorWeapon(w) {
  const tags = {};
  if (w.ignore_cover) tags.ignore_cover = w.ignore_cover;
  if (w.kneel_only) tags.kneel_only = true;
  if (w.on_hit) tags.on_hit = w.on_hit;
  const out = { name: 'Vector weapon', type: pg.lc(w.damage_type), shots: w.shots, dmg: w.damage, ap: w.ap, aim: w.aim, heavy: w.heavy,
    melee: w.melee, rmin: w.melee ? 0 : 1, rmax: w.melee ? 0 : 8, arc: 360, mag: 0, spares: 0, energy: 0, size: 'medium',
    special: w.on_hit ? `On a hit: ${w.on_hit}.` : '', gen: 2, tags };
  if (w.kneel_only) Object.assign(out, { still: true, kneel: true });
  if (w.on_hit) out.onHit = w.on_hit;
  pg.W._vec = out;
  return '_vec';
}

// Builds attacker, defender and weapon for an attack case; returns what forecast() and rollAttack() need.
function attackSetup(raw, weaponId) {
  const c = withDefaults(raw), a = c.attacker, w = c.weapon, d = c.defender, s = c.situation;
  const S = world();
  const wid = weaponId || vectorWeapon(w);
  const W = pg.W[wid];
  frame('_vatt');
  frame('_vdef', { size: pg.lc(d.size), structure: d.structure, armour: d.armour, armourType: pg.lc(d.armour_type) });
  pilot('_vatt', { gunnery: a.attack, melee: a.attack, precision: a.precision, systems: a.systems }, s.see_it ? ['push', 'see_it'] : ['push']);
  pilot('_vdef', { reflex: d.reflex, countermeasures: d.countermeasures, brace: d.brace });
  const R = W.melee ? 1 : Math.max(1, Math.ceil(W.rmin));
  if (!W.melee && R > Math.floor(W.rmax)) throw new Error(`no legal range for ${wid}`);
  const att = unit(S, { id: 'att', cs: 'ATT', side: 0, pilot: '_vatt', frame: '_vatt', weapons: [wid], hex: START });
  const def = unit(S, { id: 'def', cs: 'DEF', side: 1, pilot: '_vdef', frame: '_vdef', hex: east(START, R), facing: 4 });
  if (s.cover) {
    if (!COVER_TERRAIN[s.cover]) throw new Error(`no terrain gives cover ${s.cover}`);
    S.testTerrain[pg.key(def.hex)] = COVER_TERRAIN[s.cover];
  }
  att.energy = 99;
  def.structure = d.structure;
  def.stance = d.stance;
  if (d.full_move) { def.moveM = 'ground'; def.moveHexes = pg.moveOf(def); }
  att.stance = s.planted ? 'brace' : 'evade';
  att.moved = false;
  if (s.charged) att.chargeTarget = def.id;
  if (s.lock === 'none') att.effects.push({ pid: 'jam', name: 'Jam', flag: 'jam', expires: 99, strength: 0, kind: 'debuff' });
  const opts = { push: s.push, seeIt: s.see_it, modifier: s.modifier, locked: s.lock === 'locked' };
  return { S, att, def, wid, W, opts, c };
}

function illegal(err) {
  if (/kneel/i.test(err)) return 'kneel_only';
  throw new Error(`the page refused the attack: ${err}`);
}

function pageForecast(raw, weaponId) {
  const { att, def, wid, opts } = attackSetup(raw, weaponId);
  const err = pg.attackError(att, def, wid);
  if (err) return { illegal: illegal(err) };
  const f = pg.forecast(att, def, wid, opts);
  return {
    hit_target: f.ht.t, glance_to: f.glanceTo, crit_target: f.crit, brace_target: f.bt, full_move_reroll: !!f.fm,
    lock_target: f.li.ok ? f.li.t : null, lock_countered_to: f.li.ok ? f.li.tu : null,
    effective_armour: f.ea, hit_damage: f.dH, crit_damage: f.dC, glance_damage: f.dG,
    p_lock: f.pLock, expected_damage: f.exp, expected_damage_locked: f.expLocked, expected_damage_unlocked: f.expUnlocked,
    p_damage: f.any, p_destroy: f.kill,
    p_on_hit: pg.W[wid].onHit ? f.pOnHit : null,
    p_will_see_it: opts.seeIt ? f.pSeeIt : null,
  };
}

// Scripted dice: every die must be used.
function script(dice) {
  let i = 0;
  const fn = () => { if (i >= dice.length) throw new Error('ran out of scripted dice'); return dice[i++]; };
  fn.left = () => dice.length - i;
  return fn;
}
function pageRoll(raw, dice) {
  const { att, def, wid, opts } = attackSetup(raw);
  const roll = script(dice);
  const res = pg.rollAttack(att, def, wid, opts, roll);
  if (res.err) return { illegal: illegal(res.err) };
  if (roll.left()) throw new Error(`${roll.left()} dice left over`);
  const w = pg.W[wid];
  return {
    lock: res.lockRes, results: res.shots.map(s => s.res), damage: res.shots.map(s => s.dmg), total: res.total,
    will_see_it: res.seeIt ? 1 : 0,
    // The page's own trigger: a weapon with an on-hit effect, and at least one shot that hit (glances don't count).
    on_hit: Boolean(w.special && w.onHit) && res.shots.some(s => s.res === 'hit' || s.res === 'crit'),
    destroyed: res.killed,
  };
}

// ------------------------------------------------------------------ comparison and reporting
// Numbers within tol; arrays and objects field by field.
function same(got, want, tol) {
  if (Array.isArray(want)) return Array.isArray(got) && got.length === want.length && want.every((v, i) => same(got[i], v, tol));
  if (want && typeof want === 'object') return !!got && typeof got === 'object' && Object.keys(want).every(k => same(got[k], want[k], tol));
  if (typeof want === 'number' && typeof got === 'number') return Math.abs(got - want) <= tol;
  return got === want;
}
const show = v => JSON.stringify(v);

class Report {
  constructor(name) { Object.assign(this, { name, cases: 0, passed: 0, failed: 0, empty: 0, notCompared: {}, failures: [] }); }
  check(id, got, expected, tol, skip = {}) {
    this.cases++;
    let compared = 0;
    const bad = [];
    for (const [k, want] of Object.entries(expected)) {
      if (skip[k] || !(k in got) || got[k] === undefined) {
        const why = skip[k] || 'the page has no such figure';
        this.notCompared[`${k} (${why})`] = (this.notCompared[`${k} (${why})`] || 0) + 1;
        continue;
      }
      compared++;
      if (!same(got[k], want, tol)) bad.push(`${k}: page ${show(got[k])}, vector ${show(want)}`);
    }
    if (bad.length) { this.failed++; this.failures.push(`${id}: ${bad.join('; ')}`); }
    else if (compared) this.passed++;
    else this.empty++;
  }
  error(id, e) { this.cases++; this.failed++; this.failures.push(`${id}: ${e.message || e}`); }
  notComparable(field, why, n = 1) { this.cases += n; this.empty += n; this.notCompared[`${field} (${why})`] = (this.notCompared[`${field} (${why})`] || 0) + n; }
  print() {
    const nc = Object.entries(this.notCompared);
    console.log(`${this.name}: ${this.cases} cases, ${this.passed} passed, ${this.failed} failed${this.empty ? `, ${this.empty} with nothing to compare` : ''}`);
    for (const [k, n] of nc) console.log(`    not compared: ${k} × ${n}`);
    for (const f of this.failures.slice(0, VERBOSE ? Infinity : 10)) console.log(`    FAIL ${f}`);
    if (!VERBOSE && this.failures.length > 10) console.log(`    … ${this.failures.length - 10} more (run with -v)`);
  }
}

function runForecasts(name, cases, tol, weaponOf = () => null, extra = null) {
  const rep = new Report(name);
  for (const c of cases) {
    try {
      const wid = weaponOf(c);
      if (wid && !pg.W[wid]) throw new Error(`the page has no weapon ${wid}`);
      const got = pageForecast(c, wid);
      if (extra) Object.assign(got, extra(c));
      const expected = Object.assign({}, c.expected, extra ? extra.expected(c) : {});
      rep.check(c.id, got, expected, tol);
    } catch (e) { rep.error(c.id, e); }
  }
  return rep;
}

// Catalogue cases: the page's own weapon, and its own frames and pilots must give the case's totals.
function catalogueExtra(c) {
  const S = world();
  const wid = c.weapon_id, w = pg.W[wid], v = c.weapon;
  const a = unit(S, { id: 'a', cs: 'A', side: 0, pilot: c.attacker_pilot, frame: c.attacker_frame, hex: START });
  const d = unit(S, { id: 'd', cs: 'D', side: 1, pilot: c.defender_pilot, frame: c.defender_frame, hex: east(START, 2) });
  const df = pg.F[c.defender_frame];
  return {
    weapon_data: w ? { shots: w.shots, damage: w.dmg, ap: w.ap, aim: w.aim, heavy: !!w.heavy, melee: !!w.melee, damage_type: w.type,
      on_hit: w.onHit || null, ignore_cover: (w.tags && w.tags.ignore_cover) || 0, kneel_only: !!w.kneel } : null,
    attacker_totals: [pg.stat(a, v.melee ? 'melee' : 'gunnery'), pg.stat(a, 'precision'), pg.stat(a, 'systems')],
    defender_totals: [pg.stat(d, 'reflex'), pg.stat(d, 'countermeasures'), pg.stat(d, 'brace'), df.armour, df.armourType, df.size, df.structure],
  };
}
catalogueExtra.expected = c => {
  const v = c.weapon, a = c.attacker, d = c.defender;
  return {
    weapon_data: { shots: v.shots, damage: v.damage, ap: v.ap, aim: v.aim, heavy: v.heavy, melee: v.melee, damage_type: pg.lc(v.damage_type),
      on_hit: v.on_hit, ignore_cover: v.ignore_cover, kneel_only: v.kneel_only },
    attacker_totals: [a.attack, a.precision, a.systems],
    defender_totals: [d.reflex, d.countermeasures, d.brace, d.armour, pg.lc(d.armour_type), pg.lc(d.size), d.structure],
  };
};

function runDice(cases) {
  const rep = new Report('dice.json');
  for (const c of cases) {
    try { rep.check(c.id, pageRoll(c, c.dice), c.expected, 0); } catch (e) { rep.error(c.id, e); }
  }
  // The runner itself: one die too many or too few must be an error.
  const first = cases[0];
  for (const [label, dice] of [['one die too many', first.dice.concat([5])], ['one die too few', first.dice.slice(0, -1)]]) {
    rep.cases++;
    try { pageRoll(first, dice); rep.failed++; rep.failures.push(`${first.id} with ${label}: no error`); } catch (e) { rep.passed++; }
  }
  return rep;
}

// ------------------------------------------------------------------ locks, Protocols, Purges, stats
const ROLLS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

function lockWorld(systems, countermeasures) {
  const S = world();
  frame('_vatt'); frame('_vdef');
  pilot('_vatt', { systems, precision: 5 });
  pilot('_vdef', { countermeasures });
  vectorWeapon(Object.assign({}, DEFAULTS.weapon, { shots: 1, damage: 1 }));
  const a = unit(S, { id: 'att', cs: 'ATT', side: 0, pilot: '_vatt', frame: '_vatt', weapons: ['_vec'], hex: START });
  const d = unit(S, { id: 'def', cs: 'DEF', side: 1, pilot: '_vdef', frame: '_vdef', hex: east(START, 2), facing: 4 });
  return { a, d };
}
function pageLock(c) {
  const { a, d } = lockWorld(c.systems, c.countermeasures);
  const li = pg.lockInfo(a, d);
  // The result of each lock roll, from rollAttack: the lock die, then 10s (always a miss) for the shot and its reroll.
  const results = ROLLS.map(r => {
    const w = lockWorld(c.systems, c.countermeasures);
    let first = true;
    const res = pg.rollAttack(w.a, w.d, '_vec', {}, () => { if (first) { first = false; return r; } return 10; });
    if (res.err) throw new Error(res.err);
    return res.lockRes;
  });
  return { lock_target: li.t, lock_countered_to: li.tu, results };
}
function runLocks(name, cases) {
  const rep = new Report(name);
  for (const c of cases) { try { rep.check(c.id, pageLock(c), c.expected, 0); } catch (e) { rep.error(c.id, e); } }
  return rep;
}

const DIFF_NAME = m => Object.keys(pg.DIFF).find(k => pg.DIFF[k] === m);
function protoWorld(c, pid, p) {
  const S = world();
  frame('_vcaster'); frame('_vtarget');
  pilot('_vcaster', { systems: c.systems });
  pilot('_vtarget', { countermeasures: c.target_cm == null ? 5 : c.target_cm });
  const hostile = p.kind === 'debuff' || p.kind === 'damage';
  const u = unit(S, { id: 'u', cs: 'CASTER', side: 0, pilot: '_vcaster', frame: '_vcaster', hex: START });
  const t = p.self ? u : unit(S, { id: 't', cs: 'TARGET', side: hostile ? 1 : 0, pilot: '_vtarget', frame: '_vtarget', hex: east(START, 1), facing: 4 });
  u.energy = 99;
  return { S, u, t, hostile };
}
function pageProtocol(c) {
  let pid = c.protocol, p = pid && pg.PROTOS[pid];
  const got = {};
  if (pid) {
    if (!p) throw new Error(`the page has no Protocol ${pid}`);
    const hostile = p.kind === 'debuff' || p.kind === 'damage';
    got.protocol_data = { hostile, modifier: pg.DIFF[p.diff] };
  } else {
    const diff = DIFF_NAME(c.modifier);
    if (diff === undefined) throw new Error(`no difficulty gives ${c.modifier}`);
    pid = '_vproto';
    p = pg.PROTOS[pid] = { name: 'Vector Protocol', kind: c.hostile ? 'debuff' : 'buff', diff, energy: 0, range: 99, text: '', tags: {} };
  }
  const { u, t, hostile } = protoWorld(c, pid, p);
  const info = pg.protoRoll(u, pid, t, c.push);
  got.target = info.t;
  got.countered_to = hostile ? info.tu : null;
  got.results = ROLLS.map(r => {
    const w = protoWorld(c, pid, p);
    const res = pg.useProtocol(w.u, pid, w.t, c.push, 0, script([r]));
    if (res.err) throw new Error(res.err);
    if (res.o) return res.o;
    // Cascade Burst rolls once per enemy in the area and returns no single outcome: read it from the log.
    const m = /<b>(SUCCESS|COUNTERED|FIZZLED)<\/b>/.exec(w.S.log[0].html);
    if (!m) throw new Error('no outcome in the log');
    return m[1];
  });
  ROLLS.forEach((r, i) => { got[`roll_${r}`] = got.results[i]; });
  return got;
}
function runProtocols(name, cases) {
  const rep = new Report(name);
  for (const c of cases) {
    try {
      const expected = Object.assign({}, c.expected);
      if (c.protocol) expected.protocol_data = { hostile: c.hostile, modifier: c.modifier };
      const got = pageProtocol(c);
      rep.check(c.id, got, expected, 0);
    } catch (e) { rep.error(c.id, e); }
  }
  return rep;
}

function pagePurge(c) {
  const diff = DIFF_NAME(c.modifier);
  if (diff === undefined) throw new Error(`no difficulty gives ${c.modifier}`);
  pg.PROTOS._vpurge = { name: 'Vector Purge', kind: 'dispel', diff, energy: 0, range: 99, text: '', tags: {} };
  const S = world();
  frame('_vcaster'); frame('_vtarget');
  pilot('_vcaster', { countermeasures: c.countermeasures });
  pilot('_vtarget');
  const u = unit(S, { id: 'u', cs: 'CASTER', side: 0, pilot: '_vcaster', frame: '_vcaster', hex: START });
  const t = unit(S, { id: 't', cs: 'ALLY', side: 0, pilot: '_vtarget', frame: '_vtarget', hex: east(START, 1) });
  const effect = { pid: 'effect', name: 'Effect', stat: 'reflex', amt: 0, expires: 99, strength: c.strength, kind: 'debuff' };
  t.effects.push(effect);
  return { target: pg.protoRoll(u, '_vpurge', t, c.push, effect).t };
}
function runPurges(name, cases) {
  const rep = new Report(name);
  for (const c of cases) { try { rep.check(c.id, pagePurge(c), c.expected, 0); } catch (e) { rep.error(c.id, e); } }
  return rep;
}

// Stat totals: the page has whole bonuses (hardware and effects) but no fractional ones, so a case whose fractions
// are not a whole number cannot be put to it.
function fractionValue(s) { const [n, d = '1'] = String(s).split('/'); return Number(n) / Number(d); }
function runStats(name, cases) {
  const rep = new Report(name);
  cases.forEach((c, i) => {
    const id = c.id || `stat/${i}`;
    const f = fractionValue(c.fractions);
    if (!Number.isInteger(f)) { rep.notComparable('expected', 'fractions that are not whole: the page has no fractional bonuses'); return; }
    try {
      const S = world();
      pg.F._vstat = pg.sf('Vector stat', 2, 'medium', 50, 0, 'none', 3, 99, 1, [c.whole + f, 0, 0, 0, 0, 0], [c.limit, 99, 99, 99, 99, 99], [0, 99], { melee: null });
      pilot('_vstat', { gunnery: c.pilot });
      const u = unit(S, { id: 'u', cs: 'U', side: 0, pilot: '_vstat', frame: '_vstat', hex: START });
      rep.check(id, { expected: pg.stat(u, 'gunnery') }, { expected: c.expected }, 0);
    } catch (e) { rep.error(id, e); }
  });
  return rep;
}

// Task checks: target = stat + difficulty + Push (+2) + help (+1), limited to 1-9 (the page's taskTarget).
function runTasks(name, cases) {
  const rep = new Report(name);
  for (const c of cases) {
    try {
      const diff = DIFF_NAME(c.modifier);
      if (diff === undefined) throw new Error(`no difficulty gives ${c.modifier}`);
      const S = world();
      pg.F._vtask = pg.sf('Vector task', 2, 'medium', 50, 0, 'none', 3, 99, 1, [0, 0, 0, 0, 0, 0], [99, 99, 99, 99, 99, 99], [0, 99], { melee: null });
      pilot('_vtask', { gunnery: c.stat });
      const u = unit(S, { id: 'u', cs: 'U', side: 0, pilot: '_vtask', frame: '_vtask', hex: START });
      rep.check(c.id, { expected: pg.taskTarget(u, 'gunnery', diff, c.push, c.help > 0).t }, { expected: c.expected }, 0);
    } catch (e) { rep.error(c.id, e); }
  }
  return rep;
}

// ------------------------------------------------------------------ main
function main() {
  const reports = [];
  const anchors = load('anchors.json');
  reports.push(runForecasts('anchors.json attacks', anchors.attacks, 1e-9));
  reports.push(runLocks('anchors.json locks', anchors.locks));
  reports.push(runProtocols('anchors.json protocols', anchors.protocols));
  reports.push(runPurges('anchors.json purges', anchors.purges));
  reports.push(runStats('anchors.json stats', anchors.stats));
  reports.push(runTasks('anchors.json tasks', anchors.tasks));
  reports.push(runDice(load('dice.json').cases));
  reports.push(runForecasts('converted.json', load('converted.json').cases, 0.006));
  // build_vectors.py writes the engine's figures rounded to 6 decimals.
  reports.push(runForecasts('catalogue_attacks.json', load('catalogue_attacks.json').cases, 5e-7 + 1e-12, c => c.weapon_id, catalogueExtra));
  const protos = load('protocols.json');
  reports.push(runLocks('protocols.json locks', protos.locks));
  reports.push(runProtocols('protocols.json protocols', protos.protocols));
  reports.push(runPurges('protocols.json purges', protos.purges));
  reports.push(runStats('stats.json', load('stats.json').cases));

  for (const r of reports) r.print();
  const failed = reports.reduce((n, r) => n + r.failed, 0), total = reports.reduce((n, r) => n + r.cases, 0);
  const empty = reports.reduce((n, r) => n + r.empty, 0);
  console.log(`\n${total - failed - empty}/${total} vector cases pass, ${failed} fail, ${empty} not compared`);
  return failed ? 1 : 0;
}

try {
  process.exitCode = main();
} catch (e) {
  console.error(`Could not run the vectors against the sandbox: ${e.stack || e}`);
  process.exitCode = 1;
}
