<%@ page language="java" trimDirectiveWhitespaces="true" %>

<%
/*
    ===========================================================
    RequireAdmin.jsp
    Blocks access to any page unless the user is an admin.
    Usage:
        <jsp:include page="/auth/SessionInit.jsp" />
        <jsp:include page="/auth/RequireAdmin.jsp" />
    ===========================================================
*/

String type = (String) session.getAttribute("type");

// If no session OR not admin → redirect to login
if (type == null || !"admin".equals(type)) {

    // Optional: Show error message
    String msg = java.net.URLEncoder.encode(
        "Admin access required. Please log in as admin.",
        "UTF-8"
    );

    response.sendRedirect(
        request.getContextPath() + "/login/login.html?msg=" + msg
    );
    return;
}
%>
