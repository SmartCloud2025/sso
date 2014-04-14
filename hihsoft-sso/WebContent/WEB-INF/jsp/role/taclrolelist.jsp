<%@ page contentType="text/html;charset=UTF-8"%>
<%@ include file="/WEB-INF/jsp/common/taglibs.jsp"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%@ include file="/WEB-INF/jsp/common/meta.jsp"%>
<%@ include file="/WEB-INF/jsp/common/title.jsp"%>
<script type="text/javascript">
var ids;
var win;
	$(function() {
		var form = $("form[name=listForm]");
		initGrid(form);
		var handler = function() {
			win.window('open');
			var div = $(this);
			div.show();
		};
		win = $("#win").window({
			title : "操作窗口",
			modal : true
		});
		
		$("#btn_add").click(
				function() {
					win.window('open');
					$("#msg").load(
							"${ctx}/taclRoleController.do?method=add",
							"", handler);
				});
		
		$("#btn_edit").click(
					function() {
						var isGroup = $("#isGroup").val();
						var text = form.find(":checked").parent().parent().find("td:eq(5)").text();
						if (isGroup!="true" && text=="公共") {
							alert("非集团用户不能修改公共角色");
							return;
						}
						var ids = getSelected(true);
						if (ids){
							win.window('open');
							$("#msg").load("${ctx}/taclRoleController.do?method=modifyInit",
										{id : ids}, handler);
						}
					});
		
		$("#btn_remove")
				.click(
						function() {
							var isGroup = $("#isGroup").val();
							var text = form.find(":checked").parent().parent().find("td:eq(5)").text();
							var str = "公共";
							if(isGroup!="true"&&text.indexOf(str)!=-1){
								alert("非集团用户不能删除公共角色");
								return;
							}
							if (!confirm("确定删除选中的记录吗？"))
								return;
							form.attr("action", "${ctx}/taclRoleController.do?method=delete&ids="
									+ getSelected());
							submit(form,function(res,status){
								if(isSuccess(res, status)){
									alert("删除成功", "info", function(){
										form.attr("action", "${ctx}/taclRoleController.do?method=list");
										form.submit();
									});
								}else{
									alert("您所选的角色当中存在已分配用户","info",function(){
										form.attr("action", "${ctx}/taclRoleController.do?method=list");
										form.submit();
									});
								}
							});
						});
		$("#btn_authorization").click(function() {
					ids = getSelected(true);
					if (ids) {
						detail({roleId: ids});
					}
				});
		
		$("#btn_cancel").click(
				function(){
					var isGroup = $("#isGroup").val();
					var text = form.find(":checked").parent().parent().find("td:eq(5)").text();
					if (isGroup!="true" && text=="公共") {
						alert("非集团用户不能修改取消分配公共角色");
						return;
					}
					ids = getSelected(true);
					if(ids){
						win.window('open');
						$("#msg").load("${ctx}/taclRoleController.do?method=userView",
						{
							id : ids
						}, handler);
					}
				}	
			);
		
		$("#btn_search").click(function() {
			form.submit();
		});

		$(".table-container").layout();
		$(window).resize(function() {
			$("#container").layout();
		});
	});
				
	function detail(config) {
		var curPage = config.curPage;
		var pageSize = config.pageSize;
		win.window('open');
		var url = "${ctx}/taclRoleController.do?method=userRole";
		if (curPage) url += "&page="+curPage;
		if (pageSize) url += "&rows="+pageSize;
		var loginName = $("input[name='srh_loginname']").val();
		if (loginName) url += "&srh_loginname=" + loginName; 
		var mobile = $("input[name='srh_mobile']").val();
		if (mobile) url += "&srh_mobile=" + mobile; 
		var usertype = $("select[name='usertype']").val();
		if (usertype) url += "&usertype=" + usertype; 
		if (config.roleId) url += "&roleId=" + config.roleId;
		$("#msg").load(url);
	}		
	
	function showRole(id){
		if(!id) return;
		$("#msg").load("${ctx}/taclRoleController.do?method=roleView&id=" + id, function(){
		win.window("open");
		});
	}
	
</script>
</head>
<body>
<form method="post" target="_self" action="${ctx}/taclRoleController.do?method=list" name="listForm">
	<div  id="container">
		<input type="hidden" id="isGroup" value="${isGroup}" />
		<div class="datagrid-toolbar" region="north" border="false" style="height: 70px;">
			<hih:auth operate="ADD" module="ACL_ROLE" value="button.add"
				id="btn_add" iconCls="icon-add" />
			<hih:auth operate="EDIT" module="ACL_ROLE" value="button.edit"
				id="btn_edit" iconCls="icon-edit" />
			<hih:auth operate="DELETE" module="ACL_ROLE" value="button.remove"
				id="btn_remove" iconCls="icon-remove" />
			<hih:auth operate="AUTHORIZATION" module="ACL_ROLE" value="button.assign.user"
				id="btn_authorization" iconCls="icon-ok" style="width: 70px;"/>
			<hih:auth operate="CANCEL" module="ACL_ROLE" value="button.cancel.assign"
				id="btn_cancel" iconCls="icon-remove" style="width: 70px;"/>
			<hih:auth operate="QUERY" module="ACL_ROLE" value="button.query"
				id="btn_search" iconCls="icon-search" />
			<table class="FormView" border="0" cellspacing="1" cellpadding="0" style="margin-top: 4px;">
				<col class="Label" />
				<col class="Data" />
				<col class="Label" />
				<col class="Data" />
				<tr height="30px">
					<td align="left" >
						<fmt:message key="taclrole.rolename" /></td>
					<td><input type="text" style="width:200px" name="srh_rolename" value="${rolename}"></td>
					<td>&nbsp;&nbsp;</td>
					<td>&nbsp;&nbsp;</td>
				</tr>
			</table>
		</div>
		<div id="grid-body" region="center">
			<hih:table items="${list}" var="taclrole">
				<hih:column field="roleid" checkbox="true"/>
				<hih:column field="rolename" header="taclrole.rolename" width="200">
				<a href="#" onclick="showRole('${taclrole.roleid}')">${taclrole.rolename}</a>
				</hih:column>
				<hih:column field="roletype" header="taclrole.roletype" width="120"/>
				<hih:column field="roleSort" header="taclrole.rolesort" width="120"/>
				<hih:column field="orgid" header="taclrole.orgid" width="200"/>
			    <hih:column field="remark" header="taclrole.remark" width="400"/>
			</hih:table>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/page.jsp" />
	</div>
</form>
	<div id="win" closed="true" style="width: 650px; height: 500px;">
		<div id="msg"></div>
	</div>
</body>
</html>
