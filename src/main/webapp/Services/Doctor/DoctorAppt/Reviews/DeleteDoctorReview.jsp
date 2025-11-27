<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
String reviewId = request.getParameter("id");
String doctorId = request.getParameter("doctor_id");
Integer memberId = (Integer) session.getAttribute("member_id");

if (reviewId == null || doctorId == null) {
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId);
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

/* Ensure user owns review */
PreparedStatement check = conn.prepareStatement(
    "SELECT 1 FROM doctor_review WHERE id=? AND member_id=?"
);
check.setString(1, reviewId);
check.setInt(2, memberId);
ResultSet rs = check.executeQuery();

if (!rs.next()) {
    conn.close();
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId);
    return;
}

/* Delete replies */
PreparedStatement delRep = conn.prepareStatement(
    "DELETE FROM doctor_review_reply WHERE review_id=?"
);
delRep.setString(1, reviewId);
delRep.executeUpdate();

/* Delete review */
PreparedStatement del = conn.prepareStatement(
    "DELETE FROM doctor_review WHERE id=?"
);
del.setString(1, reviewId);
del.executeUpdate();

conn.close();

response.sendRedirect("../DoctorDetails.jsp?id=" + doctorId + "&msg=Review+deleted");



%>
