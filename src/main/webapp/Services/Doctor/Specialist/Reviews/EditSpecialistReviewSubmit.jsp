<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

Integer memberId = (Integer) session.getAttribute("member_id");
String reviewId  = request.getParameter("id");
String clinicId  = request.getParameter("clinic_id");
String rating    = request.getParameter("rating");
String text      = request.getParameter("review_text");

if (memberId == null || reviewId == null || clinicId == null) {
    response.sendRedirect("../SpecialistDetails.jsp?id=" + clinicId +
        "&msg=Invalid review update.");
    return;
}

// ===========================
// DB CONNECTION
// ===========================
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

// ===========================
// Ensure the member OWNS this review
// ===========================
PreparedStatement check = conn.prepareStatement(
    "SELECT member_id FROM specialist_review WHERE id=?"
);
check.setString(1, reviewId);
ResultSet rs = check.executeQuery();

if (!rs.next() || rs.getInt("member_id") != memberId) {
    conn.close();
    response.sendRedirect("../SpecialistDetails.jsp?id=" + clinicId +
        "&msg=You cannot edit someone else's review.");
    return;
}

// ===========================
// UPDATE REVIEW
// ===========================
PreparedStatement ps = conn.prepareStatement(
    "UPDATE specialist_review SET rating=?, review_text=?, updated_at=NOW() WHERE id=?"
);
ps.setInt(1, Integer.parseInt(rating));
ps.setString(2, text);
ps.setString(3, reviewId);

ps.executeUpdate();
conn.close();

// ===========================
// REDIRECT BACK
// ===========================
response.sendRedirect("../SpecialistDetails.jsp?id=" + clinicId + "&msg=Review updated successfully.");
%>
