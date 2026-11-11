// Flags kicker patterns (see docs/atlas-voice-guide.md) in every atlas string of 40+ characters.
// usage: node voice-sweep.js atlas-data.json hits.txt
const fs=require('fs');const D=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
const hits=[];
function walk(o,path){ if(Array.isArray(o)){o.forEach((v,i)=>walk(v,path+'['+i+']'));return;}
  if(o&&typeof o==='object'){for(const k of Object.keys(o)){if(k==='notes')continue;walk(o[k],path+'.'+k);}return;}
  if(typeof o!=='string'||o.length<40)return;
  const s=o.trim().split(/(?<=[.!?”"])\s+(?=[A-Z“"█])/);if(s.length<2)return;
  const last=s[s.length-1],prev=s[s.length-2],w=last.split(/\s+/).length;
  const r=[];
  if(/\b(nobody|no one|none of them|never)\b/i.test(last)&&w<=16)r.push('absolute');
  if(w<=6&&!/█/.test(last))r.push('short');
  if(/\bcalls? (it|them|him|her)\b[^.]*\.$/.test(prev)&&/\bcalls? (it|them|him|her)\b/.test(last))r.push('they-call');
  if(/; [^;]+ (did|does|didn't|doesn't|do|don't)( not)?\.$/.test(last))r.push('inversion');
  if(/\bwhich is (the point|often|why)\b/.test(last))r.push('which-is');
  if(/\b(So|And), [a-z]+ly,/.test(last))r.push('so-x');
  if(r.length)hits.push(`${r.join('+')} | ${path} | ${last}`);
}
walk(D,'');
fs.writeFileSync(process.argv[3],hits.join('\n'));console.log(hits.length);
