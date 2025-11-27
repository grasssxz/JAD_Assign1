<jsp:include page="/auth/AuthCheck.jsp" /> 
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Specialist Appointments</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-6xl mx-auto px-5 py-6">

<h1 class="text-3xl font-bold mb-6">My Specialist Appointments</h1>

<%
Integer memberId = (Integer) session.getAttribute("member_id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "SELECT a.*, c.name AS clinic_name, p.name AS package_name " +
    "FROM specialist_appointment a " +
    "JOIN specialist_clinic c ON a.clinic_id=c.id " +
    "JOIN specialist_package p ON a.package_id=p.id " +
    "WHERE a.member_id=? ORDER BY appointment_datetime DESC"
);
ps.setInt(1, memberId);

ResultSet rs = ps.executeQuery();
boolean has = false;
%>

<div class="space-y-6">

<%
while (rs.next()) {
    has = true;

    Timestamp dt = rs.getTimestamp("appointment_datetime");
    java.sql.Date apptDate = new java.sql.Date(dt.getTime());
    java.sql.Time apptTime = new java.sql.Time(dt.getTime());
%>

<div class="bg-white p-6 rounded-xl shadow">
    <h2 class="text-xl font-semibold"><%= rs.getString("clinic_name") %></h2>

    <p class="mt-2 text-gray-700"><b>Package:</b> <%= rs.getString("package_name") %></p>

    <p><b>Date:</b> <%= apptDate %></p>
    <p><b>Time:</b> <%= apptTime %></p>

    <p><b>Status:</b> 
        <span class="font-semibold">
        <%= rs.getString("status").toUpperCase() %>
        </span>
    </p>

    <p class="mt-2"><b>Final Price:</b> $<%= rs.getDouble("final_price") %></p>

  <% if ("pending".equals(rs.getString("status"))) { %>

    <!-- RESCHEDULE BUTTON -->
    <a href="RescheduleAppointment.jsp?id=<%= rs.getInt("id") %>"
       class="inline-block mt-3 bg-yellow-500 text-white px-4 py-2 rounded-lg text-sm mr-3">
       Reschedule
    </a>

    <!-- CANCEL BUTTON -->
    <a href="CancelAppointment.jsp?id=<%= rs.getInt("id") %>"
       onclick="return confirm('Cancel this appointment?')"
       class="inline-block mt-3 bg-red-600 text-white px-4 py-2 rounded-lg text-sm">
       Cancel
    </a>

<% } %>

</div>

<% } %>

<% if (!has) { %>
    <p class="text-gray-600 text-lg">You have no appointments yet.</p>
<% } %>

</div>

</div>
</body>
</html>

<%
conn.close();
%>
