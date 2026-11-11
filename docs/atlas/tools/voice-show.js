// node voice-show.js atlas-data.json tab [from] [count] [voice-cards.json] -> prints cards with tone/ending codes
const fs=require('fs');const D=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
const C=Object.fromEntries(JSON.parse(fs.readFileSync(process.argv[6]||'voice-cards.json','utf8')).map(c=>[c.id,c]));
const tab=process.argv[3],from=+(process.argv[4]||0),cnt=+(process.argv[5]||999);
for(const n of D.DATA[tab].nodes.slice(from,from+cnt)){const c=C[n.id]||{};
  console.log(`\n## ${n.id} [${c.voice}/${c.end}] ${n.n} — t: ${n.t||''}`);
  if(n.x)console.log('x: '+n.x); if(n.z)console.log('z: '+n.z);}
