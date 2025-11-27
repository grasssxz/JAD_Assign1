<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%@ page import="java.sql.*" %>

<%
String apptId = request.getParameter("id");
Integer memberId = (Integer) session.getAttribute("member_id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// Load appointment
PreparedStatement ps = conn.prepareStatement(
    "SELECT appointment_datetime FROM specialist_appointment WHERE id=? AND member_id=?"
);
ps.setString(1, apptId);
ps.setInt(2, memberId);

ResultSet rs = ps.executeQuery();
if (!rs.next()) {
    out.println("<h2 class='text-red-600 text-xl p-6'>Invalid appointment.</h2>");
    return;
}

Timestamp oldDT = rs.getTimestamp("appointment_datetime");
java.sql.Date oldDate = new java.sql.Date(oldDT.getTime());
java.sql.Time oldTime = new java.sql.Time(oldDT.getTime());
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<script src="https://cdn.tailwindcss.com"></script>
<title>Reschedule Appointment</title>
</head>

<body class="bg-gray-100">

<div class="max-w-3xl mx-auto bg-white p-8 rounded-xl shadow mt-10">

    <h1 class="text-3xl font-bold mb-6">Reschedule Appointment</h1>

    <form action="RescheduleSubmit.jsp" method="post" class="space-y-4">

        <input type="hidden" name="id" value="<%= apptId %>" />

        <p><b>Current Date:</b> <%= oldDate %></p>
        <p><b>Current Time:</b> <%= oldTime %></p>

        <div>
            <label class="font-semibold">New Date</label>
            <input type="date" name="new_date" required
                   class="w-full border px-4 py-2 rounded-lg"/>
        </div>

        <div>
            <label class="font-semibold">New Time</label>
            <input type="time" name="new_time" required
                   class="w-full border px-4 py-2 rounded-lg"/>
        </div>

        <button class="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold">
            Confirm Reschedule
        </button>

    </form>
</div>

</body>
</html>

<%
conn.close();
%>
