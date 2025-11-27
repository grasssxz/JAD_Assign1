<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>
<%
/* ==========================================================
   BACKEND: ADD A REPLY TO A REVIEW
   - Receives reply submission from DoctorDetails.html
   - This JSP:
        1. Reads review_id, doctor_id, reply text
        2. Ensures user does not reply to their own review
        3. Inserts reply into doctor_review_reply table
        4. Redirects back to DoctorDetails.html
   ========================================================== */

request.setCharacterEncoding("UTF-8");

String doctorId = request.getParameter("doctor_id");
String reviewId = request.getParameter("review_id");
String replyText = request.getParameter("reply_text");

Integer memberId = (Integer) session.getAttribute("member_id");
if (memberId == null) memberId = 1;  // fallback if not logged in

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
   User CANNOT reply to their own review.
   ========================================================== */

PreparedStatement getReview = conn.prepareStatement(
    "SELECT member_id FROM doctor_review WHERE id=?"
);
getReview.setString(1, reviewId);
ResultSet revOwner = getReview.executeQuery();
revOwner.next();

int ownerId = revOwner.getInt("member_id");

if (ownerId == memberId) {
    message = "You cannot reply to your own review.";
} else {

    /* ==========================================================
       INSERT THE REPLY
       ========================================================== */
    PreparedStatement add = conn.prepareStatement(
        "INSERT INTO doctor_review_reply (review_id, member_id, replier_name, reply_text) VALUES (?,?,?,?)"
    );

    add.setString(1, reviewId);
    add.setInt(2, memberId);
    add.setString(3, "User " + memberId);
    add.setString(4, replyText);
    add.executeUpdate();

    message = "Reply added successfully!";
}

conn.close();

/* ==========================================================
   REDIRECT BACK TO FRONTEND DOCTOR DETAILS PAGE
   ========================================================== */

message = java.net.URLEncoder.encode(message, "UTF-8");
response.sendRedirect("DoctorDetails.html?id=" + doctorId + "&msg=" + message);
%>
