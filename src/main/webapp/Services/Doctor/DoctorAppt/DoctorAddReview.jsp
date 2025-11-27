<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>
<%
/* ==========================================================
   BACKEND: ADD REVIEW ACTION
   This page receives form submission from DoctorDetails.html.
   It must NOT contain any HTML layout.
   Only:
   1. Read form data
   2. Validate rules
   3. Insert into DB
   4. Redirect back to DoctorDetails.html
   ========================================================== */

request.setCharacterEncoding("UTF-8");

String doctorId = request.getParameter("doctor_id");
String rating = request.getParameter("rating");
String reviewText = request.getParameter("review_text");

Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) memberId = 1; // TEMP fallback

String message = "";

/* ==========================================================
   CONNECT TO DATABASE
   ========================================================== */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

/* ==========================================================
   BUSINESS RULE: Only 1 review per user per doctor
   ========================================================== */
PreparedStatement check = conn.prepareStatement(
    "SELECT * FROM doctor_review WHERE doctor_id=? AND member_id=?"
);
check.setString(1, doctorId);
check.setInt(2, memberId);
ResultSet rs = check.executeQuery();

if (rs.next()) {
    message = "You already wrote a review.";
} else {

    /* ==========================================================
       ADD THE REVIEW
       ========================================================== */
    PreparedStatement add = conn.prepareStatement(
        "INSERT INTO doctor_review (doctor_id, member_id, reviewer_name, rating, review_text) VALUES (?,?,?,?,?)"
    );
    add.setString(1, doctorId);
    add.setInt(2, memberId);
    add.setString(3, "User " + memberId);
    add.setString(4, rating);
    add.setString(5, reviewText);
    add.executeUpdate();

    message = "Review added successfully!";
}

conn.close();

/* ==========================================================
   REDIRECT BACK TO FRONTEND PAGE
   Pass message as URL parameter for notification
   ========================================================== */

// Encode message for URL
message = java.net.URLEncoder.encode(message, "UTF-8");

response.sendRedirect("DoctorDetails.html?id=" + doctorId + "&msg=" + message);
%>
