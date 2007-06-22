/*
 * Ext JS Library 1.1 Beta 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://www.extjs.com/license
 */


Ext.tree.DefaultSelectionModel=function(){this.selNode=null;this.addEvents({"selectionchange":true,"beforeselect":true});};Ext.extend(Ext.tree.DefaultSelectionModel,Ext.util.Observable,{init:function(_1){this.tree=_1;_1.getTreeEl().on("keydown",this.onKeyDown,this);_1.on("click",this.onNodeClick,this);},onNodeClick:function(_2,e){this.select(_2);},select:function(_4){var _5=this.selNode;if(_5!=_4&&this.fireEvent("beforeselect",this,_4,_5)!==false){if(_5){_5.ui.onSelectedChange(false);}this.selNode=_4;_4.ui.onSelectedChange(true);this.fireEvent("selectionchange",this,_4,_5);}return _4;},unselect:function(_6){if(this.selNode==_6){this.clearSelections();}},clearSelections:function(){var n=this.selNode;if(n){n.ui.onSelectedChange(false);this.selNode=null;this.fireEvent("selectionchange",this,null);}return n;},getSelectedNode:function(){return this.selNode;},isSelected:function(_8){return this.selNode==_8;},selectPrevious:function(){var s=this.selNode||this.lastSelNode;if(!s){return null;}var ps=s.previousSibling;if(ps){if(!ps.isExpanded()||ps.childNodes.length<1){return this.select(ps);}else{var lc=ps.lastChild;while(lc&&lc.isExpanded()&&lc.childNodes.length>0){lc=lc.lastChild;}return this.select(lc);}}else{if(s.parentNode&&(this.tree.rootVisible||!s.parentNode.isRoot)){return this.select(s.parentNode);}}return null;},selectNext:function(){var s=this.selNode||this.lastSelNode;if(!s){return null;}if(s.firstChild&&s.isExpanded()){return this.select(s.firstChild);}else{if(s.nextSibling){return this.select(s.nextSibling);}else{if(s.parentNode){var _d=null;s.parentNode.bubble(function(){if(this.nextSibling){_d=this.getOwnerTree().selModel.select(this.nextSibling);return false;}});return _d;}}}return null;},onKeyDown:function(e){var s=this.selNode||this.lastSelNode;var sm=this;if(!s){return;}var k=e.getKey();switch(k){case e.DOWN:e.stopEvent();this.selectNext();break;case e.UP:e.stopEvent();this.selectPrevious();break;case e.RIGHT:e.preventDefault();if(s.hasChildNodes()){if(!s.isExpanded()){s.expand();}else{if(s.firstChild){this.select(s.firstChild,e);}}}break;case e.LEFT:e.preventDefault();if(s.hasChildNodes()&&s.isExpanded()){s.collapse();}else{if(s.parentNode&&(this.tree.rootVisible||s.parentNode!=this.tree.getRootNode())){this.select(s.parentNode,e);}}break;}}});Ext.tree.MultiSelectionModel=function(){this.selNodes=[];this.selMap={};this.addEvents({"selectionchange":true});};Ext.extend(Ext.tree.MultiSelectionModel,Ext.util.Observable,{init:function(_12){this.tree=_12;_12.getTreeEl().on("keydown",this.onKeyDown,this);_12.on("click",this.onNodeClick,this);},onNodeClick:function(_13,e){this.select(_13,e,e.ctrlKey);},select:function(_15,e,_17){if(_17!==true){this.clearSelections(true);}if(this.isSelected(_15)){this.lastSelNode=_15;return _15;}this.selNodes.push(_15);this.selMap[_15.id]=_15;this.lastSelNode=_15;_15.ui.onSelectedChange(true);this.fireEvent("selectionchange",this,this.selNodes);return _15;},unselect:function(_18){if(this.selMap[_18.id]){_18.ui.onSelectedChange(false);var sn=this.selNodes;var _1a=-1;if(sn.indexOf){_1a=sn.indexOf(_18);}else{for(var i=0,len=sn.length;i<len;i++){if(sn[i]==_18){_1a=i;break;}}}if(_1a!=-1){this.selNodes.splice(_1a,1);}delete this.selMap[_18.id];this.fireEvent("selectionchange",this,this.selNodes);}},clearSelections:function(_1d){var sn=this.selNodes;if(sn.length>0){for(var i=0,len=sn.length;i<len;i++){sn[i].ui.onSelectedChange(false);}this.selNodes=[];this.selMap={};if(_1d!==true){this.fireEvent("selectionchange",this,this.selNodes);}}},isSelected:function(_21){return this.selMap[_21.id]?true:false;},getSelectedNodes:function(){return this.selNodes;},onKeyDown:Ext.tree.DefaultSelectionModel.prototype.onKeyDown,selectNext:Ext.tree.DefaultSelectionModel.prototype.selectNext,selectPrevious:Ext.tree.DefaultSelectionModel.prototype.selectPrevious});