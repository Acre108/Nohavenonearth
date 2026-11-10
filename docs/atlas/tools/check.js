// Usage: node tools/check.js mech-lineage-atlas.html
// Syntax-checks the page script, then checks that every reference in atlas-data.json (beside the page) resolves.
const fs=require("fs"),path=require("path");
const html=fs.readFileSync(process.argv[2],"utf8");
const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]);
new Function(scripts[scripts.length-1]); // syntax check
const {GROUPS,COLS,VART,PLATES,SCENES,DATA,LOC,MINOR,ORBIT,POWERS,SPACE,UNEL,TIMELINE,BLOC,ACE_FACTIONS,ACE_ERAS,ACES,SOLAR,CHRONO=[]}=JSON.parse(fs.readFileSync(path.join(path.dirname(process.argv[2]),"atlas-data.json"),"utf8"));
const IDX={};let errs=[];
for(const [k,t] of Object.entries(DATA))for(const n of t.nodes){if(IDX[n.id])errs.push("dup "+n.id);IDX[n.id]=k;if(!GROUPS[n.m])errs.push("group "+n.id+" "+n.m);}
for(const [k,t] of Object.entries(DATA)){const cells={};const ncol=(t.cols||COLS).length;const fams=new Set(t.fams.map(f=>f[0]));
 for(const n of t.nodes){const key=n.f+"/"+n.c+"/"+n.r;if(cells[key])errs.push(`cell clash ${k} ${n.id} ${cells[key]}`);cells[key]=n.id;
  if(!fams.has(n.f))errs.push("fam "+n.id);if(n.c>=ncol)errs.push("col "+n.id);
  for(const [p,t2] of n.p||[]){if(IDX[p]!==k)errs.push(`parent ${n.id}->${p}`);if(!DATA[k].rel[t2])errs.push(`relation ${n.id}->${p} ${t2}`)}
  for(const f of ["fr","mx","pw","wp","dc","ln"])for(const id of n[f]||[])if(!IDX[id]&&!(f==="ln"&&(k==="people"||k==="mysteries")&&ACES.some(a=>a.id===id)))errs.push(`ref ${n.id}.${f} ${id}`);}}
for(const n of DATA.conflicts.nodes)if(!LOC[n.id]&&!ORBIT[n.id])errs.push("no LOC or ORBIT "+n.id);
for(const n of MINOR)for(const f of ["mx","pw","wp","dc"])for(const id of n[f]||[])if(!IDX[id])errs.push(`minor ref ${n.id} ${id}`);
if(DATA.nppl){const B=(SOLAR&&SOLAR.bodies)||{},AT=(SOLAR&&SOLAR.at)||{};
 if(!SOLAR||(SOLAR.eras||[]).length!==DATA.nppl.cols.length)errs.push("SOLAR.eras needs one entry per nppl column");
 for(const [k,b] of Object.entries(B))if(b.of&&!B[b.of])errs.push(`body ${k} orbits unknown ${b.of}`);
 for(const n of DATA.nppl.nodes)if(!AT[n.id])errs.push("no SOLAR.at "+n.id);else if(!B[AT[n.id][0]])errs.push(`SOLAR.at ${n.id} unknown body ${AT[n.id][0]}`);
 for(const id of Object.keys(AT))if(IDX[id]!=="nppl")errs.push("SOLAR.at for unknown nppl entry "+id);}
{const FV=JSON.parse(fs.readFileSync(path.join(path.dirname(process.argv[2]),"atlas-data.json"),"utf8")).FACTION_VIEWS;
 if(FV){const keys=new Set(FV.factions.map(f=>f.k)),lanes=new Set(TIMELINE.map(l=>l.g)),afs=new Set(ACE_FACTIONS.map(a=>a[0]));
  for(const f of FV.factions){const c=f.card==="UNEL"?UNEL:f.kind==="power"?POWERS.find(p=>p.b===f.card):SPACE.find(p=>p.n===f.card);if(!c)errs.push("view card "+f.k);
   for(const g of [...f.lanes,...(f.tl||[])])if(!lanes.has(g))errs.push(`view lane ${f.k} ${g}`);for(const a of f.aces)if(!afs.has(a))errs.push(`view aces ${f.k} ${a}`);
   for(const b of f.bands)if(!DATA.people||!DATA.people.fams.some(x=>x[0]===b))errs.push(`view band ${f.k} ${b}`)}
  for(const [code,ks] of Object.entries(FV.makers)){if(!GROUPS[code])errs.push("view maker "+code);for(const k of ks)if(!keys.has(k))errs.push(`view maker ${code} ${k}`)}
  for(const n of [...Object.values(DATA).flatMap(t=>t.nodes),...MINOR])for(const k of n.fx||[])if(!keys.has(k))errs.push(`fx ${n.id} ${k}`);}}
