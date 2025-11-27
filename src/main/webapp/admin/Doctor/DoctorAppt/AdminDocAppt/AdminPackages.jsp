<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
String doctorId = request.getParameter("doctor_id");
if (doctorId == null) {
    out.print("<div class='p-4 bg-red-200 text-red-700'>Missing doctor ID.</div>");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Admin: Packages</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<div class="max-w-4xl mx-auto mt-10 bg-white p-6 rounded-lg shadow">

    <h1 class="text-3xl font-bold mb-4">Manage Packages</h1>
    <!-- Back to Admin Home -->
<a href="<%= request.getContextPath() %>/admin/admin_homePage.jsp"
   class="inline-block mb-4 px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-800">
     Back to Admin Home
</a>

    <a href="AddPackage.jsp?doctor_id=<%= doctorId %>"
       class="px-4 py-2 mb-4 inline-block bg-blue-600 text-white rounded-lg hover:bg-blue-700">
       + Add Package
    </a>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM doctor_package WHERE doctor_id=?"
);
ps.setString(1, doctorId);
ResultSet rs = ps.executeQuery();
%>

<table class="w-full border-collapse">
<tr class="bg-gray-200 text-left">
    <th class="p-2">Package Name</th>
    <th class="p-2">Adjustment</th>
    <th class="p-2">Active</th>
    <th class="p-2">Actions</th>
</tr>

<%
while (rs.next()) {
%>
<tr class="border-b">
    <td class="p-2"><%= rs.getString("package_name") %></td>
    <td class="p-2">
        <%= rs.getString("adjust_type") %> -
        <%= rs.getDouble("adjust_value") %>
    </td>
    <td class="p-2"><%= rs.getInt("is_active") == 1 ? "Yes" : "No" %></td>

    <td class="p-2 flex gap-3">
        <a href="EditPackage.jsp?id=<%= rs.getInt("id") %>"
           class="px-3 py-1 bg-yellow-500 text-white rounded-lg">
           Edit
        </a>

        <a href="DeletePackage.jsp?id=<%= rs.getInt("id") %>"
           class="px-3 py-1 bg-red-600 text-white rounded-lg">
           Delete
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
