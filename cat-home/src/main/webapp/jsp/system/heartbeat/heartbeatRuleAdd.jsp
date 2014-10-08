<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="a" uri="/WEB-INF/app.tld"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="res" uri="http://www.unidal.org/webres"%>
<%@ taglib prefix="w" uri="http://www.unidal.org/web/core"%>

<jsp:useBean id="ctx" type="com.dianping.cat.system.page.config.Context" scope="request"/>
<jsp:useBean id="payload" type="com.dianping.cat.system.page.config.Payload" scope="request"/>
<jsp:useBean id="model" type="com.dianping.cat.system.page.config.Model" scope="request"/>

<a:body>
	<res:useJs value="${res.js.local['jquery.validate.min.js']}" target="head-js" />
	<res:useJs value="${res.js.local['alarm_js']}" target="head-js" />
	<res:useJs value="${res.js.local['dependencyConfig_js']}" target="head-js" />
	<res:useCss value="${res.css.local['select2.css']}" target="head-css" />
	<res:useJs value="${res.js.local['select2.min.js']}" target="head-js" />

	<div class="row-fluid">
		<div class="span2">
			<%@include file="../configTree.jsp"%>
		</div>
		<div class="span10">
			</br>
			<form method="post">
				<h3 class="text-center text-success">编辑心跳监控规则</h3>
				
				<div class="config">
				<strong class="text-success">规则ID</strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input id="ruleId" type="text" value="${model.id}" /> <span class="text-error">String，唯一性</span>
				</div>
				<div id="metrics" class="config">
					<button class="btn btn-success btn-small" id="add-metric-button" type="button">
					    添加匹配对象<i class="icon-plus icon-white"></i>
					</button>
					
					<div id="metricItem" class="config">
					    <strong class="text-success">匹配对象：</strong>
					    <input id="metricsStr" type="hidden"></>
					    <br>
					
					    <div class="metric">
					        项目及ip(冒号连接)：<textarea name="productlineText" class="productlineText" type=" text" placeholder="支持正则"></textarea>
					        指标：
					        <select name="metricText" class="metricText">
					        	<option value="ThreadCount">ThreadCount</option>
					        	<option value="DaemonCount">DaemonCount</option>
					        	<option value="TotalStartedCount">TotalStartedCount</option>
					        	<option value="CatThreadCount">CatThreadCount</option>
					        	<option value="PiegonThreadCount">PiegonThreadCount</option>
					        	<option value="HttpThreadCount">HttpThreadCount</option>
					        	<option value="NewGcCount">NewGcCount</option>
					        	<option value="OldGcCount">OldGcCount</option>
					        	<option value="MemoryFree">MemoryFree</option>
					        	<option value="HeapUsage">HeapUsage</option>
					        	<option value="NoneHeapUsage">NoneHeapUsage</option>
					        	<option value="SystemLoadAverage">SystemLoadAverage</option>
					        	<option value="CatMessageOverflow">CatMessageOverflow</option>
					        	<option value="CatMessageSize">CatMessageSize</option>
					        </select>
					        <button class="btn btn-danger btn-small delete-metric-button" type="button">
					            <i class="icon-trash icon-white"></i>
					        </button>
					    </div>
				    </div>
				</div>
				${model.content}
				<div style='text-align: center'>
					<input class="btn btn-primary" id="ruleSubmitButton" type="text"
						name="submit" value="提交">
					</button>
				</div>
			</form>
		</div>
	</div>
	
	<script type="text/javascript">
		function drawMetricItems(metricsStr, newMetric) {
	        var metrics = null;
	
	        if (metricsStr == undefined || metricsStr == "") {
	            return;
	        }
	
	        try {
	            metrics = JSON.parse(metricsStr);
	        } catch (e) {
	            alert("读取规则错误！请刷新重试或联系leon.li@dianping.com");
	            return;
	        }
	
	        if (metrics != undefined) {
	            for (count in metrics) {
	                var metric = metrics[count];
	                var productlineText = metric["productText"];
	                var metricText = metric["metricItemText"];
	
	                if (count > 0) {
	                	addMetricHeader(newMetric.clone());
	                }
	                var metricForm = $(".metric").last();
	                if (productlineText) {
	                    metricForm.find(".productlineText").val(productlineText);
	                }
	                if (metricText) {
	                    metricForm.find(".metricText").val(metricText);
	                }
	            }
	        }
	    }
	
	    function generateMetricsJsonString() {
	        var metricLength = $(".metric").length;
	        if (metricLength > 0) {
	            var metricList = [];
	            $(".metric").each(function () {
	                var metric = {};
	                var hasPro = false;
	                var productLineText = $(this).find(".productlineText").val();
	                var metricText = $(this).find(".metricText").val()
	
	                if (productLineText != "") {
	                    metric["productText"] = productLineText;
	                    hasPro = true;
	                }
	                if (metricText != "") {
	                    metric["metricItemText"] = metricText;
	                    hasPro = true;
	                }
	
	                if (hasPro) {
	                    metricList.push(metric);
	                }
	            });
	            if (metricList.length > 0) {
	                return JSON.stringify(metricList);
	            } else {
	                return "";
	            }
	        }
	    }
		
		function addMetricHeader(newMetric){
			$("#metrics").append(newMetric.clone());
		}
		
		 $(document).ready(function() {
			var newMetric = $('#metricItem').clone();
			$('#heartbeatRuleConfigList').addClass('active');
			
			var configHeader = '${model.configHeader}';
			drawMetricItems(configHeader, newMetric);
			
			$(document).delegate("#ruleSubmitButton","click",function(){
				var key = $('#ruleId').val();
				var metrics = generateMetricsJsonString();
				var configStr = generateConfigsJsonString();
			    window.location.href = "?op=heartbeatRuleSubmit&configs=" + configStr + "&ruleId=" + key +"&metrics="+metrics;
			});
			
			$("#add-metric-button").click(function(){
				addMetricHeader(newMetric);
			});
			
			$("#metrics").delegate(".delete-metric-button", "click", function () {
	            $(this).parent().parent().remove();
	        });
		});
	</script>
</a:body>