for(const [k,t] of Object.entries(DATA))for(const r of t.profile||[])for(const id of r.ids)if(IDX[id]!==k)errs.push(`profile ${k} ${r.k} ${id}`);
const NCH=DATA.conflicts.cols.length+(DATA.nppl?DATA.nppl.cols.length:1);
for(const b of CHRONO){if(b.e>=NCH)errs.push(`chrono era ${b.t} ${b.e}`);if(b.id&&!IDX[b.id]&&!ACES.some(a=>a.id===b.id))errs.push(`chrono ref ${b.t} ${b.id}`)}
for(const p of [...SPACE,UNEL,...POWERS])for(const id of p.from||[])if(!IDX[id]&&!ACES.some(a=>a.id===id))errs.push(`seed ref ${p.n} ${id}`);
for(const p of POWERS)if(!BLOC[p.b])errs.push(`power bloc ${p.n} ${p.b}`);
for(const l of TIMELINE)for(const e of l.ev)if(e[3]&&!IDX[e[3]])errs.push(`timeline ref ${l.n} ${e[3]}`);
const FAC=new Set(ACE_FACTIONS.map(f=>f[0])),ERAS=new Set(ACE_ERAS.map(e=>e[0])),AIDS=new Set();
for(const a of ACES){if(AIDS.has(a.id))errs.push("dup ace "+a.id);AIDS.add(a.id);if(!FAC.has(a.g))errs.push(`ace faction ${a.id} ${a.g}`);if(!ERAS.has(a.c))errs.push(`ace era ${a.id} ${a.c}`);
 for(const [id,b,vn,note] of a.fr){if(b!=="S"&&!(vn&&note&&note.length>60))errs.push(`ace variant needs a name and differences ${a.id} ${id}`);if(IDX[id]!=="frames")errs.push(`ace frame ${a.id} ${id}`);if(!"SVC".includes(b)||b.length!==1)errs.push(`ace build ${a.id} ${b}`)}
 for(const id of a.cf)if(IDX[id]!=="conflicts"&&IDX[id]!=="nppl")errs.push(`ace conflict ${a.id} ${id}`);for(const id of a.ln||[])if(!IDX[id]&&!ACES.some(b=>b.id===id))errs.push(`ace ref ${a.id} ${id}`);}
const VNS=new Set();for(const a of ACES)for(const f of a.fr)if(f[2])VNS.add(f[2]);
for(const vn of Object.keys(VART||{}))if(!VNS.has(vn))errs.push("variant art for unknown version "+vn);
for(const [k,p] of Object.entries(PLATES||{})){if(!DATA[k])errs.push("plate tree "+k);if(!p.f||!p.h||!p.c)errs.push("plate fields "+k);for(const id of p.go||[])if(!IDX[id])errs.push(`plate ref ${k} ${id}`);}
const LANES=new Set(TIMELINE.map(l=>l.g));
for(const [id,p] of Object.entries(SCENES||{})){if(!IDX[id]&&!AIDS.has(id)&&!LANES.has(id)&&id!=="UNEL"&&id!=="headline")errs.push("scene for unknown entry "+id);if(!p.f||!p.h||!p.c)errs.push("scene fields "+id);
 if(!fs.existsSync(path.join(path.dirname(process.argv[2]),"art",p.f+".jpg"))&&process.env.ART_DIR&&!fs.existsSync(path.join(process.env.ART_DIR,p.f+".jpg")))errs.push("scene art missing "+p.f);}
console.log(errs.length?errs.join("\n"):"OK: "+Object.keys(IDX).length+" nodes, all references resolve");
