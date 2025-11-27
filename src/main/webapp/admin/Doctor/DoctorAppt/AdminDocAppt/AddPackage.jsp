<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<!DOCTYPE html>
<html>
<head>
<title>Add Package</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<div class="max-w-xl mx-auto mt-10 bg-white p-6 rounded-xl shadow">

    <h1 class="text-2xl font-bold mb-5">Add New Package</h1>

    <%
    // doctor_id MUST be provided from previous page
    String doctorId = request.getParameter("doctor_id");
    if (doctorId == null) {
        out.println("<p class='text-red-600'>Error: Missing doctor ID.</p>");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String name = request.getParameter("name");
        String desc = request.getParameter("description");
        String type = request.getParameter("adjust_type");
        String val  = request.getParameter("adjust_value");

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
            "root","1G9r5a6c1E**"
        );

        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO doctor_package (doctor_id, package_name, description, adjust_type, adjust_value, is_active) " +
            "VALUES (?,?,?,?,?,1)"
        );

        ps.setString(1, doctorId);
        ps.setString(2, name);
        ps.setString(3, desc);
        ps.setString(4, type);
        ps.setString(5, val);
        ps.executeUpdate();

        conn.close();

        response.sendRedirect(
        	    "AdminPackages.jsp?doctor_id=" + doctorId +
        	    "&msg=" + java.net.URLEncoder.encode("Package added successfully!", "UTF-8")
        	);
        	return;

    }
    %>

    <form method="post" class="space-y-4">

        <div>
            <label class="font-medium block mb-1">Package Name</label>
            <input type="text" name="name" required
                   class="w-full border rounded-lg px-3 py-2" />
        </div>

        <div>
            <label class="font-medium block mb-1">Description</label>
            <textarea name="description" rows="4"
                      class="w-full border rounded-lg px-3 py-2"></textarea>
        </div>

        <div>
            <label class="font-medium block mb-1">Adjustment Type</label>
            <select name="adjust_type" class="w-full border rounded-lg px-3 py-2">
                <option value="FLAT">FLAT (Amount)</option>
                <option value="PERCENT">PERCENT (%)</option>
            </select>
        </div>

        <div>
            <label class="font-medium block mb-1">Adjustment Value</label>
            <input type="number" name="adjust_value" step="0.01" required
                   class="w-full border rounded-lg px-3 py-2" />
        </div>

        <button class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg">
            Add Package
        </button>

    </form>

</div>

</body>
</html>
