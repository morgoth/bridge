/*
Copyright (c) 2010, Yahoo! Inc. All rights reserved.
Code licensed under the BSD License:
http://developer.yahoo.com/yui/license.html
version: 3.1.2
build: 56
*/
YUI.add("base-build",function(D){var B=D.Base,A=D.Lang,C;B._build=function(F,L,P,T,S,O){var U=B._build,G=U._ctor(L,O),J=U._cfg(L,O),R=U._mixCust,N=J.aggregates,E=J.custom,I=G._yuibuild.dynamic,M,K,H,Q;if(I&&N){for(M=0,K=N.length;M<K;++M){H=N[M];if(L.hasOwnProperty(H)){G[H]=A.isArray(L[H])?[]:{};}}}for(M=0,K=P.length;M<K;M++){Q=P[M];D.mix(G,Q,true,null,1);R(G,Q,N,E);G._yuibuild.exts.push(Q);}if(T){D.mix(G.prototype,T,true);}if(S){D.mix(G,U._clean(S,N,E),true);R(G,S,N,E);}G.prototype.hasImpl=U._impl;if(I){G.NAME=F;G.prototype.constructor=G;}return G;};C=B._build;D.mix(C,{_mixCust:function(G,F,I,H){if(I){D.aggregate(G,F,true,I);}if(H){for(var E in H){if(H.hasOwnProperty(E)){H[E](E,G,F);}}}},_tmpl:function(E){function F(){F.superclass.constructor.apply(this,arguments);}D.extend(F,E);return F;},_impl:function(H){var K=this._getClasses(),J,F,E,I,L,G;for(J=0,F=K.length;J<F;J++){E=K[J];if(E._yuibuild){I=E._yuibuild.exts;L=I.length;for(G=0;G<L;G++){if(I[G]===H){return true;}}}}return false;},_ctor:function(E,F){var G=(F&&false===F.dynamic)?false:true,H=(G)?C._tmpl(E):E;H._yuibuild={id:null,exts:[],dynamic:G};return H;},_cfg:function(E,F){var G=[],J={},I,H=(F&&F.aggregates),L=(F&&F.custom),K=E;while(K&&K.prototype){I=K._buildCfg;if(I){if(I.aggregates){G=G.concat(I.aggregates);}if(I.custom){D.mix(J,I.custom,true);}}K=K.superclass?K.superclass.constructor:null;}if(H){G=G.concat(H);}if(L){D.mix(J,F.cfgBuild,true);}return{aggregates:G,custom:J};},_clean:function(K,J,G){var I,F,E,H=D.merge(K);for(I in G){if(H.hasOwnProperty(I)){delete H[I];}}for(F=0,E=J.length;F<E;F++){I=J[F];if(H.hasOwnProperty(I)){delete H[I];}}return H;}});B.build=function(G,E,H,F){return C(G,E,H,null,null,F);};B.create=function(E,H,G,F,I){return C(E,H,G,F,I);};B.mix=function(E,F){return C(null,E,F,null,null,{dynamic:false});};B._buildCfg={custom:{ATTRS:function(G,F,E){F[G]=F[G]||{};if(E[G]){D.aggregate(F[G],E[G],true);}}},aggregates:["_PLUG","_UNPLUG"]};},"3.1.2",{requires:["base-base"]});