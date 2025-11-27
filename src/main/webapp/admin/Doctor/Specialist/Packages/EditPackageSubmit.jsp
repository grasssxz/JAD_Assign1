<%@ page import="java.sql.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
String id          = request.getParameter("id");
String name        = request.getParameter("name");
String desc        = request.getParameter("description");
String duration    = request.getParameter("duration");
String price       = request.getParameter("price");
String type        = request.getParameter("adjust_type");
String value       = request.getParameter("adjust_value");
String active      = request.getParameter("is_active");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
  "UPDATE specialist_package SET name=?, description=?, duration_minutes=?, price=?, adjust_type=?, adjust_value=?, is_active=? WHERE id=?"
);

ps.setString(1, name);
ps.setString(2, desc);
ps.setInt(3, Integer.parseInt(duration));
ps.setDouble(4, Double.parseDouble(price));
ps.setString(5, type);
ps.setDouble(6, Double.parseDouble(value));
ps.setInt(7, Integer.parseInt(active));
ps.setInt(8, Integer.parseInt(id));

ps.executeUpdate();
conn.close();

response.sendRedirect("ViewPackages.jsp?msg=Package updated");
%>
