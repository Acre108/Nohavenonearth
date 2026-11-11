// node voice-apply.js atlas-data.json edits.json
// edits.json: {"<node id>": {"x": "new text", "z": "...", "t": "..."}} for DATA tree nodes.
// Replaces the field's current value on the node's own line; checks redaction bars are unchanged.
const fs=require('fs');const [,,file,ef]=process.argv;
let src=fs.readFileSync(file,'utf8');const D=JSON.parse(src);const E=JSON.parse(fs.readFileSync(ef,'utf8'));
const node={};for(const t of Object.values(D.DATA))for(const n of t.nodes)node[n.id]=n;
const lines=src.split('\n');let bad=0,done=0;
const bars=s=>(s.match(/█+/g)||[]).join('|');
for(const [id,fields] of Object.entries(E)){
  const n=node[id];if(!n){console.error('no node',id);bad++;continue;}
  const li=lines.findIndex(l=>l.includes(`{"id":${JSON.stringify(id)},`));
  if(li<0){console.error('no line',id);bad++;continue;}
  for(const [f,nv] of Object.entries(fields)){
    const ov=n[f];if(ov==null){console.error('no field',id,f);bad++;continue;}
    if(bars(ov)!==bars(nv)){console.error('redaction changed',id,f);bad++;continue;}
    if(/—/.test(nv)){console.error('em dash',id,f);bad++;continue;}
    const o=`"${f}":${JSON.stringify(ov)}`,k=lines[li].split(o).length-1;
    if(k!==1){console.error('match count',k,id,f);bad++;continue;}
    lines[li]=lines[li].replace(o,()=>`"${f}":${JSON.stringify(nv)}`);done++;
  }
}
if(bad){console.error(bad+' problems; nothing written');process.exit(1);}
const out=lines.join('\n');JSON.parse(out);fs.writeFileSync(file,out);console.log('applied',done);
