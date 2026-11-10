// Usage: node tools/check.js mech-lineage-atlas.html
// Syntax-checks the page script, then checks that every reference in atlas-data.json (beside the page) resolves.
const fs=require("fs"),path=require("path");
const html=fs.readFileSync(process.argv[2],"utf8");
const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]);
new Function(scripts[scripts.length-1]); // syntax check
const {GROUPS,COLS,GENS=[],VART,PLATES,SCENES,DATA,LOC,MINOR,POWERS,SPACE,UNEL,TIMELINE,BLOC,ACE_FACTIONS,ACE_ERAS,ACES,SOLAR,CHRONO=[],ORGMAP={},SITES={},MOON,MARS,MAPNOTE=[],FUTURE_OVR=[]}=JSON.parse(fs.readFileSync(path.join(path.dirname(process.argv[2]),"atlas-data.json"),"utf8"));
const IDX={};let errs=[];
for(const [k,t] of Object.entries(DATA))for(const n of t.nodes){if(IDX[n.id])errs.push("dup "+n.id);IDX[n.id]=k;if(!GROUPS[n.m])errs.push("group "+n.id+" "+n.m);}
for(const [k,t] of Object.entries(DATA)){const cells={};const ncol=(t.cols||COLS).length;const fams=new Set(t.fams.map(f=>f[0]));
 for(const n of t.nodes){const key=n.f+"/"+n.c+"/"+n.r;if(cells[key])errs.push(`cell clash ${k} ${n.id} ${cells[key]}`);cells[key]=n.id;
  if(!fams.has(n.f))errs.push("fam "+n.id);if(n.c>=ncol)errs.push("col "+n.id);
  for(const [p,t2] of n.p||[]){if(IDX[p]!==k)errs.push(`parent ${n.id}->${p}`);if(!DATA[k].rel[t2])errs.push(`relation ${n.id}->${p} ${t2}`)}
  for(const f of ["fr","mx","pw","wp","dc","ln"])for(const id of n[f]||[])if(!IDX[id]&&!(f==="ln"&&(k==="people"||k==="mysteries")&&ACES.some(a=>a.id===id)))errs.push(`ref ${n.id}.${f} ${id}`);}}
