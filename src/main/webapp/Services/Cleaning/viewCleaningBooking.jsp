<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>

<%
/* ===============================
   1. DB CONNECTION
================================*/
Class.forName("com.mysql.cj.jdbc.Driver");
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

/* ===============================
   2. GET MEMBER ID FROM SESSION
================================*/
Integer memberId = (Integer) session.getAttribute("member_id");

if (memberId == null) {
    response.sendRedirect(ctx + "/login/login.html");
    return;
}

/* ===============================
   3. LOAD BOOKINGS FOR THIS MEMBER
================================*/
PreparedStatement ps = conn.prepareStatement(
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
ps.setInt(1, memberId);
ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Cleaning Bookings</title>

<style>
body {
  font-family: Arial;
  background: #f5f6fa;
  padding: 20px;
}

h1 {
  margin-bottom: 10px;
}

.booking-card {
  background: white;
  border-radius: 14px;
  padding: 16px;
  margin-bottom: 18px;
  box-shadow: 0 3px 8px rgba(0,0,0,0.1);
  display: flex;
  gap: 16px;
}

.book-img {
  width: 110px;
  height: 110px;
  border-radius: 12px;
  object-fit: cover;
}

.status-box {
  font-weight: bold;
  margin-top: 4px;
}

.paid { color: #0b7a38; }
.pending { color: #c47f00; }
.failed { color: #b00020; }

.pay-btn {
  margin-top: 8px;
  background: #7f9cf5;
  padding: 6px 12px;
  color: white;
  text-decoration: none;
  border-radius: 6px;
  display: inline-block;
}

.pay-btn:hover {
  background: #5e7ce0;
}
</style>

</head>
<body>

<h1>My Cleaning Bookings</h1>
<a class="btn" 
   style="background:#64748b; color:white;"
   href="<%=request.getContextPath()%>/home/HomePage.jsp">
    ← Back to Home Page
</a>
<%
boolean hasBookings = false;

while (rs.next()) {
    hasBookings = true;

    int bookingId = rs.getInt("booking_id");
    String date = rs.getString("date");
    int hours = rs.getInt("hours");
    String type = rs.getString("cleaning_type_name");
    String cleanerName = rs.getString("cleaner_name");
    String profileUrl = rs.getString("profile_url");

    String bookingStatus = rs.getString("booking_status");

    Double amount = rs.getDouble("amount");
    if (rs.wasNull()) amount = null;

    String paymentStatus = rs.getString("payment_status");
    Timestamp paidAt = rs.getTimestamp("paid_at");
    String paidAtStr = "-";
    if (paidAt != null) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        paidAtStr = sdf.format(paidAt);
    }

%>

<div class="booking-card">

  <!-- Cleaner image -->
  <img class="book-img" src="<%= ctx %>/Services/Cleaning/Images/<%= profileUrl %>" />

  <div>
    <h3><%= type %></h3>
    <p><strong>Cleaner:</strong> <%= cleanerName %></p>
    <p><strong>Date:</strong> <%= date %></p>
    <p><strong>Hours:</strong> <%= hours %></p>

    <p class="status-box <%= bookingStatus %>">
      Booking Status: <%= bookingStatus %>
    </p>

    <p>
      <strong>Amount:</strong> 
      <%= amount != null ? "$" + String.format("%.2f", amount) : "-" %>
    </p>

    <p class="status-box 
        <%= "paid".equals(paymentStatus) ? "paid" : 
            "failed".equals(paymentStatus) ? "failed" : "pending" %>">
      Payment Status: <%= paymentStatus != null ? paymentStatus : "-" %>
      <br>
       Paid at: <%= paidAtStr %>
    

    <% if (!"paid".equals(paymentStatus)) { %>
      <a class="pay-btn" href="<%= ctx %>/Services/Cleaning/cleanerPayment.jsp?bookingId=<%= bookingId %>">
        Pay Now
      </a>
    <% } %>
  </div>

</div>

<% } // end loop %>

<%
if (!hasBookings) {
%>
  <p>You have no bookings yet.</p>
<%
}
%>

<%
rs.close();
ps.close();
conn.close();
%>

</body>
</html>
