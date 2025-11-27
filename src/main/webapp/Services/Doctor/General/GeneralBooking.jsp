<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%@ page language="java" import="java.sql.*" %>

<%
String doctorId = request.getParameter("doctor_id");
String packageId = request.getParameter("package_id");

if (doctorId == null || packageId == null) {
    out.println("<p>Missing parameters.</p>");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// Fetch package
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM doctor_package WHERE id = ?"
);
ps.setString(1, packageId);
ResultSet rs = ps.executeQuery();

if (!rs.next()) {
    out.println("Invalid package.");
    return;
}

double basePrice = rs.getDouble("base_price");
String adjText = rs.getString("adjustment_info");
double adjAmount = rs.getDouble("adjustment_amount");

rs.close();
ps.close();
%>

<!DOCTYPE html>
<html>
<head>
<title>Book General Clinic Visit</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">
<div class="max-w-xl mx-auto mt-10 bg-white p-6 rounded shadow">

<h2 class="text-2xl font-bold mb-4">General Clinic Visit Booking</h2>

<form action="GeneralSubmitBooking.jsp" method="post" class="space-y-4">

    <input type="hidden" name="doctor_id" value="<%= doctorId %>">
    <input type="hidden" name="package_id" value="<%= packageId %>">

    <div>
        <label class="font-medium">Date</label>
        <input type="date" name="appointment_date"
               class="w-full border rounded px-3 py-2" required>
    </div>

    <div>
        <label class="font-medium">Time</label>
        <input type="time" name="appointment_time"
               class="w-full border rounded px-3 py-2" required>
    </div>

    <!-- PRICE PREVIEW -->
    <div class="p-3 bg-blue-50 border border-blue-300 rounded">
        <p><b>Base Price:</b> $<%= basePrice %></p>
        <p><b>Adjustment:</b> <%= adjText %> ($<%= adjAmount %>)</p>
        <p class="mt-2 text-xl font-bold">
            Total: $<%= basePrice + adjAmount %>
        </p>
    </div>

    <button class="w-full mt-4 bg-blue-600 text-white py-2 rounded">
        Confirm Booking
    </button>

</form>

</div>
</body>
</html>

<%
conn.close();
%>
