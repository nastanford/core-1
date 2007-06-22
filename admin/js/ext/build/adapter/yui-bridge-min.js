/*
 * Ext JS Library 1.1 Beta 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */


if(typeof YAHOO=="undefined"){throw"Unable to load Ext, core YUI utilities (yahoo, dom, event) not found.";}(function(){var E=YAHOO.util.Event;var D=YAHOO.util.Dom;var CN=YAHOO.util.Connect;var ES=YAHOO.util.Easing;var A=YAHOO.util.Anim;var _6;Ext.lib.Dom={getViewWidth:function(_7){return _7?D.getDocumentWidth():D.getViewportWidth();},getViewHeight:function(_8){return _8?D.getDocumentHeight():D.getViewportHeight();},isAncestor:function(_9,_a){return D.isAncestor(_9,_a);},getRegion:function(el){return D.getRegion(el);},getY:function(el){return this.getXY(el)[1];},getX:function(el){return this.getXY(el)[0];},getXY:function(el){var p,pe,b,_12,bd=document.body;el=Ext.getDom(el);if(el.getBoundingClientRect){b=el.getBoundingClientRect();_12=fly(document).getScroll();return[b.left+_12.left,b.top+_12.top];}else{var x=el.offsetLeft,y=el.offsetTop;p=el.offsetParent;var _16=false;if(p!=el){while(p){x+=p.offsetLeft;y+=p.offsetTop;if(Ext.isSafari&&!_16&&fly(p).getStyle("position")=="absolute"){_16=true;}if(Ext.isGecko){pe=fly(p);var bt=parseInt(pe.getStyle("borderTopWidth"),10)||0;var bl=parseInt(pe.getStyle("borderLeftWidth"),10)||0;x+=bl;y+=bt;if(p!=el&&pe.getStyle("overflow")!="visible"){x+=bl;y+=bt;}}p=p.offsetParent;}}if(Ext.isSafari&&(_16||fly(el).getStyle("position")=="absolute")){x-=bd.offsetLeft;y-=bd.offsetTop;}}p=el.parentNode;while(p&&p!=bd){if(!Ext.isOpera||(Ext.isOpera&&p.tagName!="TR"&&fly(p).getStyle("display")!="inline")){x-=p.scrollLeft;y-=p.scrollTop;}if(Ext.isGecko){pe=fly(p);if(pe.getStyle("overflow")!="visible"){x+=parseInt(pe.getStyle("borderLeftWidth"),10)||0;y+=parseInt(pe.getStyle("borderTopWidth"),10)||0;}}p=p.parentNode;}return[x,y];},setXY:function(el,xy){el=Ext.fly(el,"_setXY");el.position();var pts=el.translatePoints(xy);if(xy[0]!==false){el.dom.style.left=pts.left+"px";}if(xy[1]!==false){el.dom.style.top=pts.top+"px";}},setX:function(el,x){this.setXY(el,[x,false]);},setY:function(el,y){this.setXY(el,[false,y]);}};Ext.lib.Event={getPageX:function(e){return E.getPageX(e.browserEvent||e);},getPageY:function(e){return E.getPageY(e.browserEvent||e);},getXY:function(e){return E.getXY(e.browserEvent||e);},getTarget:function(e){return E.getTarget(e.browserEvent||e);},getRelatedTarget:function(e){return E.getRelatedTarget(e.browserEvent||e);},on:function(el,_26,fn,_28,_29){E.on(el,_26,fn,_28,_29);},un:function(el,_2b,fn){E.removeListener(el,_2b,fn);},purgeElement:function(el){E.purgeElement(el);},preventDefault:function(e){E.preventDefault(e.browserEvent||e);},stopPropagation:function(e){E.stopPropagation(e.browserEvent||e);},stopEvent:function(e){E.stopEvent(e.browserEvent||e);},onAvailable:function(el,fn,_33,_34){return E.onAvailable(el,fn,_33,_34);}};Ext.lib.Ajax={request:function(_35,uri,cb,_38,_39){if(_39&&_39.headers){var hs=_39.headers;for(var h in hs){if(hs.hasOwnProperty(h)){CN.initHeader(h,hs[h],false);}}}return CN.asyncRequest(_35,uri,cb,_38);},formRequest:function(_3c,uri,cb,_3f,_40,_41){CN.setForm(_3c,_40,_41);return CN.asyncRequest(Ext.getDom(_3c).method||"POST",uri,cb,_3f);},isCallInProgress:function(_42){return CN.isCallInProgress(_42);},abort:function(_43){return CN.abort(_43);},serializeForm:function(_44){var d=CN.setForm(_44.dom||_44);CN.resetFormState();return d;}};Ext.lib.Region=YAHOO.util.Region;Ext.lib.Point=YAHOO.util.Point;Ext.lib.Anim={scroll:function(el,_47,_48,_49,cb,_4b){this.run(el,_47,_48,_49,cb,_4b,YAHOO.util.Scroll);},motion:function(el,_4d,_4e,_4f,cb,_51){this.run(el,_4d,_4e,_4f,cb,_51,YAHOO.util.Motion);},color:function(el,_53,_54,_55,cb,_57){this.run(el,_53,_54,_55,cb,_57,YAHOO.util.ColorAnim);},run:function(el,_59,_5a,_5b,cb,_5d,_5e){_5e=_5e||YAHOO.util.Anim;if(typeof _5b=="string"){_5b=YAHOO.util.Easing[_5b];}var _5f=new _5e(el,_59,_5a,_5b);_5f.animateX(function(){Ext.callback(cb,_5d);});return _5f;}};function fly(el){if(!_6){_6=new Ext.Element.Flyweight();}_6.dom=el;return _6;}if(Ext.isIE){YAHOO.util.Event.on(window,"unload",function(){var p=Function.prototype;delete p.createSequence;delete p.defer;delete p.createDelegate;delete p.createCallback;delete p.createInterceptor;});}if(YAHOO.util.Anim){YAHOO.util.Anim.prototype.animateX=function(_62,_63){var f=function(){this.onComplete.unsubscribe(f);if(typeof _62=="function"){_62.call(_63||this,this);}};this.onComplete.subscribe(f,this,true);this.animate();};}if(YAHOO.util.DragDrop&&Ext.dd.DragDrop){YAHOO.util.DragDrop.defaultPadding=Ext.dd.DragDrop.defaultPadding;YAHOO.util.DragDrop.constrainTo=Ext.dd.DragDrop.constrainTo;}YAHOO.util.Dom.getXY=function(el){var f=function(el){return Ext.lib.Dom.getXY(el);};return YAHOO.util.Dom.batch(el,f,YAHOO.util.Dom,true);};if(YAHOO.util.AnimMgr){YAHOO.util.AnimMgr.fps=1000;}YAHOO.util.Region.prototype.adjust=function(t,l,b,r){this.top+=t;this.left+=l;this.right+=r;this.bottom+=b;return this;};})();