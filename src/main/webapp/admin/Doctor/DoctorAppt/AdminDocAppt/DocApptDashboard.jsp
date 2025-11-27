<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<!DOCTYPE html>
<html>
<head>
<title>Admin: Appointments</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<div class="max-w-5xl mx-auto mt-10 bg-white p-6 shadow rounded-lg">

    <h1 class="text-3xl font-bold mb-6">All Doctor Appointments</h1>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "SELECT a.*, m.username, d.name AS doctor_name, p.package_name " +
    "FROM doctor_appointment a " +
    "JOIN member m ON a.member_id = m.id " +
    "JOIN doctor d ON a.doctor_id = d.id " +
    "JOIN doctor_package p ON a.package_id = p.id " +
    "ORDER BY a.appointment_date DESC, a.appointment_time DESC"
);

ResultSet rs = ps.executeQuery();
%>
<%
String msg = request.getParameter("msg");
String err = request.getParameter("err");
%>

<% if (msg != null) { %>
<div class="mb-4 p-4 rounded-lg bg-green-100 text-green-800 border border-green-300">
    <%= msg %>
</div>
<% } %>

<% if (err != null) { %>
<div class="mb-4 p-4 rounded-lg bg-red-100 text-red-800 border border-red-300">
    <%= err %>
</div>
<% } %>

<table class="w-full border-collapse">
<tr class="bg-gray-200 text-left">
    <th class="p-2">Doctor</th>
    <th class="p-2">User</th>
    <th class="p-2">Package</th>
    <th class="p-2">Date</th>
    <th class="p-2">Time</th>
    <th class="p-2">Status</th>
    <th class="p-2">Actions</th>
</tr>

<%
while (rs.next()) {
%>
<tr class="border-b">
    <td class="p-2"><%= rs.getString("doctor_name") %></td>
    <td class="p-2"><%= rs.getString("username") %></td>
    <td class="p-2"><%= rs.getString("package_name") %></td>
    <td class="p-2"><%= rs.getString("appointment_date") %></td>
    <td class="p-2"><%= rs.getString("appointment_time") %></td>
    <td class="p-2"><%= rs.getString("status") %></td>

    <td class="p-2 flex gap-3">

        <!-- Delete -->
<a href="<%= request.getContextPath() %>/admin/Doctor/DoctorAppt/AdminDocAppt/DeleteDocAppt.jsp?id=<%= rs.getInt("id") %>"
   class="px-3 py-1 bg-red-600 text-white rounded-lg">
    Delete
</a>

<!-- Mark Completed -->
<a href="<%= request.getContextPath() %>/admin/Doctor/DoctorAppt/AdminDocAppt/UpdateStatusAppt.jsp?id=<%= rs.getInt("id") %>&status=COMPLETED"
   class="px-3 py-1 bg-green-600 text-white rounded-lg">
    Completed
</a>

<!-- Mark Pending -->
<a href="<%= request.getContextPath() %>/admin/Doctor/DoctorAppt/AdminDocAppt/UpdateStatusAppt.jsp?id=<%= rs.getInt("id") %>&status=PENDING"
   class="px-3 py-1 bg-yellow-500 text-white rounded-lg">
    Pending
</a>




    </td>

</tr>
<%
}
conn.close();
%>

</table>

</div>
</body>
</html>
