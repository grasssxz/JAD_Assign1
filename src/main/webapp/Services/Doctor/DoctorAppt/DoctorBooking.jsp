<%@ page import="java.sql.*" %>
<%
/* ==========================================================
   PROCESS DOCTOR APPOINTMENT BOOKING
========================================================== */

request.setCharacterEncoding("UTF-8");

String doctorId     = request.getParameter("doctor_id");
String dateStr      = request.getParameter("appointment_date");
String timeStr      = request.getParameter("appointment_time");
String packageId    = request.getParameter("package_id");

Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) memberId = 1;  // fallback for testing

String message = "";

/* ==========================================================
   VALIDATE INPUT
========================================================== */
if (doctorId == null || dateStr == null || timeStr == null || packageId == null ||
    doctorId.isEmpty() || dateStr.isEmpty() || timeStr.isEmpty() || packageId.isEmpty()) {

    message = "Missing required booking fields.";
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId + "&msg=" + 
         java.net.URLEncoder.encode(message, "UTF-8"));
    return;
}

/* Convert to SQL types */
java.sql.Date sqlDate = java.sql.Date.valueOf(dateStr);         // yyyy-mm-dd
java.sql.Time sqlTime = java.sql.Time.valueOf(timeStr + ":00"); // hh:mm:ss

/* ==========================================================
   CONNECT TO DATABASE
========================================================== */
Class.forName("com.mysql.cj.jdbc.Driver");

Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

/* ==========================================================
   VALIDATION 1: USER DOUBLE-BOOKING CHECK
========================================================== */
PreparedStatement selfCheck = conn.prepareStatement(
    "SELECT 1 FROM doctor_appointment " +
    "WHERE member_id=? AND appointment_date=? AND appointment_time=? " +
    "AND status <> 'CANCELLED'"
);
selfCheck.setInt(1, memberId);
selfCheck.setDate(2, sqlDate);
selfCheck.setTime(3, sqlTime);

ResultSet s = selfCheck.executeQuery();

if (s.next()) {
    message = "You already have an appointment at this time.";
    response.sendRedirect(
    	    request.getContextPath()
    	    + "/Services/Doctor/DoctorAppt/DoctorDetails.jsp?id=" 
    	    + doctorId 
    	    + "&msg=" 
    	    + java.net.URLEncoder.encode(message, "UTF-8")
    	);

    return;
}

/* ==========================================================
   VALIDATION 2: DOCTOR BOOKED CHECK
========================================================== */
PreparedStatement conflict = conn.prepareStatement(
    "SELECT 1 FROM doctor_appointment " +
    "WHERE doctor_id=? AND appointment_date=? AND appointment_time=?"
);
conflict.setString(1, doctorId);
conflict.setDate(2, sqlDate);
conflict.setTime(3, sqlTime);

ResultSet c = conflict.executeQuery();

if (c.next()) {
    message = "This time slot is already booked by another patient.";
    response.sendRedirect(
    	    request.getContextPath()
    	    + "/Services/Doctor/DoctorAppt/DoctorDetails.jsp?id=" 
    	    + doctorId 
    	    + "&msg=" 
    	    + java.net.URLEncoder.encode(message, "UTF-8")
    	);

    return;
}

/* ==========================================================
   LOAD DOCTOR NAME + BASE PRICE
========================================================== */
PreparedStatement psDoc = conn.prepareStatement(
    "SELECT name, base_price FROM doctor WHERE id=?"
);
psDoc.setString(1, doctorId);
ResultSet doc = psDoc.executeQuery();
doc.next();

String doctorName = doc.getString("name");
double basePrice  = doc.getDouble("base_price");

/* ==========================================================
   LOAD SELECTED PACKAGE
========================================================== */
PreparedStatement psPkg = conn.prepareStatement(
    "SELECT package_name, adjust_type, adjust_value " +
    "FROM doctor_package WHERE id=? AND is_active=1"
);
psPkg.setString(1, packageId);
ResultSet pkg = psPkg.executeQuery();

if (!pkg.next()) {
    message = "Invalid package selected.";
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId + "&msg=" +
         java.net.URLEncoder.encode(message, "UTF-8"));
    return;
}

String packageName = pkg.getString("package_name");
String type        = pkg.getString("adjust_type");
double val         = pkg.getDouble("adjust_value");

/* ==========================================================
   CALCULATE FINAL PRICE
========================================================== */
double finalPrice = basePrice;

if ("FLAT".equals(type)) {
    finalPrice = basePrice + val;
} else if ("PERCENT".equals(type)) {
    finalPrice = basePrice + (basePrice * val / 100.0);
}

/* ==========================================================
   INSERT APPOINTMENT
========================================================== */
PreparedStatement insert = conn.prepareStatement(
    "INSERT INTO doctor_appointment " +
    "(member_id, doctor_id, appointment_date, appointment_time, package_id, final_price) " +
    "VALUES (?,?,?,?,?,?)"
);

insert.setInt(1, memberId);
insert.setString(2, doctorId);
insert.setDate(3, sqlDate);
insert.setTime(4, sqlTime);
insert.setString(5, packageId);
insert.setDouble(6, finalPrice);
insert.executeUpdate();

conn.close();

/* ==========================================================
   REDIRECT TO SUCCESS PAGE
========================================================== */
response.sendRedirect("BookingSuccess.jsp"
    + "?doctor="  + java.net.URLEncoder.encode(doctorName, "UTF-8")
    + "&date="    + dateStr
    + "&time="    + timeStr
    + "&package=" + java.net.URLEncoder.encode(packageName, "UTF-8")
    + "&price="   + finalPrice);
%>
