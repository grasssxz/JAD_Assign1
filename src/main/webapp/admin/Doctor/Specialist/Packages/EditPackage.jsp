<%@ page import="java.sql.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />
<jsp:include page="/admin/adminNavBar.jsp" />

<%
String id = request.getParameter("id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement("SELECT * FROM specialist_package WHERE id=?");
ps.setString(1, id);
ResultSet pkg = ps.executeQuery();

if (!pkg.next()) {
    out.println("Package not found");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Package</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<div class="max-w-3xl mx-auto bg-white shadow p-8 mt-10 rounded-xl">

<h1 class="text-3xl font-bold mb-6">Edit Package</h1>

<form action="EditPackageSubmit.jsp" method="post" class="space-y-5">

    <input type="hidden" name="id" value="<%= id %>">

    <div>
        <label class="font-semibold">Package Name</label>
        <input type="text" name="name" value="<%= pkg.getString("name") %>" class="w-full border rounded-lg px-3 py-2">
    </div>

    <div>
        <label class="font-semibold">Description</label>
        <textarea name="description" rows="3" class="w-full border rounded-lg px-3 py-2"><%= pkg.getString("description") %></textarea>
    </div>

    <div>
        <label class="font-semibold">Duration (minutes)</label>
        <input type="number" name="duration" value="<%= pkg.getInt("duration_minutes") %>" class="w-full border rounded-lg px-3 py-2">
    </div>

    <div>
        <label class="font-semibold">Base Price ($)</label>
        <input type="number" step="0.01" name="price" value="<%= pkg.getDouble("price") %>" class="w-full border rounded-lg px-3 py-2">
    </div>

    <div>
        <label class="font-semibold">Adjustment Type</label>
        <select name="adjust_type" class="w-full border rounded-lg px-3 py-2">
            <option value="FLAT" <%= "FLAT".equals(pkg.getString("adjust_type")) ? "selected" : "" %>>FLAT</option>
            <option value="PERCENT" <%= "PERCENT".equals(pkg.getString("adjust_type")) ? "selected" : "" %>>PERCENT</option>
        </select>
    </div>

    <div>
        <label class="font-semibold">Adjustment Value</label>
        <input type="number" step="0.01" name="adjust_value"
               value="<%= pkg.getDouble("adjust_value") %>"
               class="w-full border rounded-lg px-3 py-2">
    </div>

    <div>
        <label class="font-semibold">Status</label>
        <select name="is_active" class="w-full border rounded-lg px-3 py-2">
            <option value="1" <%= pkg.getInt("is_active") == 1 ? "selected" : "" %>>Active</option>
            <option value="0" <%= pkg.getInt("is_active") == 0 ? "selected" : "" %>>Inactive</option>
        </select>
    </div>

    <button class="bg-blue-600 text-white px-5 py-2 rounded-lg font-semibold">
        Update Package
    </button>

</form>

</div>

</body>
</html>
