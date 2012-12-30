(function(){var Hamler,__slice=[].slice,__indexOf=[].indexOf||function(e){for(var t=0,n=this.length;t<n;t++)if(t in this&&this[t]===e)return t;return-1};Hamler=function(){function Hamler(e,t){this.options=t!=null?t:{};this.templates={};this.queue=[];if(e.indexOf("\n")===-1)this.loadResource(e);else{this.completed=!0;this.templates[0]=e;this.render(0,t)}return this}Hamler.prototype.loadResource=function(e){var t,n,r,i,s;t=window.jQuery||this.options.jQuery||!1;n=this;n.completed=!1;if(typeof require=="function")return require(["text!"+e],function(e){n.completed=!0;n.parseFile.call(n,e);return n.clearQueue()});if(t){r=t.ajax(e,{cache:(s=this.options.cache)!=null?s:!0,dataType:"text"});r.done(function(e){n.completed=!0;n.parseFile.call(n,e);return n.clearQueue()});return r}try{i=new XMLHttpRequest}catch(o){try{i=new ActiveXObject("Msxml2.XMLHTTP")}catch(o){try{i=new ActiveXObject("Microsoft.XMLHTTP")}catch(o){i=!1}}}if(!i)return null;try{i.open("get",e);i.onreadystatechange=function(e){if(i.readyState===4&&!n.completed){n.completed=!0;n.parseFile.call(n,i.responseText);return n.clearQueue()}};i.send(null)}catch(o){return!1}return i};Hamler.prototype.parseFile=function(e){var t,n,r,i,s,o,u,a,f;s=/^\${3}\s([a-zA-Z0-9]+)\s\${3}$/;r=e.split("\n");i=null;f=[];for(o=0,u=r.length;o<u;o++){n=r[o];if(s.test(n)){a=n.match(s),t=a[0],i=a[1];f.push(this.templates[i]=[])}else i?f.push(this.templates[i].push(n)):f.push(void 0)}return f};Hamler.prototype.clearQueue=function(){var e,t;t=[];while(this.queue.length){e=this.queue.shift();t.push(this.render(e.name,e.options))}return t};Hamler.prototype.render=function(e,t){var n,r,i;if(!this.completed){this.queue.push({name:e,options:t});return!1}r=(i=t.vars)!=null?i:{};n=this.haml(this.templates[e],r);return t.append?t.append.appendChild(n):t.prepend?t.prepend.insertBefore(n,t.prepend.firstChild):t.before?t.before.parentNode.insertBefore(n,t.before):t.after?t.after.parentNode.insertBefore(n,t.after.nextSibling):n};Hamler.prototype.haml=function(e,t){var n,r,i,s,o,u,a,f,l,c,h,p,d,v,m,g,y,b,w,E,S,x,T,N,C,k,L,A,O,M,_,D,P;g=!1;typeof e=="string"&&(e=e.split("\n"));c=0;d=-1;r=[document.createDocumentFragment()];a=[];for(u in e){h=e[u];f=h.match(/^[\s]+/);g===!1&&f!==null&&(g=f[0].length);c=0;f!==null&&(c=f[0].length/g);v=!0;for(w=0,T=a.length;w<T;w++){s=a[w];if(s.active===!1)continue;if(s.type==="each")if(c>s.level){s.collected.push(h.substr((s.level+1)*g));v=!1}else{s.active=!1;O=t[s.loop];for(E=0,N=O.length;E<N;E++){b=O[E];n=this.cloneObj(t);n[s.key]=b;r[s.level].appendChild(this.haml(s.collected,n))}}else if(c>s.level){s.show&&s.collected.push(h.substr((s.level+1)*g));v=!1}else{s.active=!1;if(s.collected.length){n=this.cloneObj(t);r[s.level].appendChild(this.haml(s.collected,n))}}}if(!v)continue;o=this.parseLine(h,t);if(typeof o=="string"){M=o.split("|"),y=M[0],i=2<=M.length?__slice.call(M,1):[];if(y==="if"||y==="elseif"||y==="else"){m=i[0];if(m==="o"){p=null;for(u=S=_=a.length-1;_<=0?S<=0:S>=0;u=_<=0?++S:--S){s=a[u];if(s.level===c&&s.type==="if"){p=s.show;break}}if(p===null)throw"Nothing to else or elseif from";m=p?"h":"s"}a.push({active:!0,level:c,show:m==="s",type:y,collected:[]})}else a.push({active:!0,level:c,type:"each",collected:[],loop:i[0],key:i[1]});continue}if(!o)continue;if(c<d){for(u=x=0,D=d-c;0<=D?x<D:x>D;u=0<=D?++x:--x){l=r.length;if(l<3)continue;r[l-2].appendChild(r[l-1]);r.splice(l-1,1)}r[r.length-2].appendChild(o);r[r.length-1]=o}else if(c===d){r[r.length-2].appendChild(o);r[r.length-1]=o}else{if(c-d!==1)throw"Too much indentation";r[r.length-1].appendChild(o);r.push(o)}d=c}for(L=0,C=a.length;L<C;L++){s=a[L];if(s.active===!1)continue;if(s.type==="each"){P=t[s.loop];for(A=0,k=P.length;A<k;A++){b=P[A];n=this.cloneObj(t);n[s.key]=b;r[s.level].appendChild(this.haml(s.collected,n));r.splice(s.level+1,Infinity)}}else if(s.collected.length){n=this.cloneObj(t);r[s.level].appendChild(this.haml(s.collected,n));r.splice(s.level+1,Infinity)}}return r[0]};Hamler.prototype.cloneObj=function(e){var t,n,r;t={};for(n in e){r=e[n];typeof r=="object"?t[n]=this.cloneObj(r):t[n]=r}return t};Hamler.prototype.parseLine=function(line,vars){var $v,action,attr,attrs,className,elm,nodeName,parsed,show,txt,val;$v=this.cloneObj(vars);line=line.replace(/^\s+/,"");if(line.length===0)return!1;parsed=line.match(/^(%[a-zA-Z0-9]+)?(\.[-\w\u00C0-\uFFFF]+)?(\#[-\w\u00C0-\uFFFF=$]+)?(\.[-\w\u00C0-\uFFFF]+)?((\{[^}]+\})|(\([^)]+\)))?(=?[\s]+[\s\S]+)?$/);if(parsed===null){if(line.indexOf("-")===0){action=line.match(/^\-\s+(if|unless|elseif|else|\$v\.([a-zA-Z0-9.]+)\.each\sdo\s\|([a-zA-Z0-9]+)\|)/);if(action===null)throw"Unrecognized control structure";if(!action[2]){if(action[1]==="if"||action[1]==="unless"){show=eval(line.substring(action[0].length));action[1]==="unless"&&(show=!show);return show?"if|s":"if|h"}if(action[1]==="elseif"){show=eval(line.substring(action[0].length));return show?"elseif|o":"elseif|h"}return"elseif|o"}return"each|"+action[2]+"|"+action[3]}return this.htmlify(line)}nodeName="div";parsed[1]&&(nodeName=parsed[1].substr(1));attrs={};className=(parsed[2]||"")+(parsed[4]||"");className=className.replace(/\./g," ").replace(/^\s+|\s+$/g,"");className.length&&(attrs["class"]=className);parsed[3]&&(attrs.id=parsed[3].substr(1));parsed[5]&&this.parseAttrs(attrs,parsed[5],$v);elm=document.createElement(nodeName);for(attr in attrs){val=attrs[attr];elm.setAttribute(attr,val)}if(parsed[8]){txt=parsed[8];txt.indexOf("=")===0&&(txt=eval(parsed[8].substr(1)));elm.appendChild(this.htmlify(txt))}return elm};Hamler.prototype.htmlify=function(e){var t,n;n=document.createDocumentFragment();t=document.createElement("div");t.innerHTML=e;n.appendChild(t);while(t.firstChild)n.appendChild(t.removeChild(t.firstChild));n.removeChild(t);return n};Hamler.prototype.parseAttrs=function(attrs,str,$v){var addUpUntil,addedUp,attr,i,ignoreSpaces,nextToken,part,parts,token,tokens,value,_i,_j,_len,_len1;tokens=str.substr(1,str.length-2).split("");addUpUntil="";addedUp="";parts=[];ignoreSpaces=!0;for(i=_i=0,_len=tokens.length;_i<_len;i=++_i){token=tokens[i];nextToken=i<tokens.length-1?tokens[i+1]:"";if(!ignoreSpaces||token!==" ")addedUp+=token;if(__indexOf.call(addUpUntil.split(""),token)>=0){parts.push(addedUp);addUpUntil="";addedUp="";ignoreSpaces=!0}else if(token===","&&!addUpUntil){parts.push(addedUp);addUpUntil="";addedUp="";ignoreSpaces=!0}else if(token==='"'&&!addUpUntil){addUpUntil='"';ignoreSpaces=!1}else if(token==="'"&&!addUpUntil){addUpUntil="'";ignoreSpaces=!1}else token===":"&&!addUpUntil?addUpUntil=">":token==="="&&!addUpUntil?addUpUntil=" ":token==="$"&&nextToken==="v"&&!addUpUntil&&(addUpUntil=", ")}attr=null;value=null;for(_j=0,_len1=parts.length;_j<_len1;_j++){part=parts[_j];if(part.indexOf('"')===0||part.indexOf("'")===0)value=part.substr(1,part.length-2);else if(part.indexOf("$v")===0){part.lastIndexOf(",")===part.length-1&&(part=part.substr(0,part.length-1));value=eval(part)}else{part.indexOf(":")===0?attr=part.substr(1,part.length-3):attr=part.substr(0,part.length-1);value=null}if(attr&&value){attrs[attr]=value;attr=null;value=null}}};return Hamler}();window.Hamler=Hamler;typeof define=="function"&&define.amd&&define("Hamler",function(){return Hamler})}).call(this);