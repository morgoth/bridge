/*
Copyright (c) 2010, Yahoo! Inc. All rights reserved.
Code licensed under the BSD License:
http://developer.yahoo.com/yui/license.html
version: 3.1.2
build: 56
*/
YUI.add("json-stringify",function(B){var I=(B.config.win||{}).JSON,k=B.Lang,M=k.isFunction,f=k.isObject,R=k.isArray,J=Object.prototype.toString,Z=(J.call(I)==="[object JSON]"&&I),c=!!Z,a="undefined",O="object",W="null",i="string",X="number",S="boolean",K="date",b={"undefined":a,"string":i,"[object String]":i,"number":X,"[object Number]":X,"boolean":S,"[object Boolean]":S,"[object Date]":K,"[object RegExp]":O},F="",N="{",A="}",U="[",H="]",P=",",C=",\n",L="\n",d=":",G=": ",Q='"',E=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,D={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"};function l(e){var Y=typeof e;return b[Y]||b[J.call(e)]||(Y===O?(e?O:W):a);}function h(Y){if(!D[Y]){D[Y]="\\u"+("0000"+(+(Y.charCodeAt(0))).toString(16)).slice(-4);}return D[Y];}function T(Y){return Q+Y.replace(E,h)+Q;}function V(Y,e){return Y.replace(/^/gm,e);}function g(e,u,Y){if(e===undefined){return undefined;}var n=M(u)?u:null,t=J.call(Y).match(/String|Number/)||[],v=B.JSON.dateToString,s=[],q,p,r;if(n||!R(u)){u=undefined;}if(u){q={};for(p=0,r=u.length;p<r;++p){q[u[p]]=true;}u=q;}Y=t[0]==="Number"?new Array(Math.min(Math.max(0,Y),10)+1).join(" "):(Y||F).slice(0,10);function m(x,AD){var AB=x[AD],AF=l(AB),AA=[],z=Y?G:d,y,w,AE,o,AC;if(f(AB)&&M(AB.toJSON)){AB=AB.toJSON(AD);}else{if(AF===K){AB=v(AB);}}if(M(n)){AB=n.call(x,AD,AB);}if(AB!==x[AD]){AF=l(AB);}switch(AF){case K:case O:break;case i:return T(AB);case X:return isFinite(AB)?AB+F:W;case S:return AB+F;case W:return W;default:return undefined;}for(w=s.length-1;w>=0;--w){if(s[w]===AB){throw new Error("JSON.stringify. Cyclical reference");}}y=R(AB);s.push(AB);if(y){for(w=AB.length-1;w>=0;--w){AA[w]=m(AB,w)||W;}}else{AE=u||AB;w=0;for(o in AE){if(AE.hasOwnProperty(o)){AC=m(AB,o);if(AC){AA[w++]=T(o)+z+AC;}}}}s.pop();if(Y&&AA.length){return y?U+L+V(AA.join(C),Y)+L+H:N+L+V(AA.join(C),Y)+L+A;}else{return y?U+AA.join(P)+H:N+AA.join(P)+A;}}return m({"":e},"");}if(Z){try{c=("0"===Z.stringify(0));}catch(j){c=false;}}B.mix(B.namespace("JSON"),{useNativeStringify:c,dateToString:function(e){function Y(m){return m<10?"0"+m:m;}return e.getUTCFullYear()+"-"+Y(e.getUTCMonth()+1)+"-"+Y(e.getUTCDate())+"T"+Y(e.getUTCHours())+d+Y(e.getUTCMinutes())+d+Y(e.getUTCSeconds())+"Z";},stringify:function(m,Y,e){return Z&&B.JSON.useNativeStringify?Z.stringify(m,Y,e):g(m,Y,e);}});},"3.1.2");