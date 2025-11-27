<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<!DOCTYPE html>
<html>
<head>
<title>Edit Package</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<%
String id = request.getParameter("id");

if (id == null) {
    out.println("<p class='text-red-600 p-6'>Invalid package ID</p>");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM doctor_package WHERE id=?"
);
ps.setString(1, id);
ResultSet rs = ps.executeQuery();

if (!rs.next()) {
    out.println("<p class='text-red-600 p-6'>Package not found.</p>");
    conn.close();
    return;
}

if ("POST".equalsIgnoreCase(request.getMethod())) {

    String name = request.getParameter("name");
    String desc = request.getParameter("description");
    String type = request.getParameter("adjust_type");
    String val  = request.getParameter("adjust_value");

    PreparedStatement upd = conn.prepareStatement(
        "UPDATE doctor_package SET package_name=?, description=?, adjust_type=?, adjust_value=? WHERE id=?"
    );

    upd.setString(1, name);
    upd.setString(2, desc);
    upd.setString(3, type);
    upd.setString(4, val);
    upd.setString(5, id);
    upd.executeUpdate();

    conn.close();

    response.sendRedirect("AdminPackages.jsp?msg=" +
        java.net.URLEncoder.encode("Package updated successfully!", "UTF-8"));
    return;
}
%>

<div class="max-w-xl mx-auto mt-10 bg-white shadow p-6 rounded-lg">
    <h1 class="text-2xl font-bold mb-5">Edit Package</h1>

    <form method="post" class="space-y-4">

        <div>
            <label class="font-medium mb-1 block">Package Name</label>
            <input type="text" name="name" value="<%= rs.getString("package_name") %>"
                   class="w-full border rounded-lg px-3 py-2" required />
        </div>

        <div>
            <label class="font-medium mb-1 block">Description</label>
            <textarea name="description" rows="4"
                      class="w-full border rounded-lg px-3 py-2"><%= rs.getString("description") %></textarea>
        </div>

        <div>
            <label class="font-medium mb-1 block">Adjustment Type</label>
            <select name="adjust_type" class="w-full border rounded-lg px-3 py-2">
                <option value="FLAT" <%= rs.getString("adjust_type").equals("FLAT") ? "selected" : "" %>>
                    FLAT (Amount)
                </option>
                <option value="PERCENT" <%= rs.getString("adjust_type").equals("PERCENT") ? "selected" : "" %>>
                    PERCENT (%)
                </option>
            </select>
        </div>

        <div>
            <label class="font-medium mb-1 block">Adjustment Value</label>
            <input type="number" name="adjust_value" step="0.01"
                   value="<%= rs.getDouble("adjust_value") %>"
                   class="w-full border rounded-lg px-3 py-2" required />
        </div>

        <button class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700">
            Save Changes
        </button>

    </form>

</div>

</body>
</html>
