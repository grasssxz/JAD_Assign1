<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
String id = request.getParameter("id");
String newStatus = request.getParameter("status");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "UPDATE doctor_appointment SET status=? WHERE id=?"
);
ps.setString(1, newStatus);
ps.setString(2, id);
ps.executeUpdate();

conn.close();

response.sendRedirect("DocApptDashboard.jsp?msg=Status+updated");
%>
