<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
String id = request.getParameter("id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "DELETE FROM doctor_package WHERE id=?"
);

ps.setString(1, id);
ps.executeUpdate();

conn.close();

response.sendRedirect("AdminPackages.jsp?msg=" +
    java.net.URLEncoder.encode("Package deleted successfully!", "UTF-8"));
%>
