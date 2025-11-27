<%@ page import="java.sql.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
request.setCharacterEncoding("UTF-8");

String clinicId     = request.getParameter("clinic_id");
String name         = request.getParameter("name");
String desc         = request.getParameter("description");
String durationStr  = request.getParameter("duration");
String priceStr     = request.getParameter("price");
String type         = request.getParameter("adjust_type");
String valueStr     = request.getParameter("adjust_value");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
  "INSERT INTO specialist_package (clinic_id, name, description, duration_minutes, price, adjust_type, adjust_value, is_active) " +
  "VALUES (?,?,?,?,?,?,?,1)"
);

ps.setInt(1, Integer.parseInt(clinicId));
ps.setString(2, name);
ps.setString(3, desc);
ps.setInt(4, Integer.parseInt(durationStr));
ps.setDouble(5, Double.parseDouble(priceStr));
ps.setString(6, type);
ps.setDouble(7, Double.parseDouble(valueStr));

ps.executeUpdate();
conn.close();

response.sendRedirect("ViewPackages.jsp?msg=Package added successfully");
%>
