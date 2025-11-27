<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<!DOCTYPE html>
<html>
<head>
<title>Admin: Doctors</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<div class="max-w-4xl mx-auto mt-10 bg-white p-6 shadow rounded-lg">
    <h1 class="text-3xl font-bold mb-6">Doctors</h1>
<!-- Back to Admin Home -->
<a href="<%= request.getContextPath() %>/admin/admin_homePage.jsp"
   class="inline-block mb-4 px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-800">
     Back to Admin Home
</a>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement("SELECT * FROM doctor");
ResultSet rs = ps.executeQuery();
%>

<table class="w-full border-collapse">
<tr class="bg-gray-200 text-left">
    <th class="p-2">Name</th>
    <th class="p-2">Specialty</th>
    <th class="p-2">Action</th>
</tr>

<%
while (rs.next()) {
%>
<tr class="border-b">
    <td class="p-2"><%= rs.getString("name") %></td>
    <td class="p-2"><%= rs.getString("specialty") %></td>
    <td class="p-2">
        <a href="AdminPackages.jsp?doctor_id=<%= rs.getInt("id") %>"
           class="px-3 py-1 bg-blue-600 text-white rounded-lg">
           Manage Packages
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
