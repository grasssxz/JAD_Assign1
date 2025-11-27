<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>
<%
/* ==========================================================
   BACKEND: DELETE REVIEW ACTION
   - Receives form submission from DoctorDetails.html
   - This JSP:
        1. Reads the review ID + doctor ID
        2. Validates that the current user is the owner
        3. Deletes all replies linked to the review
        4. Deletes the review itself
        5. Redirects back to DoctorDetails.html
   ========================================================== */

request.setCharacterEncoding("UTF-8");

String doctorId = request.getParameter("doctor_id");
String reviewId = request.getParameter("review_id");

Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) memberId = 1; // TEMP fallback

String message = "";

/* ==========================================================
   DATABASE CONNECTION
   ========================================================== */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root",
    "1G9r5a6c1E**"
);

/* ==========================================================
   BUSINESS RULE:
   Only the author can delete their review.
   ========================================================== */
PreparedStatement checkOwner = conn.prepareStatement(
    "SELECT * FROM doctor_review WHERE id=? AND member_id=?"
);
checkOwner.setString(1, reviewId);
checkOwner.setInt(2, memberId);

ResultSet rs = checkOwner.executeQuery();

if (!rs.next()) {
    // Ownership violation → reject
    message = "You can only delete your own review.";
} else {

    /* ==========================================================
       1. DELETE ALL REPLIES FIRST (business rule)
       ========================================================== */
    PreparedStatement delReplies = conn.prepareStatement(
        "DELETE FROM doctor_review_reply WHERE review_id=?"
    );
    delReplies.setString(1, reviewId);
    delReplies.executeUpdate();

    /* ==========================================================
       2. DELETE THE REVIEW
       ========================================================== */
    PreparedStatement del = conn.prepareStatement(
        "DELETE FROM doctor_review WHERE id=?"
    );
    del.setString(1, reviewId);
    del.executeUpdate();

    message = "Review deleted successfully!";
}

conn.close();

/* ==========================================================
   REDIRECT TO DOCTOR DETAILS FRONTEND PAGE
   ========================================================== */
message = java.net.URLEncoder.encode(message, "UTF-8");
response.sendRedirect("DoctorDetails.html?id=" + doctorId + "&msg=" + message);
%>
