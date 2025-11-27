<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>
<%
/* ==========================================================
   BACKEND: UPDATE REVIEW ACTION
   - User submits edit review form from DoctorDetails.html
   - This JSP:
       1. Reads the form data
       2. Checks if user owns the review
       3. Updates the review
       4. Redirects back to DoctorDetails.html
   NOTE:
   - DO NOT place any HTML here.
   - This is backend logic only.
   ========================================================== */

request.setCharacterEncoding("UTF-8");

String doctorId = request.getParameter("doctor_id");
String reviewId = request.getParameter("review_id");
String updatedText = request.getParameter("review_text");

Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) memberId = 1;  // Temporary fallback for testing

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
   BUSINESS RULE:
   Only the author can update their review.
   ========================================================== */
PreparedStatement checkOwner = conn.prepareStatement(
    "SELECT * FROM doctor_review WHERE id=? AND member_id=?"
);
checkOwner.setString(1, reviewId);
checkOwner.setInt(2, memberId);
ResultSet rs = checkOwner.executeQuery();

if (!rs.next()) {
    // User does NOT own the review → Reject action
    message = "You can only edit your own review.";
} else {

    /* ==========================================================
       PERFORM THE UPDATE
       ========================================================== */
    PreparedStatement update = conn.prepareStatement(
        "UPDATE doctor_review SET review_text=? WHERE id=?"
    );
    update.setString(1, updatedText);
    update.setString(2, reviewId);
    update.executeUpdate();

    message = "Review updated successfully!";
}

conn.close();

/* ==========================================================
   REDIRECT BACK TO FRONTEND
   Message is passed via URL for display.
   ========================================================== */

message = java.net.URLEncoder.encode(message, "UTF-8");
response.sendRedirect("DoctorDetails.html?id=" + doctorId + "&msg=" + message);
%>
