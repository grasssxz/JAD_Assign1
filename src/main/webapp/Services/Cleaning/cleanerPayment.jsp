<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.*" %>


<%
/* ==== AUTH GUARD (BLOCK BYPASS) ==== */
Integer memberIdObj = (Integer) session.getAttribute("member_id");
if (memberIdObj == null) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}
int memberId = memberIdObj; // safe to use as int now

String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

String ctx = request.getContextPath();

/* ==== DB CONNECTION ==== */
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Connection conn = DriverManager.getConnection(connURL);

/* ==== PROFILE PIC ==== */
String profilePic = ctx + "/home/Images/profile.jpg";

PreparedStatement psUser = conn.prepareStatement(
    "SELECT profile_pic FROM member WHERE id = ?"
);
psUser.setInt(1, memberId);
ResultSet rsUser = psUser.executeQuery();

if (rsUser.next()) {
    String pp = rsUser.getString("profile_pic");
    if (pp != null && !pp.isEmpty()) {
        profilePic = ctx + "/home/Images/" + pp;
    }
}
rsUser.close();
psUser.close();
/* ==== READ PARAMS ==== */
String cleanerIdParam      = request.getParameter("cleanerId");
String cleaningTypeIdParam = request.getParameter("cleaningTypeId");
String hoursParam          = request.getParameter("hours");
String dateParam           = request.getParameter("date");

/* shared variables for whole page */
String message = null;
boolean fullyBooked = false;

int cleanerId = -1;
int cleaningTypeId = -1;
int hours = 0;
java.sql.Date serviceDate = null;


double hourlyRate = 0.0;
double amount = 0.0;
String cleaningType = null;

/* ==== VALIDATE + LOAD RATE + CHECK CAPACITY ==== */

// Check that all required params are present and not empty
boolean hasAllParams =
    cleanerIdParam != null && !cleanerIdParam.isEmpty() &&
    cleaningTypeIdParam != null && !cleaningTypeIdParam.isEmpty() &&
    hoursParam != null && !hoursParam.isEmpty() &&
    dateParam != null && !dateParam.isEmpty();

try {
    if (hasAllParams) {

        cleanerId      = Integer.parseInt(cleanerIdParam);
        cleaningTypeId = Integer.parseInt(cleaningTypeIdParam);
        hours          = Integer.parseInt(hoursParam);
        serviceDate    = java.sql.Date.valueOf(dateParam);
        
        //net incase it is bypassed in bookCleaner
        LocalDate today = LocalDate.now();
        if (serviceDate.toLocalDate().isBefore(today)) {
            message = "You cannot book a cleaner in the past. Please pick a future date.";
            out.print("<script>alert('You cannot book a cleaner in the past. Please pick a future date.');"
                    + "window.location.href='" + ctx + "/Services/Cleaning/bookCleaner.jsp"
                    + "?cleanerId=" + cleanerId
                    + "&cleaningTypeId=" + cleaningTypeId
                    + "';</script>");
            return;
        }


        // 1) hourly rate
        PreparedStatement psRate = conn.prepareStatement(
        	    "SELECT (c.base_hourly_pay + ct.pay_increment) AS hourly_rate, " +
        	    "       ct.name AS cleaning_type " +
        	    "FROM cleaner c " +
        	    "JOIN cleaner_cleaning_type cct ON c.id = cct.cleaner_id " +
        	    "JOIN cleaning_type ct ON cct.cleaning_type_id = ct.id " +
        	    "WHERE c.id = ? AND ct.id = ?"
        	);
        	psRate.setInt(1, cleanerId);
        	psRate.setInt(2, cleaningTypeId);
        	ResultSet rsRate = psRate.executeQuery();

        	if (rsRate.next()) {
        	    hourlyRate   = rsRate.getDouble("hourly_rate");
        	    amount       = hourlyRate * hours;
        	    cleaningType = rsRate.getString("cleaning_type");   // ★ name here
        	} else {
        	    message = "Cleaner or cleaning type not found.";
        	}

        	rsRate.close();
        	psRate.close();

        // 2) capacity check (dynamic using cleaner.max_booking_per_day)

        // 2a) how many bookings already for that cleaner on that date
        PreparedStatement psCheck = conn.prepareStatement(
            "SELECT COUNT(*) AS total " +
            "FROM cleaner_booking " +
            "WHERE cleaner_id = ? AND date = ?"
        );
        psCheck.setInt(1, cleanerId);
        psCheck.setDate(2, serviceDate);
        ResultSet rsCheck = psCheck.executeQuery();

        int total = 0;
        if (rsCheck.next()) total = rsCheck.getInt("total");

        rsCheck.close();
        psCheck.close();

        // 2b) get this cleaner's max per day
        PreparedStatement psLimit = conn.prepareStatement(
            "SELECT max_booking_per_day FROM cleaner WHERE id = ?"
        );
        psLimit.setInt(1, cleanerId);
        ResultSet rsLimit = psLimit.executeQuery();

        int maxPerDay = 10;   // fallback default, just in case
        if (rsLimit.next()) {
            maxPerDay = rsLimit.getInt("max_booking_per_day");
        }

        rsLimit.close();
        psLimit.close();

        // 2c) compare
        if (total >= maxPerDay) {
            message = "This cleaner is fully booked on that date.";

            out.print("<script>alert('This cleaner is fully booked on that date.'); "
                    + "window.location.href='" + ctx + "/Services/Cleaning/bookCleaner.jsp"
                    + "?cleanerId=" + cleanerId
                    + "&cleaningTypeId=" + cleaningTypeId
                    + "';</script>");
            return;
        }


    } else {
        message = "Missing booking information.";
    }
} catch (Exception e) {
    message = "Error: " + e.getMessage();
    e.printStackTrace();
}

