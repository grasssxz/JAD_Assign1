<%@ page import="java.sql.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />
<jsp:include page="/admin/adminNavBar.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Add Specialist Package</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">
<div class="max-w-3xl mx-auto bg-white shadow p-8 mt-10 rounded-xl">

    <h1 class="text-3xl font-bold mb-6">Add New Package</h1>

    <form action="AddPackageSubmit.jsp" method="post" class="space-y-5">

        <!-- Select Clinic -->
        <div>
            <label class="font-semibold">Select Clinic</label>
            <select name="clinic_id" class="w-full border rounded-lg px-3 py-2 mt-1" required>
                <%
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
                    "root","1G9r5a6c1E**"
                );
                PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM specialist_clinic");
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                %>
                <option value="<%= rs.getInt("id") %>"><%= rs.getString("name") %></option>
                <% } conn.close(); %>
            </select>
        </div>

        <div>
            <label class="font-semibold">Package Name</label>
            <input type="text" name="name" class="w-full border rounded-lg px-3 py-2" required>
        </div>

        <div>
            <label class="font-semibold">Description</label>
            <textarea name="description" rows="3" class="w-full border rounded-lg px-3 py-2"></textarea>
        </div>

        <div>
            <label class="font-semibold">Duration (minutes)</label>
            <input type="number" name="duration" class="w-full border rounded-lg px-3 py-2" required>
        </div>

        <div>
            <label class="font-semibold">Base Price ($)</label>
            <input type="number" step="0.01" name="price" class="w-full border rounded-lg px-3 py-2" required>
        </div>

        <div>
            <label class="font-semibold">Adjustment Type</label>
            <select name="adjust_type" class="w-full border rounded-lg px-3 py-2">
                <option value="FLAT">Flat Adjustment</option>
                <option value="PERCENT">Percentage Discount</option>
            </select>
        </div>

        <div>
            <label class="font-semibold">Adjustment Value</label>
            <input type="number" step="0.01" name="adjust_value" class="w-full border rounded-lg px-3 py-2" required>
        </div>

        <button class="bg-blue-600 text-white px-5 py-2 rounded-lg font-semibold">
            Save Package
        </button>
    </form>

</div>
</body>
</html>
