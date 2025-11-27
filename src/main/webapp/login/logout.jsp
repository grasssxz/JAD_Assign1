<%@ page language="java" %>
<%
    // ===== SESSION LOGOUT =====
    HttpSession sess = request.getSession(false);
    if (sess != null) {
        sess.invalidate();
    }

    // ===== COOKIE LOGOUT =====
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
    	for (Cookie c : cookies) {
    	    if ("username".equals(c.getName())) {
    	        c.setValue("");
    	        c.setMaxAge(0);
    	        c.setPath("/");    // MUST MATCH CREATION
    	        response.addCookie(c);
    	    }
    	}

    }

    // ===== REDIRECT =====
    response.sendRedirect(request.getContextPath() + "/login/login.html");
%>
