<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%
String id = request.getParameter("id");
Integer memberId = (Integer) session.getAttribute("member_id");

if (id == null) {
    out.println("<div class='p-6 text-red-600'>Invalid appointment ID.</div>");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

/* Load existing appointment */
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM doctor_appointment WHERE id=? AND member_id=?"
);
ps.setString(1, id);
ps.setInt(2, memberId);

ResultSet rs = ps.executeQuery();
if (!rs.next()) {
    conn.close();
    out.println("<div class='p-6 text-red-600'>Appointment not found.</div>");
    return;
}

String doctorId = rs.getString("doctor_id");
%>

<!DOCTYPE html>
<html>
<head>
<title>Reschedule Appointment</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<div class="max-w-xl mx-auto mt-10 bg-white shadow p-6 rounded-lg">

    <h2 class="text-2xl font-bold mb-4">Reschedule Appointment</h2>

    <form method="post" class="space-y-4">

        <input type="hidden" name="id" value="<%= id %>">

        <div>
            <label class="font-medium block mb-1">New Date</label>
            <input type="date" name="date" class="w-full border rounded-lg px-3 py-2" required>
        </div>

        <div>
            <label class="font-medium block mb-1">New Time</label>
            <input type="time" name="time" class="w-full border rounded-lg px-3 py-2" required>
        </div>

        <button class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700">
            Confirm Change
        </button>

    </form>
</div>

</body>
</html>

<%
/* -------------------------
   PROCESS RESCHEDULE
--------------------------*/
if ("POST".equalsIgnoreCase(request.getMethod())) {

	String newDate = request.getParameter("date");
	String newTime = request.getParameter("time");

	// Convert HH:MM → HH:MM:00
	if (newTime != null && newTime.length() == 5) {
	    newTime = newTime + ":00";
	}

	java.sql.Date sqlDate = java.sql.Date.valueOf(newDate);
	java.sql.Time sqlTime = java.sql.Time.valueOf(newTime);


    /* USER double-booking check */
    PreparedStatement selfCheck = conn.prepareStatement(
        "SELECT 1 FROM doctor_appointment WHERE member_id=? AND appointment_date=? AND appointment_time=? AND id<>?"
    );
    selfCheck.setInt(1, memberId);
    selfCheck.setDate(2, sqlDate);
    selfCheck.setTime(3, sqlTime);
    selfCheck.setString(4, id);

    if (selfCheck.executeQuery().next()) {
        conn.close();
        response.sendRedirect("MyAppointments.jsp?msg=You+already+have+an+appointment+at+this+time");
        return;
    }

    /* DOCTOR time slot check */
    PreparedStatement conflict = conn.prepareStatement(
        "SELECT 1 FROM doctor_appointment WHERE doctor_id=? AND appointment_date=? AND appointment_time=? AND id<>?"
    );
    conflict.setString(1, doctorId);
    conflict.setDate(2, sqlDate);
    conflict.setTime(3, sqlTime);
    conflict.setString(4, id);

    if (conflict.executeQuery().next()) {
        conn.close();
        response.sendRedirect("MyAppointments.jsp?msg=Doctor+already+booked+at+this+time");
        return;
    }

    /* UPDATE appointment */
    PreparedStatement update = conn.prepareStatement(
        "UPDATE doctor_appointment SET appointment_date=?, appointment_time=? WHERE id=?"
    );
    update.setDate(1, sqlDate);
    update.setTime(2, sqlTime);
    update.setString(3, id);
    update.executeUpdate();

    conn.close();
    response.sendRedirect("MyAppointments.jsp?msg=Appointment+rescheduled+successfully");
}
%>
