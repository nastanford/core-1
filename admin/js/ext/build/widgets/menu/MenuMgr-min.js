/*
 * Ext JS Library 1.1 Beta 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */


Ext.menu.MenuMgr=function(){var _1,_2,_3={},_4=false,_5=new Date();function init(){_1={},_2=new Ext.util.MixedCollection();Ext.get(document).addKeyListener(27,function(){if(_2.length>0){hideAll();}});}function hideAll(){if(_2.length>0){var c=_2.clone();c.each(function(m){m.hide();});}}function onHide(m){_2.remove(m);if(_2.length<1){Ext.get(document).un("mousedown",onMouseDown);_4=false;}}function onShow(m){var _a=_2.last();_5=new Date();_2.add(m);if(!_4){Ext.get(document).on("mousedown",onMouseDown);_4=true;}if(m.parentMenu){m.getEl().setZIndex(parseInt(m.parentMenu.getEl().getStyle("z-index"),10)+3);m.parentMenu.activeChild=m;}else{if(_a&&_a.isVisible()){m.getEl().setZIndex(parseInt(_a.getEl().getStyle("z-index"),10)+3);}}}function onBeforeHide(m){if(m.activeChild){m.activeChild.hide();}if(m.autoHideTimer){clearTimeout(m.autoHideTimer);delete m.autoHideTimer;}}function onBeforeShow(m){var pm=m.parentMenu;if(!pm&&!m.allowOtherMenus){hideAll();}else{if(pm&&pm.activeChild){pm.activeChild.hide();}}}function onMouseDown(e){if(_5.getElapsed()>50&&_2.length>0&&!e.getTarget(".x-menu")){hideAll();}}function onBeforeCheck(mi,_10){if(_10){var g=_3[mi.group];for(var i=0,l=g.length;i<l;i++){if(g[i]!=mi){g[i].setChecked(false);}}}}return{hideAll:function(){hideAll();},register:function(_14){if(!_1){init();}_1[_14.id]=_14;_14.on("beforehide",onBeforeHide);_14.on("hide",onHide);_14.on("beforeshow",onBeforeShow);_14.on("show",onShow);var g=_14.group;if(g&&_14.events["checkchange"]){if(!_3[g]){_3[g]=[];}_3[g].push(_14);_14.on("checkchange",onCheck);}},get:function(_16){if(typeof _16=="string"){return _1[_16];}else{if(_16.events){return _16;}else{if(typeof _16.length=="number"){return new Ext.menu.Menu({items:_16});}else{return new Ext.menu.Menu(_16);}}}},unregister:function(_17){delete _1[_17.id];_17.un("beforehide",onBeforeHide);_17.un("hide",onHide);_17.un("beforeshow",onBeforeShow);_17.un("show",onShow);var g=_17.group;if(g&&_17.events["checkchange"]){_3[g].remove(_17);_17.un("checkchange",onCheck);}},registerCheckable:function(_19){var g=_19.group;if(g){if(!_3[g]){_3[g]=[];}_3[g].push(_19);_19.on("beforecheckchange",onBeforeCheck);}},unregisterCheckable:function(_1b){var g=_1b.group;if(g){_3[g].remove(_1b);_1b.un("beforecheckchange",onBeforeCheck);}}};}();