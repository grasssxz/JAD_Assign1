<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
String apptId = request.getParameter("id");
String newDate = request.getParameter("new_date");
String newTime = request.getParameter("new_time");

Integer memberId = (Integer) session.getAttribute("member_id");

String msg = "";

// Build datetime
String datetimeStr = newDate + " " + newTime + ":00";
Timestamp newDT = Timestamp.valueOf(datetimeStr);

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// Load appointment to get clinic ID
PreparedStatement psLoad = conn.prepareStatement(
    "SELECT clinic_id FROM specialist_appointment WHERE id=? AND member_id=?"
);
psLoad.setString(1, apptId);
psLoad.setInt(2, memberId);

ResultSet rs = psLoad.executeQuery();
if (!rs.next()) {
    msg = "Invalid appointment.";
    response.sendRedirect("MyAppointments.jsp?msg=" + msg);
    return;
}
int clinicId = rs.getInt("clinic_id");

// Check if clinic already has booking at new time
PreparedStatement conflict = conn.prepareStatement(
    "SELECT 1 FROM specialist_appointment WHERE clinic_id=? AND appointment_datetime=? AND id<>?"
);
conflict.setInt(1, clinicId);
conflict.setTimestamp(2, newDT);
conflict.setString(3, apptId);

if (conflict.executeQuery().next()) {
    msg = "This time slot is already taken.";
    response.sendRedirect("RescheduleAppointment.jsp?id=" + apptId + "&msg=" + msg);
    return;
}

// Update appointment
PreparedStatement update = conn.prepareStatement(
    "UPDATE specialist_appointment SET appointment_datetime=? WHERE id=?"
);
update.setTimestamp(1, newDT);
update.setString(2, apptId);
update.executeUpdate();

conn.close();

response.sendRedirect("MyAppointments.jsp?msg=Appointment Rescheduled Successfully");
%>
