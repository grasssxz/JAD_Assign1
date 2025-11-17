<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Service Table Test</title>
</head>
<body>
<%
    try {
        // Step 1: Load JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");  // Updated driver for newer MySQL connector

        // Step 2: Define Connection URL
        String connURL = "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC";

        // Step 3: Establish connection
        Connection conn = DriverManager.getConnection(connURL);

        // Step 4: Create Statement object
        Statement stmt = conn.createStatement();

        // Step 5: Execute SQL Command
        String sqlStr = "SELECT * FROM service";   
        ResultSet rs = stmt.executeQuery(sqlStr);

        // Step 6: Process Result
        out.println("<h2>Service Table Data</h2>");
        out.println("<table border='1' cellpadding='8'>");
        out.println("<tr><th>ID</th><th>Service Type</th><th>Name</th><th>Description</th><th>Active</th></tr>");

        while (rs.next()) {
            int id = rs.getInt("id");
            String serviceType = rs.getString("service_type");
            String name = rs.getString("name");
            String desc = rs.getString("description");
            boolean isActive = rs.getBoolean("is_active");

            out.println("<tr>");
            out.println("<td>" + id + "</td>");
            out.println("<td>" + serviceType + "</td>");
            out.println("<td>" + name + "</td>");
            out.println("<td>" + desc + "</td>");
            out.println("<td>" + isActive + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");

        // Step 7: Close connection
        conn.close();

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e + "</p>");
    }
%>
</body>
</html>
