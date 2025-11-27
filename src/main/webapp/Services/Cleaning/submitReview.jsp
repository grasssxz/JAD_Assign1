<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
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

/* ==== GET MEMBER FROM SESSION (AUTH GUARD) ==== */
Integer memberIdObj = (Integer) session.getAttribute("member_id");
if (memberIdObj == null) {
    response.sendRedirect(ctx + "/login/login.html");
    conn.close();
    return;
}
int memberId = memberIdObj;   // safe unboxing

/* ==== READ FORM FIELDS ==== */
int cleanerId = Integer.parseInt(request.getParameter("cleanerId"));
int cleaningTypeId = Integer.parseInt(request.getParameter("cleaningTypeId"));
String reviewText = request.getParameter("review_text");

/* ==== CHECK IF USER HAS PAID BOOKING ==== */
PreparedStatement psCheck = conn.prepareStatement(
    "SELECT COUNT(*) FROM cleaner_booking " +
    "WHERE member_id = ? AND cleaner_id = ? " +
    "AND cleaning_type_id = ? AND status = 'paid'"
);
psCheck.setInt(1, memberId);
psCheck.setInt(2, cleanerId);
psCheck.setInt(3, cleaningTypeId);
ResultSet rsCheck = psCheck.executeQuery();
rsCheck.next();

if (rsCheck.getInt(1) == 0) {
    rsCheck.close();
    psCheck.close();
    conn.close();
    out.println("You cannot review this cleaner because you have not booked them before.");
    return;
}
rsCheck.close();
psCheck.close();

/* ==== INSERT REVIEW ==== */
PreparedStatement psInsert = conn.prepareStatement(
    "INSERT INTO cleaning_review (cleaning_type_id, cleaner_id, member_id, review_text) " +
    "VALUES (?, ?, ?, ?)"
);
psInsert.setInt(1, cleaningTypeId);
psInsert.setInt(2, cleanerId);
psInsert.setInt(3, memberId);
psInsert.setString(4, reviewText);
psInsert.executeUpdate();
psInsert.close();

conn.close();

/* ==== REDIRECT BACK TO HOUSEKEEPING PAGE ==== */
response.sendRedirect(ctx + "/Services/Cleaning/HouseKeeping.jsp");
%>

