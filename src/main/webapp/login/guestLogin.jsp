<%@ page language="java" %>
<%
    // Create a session for guest
    HttpSession sess = request.getSession(true);

    sess.setAttribute("member_id", null);     // no DB ID
    sess.setAttribute("username", "Guest");
    sess.setAttribute("type", "guest");

    // Redirect to homepage
    response.sendRedirect(request.getContextPath() + "/home/HomePage.jsp");
%>
