<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>

<%
String reviewId = request.getParameter("id");
String clinicId = request.getParameter("clinic_id");
Integer memberId = (Integer) session.getAttribute("member_id");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// Ensure user owns the review
PreparedStatement ps = conn.prepareStatement(
    "DELETE FROM specialist_review WHERE id=? AND member_id=?"
);
ps.setString(1, reviewId);
ps.setInt(2, memberId);

ps.executeUpdate();
conn.close();

response.sendRedirect("../SpecialistDetails.jsp?id=" + clinicId + "&msg=Review deleted.");
%>
