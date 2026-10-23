const http=require("http"),fs=require("fs"),path=require("path");
const root=process.argv[2];
http.createServer((q,r)=>{const p=path.join(root,decodeURIComponent(q.url.split("?")[0]==="/"?"/index.html":q.url.split("?")[0]));
 fs.readFile(p,(e,d)=>{if(e){r.writeHead(404);r.end();return}r.writeHead(200,{"Content-Type":p.endsWith(".html")?"text/html; charset=utf-8":p.endsWith(".json")?"application/json":"application/octet-stream"});r.end(d)})}).listen(8765);
