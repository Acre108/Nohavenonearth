// node voice-apply.js atlas-data.json edits.json
// edits.json: {"<node id>": {"x": "new text", "z": "...", "t": "..."}} for DATA tree nodes.
// Replaces the field's current value on the node's own line; checks redaction bars are unchanged.
const fs=require('fs');const [,,file,ef]=process.argv;
let src=fs.readFileSync(file,'utf8');const D=JSON.parse(src);const E=JSON.parse(fs.readFileSync(ef,'utf8'));
const bars=s=>(s.match(/█+/g)||[]).join('|');
// Array mode, for text outside DATA (ACES, CHRONO, POWERS, SPACE, TIMELINE, SCENES, MINOR):
// [["exact old text", "new text"], ...]; each old text must occur exactly once in the file.
if(Array.isArray(E)){let bad=0;
  for(const [ov,nv] of E){
    // Whole string value first; failing that, a unique run of text inside one value.
    let o=JSON.stringify(ov),n=JSON.stringify(nv),k=src.split(o).length-1;
    if(k===0){o=o.slice(1,-1);n=n.slice(1,-1);k=src.split(o).length-1;}
    if(k!==1){console.error('match count',k,ov.slice(0,70));bad++;continue;}
    if(bars(ov)!==bars(nv)){console.error('redaction changed',ov.slice(0,70));bad++;continue;}
    if(/—/.test(nv)){console.error('em dash',nv.slice(0,70));bad++;continue;}
    src=src.replace(o,()=>n);}
  if(bad){console.error(bad+' problems; nothing written');process.exit(1);}
  JSON.parse(src);fs.writeFileSync(file,src);console.log('applied',E.length);process.exit(0);}
const node={};for(const t of Object.values(D.DATA))for(const n of t.nodes)node[n.id]=n;
const lines=src.split('\n');let bad=0,done=0;
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
