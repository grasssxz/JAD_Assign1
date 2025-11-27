<%@ page import="java.sql.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />
<jsp:include page="/admin/adminNavBar.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Manage Specialist Packages</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-6xl mx-auto px-6 py-8">

    <h1 class="text-3xl font-bold text-gray-800 mb-6">Manage Specialist Packages</h1>

    <!-- Add Package Button -->
    <div class="mb-6">
        <a href="AddPackage.jsp"
           class="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg font-semibold shadow">
            + Add New Package
        </a>
    </div>

    <%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
        "root",
        "1G9r5a6c1E**"
    );

    PreparedStatement ps = conn.prepareStatement(
        "SELECT p.*, c.name AS clinic_name " +
        "FROM specialist_package p " +
        "JOIN specialist_clinic c ON p.clinic_id = c.id " +
        "ORDER BY p.clinic_id, p.name"
    );
    ResultSet rs = ps.executeQuery();
    %>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

        <% while (rs.next()) { %>

        <div class="bg-white p-6 rounded-xl shadow border border-gray-200 space-y-3">

            <!-- Clinic Name -->
            <h2 class="text-lg font-bold text-gray-900">
                <%= rs.getString("clinic_name") %>
            </h2>

            <!-- Package Name -->
            <p class="text-blue-700 font-semibold text-md">
                <%= rs.getString("name") %>
            </p>

            <!-- Description -->
            <p class="text-gray-600 text-sm">
                <%= rs.getString("description") %>
            </p>

            <!-- Duration -->
            <p class="text-gray-700 text-sm">
                <b>Duration:</b> <%= rs.getInt("duration_minutes") %> mins
            </p>

            <!-- Base Price -->
            <p class="text-gray-700 text-sm">
                <b>Base Price:</b> $<%= String.format("%.2f", rs.getDouble("price")) %>
            </p>

            <!-- Adjust Type / Value -->
            <p class="text-gray-700 text-sm">
                <b>Adjustment:</b>
                <%
                    String type = rs.getString("adjust_type");
                    double val  = rs.getDouble("adjust_value");

                    if ("FLAT".equals(type)) {
                        out.print((val > 0 ? "+" : "") + "$" + String.format("%.2f", val));
                    } else {
                        out.print((val > 0 ? "+" : "-") + Math.abs(val) + "%");
                    }
                %>
            </p>

            <!-- Status -->
            <p class="text-sm">
                <b>Status:</b>
                <span class="<%= rs.getInt("is_active") == 1 ? "text-green-600" : "text-red-600" %> font-semibold">
                    <%= rs.getInt("is_active") == 1 ? "Active" : "Inactive" %>
                </span>
            </p>

            <!-- ACTION BUTTONS -->
            <div class="flex gap-3 pt-3">

                <!-- EDIT -->
                <a href="EditPackage.jsp?id=<%= rs.getInt("id") %>"
                   class="bg-yellow-500 hover:bg-yellow-600 text-white px-4 py-2 rounded-lg text-sm">
                    Edit
                </a>

                <!-- DELETE -->
                <a href="DeletePackage.jsp?id=<%= rs.getInt("id") %>"
                   onclick="return confirm('Delete this package?');"
                   class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm">
                    Delete
                </a>
            </div>

        </div>

        <% } conn.close(); %>

    </div>

</div>

</body>
</html>
