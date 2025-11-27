<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
String doctorId = request.getParameter("doctor_id");
String packageId = request.getParameter("package_id");
String date = request.getParameter("appointment_date");
String time = request.getParameter("appointment_time");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// fetch price
PreparedStatement ps = conn.prepareStatement(
    "SELECT base_price, adjustment_amount FROM doctor_package WHERE id = ?"
);
ps.setString(1, packageId);
ResultSet rs = ps.executeQuery();
rs.next();
double total = rs.getDouble("base_price") + rs.getDouble("adjustment_amount");

rs.close();
ps.close();

// insert booking
PreparedStatement ps2 = conn.prepareStatement(
    "INSERT INTO doctor_booking (member_id, doctor_id, package_id, service_type, appointment_date, appointment_time, total_fee, status, created_at) "
  + "VALUES (?, ?, ?, 'GENERAL', ?, ?, ?, 'PENDING', NOW())"
);
ps2.setInt(1, memberId);
ps2.setString(2, doctorId);
ps2.setString(3, packageId);
ps2.setString(4, date);
ps2.setString(5, time);
ps2.setDouble(6, total);

ps2.executeUpdate();
ps2.close();
conn.close();
%>

<script>
alert("General Clinic Visit booked successfully!");
window.location.href = "<%= request.getContextPath() %>/Services/Doctor/General/DoctorGeneralDetails.jsp?id=<%= doctorId %>";
</script>