// The map: every conflict has a place in at least one view (Earth LOC, Moon or Mars SITES, inner-system SOLAR.at)
{const B=(SOLAR&&SOLAR.bodies)||{},AT=(SOLAR&&SOLAR.at)||{},NG=DATA.conflicts.cols.length,isGen=g=>Number.isInteger(g)&&g>=0&&g<NG;
 const ll=(lon,lat)=>typeof lon==="number"&&typeof lat==="number"&&lon>=-180&&lon<=180&&lat>=-90&&lat<=90;
 const place=(p,what)=>{if(typeof p!=="string"||!p)errs.push("no place "+what)};
 for(const [k,b] of Object.entries(B))if(b.of&&!B[b.of])errs.push(`body ${k} orbits unknown ${b.of}`);
 for(const n of DATA.conflicts.nodes)if(!LOC[n.id]&&!AT[n.id]&&!(SITES.moon||{})[n.id]&&!(SITES.mars||{})[n.id])errs.push("no map place "+n.id);
 for(const [id,v] of Object.entries(LOC)){if(IDX[id]!=="conflicts")errs.push("LOC for a non-conflict "+id);if(!ll(v[0],v[1]))errs.push("LOC coordinates "+id);place(v[2],"LOC "+id)}
 for(const [id,v] of Object.entries(AT)){if(IDX[id]!=="conflicts")errs.push("SOLAR.at for a non-conflict "+id);if(!B[v[0]])errs.push(`SOLAR.at ${id} unknown body ${v[0]}`);place(v[1],"SOLAR.at "+id)}
 for(const [v,t] of Object.entries(SITES)){if(v!=="moon"&&v!=="mars")errs.push("SITES view "+v);
  for(const [id,list] of Object.entries(t)){if(IDX[id]!=="conflicts")errs.push(`SITES.${v} for a non-conflict ${id}`);if(!Array.isArray(list)||!list.length)errs.push(`SITES.${v} ${id} empty`);
   for(const st of list||[])if(typeof st[0]==="number"){if(!ll(st[0],st[1]))errs.push(`SITES.${v} ${id} coordinates`);place(st[2],`SITES.${v} ${id}`)}
    else{if(v!=="mars"||!["phobos","deimos"].includes(st[0]))errs.push(`SITES.${v} ${id} body ${st[0]}`);place(st[1],`SITES.${v} ${id}`)}}}
 for(const n of MINOR){if(!ll(n.at[0],n.at[1]))errs.push("minor coordinates "+n.id);place(n.at[2],"minor "+n.id)}
 for(const [id,o] of Object.entries(ORGMAP)){if(IDX[id]!=="orgs")errs.push("ORGMAP for a non-organisation "+id);if(o.to!=null&&!isGen(o.to))errs.push("ORGMAP to "+id);
  for(const st of o.at||[]){if(!ll(st[0],st[1]))errs.push("ORGMAP at "+id);place(st[2],"ORGMAP at "+id)}
  for(const v of ["moon","mars"])for(const st of o[v]||[]){if(!ll(st[0],st[1]))errs.push(`ORGMAP ${v} ${id}`);place(st[2],`ORGMAP ${v} ${id}`);if(st[3]!=null&&!isGen(st[3]))errs.push(`ORGMAP ${v} last Gen ${id}`)}
  if(o.sys){if(!B[o.sys[0]])errs.push(`ORGMAP sys ${id} unknown body ${o.sys[0]}`);place(o.sys[1],"ORGMAP sys "+id)}}
 if(MAPNOTE.length!==NG)errs.push(`MAPNOTE needs one note per generation (${NG})`);
 for(const [i,nt] of MAPNOTE.entries())if(!nt||!nt[0]||!nt[1])errs.push("MAPNOTE "+i);
 if(GENS.length&&GENS.length!==NG)errs.push("GENS and the conflicts columns differ");
 if(FUTURE_OVR.length>NG-6)errs.push("FUTURE_OVR has more entries than post-war generations");
 const towns=(D,nm)=>{for(const t of D.towns||[]){if(!ll(t[0],t[1])||!t[2])errs.push(nm+" town "+t[2]);if(!isGen(t[3])||!isGen(t[4])||t[3]>t[4])errs.push(nm+" town Gens "+t[2])}
  for(const l of D.labels||[])if(!ll(l[0],l[1])||!l[2]||![1,2].includes(l[4]))errs.push(nm+" label "+l[2])};
 if(SITES.moon&&Object.keys(SITES.moon).length){if(!MOON)errs.push("SITES.moon without MOON");else{if((MOON.panels||[]).length!==3||MOON.panels.filter(p=>p.pole!=null).length!==1)errs.push("MOON needs three panels, one of them the pole");towns(MOON,"MOON")}}
 if(SITES.mars&&Object.keys(SITES.mars).length){if(!MARS)errs.push("SITES.mars without MARS");else{towns(MARS,"MARS");
  for(const l of MARS.lines||[])if(!isGen(l.from)||!isGen(l.to)||l.from>l.to||(l.pts||[]).length<2||!["loc","wall"].includes(l.k))errs.push("MARS line "+l.n)}}}
{const FV=JSON.parse(fs.readFileSync(path.join(path.dirname(process.argv[2]),"atlas-data.json"),"utf8")).FACTION_VIEWS;
 if(FV){const keys=new Set(FV.factions.map(f=>f.k)),lanes=new Set(TIMELINE.map(l=>l.g)),afs=new Set(ACE_FACTIONS.map(a=>a[0]));
  for(const f of FV.factions){const c=f.card==="UNEL"?UNEL:f.kind==="power"?POWERS.find(p=>p.b===f.card):SPACE.find(p=>p.n===f.card);if(!c)errs.push("view card "+f.k);
   for(const g of [...f.lanes,...(f.tl||[])])if(!lanes.has(g))errs.push(`view lane ${f.k} ${g}`);for(const a of f.aces)if(!afs.has(a))errs.push(`view aces ${f.k} ${a}`);
   for(const b of f.bands)if(!DATA.people||!DATA.people.fams.some(x=>x[0]===b))errs.push(`view band ${f.k} ${b}`)}
  for(const [code,ks] of Object.entries(FV.makers)){if(!GROUPS[code])errs.push("view maker "+code);for(const k of ks)if(!keys.has(k))errs.push(`view maker ${code} ${k}`)}
  for(const n of [...Object.values(DATA).flatMap(t=>t.nodes),...MINOR])for(const k of n.fx||[])if(!keys.has(k))errs.push(`fx ${n.id} ${k}`);}}
