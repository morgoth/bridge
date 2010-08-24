/*
Copyright (c) 2010, Yahoo! Inc. All rights reserved.
Code licensed under the BSD License:
http://developer.yahoo.com/yui/license.html
version: 3.1.2
build: 56
*/
YUI.add("widget-position-align",function(A){var H=A.Lang,D="align",F="bindUI",B="syncUI",E="offsetWidth",I="offsetHeight",K="viewportRegion",G="region",J="alignChange";function C(L){if(!this._posNode){A.error("WidgetPosition needs to be added to the Widget, before WidgetPositionAlign is added");}A.after(this._syncUIPosAlgin,this,B);A.after(this._bindUIPosAlign,this,F);}C.ATTRS={align:{value:null},centered:{setter:"_setAlignCenter",lazyAdd:false,value:false}};C.TL="tl";C.TR="tr";C.BL="bl";C.BR="br";C.TC="tc";C.RC="rc";C.BC="bc";C.LC="lc";C.CC="cc";C.prototype={_syncUIPosAlgin:function(){var L=this.get(D);if(L){this._uiSetAlign(L.node,L.points);}},_bindUIPosAlign:function(){this.after(J,this._afterAlignChange);},_setAlignCenter:function(L){if(L){this.set(D,{node:L===true?null:L,points:[C.CC,C.CC]});}return L;},_afterAlignChange:function(L){if(L.newVal){this._uiSetAlign(L.newVal.node,L.newVal.points);}},_uiSetAlign:function(O,N){if(!H.isArray(N)||N.length!=2){A.error("align: Invalid Points Arguments");return;}var M=this._getRegion(O),L,P,Q;if(M){L=N[0];P=N[1];switch(P){case C.TL:Q=[M.left,M.top];break;case C.TR:Q=[M.right,M.top];break;case C.BL:Q=[M.left,M.bottom];break;case C.BR:Q=[M.right,M.bottom];break;case C.TC:Q=[M.left+Math.floor(M.width/2),M.top];break;case C.BC:Q=[M.left+Math.floor(M.width/2),M.bottom];break;case C.LC:Q=[M.left,M.top+Math.floor(M.height/2)];break;case C.RC:Q=[M.right,M.top+Math.floor(M.height/2),L];break;case C.CC:Q=[M.left+Math.floor(M.width/2),M.top+Math.floor(M.height/2),L];break;default:break;}if(Q){this._doAlign(L,Q[0],Q[1]);}}},_doAlign:function(M,L,P){var O=this._posNode,N;switch(M){case C.TL:N=[L,P];break;case C.TR:N=[L-O.get(E),P];break;case C.BL:N=[L,P-O.get(I)];break;case C.BR:N=[L-O.get(E),P-O.get(I)];break;case C.TC:N=[L-(O.get(E)/2),P];break;case C.BC:N=[L-(O.get(E)/2),P-O.get(I)];break;case C.LC:N=[L,P-(O.get(I)/2)];break;case C.RC:N=[(L-O.get(E)),P-(O.get(I)/2)];break;case C.CC:N=[L-(O.get(E)/2),P-(O.get(I)/2)];break;default:break;}if(N){this.move(N);}},_getRegion:function(M){var L;if(!M){L=this._posNode.get(K);}else{M=A.Node.one(M);if(M){L=M.get(G);}}return L;},align:function(M,L){this.set(D,{node:M,points:L});},centered:function(L){this.align(L,[C.CC,C.CC]);}};A.WidgetPositionAlign=C;},"3.1.2",{requires:["widget","widget-position"]});