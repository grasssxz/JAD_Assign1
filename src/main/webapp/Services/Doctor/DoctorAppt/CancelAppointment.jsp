<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%
String id = request.getParameter("id");
Integer memberId = (Integer) session.getAttribute("member_id");

if (id == null || memberId == null) {
    response.sendRedirect("MyAppointments.jsp?msg=Invalid+appointment+ID");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

/* Ensure the appointment belongs to this user */
PreparedStatement psCheck = conn.prepareStatement(
    "SELECT 1 FROM doctor_appointment WHERE id=? AND member_id=?"
);
psCheck.setString(1, id);
psCheck.setInt(2, memberId);

ResultSet rs = psCheck.executeQuery();
if (!rs.next()) {
    conn.close();
    response.sendRedirect("MyAppointments.jsp?msg=Unauthorized+action");
    return;
}

/* HARD DELETE */
PreparedStatement psDel = conn.prepareStatement(
    "DELETE FROM doctor_appointment WHERE id=?"
);
psDel.setString(1, id);
psDel.executeUpdate();

conn.close();

response.sendRedirect("MyAppointments.jsp?msg=Appointment+deleted+successfully");
%>
