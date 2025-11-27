<%@ page language="java" %>
<%
String role = (String) session.getAttribute("type");

if (role == null || !"admin".equals(role)) {
%>
<script>
    alert("Admin access only.");
    window.location.href = "<%= request.getContextPath() %>/login/login.html";
</script>
<%
    return;
}
%>
