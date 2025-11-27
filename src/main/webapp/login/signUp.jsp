<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>sign up</title>
</head>
<body>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
String email = request.getParameter("email");
String type = "member";
String newUrl;

try{
    Class.forName("com.mysql.cj.jdbc.Driver");

    String connURL = "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC";

    Connection conn = DriverManager.getConnection(connURL);

    try {
        //check for existing username or email
        String checkSql = "SELECT 1 FROM member WHERE username = ? OR email = ?";
        try (PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setString(1, username);
            check.setString(2, email);
            try (ResultSet r = check.executeQuery()) {
                if (r.next()) {
                	out.println("<script>alert('Username or email already exists.'); window.location.href='signUp.jsp';</script>");
                	return;

                }
            }
        }
    } catch (Exception e) {
        out.println(e.getMessage());
    }

    // create new user
    try {
        String insertSql = "INSERT INTO member (username, password, email, type) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ps.setString(3, email);
            ps.setString(4, type);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("login.html");
                return;
            } else {
                out.println("<p style='color:red'>Failed to create account. Please try again.</p>");
            }
        }
    } catch (Exception e) {
        out.println(e.getMessage());
    } finally {
        conn.close();  
    }

} catch (Exception e){
    out.print(e.getMessage());
}
%>

</body>
</html>