/*
 * Ext JS Library 1.1 Beta 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */


Ext.MenuButton=function(_1,_2){Ext.MenuButton.superclass.constructor.call(this,_1,_2);this.addEvents({"arrowclick":true});};Ext.extend(Ext.MenuButton,Ext.Button,{render:function(_3){var _4=new Ext.Template("<table cellspacing=\"0\" class=\"x-btn-menu-wrap x-btn\"><tr><td>","<table cellspacing=\"0\" class=\"x-btn-wrap x-btn-menu-text-wrap\"><tbody>","<tr><td class=\"x-btn-left\"><i>&#160;</i></td><td class=\"x-btn-center\"><button class=\"x-btn-text\" type=\"{1}\">{0}</button></td></tr>","</tbody></table></td><td>","<table cellspacing=\"0\" class=\"x-btn-wrap x-btn-menu-arrow-wrap\"><tbody>","<tr><td class=\"x-btn-center\"><button class=\"x-btn-menu-arrow-el\" type=\"button\">&#160;</button></td><td class=\"x-btn-right\"><i>&#160;</i></td></tr>","</tbody></table></td></tr></table>");var _5=_4.append(_3,[this.text,this.type],true);if(this.cls){_5.addClass(this.cls);}if(this.icon){_5.child("button").setStyle("background-image","url("+this.icon+")");}this.el=_5;if(this.handleMouseEvents){_5.on("mouseover",this.onMouseOver,this);_5.on("mouseout",this.onMouseOut,this);_5.on("mousedown",this.onMouseDown,this);_5.on("mouseup",this.onMouseUp,this);}_5.on(this.clickEvent,this.onClick,this);if(this.tooltip){var _6=_5.child("button:first");if(typeof this.tooltip=="object"){Ext.QuickTips.tips(Ext.apply({target:_6.id},this.tooltip));}else{_6.dom[this.tooltipType]=this.tooltip;}}if(this.arrowTooltip){var _6=_5.child("button:nth(2)");_6.dom[this.tooltipType]=this.arrowTooltip;}if(this.hidden){this.hide();}if(this.disabled){this.disable();}if(Ext.isIE&&!Ext.isIE7){this.autoWidth.defer(1,this);}else{this.autoWidth();}if(this.menu){this.menu.on("show",this.onMenuShow,this);this.menu.on("hide",this.onMenuHide,this);}},autoWidth:function(){if(this.el){var _7=this.el.child("table:first");var _8=this.el.child("table:last");this.el.setWidth("auto");_7.setWidth("auto");if(Ext.isIE7&&Ext.isStrict){var ib=this.el.child("button:first");if(ib&&ib.getWidth()>20){ib.clip();ib.setWidth(Ext.util.TextMetrics.measure(ib,this.text).width+ib.getFrameWidth("lr"));}}if(this.minWidth){if(this.hidden){this.el.beginMeasure();}if((_7.getWidth()+_8.getWidth())<this.minWidth){_7.setWidth(this.minWidth-_8.getWidth());}if(this.hidden){this.el.endMeasure();}}this.el.setWidth(_7.getWidth()+_8.getWidth());}},setHandler:function(_a,_b){this.handler=_a;this.scope=_b;},setArrowHandler:function(_c,_d){this.arrowHandler=_c;this.scope=_d;},focus:function(){if(this.el){this.el.child("button:first").focus();}},onClick:function(e){e.preventDefault();if(!this.disabled){if(e.getTarget(".x-btn-menu-arrow-wrap")){if(this.menu&&!this.menu.isVisible()){this.menu.show(this.el,this.menuAlign);}this.fireEvent("arrowclick",this,e);if(this.arrowHandler){this.arrowHandler.call(this.scope||this,this,e);}}else{this.fireEvent("click",this,e);if(this.handler){this.handler.call(this.scope||this,this,e);}}}},onMouseDown:function(e){if(!this.disabled){Ext.fly(e.getTarget("table")).addClass("x-btn-click");}},onMouseUp:function(e){Ext.fly(e.getTarget("table")).removeClass("x-btn-click");}});