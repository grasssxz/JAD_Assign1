<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.*" %>


<%
    String type = (String) session.getAttribute("type");
    if ("guest".equals(type)) {
        response.sendRedirect(request.getContextPath() + "/login/login.html");
        return;
    }

    Integer memberId = (Integer) session.getAttribute("member_id");
%>


<%
/* SETUP & PROFILE (same as before, if you like) */
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

String username = (String) session.getAttribute("username");
if (username == null) username = "Guest";

String ctx = request.getContextPath();
String profilePic = ctx + "/home/Images/profile.jpg";

PreparedStatement psUser = conn.prepareStatement(
    "SELECT profile_pic FROM member WHERE username = ?"
);
psUser.setString(1, username);
ResultSet rsUser = psUser.executeQuery();
if (rsUser.next()) {
    String pp = rsUser.getString("profile_pic");
    if (pp != null && !pp.isEmpty()) {
        profilePic = ctx + "/home/Images/" + pp;
    }
}
rsUser.close();
psUser.close();

/* READ PARAMS FROM PREVIOUS PAGE */
String cleanerIdParam      = request.getParameter("cleanerId");
String cleaningTypeIdParam = request.getParameter("cleaningTypeId");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Book cleaner</title>
<link rel="stylesheet" href="bookCleaner.css">
</head>
<body>
<jsp:include page="/home/NavBar.jsp"/>

<section class="profile">
  <img class="avatar" src="<%= profilePic %>" />
  <span class="name"><%= username %></span>
</section>

<div class="page-wrap">
  <main class="cleaner-section">
    <h2 class="page-title">Book your cleaner</h2>

    <!--  chooses date + hours -->
    <form method="get" action="<%= ctx %>/Services/Cleaning/cleanerPayment.jsp" class="booking-form">
      <!-- keep cleaner + service type from previous page -->
      <input type="hidden" name="cleanerId" value="<%= cleanerIdParam %>">
      <input type="hidden" name="cleaningTypeId" value="<%= cleaningTypeIdParam %>">

      <div>
        <label>Date: </label>
        <input type="date" name="date" required>
      </div>

      <div>
        <label>Hours: </label>
        <select name="hours" required>
          <option value="">-- choose --</option>
          <option value="1">1 hour</option>
          <option value="2">2 hours</option>
          <option value="3">3 hours</option>
        </select>
      </div>

      <button type="submit">Continue to Payment</button>
    </form>
  </main>
</div>

<%
conn.close();
%>
</body>
</html>
