<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
String id = request.getParameter("id");
String active = request.getParameter("active");

int newStatus = ("1".equals(active)) ? 0 : 1;

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "UPDATE doctor_package SET is_active=? WHERE id=?"
);

ps.setInt(1, newStatus);
ps.setString(2, id);
ps.executeUpdate();

conn.close();

response.sendRedirect("AdminPackages.jsp?msg=" +
    java.net.URLEncoder.encode("Package status updated!", "UTF-8"));
%>
