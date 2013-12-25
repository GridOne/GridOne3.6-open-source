////////////////////////////////////////////////////////////////////////////////
//
//  ACTSONE COMPANY
//  Copyright 2013 Actsone 
//  All Rights Reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////

package kr.co.actsone.protocol
{
	import kr.co.actsone.common.GridOneImpl;
	import kr.co.actsone.controls.advancedDataGridClasses.ExAdvancedDataGridColumn;
	import kr.co.actsone.controls.advancedDataGridClasses.ExAdvancedDataGridColumnGroup;
	
	import mx.controls.Alert;

	public class GroupProtocol extends ProtocolBase
	{		
		public function GroupProtocol(app:Object)
		{
			super(app);
		}

		public function get gridoneImpl():GridOneImpl
		{
			return gridOne.gridoneImpl;
		}
		
		/*************************************************************
		 * decode
		 * *********************************************************/
		override public function decode(value:String):Object
		{
			var result:Array=new Array();
			try
			{
				if (value != null && value.length > 0)
				{
					var item:ExAdvancedDataGridColumnGroup;
					var i:int=0;
					var j:int=0;
					var fieldArray:Array;
					var row:String;
					var groupObj:Object;
					var len:int;
					var itemArr:Array=value.split(ProtocolDelimiter.ROW);
					for (i=0; i < itemArr.length - 1; i++)
					{
						row=itemArr[i];
						fieldArray=row.split(ProtocolDelimiter.CELL);
						groupObj=new Object();
						for (j=0; j < fieldArray.length - 1; )
						{
							groupObj[fieldArray[j]]=fieldArray[j + 1];
							j=j + 2;
						}
						item=gridoneImpl.createGroup(groupObj[ID], groupObj[TEXT]);
						if(groupObj[PARENT]!=null)
						{
							item.parent=groupObj[PARENT];
						}
						result.push(item);
					}
					var isRemainGroupCol:Boolean = false;
					var isStop:Boolean = false;
					if(result.length > 0)
					{
						for(i=0; i<result.length; i++)
						{
							item = ExAdvancedDataGridColumnGroup(result[i]);
							len = gridoneImpl.tempCols.length;
							if(!isRemainGroupCol && item.parent != "")
							{
								isRemainGroupCol = true;
							}
							j = 0;
							isStop = false;
							while(j<len)
							{
								for(j; j<len; j++)
								{
									if(j >= gridoneImpl.tempCols.length)
									{
										isStop = true;
										break;
									}
									if(gridoneImpl.tempCols[j] && gridoneImpl.tempCols[j] is ExAdvancedDataGridColumn && ExAdvancedDataGridColumn(gridoneImpl.tempCols[j]).parent == item._dataFieldGroupCol)
									{
										gridoneImpl.appendHeader(item._dataFieldGroupCol,ExAdvancedDataGridColumn(gridoneImpl.tempCols[j]).dataField);
										break;
									}
								}
								if(isStop)
									break;
							}
						}
						if(isRemainGroupCol)
						{
							for(i=0; i<result.length; i++)
							{
								item = ExAdvancedDataGridColumnGroup(result[i]);
								if(item.parent != "")
								{
									gridoneImpl.appendHeader(item.parent,item._dataFieldGroupCol);
								}
							}
						}
					}
				}
			}
			catch (error:Error)
			{
				Alert.show("Group "+error.message);
			}
			return result;

		}
		
		/*************************************************************
		 * encode
		 * *********************************************************/
		override public function encode(groups:Object):String
		{
			var result:String="";
			if(datagrid._isGroupedColumn)
			{
				var listGroupCols:Array = getAllGroupsCol();
				if(listGroupCols.length > 0)
				{
					for each(var group:ExAdvancedDataGridColumnGroup in listGroupCols)
					{
						if(group.parent != "")
							result=result+ID+ProtocolDelimiter.CELL+group._dataFieldGroupCol+ProtocolDelimiter.CELL+TEXT+ProtocolDelimiter.CELL+group.headerText+ProtocolDelimiter.CELL+PARENT+ProtocolDelimiter.CELL+group.parent+ProtocolDelimiter.CELL+ProtocolDelimiter.ROW;
						else
							result=result+ID+ProtocolDelimiter.CELL+group._dataFieldGroupCol+ProtocolDelimiter.CELL+TEXT+ProtocolDelimiter.CELL+group.headerText+ProtocolDelimiter.CELL+ProtocolDelimiter.ROW;
						
					}
				}
			}
			return result;
		}
		
		/*************************************************************
		 * get all group column
		 * *********************************************************/
		private function getAllGroupsCol():Array
		{
			var groupColArr:Array = new Array();
			for (var i:int=0; i< datagrid.groupedColumns.length; i++)
			{
				if(datagrid.groupedColumns[i] is ExAdvancedDataGridColumnGroup)
				{
					var groupCol:ExAdvancedDataGridColumnGroup = datagrid.groupedColumns[i] as ExAdvancedDataGridColumnGroup;
					groupColArr.push(groupCol);
					if(groupCol.children.length > 0)
					{
						groupColArr = getChildGroupInsideGroupCol(groupCol, groupColArr);
					}
				}
			}
			return groupColArr;
		}
		
		/*************************************************************
		 * get child group inside group column
		 * *********************************************************/
		private function getChildGroupInsideGroupCol(groupCol:ExAdvancedDataGridColumnGroup,result:Array):Array
		{
			for (var i:int=0; i< groupCol.children.length; i++)
			{
				if(groupCol.children[i] is ExAdvancedDataGridColumnGroup)
				{
					var childGroupCol:ExAdvancedDataGridColumnGroup = groupCol.children[i] as ExAdvancedDataGridColumnGroup;
					result.push(childGroupCol);
					if(childGroupCol.children.length > 0)
					{
						result = getChildGroupInsideGroupCol(childGroupCol, result);
					}
				}
			}
			return result;
		}

	}
}