/* ==== AFTER PAYMENT ==== */
int bookingId = -1;
String paymentStatus = null;
Timestamp paidAt = null;

/* ==== HANDLE PAY (POST) ==== */
if ("POST".equalsIgnoreCase(request.getMethod()) &&
    request.getParameter("doPay") != null &&
    !fullyBooked &&
    message == null) {

    try {
        PreparedStatement psInsertBooking = conn.prepareStatement(
            "INSERT INTO cleaner_booking " +
            "(cleaner_id, member_id, cleaning_type_id, hours, date, status) " +
            "VALUES (?, ?, ?, ?, ?, 'paid')",
            Statement.RETURN_GENERATED_KEYS
        );
        psInsertBooking.setInt(1, cleanerId);
        psInsertBooking.setInt(2, memberId);
        psInsertBooking.setInt(3, cleaningTypeId);
        psInsertBooking.setInt(4, hours);
        psInsertBooking.setDate(5, serviceDate);

        int rows = psInsertBooking.executeUpdate();
        if (rows > 0) {
            ResultSet rsKey = psInsertBooking.getGeneratedKeys();
            if (rsKey.next()) bookingId = rsKey.getInt(1);
            rsKey.close();
        }
        psInsertBooking.close();

        if (bookingId > 0) {
            PreparedStatement psPay = conn.prepareStatement(
                "INSERT INTO cleaner_payment (booking_id, amount, status, paid_at) " +
                "VALUES (?, ?, 'paid', NOW())"
            );
            psPay.setInt(1, bookingId);
            psPay.setDouble(2, amount);
            psPay.executeUpdate();
            psPay.close();

            PreparedStatement psPayInfo = conn.prepareStatement(
                "SELECT status, paid_at FROM cleaner_payment " +
                "WHERE booking_id = ? ORDER BY id DESC LIMIT 1"
            );
            psPayInfo.setInt(1, bookingId);
            ResultSet rsPayInfo = psPayInfo.executeQuery();
            if (rsPayInfo.next()) {
                paymentStatus = rsPayInfo.getString("status");
                paidAt = rsPayInfo.getTimestamp("paid_at");
            }
            rsPayInfo.close();
            psPayInfo.close();

            message = "Payment successful! Booking confirmed.";
        } else {
            message = "Unable to create booking.";
        }

    } catch (Exception e) {
        message = "Payment error: " + e.getMessage();
        e.printStackTrace();
    }
}

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Cleaner Payment</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/Services/Cleaning/bookCleaner.css">
</head>
<body>
<jsp:include page="/home/NavBar.jsp"/>

<section class="profile">
  <img class="avatar" src="<%= profilePic %>" />
  <span class="name"><%= username %></span>
</section>

<div class="page-wrap">
  <main class="cleaner-section">
    <h2 class="page-title">Cleaner Payment</h2>

    <% if (message != null) { %>
      <p style="color: red;"><%= message %></p>
    <% } %>
    
    
 <a class="btn" href="<%=request.getContextPath()%>/home/HomePage.jsp">
  ← Back to Home Page
</a>
    <h3>Booking Summary</h3>
<ul>
  <li>Cleaner ID: <%= cleanerId %></li>
  <li>Cleaning Type: 
    <%= cleaningType != null ? cleaningType : ("ID " + cleaningTypeId) %>
  </li>
  <li>Date: <%= serviceDate %></li>
  <li>Hours: <%= hours %></li>
  <li>Hourly rate: S$ <%= String.format("%.2f", hourlyRate) %></li>
  <li>Amount: <strong>S$ <%= String.format("%.2f", amount) %></strong></li>
</ul>

    <% if (!fullyBooked && bookingId == -1 && message == null) { %>
      <form method="post" action="<%= ctx %>/Services/Cleaning/cleanerPayment.jsp">
        <input type="hidden" name="cleanerId" value="<%= cleanerId %>">
        <input type="hidden" name="cleaningTypeId" value="<%= cleaningTypeId %>">
        <input type="hidden" name="date" value="<%= serviceDate %>">
        <input type="hidden" name="hours" value="<%= hours %>">
        <button type="submit" name="doPay" value="1" class="pay-btn">Pay now</button>
      </form>
    <% } %>

    <% if (bookingId > 0) { %>
      <h3>Payment Details</h3>
      <ul>
        <li>Booking ID: <%= bookingId %></li>
        <li>Amount: S$ <%= String.format("%.2f", amount) %></li>
        <li>Status: <%= paymentStatus %></li>
        <li>Paid at: <%= paidAt %></li>
      </ul>
    <% } %>

  </main>
</div>

<%
conn.close();
%>
</body>
</html>