/*
 * Ext JS Library 1.1 Beta 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */


Ext.Editor=function(_1,_2){Ext.Editor.superclass.constructor.call(this,_2);this.field=_1;this.addEvents({"beforestartedit":true,"startedit":true,"beforecomplete":true,"complete":true,"specialkey":true});};Ext.extend(Ext.Editor,Ext.Component,{value:"",alignment:"c-c?",shadow:"frame",constrain:false,updateEl:false,onRender:function(ct,_4){this.el=new Ext.Layer({shadow:this.shadow,cls:"x-editor",parentEl:ct,shim:this.shim,shadowOffset:4,id:this.id});this.el.setStyle("overflow",Ext.isGecko?"auto":"hidden");if(this.field.msgTarget!="title"){this.field.msgTarget="qtip";}this.field.render(this.el);if(Ext.isGecko){this.field.el.dom.setAttribute("autocomplete","off");}this.field.show();this.field.on("blur",this.onBlur,this);this.relayEvents(this.field,["specialkey"]);if(this.field.grow){this.field.on("autosize",this.el.sync,this.el,{delay:1});}},startEdit:function(el,_6){if(this.editing){this.completeEdit();}this.boundEl=Ext.get(el);var v=_6!==undefined?_6:this.boundEl.dom.innerHTML;if(!this.rendered){this.render(this.parentEl||document.body);}if(this.fireEvent("beforestartedit",this,this.boundEl,v)===false){return;}this.startValue=v;this.field.setValue(v);if(this.autoSize){var sz=this.boundEl.getSize();switch(this.autoSize){case"width":this.setSize(sz.width,"");break;case"height":this.setSize("",sz.height);break;default:this.setSize(sz.width,sz.height);}}this.el.alignTo(this.boundEl,this.alignment);this.editing=true;if(Ext.QuickTips){Ext.QuickTips.disable();}this.show();},setSize:function(w,h){this.field.setSize(w,h);if(this.el){this.el.sync();}},realign:function(){this.el.alignTo(this.boundEl,this.alignment);},completeEdit:function(_b){if(!this.editing){return;}var v=this.getValue();if(this.revertInvalid!==false&&!this.field.isValid()){v=this.startValue;this.cancelEdit(true);}if(String(v)==String(this.startValue)&&this.ignoreNoChange){this.editing=false;this.hide();return;}if(this.fireEvent("beforecomplete",this,v,this.startValue)!==false){this.editing=false;if(this.updateEl&&this.boundEl){this.boundEl.update(v);}if(_b!==true){this.hide();}this.fireEvent("complete",this,v,this.startValue);}},onShow:function(){this.el.show();if(this.hideEl!==false){this.boundEl.hide();}this.field.show();if(Ext.isIE&&!this.fixIEFocus){this.fixIEFocus=true;this.deferredFocus.defer(50,this);}else{this.field.focus();}this.fireEvent("startedit",this.boundEl,this.startValue);},deferredFocus:function(){if(this.editing){this.field.focus();}},cancelEdit:function(_d){if(this.editing){this.setValue(this.startValue);if(_d!==true){this.hide();}}},onBlur:function(){if(this.allowBlur!==true&&this.editing){this.completeEdit();}},onHide:function(){if(this.editing){this.completeEdit();return;}this.field.blur();if(this.field.collapse){this.field.collapse();}this.el.hide();if(this.hideEl!==false){this.boundEl.show();}if(Ext.QuickTips){Ext.QuickTips.enable();}},setValue:function(v){this.field.setValue(v);},getValue:function(){return this.field.getValue();}});