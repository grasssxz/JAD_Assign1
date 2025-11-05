<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Database Connection Example</title>
</head>
<body>
<%
    try {
        // Step 1: Load JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Step 2: Define Connection URL
        String connURL = "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC";

        // Step 3: Establish connection
        Connection conn = DriverManager.getConnection(connURL);

        // Step 4: Create Statement object
        Statement stmt = conn.createStatement();

        // Step 5: Execute SQL command
        String sqlStr = "SELECT * FROM Member";
        ResultSet rs = stmt.executeQuery(sqlStr);

        // Step 6: Process Result
        out.println("<h3>Member Table Data:</h3>");
        while (rs.next()) {
            int id = rs.getInt("id");
            String username = rs.getString("username");
            String email = rs.getString("email");
            String type = rs.getString("type");

            out.println("ID: " + id + " | Username: " + username + " | Email: " + email + " | Type: " + type + "<br>");
        }

        // Step 7: Close connection
        rs.close();
        stmt.close();
        conn.close();

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
</body>
</html>
