<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Connection conn = DriverManager.getConnection(connURL);

String ctx = request.getContextPath();

// logged in user (for security)
Integer myIdObj = (Integer) session.getAttribute("member_id");
if (myIdObj == null) {
    response.sendRedirect(ctx + "/login/login.html");
    return;
}
int myId = myIdObj;

// which family member to view
String memberIdParam = request.getParameter("memberId");
int targetMemberId = -1;
try {
    targetMemberId = Integer.parseInt(memberIdParam);
} catch (Exception e) {
    targetMemberId = -1;
}

String message = null;
String targetUsername = null;

// check that target member is in the same family as me
Integer myFamilyId = null;
Integer targetFamilyId = null;

/* ===============================
   MY FAMILY ID  (FIXED CAST)
================================*/
PreparedStatement psMy = conn.prepareStatement(
    "SELECT family_id FROM member WHERE id = ?"
);
psMy.setInt(1, myId);
ResultSet rsMy = psMy.executeQuery();
if (rsMy.next()) {
    Object famObj = rsMy.getObject("family_id");
    if (famObj != null) {
        myFamilyId = ((Number) famObj).intValue();
    }
}
rsMy.close();
psMy.close();

/* ===============================
   TARGET FAMILY ID (FIXED CAST)
================================*/
PreparedStatement psTarget = conn.prepareStatement(
    "SELECT family_id, username FROM member WHERE id = ?"
);
psTarget.setInt(1, targetMemberId);
ResultSet rsTarget = psTarget.executeQuery();
if (rsTarget.next()) {
    Object famObj2 = rsTarget.getObject("family_id");
    if (famObj2 != null) {
        targetFamilyId = ((Number) famObj2).intValue();
    }
    targetUsername = rsTarget.getString("username");
}
rsTarget.close();
psTarget.close();

/* ===============================
   CHECK AUTHORIZATION
================================*/
if (myFamilyId == null || targetFamilyId == null || !myFamilyId.equals(targetFamilyId)) {
    message = "You are not allowed to view this member's bookings.";
}

/* ===============================
   PREPARE QUERY HANDLES
================================*/
PreparedStatement psCleaner = null;
PreparedStatement psGro     = null;
PreparedStatement psTrans   = null;
PreparedStatement psDoc     = null;

ResultSet rsCleaner = null;
ResultSet rsGro     = null;
ResultSet rsTrans   = null;
ResultSet rsDoc     = null;

