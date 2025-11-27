<%@ page import="java.sql.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />
<jsp:include page="/admin/adminNavBar.jsp" />

<%
String id = request.getParameter("id");

if (id == null) {
    response.sendRedirect("ViewAppointments.jsp?msg=Invalid+appointment");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "UPDATE specialist_appointment SET status='cancelled' WHERE id=?"
);

ps.setString(1, id);
ps.executeUpdate();

conn.close();

response.sendRedirect("ViewAppointments.jsp?msg=Appointment+cancelled");
%>