for(const [k,t] of Object.entries(DATA))for(const r of t.profile||[])for(const id of r.ids)if(IDX[id]!==k)errs.push(`profile ${k} ${r.k} ${id}`);
const NCH=DATA.conflicts.cols.length;
for(const b of CHRONO){if(b.e>=NCH)errs.push(`chrono era ${b.t} ${b.e}`);if(b.id&&!IDX[b.id]&&!ACES.some(a=>a.id===b.id))errs.push(`chrono ref ${b.t} ${b.id}`)}
for(const p of [...SPACE,UNEL,...POWERS])for(const id of p.from||[])if(!IDX[id]&&!ACES.some(a=>a.id===id))errs.push(`seed ref ${p.n} ${id}`);
for(const p of POWERS)if(!BLOC[p.b])errs.push(`power bloc ${p.n} ${p.b}`);
for(const l of TIMELINE)for(const e of l.ev)if(e[3]&&!IDX[e[3]])errs.push(`timeline ref ${l.n} ${e[3]}`);
const FAC=new Set(ACE_FACTIONS.map(f=>f[0])),ERAS=new Set(ACE_ERAS.map(e=>e[0])),AIDS=new Set();
for(const a of ACES){if(AIDS.has(a.id))errs.push("dup ace "+a.id);AIDS.add(a.id);if(!FAC.has(a.g))errs.push(`ace faction ${a.id} ${a.g}`);if(!ERAS.has(a.c))errs.push(`ace era ${a.id} ${a.c}`);
 for(const [id,b,vn,note] of a.fr){if(b!=="S"&&!(vn&&note&&note.length>60))errs.push(`ace variant needs a name and differences ${a.id} ${id}`);if(IDX[id]!=="frames")errs.push(`ace frame ${a.id} ${id}`);if(!"SVC".includes(b)||b.length!==1)errs.push(`ace build ${a.id} ${b}`)}
 for(const id of a.cf)if(IDX[id]!=="conflicts")errs.push(`ace conflict ${a.id} ${id}`);for(const id of a.ln||[])if(!IDX[id]&&!ACES.some(b=>b.id===id))errs.push(`ace ref ${a.id} ${id}`);}
const VNS=new Set();for(const a of ACES)for(const f of a.fr)if(f[2])VNS.add(f[2]);
for(const vn of Object.keys(VART||{}))if(!VNS.has(vn))errs.push("variant art for unknown version "+vn);
for(const [k,p] of Object.entries(PLATES||{})){if(!DATA[k])errs.push("plate tree "+k);if(!p.f||!p.h||!p.c)errs.push("plate fields "+k);for(const id of p.go||[])if(!IDX[id])errs.push(`plate ref ${k} ${id}`);}
const LANES=new Set(TIMELINE.map(l=>l.g));
for(const [id,p] of Object.entries(SCENES||{})){if(!IDX[id]&&!AIDS.has(id)&&!LANES.has(id)&&id!=="UNEL"&&id!=="headline")errs.push("scene for unknown entry "+id);if(!p.f||!p.h||!p.c)errs.push("scene fields "+id);
 if(!fs.existsSync(path.join(path.dirname(process.argv[2]),"art",p.f+".jpg"))&&process.env.ART_DIR&&!fs.existsSync(path.join(process.env.ART_DIR,p.f+".jpg")))errs.push("scene art missing "+p.f);}
console.log(errs.length?errs.join("\n"):"OK: "+Object.keys(IDX).length+" nodes, all references resolve");
