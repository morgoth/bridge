/*
Copyright (c) 2010, Yahoo! Inc. All rights reserved.
Code licensed under the BSD License:
http://developer.yahoo.com/yui/license.html
version: 3.1.2
build: 56
*/
YUI.add("anim-base",function(B){var C="running",N="startTime",L="elapsedTime",J="start",I="tween",M="end",D="node",K="paused",P="reverse",H="iterationCount",A=Number;var F={},O={},E;B.Anim=function(){B.Anim.superclass.constructor.apply(this,arguments);O[B.stamp(this)]=this;};B.Anim.NAME="anim";B.Anim.RE_DEFAULT_UNIT=/^width|height|top|right|bottom|left|margin.*|padding.*|border.*$/i;B.Anim.DEFAULT_UNIT="px";B.Anim.DEFAULT_EASING=function(R,Q,T,S){return T*R/S+Q;};B.Anim._intervalTime=20;B.Anim.behaviors={left:{get:function(R,Q){return R._getOffset(Q);}}};B.Anim.behaviors.top=B.Anim.behaviors.left;B.Anim.DEFAULT_SETTER=function(U,R,X,W,Q,V,S,T){T=T||"";U._node.setStyle(R,S(Q,A(X),A(W)-A(X),V)+T);};B.Anim.DEFAULT_GETTER=function(Q,R){return Q._node.getComputedStyle(R);};B.Anim.ATTRS={node:{setter:function(Q){Q=B.one(Q);this._node=Q;if(!Q){}return Q;}},duration:{value:1},easing:{value:B.Anim.DEFAULT_EASING,setter:function(Q){if(typeof Q==="string"&&B.Easing){return B.Easing[Q];}}},from:{},to:{},startTime:{value:0,readOnly:true},elapsedTime:{value:0,readOnly:true},running:{getter:function(){return !!F[B.stamp(this)];},value:false,readOnly:true},iterations:{value:1},iterationCount:{value:0,readOnly:true},direction:{value:"normal"},paused:{readOnly:true,value:false},reverse:{value:false}};B.Anim.run=function(){for(var Q in O){if(O[Q].run){O[Q].run();}}};B.Anim.pause=function(){for(var Q in F){if(F[Q].pause){F[Q].pause();}}B.Anim._stopTimer();};B.Anim.stop=function(){for(var Q in F){if(F[Q].stop){F[Q].stop();}}B.Anim._stopTimer();};B.Anim._startTimer=function(){if(!E){E=setInterval(B.Anim._runFrame,B.Anim._intervalTime);}};B.Anim._stopTimer=function(){clearInterval(E);E=0;};B.Anim._runFrame=function(){var Q=true;for(var R in F){if(F[R]._runFrame){Q=false;F[R]._runFrame();}}if(Q){B.Anim._stopTimer();}};B.Anim.RE_UNITS=/^(-?\d*\.?\d*){1}(em|ex|px|in|cm|mm|pt|pc|%)*$/;var G={run:function(){if(this.get(K)){this._resume();}else{if(!this.get(C)){this._start();}}return this;},pause:function(){if(this.get(C)){this._pause();}return this;},stop:function(Q){if(this.get(C)||this.get(K)){this._end(Q);}return this;},_added:false,_start:function(){this._set(N,new Date()-this.get(L));this._actualFrames=0;if(!this.get(K)){this._initAnimAttr();}F[B.stamp(this)]=this;B.Anim._startTimer();this.fire(J);},_pause:function(){this._set(N,null);this._set(K,true);delete F[B.stamp(this)];this.fire("pause");},_resume:function(){this._set(K,false);F[B.stamp(this)]=this;this.fire("resume");},_end:function(Q){var R=this.get("duration")*1000;if(Q){this._runAttrs(R,R,this.get(P));}this._set(N,null);this._set(L,0);this._set(K,false);delete F[B.stamp(this)];this.fire(M,{elapsed:this.get(L)});},_runFrame:function(){var U=this._runtimeAttr.duration,S=new Date()-this.get(N),R=this.get(P),Q=(S>=U),T,V;this._runAttrs(S,U,R);this._actualFrames+=1;this._set(L,S);this.fire(I);if(Q){this._lastFrame();}},_runAttrs:function(Z,Y,V){var W=this._runtimeAttr,S=B.Anim.behaviors,X=W.easing,Q=Y,R,T,U;if(V){Z=Y-Z;Q=0;}for(U in W){if(W[U].to){R=W[U];T=(U in S&&"set" in S[U])?S[U].set:B.Anim.DEFAULT_SETTER;if(Z<Y){T(this,U,R.from,R.to,Z,Y,X,R.unit);}else{T(this,U,R.from,R.to,Q,Y,X,R.unit);}}}},_lastFrame:function(){var Q=this.get("iterations"),R=this.get(H);R+=1;if(Q==="infinite"||R<Q){if(this.get("direction")==="alternate"){this.set(P,!this.get(P));}this.fire("iteration");}else{R=0;this._end();}this._set(N,new Date());this._set(H,R);},_initAnimAttr:function(){var X=this.get("from")||{},W=this.get("to")||{},Q={duration:this.get("duration")*1000,easing:this.get("easing")},S=B.Anim.behaviors,V=this.get(D),U,T,R;B.each(W,function(b,Z){if(typeof b==="function"){b=b.call(this,V);}T=X[Z];if(T===undefined){T=(Z in S&&"get" in S[Z])?S[Z].get(this,Z):B.Anim.DEFAULT_GETTER(this,Z);}else{if(typeof T==="function"){T=T.call(this,V);}}var Y=B.Anim.RE_UNITS.exec(T);var a=B.Anim.RE_UNITS.exec(b);T=Y?Y[1]:T;R=a?a[1]:b;U=a?a[2]:Y?Y[2]:"";if(!U&&B.Anim.RE_DEFAULT_UNIT.test(Z)){U=B.Anim.DEFAULT_UNIT;}if(!T||!R){B.error('invalid "from" or "to" for "'+Z+'"',"Anim");return;}Q[Z]={from:T,to:R,unit:U};},this);this._runtimeAttr=Q;},_getOffset:function(R){var T=this._node,U=T.getComputedStyle(R),S=(R==="left")?"getX":"getY",V=(R==="left")?"setX":"setY";if(U==="auto"){var Q=T.getStyle("position");if(Q==="absolute"||Q==="fixed"){U=T[S]();T[V](U);}else{U=0;}}return U;}};B.extend(B.Anim,B.Base,G);},"3.1.2",{requires:["base-base","node-style"]});