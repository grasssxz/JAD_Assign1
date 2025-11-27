<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<%
String username = request.getParameter("username");
String password = request.getParameter("password");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    String connURL =
    		"jdbc:mysql://localhost:3306/jad_assign1"
    		+ "?user=root"
    		+ "&password=1G9r5a6c1E**"
    		+ "&serverTimezone=UTC"
    		+ "&useSSL=false"
    		+ "&allowPublicKeyRetrieval=true";
    Connection conn = DriverManager.getConnection(connURL);

    // we also need status now
    String sql = "SELECT * FROM member WHERE username = ? AND password = ?";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, username);
    pstmt.setString(2, password);
    ResultSet rs = pstmt.executeQuery();

    if (rs.next()) {
        String status = rs.getString("status");   // 'activated' or 'deactivated'

        // ❌ account exists but is deactivated
        if ("deactivated".equals(status)) {
            rs.close();
            pstmt.close();
            conn.close();

            out.println("<script>alert('Your account has been deactivated. Please contact the administrator.');</script>");
            out.println("<script>window.location.href='login.html';</script>");
        } else {
            // ✅ only activated users reach here

            // SESSION
            session.setAttribute("member_id", rs.getInt("id"));
            session.setAttribute("username", rs.getString("username"));
            session.setAttribute("type", rs.getString("type"));

            // COOKIE
            Cookie ck = new Cookie("username", username);
            ck.setMaxAge(60*60*24*7);
            ck.setPath("/");   // cookie valid for whole app
            response.addCookie(ck);

            // REDIRECT BY ROLE
            String role = rs.getString("type");

            if ("admin".equals(role)) {
                response.sendRedirect("../admin/admin_homePage.jsp");
            } else {
                response.sendRedirect("../home/HomePage.jsp");
            }

            rs.close();
            pstmt.close();
            conn.close();
        }

    } else {
        // no such username+password
        out.println("<script>alert('Invalid username or password');</script>");
        out.println("<script>window.location.href='login.html';</script>");

        rs.close();
        pstmt.close();
        conn.close();
    }

} catch (Exception e) {
    out.println("<script>alert('Login error: " + e.getMessage() + "');</script>");
    out.println("<script>window.location.href='login.html';</script>");
}
%>