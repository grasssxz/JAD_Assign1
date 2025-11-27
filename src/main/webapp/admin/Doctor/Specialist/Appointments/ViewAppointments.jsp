<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />
<jsp:include page="/admin/adminNavBar.jsp" />


<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Specialist Appointments</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-7xl mx-auto px-6 py-8">

    <h1 class="text-3xl font-bold text-gray-800 mb-6">Manage Specialist Appointments</h1>

    <%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
        "root","1G9r5a6c1E**"
    );

    PreparedStatement ps = conn.prepareStatement(
        "SELECT a.*, m.username AS member_name, c.name AS clinic_name, p.name AS package_name " +
        "FROM specialist_appointment a " +
        "JOIN member m ON a.member_id = m.id " +
        "JOIN specialist_clinic c ON a.clinic_id = c.id " +
        "JOIN specialist_package p ON a.package_id = p.id " +
        "ORDER BY appointment_datetime DESC"
    );

    ResultSet rs = ps.executeQuery();
    %>

    <div class="space-y-6">

    <%
    boolean has = false;
    while (rs.next()) {
        has = true;

        String status = rs.getString("status");
        String statusColor = "bg-gray-500";

        if ("pending".equals(status))   statusColor = "bg-yellow-500";
        if ("completed".equals(status)) statusColor = "bg-green-600";
        if ("cancelled".equals(status)) statusColor = "bg-red-600";
    %>

    <!-- CARD -->
    <div class="bg-white shadow rounded-xl p-6 border border-gray-200">

        <!-- HEADER -->
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-semibold text-gray-900">
                <%= rs.getString("clinic_name") %>
            </h2>

            <span class="px-3 py-1 text-white text-sm rounded-lg <%= statusColor %>">
                <%= status.toUpperCase() %>
            </span>
        </div>

        <!-- DETAILS -->
        <p class="text-gray-700"><b>Member:</b> <%= rs.getString("member_name") %></p>
        <p class="text-gray-700"><b>Package:</b> <%= rs.getString("package_name") %></p>
        <p class="text-gray-700"><b>Date:</b> <%= rs.getTimestamp("appointment_datetime").toLocalDateTime().toLocalDate() %></p>
        <p class="text-gray-700"><b>Time:</b> <%= rs.getTimestamp("appointment_datetime").toLocalDateTime().toLocalTime() %></p>
        <p class="text-gray-700"><b>Final Price:</b> $<%= rs.getDouble("final_price") %></p>

        <!-- ACTION BUTTONS -->
        <div class="flex gap-3 mt-5">

            <!-- Toggle Pending / Completed -->
            <% if ("pending".equals(status)) { %>
                <a href="UpdateStatus.jsp?id=<%= rs.getInt("id") %>&status=completed"
                    class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg text-sm">
                    Mark Completed
                </a>
            <% } else if ("completed".equals(status)) { %>
                <a href="UpdateStatus.jsp?id=<%= rs.getInt("id") %>&status=pending"
                    class="px-4 py-2 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg text-sm">
                    Mark Pending
                </a>
            <% } %>

            <!-- Cancel Appointment -->
            <% if (!"cancelled".equals(status)) { %>
                <a href="CancelAppointment.jsp?id=<%= rs.getInt("id") %>"
                    onclick="return confirm('Cancel this appointment?');"
                    class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg text-sm">
                    Cancel
                </a>
            <% } %>

        </div>
    </div>

    <% } %>

    <% if (!has) { %>
        <p class="text-gray-600 text-lg">No specialist appointments found.</p>
    <% } %>

    </div>

</div>

</body>
</html>
