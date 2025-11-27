<%@ page trimDirectiveWhitespaces="true" %>

<%
String type = (String) session.getAttribute("type");

if (type == null || "guest".equals(type)) {
%>
    <jsp:forward page="/login/login.html" />
<%
    return;
}
%>
