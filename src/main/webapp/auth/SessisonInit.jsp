<%@ page language="java" %>
<%
    // Try to get existing session
    HttpSession sess = request.getSession(false);

    // If no session exists → create a new one
    if (sess == null) {
        sess = request.getSession(true);
        sess.setAttribute("type", "guest");
        sess.setAttribute("username", "Guest");
        sess.setAttribute("member_id", null);
    }

    // If session exists but attributes missing → normalise session
    if (sess.getAttribute("type") == null) {
        sess.setAttribute("type", "guest");
    }

    if (sess.getAttribute("username") == null) {
        sess.setAttribute("username", "Guest");
    }

    if (!sess.getAttributeNames().hasMoreElements() || sess.getAttribute("member_id") == null) {
        sess.setAttribute("member_id", null);
    }
%>
