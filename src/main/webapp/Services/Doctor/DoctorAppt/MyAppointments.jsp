<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%
Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "SELECT a.*, d.name AS doctor_name, p.package_name " +
    "FROM doctor_appointment a " +
    "JOIN doctor d ON a.doctor_id = d.id " +
    "JOIN doctor_package p ON a.package_id = p.id " +
    "WHERE a.member_id=? " +
    "ORDER BY a.appointment_date DESC, a.appointment_time DESC"
);
ps.setInt(1, memberId);

ResultSet rs = ps.executeQuery();  // <<--- NOW rs EXISTS HERE
%>

<!DOCTYPE html>
<html>
<head>
<title>My Appointments</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen">

<div class="max-w-5xl mx-auto mt-10">

    <h1 class="text-4xl font-bold mb-6 text-gray-900">My Appointments</h1>

    <%
    boolean hasAny = false;
    while (rs.next()) {   // <<--- NOW IT WORKS (rs is in scope)
        hasAny = true;
    %>

    <!-- Appointment Card UI -->
    <div class="bg-white rounded-xl shadow p-6 mb-6 border border-gray-200">

        <div class="flex items-center gap-4 mb-4">
            <div class="w-14 h-14 rounded-full bg-blue-200 flex items-center justify-center text-xl font-bold text-blue-700">
                <%= rs.getString("doctor_name").charAt(0) %>
            </div>

            <div>
                <h2 class="text-xl font-semibold text-gray-900"><%= rs.getString("doctor_name") %></h2>

                <%
                String status = rs.getString("status");
                String badge = "bg-blue-100 text-blue-700";
                if ("COMPLETED".equals(status)) badge = "bg-green-100 text-green-700";
                if ("CANCELLED".equals(status)) badge = "bg-red-100 text-red-700";
                %>

                <span class="px-3 py-1 text-sm rounded-full <%= badge %>">
                    <%= status %>
                </span>
            </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-gray-700">
            <p><b>Package:</b> <%= rs.getString("package_name") %></p>
            <p><b>Date:</b> <%= rs.getString("appointment_date") %></p>
            <p><b>Time:</b> <%= rs.getString("appointment_time") %></p>
        </div>

        <% if (!"CANCELLED".equals(status)) { %>
        <div class="flex gap-4 mt-6">
            <a href="CancelAppointment.jsp?id=<%= rs.getInt("id") %>"
               class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg shadow">Cancel</a>

            <a href="RescheduleAppointment.jsp?id=<%= rs.getInt("id") %>"
               class="px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg shadow">Reschedule</a>
        </div>
        <% } %>

    </div>

    <% } // end while %>

    <% if (!hasAny) { %>
    <div class="text-center bg-white py-10 rounded-xl shadow text-gray-600">
        You have no appointments yet.
    </div>
    <% } %>

</div>

<%
conn.close();
%>

</body>
</html>
