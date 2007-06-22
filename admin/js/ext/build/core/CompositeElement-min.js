/*
 * Ext JS Library 1.1 Beta 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */


Ext.CompositeElement=function(_1){this.elements=[];this.addElements(_1);};Ext.CompositeElement.prototype={isComposite:true,addElements:function(_2){if(!_2){return this;}if(typeof _2=="string"){_2=Ext.Element.selectorFunction(_2);}var _3=this.elements;var _4=_3.length-1;for(var i=0,_6=_2.length;i<_6;i++){_3[++_4]=Ext.get(_2[i],true);}return this;},invoke:function(fn,_8){var _9=this.elements;for(var i=0,_b=_9.length;i<_b;i++){Ext.Element.prototype[fn].apply(_9[i],_8);}return this;},add:function(_c){if(typeof _c=="string"){this.addElements(Ext.Element.selectorFunction(_c));}else{if(_c.length!==undefined){this.addElements(_c);}else{this.addElements([_c]);}}return this;},each:function(fn,_e){var _f=this.elements;for(var i=0,len=_f.length;i<len;i++){if(fn.call(_e||_f[i],_f[i],this,i)===false){break;}}return this;},item:function(_12){return this.elements[_12];}};(function(){Ext.CompositeElement.createCall=function(_13,_14){if(!_13[_14]){_13[_14]=function(){return this.invoke(_14,arguments);};}};for(var _15 in Ext.Element.prototype){if(typeof Ext.Element.prototype[_15]=="function"){Ext.CompositeElement.createCall(Ext.CompositeElement.prototype,_15);}}})();Ext.CompositeElementLite=function(els){Ext.CompositeElementLite.superclass.constructor.call(this,els);var _17=function(){};_17.prototype=Ext.Element.prototype;this.el=new Ext.Element.Flyweight();};Ext.extend(Ext.CompositeElementLite,Ext.CompositeElement,{addElements:function(els){if(els){if(els instanceof Array){this.elements=this.elements.concat(els);}else{var _19=this.elements;var _1a=_19.length-1;for(var i=0,len=els.length;i<len;i++){_19[++_1a]=els[i];}}}return this;},invoke:function(fn,_1e){var els=this.elements;var el=this.el;for(var i=0,len=els.length;i<len;i++){el.dom=els[i];Ext.Element.prototype[fn].apply(el,_1e);}return this;},item:function(_23){this.el.dom=this.elements[_23];return this.el;},addListener:function(_24,_25,_26,opt){var els=this.elements;for(var i=0,len=els.length;i<len;i++){Ext.EventManager.on(els[i],_24,_25,_26||els[i],opt);}return this;},each:function(fn,_2c){var els=this.elements;var el=this.el;for(var i=0,len=els.length;i<len;i++){el.dom=els[i];if(fn.call(_2c||el,el,this,i)===false){break;}}return this;}});Ext.CompositeElementLite.prototype.on=Ext.CompositeElementLite.prototype.addListener;if(Ext.DomQuery){Ext.Element.selectorFunction=Ext.DomQuery.select;}Ext.Element.select=function(_31,_32,_33){var els;if(typeof _31=="string"){els=Ext.Element.selectorFunction(_31,_33);}else{if(_31.length!==undefined){els=_31;}else{throw"Invalid selector";}}if(_32===true){return new Ext.CompositeElement(els);}else{return new Ext.CompositeElementLite(els);}};Ext.select=Ext.Element.select;