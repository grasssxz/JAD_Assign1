<%@ page import="java.sql.*" %>
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%
String id = request.getParameter("id");

if (id == null) {
    response.sendRedirect("AdminReviews.jsp?msg=Missing+review+ID");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root", "1G9r5a6c1E**"
);

/* Delete replies first */
PreparedStatement ps1 = conn.prepareStatement(
    "DELETE FROM doctor_review_reply WHERE review_id=?"
);
ps1.setString(1, id);
ps1.executeUpdate();

/* Delete the review */
PreparedStatement ps2 = conn.prepareStatement(
    "DELETE FROM doctor_review WHERE id=?"
);
ps2.setString(1, id);
ps2.executeUpdate();

conn.close();

response.sendRedirect("AdminReviews.jsp?msg=Review+deleted");
%>
