(()=>{"use strict";var e,t,r,o,a,n={},f={};function i(e){var t=f[e];if(void 0!==t)return t.exports;var r=f[e]={exports:{}};return n[e].call(r.exports,r,r.exports,i),r.exports}i.m=n,e=[],i.O=(t,r,o,a)=>{if(!r){var n=1/0;for(u=0;u<e.length;u++){r=e[u][0],o=e[u][1],a=e[u][2];for(var f=!0,c=0;c<r.length;c++)(!1&a||n>=a)&&Object.keys(i.O).every((e=>i.O[e](r[c])))?r.splice(c--,1):(f=!1,a<n&&(n=a));if(f){e.splice(u--,1);var d=o();void 0!==d&&(t=d)}}return t}a=a||0;for(var u=e.length;u>0&&e[u-1][2]>a;u--)e[u]=e[u-1];e[u]=[r,o,a]},i.n=e=>{var t=e&&e.__esModule?()=>e.default:()=>e;return i.d(t,{a:t}),t},r=Object.getPrototypeOf?e=>Object.getPrototypeOf(e):e=>e.__proto__,i.t=function(e,o){if(1&o&&(e=this(e)),8&o)return e;if("object"==typeof e&&e){if(4&o&&e.__esModule)return e;if(16&o&&"function"==typeof e.then)return e}var a=Object.create(null);i.r(a);var n={};t=t||[null,r({}),r([]),r(r)];for(var f=2&o&&e;"object"==typeof f&&!~t.indexOf(f);f=r(f))Object.getOwnPropertyNames(f).forEach((t=>n[t]=()=>e[t]));return n.default=()=>e,i.d(a,n),a},i.d=(e,t)=>{for(var r in t)i.o(t,r)&&!i.o(e,r)&&Object.defineProperty(e,r,{enumerable:!0,get:t[r]})},i.f={},i.e=e=>Promise.all(Object.keys(i.f).reduce(((t,r)=>(i.f[r](e,t),t)),[])),i.u=e=>"assets/js/"+({6:"36b89c81",53:"935f2afb",85:"1f391b9e",119:"53ff8a57",237:"1df93b7f",281:"17f1956f",347:"12de342b",414:"393be207",426:"febef4e2",468:"8c66a02b",504:"0186cd1a",510:"0e3c5954",514:"1be78505",680:"30d88020",705:"6df6864c",787:"f22f2266",817:"14eb3368",918:"17896441"}[e]||e)+"."+{6:"625b70df",53:"760ba1e8",85:"ac938147",119:"ad3b4b82",237:"b3c5f59f",281:"dfdb4b73",347:"cbcac33d",414:"2bffe0ea",426:"b9082ffc",455:"e9522fd9",468:"85005cd3",504:"0ffbb25b",510:"5948cf15",514:"55c596c7",680:"22be9a28",705:"819d4147",787:"6e2fac2b",817:"7e03ae12",918:"0464a250",972:"05015f83"}[e]+".js",i.miniCssF=e=>{},i.g=function(){if("object"==typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"==typeof window)return window}}(),i.o=(e,t)=>Object.prototype.hasOwnProperty.call(e,t),o={},a="documentation:",i.l=(e,t,r,n)=>{if(o[e])o[e].push(t);else{var f,c;if(void 0!==r)for(var d=document.getElementsByTagName("script"),u=0;u<d.length;u++){var b=d[u];if(b.getAttribute("src")==e||b.getAttribute("data-webpack")==a+r){f=b;break}}f||(c=!0,(f=document.createElement("script")).charset="utf-8",f.timeout=120,i.nc&&f.setAttribute("nonce",i.nc),f.setAttribute("data-webpack",a+r),f.src=e),o[e]=[t];var l=(t,r)=>{f.onerror=f.onload=null,clearTimeout(s);var a=o[e];if(delete o[e],f.parentNode&&f.parentNode.removeChild(f),a&&a.forEach((e=>e(r))),t)return t(r)},s=setTimeout(l.bind(null,void 0,{type:"timeout",target:f}),12e4);f.onerror=l.bind(null,f.onerror),f.onload=l.bind(null,f.onload),c&&document.head.appendChild(f)}},i.r=e=>{"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},i.p="/BramblDart/",i.gca=function(e){return e={17896441:"918","36b89c81":"6","935f2afb":"53","1f391b9e":"85","53ff8a57":"119","1df93b7f":"237","17f1956f":"281","12de342b":"347","393be207":"414",febef4e2:"426","8c66a02b":"468","0186cd1a":"504","0e3c5954":"510","1be78505":"514","30d88020":"680","6df6864c":"705",f22f2266:"787","14eb3368":"817"}[e]||e,i.p+i.u(e)},(()=>{var e={303:0,532:0};i.f.j=(t,r)=>{var o=i.o(e,t)?e[t]:void 0;if(0!==o)if(o)r.push(o[2]);else if(/^(303|532)$/.test(t))e[t]=0;else{var a=new Promise(((r,a)=>o=e[t]=[r,a]));r.push(o[2]=a);var n=i.p+i.u(t),f=new Error;i.l(n,(r=>{if(i.o(e,t)&&(0!==(o=e[t])&&(e[t]=void 0),o)){var a=r&&("load"===r.type?"missing":r.type),n=r&&r.target&&r.target.src;f.message="Loading chunk "+t+" failed.\n("+a+": "+n+")",f.name="ChunkLoadError",f.type=a,f.request=n,o[1](f)}}),"chunk-"+t,t)}},i.O.j=t=>0===e[t];var t=(t,r)=>{var o,a,n=r[0],f=r[1],c=r[2],d=0;if(n.some((t=>0!==e[t]))){for(o in f)i.o(f,o)&&(i.m[o]=f[o]);if(c)var u=c(i)}for(t&&t(r);d<n.length;d++)a=n[d],i.o(e,a)&&e[a]&&e[a][0](),e[a]=0;return i.O(u)},r=self.webpackChunkdocumentation=self.webpackChunkdocumentation||[];r.forEach(t.bind(null,0)),r.push=t.bind(null,r.push.bind(r))})()})();