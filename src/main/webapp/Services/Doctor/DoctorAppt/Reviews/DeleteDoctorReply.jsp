<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
String replyId = request.getParameter("id");
String doctorId = request.getParameter("doctor_id");
Integer memberId = (Integer) session.getAttribute("member_id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

/* Validate ownership */
PreparedStatement check = conn.prepareStatement(
    "SELECT 1 FROM doctor_review_reply WHERE id=? AND member_id=?"
);
check.setString(1, replyId);
check.setInt(2, memberId);
ResultSet rs = check.executeQuery();

if (!rs.next()) {
    conn.close();
    response.sendRedirect("DoctorDetails.jsp?id=" + doctorId);
    return;
}

/* Delete */
PreparedStatement del = conn.prepareStatement(
    "DELETE FROM doctor_review_reply WHERE id=?"
);
del.setString(1, replyId);
del.executeUpdate();

conn.close();

response.sendRedirect("../DoctorDetails.jsp?id=" + doctorId + "&msg=Reply+deleted");



%>
