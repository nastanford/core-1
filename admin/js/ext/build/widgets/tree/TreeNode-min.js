/*
 * Ext JS Library 1.1 Beta 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */


Ext.tree.TreeNode=function(_1){_1=_1||{};if(typeof _1=="string"){_1={text:_1};}this.childrenRendered=false;this.rendered=false;Ext.tree.TreeNode.superclass.constructor.call(this,_1);this.expanded=_1.expanded===true;this.isTarget=_1.isTarget!==false;this.draggable=_1.draggable!==false&&_1.allowDrag!==false;this.allowChildren=_1.allowChildren!==false&&_1.allowDrop!==false;this.text=_1.text;this.disabled=_1.disabled===true;this.addEvents({"textchange":true,"beforeexpand":true,"beforecollapse":true,"expand":true,"disabledchange":true,"collapse":true,"beforeclick":true,"click":true,"dblclick":true,"contextmenu":true,"beforechildrenrendered":true});var _2=this.attributes.uiProvider||Ext.tree.TreeNodeUI;this.ui=new _2(this);};Ext.extend(Ext.tree.TreeNode,Ext.data.Node,{preventHScroll:true,isExpanded:function(){return this.expanded;},getUI:function(){return this.ui;},setFirstChild:function(_3){var of=this.firstChild;Ext.tree.TreeNode.superclass.setFirstChild.call(this,_3);if(this.childrenRendered&&of&&_3!=of){of.renderIndent(true,true);}if(this.rendered){this.renderIndent(true,true);}},setLastChild:function(_5){var ol=this.lastChild;Ext.tree.TreeNode.superclass.setLastChild.call(this,_5);if(this.childrenRendered&&ol&&_5!=ol){ol.renderIndent(true,true);}if(this.rendered){this.renderIndent(true,true);}},appendChild:function(){var _7=Ext.tree.TreeNode.superclass.appendChild.apply(this,arguments);if(_7&&this.childrenRendered){_7.render();}this.ui.updateExpandIcon();return _7;},removeChild:function(_8){this.ownerTree.getSelectionModel().unselect(_8);Ext.tree.TreeNode.superclass.removeChild.apply(this,arguments);if(this.childrenRendered){_8.ui.remove();}if(this.childNodes.length<1){this.collapse(false,false);}else{this.ui.updateExpandIcon();}return _8;},insertBefore:function(_9,_a){var _b=Ext.tree.TreeNode.superclass.insertBefore.apply(this,arguments);if(_b&&_a&&this.childrenRendered){_9.render();}this.ui.updateExpandIcon();return _b;},setText:function(_c){var _d=this.text;this.text=_c;this.attributes.text=_c;if(this.rendered){this.ui.onTextChange(this,_c,_d);}this.fireEvent("textchange",this,_c,_d);},select:function(){this.getOwnerTree().getSelectionModel().select(this);},unselect:function(){this.getOwnerTree().getSelectionModel().unselect(this);},isSelected:function(){return this.getOwnerTree().getSelectionModel().isSelected(this);},expand:function(_e,_f,_10){if(!this.expanded){if(this.fireEvent("beforeexpand",this,_e,_f)===false){return;}if(!this.childrenRendered){this.renderChildren();}this.expanded=true;if(!this.isHiddenRoot()&&(this.getOwnerTree().animate&&_f!==false)||_f){this.ui.animExpand(function(){this.fireEvent("expand",this);if(typeof _10=="function"){_10(this);}if(_e===true){this.expandChildNodes(true);}}.createDelegate(this));return;}else{this.ui.expand();this.fireEvent("expand",this);if(typeof _10=="function"){_10(this);}}}else{if(typeof _10=="function"){_10(this);}}if(_e===true){this.expandChildNodes(true);}},isHiddenRoot:function(){return this.isRoot&&!this.getOwnerTree().rootVisible;},collapse:function(_11,_12){if(this.expanded&&!this.isHiddenRoot()){if(this.fireEvent("beforecollapse",this,_11,_12)===false){return;}this.expanded=false;if((this.getOwnerTree().animate&&_12!==false)||_12){this.ui.animCollapse(function(){this.fireEvent("collapse",this);if(_11===true){this.collapseChildNodes(true);}}.createDelegate(this));return;}else{this.ui.collapse();this.fireEvent("collapse",this);}}if(_11===true){var cs=this.childNodes;for(var i=0,len=cs.length;i<len;i++){cs[i].collapse(true,false);}}},delayedExpand:function(_16){if(!this.expandProcId){this.expandProcId=this.expand.defer(_16,this);}},cancelExpand:function(){if(this.expandProcId){clearTimeout(this.expandProcId);}this.expandProcId=false;},toggle:function(){if(this.expanded){this.collapse();}else{this.expand();}},ensureVisible:function(_17){var _18=this.getOwnerTree();_18.expandPath(this.getPath(),false,function(){_18.getTreeEl().scrollChildIntoView(this.ui.anchor);Ext.callback(_17);}.createDelegate(this));},expandChildNodes:function(_19){var cs=this.childNodes;for(var i=0,len=cs.length;i<len;i++){cs[i].expand(_19);}},collapseChildNodes:function(_1d){var cs=this.childNodes;for(var i=0,len=cs.length;i<len;i++){cs[i].collapse(_1d);}},disable:function(){this.disabled=true;this.unselect();if(this.rendered&&this.ui.onDisableChange){this.ui.onDisableChange(this,true);}this.fireEvent("disabledchange",this,true);},enable:function(){this.disabled=false;if(this.rendered&&this.ui.onDisableChange){this.ui.onDisableChange(this,false);}this.fireEvent("disabledchange",this,false);},renderChildren:function(_21){if(_21!==false){this.fireEvent("beforechildrenrendered",this);}var cs=this.childNodes;for(var i=0,len=cs.length;i<len;i++){cs[i].render(true);}this.childrenRendered=true;},sort:function(fn,_26){Ext.tree.TreeNode.superclass.sort.apply(this,arguments);if(this.childrenRendered){var cs=this.childNodes;for(var i=0,len=cs.length;i<len;i++){cs[i].render(true);}}},render:function(_2a){this.ui.render(_2a);if(!this.rendered){this.rendered=true;if(this.expanded){this.expanded=false;this.expand(false,false);}}},renderIndent:function(_2b,_2c){if(_2c){this.ui.childIndent=null;}this.ui.renderIndent();if(_2b===true&&this.childrenRendered){var cs=this.childNodes;for(var i=0,len=cs.length;i<len;i++){cs[i].renderIndent(true,_2c);}}}});