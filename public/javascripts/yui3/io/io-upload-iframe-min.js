/*
Copyright (c) 2010, Yahoo! Inc. All rights reserved.
Code licensed under the BSD License:
http://developer.yahoo.com/yui/license.html
version: 3.1.2
build: 56
*/
YUI.add("io-upload-iframe",function(B){var J=B.config.win,F=B.config.doc;function D(Q,P){var R=[],M=P.split("="),O,N;for(O=0,N=M.length-1;O<N;O++){R[O]=F.createElement("input");R[O].type="hidden";R[O].name=M[O].substring(M[O].lastIndexOf("&")+1);R[O].value=(O+1===N)?M[O+1]:M[O+1].substring(0,(M[O+1].lastIndexOf("&")));Q.appendChild(R[O]);}return R;}function G(O,P){var N,M;for(N=0,M=P.length;N<M;N++){O.removeChild(P[N]);}}function E(O,P,N){var M=(F.documentMode&&F.documentMode===8)?true:false;O.setAttribute("action",N);O.setAttribute("method","POST");O.setAttribute("target","ioupload"+P);O.setAttribute(B.UA.ie&&!M?"encoding":"enctype","multipart/form-data");}function L(N,M){var O;for(O in M){if(M.hasOwnProperty(M,O)){if(M[O]){N.setAttribute(O,N[O]);}else{N.removeAttribute(O);}}}}function K(N,O){var M=B.Node.create('<iframe id="ioupload'+N.id+'" name="ioupload'+N.id+'" />');M._node.style.position="absolute";M._node.style.top="-1000px";M._node.style.left="-1000px";B.one("body").appendChild(M);B.on("load",function(){A(N,O);},"#ioupload"+N.id);}function A(P,Q){var O=B.one("#ioupload"+P.id).get("contentWindow.document"),M=O.one("body"),N;if(Q.timeout){I(P.id);}if(M){N=M.query("pre:first-child");P.c.responseText=N?N.get("innerHTML"):M.get("innerHTML");}else{P.c.responseXML=O._node;}B.io.complete(P,Q);B.io.end(P,Q);J.setTimeout(function(){H(P.id);},0);}function C(M,N){B.io._timeout[M.id]=J.setTimeout(function(){var O={id:M.id,status:"timeout"};B.io.complete(O,N);B.io.end(O,N);},N.timeout);}function I(M){J.clearTimeout(B.io._timeout[M]);delete B.io._timeout[M];}function H(M){B.Event.purgeElement("#ioupload"+M,false);B.one("body").removeChild(B.one("#ioupload"+M));}B.mix(B.io,{_upload:function(Q,O,R){var P=(typeof R.form.id==="string")?F.getElementById(R.form.id):R.form.id,N,M={action:P.getAttribute("action"),target:P.getAttribute("target")};K(Q,R);E(P,Q.id,O);if(R.data){N=D(P,R.data);}if(R.timeout){C(Q,R);}P.submit();B.io.start(Q.id,R);if(R.data){G(P,N);}L(P,M);return{id:Q.id,abort:function(){var S={id:Q.id,status:"abort"};if(B.one("#ioupload"+Q.id)){H(Q.id);B.io.complete(S,R);B.io.end(S,R);}else{return false;}},isInProgress:function(){return B.one("#ioupload"+Q.id)?true:false;}};}});},"3.1.2",{requires:["io-base","node-base"]});