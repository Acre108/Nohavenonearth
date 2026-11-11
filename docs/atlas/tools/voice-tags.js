// Tags every atlas card with a faction tone and an ending code (see docs/atlas-voice-guide.md).
// usage: node voice-tags.js atlas-data.json [tab] [out.json]  (out defaults to ./voice-cards.json)
const fs=require('fs');
const D=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
const FV=D.FACTION_VIEWS,FACS=FV.factions,FMAK=FV.makers;
const TAGS={};
for(const [tk,t] of Object.entries(D.DATA)){
  const own=n=>{if(n.fx)return n.fx;
    if(tk==="people")return [...new Set([...FACS.filter(f=>f.bands.includes(n.f)).map(f=>f.k),...(FV.own.includes(n.m)?FMAK[n.m]||[]:[])])];
    return FMAK[n.m]||[]};
  const fam={};
  t.nodes.forEach(n=>{const g=own(n);if(g.length){const f=fam[n.f]=fam[n.f]||{},key=g.join(",");f[key]=(f[key]||0)+1}});
  t.nodes.forEach(n=>{let g=own(n);
    if(!g.length&&tk!=="conflicts"&&tk!=="mysteries"&&fam[n.f]){const best=Object.entries(fam[n.f]).sort((a,b)=>b[1]-a[1])[0];g=best[0].split(",")}
    TAGS[n.id]={tab:tk,fx:g,n:n}});
}
// deterministic hash of id -> 0..1
const h=s=>{let x=2166136261;for(const c of s){x^=c.charCodeAt(0);x=Math.imul(x,16777619)}return (x>>>0)/4294967296};
// Ending mix: K keep/allow a turn, P plain fact, O open/trailing, L let it run long
const END=['P','P','O','L','K','P','L','K'];
const cards=[];
for(const [id,{tab,fx,n}] of Object.entries(TAGS)){
  if(!n.x&&!n.z&&!n.t)continue;
  const v=h(id), primary=fx.length?fx[Math.floor(v*fx.length)]:'none';
  cards.push({id,tab,fx,voice:primary,end:END[Math.floor(h(id+'e')*END.length)],len:(n.x||'').length});
}
const tab=process.argv[3];
const sel=tab?cards.filter(c=>c.tab===tab):cards;
const cnt={};sel.forEach(c=>cnt[c.voice]=(cnt[c.voice]||0)+1);
console.log(sel.length,JSON.stringify(cnt));
fs.writeFileSync(process.argv[4]||'voice-cards.json',JSON.stringify(cards));
