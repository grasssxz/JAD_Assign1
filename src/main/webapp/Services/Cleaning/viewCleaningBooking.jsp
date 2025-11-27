<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>

<%
/* ===============================
   1. DB CONNECTION
================================*/
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
String pageMessage = null;

/* ===============================
3. HANDLE CANCEL (DELETE) BOOKING
================================*/
String action = request.getParameter("action");
String cancelIdParam = request.getParameter("bookingId");

if ("cancel".equals(action) && cancelIdParam != null) {
 try {
     int cancelId = Integer.parseInt(cancelIdParam);

     // Check that this booking belongs to this member and is not paid
     PreparedStatement psCheck = conn.prepareStatement(
         "SELECT cb.member_id, COALESCE(cp.status, 'pending') AS pay_status " +
         "FROM cleaner_booking cb " +
         "LEFT JOIN cleaner_payment cp ON cp.booking_id = cb.id " +
         "WHERE cb.id = ?"
     );
     psCheck.setInt(1, cancelId);
     ResultSet rsCheck = psCheck.executeQuery();

     boolean canDelete = false;
     String payStatus = null;
     int ownerId = -1;

     if (rsCheck.next()) {
    	    ownerId   = rsCheck.getInt("member_id");
    	    payStatus = rsCheck.getString("pay_status");
    	    
    	    // allow owner to delete regardless of payment
    	    if (ownerId == memberId) {
    	        canDelete = true;
    	    }
    	}

     rsCheck.close();
     psCheck.close();

     if (canDelete) {
         // Delete any payments linked to this booking (safe in case there is a row)
         PreparedStatement psDelPay = conn.prepareStatement(
             "DELETE FROM cleaner_payment WHERE booking_id = ?"
         );
         psDelPay.setInt(1, cancelId);
         psDelPay.executeUpdate();
         psDelPay.close();

         // Now delete the booking itself, only if it's mine
         PreparedStatement psDelBook = conn.prepareStatement(
             "DELETE FROM cleaner_booking WHERE id = ? AND member_id = ?"
         );
         psDelBook.setInt(1, cancelId);
         psDelBook.setInt(2, memberId);
         psDelBook.executeUpdate();
         psDelBook.close();

         pageMessage = "Booking cancelled successfully.";
     } else {
         if ("paid".equalsIgnoreCase(payStatus)) {
             pageMessage = "You cannot cancel a paid booking.";
         } else {
             pageMessage = "Booking not found or not owned by you.";
         }
     }

 } catch (Exception e) {
     pageMessage = "Error cancelling booking: " + e.getMessage();
 }
}

/* ===============================
   4. LOAD BOOKINGS FOR THIS MEMBER
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

<% if (pageMessage != null) { %>
  <p style="color:#c0392b; font-weight:bold;"><%= pageMessage %></p>
<% } %>

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

  <img class="book-img" src="<%= ctx %>/Services/Cleaning/Images/<%= profileUrl %>" />

  <div>
    <h3><%= type %></h3>
    <p><strong>Cleaner:</strong> <%= cleanerName %></p>
    <p><strong>Date:</strong> <%= date %></p>
    <p><strong>Hours:</strong> <%= hours %></p>

    <p class="status-box <%= bookingStatus %>">
      Booking Status: <%= bookingStatus %>
    </p>

    <p><strong>Amount:</strong> 
      <%= amount != null ? "$" + String.format("%.2f", amount) : "-" %>
    </p>

        <% if (!"paid".equals(paymentStatus)) { %>
      <a class="pay-btn" href="<%= ctx %>/Services/Cleaning/cleanerPayment.jsp?bookingId=<%= bookingId %>">
        Pay Now
      </a>
    <% } %>

    <!-- Always allow cancel (your server-side will double-check anyway) -->
    <form method="post"
          action="<%= ctx %>/Services/Cleaning/viewCleaningBooking.jsp"
          style="display:inline-block; margin-left:8px;"
          onsubmit="return confirm('Cancel this booking?');">
      <input type="hidden" name="action" value="cancel">
      <input type="hidden" name="bookingId" value="<%= bookingId %>">
      <button type="submit"
              style="background:#e11d48; color:white; border:none; border-radius:6px; padding:6px 12px; cursor:pointer;">
        Cancel Booking
      </button>
    </form>


  </div>
</div>

<%
} // <-- CLOSE THE WHILE LOOP PROPERLY!!!!

if (!hasBookings) {
%>
  <p>You have no bookings yet.</p>
<%
}

rs.close();
ps.close();
conn.close();
%>


</body>
</html>