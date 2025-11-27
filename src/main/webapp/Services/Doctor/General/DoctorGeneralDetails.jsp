<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<jsp:include page="/auth/SessisonInit.jsp" />

<%
request.setCharacterEncoding("UTF-8");

// Get doctor ID
String doctorId = request.getParameter("id");
if (doctorId == null || doctorId.trim().isEmpty()) {
    out.println("<p>Invalid doctor ID.</p>");
    return;
}

// DB
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// Doctor info
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM doctor WHERE id = ?"
);
ps.setString(1, doctorId);
ResultSet rs = ps.executeQuery();

if (!rs.next()) {
    out.println("<p>Doctor not found.</p>");
    return;
}

String doctorName = rs.getString("name");
String doctorQual = rs.getString("qualification");

rs.close();
ps.close();

// GENERAL packages
PreparedStatement psPkg = conn.prepareStatement(
    "SELECT * FROM doctor_package WHERE doctor_id = ? AND service_type = 'GENERAL'"
);
psPkg.setString(1, doctorId);
ResultSet rsPkg = psPkg.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<title>General Clinic Visit</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<jsp:include page="/home/NavBar.jsp" />

<div class="max-w-6xl mx-auto p-6">

    <h1 class="text-3xl font-bold mb-4">General Clinic Visit (In-Person)</h1>

    <div class="grid grid-cols-3 gap-4">

        <!-- ========== LEFT COLUMN: Doctor Info ========== -->
        <div class="bg-white p-4 rounded shadow">
            <h2 class="text-xl font-bold mb-2"><%= doctorName %></h2>
            <p class="text-gray-600"><%= doctorQual %></p>
        </div>

        <!-- ========== MIDDLE COLUMN: Packages ========== -->
        <div class="bg-white p-4 rounded shadow">
            <h3 class="text-xl font-semibold mb-3">General Visit Packages</h3>

            <%
            while (rsPkg.next()) {
            %>
                <form action="GeneralBooking.jsp" method="get" class="border p-3 rounded mb-3 bg-gray-50">
                    <input type="hidden" name="doctor_id" value="<%= doctorId %>">
                    <input type="hidden" name="package_id" value="<%= rsPkg.getInt("id") %>">

                    <p class="font-semibold"><%= rsPkg.getString("package_name") %></p>
                    <p>Base Price: $<%= rsPkg.getDouble("base_price") %></p>
                    <p>Adjustment: <%= rsPkg.getString("adjustment_info") %></p>

                    <button class="mt-2 px-4 py-2 bg-blue-600 text-white rounded">
                        Select Package
                    </button>
                </form>
            <%
            }
            %>

        </div>

        <!-- ========== RIGHT COLUMN: Reviews ========== -->
        <iframe src="../Reviews/ViewDoctorReviews.jsp?doctor_id=<%= doctorId %>"
                class="w-full h-[600px] bg-white border rounded"></iframe>

    </div>

</div>

</body>
</html>

<%
rsPkg.close();
psPkg.close();
conn.close();
%>
