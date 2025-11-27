<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>
<%
/* ==========================================================
   PROCESS SPECIALIST APPOINTMENT BOOKING
========================================================== */

request.setCharacterEncoding("UTF-8");

String clinicId  = request.getParameter("clinic_id");
String dateStr   = request.getParameter("appointment_date");  // yyyy-mm-dd
String timeStr   = request.getParameter("appointment_time");  // HH:mm
String packageId = request.getParameter("package_id");

Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

String message = "";

/* ===========================
   VALIDATION OF INPUT
=========================== */
if (clinicId == null || dateStr == null || timeStr == null || packageId == null ||
    clinicId.isEmpty() || dateStr.isEmpty() || timeStr.isEmpty() || packageId.isEmpty()) {

    message = "Missing required booking fields.";
    response.sendRedirect("SpecialistDetails.jsp?id=" + clinicId +
         "&msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    return;
}

/* ===========================
   MERGE DATE + TIME → DATETIME
=========================== */
String datetimeStr = dateStr + " " + timeStr + ":00";

Timestamp sqlDT = Timestamp.valueOf(datetimeStr);

/* ==========================================================
   DB CONNECTION
========================================================== */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

/* ==========================================================
   CHECK 1: USER DOUBLE-BOOKING
========================================================== */
PreparedStatement selfCheck = conn.prepareStatement(
    "SELECT 1 FROM specialist_appointment " +
    "WHERE member_id=? AND appointment_datetime=? " +
    "AND status <> 'cancelled'"
);
selfCheck.setInt(1, memberId);
selfCheck.setTimestamp(2, sqlDT);

if (selfCheck.executeQuery().next()) {
    message = "You already have an appointment at this time.";
    response.sendRedirect("SpecialistDetails.jsp?id=" + clinicId +
         "&msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    return;
}

/* ==========================================================
   CHECK 2: CLINIC DOUBLE-BOOKED
========================================================== */
PreparedStatement conflict = conn.prepareStatement(
    "SELECT 1 FROM specialist_appointment " +
    "WHERE clinic_id=? AND appointment_datetime=?"
);
conflict.setString(1, clinicId);
conflict.setTimestamp(2, sqlDT);

if (conflict.executeQuery().next()) {
    message = "This time slot is already booked.";
    response.sendRedirect("SpecialistDetails.jsp?id=" + clinicId +
         "&msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    return;
}

/* ==========================================================
   GET CLINIC BASE PRICE
========================================================== */
PreparedStatement psClinic = conn.prepareStatement(
    "SELECT name, base_price FROM specialist_clinic WHERE id=?"
);
psClinic.setString(1, clinicId);
ResultSet clinic = psClinic.executeQuery();

if (!clinic.next()) {
    message = "Clinic not found.";
    response.sendRedirect("SpecialistDetails.jsp?id=" + clinicId +
         "&msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    return;
}

String clinicName = clinic.getString("name");
double basePrice  = clinic.getDouble("base_price");

/* ==========================================================
   GET PACKAGE DETAILS
========================================================== */
PreparedStatement psPkg = conn.prepareStatement(
    "SELECT name, adjust_type, adjust_value FROM specialist_package " +
    "WHERE id=? AND is_active=1"
);
psPkg.setString(1, packageId);
ResultSet pkg = psPkg.executeQuery();

if (!pkg.next()) {
    message = "Invalid package selected.";
    response.sendRedirect("SpecialistDetails.jsp?id=" + clinicId +
         "&msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    return;
}

String packageName = pkg.getString("name");
String type        = pkg.getString("adjust_type");
double value       = pkg.getDouble("adjust_value");

/* ==========================================================
   CALCULATE FINAL PRICE
========================================================== */
double finalPrice = basePrice;

if ("FLAT".equals(type)) {
    finalPrice = basePrice + value;
} else if ("PERCENT".equals(type)) {
    finalPrice = basePrice + (basePrice * value / 100.0);
}

/* ==========================================================
   INSERT APPOINTMENT (DATETIME)
========================================================== */
PreparedStatement insert = conn.prepareStatement(
    "INSERT INTO specialist_appointment " +
    "(member_id, clinic_id, appointment_datetime, package_id, final_price) " +
    "VALUES (?,?,?,?,?)"
);

insert.setInt(1, memberId);
insert.setString(2, clinicId);
insert.setTimestamp(3, sqlDT);
insert.setString(4, packageId);
insert.setDouble(5, finalPrice);

insert.executeUpdate();

/* ==========================================================
   REDIRECT TO SUCCESS PAGE
========================================================== */
response.sendRedirect("BookingSuccess.jsp"
    + "?clinic="  + java.net.URLEncoder.encode(clinicName, "UTF-8")
    + "&date="    + dateStr
    + "&time="    + timeStr
    + "&package=" + java.net.URLEncoder.encode(packageName, "UTF-8")
    + "&price="   + finalPrice);

conn.close();
%>