/* ===============================
   RUN QUERIES ONLY IF AUTHORIZED
================================*/
if (message == null) {

    // CLEANER BOOKINGS
    psCleaner = conn.prepareStatement(
        "SELECT cb.id AS booking_id, cb.date, cb.hours, cb.status AS booking_status, " +
        "       c.name AS cleaner_name, c.profile_url, " +
        "       ct.name AS cleaning_type_name, " +
        "       cp.amount, cp.status AS payment_status, cp.paid_at " +
        "FROM cleaner_booking cb " +
        "JOIN cleaner c ON cb.cleaner_id = c.id " +
        "JOIN cleaning_type ct ON cb.cleaning_type_id = ct.id " +
        "LEFT JOIN cleaner_payment cp ON cp.booking_id = cb.id " +
        "WHERE cb.member_id = ? " +
        "ORDER BY cb.date DESC"
    );
    psCleaner.setInt(1, targetMemberId);
    rsCleaner = psCleaner.executeQuery();

    // GROCERY ORDERS
    psGro = conn.prepareStatement(
        "SELECT id, company_id, order_datetime, booking_date, estimated_delivery, " +
        "       total_price, status " +
        "FROM grocery_order " +
        "WHERE member_id = ? " +
        "ORDER BY order_datetime DESC"
    );
    psGro.setInt(1, targetMemberId);
    rsGro = psGro.executeQuery();

    // TRANSPORT BOOKINGS
    psTrans = conn.prepareStatement(
        "SELECT id, provider_id, booking_date, total_fee, status, created_at " +
        "FROM transport_booking " +
        "WHERE member_id = ? " +
        "ORDER BY booking_date DESC, created_at DESC"
    );
    psTrans.setInt(1, targetMemberId);
    rsTrans = psTrans.executeQuery();

    // DOCTOR APPOINTMENTS
    psDoc = conn.prepareStatement(
    "SELECT da.id, da.appointment_date, da.appointment_time, da.final_price, da.status, " +
    "       d.name AS doctor_name, p.package_name AS package_name " +
    "FROM doctor_appointment da " +
    "JOIN doctor d ON da.doctor_id = d.id " +
    "JOIN doctor_package p ON da.package_id = p.id " +
    "WHERE da.member_id = ? " +
    "ORDER BY da.appointment_date DESC, da.appointment_time DESC"
);

    psDoc.setInt(1, targetMemberId);
    rsDoc = psDoc.executeQuery();
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Family Member Bookings</title>
<style>
body{font-family:Arial;background:#f5f6fa;padding:20px}
h1{margin-bottom:10px}
h2{margin-top:24px}
.section-card {
  background:white;
  border-radius:14px;
  padding:16px;
  margin-bottom:18px;
  box-shadow:0 3px 8px rgba(0,0,0,0.06);
}
.booking-card {
  background:white;
  border-radius:14px;
  padding:12px 14px;
  margin-bottom:10px;
  box-shadow:0 1px 4px rgba(0,0,0,0.06);
}
.book-img {
  width:70px;
  height:70px;
  border-radius:12px;
  object-fit:cover;
  margin-right:10px;
  float:left;
}
.status-box{font-weight:bold;margin-top:4px}
.paid{color:#0b7a38}
.pending{color:#c47f00}
.failed{color:#b00020}
.cancelled{color:#b00020}
.completed{color:#0b7a38}

.btn-back{
  display:inline-block;
  margin-bottom:12px;
  background:#64748b;
  color:white;
  padding:6px 10px;
  border-radius:6px;
  text-decoration:none;
}
.small-label{font-weight:bold}
</style>
</head>
<body>

<a class="btn-back" href="<%= ctx %>/family/myFamily.jsp">← Back to My Family</a>

<h1>Bookings for 
  <%= (targetUsername != null ? targetUsername : ("Member " + targetMemberId)) %>
</h1>

<% if (message != null) { %>
  <p style="color:#c0392b;"><%= message %></p>
<% } else { %>

  <!-- CLEANER BOOKINGS -->
  <h2>Cleaning Bookings</h2>
  <div class="section-card">
  <%
    boolean hasCleaner = false;
    while (rsCleaner.next()) {
        hasCleaner = true;
  %>
    <div class="booking-card">
      <img class="book-img"
           src="<%= ctx %>/Services/Cleaning/Images/<%= rsCleaner.getString("profile_url") %>">
      <div>
        <p><span class="small-label">Service:</span>
           <%= rsCleaner.getString("cleaning_type_name") %></p>
        <p><span class="small-label">Cleaner:</span>
           <%= rsCleaner.getString("cleaner_name") %></p>
        <p><span class="small-label">Date:</span>
           <%= rsCleaner.getString("date") %></p>
        <p><span class="small-label">Hours:</span>
           <%= rsCleaner.getInt("hours") %></p>
        <p><span class="small-label">Amount:</span>
          <%= rsCleaner.getObject("amount") != null ?
                 "S$ " + String.format("%.2f", rsCleaner.getDouble("amount")) : "-" %>
        </p>
        <p class="status-box 
           <%= "paid".equals(rsCleaner.getString("payment_status")) ? "paid" :
               "failed".equals(rsCleaner.getString("payment_status")) ? "failed" :
               "pending" %>">
          Payment: <%= rsCleaner.getString("payment_status") != null ?
                        rsCleaner.getString("payment_status") : "-" %>
        </p>
      </div>
    </div>
  <% }
     if (!hasCleaner) { %>
     <p>No cleaning bookings found.</p>
  <% } %>
  </div>

  <!-- GROCERY ORDERS -->
  <h2>Grocery Orders</h2>
  <div class="section-card">
  <%
    boolean hasGro = false;
    while (rsGro.next()) {
        hasGro = true;
  %>
    <div class="booking-card">
      <p><span class="small-label">Order ID:</span> <%= rsGro.getInt("id") %></p>
      <p><span class="small-label">Company ID:</span> <%= rsGro.getInt("company_id") %></p>
      <p><span class="small-label">Order Time:</span> <%= rsGro.getTimestamp("order_datetime") %></p>
      <p><span class="small-label">Booking Date:</span> <%= rsGro.getDate("booking_date") %></p>
      <p><span class="small-label">Estimated Delivery:</span> <%= rsGro.getTimestamp("estimated_delivery") %></p>
      <p><span class="small-label">Total Price:</span> 
         S$ <%= String.format("%.2f", rsGro.getDouble("total_price")) %></p>
      <p class="status-box <%= rsGro.getString("status").toLowerCase() %>">
         Status: <%= rsGro.getString("status") %>
      </p>
    </div>
  <% }
     if (!hasGro) { %>
     <p>No grocery orders found.</p>
  <% } %>
  </div>

  <!-- TRANSPORT BOOKINGS -->
  <h2>Transport Bookings</h2>
  <div class="section-card">
  <%
    boolean hasTrans = false;
    while (rsTrans.next()) {
        hasTrans = true;
  %>
    <div class="booking-card">
      <p><span class="small-label">Booking ID:</span> <%= rsTrans.getInt("id") %></p>
      <p><span class="small-label">Provider ID:</span> <%= rsTrans.getInt("provider_id") %></p>
      <p><span class="small-label">Booking Date:</span> <%= rsTrans.getDate("booking_date") %></p>
      <p><span class="small-label">Total Fee:</span> 
         <%= rsTrans.getObject("total_fee") != null ?
                "S$ " + String.format("%.2f", rsTrans.getDouble("total_fee")) : "-" %></p>
      <p class="status-box <%= rsTrans.getString("status").toLowerCase() %>">
         Status: <%= rsTrans.getString("status") %>
      </p>
      <p><span class="small-label">Created At:</span> <%= rsTrans.getTimestamp("created_at") %></p>
    </div>
  <% }
     if (!hasTrans) { %>
     <p>No transport bookings found.</p>
  <% } %>
  </div>

  <!-- DOCTOR APPOINTMENTS -->
  <h2>Doctor Appointments</h2>
  <div class="section-card">
  <%
    boolean hasDoc = false;
    while (rsDoc.next()) {
        hasDoc = true;
  %>
    <div class="booking-card">
      <p><span class="small-label">Appointment ID:</span> <%= rsDoc.getInt("id") %></p>
      <p><span class="small-label">Doctor:</span> <%= rsDoc.getString("doctor_name") %></p>
      <p><span class="small-label">Package:</span> <%= rsDoc.getString("package_name") %></p>
      <p><span class="small-label">Date:</span> <%= rsDoc.getDate("appointment_date") %></p>
      <p><span class="small-label">Time:</span> <%= rsDoc.getTime("appointment_time") %></p>
      <p><span class="small-label">Final Price:</span> 
         <%= rsDoc.getObject("final_price") != null ?
                "S$ " + String.format("%.2f", rsDoc.getDouble("final_price")) : "-" %></p>
      <p class="status-box <%= rsDoc.getString("status").toLowerCase() %>">
         Status: <%= rsDoc.getString("status") %>
      </p>
     <p><span class="small-label">Appointment ID:</span> <%= rsDoc.getInt("id") %></p>
<p><span class="small-label">Doctor:</span> <%= rsDoc.getString("doctor_name") %></p>
<p><span class="small-label">Package:</span> <%= rsDoc.getString("package_name") %></p>
<p><span class="small-label">Date:</span> <%= rsDoc.getDate("appointment_date") %></p>
<p><span class="small-label">Time:</span> <%= rsDoc.getTime("appointment_time") %></p>
<p><span class="small-label">Final Price:</span> 
   <%= rsDoc.getObject("final_price") != null ?
          "S$ " + String.format("%.2f", rsDoc.getDouble("final_price")) : "-" %></p>
<p class="status-box <%= rsDoc.getString("status").toLowerCase() %>">
   Status: <%= rsDoc.getString("status") %>
</p>

    </div>
  <% }
     if (!hasDoc) { %>
     <p>No doctor appointments found.</p>
  <% } %>
  </div>

<% } // end else authorized %>

<%
if (rsCleaner != null) rsCleaner.close();
if (psCleaner != null) psCleaner.close();

if (rsGro != null) rsGro.close();
if (psGro != null) psGro.close();

if (rsTrans != null) rsTrans.close();
if (psTrans != null) psTrans.close();

if (rsDoc != null) rsDoc.close();
if (psDoc != null) psDoc.close();

conn.close();
%>

</body>
</html>
