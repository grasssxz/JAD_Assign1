<%@ page language="java" trimDirectiveWhitespaces="true" %>
<%
HttpSession sess = request.getSession(false);

if (sess == null) {
    sess = request.getSession(true);
    sess.setAttribute("type", "guest");
    sess.setAttribute("username", "Guest");
    sess.setAttribute("member_id", null);
}

if (sess.getAttribute("type") == null) {
    sess.setAttribute("type", "guest");
    sess.setAttribute("username", "Guest");
    sess.setAttribute("member_id", null);
}
%>
